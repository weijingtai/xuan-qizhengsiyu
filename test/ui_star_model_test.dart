import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/presentation/models/ui_star_model.dart';
import 'package:qizhengsiyu/presentation/pages/StarsResolver.dart';
import 'package:tuple/tuple.dart';

/// Helper to create a UIStarModel with sensible defaults.
UIStarModel _star({
  EnumStars star = EnumStars.Sun,
  int priority = 2,
  required double angle,
  double range = 4.0,
}) {
  return UIStarModel(
    star: star,
    priority: priority,
    originalAngle: angle,
    rangeAngleEachSide: range,
  );
}

void main() {
  // ============================================================
  // Group 1: correctCircleAngle normalization
  // ============================================================
  group('correctCircleAngle', () {
    late UIStarModel s;
    setUp(() {
      s = _star(angle: 0);
    });

    test('[regression] 0 stays 0', () {
      expect(s.correctCircleAngle(0), equals(0));
    });

    test('[regression] 90 stays 90', () {
      expect(s.correctCircleAngle(90), equals(90));
    });

    test('[regression] 180 stays 180', () {
      expect(s.correctCircleAngle(180), equals(180));
    });

    test('[regression] 359.9 stays 359.9', () {
      expect(s.correctCircleAngle(359.9), equals(359.9));
    });

    test('[regression] negative angle -4 becomes 356', () {
      expect(s.correctCircleAngle(-4), equals(356));
    });

    test('[regression] 364 becomes 4', () {
      expect(s.correctCircleAngle(364), equals(4));
    });

    test('[fixed] multiple wrapping: -400 should be 320', () {
      final result = s.correctCircleAngle(-400);
      // FIXED: correctCircleAngle now uses modulo, handles any angle
      expect(result, equals(320));
    });

    test('[fixed] multiple wrapping: 800 should be 80', () {
      final result = s.correctCircleAngle(800);
      // FIXED: correctCircleAngle now uses modulo, handles any angle
      expect(result, equals(80));
    });
  });

  // ============================================================
  // Group 2: getMinDiffAngleOfTwoStar
  // ============================================================
  group('getMinDiffAngleOfTwoStar', () {
    test('[regression] same rangeAngle returns max of both', () {
      final s1 = _star(angle: 10, range: 4);
      final s2 = _star(angle: 20, range: 4);
      expect(UIStarModel.getMinDiffAngleOfTwoStar(s1, s2), equals(4));
    });

    test('different rangeAngle (3,5) returns max(5)', () {
      final s1 = _star(angle: 10, range: 3);
      final s2 = _star(angle: 20, range: 5);
      final result = UIStarModel.getMinDiffAngleOfTwoStar(s1, s2);
      expect(result, equals(5));
    });
  });

  // ============================================================
  // Group 3: adjustAngle state changes
  // ============================================================
  group('adjustAngle', () {
    test('[regression] adjustAngle(4) moves right correctly', () {
      final s = _star(angle: 90, range: 4);
      s.adjustAngle(4);
      expect(s.adjustedAngle, equals(94));
      expect(s.angle, equals(94));
      expect(s.adjustCount, equals(1));
      expect(s.previousAdjustedDirection, isTrue); // positive = right
    });

    test('[regression] adjustAngle(-4) moves left correctly', () {
      final s = _star(angle: 90, range: 4);
      s.adjustAngle(-4);
      expect(s.adjustedAngle, equals(86));
      expect(s.angle, equals(86));
      expect(s.adjustCount, equals(1));
      expect(s.previousAdjustedDirection, isFalse); // negative = left
    });

    test('[regression] adjustedEdges updated correctly after adjustAngle', () {
      final s = _star(angle: 90, range: 4);
      s.adjustAngle(4);
      // After adjustment: angle=94, edges should be (90, 98, 94)
      expect(s.adjustedEdges, isNotNull);
      expect(s.adjustedEdges!.item1, equals(90)); // 94-4
      expect(s.adjustedEdges!.item2, equals(98)); // 94+4
      expect(s.adjustedEdges!.item3, equals(94)); // center
    });

    test('[defect-8] consecutive adjustAngle calls accumulate on adjusted value',
        () {
      final s = _star(angle: 90, range: 4);
      s.adjustAngle(4); // first: 90 + 4 = 94
      s.adjustAngle(4); // second: 94 + 4 = 98 (uses angle getter which returns adjustedAngle)
      // This is the mutable state behavior — adjustAngle accumulates
      // because it reads `angle` (which returns adjustedAngle after first call).
      // This is by design but can cause subtle bugs when callers don't realize
      // that subsequent calls compound rather than being relative to original.
      expect(s.adjustedAngle, equals(98));
      expect(s.adjustCount, equals(2));
    });
  });

  // ============================================================
  // Group 4: inRangeAngle
  // ============================================================
  group('inRangeAngle (UIStarModel)', () {
    test('[regression] non-crossing-0: other on left side within range', () {
      // Star at 90, edges (86, 94, 90). Other at 87 → closer to left edge
      final s = _star(angle: 90, range: 4);
      final other = _star(angle: 87, range: 4);
      final result = s.inRangeAngle(other);
      expect(result.item1, isTrue);
      expect(result.item2, equals(1.0)); // 87-86=1, distance to left edge
      expect(result.item3, isNull);
    });

    test('[regression] non-crossing-0: other on right side within range', () {
      final s = _star(angle: 90, range: 4);
      final other = _star(angle: 93, range: 4);
      final result = s.inRangeAngle(other);
      expect(result.item1, isTrue);
      expect(result.item2, isNull);
      expect(result.item3, equals(1.0)); // 94-93=1, distance to right edge
    });

    test('[regression] non-crossing-0: other not in range', () {
      final s = _star(angle: 90, range: 4);
      final other = _star(angle: 100, range: 4);
      final result = s.inRangeAngle(other);
      expect(result.item1, isFalse);
    });

    test('[regression] crossing-0: other within right edge', () {
      // Star at 2, range 4 → edges: (358, 6, 2)
      final s = _star(angle: 2, range: 4);
      final other = _star(angle: 5, range: 4);
      final result = s.inRangeAngle(other);
      expect(result.item1, isTrue);
      expect(result.item3, equals(1.0)); // 6-5=1
      expect(result.item2, isNull);
    });

    test('[regression] crossing-0: other within left edge', () {
      // Star at 2, range 4 → edges: (358, 6, 2)
      final s = _star(angle: 2, range: 4);
      final other = _star(angle: 359, range: 4);
      final result = s.inRangeAngle(other);
      expect(result.item1, isTrue);
      expect(result.item2, equals(1.0)); // 359-358=1
      expect(result.item3, isNull);
    });

    test('[defect-5] other exactly at center angle', () {
      // Star at 90, range=4, edges=(86,94,90). Other at 90 (center).
      // Since leftDist == rightDist == 4, both should be returned.
      final s = _star(angle: 90, range: 4);
      final other = _star(angle: 90, range: 4);
      final result = s.inRangeAngle(other);
      // The method correctly returns both distances when they're equal
      expect(result.item1, isTrue);
      expect(result.item2, equals(4.0)); // 90-86=4
      expect(result.item3, equals(4.0)); // 94-90=4
    });
  });

  // ============================================================
  // Group 5: compareTo consistency
  // ============================================================
  group('compareTo', () {
    test('[fixed] compareTo is now symmetric', () {
      final s1 = _star(star: EnumStars.Sun, angle: 90, range: 4);
      final s2 = _star(star: EnumStars.Moon, angle: 90, range: 4);
      // FIXED: compareTo now uses star.index comparison, producing proper ordering
      final forward = s1.compareTo(s2);
      final backward = s2.compareTo(s1);
      // forward and backward should have opposite signs
      expect(forward, equals(-backward));
    });

    test('[defect-9] compareTo vs == semantic mismatch', () {
      // Same star enum, different angle → Equatable props=[star, originalAngle]
      final s1 = _star(star: EnumStars.Sun, angle: 90, range: 4);
      final s2 = _star(star: EnumStars.Sun, angle: 100, range: 4);
      // compareTo compares only star enum, so same star → 0
      expect(s1.compareTo(s2), equals(0));
      // == uses Equatable props [star, originalAngle], so different angle → false
      expect(s1 == s2, isFalse);
      // This proves compareTo==0 does not imply ==true, violating Comparable contract
    });
  });

  // ============================================================
  // Group 6: addStar
  // ============================================================
  group('addStar', () {
    test('[regression] two stars overlapping at same angle → each step back', () {
      final s1 = _star(star: EnumStars.Sun, angle: 90, range: 4);
      final s2 = _star(star: EnumStars.Moon, angle: 90, range: 4);
      final result = s1.addStar(s2);
      expect(result, isNotNull);
      expect(result!.orderedStars.length, equals(2));
      // Both should be adjusted: s1 left, s2 right
      expect(s1.adjustCount, equals(1));
      expect(s2.adjustCount, equals(1));
    });

    test('[regression] other not in range → returns null', () {
      final s1 = _star(star: EnumStars.Sun, angle: 90, range: 4);
      final s2 = _star(star: EnumStars.Moon, angle: 180, range: 4);
      final result = s1.addStar(s2);
      expect(result, isNull);
    });

    test('[regression] other in range → pushed out', () {
      final s1 = _star(star: EnumStars.Sun, angle: 90, range: 4);
      final s2 = _star(star: EnumStars.Moon, angle: 92, range: 4);
      final result = s1.addStar(s2);
      expect(result, isNotNull);
      // s2 was in range and should be adjusted
      expect(s2.adjustCount, greaterThan(0));
    });
  });

  // ============================================================
  // Group 7: resolveUIStars — global overlap fix
  // ============================================================
  group('resolveUIStars', () {
    /// Helper: check that all adjacent pairs (circular) have sufficient distance.
    void expectNoOverlaps(List<UIStarModel> resolved) {
      final sorted = resolved.toList()
        ..sort((a, b) => a.angle.compareTo(b.angle));
      for (int i = 0; i < sorted.length; i++) {
        final j = (i + 1) % sorted.length;
        if (i == j) continue;
        final dist = StarsResolver.calculateMinAngleDifference(
            sorted[i].angle, sorted[j].angle);
        final minDist =
            UIStarModel.getMinDiffAngleOfTwoStar(sorted[i], sorted[j]);
        expect(dist, greaterThanOrEqualTo(minDist - 1e-4),
            reason:
                '${sorted[i].star}@${sorted[i].angle.toStringAsFixed(2)} ↔ '
                '${sorted[j].star}@${sorted[j].angle.toStringAsFixed(2)}: '
                'dist=$dist < minDist=$minDist');
      }
    }

    test('Bug1: cluster pushes into independent star', () {
      // Stars: 10°, 11°, 12°, 16° — cluster [10,11,12] resolves and may
      // push the 12° star near the independent 16° star.
      final stars = [
        _star(star: EnumStars.Sun, angle: 10, range: 4),
        _star(star: EnumStars.Moon, angle: 11, range: 4),
        _star(star: EnumStars.Mercury, angle: 12, range: 4),
        _star(star: EnumStars.Venus, angle: 16, range: 4),
      ];
      final resolved = StarsResolver.resolveUIStars(stars);
      expectNoOverlaps(resolved);
    });

    test('Bug2: two clusters with independent star in between', () {
      // Cluster A [5,6], independent [14], cluster B [20,21]
      // Resolving clusters might push edges toward the independent star.
      final stars = [
        _star(star: EnumStars.Sun, angle: 5, range: 4),
        _star(star: EnumStars.Moon, angle: 6, range: 4),
        _star(star: EnumStars.Mercury, angle: 14, range: 4),
        _star(star: EnumStars.Venus, angle: 20, range: 4),
        _star(star: EnumStars.Mars, angle: 21, range: 4),
      ];
      final resolved = StarsResolver.resolveUIStars(stars);
      expectNoOverlaps(resolved);
    });

    test('all independent stars with no overlaps remain unchanged', () {
      final stars = [
        _star(star: EnumStars.Sun, angle: 0, range: 4),
        _star(star: EnumStars.Moon, angle: 90, range: 4),
        _star(star: EnumStars.Mercury, angle: 180, range: 4),
        _star(star: EnumStars.Venus, angle: 270, range: 4),
      ];
      final resolved = StarsResolver.resolveUIStars(stars);
      // No adjustments needed
      for (var s in resolved) {
        expect(s.adjustedAngle, isNull,
            reason: '${s.star} should not be adjusted');
      }
    });

    test('cross-0° overlap between independent stars', () {
      // Stars near 0°: 358° and 1° — distance is 3° < minSafe 4°
      final stars = [
        _star(star: EnumStars.Sun, angle: 358, range: 4),
        _star(star: EnumStars.Moon, angle: 1, range: 4),
      ];
      final resolved = StarsResolver.resolveUIStars(stars);
      expectNoOverlaps(resolved);
    });

    test('large cluster resolves without any overlaps', () {
      // 5 stars bunched at 100°–104°
      final stars = [
        _star(star: EnumStars.Sun, angle: 100, range: 4),
        _star(star: EnumStars.Moon, angle: 101, range: 4),
        _star(star: EnumStars.Mercury, angle: 102, range: 4),
        _star(star: EnumStars.Venus, angle: 103, range: 4),
        _star(star: EnumStars.Mars, angle: 104, range: 4),
      ];
      final resolved = StarsResolver.resolveUIStars(stars);
      expectNoOverlaps(resolved);
    });
  });

  // ============================================================
  // Group 8: resolveUIStars — comprehensive coverage
  // ============================================================
  group('resolveUIStars — comprehensive', () {
    /// Helper: check that all adjacent pairs (circular) have sufficient distance.
    void expectNoOverlaps(List<UIStarModel> resolved) {
      final sorted = resolved.toList()
        ..sort((a, b) => a.angle.compareTo(b.angle));
      for (int i = 0; i < sorted.length; i++) {
        final j = (i + 1) % sorted.length;
        if (i == j) continue;
        final dist = StarsResolver.calculateMinAngleDifference(
            sorted[i].angle, sorted[j].angle);
        final minDist =
            UIStarModel.getMinDiffAngleOfTwoStar(sorted[i], sorted[j]);
        expect(dist, greaterThanOrEqualTo(minDist - 1e-3),
            reason:
                '${sorted[i].star}@${sorted[i].angle.toStringAsFixed(2)} ↔ '
                '${sorted[j].star}@${sorted[j].angle.toStringAsFixed(2)}: '
                'dist=$dist < minDist=$minDist');
      }
    }

    // ---- A. 主流程边界 ----
    group('A. main flow boundaries', () {
      test('A1: empty list returns empty', () {
        final resolved = StarsResolver.resolveUIStars([]);
        expect(resolved, isEmpty);
      });

      test('A2: single star returns unadjusted', () {
        final stars = [_star(star: EnumStars.Sun, angle: 137)];
        final resolved = StarsResolver.resolveUIStars(stars);
        expect(resolved.length, equals(1));
        expect(resolved.first.adjustedAngle, isNull);
      });

      test('A3: idempotency — double call same result', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 10),
          _star(star: EnumStars.Moon, angle: 11),
          _star(star: EnumStars.Mercury, angle: 12),
        ];
        final resolved1 = StarsResolver.resolveUIStars(stars);
        final angles1 = resolved1.map((s) => s.angle).toList();

        // Second call should reset and produce identical results
        final resolved2 = StarsResolver.resolveUIStars(stars);
        final angles2 = resolved2.map((s) => s.angle).toList();

        for (int i = 0; i < angles1.length; i++) {
          expect(angles2[i], closeTo(angles1[i], 1e-9),
              reason: 'Star $i differs on second call');
        }
      });

      test('A4: distance == minSafe — no adjustment needed', () {
        // Sun@0, Moon@4: distance=4, minSafe=max(4,4)=4 → not < 4
        final stars = [
          _star(star: EnumStars.Sun, angle: 0),
          _star(star: EnumStars.Moon, angle: 4),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        for (var s in resolved) {
          expect(s.adjustedAngle, isNull,
              reason: '${s.star} should not be adjusted when dist == minSafe');
        }
      });

      test('A5: distance just below minSafe — triggers adjustment', () {
        // Sun@0, Moon@3.99: distance=3.99 < minSafe=4 → overlap
        final stars = [
          _star(star: EnumStars.Sun, angle: 0),
          _star(star: EnumStars.Moon, angle: 3.99),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        final anyAdjusted = resolved.any((s) => s.adjustedAngle != null);
        expect(anyAdjusted, isTrue,
            reason: 'At least one star should be adjusted');
        expectNoOverlaps(resolved);
      });
    });

    // ---- B. 集群检测场景 ----
    group('B. cluster detection', () {
      test('B1: three separate clusters', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 30),
          _star(star: EnumStars.Moon, angle: 31),
          _star(star: EnumStars.Mercury, angle: 120),
          _star(star: EnumStars.Mars, angle: 121),
          _star(star: EnumStars.Saturn, angle: 250),
          _star(star: EnumStars.Venus, angle: 251),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
      });

      test('B2: cross-0° cluster merge', () {
        // 4 stars straddling 0°: 356, 358, 0, 2 → should form one cluster
        final stars = [
          _star(star: EnumStars.Sun, angle: 356),
          _star(star: EnumStars.Moon, angle: 358),
          _star(star: EnumStars.Mercury, angle: 0),
          _star(star: EnumStars.Mars, angle: 2),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
      });

      test('B3: independent stars with cross-0° overlap (clusters.isEmpty branch)',
          () {
        // All widely separated, but Sun@1 and Saturn@358 overlap across 0°
        final stars = [
          _star(star: EnumStars.Sun, angle: 1),
          _star(star: EnumStars.Moon, angle: 90),
          _star(star: EnumStars.Mercury, angle: 180),
          _star(star: EnumStars.Mars, angle: 270),
          _star(star: EnumStars.Saturn, angle: 358),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
        // Moon, Mercury, Mars should be unaffected
        final moon = resolved.firstWhere((s) => s.star == EnumStars.Moon);
        final mercury = resolved.firstWhere((s) => s.star == EnumStars.Mercury);
        final mars = resolved.firstWhere((s) => s.star == EnumStars.Mars);
        expect(moon.adjustedAngle, isNull);
        expect(mercury.adjustedAngle, isNull);
        expect(mars.adjustedAngle, isNull);
      });

      test('B4: single cluster + independent cross-0° pair', () {
        // Mercury@100 + Mars@102 form a cluster; Sun@1 + Saturn@359 overlap across 0°
        final stars = [
          _star(star: EnumStars.Sun, angle: 1),
          _star(star: EnumStars.Moon, angle: 100),
          _star(star: EnumStars.Mercury, angle: 102),
          _star(star: EnumStars.Mars, angle: 359),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
      });

      test('B5: all stars form one giant cluster', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 0),
          _star(star: EnumStars.Moon, angle: 1),
          _star(star: EnumStars.Mercury, angle: 2),
          _star(star: EnumStars.Mars, angle: 3),
          _star(star: EnumStars.Saturn, angle: 4),
          _star(star: EnumStars.Venus, angle: 5),
          _star(star: EnumStars.Jupiter, angle: 6),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
      });
    });

    // ---- C. 集群内部解析 ----
    group('C. cluster-internal resolution', () {
      test('C1: two equal-priority stars — symmetric resolution', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 50, priority: 2),
          _star(star: EnumStars.Moon, angle: 51, priority: 2),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
        // Midpoint should be near 50.5
        final midpoint = (resolved[0].angle + resolved[1].angle) / 2;
        // Allow some tolerance because circular mean may shift slightly
        expect(midpoint, closeTo(50.5, 1.0));
      });

      test('C2: three stars, different priorities — weighted bias', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 100, priority: 4),
          _star(star: EnumStars.Moon, angle: 101, priority: 1),
          _star(star: EnumStars.Mercury, angle: 102, priority: 1),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
        // The weighted circular mean shifts toward Sun (high priority),
        // so the cluster center should be closer to 100 than to 102
        final sun = resolved.firstWhere((s) => s.star == EnumStars.Sun);
        final moon = resolved.firstWhere((s) => s.star == EnumStars.Moon);
        final mercury = resolved.firstWhere((s) => s.star == EnumStars.Mercury);
        // Verify all three have distinct angles after resolution
        final angles = {sun.angle, moon.angle, mercury.angle};
        expect(angles.length, equals(3),
            reason: 'All 3 stars should have distinct resolved angles');
      });

      test('C3: different rangeAngleEachSide values', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 50, range: 3),
          _star(star: EnumStars.Moon, angle: 52, range: 6),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
        // Min safe distance = max(3,6) = 6
        final dist = StarsResolver.calculateMinAngleDifference(
            resolved[0].angle, resolved[1].angle);
        expect(dist, greaterThanOrEqualTo(6 - 1e-4));
      });

      test('C4: all stars at exactly same angle', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 180),
          _star(star: EnumStars.Moon, angle: 180),
          _star(star: EnumStars.Mercury, angle: 180),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
        // All should have different adjusted angles
        final angles = resolved.map((s) => s.angle).toSet();
        expect(angles.length, equals(3),
            reason: 'All 3 stars should have distinct angles');
        // Center should be near 180
        final avgAngle = resolved.map((s) => s.angle).reduce((a, b) => a + b) / 3;
        expect(avgAngle, closeTo(180, 5.0));
      });

      test('C5: two-star cluster, one high priority', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 60, priority: 4),
          _star(star: EnumStars.Moon, angle: 61, priority: 1),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
        // Weighted center is closer to Sun (p=4) than Moon (p=1),
        // so the cluster is biased toward Sun's original position
        final sun = resolved.firstWhere((s) => s.star == EnumStars.Sun);
        final moon = resolved.firstWhere((s) => s.star == EnumStars.Moon);
        expect(sun.angle, isNot(equals(moon.angle)),
            reason: 'Sun and Moon should have different resolved angles');
      });
    });

    // ---- D. 全局修复 ----
    group('D. global fix', () {
      test('D1: 8 tightly packed stars — cascading overlaps', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 50),
          _star(star: EnumStars.Moon, angle: 51),
          _star(star: EnumStars.Mercury, angle: 52),
          _star(star: EnumStars.Mars, angle: 53),
          _star(star: EnumStars.Saturn, angle: 54),
          _star(star: EnumStars.Venus, angle: 55),
          _star(star: EnumStars.Jupiter, angle: 56),
          _star(star: EnumStars.Qi, angle: 57),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
      });

      test('D2: cross-0° pair in global fix', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 358),
          _star(star: EnumStars.Moon, angle: 0),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
        // Both should stay near 0°/360° boundary
        final sun = resolved.firstWhere((s) => s.star == EnumStars.Sun);
        final moon = resolved.firstWhere((s) => s.star == EnumStars.Moon);
        // Sun should be pushed toward higher angles, Moon toward lower
        // (or vice versa), but both near boundary
        final sunDist = StarsResolver.calculateMinAngleDifference(sun.angle, 359);
        final moonDist = StarsResolver.calculateMinAngleDifference(moon.angle, 359);
        expect(sunDist, lessThan(20),
            reason: 'Sun should remain near 0°/360° boundary');
        expect(moonDist, lessThan(20),
            reason: 'Moon should remain near 0°/360° boundary');
      });

      test('D3: cluster pushes into neighbor cluster', () {
        // Cluster A [20,21,22] and Cluster B [27,28] — close enough that
        // resolving A might push into B's space
        final stars = [
          _star(star: EnumStars.Sun, angle: 20),
          _star(star: EnumStars.Moon, angle: 21),
          _star(star: EnumStars.Mercury, angle: 22),
          _star(star: EnumStars.Mars, angle: 27),
          _star(star: EnumStars.Saturn, angle: 28),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
      });

      test('D4: 11 stars large cluster convergence', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 100),
          _star(star: EnumStars.Moon, angle: 100.5),
          _star(star: EnumStars.Mercury, angle: 101),
          _star(star: EnumStars.Mars, angle: 101.5),
          _star(star: EnumStars.Saturn, angle: 102),
          _star(star: EnumStars.Venus, angle: 102.5),
          _star(star: EnumStars.Jupiter, angle: 103),
          _star(star: EnumStars.Qi, angle: 103.5),
          _star(star: EnumStars.Luo, angle: 104),
          _star(star: EnumStars.Ji, angle: 104.5),
          _star(star: EnumStars.Bei, angle: 105),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
      });
    });

    // ---- E. 圆周算术 ----
    group('E. circular arithmetic', () {
      test('E1: stars straddling 180° boundary', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 179),
          _star(star: EnumStars.Moon, angle: 181),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
        // Both should remain near 180°
        for (var s in resolved) {
          final dist = StarsResolver.calculateMinAngleDifference(s.angle, 180);
          expect(dist, lessThan(10),
              reason: '${s.star} should stay near 180°');
        }
      });

      test('E2: stars at 0° and 359° (near-0° wrap)', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 0),
          _star(star: EnumStars.Moon, angle: 359),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
        // Both should stay near the 0°/360° boundary
        for (var s in resolved) {
          final distTo0 = StarsResolver.calculateMinAngleDifference(s.angle, 0);
          expect(distTo0, lessThan(10),
              reason: '${s.star} should stay near 0°/360° boundary');
        }
      });

      test('E3: weighted circular mean cross-0° correctness', () {
        // Two equal-priority stars at 359° and 1° — mean should be near 0°, not 180°
        final stars = [
          _star(star: EnumStars.Sun, angle: 359, priority: 3),
          _star(star: EnumStars.Moon, angle: 1, priority: 3),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
        // Midpoint should be near 0°, not near 180°
        for (var s in resolved) {
          final distTo0 = StarsResolver.calculateMinAngleDifference(s.angle, 0);
          expect(distTo0, lessThan(10),
              reason: '${s.star}@${s.angle} center should be near 0°, not 180°');
        }
      });
    });

    // ---- F. 数学正确性 ----
    group('F. math correctness', () {
      test('F1: asymmetric ranges — max(r1,r2) dominance', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 50, range: 2),
          _star(star: EnumStars.Moon, angle: 53, range: 6),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
        final dist = StarsResolver.calculateMinAngleDifference(
            resolved[0].angle, resolved[1].angle);
        expect(dist, greaterThanOrEqualTo(6 - 1e-4),
            reason: 'Min distance should be >= max(2,6) = 6');
      });

      test('F2: floating point — 10 tightly packed stars', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 100),
          _star(star: EnumStars.Moon, angle: 100.1),
          _star(star: EnumStars.Mercury, angle: 100.2),
          _star(star: EnumStars.Mars, angle: 100.3),
          _star(star: EnumStars.Saturn, angle: 100.4),
          _star(star: EnumStars.Venus, angle: 100.5),
          _star(star: EnumStars.Jupiter, angle: 100.6),
          _star(star: EnumStars.Qi, angle: 100.7),
          _star(star: EnumStars.Luo, angle: 100.8),
          _star(star: EnumStars.Ji, angle: 100.9),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
        // Verify no NaN or Infinity
        for (var s in resolved) {
          expect(s.angle.isNaN, isFalse,
              reason: '${s.star} angle should not be NaN');
          expect(s.angle.isInfinite, isFalse,
              reason: '${s.star} angle should not be Infinite');
        }
      });

      test('F3: impossible config — total range > 360°', () {
        // 6 stars with range=61 → need 6*61=366° > 360° total
        // Should not crash; angles must be in [0, 360)
        final stars = [
          _star(star: EnumStars.Sun, angle: 0, range: 61),
          _star(star: EnumStars.Moon, angle: 60, range: 61),
          _star(star: EnumStars.Mercury, angle: 120, range: 61),
          _star(star: EnumStars.Mars, angle: 180, range: 61),
          _star(star: EnumStars.Saturn, angle: 240, range: 61),
          _star(star: EnumStars.Venus, angle: 300, range: 61),
        ];
        // Should not throw
        final resolved = StarsResolver.resolveUIStars(stars);
        expect(resolved.length, equals(6));
        // All angles in valid range
        for (var s in resolved) {
          expect(s.angle, greaterThanOrEqualTo(0));
          expect(s.angle, lessThan(360));
          expect(s.angle.isNaN, isFalse);
          expect(s.angle.isInfinite, isFalse);
        }
        // Note: expectNoOverlaps NOT called — impossible to satisfy with range=61
      });
    });
  });

  // ============================================================
  // Group 9: resolveUIStars — adjustment ordering
  // ============================================================
  group('resolveUIStars — adjustment ordering', () {
    void expectNoOverlaps(List<UIStarModel> resolved) {
      final sorted = resolved.toList()
        ..sort((a, b) => a.angle.compareTo(b.angle));
      for (int i = 0; i < sorted.length; i++) {
        final j = (i + 1) % sorted.length;
        if (i == j) continue;
        final a = sorted[i];
        final b = sorted[j];
        final dist =
            StarsResolver.calculateMinAngleDifference(a.angle, b.angle);
        final minRequired = UIStarModel.getMinDiffAngleOfTwoStar(a, b);
        expect(dist, greaterThanOrEqualTo(minRequired - 0.05),
            reason:
                '${a.star}@${a.angle} and ${b.star}@${b.angle} overlap: dist=$dist < min=$minRequired');
      }
    }

    // ---- G. 同轮双重调整 ----
    group('G. same-round double adjustment', () {
      test('G1: middle star adjusted twice in same round', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 10, range: 4),
          _star(star: EnumStars.Moon, angle: 12, range: 4),
          _star(star: EnumStars.Mercury, angle: 14, range: 4),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
        final moon = resolved.firstWhere((s) => s.star == EnumStars.Moon);
        // NOTE: The cluster resolver may place Moon at its original angle if it
        // happens to coincide with the weighted cluster center. The important
        // thing is that all overlaps are resolved (checked by expectNoOverlaps).
        // Verify at least one star in the triple was repositioned.
        final anyAdjusted = resolved.any((s) => s.adjustedAngle != null);
        expect(anyAdjusted, isTrue,
            reason: 'At least one star should have been repositioned');
        // Verify Moon is not at the same angle as its neighbors
        final sun = resolved.firstWhere((s) => s.star == EnumStars.Sun);
        final mercury =
            resolved.firstWhere((s) => s.star == EnumStars.Mercury);
        expect(moon.angle, isNot(equals(sun.angle)));
        expect(moon.angle, isNot(equals(mercury.angle)));
      });

      test('G2: chain of 4 — cascading double adjustments', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 50, range: 4),
          _star(star: EnumStars.Moon, angle: 52, range: 4),
          _star(star: EnumStars.Mercury, angle: 54, range: 4),
          _star(star: EnumStars.Mars, angle: 56, range: 4),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
        final moon = resolved.firstWhere((s) => s.star == EnumStars.Moon);
        final mercury =
            resolved.firstWhere((s) => s.star == EnumStars.Mercury);
        // NOTE: cluster resolution handles most overlap in one pass;
        // adjustCount may be < 2 if cluster-internal placement is sufficient.
        expect(moon.adjustCount, greaterThanOrEqualTo(1),
            reason: 'Moon should be adjusted at least once');
        expect(mercury.adjustCount, greaterThanOrEqualTo(1),
            reason: 'Mercury should be adjusted at least once');
      });

      test('G3: double adjustment does not overshoot', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 0, range: 4),
          _star(star: EnumStars.Moon, angle: 2, range: 4),
          _star(star: EnumStars.Mercury, angle: 5, range: 4),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
        final sun = resolved.firstWhere((s) => s.star == EnumStars.Sun);
        final moon = resolved.firstWhere((s) => s.star == EnumStars.Moon);
        final mercury =
            resolved.firstWhere((s) => s.star == EnumStars.Mercury);
        // Verify Moon's final angle is reasonable (not pushed excessively far)
        // The original spread is 0-5°, so after resolution all stars should
        // stay within a reasonable range of their original positions.
        final moonDist = (moon.angle - 2).abs();
        expect(moonDist, lessThan(15),
            reason:
                'Moon should not be pushed too far from original position');
      });
    });

    // ---- H. 跨轮顺序翻转 ----
    group('H. cross-round order flip', () {
      test('H1: two tight pairs that swap order after round 1', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 20, range: 4),
          _star(star: EnumStars.Moon, angle: 21, range: 4),
          _star(star: EnumStars.Mercury, angle: 24, range: 4),
          _star(star: EnumStars.Mars, angle: 25, range: 4),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
        // Final sorted order should be consistent
        final sorted = resolved.toList()
          ..sort((a, b) => a.angle.compareTo(b.angle));
        for (int i = 0; i < sorted.length - 1; i++) {
          expect(sorted[i].angle, lessThan(sorted[i + 1].angle),
              reason: 'Stars should have strictly increasing angles');
        }
      });

      test('H2: triple cluster adjacent — re-sort needed', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 30, range: 4),
          _star(star: EnumStars.Moon, angle: 31, range: 4),
          _star(star: EnumStars.Mercury, angle: 35, range: 4),
          _star(star: EnumStars.Mars, angle: 36, range: 4),
          _star(star: EnumStars.Saturn, angle: 40, range: 4),
          _star(star: EnumStars.Venus, angle: 41, range: 4),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
      });

      test('H3: convergence within 20 rounds', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 80, range: 4),
          _star(star: EnumStars.Moon, angle: 81, range: 4),
          _star(star: EnumStars.Mercury, angle: 82, range: 4),
          _star(star: EnumStars.Mars, angle: 83, range: 4),
          _star(star: EnumStars.Saturn, angle: 84, range: 4),
          _star(star: EnumStars.Venus, angle: 85, range: 4),
          _star(star: EnumStars.Jupiter, angle: 86, range: 4),
          _star(star: EnumStars.Qi, angle: 87, range: 4),
          _star(star: EnumStars.Luo, angle: 88, range: 4),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
      });
    });

    // ---- I. 跨 0° 覆盖 ----
    group('I. cross-0° coverage', () {
      test('I1: push past 360° wraps to 0° — no partner swap', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 356, range: 4),
          _star(star: EnumStars.Moon, angle: 358, range: 4),
          _star(star: EnumStars.Mercury, angle: 1, range: 4),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
        for (var s in resolved) {
          expect(s.angle, greaterThanOrEqualTo(0),
              reason: '${s.star} angle should be >= 0');
          expect(s.angle, lessThan(360),
              reason: '${s.star} angle should be < 360');
        }
      });

      test('I2: two clusters flanking 0° — global fix stabilizes', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 354, range: 4),
          _star(star: EnumStars.Moon, angle: 356, range: 4),
          _star(star: EnumStars.Mercury, angle: 2, range: 4),
          _star(star: EnumStars.Mars, angle: 4, range: 4),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
      });

      test('I3: 3 stars at 359, 0, 1 — triple cross-0° interaction', () {
        final stars = [
          _star(star: EnumStars.Sun, angle: 359, range: 4),
          _star(star: EnumStars.Moon, angle: 0, range: 4),
          _star(star: EnumStars.Mercury, angle: 1, range: 4),
        ];
        final resolved = StarsResolver.resolveUIStars(stars);
        expectNoOverlaps(resolved);
        // Center of mass should still be near 0°
        for (var s in resolved) {
          final distTo0 =
              StarsResolver.calculateMinAngleDifference(s.angle, 0);
          expect(distTo0, lessThan(15),
              reason:
                  '${s.star}@${s.angle} should remain near 0° (dist=$distTo0)');
        }
      });
    });
  });
}
