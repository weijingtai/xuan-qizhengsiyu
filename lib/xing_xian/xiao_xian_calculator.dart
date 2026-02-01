import 'package:common/enums.dart';
import 'package:common/models/year_month.dart';
import 'package:qizhengsiyu/xing_xian/gong_constellation_mapping.dart';

import '../domain/entities/models/star_enter_info.dart';
import '../enums/enum_twelve_gong.dart';
import '../enums/enum_xing_xian_type.dart';
import 'base_xian_calculator.dart';
import 'base_xian_palace.dart';
import 'da_xian_constellation_passage_info.dart';
import 'da_xian_palace_info.dart';
import 'star_influence_model.dart';
import 'xiao_xian_detail_palace.dart';

/// 洞微小限计算器
class XiaoXianCalculator extends BaseXianCalculator {
  XiaoXianCalculator({
    required super.zhouTianModel,
    required super.basePanel,
    required super.observerPosition,
    required super.daxianPalaceOrder,
    required super.daxianPalaceDurations,
    super.isRetrograde = true,
    super.luoRangeDegree = 1.0,
    super.dingRangeDegree = 1.0,
  });
  // // 辅助方法：计算星宿过限信息
  // List<DaXianConstellationPassageInfo> _calculateConstellationPassages(
  //     EnumTwelveGong palace, DateTime startTime, YearMonth duration) {
  //   // 根据宫位和时间范围计算星宿过限信息
  //   // 这里需要根据具体的星宿计算逻辑来实现
  //   return [];
  // }

  /// 计算小限信息
  /// [startAge] 起始年龄
  /// [endAge] 结束年龄
  /// [birthDate] 出生日期
  /// 返回小限宫位信息列表
  XiaoXianDetailPalace calculateEach({
    required PalaceMappingResult object,
    required DateTime startTime,
    required YearMonth startAge,
  }) {
    double totalGongDegree = object.totalWidthDeg;
    List<XiaoXianDetailPalace> xiaoXianList = [];

    // 从起始年龄开始，每年计算一个小限
    // 计算当前年龄对应的小限起始时间（生日）
    DateTime xiaoXianStartTime = startTime;

    // 计算小限结束时间（下一个生日）
    DateTime xiaoXianEndTime =
        startTime.add(Duration(days: _isLeapYear(startTime.year) ? 366 : 365));
    // 计算小限宫位（根据年龄确定）

    List<DaXianConstellationPassageInfo> constellationPassages =
        calculateXingXianStarPassages(
      targetPalaceMapping: object,
      daxianDuration: YearMonth(1, 0),
      daxianStartTime: startTime,
      daxianStartAge: startAge,
      isRetrograde: true,
    );

    XiaoXianDetailPalace xiaoXianDetailPalace = XiaoXianDetailPalace(
      order: startAge.year + 1,
      palace: object.palaceName,
      startAge: startAge,
      endAge: YearMonth.fromYear(startAge.year + 1),
      startTime: xiaoXianStartTime,
      endTime: xiaoXianEndTime,
      durationYears: YearMonth.oneYear(),
      constellationPassages: constellationPassages,
      totalGongDegreee: totalGongDegree, // 每宫30度
      xingXianType: EnumXingXianType.yang9,
    );

    return xiaoXianDetailPalace;

    // 设置星体影响
  }

  /// 计算指定年龄的生日日期
  /// [birthDate] 出生日期
  /// [age] 年龄
  /// 返回对应年龄的生日日期
  DateTime _calculateBirthdayForAge(DateTime birthDate, int age) {
    int targetYear = birthDate.year + age;

    // 处理闰年2月29日的特殊情况
    if (birthDate.month == 2 && birthDate.day == 29) {
      // 如果目标年份不是闰年，则使用2月28日
      if (!_isLeapYear(targetYear)) {
        return DateTime(targetYear, 2, 28, birthDate.hour, birthDate.minute,
            birthDate.second);
      }
    }

    return DateTime(
      targetYear,
      birthDate.month,
      birthDate.day,
      birthDate.hour,
      birthDate.minute,
      birthDate.second,
    );
  }

  /// 判断是否为闰年
  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// 计算小限宫位
  /// [age] 年龄
  /// [birthDate] 出生日期
  /// 返回对应的小限宫位
  EnumTwelveGong _calculateXiaoXianPalace(int age, DateTime birthDate) {
    // 根据出生年份的地支确定起始宫位
    // 这里需要根据具体的小限计算规则来实现
    // 暂时使用简单的轮转方式
    int birthYearZhi = (birthDate.year - 4) % 12; // 甲子年为0
    int palaceIndex = (birthYearZhi + age) % 12;
    return EnumTwelveGong.values[palaceIndex];
  }

  @override
  StarGongInfluence? calculateStarInfluences({
    required EnumTwelveGong targetPalace,
    required Map<EnumStars, EnteredInfo> starsEnterInfo,
  }) {
    // 计算本宫影响
    List<PalaceStarInfluenceModel> sameGongInfluence =
        calculateSameGongInfluence(
      targetPalace: targetPalace,
      starsEnterInfo: starsEnterInfo,
    );

    // 计算对宫影响
    List<PalaceStarInfluenceModel> oppositeGongInfluence =
        calculateOppositeGongInfluence(
      targetPalace: targetPalace,
      starsEnterInfo: starsEnterInfo,
    );

    // 计算三方影响
    Map<EnumTwelveGong, List<PalaceStarInfluenceModel>> triangleGongInfluence =
        calculateTriangleGongInfluence(
      targetPalace: targetPalace,
      starsEnterInfo: starsEnterInfo,
    );

    // 计算四正影响
    Map<EnumTwelveGong, List<PalaceStarInfluenceModel>> squareGongInfluence =
        calculateSquareGongInfluence(
      targetPalace: targetPalace,
      starsEnterInfo: starsEnterInfo,
    );

    // 注意：这里移除了同络影响的计算

    // 检查是否所有影响列表都为空
    if (sameGongInfluence.isEmpty &&
        oppositeGongInfluence.isEmpty &&
        triangleGongInfluence.isEmpty &&
        squareGongInfluence.isEmpty) {
      return null;
    }

    return StarGongInfluence(
      sameGongInfluence: sameGongInfluence.isEmpty ? null : sameGongInfluence,
      oppositeGongInfluence:
          oppositeGongInfluence.isEmpty ? null : oppositeGongInfluence,
      triangleGongInfluence:
          triangleGongInfluence.isEmpty ? null : triangleGongInfluence,
      squareGongInfluence:
          squareGongInfluence.isEmpty ? null : squareGongInfluence,
      sameLuoInfluence: null, // 明确设置为null，不计算同络影响
    );
  }

  @override
  DingStarInfluenceModel createDingStarInfluence(
      PalaceStarInfluenceModel starInfluence,
      BaseXianPalace daXianPassageGong,
      EnumInfluenceType influenceType) {
    // TODO: implement createDingStarInfluence
    throw UnimplementedError();
  }
}
