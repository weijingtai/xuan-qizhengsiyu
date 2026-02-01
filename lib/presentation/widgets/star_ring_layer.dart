import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:qizhengsiyu/presentation/models/ui_star_model.dart';

import 'ring_layer.dart';

/// A reusable wrapper for rendering a star ring using RingLayer.
/// It binds a ValueListenable of UIStarModel list to track/body builders,
/// shows a grid between inner/outer sizes, and provides a consistent placeholder
/// when data is not yet available.
class StarRingLayer extends StatelessWidget {
  const StarRingLayer({
    super.key,
    required this.starsListenable,
    required this.outerSize,
    required this.innerSize,
    this.showTrack = true,
    this.showGrid = true,
    this.trackRotationAngle,
    this.bodyRotationAngle,
    required this.trackBuilder,
    required this.gridBuilder,
    required this.bodyBuilder,
  });

  final ValueListenable<List<UIStarModel>?> starsListenable;
  final double outerSize;
  final double innerSize;

  final bool showTrack;
  final bool showGrid;

  final double? trackRotationAngle;
  final double? bodyRotationAngle;

  /// Build the track layer from the current stars.
  final Widget Function(List<UIStarModel> stars) trackBuilder;

  /// Build the grid overlay given inner/outer sizes.
  final Widget Function(double innerSize, double outerSize) gridBuilder;

  /// Build the body layer from the current stars.
  final Widget Function(List<UIStarModel> stars) bodyBuilder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<UIStarModel>?>(
      valueListenable: starsListenable,
      builder: (ctx, stars, _) {
        return RingLayer(
          showTrack: showTrack,
          showGrid: showGrid,
          trackRotationAngle: trackRotationAngle,
          trackBuilder: () {
            if (stars == null) return _placeholder();
            return trackBuilder(stars);
          },
          gridBuilder: () => gridBuilder(innerSize, outerSize),
          bodyRotationAngle: bodyRotationAngle,
          bodyBuilder: () {
            if (stars == null) return _placeholder();
            return bodyBuilder(stars);
          },
        );
      },
    );
  }

  Widget _placeholder() {
    return Container(
      width: outerSize,
      height: outerSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(outerSize),
        border: Border.all(color: Colors.black87, width: 1),
      ),
    );
  }
}
