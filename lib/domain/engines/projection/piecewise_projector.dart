import '../../../utils/math/spline_interpolator.dart';
import 'i_celestial_projector.dart';

/// Piecewise non-linear projection using monotonic cubic spline interpolation.
/// Maps discrete control points in source space to target space.
class PiecewiseCelestialProjector implements ICelestialProjector {
  final MonotonicCubicSpline _spline;
  final double sourceTotal;
  final double targetTotal;

  PiecewiseCelestialProjector({
    required List<double> sourcePoints,
    required List<double> targetPoints,
    this.sourceTotal = 360.0,
    this.targetTotal = 365.25,
  }) : _spline = MonotonicCubicSpline(sourcePoints, targetPoints) {
    if (sourcePoints.first != 0 || sourcePoints.last != sourceTotal) {
      throw ArgumentError("Source points must span [0, $sourceTotal]");
    }
  }

  @override
  double project(double sourceDegree) {
    // Normalize input to [0, sourceTotal)
    double normalizedSource = sourceDegree % sourceTotal;
    if (normalizedSource < 0) normalizedSource += sourceTotal;

    // Boundary: if normalized to 0 but original was non-zero,
    // it's a full-cycle boundary → return targetTotal (e.g. 365.25)
    if (normalizedSource == 0 && sourceDegree != 0) return targetTotal;

    return _spline.interpolate(normalizedSource);
  }

  @override
  double reverse(double projectedDegree) {
    // Reverse interpolation is complex for splines, 
    // usually implemented via binary search on the forward spline.
    throw UnimplementedError("Reverse projection not implemented for Piecewise engine yet.");
  }
}
