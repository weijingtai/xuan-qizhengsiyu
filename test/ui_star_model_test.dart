import 'package:flutter_test/flutter_test.dart';
import 'package:common/enums/enum_stars.dart';
import 'package:qizhengsiyu/presentation/models/ui_star_model.dart';
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

    test('[defect-3] multiple wrapping: -400 should be 320, actual is -40', () {
      final result = s.correctCircleAngle(-400);
      // KNOWN DEFECT: correctCircleAngle only does a single +360 for negatives.
      // Correct behavior: -400 % 360 → 320
      // Actual behavior: 360 + (-400) = -40 (still negative, not in [0,360))
      // expect(result, equals(320)); // correct
      expect(result, equals(-40)); // proves the bug: single wrap fails for < -360
    });

    test('[defect-3] multiple wrapping: 800 should be 80, actual is 440', () {
      final result = s.correctCircleAngle(800);
      // KNOWN DEFECT: correctCircleAngle only does a single -360 for values >=360.
      // Correct behavior: 800 % 360 → 80
      // Actual behavior: 800 - 360 = 440 (still >= 360)
      // expect(result, equals(80)); // correct
      expect(result, equals(440)); // proves the bug: single wrap fails for >= 720
    });
  });

  // ============================================================
  // Group 2: getMinDiffAngleOfTwoStar
  // ============================================================
  group('getMinDiffAngleOfTwoStar', () {
    test('[regression] same rangeAngle returns that value', () {
      final s1 = _star(angle: 10, range: 4);
      final s2 = _star(angle: 20, range: 4);
      expect(UIStarModel.getMinDiffAngleOfTwoStar(s1, s2), equals(4));
    });

    test('[defect-4] different rangeAngle (3,5) returns max(5) not sum(8)', () {
      final s1 = _star(angle: 10, range: 3);
      final s2 = _star(angle: 20, range: 5);
      final result = UIStarModel.getMinDiffAngleOfTwoStar(s1, s2);
      // KNOWN DEFECT: The method returns max(rangeAngleEachSide) instead of
      // sum(rangeAngleEachSide) which is the actual minimum distance needed
      // for two stars not to overlap (since each side extends by its own range).
      // Correct behavior: 3 + 5 = 8
      // Actual behavior: max(3, 5) = 5
      // expect(result, equals(8)); // correct
      expect(result, equals(5)); // proves the bug: uses max instead of sum
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
    test('[defect-9] compareTo never returns -1', () {
      final s1 = _star(star: EnumStars.Sun, angle: 90, range: 4);
      final s2 = _star(star: EnumStars.Moon, angle: 90, range: 4);
      // KNOWN DEFECT: compareTo returns 1 when stars differ, never -1.
      // For a correct Comparable implementation, if a.compareTo(b) > 0
      // then b.compareTo(a) < 0 must hold. But here both return 1.
      final forward = s1.compareTo(s2);
      final backward = s2.compareTo(s1);
      // Correct behavior: forward and backward should have opposite signs
      // expect(forward, equals(-backward)); // correct
      // Actual behavior: both return 1
      expect(forward, equals(1));
      expect(backward, equals(1)); // proves the bug: asymmetric compareTo
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
}
