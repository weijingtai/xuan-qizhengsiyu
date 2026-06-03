/// Interface for celestial coordinate projection.
/// Maps source degrees (e.g. 360° SWEPH) to target degrees (e.g. 365.25° ancient).
abstract class ICelestialProjector {
  /// Projects a source degree to the target system.
  double project(double sourceDegree);

  /// Reverse project (optional, for verification).
  double reverse(double projectedDegree);
}
