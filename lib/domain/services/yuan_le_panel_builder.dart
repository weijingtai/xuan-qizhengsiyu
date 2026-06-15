import 'dart:convert';

import 'package:metaphysics_core/enums.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import 'package:qizhengsiyu/dataset/star_position_status_model.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/passage_year_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/star_enter_info.dart';
import 'package:qizhengsiyu/domain/entities/models/yuan_le_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/body_life_model.dart';
import 'package:qizhengsiyu/domain/entities/models/stars_angle.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/enums/enum_star_position_status.dart';

import '../../enums/enum_twelve_gong.dart';

class YuanLePanelBuilder {
  final QiZhengStarPositionStatusRepository _positionStatusRepo;
  List<StarPositionStatusDatasetModel<EnumTwelveGong>>? _cachedStatusData;

  YuanLePanelBuilder({required QiZhengStarPositionStatusRepository positionStatusRepo})
      : _positionStatusRepo = positionStatusRepo;

  Future<List<StarPositionStatusDatasetModel<EnumTwelveGong>>> _loadStarPositionStatusData() async {
    if (_cachedStatusData != null) return _cachedStatusData!;

    try {
      final contracts = await _positionStatusRepo.loadStarPositionStatus();

      final statusDataList = <StarPositionStatusDatasetModel<EnumTwelveGong>>[];
      for (final contract in contracts) {
        try {
          final model = StarPositionStatusDatasetModel<EnumTwelveGong>.fromJson(contract.raw);
          statusDataList.add(model);
        } catch (e) {
          // 跳过非宫位记录
        }
      }

      _cachedStatusData = statusDataList;
      return statusDataList;
    } catch (e) {
      // debugPrint 已移除，静默忽略
      return [];
    }
  }

  /// 从本命盘和流年盘构建垣乐面板
  Future<YuanLePanel> build(
    BasePanelModel natalPanel, {
    PassageYearPanelModel? transitPanel,
    ZhouTianModel? zhouTianModel,
  }) async {
    final statusDataList = await _loadStarPositionStatusData();

    final natalStars =
        _buildStarListFromBasePanel(natalPanel, statusDataList, zhouTianModel);
    final transitStars = transitPanel != null
        ? _buildStarListFromTransitPanel(transitPanel, statusDataList)
        : null;

    return YuanLePanel(
      natalStars: natalStars,
      transitStars: transitStars,
    );
  }

  /// 从 BasePanelModel 构建星体列表
  List<YuanLeStarInfo> _buildStarListFromBasePanel(
    BasePanelModel panelModel,
    List<StarPositionStatusDatasetModel<EnumTwelveGong>> statusDataList,
    ZhouTianModel? zhouTianModel,
  ) {
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

    // 添加普通五星（日、月、金、木、水、火、土、罗、计、炁、孛）
    final fiveStars = [
      EnumStars.Sun,
      EnumStars.Moon,
      EnumStars.Mercury,
      EnumStars.Venus,
      EnumStars.Mars,
      EnumStars.Jupiter,
      EnumStars.Saturn,
      EnumStars.Luo,      // 罗
      EnumStars.Ji,       // 计
      EnumStars.Qi,       // 炁
      EnumStars.Bei,      // 孛
    ];

    for (final star in fiveStars) {
      final enteredInfo = panelModel.enteredGongMapper[star];
      final fiveStarWalkingInfo = panelModel.fiveStarWalkingTypeMapper[star];

      if (enteredInfo != null) {
        // 获取星宿总度数 (从 ViewModel 获取或默认为 30.0)
        double constellationTotalDegree = 30.0;
        final zhouTian = zhouTianModel;
        if (zhouTian != null) {
          final constellationDegree = zhouTian.starInnDegreeSeq.firstWhere(
            (e) => e.constellation == enteredInfo.inn,
            orElse: () => ConstellationDegree(
                constellation: enteredInfo.inn, 
                degree: 30.0,
            ),
          );
          constellationTotalDegree = constellationDegree.degree;
        }

        starList.add(
          _buildStarInfo(
            star: star,
            enteredInfo: enteredInfo,
            fiveStarWalkingInfo: fiveStarWalkingInfo,
            gongPositionStatus: _queryPositionStatus<EnumTwelveGong>(
              star,
              enteredInfo.gong,
              statusDataList,
            ),
            innPositionStatus: _queryPositionStatus<Enum28Constellations>(
              star,
              enteredInfo.inn,
              statusDataList,
            ),
            constellationTotalDegree: constellationTotalDegree,
          ),
        );
      }
    }

    print(
        '[YuanLePanelBuilder] Built ${starList.length} stars from BasePanelModel');
    return starList;
  }

