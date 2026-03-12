import 'dart:convert';

import 'package:common/enums.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:qizhengsiyu/dataset/star_position_status_model.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/passage_year_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/star_enter_info.dart';
import 'package:qizhengsiyu/domain/entities/models/yuan_le_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/body_life_model.dart';
import 'package:qizhengsiyu/domain/entities/models/stars_angle.dart';
import 'package:qizhengsiyu/enums/enum_star_position_status.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

/// 构建垣乐面板的 Builder 服务
class YuanLePanelBuilder {
  // 缓存星体位置状态数据
  static List<StarPositionStatusDatasetModel<EnumTwelveGong>>? _cachedStatusData;

  /// 从 assets 加载星体位置状态数据（带缓存）
  static Future<List<StarPositionStatusDatasetModel<EnumTwelveGong>>>
      _loadStarPositionStatusData() async {
    if (_cachedStatusData != null) {
      return _cachedStatusData!;
    }

    try {
      final jsonString = await rootBundle
          .loadString('assets/qizhengsiyu/star_position_status.json');
      final jsonList = jsonDecode(jsonString) as List<dynamic>;

      print('[YuanLePanelBuilder] Loaded ${jsonList.length} position status records');

      final parsed = <StarPositionStatusDatasetModel<EnumTwelveGong>>[];
      for (final item in jsonList) {
        try {
          final record = StarPositionStatusDatasetModel<EnumTwelveGong>.fromJson(
              item as Map<String, dynamic>);
          parsed.add(record);
        } catch (e) {
          // Skip records that fail to parse (e.g., those with 28-constellation positions)
          print('[YuanLePanelBuilder] Skipped record (likely constellation-based): ${item['star']} in ${item['positionList']}');
        }
      }

      _cachedStatusData = parsed;

      print('[YuanLePanelBuilder] Successfully parsed ${_cachedStatusData!.length} records');
      // 打印前几条记录用于调试
      for (var i = 0; i < (_cachedStatusData!.length < 3 ? _cachedStatusData!.length : 3); i++) {
        final record = _cachedStatusData![i];
        print('[YuanLePanelBuilder] Record $i: star=${record.star}, status=${record.starPositionStatusType}, positions=${record.positionList}');
      }

      return _cachedStatusData!;
    } catch (e) {
      print('[YuanLePanelBuilder] Error loading star position status data: $e');
      return [];
    }
  }

  /// 从本命盘和流年盘构建垣乐面板
  static Future<YuanLePanel> build(
    BasePanelModel natalPanel, {
    PassageYearPanelModel? transitPanel,
  }) async {
    print('[YuanLePanelBuilder] Starting to load position status data...');
    // 加载星体位置状态数据
    final statusDataList = await _loadStarPositionStatusData();
    print('[YuanLePanelBuilder] Loaded statusDataList with ${statusDataList.length} records');

    final natalStars = _buildStarListFromBasePanel(natalPanel,
        statusDataList: statusDataList);
    final transitStars = transitPanel != null
        ? _buildStarListFromTransitPanel(transitPanel, statusDataList: statusDataList)
        : null;

    return YuanLePanel(
      natalStars: natalStars,
      transitStars: transitStars,
    );
  }

  /// 从 BasePanelModel 构建星体列表
  static List<YuanLeStarInfo> _buildStarListFromBasePanel(
      BasePanelModel panelModel,
      {List<StarPositionStatusDatasetModel<EnumTwelveGong>>? statusDataList}) {
    final starList = <YuanLeStarInfo>[];

    // 添加命主和身主（特殊处理）
    final lifeInfo = panelModel.bodyLifeModel;
    starList.add(
      _buildBodyLifeMasterInfo(
        lifeInfo,
        isLife: true,
      ),
    );

    // 添加身主
    starList.add(
      _buildBodyLifeMasterInfo(
        lifeInfo,
        isLife: false,
      ),
    );

    // 添加普通五星（日、月、金、木、水、火、土）以及罗、计、炁、孛
    final fiveStars = [
      EnumStars.Sun,
      EnumStars.Moon,
      EnumStars.Mercury,
      EnumStars.Venus,
      EnumStars.Mars,
      EnumStars.Jupiter,
      EnumStars.Saturn,
      EnumStars.Luo,        // 罗
      EnumStars.Ji,         // 计
      EnumStars.Qi,         // 炁
      EnumStars.Bei,        // 孛
    ];

    for (final star in fiveStars) {
      final enteredInfo = panelModel.enteredGongMapper[star];
      final fiveStarWalkingInfo = panelModel.fiveStarWalkingTypeMapper[star];

      if (enteredInfo != null) {
        starList.add(
          _buildStarInfo(
            star: star,
            enteredInfo: enteredInfo,
            fiveStarWalkingInfo: fiveStarWalkingInfo,
            positionStatusType: _getPositionStatus(star, enteredInfo.gong,
                statusDataList: statusDataList),
          ),
        );
      }
    }

    print(
        '[YuanLePanelBuilder] Built ${starList.length} stars from BasePanelModel');
    return starList;
  }

