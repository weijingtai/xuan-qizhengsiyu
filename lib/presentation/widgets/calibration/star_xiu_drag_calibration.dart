// TECHNICAL DEBT: 本层是 StarXiuRingPainter 原型化，chart-ui 共享渲染包就绪后整层替换。
// ①②层（ring_drag_angle_delta + 语义适配）可直接搬迁，本层重写。

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:metaphysics_core/enums.dart';

import '../../../domain/calibration/alignment_point_resolver.dart';
import '../../../domain/entities/models/naming_degree_pair.dart';
import '../../../domain/entities/models/star_inn_gong_degree.dart';
import '../../../domain/entities/models/zhou_tian_model.dart';
import '../../../domain/geometry/ring_drag_angle_delta.dart';
import '../../../painter/chart_style/qi_zheng_chart_style.dart';
import '../../../painter/star_xiu_ring_painter.dart';

/// 周天对齐点拖拽校准 · ③-甲 Painter + GestureDetector 拼装。
///
/// 在 [StarXiuRingPainter] 外包一层手势识别，把①②层串起来，
/// 实时重绘并显示当前对齐点读数（"XX宿 X.XX°"）。
///
/// 全程自由连续拖动，不做候选点吸附。
class StarXiuDragCalibration extends StatefulWidget {
  final double outerSize;
  final double innerSize;
  final Map<Enum28Constellations, ConstellationGongDegreeInfo> mapper;
  final Map<EnumStars, Color> sevenZhengColorMapper;
  final QiZhengChartStyle? style;
  final ZhouTianModel zhouTianModel;
  final ConstellationDegree initialAlignmentPoint;
  final ValueChanged<ConstellationDegree>? onAlignmentChanged;
  final ValueChanged<ConstellationDegree>? onDragEnd;
  final bool enabled;

  const StarXiuDragCalibration({
    super.key,
    required this.outerSize,
    required this.innerSize,
    required this.mapper,
    required this.sevenZhengColorMapper,
    this.style,
    required this.zhouTianModel,
    required this.initialAlignmentPoint,
    this.onAlignmentChanged,
    this.onDragEnd,
    this.enabled = true,
  });

  @override
  State<StarXiuDragCalibration> createState() => _StarXiuDragCalibrationState();
}

class _StarXiuDragCalibrationState extends State<StarXiuDragCalibration> {
  double _accumulatedAngle = 0.0;
  Offset? _lastPanLocal;
  ConstellationDegree? _currentAlignmentPoint;

  Map<Enum28Constellations, ConstellationGongDegreeInfo> _rotateMapper() {
    final angleDegrees = _accumulatedAngle * 180 / math.pi;
    final result = <Enum28Constellations, ConstellationGongDegreeInfo>{};
    for (final entry in widget.mapper.entries) {
      final info = entry.value;
      var newStart = (info.degreeStartAt + angleDegrees) % 360;
      if (newStart < 0) newStart += 360;
      result[entry.key] = ConstellationGongDegreeInfo(
        starType: info.starType,
        starXiu: info.starXiu,
        degreeStartAt: newStart,
        totalDegree: info.totalDegree,
        startAtGongDegree: info.startAtGongDegree,
        endAtGongDegree: info.endAtGongDegree,
      );
    }
    return result;
  }

  void _updateAlignment() {
    _currentAlignmentPoint = resolveAlignmentPointFromDrag(
      model: widget.zhouTianModel,
      basePoint: widget.initialAlignmentPoint,
      angleDeltaRadians: _accumulatedAngle,
    );
    widget.onAlignmentChanged?.call(_currentAlignmentPoint!);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.outerSize;
    final center = Offset(size / 2, size / 2);

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: widget.enabled ? (details) {
            _lastPanLocal = details.localPosition;
          } : null,
          onPanUpdate: widget.enabled ? (details) {
            if (_lastPanLocal == null) return;
            final delta = calculateRingDragAngleDelta(
              ringCenter: center,
              radius: widget.outerSize / 2,
              startPointer: _lastPanLocal!,
              endPointer: details.localPosition,
            );
            _lastPanLocal = details.localPosition;
            setState(() {
              _accumulatedAngle += delta;
              _updateAlignment();
            });
          } : null,
          onPanEnd: widget.enabled ? (details) {
            if (_currentAlignmentPoint != null) {
              widget.onDragEnd?.call(_currentAlignmentPoint!);
            }
          } : null,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(size, size),
                  painter: StarXiuRingPainter(
                    outerSize: widget.outerSize,
                    innerSize: widget.innerSize,
                    mapper: _rotateMapper(),
                    sevenZhengColorMapper: widget.sevenZhengColorMapper,
                    style: widget.style,
                  ),
                ),
                if (_currentAlignmentPoint != null)
                  Positioned(
                    top: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '当前: ${_currentAlignmentPoint!.constellation.starName} ${_currentAlignmentPoint!.degree.toStringAsFixed(2)}°',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
