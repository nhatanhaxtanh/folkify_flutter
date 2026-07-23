import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/bank_apps.dart';
import '../../../../core/providers/payment_provider.dart';
import '../../../../core/widgets/gradient_button.dart';

/// Màn thanh toán Pay2S — toàn bộ diễn ra trong app bằng WebView.
class Pay2sCheckoutScreen extends ConsumerStatefulWidget {
  final String plan; // "BASIC" | "PRO"
  const Pay2sCheckoutScreen({super.key, required this.plan});

  @override
  ConsumerState<Pay2sCheckoutScreen> createState() => _Pay2sCheckoutScreenState();
}

/// JS chặn nút "tải QR" của trang Pay2S (data:/blob: mà WebView bỏ qua) và
/// chuyển dữ liệu ảnh về Flutter để lưu vào thư viện.
const String _downloadInterceptJs = r"""
(function(){
  if (window.__folkifyDl) return; window.__folkifyDl = true;
  // Đọc ảnh trong đúng context của trang (blob: chỉ hợp lệ ở đây) rồi gửi base64 về Flutter.
  function sendImage(href){
    if(!href) return;
    try {
      fetch(href).then(function(r){ return r.blob(); }).then(function(b){
        var fr = new FileReader();
        fr.onloadend = function(){ window.flutter_inappwebview.callHandler('saveImage', fr.result); };
        fr.readAsDataURL(b);
      }).catch(function(){ window.flutter_inappwebview.callHandler('saveImage', href); });
    } catch(e){ window.flutter_inappwebview.callHandler('saveImage', href); }
  }
  function isImg(h){ return h && (h.indexOf('data:image')===0 || h.indexOf('blob:')===0); }
  document.addEventListener('click', function(e){
    var t = e.target;
    var a = (t && t.closest) ? t.closest('a') : null;
    if (a && (a.hasAttribute('download') || isImg(a.href))) {
      e.preventDefault(); e.stopPropagation(); sendImage(a.href);
    }
  }, true);
  var _click = HTMLAnchorElement.prototype.click;
  HTMLAnchorElement.prototype.click = function(){
    if (this.download || isImg(this.href)) { sendImage(this.href); return; }
    return _click.apply(this, arguments);
  };
})();
""";

