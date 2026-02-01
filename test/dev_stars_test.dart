import 'package:flutter_test/flutter_test.dart';
import 'package:common/enums/enum_stars.dart';
import 'package:qizhengsiyu/presentation/models/ui_star_model.dart';
import 'package:qizhengsiyu/presentation/pages/StarsResolver.dart';
import 'package:tuple/tuple.dart';

void main() {
  const rangeAngle = 4.0;
  group("star adjust star:2 ", () {
    double rangeAngle = 4;
    test('around star 2 same angle 90', () {
      // 创建小球列表，除一个 priority = 4 的小球角度为 270° 外，其他都为 90°
      final stars = [
        UIStarModel(
            star: EnumStars.Sun,
            priority: 4,
            originalAngle: 90,
            rangeAngleEachSide: rangeAngle),
        UIStarModel(
            star: EnumStars.Moon,
            priority: 3,
            originalAngle: 90,
            rangeAngleEachSide: rangeAngle),
      ];

      final resolvedStars = StarsResolver.doResolveConstellation(stars);
      expect(resolvedStars.orderedStars.length, equals(2));
    });
    test('around star 2 same angle 0', () {
      // 创建小球列表，除一个 priority = 4 的小球角度为 270° 外，其他都为 90°
      final stars = [
        UIStarModel(
            star: EnumStars.Sun,
            priority: 4,
            originalAngle: 0,
            rangeAngleEachSide: rangeAngle),
        UIStarModel(
            star: EnumStars.Moon,
            priority: 3,
            originalAngle: 0,
            rangeAngleEachSide: rangeAngle),
      ];

      final resolvedStars = StarsResolver.doResolveConstellation(stars);
      resolvedStars.orderedStars.sort((a, b) => a.angle.compareTo(b.angle));
      expect(resolvedStars.orderedStars.length, equals(2));
      expect(resolvedStars.orderedStars.first.adjustCount, equals(1));
      expect(resolvedStars.orderedStars.last.adjustCount, equals(1));

      expect(resolvedStars.orderedStars.first.adjustedAngle, equals(2.0));
      expect(resolvedStars.orderedStars.last.adjustedAngle, equals(358.0));
    });
    test('around star 2 angle 0 and 1', () {
      // 创建小球列表，除一个 priority = 4 的小球角度为 270° 外，其他都为 90°
      final stars = [
        UIStarModel(
            star: EnumStars.Sun,
            priority: 4,
            originalAngle: 0,
            rangeAngleEachSide: rangeAngle),
        UIStarModel(
            star: EnumStars.Moon,
            priority: 3,
            originalAngle: 1,
            rangeAngleEachSide: rangeAngle),
      ];

      final resolvedStars = StarsResolver.doResolveConstellation(stars);
      resolvedStars.orderedStars.sort((a, b) => a.angle.compareTo(b.angle));
      expect(resolvedStars.orderedStars.length, equals(2));
      expect(resolvedStars.orderedStars.last.adjustedAngle, equals(358.5));
      expect(resolvedStars.orderedStars.first.adjustCount, equals(1));

      expect(resolvedStars.orderedStars.first.adjustedAngle, equals(2.5));
      expect(resolvedStars.orderedStars.last.adjustCount, equals(1));
    });

    test('around star 2 angle 359 and 1', () {
      // 创建小球列表，除一个 priority = 4 的小球角度为 270° 外，其他都为 90°
      final stars = [
        UIStarModel(
            star: EnumStars.Sun,
            priority: 4,
            originalAngle: 359,
            rangeAngleEachSide: rangeAngle),
        UIStarModel(
            star: EnumStars.Moon,
            priority: 3,
            originalAngle: 1,
            rangeAngleEachSide: rangeAngle),
      ];

      // var easyStars = stars.map((e)=>e.generateEasyCalculate()).toList();
      // print(easyStars);
      final resolvedStars = StarsResolver.doResolveConstellation(stars);
      resolvedStars.orderedStars.sort((a, b) => a.angle.compareTo(b.angle));
      expect(resolvedStars.orderedStars.length, equals(2));
      expect(resolvedStars.orderedStars.last.adjustedAngle, equals(358));
      expect(resolvedStars.orderedStars.first.adjustCount, equals(1));
      expect(resolvedStars.orderedStars.first.adjustedAngle, equals(2));
      expect(resolvedStars.orderedStars.last.adjustCount, equals(1));
    });
    test('around star 2 angle 1 and 359', () {
      // 创建小球列表，除一个 priority = 4 的小球角度为 270° 外，其他都为 90°
      final stars = [
        UIStarModel(
            star: EnumStars.Sun,
            priority: 4,
            originalAngle: 1,
            rangeAngleEachSide: rangeAngle),
        UIStarModel(
            star: EnumStars.Moon,
            priority: 3,
            originalAngle: 359,
            rangeAngleEachSide: rangeAngle),
      ];

      // var easyStars = stars.map((e)=>e.generateEasyCalculate()).toList();
      final resolvedStars = StarsResolver.doResolveConstellation(stars);
      // print(resolvedStars.orderedStars.map((e)=>e.angle));
      expect(resolvedStars.orderedStars.length, equals(2));

      expect(resolvedStars.orderedStars.last.adjustedAngle, equals(2));
      expect(resolvedStars.orderedStars.first.adjustCount, equals(1));

      expect(resolvedStars.orderedStars.first.adjustedAngle, equals(358));
      expect(resolvedStars.orderedStars.last.adjustCount, equals(1));
    });
  });

  group("star adjust star:3", () {
    double rangeAngle = 4;
    test('around star 3 same angle 90', () {
      // 创建小球列表，除一个 priority = 4 的小球角度为 270° 外，其他都为 90°
      final stars = [
        UIStarModel(
            star: EnumStars.Sun,
            priority: 4,
            originalAngle: 90,
            rangeAngleEachSide: rangeAngle),
        UIStarModel(
            star: EnumStars.Moon,
            priority: 3,
            originalAngle: 90,
            rangeAngleEachSide: rangeAngle),
        UIStarModel(
            star: EnumStars.Venus,
            priority: 2,
            originalAngle: 90,
            rangeAngleEachSide: rangeAngle),
      ];

      // final resolver = StarsResolver();
      final resolvedStars = StarsResolver.doResolveConstellation(stars);
      expect(resolvedStars.orderedStars.length, equals(3));

      expect(resolvedStars.orderedStars.first.adjustedAngle, equals(86));
      expect(resolvedStars.orderedStars.first.adjustCount, equals(1));

      expect(resolvedStars.orderedStars[1].angle, equals(90));
      expect(resolvedStars.orderedStars[1].adjustCount, equals(0));

      expect(resolvedStars.orderedStars.last.adjustedAngle, equals(94));
      expect(resolvedStars.orderedStars.last.adjustCount, equals(1));
    });
    test('around star 3 same angle 0', () {
      // 创建小球列表，除一个 priority = 4 的小球角度为 270° 外，其他都为 90°
      final stars = [
        UIStarModel(
            star: EnumStars.Sun,
            priority: 4,
            originalAngle: 0,
            rangeAngleEachSide: rangeAngle),
        UIStarModel(
            star: EnumStars.Moon,
            priority: 3,
            originalAngle: 0,
            rangeAngleEachSide: rangeAngle),
        UIStarModel(
            star: EnumStars.Venus,
            priority: 2,
            originalAngle: 0,
            rangeAngleEachSide: rangeAngle),
      ];

      final resolvedStars = StarsResolver.doResolveConstellation(stars);
      expect(resolvedStars.orderedStars.length, equals(3));

      expect(resolvedStars.orderedStars.first.adjustedAngle, equals(356));
      expect(resolvedStars.orderedStars.first.adjustCount, equals(1));

      expect(resolvedStars.orderedStars[1].angle, equals(0));
      expect(resolvedStars.orderedStars[1].adjustCount, equals(0));

      expect(resolvedStars.orderedStars.last.adjustedAngle, equals(4));
      expect(resolvedStars.orderedStars.last.adjustCount, equals(1));
    });
    test('around star 3 same angle 90,90,91', () {
      // 创建小球列表，除一个 priority = 4 的小球角度为 270° 外，其他都为 90°
      final stars = [
        UIStarModel(
            star: EnumStars.Sun,
            priority: 4,
            originalAngle: 90,
            rangeAngleEachSide: rangeAngle),
        UIStarModel(
            star: EnumStars.Moon,
            priority: 3,
            originalAngle: 90,
            rangeAngleEachSide: rangeAngle),
        UIStarModel(
            star: EnumStars.Venus,
            priority: 2,
            originalAngle: 91,
            rangeAngleEachSide: rangeAngle),
      ];

      final resolvedStars = StarsResolver.doResolveConstellation(stars);
      expect(resolvedStars.orderedStars.length, equals(3));

      expect(resolvedStars.orderedStars.first.adjustCount, equals(1));
      expect(resolvedStars.orderedStars[1].adjustCount, equals(1));
      expect(resolvedStars.orderedStars.last.adjustCount, equals(1));

      expect(resolvedStars.orderedStars.first.adjustedAngle, equals(88));
      expect(resolvedStars.orderedStars[1].angle, equals(92));
      expect(resolvedStars.orderedStars.last.adjustedAngle, equals(96));
    });
    test('around star 3 same angle 0,0,1', () {
      // 创建小球列表，除一个 priority = 4 的小球角度为 270° 外，其他都为 90°
      final stars = [
        UIStarModel(
            star: EnumStars.Sun,
            priority: 4,
            originalAngle: 0,
            rangeAngleEachSide: rangeAngle),
        UIStarModel(
            star: EnumStars.Moon,
            priority: 3,
            originalAngle: 0,
            rangeAngleEachSide: rangeAngle),
        UIStarModel(
            star: EnumStars.Venus,
            priority: 2,
            originalAngle: 1,
            rangeAngleEachSide: rangeAngle),
      ];

      final resolvedStars = StarsResolver.doResolveConstellation(stars);
      expect(resolvedStars.orderedStars.length, equals(3));

      expect(resolvedStars.orderedStars.first.adjustCount, equals(1));
      expect(resolvedStars.orderedStars[1].adjustCount, equals(1));
      expect(resolvedStars.orderedStars.last.adjustCount, equals(1));
      // print([resolvedStars.first.angle, resolvedStars[1].angle, resolvedStars.last.angle]);

      expect(resolvedStars.orderedStars.map((r) => r.angle).toSet(),
          equals({358.0, 2.0, 6.0}));
      // expect(resolvedStars.first.adjustedAngle, equals(2));
      // expect(resolvedStars[1].angle, equals(6));
      // expect(resolvedStars.last.adjustedAngle, equals(358));
    });
    test('around star 3 same angle 89,90,91', () {
      // 创建小球列表，除一个 priority = 4 的小球角度为 270° 外，其他都为 90°
      final stars = [
        UIStarModel(
            star: EnumStars.Sun,
            priority: 4,
            originalAngle: 89,
            rangeAngleEachSide: rangeAngle),
        UIStarModel(
            star: EnumStars.Moon,
            priority: 3,
            originalAngle: 90,
            rangeAngleEachSide: rangeAngle),
        UIStarModel(
            star: EnumStars.Venus,
            priority: 2,
            originalAngle: 91,
            rangeAngleEachSide: rangeAngle),
      ];

      final resolvedStars = StarsResolver.doResolveConstellation(stars);
      // print(resolvedStars.map((r)=>"${r.star.starName}[${r.angle}]"));
      expect(resolvedStars.orderedStars.length, equals(3));

      expect(resolvedStars.orderedStars.first.adjustCount, equals(1));
      expect(resolvedStars.orderedStars[1].adjustCount, equals(0));
      expect(resolvedStars.orderedStars.last.adjustCount, equals(1));

      // print(resolvedStars.map((r)=>r.angle));
      expect(resolvedStars.orderedStars.map((r) => r.angle).toSet(),
          equals({86.0, 90.0, 94.0}));
      // expect(resolvedStars.first.adjustedAngle, equals(86));
      // expect(resolvedStars[1].angle, equals(90));
      // expect(resolvedStars.last.adjustedAngle, equals(94));
    });
    test('around star 3 same angle 359,0,1', () {
      // 创建小球列表，除一个 priority = 4 的小球角度为 270° 外，其他都为 90°
      final stars = [
        UIStarModel(
            star: EnumStars.Sun,
            priority: 4,
            originalAngle: 359,
            rangeAngleEachSide: rangeAngle),
        UIStarModel(
            star: EnumStars.Moon,
            priority: 3,
            originalAngle: 0,
            rangeAngleEachSide: rangeAngle),
        UIStarModel(
            star: EnumStars.Venus,
            priority: 2,
            originalAngle: 1,
            rangeAngleEachSide: rangeAngle),
      ];

      final resolvedStars = StarsResolver.doResolveConstellation(stars);
      resolvedStars.orderedStars.sort((a, b) => a.angle.compareTo(b.angle));
      expect(resolvedStars.orderedStars.length, equals(3));

      expect(resolvedStars.orderedStars.first.adjustCount, equals(0));
      expect(resolvedStars.orderedStars[1].adjustCount, equals(1));
      expect(resolvedStars.orderedStars.last.adjustCount, equals(1));

      // expect(resolvedStars.last.adjustedAngle, equals(356));
      // expect(resolvedStars[0].angle, equals(0));
      // expect(resolvedStars[1].adjustedAngle, equals(2.0));
      expect(resolvedStars.orderedStars.map((r) => r.angle).toSet(),
          equals({356.0, 0.0, 4.0}));
    });

    test(
        'around star 6, there are 5 stars in range and other 1 star not in, but when those 5 stars adjusted, The other in range , [90,91,92,93,94, 102]',
        () {
      ///              [84,88,92,96,100, 102]

      Map<double, List<UIStarModel>> starsMapper = {};
      for (var s in [
        UIStarModel(
          star: EnumStars.Mercury,
          priority: 2,
          originalAngle: 90,
          rangeAngleEachSide: rangeAngle,
        ),
        UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 91,
          rangeAngleEachSide: rangeAngle,
        ),
        UIStarModel(
          star: EnumStars.Moon,
          priority: 3,
          originalAngle: 92,
          rangeAngleEachSide: rangeAngle,
        ),
        UIStarModel(
          star: EnumStars.Jupiter,
          priority: 2,
          originalAngle: 93,
          rangeAngleEachSide: rangeAngle,
        ),
        UIStarModel(
          star: EnumStars.Venus,
          priority: 2,
          originalAngle: 94,
          rangeAngleEachSide: rangeAngle,
        ),
      ]) {
        if (starsMapper.containsKey(s.originalAngle)) {
          starsMapper[s.originalAngle]!.add(s);
        } else {
          starsMapper[s.originalAngle] = [s];
        }
      }
      final result = StarsResolver.sortMultipleInRangeStars(starsMapper);
      expect(result.orderedStars.isNotEmpty, true);
      expect(result.orderedStars.length, equals(5));
      expect(result.orderedStars.map((s) => s.angle).toSet(),
          equals({84.0, 88.0, 92.0, 96.0, 100.0}));
    });
  });

  group("star ", () {
    test("", () {
      print(StarsResolver.sortCircularAngles([359, 3, 1, 2]));
      print(StarsResolver.sortCircularAngles(
          [358, 350, 0, 4, 359, 1, 2, 5, 7, 8, 9]));
      print(StarsResolver.sortCircularAngles([359, 358, 350, 0, 351, 240, 10]));
    });
  });

  group("doResolveSameAngleStars", () {
    double rangeAngle = 4.0;
    test("doResolveSameAngleStars 2", () {
      UIConstellationModel constellationModel =
          StarsResolver.doResolveSameAngleStars([
        UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 90,
          rangeAngleEachSide: rangeAngle,
        ),
        UIStarModel(
          star: EnumStars.Moon,
          priority: 3,
          originalAngle: 90,
          rangeAngleEachSide: rangeAngle,
        ),
      ]);
      Iterable<double> angleList =
          constellationModel.orderedStars.map((e) => e.angle);
      expect(angleList.length, equals(2));
      expect(angleList.toSet(), equals({88.0, 92.0}));
    });

    test("doResolveSameAngleStars 4", () {
      UIConstellationModel constellationModel =
          StarsResolver.doResolveSameAngleStars([
        UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 90,
          rangeAngleEachSide: rangeAngle,
        ),
        UIStarModel(
          star: EnumStars.Moon,
          priority: 3,
          originalAngle: 90,
          rangeAngleEachSide: rangeAngle,
        ),
        UIStarModel(
          star: EnumStars.Venus,
          priority: 2,
          originalAngle: 90,
          rangeAngleEachSide: rangeAngle,
        ),
        UIStarModel(
          star: EnumStars.Jupiter,
          priority: 2,
          originalAngle: 90,
          rangeAngleEachSide: rangeAngle,
        ),
      ]);
      Iterable<double> angleList =
          constellationModel.orderedStars.map((e) => e.angle);
      expect(angleList.length, equals(4));
      expect(angleList.toSet(), equals({84.0, 88.0, 92.0, 96.0}));
    });

    test("doResolveSameAngleStars 3", () {
      UIConstellationModel constellationModel =
          StarsResolver.doResolveSameAngleStars([
        UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 90,
          rangeAngleEachSide: rangeAngle,
        ),
        UIStarModel(
          star: EnumStars.Moon,
          priority: 3,
          originalAngle: 90,
          rangeAngleEachSide: rangeAngle,
        ),
        UIStarModel(
          star: EnumStars.Venus,
          priority: 2,
          originalAngle: 90,
          rangeAngleEachSide: rangeAngle,
        ),
        UIStarModel(
          star: EnumStars.Jupiter,
          priority: 2,
          originalAngle: 90,
          rangeAngleEachSide: rangeAngle,
        ),
        UIStarModel(
          star: EnumStars.Mercury,
          priority: 2,
          originalAngle: 90,
          rangeAngleEachSide: rangeAngle,
        ),
      ]);
      Iterable<double> angleList =
          constellationModel.orderedStars.map((e) => e.angle);
      expect(angleList.length, equals(5));
      expect(angleList.toSet(), equals({82.0, 86.0, 90.0, 94.0, 98.0}));
    });
  });
  group("sortInRangeStarsNoneSameAngleWithPriority", () {
    test("2 priority=4,3", () {
      UIConstellationModel constellationModel =
          StarsResolver.sortInRangeStarsNoneSameAngleWithPriority([
        UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 91,
          rangeAngleEachSide: rangeAngle,
        ),
        UIStarModel(
          star: EnumStars.Moon,
          priority: 3,
          originalAngle: 90,
          rangeAngleEachSide: rangeAngle,
        ),
      ]);
      // Iterable<double> angleList = constellationModel.map((e)=>e.angle);
      expect(constellationModel.orderedStars.length, equals(2));
      expect(constellationModel.orderedStars.map((s) => s.angle),
          equals([90, 91]));
    });
    test("3 priority=4,3,2 - [89,90,※91]", () {
      UIConstellationModel constellationModel =
          StarsResolver.sortInRangeStarsNoneSameAngleWithPriority([
        UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 91,
          rangeAngleEachSide: rangeAngle,
        ),
        UIStarModel(
          star: EnumStars.Moon,
          priority: 3,
          originalAngle: 90,
          rangeAngleEachSide: rangeAngle,
        ),
        UIStarModel(
          star: EnumStars.Venus,
          priority: 2,
          originalAngle: 89,
          rangeAngleEachSide: rangeAngle,
        ),
      ]);
      // Iterable<double> angleList = constellationModel.map((e)=>e.angle);
      expect(constellationModel.orderedStars.length, equals(3));
      expect(constellationModel.orderedStars.map((s) => s.angle),
          equals([89, 90, 91]));
    });
    test("3 priority=4,3,2 - [89,※91,92]", () {
      UIConstellationModel constellationModel =
          StarsResolver.sortInRangeStarsNoneSameAngleWithPriority([
        UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 91,
          rangeAngleEachSide: rangeAngle,
        ),
        UIStarModel(
          star: EnumStars.Moon,
          priority: 3,
          originalAngle: 92,
          rangeAngleEachSide: rangeAngle,
        ),
        UIStarModel(
          star: EnumStars.Venus,
          priority: 2,
          originalAngle: 89,
          rangeAngleEachSide: rangeAngle,
        ),
      ]);
      // Iterable<double> angleList = constellationModel.map((e)=>e.angle);
      expect(constellationModel.orderedStars.length, equals(3));
      expect(constellationModel.orderedStars.map((s) => s.angle),
          equals([89, 91, 92]));
    });

    test("3 priority=2,2,1 ", () {
      UIConstellationModel constellationModel =
          StarsResolver.sortInRangeStarsNoneSameAngleWithPriority([
        UIStarModel(
          star: EnumStars.Venus,
          priority: 2,
          originalAngle: 91,
          rangeAngleEachSide: rangeAngle,
        ),
        UIStarModel(
          star: EnumStars.Jupiter,
          priority: 2,
          originalAngle: 90,
          rangeAngleEachSide: rangeAngle,
        ),
        UIStarModel(
          star: EnumStars.Qi,
          priority: 1,
          originalAngle: 92,
          rangeAngleEachSide: rangeAngle,
        ),
      ]);
      // print(constellationModel.length);
      // Iterable<double> angleList = constellationModel.map((e)=>e.angle);
      expect(constellationModel.orderedStars.length, equals(3));
      expect(constellationModel.orderedStars.map((s) => s.angle),
          equals([90, 91, 92]));
    });
    test("4 priority=2,2,2,1 ", () {
      UIConstellationModel constellationModel =
          StarsResolver.sortInRangeStarsNoneSameAngleWithPriority([
        UIStarModel(
          star: EnumStars.Venus,
          priority: 2,
          originalAngle: 91,
          rangeAngleEachSide: rangeAngle,
        ),
        UIStarModel(
          star: EnumStars.Jupiter,
          priority: 2,
          originalAngle: 90,
          rangeAngleEachSide: rangeAngle,
        ),
        UIStarModel(
          star: EnumStars.Mercury,
          priority: 2,
          originalAngle: 89,
          rangeAngleEachSide: rangeAngle,
        ),
        UIStarModel(
          star: EnumStars.Qi,
          priority: 1,
          originalAngle: 92,
          rangeAngleEachSide: rangeAngle,
        ),
      ]);
      // Iterable<double> angleList = constellationModel.map((e)=>e.angle);
      expect(constellationModel.orderedStars.length, equals(4));
      expect(constellationModel.orderedStars.map((s) => s.angle),
          equals([89, 90, 91, 92]));
    });
  });

  group("sortStarByWithCircularAngle", () {
    test("sortStarByWithCircularAngle", () {
      final stars = [
        UIStarModel(
            star: EnumStars.Sun,
            priority: 4,
            originalAngle: 359,
            rangeAngleEachSide: rangeAngle),
        UIStarModel(
            star: EnumStars.Moon,
            priority: 3,
            originalAngle: 0,
            rangeAngleEachSide: rangeAngle),
        UIStarModel(
            star: EnumStars.Venus,
            priority: 2,
            originalAngle: 1,
            rangeAngleEachSide: rangeAngle),
      ];
      final res = StarsResolver.sortStarWithCircularAngleByCenterStar(
              stars, stars.first)
          .orderedStars;
      expect(res.length, equals(3));
      expect(res[0].star, equals(EnumStars.Sun));
      expect(res[1].star, equals(EnumStars.Moon));
      expect(res[2].star, equals(EnumStars.Venus));
    });
    test("sortStarByWithCircularAngle", () {
      final stars = [
        UIStarModel(
            star: EnumStars.Sun,
            priority: 4,
            originalAngle: 0,
            rangeAngleEachSide: rangeAngle),
        UIStarModel(
            star: EnumStars.Moon,
            priority: 3,
            originalAngle: 359,
            rangeAngleEachSide: rangeAngle),
        UIStarModel(
            star: EnumStars.Venus,
            priority: 2,
            originalAngle: 1,
            rangeAngleEachSide: rangeAngle),
      ];
      final res = StarsResolver.sortStarWithCircularAngleByCenterStar(
              stars, stars.first)
          .orderedStars;
      expect(res.length, equals(3));
      expect(res[0].star, equals(EnumStars.Moon));
      expect(res[1].star, equals(EnumStars.Sun));
      expect(res[2].star, equals(EnumStars.Venus));
    });
  });

  group('sortMultipleInRangeStars Tests', () {
    double rangeAngleEachSide = 4;
    // 测试奇数个不同角度且每个角度只有一个星体的情况
    test('Odd number of angles with one star per angle 3', () {
      Map<double, List<UIStarModel>> starsMapper = {};
      for (var s in [
        UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 10,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Moon,
          priority: 3,
          originalAngle: 11,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Venus,
          priority: 2,
          originalAngle: 12,
          rangeAngleEachSide: rangeAngleEachSide,
        )
      ]) {
        if (starsMapper.containsKey(s.originalAngle)) {
          starsMapper[s.originalAngle]!.add(s);
        } else {
          starsMapper[s.originalAngle] = [s];
        }
      }

      final result = StarsResolver.sortMultipleInRangeStars(starsMapper);
      expect(result.orderedStars.isNotEmpty, true);
      expect(result.orderedStars.length, equals(3));
      expect(
          result.orderedStars.map((s) => s.angle), equals({7.0, 11.0, 15.0}));
    });

    // 测试奇数个不同角度且每个角度只有一个星体的情况
    test('Odd number of angles , center angle with two stars', () {
      Map<double, List<UIStarModel>> starsMapper = {};
      for (var s in [
        UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 10,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Moon,
          priority: 3,
          originalAngle: 11,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Jupiter,
          priority: 2,
          originalAngle: 11,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Venus,
          priority: 2,
          originalAngle: 12,
          rangeAngleEachSide: rangeAngleEachSide,
        )
      ]) {
        if (starsMapper.containsKey(s.originalAngle)) {
          starsMapper[s.originalAngle]!.add(s);
        } else {
          starsMapper[s.originalAngle] = [s];
        }
      }

      final result = StarsResolver.sortMultipleInRangeStars(starsMapper);
      expect(result.orderedStars.isNotEmpty, true);
      expect(result.orderedStars.length, equals(4));
      expect(result.orderedStars.map((s) => s.angle),
          equals({5.0, 9.0, 13.0, 17.0}));
    });

    // 测试偶数个不同角度且每个角度只有一个星体的情况
    test('当有偶数个角度，且可以作为起始中间点的角度上一个有两个星体，另一个只有一个行星体', () {
      Map<double, List<UIStarModel>> starsMapper = {};
      for (var s in [
        UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 10,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Moon,
          priority: 3,
          originalAngle: 11,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Jupiter,
          priority: 2,
          originalAngle: 11,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
      ]) {
        if (starsMapper.containsKey(s.originalAngle)) {
          starsMapper[s.originalAngle]!.add(s);
        } else {
          starsMapper[s.originalAngle] = [s];
        }
      }

      final result = StarsResolver.sortMultipleInRangeStars(starsMapper);
      expect(result.orderedStars.isNotEmpty, true);
      expect(result.orderedStars.length, equals(3));
      expect(result.orderedStars.map((s) => s.angle), equals({5.0, 9.0, 13.0}));
    });

    // 测试偶数个不同角度且每个角度只有一个星体的情况
    test(
        'Even number angles, there a two same angle can be center, and both of them has two stars',
        () {
      // 当有偶数个角度，且可以作为起始中间点的角度上一个有两个星体，另一个也有两个星体'
      Map<double, List<UIStarModel>> starsMapper = {};
      for (var s in [
        UIStarModel(
          star: EnumStars.Mercury,
          priority: 2,
          originalAngle: 10,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 10,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Moon,
          priority: 3,
          originalAngle: 11,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Jupiter,
          priority: 2,
          originalAngle: 11,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
      ]) {
        if (starsMapper.containsKey(s.originalAngle)) {
          starsMapper[s.originalAngle]!.add(s);
        } else {
          starsMapper[s.originalAngle] = [s];
        }
      }

      final result = StarsResolver.sortMultipleInRangeStars(starsMapper);
      expect(result.orderedStars.isNotEmpty, true);
      expect(result.orderedStars.length, equals(4));
      expect(result.orderedStars.map((s) => s.angle).toSet(),
          equals({4.5, 8.5, 12.5, 16.5}));
    });

    // 测试偶数个不同角度且每个角度只有一个星体的情况
    test(
        'Even number angles, there a two same angle can be center, and both of them has two stars and both side has one star',
        () {
      // 当有偶数个角度，且可以作为起始中间点的角度上一个有两个星体，另一个也有两个星体'
      Map<double, List<UIStarModel>> starsMapper = {};
      for (var s in [
        UIStarModel(
          star: EnumStars.Mars,
          priority: 2,
          originalAngle: 8,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Mercury,
          priority: 2,
          originalAngle: 10,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 10,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Moon,
          priority: 3,
          originalAngle: 11,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Jupiter,
          priority: 2,
          originalAngle: 11,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Saturn,
          priority: 2,
          originalAngle: 12,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
      ]) {
        if (starsMapper.containsKey(s.originalAngle)) {
          starsMapper[s.originalAngle]!.add(s);
        } else {
          starsMapper[s.originalAngle] = [s];
        }
      }

      final result = StarsResolver.sortMultipleInRangeStars(starsMapper);
      expect(result.orderedStars.isNotEmpty, true);
      expect(result.orderedStars.length, equals(6));
      expect(result.orderedStars.map((s) => s.angle).toSet(),
          equals({0.5, 4.5, 8.5, 12.5, 16.5, 20.5}));
    });

    // 测试偶数个角度，中间最中间两个角度分别有且只有一个star
    test(
        'Even number angles, there a two same angle can be center, and both of them has two stars',
        () {
      // 当有偶数个角度，且可以作为起始中间点的角度上一个有两个星体，另一个也有两个星体'
      Map<double, List<UIStarModel>> starsMapper = {};
      for (var s in [
        UIStarModel(
          star: EnumStars.Mercury,
          priority: 2,
          originalAngle: 9,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 10,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Moon,
          priority: 3,
          originalAngle: 11,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Jupiter,
          priority: 2,
          originalAngle: 12,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
      ]) {
        if (starsMapper.containsKey(s.originalAngle)) {
          starsMapper[s.originalAngle]!.add(s);
        } else {
          starsMapper[s.originalAngle] = [s];
        }
      }

      final result = StarsResolver.sortMultipleInRangeStars(starsMapper);
      expect(result.orderedStars.isNotEmpty, true);
      expect(result.orderedStars.length, equals(4));
      expect(result.orderedStars.map((s) => s.angle).toSet(),
          equals({4.5, 8.5, 12.5, 16.5}));
    });

    // 测试奇数个不同角度且每个角度只有一个星体的情况
    test('Odd number angles,center angle with two stars', () {
      // 当有偶数个角度，且可以作为起始中间点的角度上一个有两个星体，另一个也有两个星体'
      Map<double, List<UIStarModel>> starsMapper = {};
      for (var s in [
        UIStarModel(
          star: EnumStars.Mercury,
          priority: 2,
          originalAngle: 10,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 11,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Moon,
          priority: 3,
          originalAngle: 11,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Jupiter,
          priority: 2,
          originalAngle: 12,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
      ]) {
        if (starsMapper.containsKey(s.originalAngle)) {
          starsMapper[s.originalAngle]!.add(s);
        } else {
          starsMapper[s.originalAngle] = [s];
        }
      }

      final result = StarsResolver.sortMultipleInRangeStars(starsMapper);
      expect(result.orderedStars.isNotEmpty, true);
      expect(result.orderedStars.length, equals(4));
      expect(result.orderedStars.map((s) => s.angle).toSet(),
          equals({5.0, 9.0, 13.0, 17.0}));
    });

    // 测试奇数个不同角度且每个角度只有一个星体的情况
    test('Odd number angles,center angle with two stars', () {
      // 当有偶数个角度，且可以作为起始中间点的角度上一个有两个星体，另一个也有两个星体'
      Map<double, List<UIStarModel>> starsMapper = {};
      for (var s in [
        UIStarModel(
          star: EnumStars.Mercury,
          priority: 2,
          originalAngle: 10,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 11,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Moon,
          priority: 3,
          originalAngle: 11,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Venus,
          priority: 2,
          originalAngle: 11,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Jupiter,
          priority: 2,
          originalAngle: 12,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
      ]) {
        if (starsMapper.containsKey(s.originalAngle)) {
          starsMapper[s.originalAngle]!.add(s);
        } else {
          starsMapper[s.originalAngle] = [s];
        }
      }

      final result = StarsResolver.sortMultipleInRangeStars(starsMapper);
      expect(result.orderedStars.isNotEmpty, true);
      expect(result.orderedStars.length, equals(5));
      expect(result.orderedStars.map((s) => s.angle).toSet(),
          equals({3.0, 7.0, 11.0, 15.0, 19.0}));
      expect(result.orderedStars[2].priority, equals(4));
    });

    // 测试奇数个不同角度且每个角度只有一个星体的情况
    test(
        'Odd number angles,center angle with two stars, one side angle has two stars',
        () {
      // 当有偶数个角度，且可以作为起始中间点的角度上一个有两个星体，另一个也有两个星体'
      Map<double, List<UIStarModel>> starsMapper = {};
      for (var s in [
        UIStarModel(
          star: EnumStars.Mercury,
          priority: 2,
          originalAngle: 10,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 11,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Moon,
          priority: 3,
          originalAngle: 11,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Jupiter,
          priority: 2,
          originalAngle: 12,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Venus,
          priority: 2,
          originalAngle: 12,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
      ]) {
        if (starsMapper.containsKey(s.originalAngle)) {
          starsMapper[s.originalAngle]!.add(s);
        } else {
          starsMapper[s.originalAngle] = [s];
        }
      }

      final result = StarsResolver.sortMultipleInRangeStars(starsMapper);
      expect(result.orderedStars.isNotEmpty, true);
      expect(result.orderedStars.length, equals(5));
      expect(result.orderedStars.map((s) => s.angle).toSet(),
          equals({5.0, 9.0, 13.0, 17.0, 21.0}));
    });
  });

  group('doResolveFixRightEdgeAngle Tests', () {
    double rangeAngleEachSide = 4;
    test("1", () {
      List<UIStarModel> stars = [
        UIStarModel(
          star: EnumStars.Sun,
          priority: 4,
          originalAngle: 5,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Moon,
          priority: 3,
          originalAngle: 9,
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Jupiter,
          priority: 3,
          originalAngle: 13, // 13
          rangeAngleEachSide: rangeAngleEachSide,
        ),
        UIStarModel(
          star: EnumStars.Venus,
          priority: 2,
          originalAngle: 17, // 17
          rangeAngleEachSide: rangeAngleEachSide,
        )
      ];
      UIConstellationModel constellationModel =
          UIConstellationModel(orderedStars: stars);
      constellationModel.toLeftAdjustAngle(1);
      expect(constellationModel.orderedStars.map((s) => s.angle).toSet(),
          equals({4, 8, 12, 16}));
      // UIConstellationModel? result = StarsResolver.doResolveFixRightEdgeAngle(stars, 16);
      // expect(result, isNotNull);
      // expect(result!.orderedStars.isNotEmpty, true);
      // expect(result.orderedStars.length, equals(4));
      // // expect(result.orderedStars.map((s)=>s.angle).toSet(), equals({5,9,13,17}));
      // expect(result.orderedStars.map((s)=>s.angle).toSet(), equals({4,8,12,16}));
      //
    });
  });
  group("doResolveConstellationWithStars Test", () {
    test("do test", () {
      double rangeAngleEachSide = 4;
      Tuple2<UIConstellationModel, List<UIStarModel>> result =
          StarsResolver.doResolveConstellationWithStars(
              UIConstellationModel(orderedStars: [
                UIStarModel(
                  star: EnumStars.Sun,
                  priority: 4,
                  originalAngle: 10,
                  rangeAngleEachSide: rangeAngleEachSide,
                ),
                UIStarModel(
                  star: EnumStars.Moon,
                  priority: 3,
                  originalAngle: 14,
                  rangeAngleEachSide: rangeAngleEachSide,
                ),
              ]),
              [
            UIStarModel(
              star: EnumStars.Venus,
              priority: 2,
              originalAngle: 8,
              rangeAngleEachSide: rangeAngleEachSide,
            ),
            UIStarModel(
              star: EnumStars.Jupiter,
              priority: 2,
              originalAngle: 16,
              rangeAngleEachSide: rangeAngleEachSide,
            ),
            UIStarModel(
              star: EnumStars.Mercury,
              priority: 2,
              originalAngle: 258,
              rangeAngleEachSide: rangeAngleEachSide,
            ),
          ]);

      expect(result.item1.orderedStars.length, equals(4));
      expect(result.item2.length, equals(2));
      expect(result.item1.orderedStars.map((s) => s.angle).toSet(),
          equals({6, 10, 14, 18}));
      expect(result.item2.map((s) => s.star),
          equals({EnumStars.Venus, EnumStars.Jupiter}));
    });
  });

  group("handleTwoConstellation Tests", () {
    test("other one to right", () {
      double rangeAngleEachSide = 4;
      StarsResolver.handleTwoConstellationModel([
        UIConstellationModel(orderedStars: [
          UIStarModel(
            star: EnumStars.Sun,
            priority: 4,
            originalAngle: 10,
            rangeAngleEachSide: rangeAngleEachSide,
          ),
          UIStarModel(
            star: EnumStars.Moon,
            priority: 3,
            originalAngle: 14,
            rangeAngleEachSide: rangeAngleEachSide,
          ),
        ]),
        UIConstellationModel(orderedStars: [
          UIStarModel(
            star: EnumStars.Venus,
            priority: 2,
            originalAngle: 13,
            rangeAngleEachSide: rangeAngleEachSide,
          ),
          UIStarModel(
            star: EnumStars.Jupiter,
            priority: 3,
            originalAngle: 17,
            rangeAngleEachSide: rangeAngleEachSide,
          ),
        ])
      ]);
      expect("1", "1");
    });
    test("other one to left", () {
      double rangeAngleEachSide = 4;
      StarsResolver.handleTwoConstellationModel([
        UIConstellationModel(orderedStars: [
          UIStarModel(
            star: EnumStars.Sun,
            priority: 4,
            originalAngle: 10,
            rangeAngleEachSide: rangeAngleEachSide,
          ),
          UIStarModel(
            star: EnumStars.Moon,
            priority: 3,
            originalAngle: 14,
            rangeAngleEachSide: rangeAngleEachSide,
          ),
        ]),
        UIConstellationModel(orderedStars: [
          UIStarModel(
            star: EnumStars.Venus,
            priority: 2,
            originalAngle: 5,
            rangeAngleEachSide: rangeAngleEachSide,
          ),
          UIStarModel(
            star: EnumStars.Jupiter,
            priority: 3,
            originalAngle: 9,
            rangeAngleEachSide: rangeAngleEachSide,
          ),
        ])
      ]);
      expect("1", "1");
    });
  });
  group("midpoint", () {
    test("midpoint 0, 360", () {
      final res = StarsResolver.calculateMidpointAngle(0, 360);
      expect(res, equals(0));
    });
    test("midpoint 10, 350", () {
      final res = StarsResolver.calculateMidpointAngle(10, 350);
      expect(res, equals(0));
    });
    test("midpoint 24, 29", () {
      final res = StarsResolver.calculateMidpointAngle(24, 29);
      expect(res, equals(26.5));
    });
    test("midpoint 352, 350", () {
      final res = StarsResolver.calculateMidpointAngle(352, 350);
      expect(res, equals(351));
    });

    test("middleAngle , 352, 350", () {
      expect(2, equals(StarsResolver.calculateMinAngleDifference(352, 350)));
      expect(2, equals(StarsResolver.calculateMinAngleDifference(350, 352)));
    });

    test("splitAngles [12,18,20,28] 19", () {
      var result = splitAngles([12, 18, 20, 28], 19);
      expect(result.item1, [12, 18]);
      expect(result.item2, [20, 28]);
    });

    test("splitAngles [338, 350, 2, 4] 0", () {
      var result = splitAngles([338, 350, 2, 4], 0);
      expect(result.item1, [338, 350]);
      expect(result.item2, [2, 4]);
    });
    test("arcsIntersect", () {
      // expect(arcsIntersect([10,20,30], [352,4,12]),isTrue);
      // expect(adjustArcsToAvoidIntersection([10,20,30], [352,4,12]),equals([350,2,10]));
      // expect(arcsIntersect([10,20,30], [45,46,47]),isFalse);
      //
      expect(arcsIntersect([10, 20, 30], [352, 4, 12]), isTrue);
      expect(arcsIntersect([10, 20, 30], [45, 46, 47]), isFalse);
    });
  });
}

bool isAngleInArc(int angle, int start, int end) {
  if (start <= end) {
    return angle >= start && angle <= end;
  }
  return angle >= start || angle <= end;
}

// 判断两个弧是否相交
bool arcsIntersect(List<int> arcA, List<int> arcB) {
  int startA = arcA[0];
  int endA = arcA[2];
  int startB = arcB[0];
  int endB = arcB[2];

  bool startAInB = isAngleInArc(startA, startB, endB);
  bool endAInB = isAngleInArc(endA, startB, endB);
  bool startBInA = isAngleInArc(startB, startA, endA);
  bool endBInA = isAngleInArc(endB, startA, endA);

  return startAInB || endAInB || startBInA || endBInA;
}

// 计算将一个弧移动到不与另一个弧相交所需的最小调整角度
int calculateAdjustment(
    int ownStart, int ownEnd, int otherStart, int otherEnd) {
  int adjustRight = (otherStart - ownEnd + 360) % 360;
  int adjustLeft = (ownStart - otherEnd + 360) % 360;
  return adjustRight < adjustLeft ? adjustRight : adjustLeft;
}

// 调整弧的角度
List<int> adjustArc(List<int> arc, int adjustment, bool moveRight) {
  int start = arc[0];
  int center = arc[1];
  int end = arc[2];

  if (moveRight) {
    return [
      (start + adjustment) % 360,
      (center + adjustment) % 360,
      (end + adjustment) % 360
    ];
  }
  return [
    (start - adjustment + 360) % 360,
    (center - adjustment + 360) % 360,
    (end - adjustment + 360) % 360
  ];
}

Tuple2<List<int>, List<int>> splitAngles(List<int> angles, int targetAngle) {
  List<int> part1 = [];
  List<int> part2 = [];

  for (int angle in angles) {
    // 计算当前角度与目标角度的最小差值
    // int diff1 = (angle - targetAngle).abs();
    // int diff2 = 360 - diff1;
    // int minDiff = diff1 < diff2 ? diff1 : diff2;
    //
    // 判断从目标角度顺时针还是逆时针到当前角度距离更近
    bool isClockwise = (angle - targetAngle + 360) % 360 < 180;

    if (isClockwise) {
      part2.add(angle);
    } else {
      part1.add(angle);
    }
  }

  return Tuple2(part1, part2);
}

List<int> sortCircularAngles_int(List<int> angles) {
  var lists = angles.toSet().toList()..sort();
  print(lists);
  // 找到中间数
  var anchor = lists[lists.length ~/ 2];
  // 删除中间点避免重复计算
  lists.removeAt(lists.length ~/ 2);
  // 确定360°距离当前位置有多少度数
  var zeroToAnchor = anchor;
  // 锚点以左应该有的数字
  Map<int, int> anchorLeftMapper = {};
  // 锚点以右应该有的数字
  Map<int, int> anchorRightMapper = {};
  for (int i = 0; i < lists.length; i++) {
    // 分别进行计算
    final current = lists[i];
    if (anchor < current) {
      // 1. 360 - _current
      // 以毛掉anchor 为原点， 当前数字 距离锚点左的距离
      var toAnchorLeft = 360 - current + zeroToAnchor;
      // 以毛掉anchor 为原点， 当前数字 距离锚点右的距离
      var toAnchorRight = current - zeroToAnchor;
      if (toAnchorLeft > toAnchorRight) {
        anchorLeftMapper[toAnchorRight] = current;
      } else {
        anchorRightMapper[toAnchorLeft] = current;
      }
    } else {
      // if anchor > _current
      var toAnchorLeft = anchor - current;
      var toAnchorRight = 360 - (anchor - current);
      // if (_current == 0){
      //   print("${_toAnchorLeft} ${_toAnchorRight}");
      // }
      if (toAnchorLeft > toAnchorRight) {
        anchorLeftMapper[toAnchorRight] = current;
      } else {
        anchorRightMapper[toAnchorLeft] = current;
      }
    }
  }
  List<int> sortedLeftKeys = anchorLeftMapper.keys.toList()..sort();

  List<int> sortedRightKeys = anchorRightMapper.keys.toList()..sort();
  List<int> rightNumber =
      sortedLeftKeys.map((e) => anchorLeftMapper[e]!).toList();
  // print("~~~~~~");
  // print(sortedRightKeys);
  List<int> leftNumbers =
      sortedRightKeys.reversed.map((e) => anchorRightMapper[e]!).toList();
  // print(leftNumbers);
  // print(anchor);
  // print(rightNumber);
  //
  // print("------");
  return [...leftNumbers, anchor, ...rightNumber];
}

List<int> sortCircularAngles_bak(List<int> angles) {
  // 找到最大角度的索引
  int maxIndex = 0;
  int maxAngle = angles[0];
  for (int i = 1; i < angles.length; i++) {
    if (angles[i] > maxAngle) {
      maxAngle = angles[i];
      maxIndex = i;
    }
  }

  // 将列表从最大角度处分割并重新组合
  List<int> firstPart = angles.sublist(maxIndex);
  List<int> secondPart = angles.sublist(0, maxIndex);
  List<int> combined = [...firstPart, ...secondPart];

  return combined;
}
