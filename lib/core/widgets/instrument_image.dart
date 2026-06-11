import 'package:flutter/material.dart';
import '../../features/learn/domain/models/instrument.dart';

const _kLocalImages = <String, String>{
  'dan-tranh': 'assets/images/instruments/dan_tranh.png',
  'sao-truc': 'assets/images/instruments/sao_truc.png',
};

const _kFeaturedImages = <String, String>{
  'dan-tranh': 'assets/images/instruments/dan_tranh_featured.jpg',
};

class InstrumentImage extends StatelessWidget {
  final String slug;
  final String imageUrl;
  final String emoji;
  final BoxFit fit;
  final bool featured;

  const InstrumentImage({
    super.key,
    required this.slug,
    required this.imageUrl,
    required this.emoji,
    this.fit = BoxFit.cover,
    this.featured = false,
  });

  factory InstrumentImage.fromSummary(
    InstrumentSummary inst, {
    Key? key,
    BoxFit fit = BoxFit.cover,
    bool featured = false,
  }) =>
      InstrumentImage(
        key: key,
        slug: inst.id,
        imageUrl: inst.imageUrl,
        emoji: inst.emoji,
        fit: fit,
        featured: featured,
      );

  factory InstrumentImage.fromDetail(
    Instrument inst, {
    Key? key,
    BoxFit fit = BoxFit.cover,
    bool featured = false,
  }) =>
      InstrumentImage(
        key: key,
        slug: inst.id,
        imageUrl: inst.imageUrl,
        emoji: inst.emoji,
        fit: fit,
        featured: featured,
      );

  @override
  Widget build(BuildContext context) {
    final map = featured ? _kFeaturedImages : _kLocalImages;
    final local = map[slug] ?? _kLocalImages[slug];
    if (local != null) {
      return Image.asset(local, fit: fit);
    }
    return Image.network(
      imageUrl,
      fit: fit,
      errorBuilder: (ctx, err, stack) =>
          Center(child: Text(emoji, style: const TextStyle(fontSize: 48))),
    );
  }
}
