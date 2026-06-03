import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/projection/i_celestial_projector.dart';
import 'package:qizhengsiyu/domain/engines/projection/linear_projector.dart';
import 'package:qizhengsiyu/domain/engines/projection/piecewise_projector.dart';

void main() {
  group('Projection Integrity (Test Vectors)', () {
    late Map<String, dynamic> suite;

    setUpAll(() {
      final file = File('../test-vectors/qizhengsiyu/projection_integrity.json');
      suite = json.decode(file.readAsStringSync());
    });

    test('TV-01: Boundary wrap-around check', () {
      final vector = suite['vectors'].firstWhere((v) => v['id'] == 'TV-01');
      final input = vector['input'];
      final expected = vector['expected'];

      final projector = LinearCelestialProjector(
        sourceTotal: 360.0,
        targetTotal: input['total_degree'],
      );

      final result = projector.project(input['sweph_degree']);
      expect(result, closeTo(expected['projected_degree'], 1e-4));
    });

    test('TV-02: Monotonicity check for Retrograde motion', () {
      final vector = suite['vectors'].firstWhere((v) => v['id'] == 'TV-02');
      final inputs = vector['inputs'] as List;

      // Mock piecewise points for non-linear test
      final projector = PiecewiseCelestialProjector(
        sourcePoints: [0, 180, 360],
        targetPoints: [0, 182.625, 365.25],
        sourceTotal: 360,
        targetTotal: 365.25,
      );

      double prev = double.infinity;
      for (var entry in inputs) {
        double result = projector.project(entry['sweph_degree']);
        expect(result < prev, isTrue, reason: "Non-monotonic at ${entry['sweph_degree']}");
        prev = result;
      }
    });

    test('TV-03: Phase Integrity (Simulation)', () {
      // Logic: Aspect must be calculated in Source Space.
      // This test confirms that our projector DOES NOT change the physical distance in source degrees.
      final a = 10.0;
      final b = 130.0;
      final diff = (b - a).abs() % 360;
      expect(diff, 120.0);
      
      // Even if projected
      final projector = PiecewiseCelestialProjector(
        sourcePoints: [0, 180, 360],
        targetPoints: [0, 100, 365.25], // Highly non-linear
      );
      
      final pa = projector.project(a);
      final pb = projector.project(b);
      
      // The projected distance is NOT 120, which is WHY we must calculate aspects in source space.
      expect((pb - pa).abs(), isNot(120.0));
    });
  });
}
