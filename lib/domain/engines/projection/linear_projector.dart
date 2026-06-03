import 'i_celestial_projector.dart';

/// Linear projection based on a simple scale ratio.
/// Formula: projected = source * (targetTotal / sourceTotal) + offset.
class LinearCelestialProjector implements ICelestialProjector {
  final double sourceTotal;
  final double targetTotal;
  final double offset;

  LinearCelestialProjector({
    this.sourceTotal = 360.0,
    required this.targetTotal,
    this.offset = 0.0,
  });

  @override
  double project(double sourceDegree) {
    double ratio = targetTotal / sourceTotal;
    double val = (sourceDegree * ratio + offset);
    
    // Boundary: if we are exactly at the end of the source cycle (or multiples), 
    // we want to return the end of the target cycle (targetTotal) to maintain continuity in calculators,
    // UNLESS it's a raw 0 input.
    if (sourceDegree > 0 && sourceDegree % sourceTotal == 0) {
      return (sourceDegree ~/ sourceTotal) * targetTotal + offset;
    }
    
    return val % targetTotal;
  }

  @override
  double reverse(double projectedDegree) {
    double ratio = targetTotal / sourceTotal;
    return (projectedDegree - offset) / ratio % sourceTotal;
  }
}
