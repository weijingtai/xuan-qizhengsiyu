import 'dart:math';
import 'package:flutter/widgets.dart';

/// PanelWidget: 可复用的盘面骨架容器
/// - 控制画布尺寸与旋转角度
/// - 包裹实际绘制内容（child）
/// - 后续可扩展叠加层（如径向辅助线、交互捕获等）
class PanelWidget extends StatelessWidget {
  final double canvasSize;
  final double rotationDeg;
  final EdgeInsetsGeometry? padding;
  final Widget child;

  const PanelWidget({
    Key? key,
    required this.canvasSize,
    required this.child,
    this.rotationDeg = 0,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: canvasSize,
        height: canvasSize,
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Align(
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: rotationDeg * pi / 180,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
