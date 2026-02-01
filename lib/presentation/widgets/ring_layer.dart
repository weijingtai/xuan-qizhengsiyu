import 'package:flutter/widgets.dart';

class RingLayer extends StatelessWidget {
  final Widget Function()? trackBuilder;
  final Widget Function()? gridBuilder;
  final Widget Function()? bodyBuilder;
  final bool showTrack;
  final bool showGrid;
  final double? trackRotationAngle;
  final double? bodyRotationAngle;

  const RingLayer({
    super.key,
    this.trackBuilder,
    this.gridBuilder,
    this.bodyBuilder,
    this.showTrack = true,
    this.showGrid = true,
    this.trackRotationAngle,
    this.bodyRotationAngle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (showTrack && trackBuilder != null)
          trackRotationAngle != null
              ? Transform.rotate(angle: trackRotationAngle!, child: trackBuilder!())
              : trackBuilder!(),
        if (showGrid && gridBuilder != null) gridBuilder!(),
        if (bodyBuilder != null)
          bodyRotationAngle != null
              ? Transform.rotate(angle: bodyRotationAngle!, child: bodyBuilder!())
              : bodyBuilder!(),
      ],
    );
  }
}