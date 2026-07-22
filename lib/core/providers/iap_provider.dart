import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kBasicPlanId = 'com.folkify.app.basic.monthly';
const kProPlanId = 'com.folkify.app.pro.monthly';
const _kProductIds = {kBasicPlanId, kProPlanId};
const _keyActivePlan = 'folkify_active_plan';

class IapState {
  final bool isPremium;
  final String? activePlanId;
  final List<ProductDetails> products;
  final bool isStoreAvailable;
  final bool isLoading;
  final String? purchaseError;

  const IapState({
    this.isPremium = false,
    this.activePlanId,
    this.products = const [],
    this.isStoreAvailable = false,
    this.isLoading = true,
    this.purchaseError,
  });

  IapState copyWith({
    bool? isPremium,
    String? activePlanId,
    List<ProductDetails>? products,
    bool? isStoreAvailable,
    bool? isLoading,
    String? purchaseError,
    bool clearError = false,
  }) {
    return IapState(
      isPremium: isPremium ?? this.isPremium,
      activePlanId: activePlanId ?? this.activePlanId,
      products: products ?? this.products,
      isStoreAvailable: isStoreAvailable ?? this.isStoreAvailable,
      isLoading: isLoading ?? this.isLoading,
      purchaseError: clearError ? null : (purchaseError ?? this.purchaseError),
    );
  }
}

class IapNotifier extends Notifier<IapState> {
  StreamSubscription<List<PurchaseDetails>>? _sub;

  @override
  IapState build() {
    ref.onDispose(() => _sub?.cancel());
    _init();
    return const IapState();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final activePlanId = prefs.getString(_keyActivePlan);

    bool available = false;
    try {
      available = await InAppPurchase.instance.isAvailable();
    } catch (_) {
      state = IapState(
        isPremium: activePlanId != null,
        activePlanId: activePlanId,
        isStoreAvailable: false,
        isLoading: false,
      );
      return;
    }

    if (!available) {
      state = IapState(
        isPremium: activePlanId != null,
        activePlanId: activePlanId,
        isStoreAvailable: false,
        isLoading: false,
      );
      return;
    }

    _sub = InAppPurchase.instance.purchaseStream.listen(
      _handlePurchases,
      onError: (_) => state = state.copyWith(isLoading: false),
    );

    // Thử tối đa 3 lần với delay 2 giây giữa các lần
    List<ProductDetails> loaded = [];
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await InAppPurchase.instance.queryProductDetails(_kProductIds);
        if (response.productDetails.isNotEmpty) {
          loaded = response.productDetails;
          break;
        }
      } catch (_) {
        // bỏ qua, thử lại
      }
      if (attempt < 2) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    state = IapState(
      isPremium: activePlanId != null,
      activePlanId: activePlanId,
      products: loaded,
      isStoreAvailable: true,
      isLoading: false,
    );
  }

  Future<void> retryLoadProducts() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);

    List<ProductDetails> loaded = [];
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await InAppPurchase.instance.queryProductDetails(_kProductIds);
        if (response.productDetails.isNotEmpty) {
          loaded = response.productDetails;
          break;
        }
      } catch (_) {
        // bỏ qua, thử lại
      }
      if (attempt < 2) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    state = state.copyWith(
      products: loaded,
      isLoading: false,
      purchaseError: loaded.isEmpty ? 'Không tải được sản phẩm. Vui lòng thử lại.' : null,
      clearError: loaded.isNotEmpty,
    );
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          state = state.copyWith(isLoading: true, clearError: true);
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _activatePremium(purchase.productID);
          if (purchase.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchase);
          }
        case PurchaseStatus.error:
          state = state.copyWith(
            isLoading: false,
            purchaseError: purchase.error?.message ?? 'Giao dịch thất bại, vui lòng thử lại',
          );
          if (purchase.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchase);
          }
        case PurchaseStatus.canceled:
          state = state.copyWith(isLoading: false, clearError: true);
      }
    }
  }

  Future<void> _activatePremium(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyActivePlan, productId);
    state = state.copyWith(
      isPremium: true,
      activePlanId: productId,
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> purchase(ProductDetails product) async {
    if (!state.isStoreAvailable || state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        purchaseError: 'Không thể khởi tạo giao dịch. Vui lòng thử lại.',
      );
    }
  }

  Future<void> restore() async {
    if (!state.isStoreAvailable || state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        purchaseError: 'Không thể khôi phục giao dịch. Vui lòng thử lại.',
      );
    }
  }
}

final iapProvider = NotifierProvider<IapNotifier, IapState>(IapNotifier.new);
