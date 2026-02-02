import 'package:common/enums/enum_28_constellations.dart';

import 'package:common/enums/enum_four_seasons.dart';
import 'package:qizhengsiyu/enums/enum_moon_phases.dart';
import 'package:common/enums.dart';
import 'package:common/models/shen_sha.dart';
import 'package:qizhengsiyu/domain/entities/models/body_life_model.dart';
import 'package:qizhengsiyu/domain/entities/models/di_zhi_shen_sha.dart';
import 'package:qizhengsiyu/domain/entities/models/eleven_stars_info.dart';
import 'package:qizhengsiyu/domain/entities/models/hua_yao.dart';
import 'package:qizhengsiyu/domain/entities/models/stars_angle.dart';

import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_stars_four_type.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_star_position_status.dart';

import '../star_to_star_relationship_model.dart';

/// 格局判断的统一输入模型
/// 旨在解耦计算引擎与底层数据结构，提供统一的查询接口
class GeJuInput {
  // ========== 基础配置 ==========
  /// 天文坐标体系（黄道/赤道/天赤道等），某些格局可能依赖特定的坐标系
  final CelestialCoordinateSystem coordinateSystem;

  // ========== 星曜信息 ==========
  /// 11颗星体的完整信息（度数、宫位、状态等）
  final Set<ElevenStarsInfo> starsSet;

  /// 星曜间的关系（同宫、对宫、三合、四正、同宿等）
  final StarToStarRelationshipModel starRelationship;

  /// 五星运行状态（顺逆留迟速）
  final Map<EnumStars, BaseFiveStarWalkingInfo>? fiveStarWalkingTypeMapper;

  // ========== 命盘结构 ==========
  /// 身命四主模型
  final BodyLifeModel bodyLifeModel;

  /// 命理十二宫（命宫、财帛、兄弟...）对应的地支宫位
  final Map<EnumDestinyTwelveGong, EnumTwelveGong> destinyGongMapper;

  // ========== 用神体系 ==========
  /// 星曜的恩难仇用关系
  final Map<EnumStars, Map<EnumStarsFourType, Set<EnumStars>>>
      starsFourTypeMapper;

  /// 星曜的化曜信息（禄暗福耗...）
  final Map<EnumStars, List<HuaYaoItem>> huaYaoMapper;

  // ========== 时间条件 ==========
  /// 出生季节
  final FourSeasons season;

  /// 出生月支
  final DiZhi monthZhi;

  /// 是否昼生（true=昼, false=夜）
  final bool isDayBirth;

  /// 月相
  final EnumMoonPhases moonPhase;

  // ========== 神煞 ==========
  /// 各宫位的神煞列表
  final Map<EnumTwelveGong, List<ShenSha>> shenShaMapper;

  /// 甲子类神煞（空亡、孤虚等）
  final JiaZiShenSha jiaZiShenSha;

  /// 年干支
  final JiaZi yearJiaZi;

  // ========== 行限（可选，用于行限格局判断） ==========
  /// 当前行限所在宫位
  final EnumTwelveGong? currentXianGong;

  /// 当前行限所在星宿
  final Enum28Constellations? currentXianConstellation;

  /// 行限宫内的星曜
  final List<EnumStars>? xianPalaceStars;

  // ========== 星曜状态（可选） ==========
  /// 星曜的庙旺陷等状态映射
  /// key: 星曜, value: 该星曜在当前宫位的状态列表
  final Map<EnumStars, List<EnumStarGongPositionStatusType>>? starGongStatusMapper;

  GeJuInput({
    required this.coordinateSystem,
    required this.starsSet,
    required this.starRelationship,
    this.fiveStarWalkingTypeMapper,
    required this.bodyLifeModel,
    required this.destinyGongMapper,
    required this.starsFourTypeMapper,
    required this.huaYaoMapper,
    required this.season,
    required this.monthZhi,
    required this.isDayBirth,
    required this.moonPhase,
    required this.shenShaMapper,
    required this.jiaZiShenSha,
    required this.yearJiaZi,
    this.currentXianGong,
    this.currentXianConstellation,
    this.xianPalaceStars,
    this.starGongStatusMapper,
  });