class _Pay2sCheckoutScreenState extends ConsumerState<Pay2sCheckoutScreen> {
  InAppWebViewController? _webController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pay2sProvider.notifier).start(widget.plan);
    });
  }

  String get _planLabel => widget.plan == 'PRO' ? 'Pro' : 'Basic';

  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : const Color(0xFF16A34A),
    ));
  }

  /// Nhận ảnh QR (thường là data: base64 do JS convert sẵn) → decode → lưu thư viện ảnh.
  Future<void> _saveImageFromUrl(String url) async {
    try {
      // Nếu chưa phải data: (hiếm) thì thử convert qua JS của trang.
      if (!url.startsWith('data:')) {
        final controller = _webController;
        if (controller != null) {
          final res = await controller.callAsyncJavaScript(
            functionBody: """
              const res = await fetch(url);
              const blob = await res.blob();
              return await new Promise((resolve) => {
                const r = new FileReader();
                r.onloadend = () => resolve(r.result);
                r.readAsDataURL(blob);
              });
            """,
            arguments: {'url': url},
          );
          final d = res?.value as String?;
          if (d != null) url = d;
        }
      }
      if (!url.startsWith('data:') || !url.contains(',')) {
        _toast('Không lấy được mã QR', error: true);
        return;
      }
      final bytes = base64Decode(url.substring(url.indexOf(',') + 1));
      await Gal.putImageBytes(bytes,
          name: 'folkify_qr_${DateTime.now().millisecondsSinceEpoch}');
      _toast('Đã lưu mã QR vào thư viện ảnh');
      if (mounted) _showBankPicker();
    } on GalException catch (e) {
      _toast('Không lưu được ảnh: ${e.type.message}', error: true);
    } catch (_) {
      _toast('Không lưu được mã QR', error: true);
    }
  }

  /// Hiện danh sách ngân hàng để mở app tương ứng (quét QR đã lưu từ Thư viện).
  void _showBankPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mở app ngân hàng', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 4),
              Text(
                'Đã lưu mã QR vào Thư viện ảnh. Chọn ngân hàng rồi dùng chức năng "Quét QR từ ảnh" để thanh toán.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
                children: kBankApps.map((b) => _bankTile(ctx, b)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bankTile(BuildContext sheetCtx, BankApp bank) {
    return InkWell(
      onTap: () {
        Navigator.of(sheetCtx).pop();
        _openBank(bank);
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: bank.color,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              bank.short,
              style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            bank.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Future<void> _openBank(BankApp bank) async {
    final uri = Uri.parse('${bank.scheme}://');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        _toast('Không mở được ${bank.name}. Hãy mở app thủ công rồi quét QR đã lưu.', error: true);
      }
    } catch (_) {
      _toast('Không mở được ${bank.name}. Hãy mở app thủ công rồi quét QR đã lưu.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pay2sProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.xmark, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Thanh toán gói $_planLabel', style: AppTextStyles.headlineMedium),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(Pay2sState state) {
    switch (state.phase) {
      case Pay2sPhase.creating:
      case Pay2sPhase.idle:
        return _loading('Đang tạo giao dịch...');

      case Pay2sPhase.waiting:
        return _webViewFlow(state);

      case Pay2sPhase.success:
        return _result(
          icon: FontAwesomeIcons.circleCheck,
          color: const Color(0xFF16A34A),
          title: 'Thanh toán thành công!',
          subtitle: 'Gói $_planLabel đã được kích hoạt. Chúc bạn học vui!',
          buttonText: 'Hoàn tất',
          onPressed: () => context.pop(true),
        );

      case Pay2sPhase.expired:
        return _result(
          icon: FontAwesomeIcons.clock,
          color: AppColors.textMuted,
          title: 'Giao dịch chưa hoàn tất',
          subtitle: state.message ?? 'Vui lòng thử lại.',
          buttonText: 'Thử lại',
          onPressed: () => ref.read(pay2sProvider.notifier).start(widget.plan),
        );

      case Pay2sPhase.error:
        return _result(
          icon: FontAwesomeIcons.circleExclamation,
          color: AppColors.error,
          title: 'Có lỗi xảy ra',
          subtitle: state.message ?? 'Không thể tạo giao dịch.',
          buttonText: 'Thử lại',
          onPressed: () => ref.read(pay2sProvider.notifier).start(widget.plan),
        );
    }
  }

  Widget _webViewFlow(Pay2sState state) {
    final url = state.payUrl;
    if (url == null) return _loading('Đang mở trang thanh toán...');

    // WebView full màn hình; việc kiểm tra trạng thái chạy nền (poll trong provider).
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(url)),
      initialSettings: InAppWebViewSettings(
        useShouldOverrideUrlLoading: true,
        useOnDownloadStart: true,
        javaScriptEnabled: true,
        domStorageEnabled: true,
        supportZoom: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      onWebViewCreated: (controller) {
        _webController = controller;
        controller.addJavaScriptHandler(
          handlerName: 'saveImage',
          callback: (args) async {
            if (args.isNotEmpty && args.first is String) {
              await _saveImageFromUrl(args.first as String);
            }
            return null;
          },
        );
      },
      onLoadStop: (controller, _) =>
          controller.evaluateJavascript(source: _downloadInterceptJs),
      onDownloadStartRequest: (controller, req) =>
          _saveImageFromUrl(req.url.toString()),
      shouldOverrideUrlLoading: (controller, action) async {
        final uri = action.request.url;
        if (uri == null) return NavigationActionPolicy.ALLOW;

        // Redirect sau thanh toán / khi user bấm "Hủy giao dịch" trên trang Pay2S.
        if (uri.scheme == 'folkify' || uri.path.contains('/api/payments/result')) {
          await ref.read(pay2sProvider.notifier).checkNow(); // đợi kiểm tra xong
          // Chưa thành công → coi như hủy/quay lại → về trang subscription.
          if (ref.read(pay2sProvider).phase != Pay2sPhase.success && mounted) {
            context.pop();
          }
          return NavigationActionPolicy.CANCEL;
        }

        // Scheme app ngân hàng / momo... → mở app tương ứng (không phải trình duyệt).
        if (uri.scheme != 'http' && uri.scheme != 'https') {
          final external = Uri.parse(uri.toString());
          if (await canLaunchUrl(external)) {
            await launchUrl(external, mode: LaunchMode.externalApplication);
          }
          return NavigationActionPolicy.CANCEL;
        }

        return NavigationActionPolicy.ALLOW;
      },
    );
  }

  Widget _loading(String text) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(text, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _result({
    required FaIconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, size: 64, color: color),
            const SizedBox(height: 20),
            Text(title, style: AppTextStyles.displayMedium, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(subtitle, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            GradientButton(text: buttonText, onPressed: onPressed),
          ],
        ),
      ),
    );
  }
}