  /// 从 PassageYearPanelModel 构建星体列表
  static List<YuanLeStarInfo> _buildStarListFromTransitPanel(
      PassageYearPanelModel panelModel,
      {List<StarPositionStatusDatasetModel<EnumTwelveGong>>? statusDataList}) {
    final starList = <YuanLeStarInfo>[];

    // 流年盘没有身命信息，所以跳过命主和身主

    // 添加普通五星（日、月、金、木、水、火、土）以及罗、计、炁、孛
    final fiveStars = [
      EnumStars.Sun,
      EnumStars.Moon,
      EnumStars.Mercury,
      EnumStars.Venus,
      EnumStars.Mars,
      EnumStars.Jupiter,
      EnumStars.Saturn,
      EnumStars.Luo,        // 罗
      EnumStars.Ji,         // 计
      EnumStars.Qi,         // 炁
      EnumStars.Bei,        // 孛
    ];

    for (final star in fiveStars) {
      final enteredInfo = panelModel.enteredGongMapper[star];
      final fiveStarWalkingInfo = panelModel.fiveStarWalkingTypeMapper[star];

      if (enteredInfo != null) {
        starList.add(
          _buildStarInfo(
            star: star,
            enteredInfo: enteredInfo,
            fiveStarWalkingInfo: fiveStarWalkingInfo,
            positionStatusType: _getPositionStatus(star, enteredInfo.gong,
                statusDataList: statusDataList),
          ),
        );
      }
    }

    return starList;
  }

  /// 构建命主/身主信息
  static YuanLeStarInfo _buildBodyLifeMasterInfo(
    BodyLifeModel bodyLifeModel, {
    required bool isLife,
  }) {
    final info = isLife
        ? bodyLifeModel.lifeConstellationInfo
        : bodyLifeModel.bodyConstellationInfo;
    final gongInfo =
        isLife ? bodyLifeModel.lifeGongInfo : bodyLifeModel.bodyGongInfo;
    final degree = info.degree;
    final constellationName = info.constellation.name;
    final gongName = gongInfo.gong.name;

    return YuanLeStarInfo(
      star: isLife ? EnumStars.Sun : EnumStars.Moon,
      constellationName: constellationName,
      degree: degree,
      gongDegree: gongInfo.degree,
      gongName: gongName,
      minutes: ((degree - degree.toInt()) * 60).toInt(),
      isBodyLifeMaster: true,
      label: isLife ? '命主' : '身主',
      positionStatus: null,
      walkingStatus: null,
    );
  }

  /// 构建普通星体信息
  static YuanLeStarInfo _buildStarInfo({
    required EnumStars star,
    required EnteredInfo enteredInfo,
    required BaseFiveStarWalkingInfo? fiveStarWalkingInfo,
    required EnumStarGongPositionStatusType? positionStatusType,
  }) {
    final innDegree = enteredInfo.atInnDegree;
    final gongDegree = enteredInfo.atGongDegree;
    final constellationName = enteredInfo.inn.name;
    final gongName = enteredInfo.gong.name; // 宫位中文名

    return YuanLeStarInfo(
      star: star,
      constellationName: constellationName,
      degree: innDegree,
      minutes: ((innDegree - innDegree.toInt()) * 60).toInt(),
      gongDegree: gongDegree,
      gongName: gongName,
      positionStatus: positionStatusType,
      walkingStatus: _formatWalkingStatus(fiveStarWalkingInfo),
      isBodyLifeMaster: false,
      label: '',
    );
  }

  /// 获取星体在宫位的垣位状态（庙旺喜乐落陷等）
  /// 基于 StarPositionStatusDatasetModel 的数据查询
  static EnumStarGongPositionStatusType? _getPositionStatus(
    EnumStars star,
    EnumTwelveGong gong, {
    List<StarPositionStatusDatasetModel<EnumTwelveGong>>? statusDataList,
  }) {
    if (statusDataList == null || statusDataList.isEmpty) {
      print('[YuanLePanelBuilder] No status data available for $star in $gong');
      return null;
    }

    // 查找该星在该宫位的第一个匹配状态
    // 优先级：如果一个宫位有多个状态，返回第一个找到的
    for (var data in statusDataList) {
      if (data.star == star && data.positionList.contains(gong)) {
        print('[YuanLePanelBuilder] Found status for $star in $gong: ${data.starPositionStatusType}');
        return data.starPositionStatusType;
      }
    }

    print('[YuanLePanelBuilder] No match found for $star in $gong');
    return null;
  }

  /// 格式化星体运行状态（迟/留/伏/逆）
  static String? _formatWalkingStatus(BaseFiveStarWalkingInfo? walkingInfo) {
    if (walkingInfo == null) return null;

    final walkingType = walkingInfo.walkingType;
    return walkingType.name; // 返回 FiveStarWalkingType 的名称（迟/留/伏/逆等）
  }
}