  // ========== 便捷查询方法 ==========

  /// 获取指定星曜的完整信息
  ElevenStarsInfo? getStar(EnumStars star) {
    for (var info in starsSet) {
      if (info.star == star) return info;
    }
    return null;
  }

  /// 获取星曜所在宫位
  EnumTwelveGong? getStarGong(EnumStars star) {
    return getStar(star)?.enteredGong;
  }

  double? getStarInnDegree(EnumStars star) {
    // Assuming 'enteredStarInnDegree' is meant to be 'innDegree.degree'
    // and 'fiveStars'/'fourSlaveStars' are not directly available here,
    // relying on the existing 'getStar' method.
    return getStar(star)?.enteredStarInnDegree;
  }

  /// 获取星曜所在星宿
  Enum28Constellations? getStarConstellation(EnumStars star) {
    return getStar(star)?.enteredStarInn;
  }

  /// 获取星曜的运行状态（顺逆留迟速）
  FiveStarWalkingType? getStarWalkingType(EnumStars star) {
    if (fiveStarWalkingTypeMapper == null) return null;
    return fiveStarWalkingTypeMapper![star]?.walkingType;
  }

  /// 命宫
  EnumTwelveGong get lifeGong => bodyLifeModel.lifeGong;

  /// 命度
  Enum28Constellations get lifeConstellation => bodyLifeModel.lifeConstellation;

  /// 命宫主
  EnumStars get lifeGongMaster => lifeGong.sevenZheng;

  /// 命度主
  EnumStars get lifeConstellationMaster => lifeConstellation.sevenZheng;

  /// 身宫主
  EnumStars get bodyGongMaster => bodyLifeModel.bodyGong.sevenZheng;

  /// 身度主
  EnumStars get bodyConstellationMaster =>
      bodyLifeModel.bodyConstellation.sevenZheng;

  /// 判断两星是否同宫
  bool isSameGong(EnumStars star1, EnumStars star2) {
    final gong1 = getStarGong(star1);
    final gong2 = getStarGong(star2);
    return gong1 != null && gong2 != null && gong1 == gong2;
  }

  /// 判断两星是否对照（对宫）
  bool isOpposite(EnumStars star1, EnumStars star2) {
    final gong1 = getStarGong(star1);
    final gong2 = getStarGong(star2);
    return gong1 != null && gong2 != null && gong1.opposite == gong2;
  }

  /// 判断星曜是否落入空亡宫
  bool isStarInKongWang(EnumStars star) {
    EnumTwelveGong? gong = getStarGong(star);
    if (gong == null) return false;
    // JiaZiShenSha.getKongWangAtDiZhi returns Set<DiZhi>?
    Set<DiZhi>? kongWang = JiaZiShenSha.getKongWangAtDiZhi(yearJiaZi);
    return kongWang?.contains(gong.zhi) ?? false;
  }

  /// 获取星曜在当前宫位的状态列表
  List<EnumStarGongPositionStatusType> getStarGongStatus(EnumStars star) {
    if (starGongStatusMapper == null) return [];
    return starGongStatusMapper![star] ?? [];
  }

  /// 判断星曜是否处于指定状态
  bool hasStarGongStatus(EnumStars star, EnumStarGongPositionStatusType status) {
    return getStarGongStatus(star).contains(status);
  }

  /// 判断星曜是否处于任一指定状态
  bool hasAnyStarGongStatus(EnumStars star, List<EnumStarGongPositionStatusType> statuses) {
    final currentStatuses = getStarGongStatus(star);
    for (var status in statuses) {
      if (currentStatuses.contains(status)) return true;
    }
    return false;
  }
}
