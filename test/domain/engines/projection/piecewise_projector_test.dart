import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/projection/piecewise_projector.dart';

void main() {
  group('PiecewiseCelestialProjector Deep Tests', () {
    test('Identity Mapping (Linear-like Piecewise)', () {
      final projector = PiecewiseCelestialProjector(
        sourcePoints: [0, 180, 360],
        targetPoints: [0, 180, 360],
        sourceTotal: 360,
        targetTotal: 360,
      );

      expect(projector.project(90), 90.0);
      expect(projector.project(270), 270.0);
    });

    test('Complex Non-linear Mapping (Compression/Expansion)', () {
      // Scenario: First half of zodiac is compressed, second half is expanded.
      final projector = PiecewiseCelestialProjector(
        sourcePoints: [0, 180, 360],
        targetPoints: [0, 90, 360], 
        sourceTotal: 360,
        targetTotal: 360,
      );

      expect(projector.project(180), 90.0);
      // In the middle of the first segment (90), it should be around 45 (if linear) 
      // but spline might curve it slightly. We check for monotonicity.
      expect(projector.project(90) < 90, isTrue);
      expect(projector.project(270) > 180, isTrue);
    });

    test('Boundary Seamless Wrap: 360 and 0 mapping', () {
      final projector = PiecewiseCelestialProjector(
        sourcePoints: [0, 180, 360],
        targetPoints: [0, 182.625, 365.25],
        sourceTotal: 360,
        targetTotal: 365.25,
      );

      // We expect 360 to map to 365.25 (the boundary) or 0.0 depending on implementation.
      // But for circular math, 0 and 365.25 are equivalent.
      // We check that values near 360 approach 365.25.
      expect(projector.project(359.9) > 360, isTrue);
      expect(projector.project(0.1) < 1, isTrue);
    });

    test('Reverse Projection (Optional/Unimplemented)', () {
      final projector = PiecewiseCelestialProjector(
        sourcePoints: [0, 360],
        targetPoints: [0, 365.25],
      );
      
      // If implementer implements reverse, this test will pass. 
      // Currently it should throw or fail.
      expect(() => projector.reverse(182.625), throwsUnimplementedError);
    });
  });
}
