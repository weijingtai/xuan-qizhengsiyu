import '../engines/projection/i_celestial_projector.dart';
import '../engines/projection/linear_projector.dart';
import '../engines/projection/piecewise_projector.dart';
import '../entities/models/projection_config.dart';

class CelestialProjectorFactory {
  static ICelestialProjector create(ProjectionConfig? config, double targetTotal) {
    if (config == null || config.strategy == MappingStrategy.linear) {
      return LinearCelestialProjector(
        sourceTotal: 360.0,
        targetTotal: targetTotal,
        offset: config?.offset ?? 0.0,
      );
    } else {
      return PiecewiseCelestialProjector(
        sourcePoints: config.sourcePoints!,
        targetPoints: config.targetPoints!,
        sourceTotal: 360.0,
        targetTotal: targetTotal,
      );
    }
  }
}
