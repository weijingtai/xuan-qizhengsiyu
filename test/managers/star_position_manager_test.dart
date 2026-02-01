import 'package:flutter_test/flutter_test.dart';
import 'package:common/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/gong_star_info.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/entities/models/star_enter_info.dart';
import 'package:qizhengsiyu/domain/managers/star_position_manager.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

void main() {
  late StarPositionManager manager;
  late List<EnteredInfo> mockEnteredInfos;

  setUp(() {
    // 创建模拟数据
    mockEnteredInfos = [
      EnteredInfo(
        originalStar: StarDegree(star: EnumStars.Sun, degree: 15.0),
        enterGongInfo: GongDegree(
          gong: EnumTwelveGong.Zi,
          degree: 15.5,
        ),
        enterInnInfo: ConstellationDegree(
          constellation: Enum28Constellations.Lou_Jin_Gou,
          degree: 21.0,
        ),
      ),
      EnteredInfo(
        originalStar: StarDegree(star: EnumStars.Moon, degree: 15.0),
        enterGongInfo: GongDegree(
          gong: EnumTwelveGong.Zi,
          degree: 2.0,
        ),
        enterInnInfo: ConstellationDegree(
          constellation: Enum28Constellations.Lou_Jin_Gou,
          degree: 15.0,
        ),
      ),
      EnteredInfo(
        originalStar: StarDegree(star: EnumStars.Mars, degree: 195.0),
        enterGongInfo: GongDegree(
          gong: EnumTwelveGong.Wu,
          degree: 10.0,
        ),
        enterInnInfo: ConstellationDegree(
          constellation: Enum28Constellations.Xing_Ri_Ma,
          degree: 15.0,
        ),
      ),
    ];

    manager = StarPositionManager(
      enteredInfos: mockEnteredInfos,
      tongLuoRangeDegree: 0.5,
    );
  });

  group('StarPositionManager Tests', () {
    test('calculateSameGong - 同宫测试', () {
      final result = manager.calculateSameGong();

      expect(result, isNotNull);
      expect(result!.length, 1);

      final sameGongInfo = result.first;
      expect(sameGongInfo.positionType, StarGongPositionType.tongGong);
      expect(sameGongInfo.mapper.length, 1);
      expect(sameGongInfo.mapper[EnumTwelveGong.Zi], contains(EnumStars.Sun));
      expect(sameGongInfo.mapper[EnumTwelveGong.Zi], contains(EnumStars.Moon));
    });

    test('calculateOppositeGong - 对宫测试', () {
      // 添加对宫星体数据
      mockEnteredInfos.add(
        EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Venus, degree: 195.0),
          enterGongInfo: GongDegree(
            gong: EnumTwelveGong.Wu,
            degree: 14.0,
          ),
          enterInnInfo: ConstellationDegree(
            constellation: Enum28Constellations.Xing_Ri_Ma,
            degree: 15.0,
          ),
        ),
      );

      final result = manager.calculateOppositeGong();

      expect(result, isNotNull);
      expect(result!.length, 1);

      final oppositeGongInfo = result.first;
      expect(oppositeGongInfo.positionType, StarGongPositionType.duiGong);
      expect(oppositeGongInfo.mapper.length, 2);
      expect(oppositeGongInfo.mapper[EnumTwelveGong.Zi], isNotNull);
      expect(oppositeGongInfo.mapper[EnumTwelveGong.Wu], isNotNull);
    });

    test('calculateSameLuo - 同络测试', () {
      // 添加同络星体数据
      mockEnteredInfos.add(
        EnteredInfo(
          originalStar: StarDegree(star: EnumStars.Jupiter, degree: 75.0),
          enterGongInfo: GongDegree(
            gong: EnumTwelveGong.Mao,
            degree: 15.7,
          ),
          enterInnInfo: ConstellationDegree(
            constellation: Enum28Constellations.Bi_Yue_Wu,
            degree: 15.0,
          ),
        ),
      );

      final result = manager.calculateSameLuo(0.5);

      expect(result, isNotNull);
      expect(result!.length, 1);

      final sameLuoInfo = result.first;
      expect(sameLuoInfo.star, isIn([EnumStars.Jupiter]));
      expect(sameLuoInfo.sameLuoStars.length, 1);
    });

    test('isInSameDegree - 度数判断测试', () {
      expect(manager.isInSameDegree(15.0, 15.2, 0.5), isTrue);
      expect(manager.isInSameDegree(15.0, 15.6, 0.5), isFalse);
    });
  });
}