  /// 从 PassageYearPanelModel 构建星体列表
  List<YuanLeStarInfo> _buildStarListFromTransitPanel(
    PassageYearPanelModel panelModel,
    List<StarPositionStatusDatasetModel<EnumTwelveGong>> statusDataList,
  ) {
    final starList = <YuanLeStarInfo>[];

    // 流年盘没有身命信息，所以跳过命主和身主

    // 添加普通五星（日、月、金、木、水、火、土、罗、计、炁、孛）
    final fiveStars = [
      EnumStars.Sun,
      EnumStars.Moon,
      EnumStars.Mercury,
      EnumStars.Venus,
      EnumStars.Mars,
      EnumStars.Jupiter,
      EnumStars.Saturn,
      EnumStars.Luo,      // 罗
      EnumStars.Ji,       // 计
      EnumStars.Qi,       // 炁
      EnumStars.Bei,      // 孛
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
            gongPositionStatus: _queryPositionStatus<EnumTwelveGong>(
              star,
              enteredInfo.gong,
              statusDataList,
            ),
            innPositionStatus: _queryPositionStatus<Enum28Constellations>(
              star,
              enteredInfo.inn,
              statusDataList,
            ),
            constellationTotalDegree: 30.0,
          ),
        );
      }
    }

    return starList;
  }

  /// 构建命主/身主信息
  YuanLeStarInfo _buildBodyLifeMasterInfo(
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
      gongPositionStatus: null,
      innPositionStatus: null,
      walkingStatus: null,
      constellationTotalDegree: 30.0, // 命身宿总度数通常固定或需从 ZhouTianModel 获取
    );
  }

  /// 构建普通星体信息
  YuanLeStarInfo _buildStarInfo({
    required EnumStars star,
    required EnteredInfo enteredInfo,
    required BaseFiveStarWalkingInfo? fiveStarWalkingInfo,
    required EnumStarGongPositionStatusType? gongPositionStatus,
    required EnumStarGongPositionStatusType? innPositionStatus,
    required double constellationTotalDegree,
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
      gongPositionStatus: gongPositionStatus,
      innPositionStatus: innPositionStatus,
      walkingStatus: _formatWalkingStatus(fiveStarWalkingInfo),
      isBodyLifeMaster: false,
      label: '',
      constellationTotalDegree: constellationTotalDegree,
    );
  }

  /// 从数据库查询星体在宫位或星宿的垣位状态
  /// 返回第一个匹配的状态（按优先级）
  EnumStarGongPositionStatusType? _queryPositionStatus<T extends Enum>(
    EnumStars star,
    T position,
    List<StarPositionStatusDatasetModel<EnumTwelveGong>> statusDataList,
  ) {
    final statuses = <EnumStarGongPositionStatusType>[];

    // 查找该星在该位置的所有状态
    for (var data in statusDataList) {
      // 检查 data.positionList 是否包含 position
      // 注意：data.positionList 的泛型可能与 T 不匹配，但运行时内容应该是对应的 Enum
      if (data.star == star) {
        bool match = false;
        for (var p in data.positionList) {
          if (p == position) {
            match = true;
            break;
          }
        }
        if (match) {
          statuses.add(data.starPositionStatusType);
        }
      }
    }

    if (statuses.isEmpty) return null;

    // 优先级排序：庙 > 旺 > 喜 > 乐 > 正 > 垣 > 殿 > 贵 > 偏 > 怒 > 凶
    const priorityOrder = [
      EnumStarGongPositionStatusType.Miao,    // 庙
      EnumStarGongPositionStatusType.Wang,    // 旺
      EnumStarGongPositionStatusType.Xi,      // 喜
      EnumStarGongPositionStatusType.Le,      // 乐
      EnumStarGongPositionStatusType.Zheng,   // 正
      EnumStarGongPositionStatusType.Yuan,    // 垣
      EnumStarGongPositionStatusType.Dian,    // 殿
      EnumStarGongPositionStatusType.Gui,     // 贵
      EnumStarGongPositionStatusType.Pian,    // 偏
      EnumStarGongPositionStatusType.Nu,      // 怒
      EnumStarGongPositionStatusType.Xiong,   // 凶
    ];

    for (final priority in priorityOrder) {
      if (statuses.contains(priority)) {
        return priority;
      }
    }

    return statuses.first;
  }

  /// 格式化星体运行状态（迟/留/伏/逆）
  String? _formatWalkingStatus(BaseFiveStarWalkingInfo? walkingInfo) {
    if (walkingInfo == null) return null;

    final walkingType = walkingInfo.walkingType;
    return walkingType.name; // 返回 FiveStarWalkingType 的名称（迟/留/伏/逆等）
  }
}

