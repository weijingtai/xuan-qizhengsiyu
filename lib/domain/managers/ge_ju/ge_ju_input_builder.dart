import 'package:common/enums.dart';
import 'package:common/enums/enum_four_seasons.dart';
import 'package:flutter/foundation.dart';
import 'package:qizhengsiyu/dataset/star_position_status_model.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/di_zhi_shen_sha.dart';
import 'package:qizhengsiyu/domain/entities/models/eleven_stars_info.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_input.dart';
import 'package:qizhengsiyu/domain/entities/models/star_to_star_relationship_model.dart';
import 'package:qizhengsiyu/enums/enum_moon_phases.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:qizhengsiyu/enums/enum_star_position_status.dart';
import 'package:qizhengsiyu/enums/enum_stars_four_type.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

/// 格局输入构建器
/// 负责从 BasePanelModel 和其他数据源构建 GeJuInput
class GeJuInputBuilder {
  /// 从 BasePanelModel 和相关数据构建 GeJuInput
  ///
  /// [panelModel] 基础命盘模型
  /// [starsSet] 十一颗星体的完整信息集合
  /// [monthZhi] 出生月地支
  /// [yearJiaZi] 出生年甲子
  /// [coordinateSystem] 坐标系统（默认黄道制）
  /// [starStatusDataList] 星曜庙旺等状态数据（从数据库加载），可选
  /// [currentXianGong] 当前行限宫位（行限格局专用），可选
  /// [currentXianConstellation] 当前行限星宿（行限格局专用），可选
  /// [xianPalaceStars] 行限宫内星曜列表（行限格局专用），可选
  static GeJuInput build({
    required BasePanelModel panelModel,
    required Set<ElevenStarsInfo> starsSet,
    required DiZhi monthZhi,
    required JiaZi yearJiaZi,
    CelestialCoordinateSystem coordinateSystem = CelestialCoordinateSystem.ecliptic,
    Set<String> preferredSchools = const {'guo_lao'},
    List<StarPositionStatusDatasetModel<EnumTwelveGong>>? starStatusDataList,
    EnumTwelveGong? currentXianGong,
    Enum28Constellations? currentXianConstellation,
    List<EnumStars>? xianPalaceStars,
  }) {
    // 1. 构建星曜关系模型
    final starRelationship = StarToStarRelationshipModel.create(starsSet);

    // 2. 反转 twelveGongMapper: Map<EnumTwelveGong, EnumDestinyTwelveGong> -> Map<EnumDestinyTwelveGong, EnumTwelveGong>
    final destinyGongMapper = _invertTwelveGongMapper(panelModel.twelveGongMapper);

    // 3. 获取恩难仇用映射
    final starsFourTypeMapper = EnumStarsFourType.getStarsFourTypeMapper();

    // 4. 计算季节
    final season = FourSeasons.getFourSeason(monthZhi);

    // 5. 计算昼夜生
    final isDayBirth = _calculateIsDayBirth(starsSet);

    // 6. 获取月相
    final moonPhase = _getMoonPhase(starsSet);

    // 7. 构建甲子类神煞（空亡、孤虚等）
    final jiaZiShenSha = _buildJiaZiShenSha();

    // 8. 构建星曜庙旺状态映射（如果提供了数据）
    Map<EnumStars, List<EnumStarGongPositionStatusType>>? starGongStatusMapper;
    if (starStatusDataList != null) {
      starGongStatusMapper = _buildStarGongStatusMapper(
        starsSet,
        starStatusDataList,
      );
    }

    return GeJuInput(
      coordinateSystem: coordinateSystem,
      preferredSchools: preferredSchools,
      starsSet: starsSet,
      starRelationship: starRelationship,
      fiveStarWalkingTypeMapper: panelModel.fiveStarWalkingTypeMapper,
      bodyLifeModel: panelModel.bodyLifeModel,
      destinyGongMapper: destinyGongMapper,
      starsFourTypeMapper: starsFourTypeMapper,
      huaYaoMapper: panelModel.huaYaoItemMapper,
      season: season,
      monthZhi: monthZhi,
      isDayBirth: isDayBirth,
      moonPhase: moonPhase,
      shenShaMapper: panelModel.shenShaItemMapper,
      jiaZiShenSha: jiaZiShenSha,
      yearJiaZi: yearJiaZi,
      currentXianGong: currentXianGong,
      currentXianConstellation: currentXianConstellation,
      xianPalaceStars: xianPalaceStars,
      starGongStatusMapper: starGongStatusMapper,
    );
  }

