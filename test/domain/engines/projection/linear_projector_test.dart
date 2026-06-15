import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/projection/linear_projector.dart';

void main() {
  group('LinearCelestialProjector Unit Tests', () {
    test('Standard 360 to 365.25 mapping', () {
      final projector = LinearCelestialProjector(
        sourceTotal: 360.0,
        targetTotal: 365.25,
      );

      expect(projector.project(0), 0.0);
      expect(projector.project(180), 182.625);
      expect(projector.project(360), 365.25); // Linear mapping, no wrap at boundary
    });

    test('Mapping with Offset (Precession adjustment)', () {
      final projector = LinearCelestialProjector(
        sourceTotal: 360.0,
        targetTotal: 360.0,
        offset: 10.0,
      );

      expect(projector.project(0), 10.0);
      expect(projector.project(355), 5.0); // 355 + 10 = 365 -> 5
    });

    test('Reverse projection', () {
      final projector = LinearCelestialProjector(
        sourceTotal: 360.0,
        targetTotal: 365.25,
        offset: 0.0,
      );

      final projected = projector.project(180); // 182.625
      expect(projector.reverse(projected), closeTo(180.0, 1e-9));
    });

    test('Negative input handling', () {
      final projector = LinearCelestialProjector(
        sourceTotal: 360.0,
        targetTotal: 360.0,
      );
      expect(projector.project(-10), 350.0);
    });
  });
}