  /// 便捷方法：从 BasePanelModel 和 MoonInfo 构建 GeJuInput（简化版，用于命盘格局）
  static GeJuInput buildFromPanel({
    required BasePanelModel panelModel,
    required Set<ElevenStarsInfo> starsSet,
    required DiZhi monthZhi,
    required JiaZi yearJiaZi,
    CelestialCoordinateSystem coordinateSystem = CelestialCoordinateSystem.ecliptic,
    Set<String> preferredSchools = const {'guo_lao'},
  }) {
    debugPrint('GeJu: starGongStatusMapper not provided — '
        'starGongStatus conditions will evaluate to false');
    return build(
      panelModel: panelModel,
      starsSet: starsSet,
      monthZhi: monthZhi,
      yearJiaZi: yearJiaZi,
      coordinateSystem: coordinateSystem,
      preferredSchools: preferredSchools,
    );
  }

  /// 便捷方法：为行限格局构建 GeJuInput
  static GeJuInput buildForXingXian({
    required BasePanelModel panelModel,
    required Set<ElevenStarsInfo> starsSet,
    required DiZhi monthZhi,
    required JiaZi yearJiaZi,
    required EnumTwelveGong xianGong,
    required Enum28Constellations xianConstellation,
    CelestialCoordinateSystem coordinateSystem = CelestialCoordinateSystem.ecliptic,
    Set<String> preferredSchools = const {'guo_lao'},
  }) {
    // 计算行限宫内的星曜
    final xianPalaceStars = starsSet
        .where((star) => star.enteredGong == xianGong)
        .map((star) => star.star)
        .toList();

    return build(
      panelModel: panelModel,
      starsSet: starsSet,
      monthZhi: monthZhi,
      yearJiaZi: yearJiaZi,
      coordinateSystem: coordinateSystem,
      preferredSchools: preferredSchools,
      currentXianGong: xianGong,
      currentXianConstellation: xianConstellation,
      xianPalaceStars: xianPalaceStars,
    );
  }

  /// 反转十二宫映射
  /// 输入: Map<EnumTwelveGong, EnumDestinyTwelveGong> (宫位 -> 功能)
  /// 输出: Map<EnumDestinyTwelveGong, EnumTwelveGong> (功能 -> 宫位)
  static Map<EnumDestinyTwelveGong, EnumTwelveGong> _invertTwelveGongMapper(
    Map<EnumTwelveGong, EnumDestinyTwelveGong> original,
  ) {
    final inverted = <EnumDestinyTwelveGong, EnumTwelveGong>{};
    original.forEach((gong, destiny) {
      inverted[destiny] = gong;
    });
    return inverted;
  }

  /// 判断是否昼生
  /// 昼生判断：太阳在地平线以上（通常为命宫到迁移宫的上半部分，或简化为太阳在特定宫位）
  /// 简化规则：太阳在巳午未申宫为昼生
  static bool _calculateIsDayBirth(Set<ElevenStarsInfo> starsSet) {
    final sunInfo = starsSet.firstWhere(
      (s) => s.star == EnumStars.Sun,
      orElse: () => throw StateError('Sun not found in starsSet'),
    );

    // 昼宫：巳、午、未、申（简化判断）
    final dayGongs = [
      EnumTwelveGong.Si,
      EnumTwelveGong.Wu,
      EnumTwelveGong.Wei,
      EnumTwelveGong.Shen,
    ];
    return dayGongs.contains(sunInfo.enteredGong);
  }

  /// 获取月相
  /// MoonInfo.moonPhase 已由 buildElevenStarsSetFromPanel() 计算真实月相。
  /// 此方法仅提取值，非 MoonInfo 类型时 fallback 为 New。
  static EnumMoonPhases _getMoonPhase(Set<ElevenStarsInfo> starsSet) {
    final moonInfo = starsSet.firstWhere(
      (s) => s.star == EnumStars.Moon,
      orElse: () => throw StateError('Moon not found in starsSet'),
    );

    // MoonInfo 包含 moonPhase 属性
    if (moonInfo is MoonInfo) {
      return moonInfo.moonPhase;
    }

    // 如果不是 MoonInfo 类型，返回默认值
    return EnumMoonPhases.New;
  }

  /// 构建甲子类神煞实例
  /// 注：JiaZiShenSha 是一个包含静态方法的类，这里返回一个占位实例
  static JiaZiShenSha _buildJiaZiShenSha() {
    // JiaZiShenSha 的静态方法如 getKongWangAtDiZhi() 可直接使用
    // 这里创建一个占位实例以满足 GeJuInput 构造函数要求
    // JiaZiShenSha 使用位置参数: (name, jiXiong, descriptionList, locationDescriptionList, locationMapper)
    return JiaZiShenSha(
      '甲子神煞',
      JiXiongEnum.PING,
      [],
      [],
      {},
    );
  }

  /// 构建星曜庙旺状态映射
  /// 根据星曜当前所在宫位，查找其状态
  static Map<EnumStars, List<EnumStarGongPositionStatusType>> _buildStarGongStatusMapper(
    Set<ElevenStarsInfo> starsSet,
    List<StarPositionStatusDatasetModel<EnumTwelveGong>> statusDataList,
  ) {
    final result = <EnumStars, List<EnumStarGongPositionStatusType>>{};

    for (var starInfo in starsSet) {
      final star = starInfo.star;
      final gong = starInfo.enteredGong;
      final statuses = <EnumStarGongPositionStatusType>[];

      // 查找该星在该宫位的所有状态
      for (var data in statusDataList) {
        if (data.star == star && data.positionList.contains(gong)) {
          statuses.add(data.starPositionStatusType);
        }
      }

      if (statuses.isNotEmpty) {
        result[star] = statuses;
      }
    }

    return result;
  }

  /// 从 starsSet 构建 gong -> stars 映射
  static Map<EnumTwelveGong, List<EnumStars>> buildGongStarsMapper(
    Set<ElevenStarsInfo> starsSet,
  ) {
    final mapper = <EnumTwelveGong, List<EnumStars>>{};

    for (var starInfo in starsSet) {
      final gong = starInfo.enteredGong;
      mapper.putIfAbsent(gong, () => []).add(starInfo.star);
    }

    return mapper;
  }

  /// 辅助方法：获取指定宫位内的所有星曜
  static List<EnumStars> getStarsInGong(
    Set<ElevenStarsInfo> starsSet,
    EnumTwelveGong gong,
  ) {
    return starsSet
        .where((s) => s.enteredGong == gong)
        .map((s) => s.star)
        .toList();
  }

  /// 从 [BasePanelModel] 组装 [ElevenStarsInfo] 集合
  ///
  /// 用于在只有 [BasePanelModel] 的场景下调用 [GeJuEvaluationService]。
  /// [birthDateTime] 出生日期时间，优先使用 tyme 农历方案计算月相；
  /// 若未提供，则 fallback 到 Sweph 天文方案（从日月黄经差计算）。
  static Set<ElevenStarsInfo> buildElevenStarsSetFromPanel(
      BasePanelModel panel, {DateTime? birthDateTime}) {
    final result = <ElevenStarsInfo>{};

    for (final entry in panel.starAngleMapper.entries) {
      final star = entry.key;
      final angle = entry.value.angle;
      final speed = entry.value.speed;
      final enterInfo = panel.enteredGongMapper[star];
      if (enterInfo == null) continue;

      final ElevenStarsInfo info;
      if (star == EnumStars.Sun) {
        info = SunInfo(angle: angle, enterInfo: enterInfo);
      } else if (star == EnumStars.Moon) {
        final EnumMoonPhases moonPhase;
        if (birthDateTime != null) {
          // 优先: tyme 农历方案
          moonPhase = EnumMoonPhases.fromDateTime(birthDateTime);
        } else {
          // 备选: Sweph 天文方案（从日月黄经差计算）
          final sunAngle = panel.starAngleMapper[EnumStars.Sun]?.angle;
          moonPhase = sunAngle != null
              ? EnumMoonPhases.fromSunMoonAngle(angle, sunAngle)
              : EnumMoonPhases.New;
        }
        info = MoonInfo(
          angle: angle,
          enterInfo: enterInfo,
          moonPhase: moonPhase,
        );
      } else {
        final walkingType =
            panel.fiveStarWalkingTypeMapper[star]?.walkingType ??
                FiveStarWalkingType.Normal;
        info = ElevenStarsInfo(
          star: star,
          angle: angle,
          enterInfo: enterInfo,
          fiveStarWalkingType: walkingType,
          walkingSpeed: speed,
          priority: star.isFiveStar
              ? EnumStarsPriority.Normal
              : EnumStarsPriority.Lowest,
        );
      }
      result.add(info);
    }

    return result;
  }
}
