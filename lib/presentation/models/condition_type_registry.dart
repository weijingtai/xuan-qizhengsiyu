import 'package:common/enums.dart';
import 'package:qizhengsiyu/enums/enum_hua_yao.dart';
import 'package:qizhengsiyu/enums/enum_moon_phases.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:qizhengsiyu/enums/enum_star_position_status.dart';
import 'package:qizhengsiyu/enums/enum_stars_four_type.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

/// 条件参数类型
enum ConditionParamType {
  star, // 单个星曜
  starList, // 多星曜列表
  gong, // 单个宫位
  gongList, // 多宫位列表
  constellation, // 单个星宿
  constellationList, // 多星宿列表
  walkingStateList, // 运行状态列表
  fourTypeList, // 恩难仇用列表
  huaYaoList, // 化曜列表
  shenShaList, // 神煞名称列表
  seasonList, // 季节列表
  moonPhaseList, // 月相列表
  gongStatusList, // 庙旺状态列表
  roleList, // 四主角色列表
  destinyGong, // 命盘十二宫功能
  gongIdentifier, // 宫位标识（支持 "lifeGong" / "bodyGong" 或宫位名）
  boolean, // 布尔值
  string, // 字符串
}

/// 条件参数定义
class ConditionParamDefinition {
  final String name;
  final String displayName;
  final ConditionParamType paramType;
  final bool required;
  final dynamic defaultValue;

  const ConditionParamDefinition({
    required this.name,
    required this.displayName,
    required this.paramType,
    this.required = true,
    this.defaultValue,
  });
}

/// 条件类型定义
class ConditionTypeDefinition {
  final String type;
  final String displayName;
  final String category;
  final List<ConditionParamDefinition> params;
  final String? description;

  const ConditionTypeDefinition({
    required this.type,
    required this.displayName,
    required this.category,
    required this.params,
    this.description,
  });
}

/// 条件类型注册表
/// 包含所有支持的条件类型定义，用于条件编辑器 UI
class ConditionTypeRegistry {
  ConditionTypeRegistry._();

  /// 所有条件类型分类
  static const List<String> categories = [
    '星曜位置',
    '星曜关系',
    '命盘结构',
    '用神体系',
    '时间条件',
    '宫位状态',
    '神煞条件',
    '行限条件',
  ];

  /// 星曜位置类条件 (4种)
  static const List<ConditionTypeDefinition> _positionConditions = [
    ConditionTypeDefinition(
      type: 'starInGong',
      displayName: '星在宫',
      category: '星曜位置',
      params: [
        ConditionParamDefinition(
          name: 'star',
          displayName: '星曜',
          paramType: ConditionParamType.star,
        ),
        ConditionParamDefinition(
          name: 'gongs',
          displayName: '宫位',
          paramType: ConditionParamType.gongList,
        ),
      ],
      description: '判断指定星曜是否在指定宫位列表中',
    ),
    ConditionTypeDefinition(
      type: 'starInConstellation',
      displayName: '星躔宿',
      category: '星曜位置',
      params: [
        ConditionParamDefinition(
          name: 'star',
          displayName: '星曜',
          paramType: ConditionParamType.star,
        ),
        ConditionParamDefinition(
          name: 'constellations',
          displayName: '星宿',
          paramType: ConditionParamType.constellationList,
        ),
      ],
      description: '判断指定星曜是否躔于指定星宿列表中',
    ),
    ConditionTypeDefinition(
      type: 'starWalkingState',
      displayName: '星行状态',
      category: '星曜位置',
      params: [
        ConditionParamDefinition(
          name: 'star',
          displayName: '星曜',
          paramType: ConditionParamType.star,
        ),
        ConditionParamDefinition(
          name: 'states',
          displayName: '状态',
          paramType: ConditionParamType.walkingStateList,
        ),
      ],
      description: '判断星曜运行状态（顺、逆、留、迟、速）',
    ),
    ConditionTypeDefinition(
      type: 'starInKongWang',
      displayName: '星落空亡',
      category: '星曜位置',
      params: [
        ConditionParamDefinition(
          name: 'star',
          displayName: '星曜',
          paramType: ConditionParamType.star,
        ),
      ],
      description: '判断指定星曜是否落空亡',
    ),
  ];

  /// 星曜关系类条件 (7种)
  static const List<ConditionTypeDefinition> _relationshipConditions = [
    ConditionTypeDefinition(
      type: 'sameGong',
      displayName: '同宫',
      category: '星曜关系',
      params: [
        ConditionParamDefinition(
          name: 'stars',
          displayName: '星曜列表',
          paramType: ConditionParamType.starList,
        ),
      ],
      description: '判断多颗星曜是否在同一宫位',
    ),
    ConditionTypeDefinition(
      type: 'sameConstellation',
      displayName: '同宿',
      category: '星曜关系',
      params: [
        ConditionParamDefinition(
          name: 'stars',
          displayName: '星曜列表',
          paramType: ConditionParamType.starList,
        ),
      ],
      description: '判断多颗星曜是否在同一星宿',
    ),
    ConditionTypeDefinition(
      type: 'oppositeGong',
      displayName: '对照',
      category: '星曜关系',
      params: [
        ConditionParamDefinition(
          name: 'stars',
          displayName: '两颗星曜',
          paramType: ConditionParamType.starList,
        ),
      ],
      description: '判断两颗星曜是否对宫（对照）',
    ),
    ConditionTypeDefinition(
      type: 'trineGong',
      displayName: '三合',
      category: '星曜关系',
      params: [
        ConditionParamDefinition(
          name: 'stars',
          displayName: '星曜列表',
          paramType: ConditionParamType.starList,
        ),
      ],
      description: '判断多颗星曜是否在三合宫位',
    ),
    ConditionTypeDefinition(
      type: 'squareGong',
      displayName: '四正',
      category: '星曜关系',
      params: [
        ConditionParamDefinition(
          name: 'stars',
          displayName: '星曜列表',
          paramType: ConditionParamType.starList,
        ),
      ],
      description: '判断多颗星曜是否在四正宫位',
    ),
    ConditionTypeDefinition(
      type: 'sameJing',
      displayName: '同经',
      category: '星曜关系',
      params: [
        ConditionParamDefinition(
          name: 'stars',
          displayName: '星曜列表',
          paramType: ConditionParamType.starList,
        ),
      ],
      description: '判断多颗星曜是否同经',
    ),
    ConditionTypeDefinition(
      type: 'sameLuo',
      displayName: '同络',
      category: '星曜关系',
      params: [
        ConditionParamDefinition(
          name: 'stars',
          displayName: '星曜列表',
          paramType: ConditionParamType.starList,
        ),
      ],
      description: '判断多颗星曜是否同络',
    ),
  ];

  /// 命盘结构类条件 (4种)
  static const List<ConditionTypeDefinition> _structureConditions = [
    ConditionTypeDefinition(
      type: 'lifeGongAt',
      displayName: '命宫在宫',
      category: '命盘结构',
      params: [
        ConditionParamDefinition(
          name: 'gongs',
          displayName: '宫位',
          paramType: ConditionParamType.gongList,
        ),
      ],
      description: '判断命宫是否在指定宫位',
    ),
    ConditionTypeDefinition(
      type: 'lifeConstellationAt',
      displayName: '命度躔宿',
      category: '命盘结构',
      params: [
        ConditionParamDefinition(
          name: 'constellations',
          displayName: '星宿',
          paramType: ConditionParamType.constellationList,
        ),
      ],
      description: '判断命度是否躔于指定星宿',
    ),
    ConditionTypeDefinition(
      type: 'starGuardLife',
      displayName: '星临命',
      category: '命盘结构',
      params: [
        ConditionParamDefinition(
          name: 'star',
          displayName: '星曜',
          paramType: ConditionParamType.star,
        ),
      ],
      description: '判断指定星曜是否在命宫',
    ),
    ConditionTypeDefinition(
      type: 'starInDestinyGong',
      displayName: '星在功能宫',
      category: '命盘结构',
      params: [
        ConditionParamDefinition(
          name: 'star',
          displayName: '星曜',
          paramType: ConditionParamType.star,
        ),
        ConditionParamDefinition(
          name: 'destinyGong',
          displayName: '功能宫',
          paramType: ConditionParamType.destinyGong,
        ),
      ],
      description: '判断星曜是否在指定命盘功能宫（财帛、官禄等）',
    ),
  ];

  /// 用神体系类条件 (3种)
  static const List<ConditionTypeDefinition> _yongShenConditions = [
    ConditionTypeDefinition(
      type: 'starIsSiZhu',
      displayName: '星为四主',
      category: '用神体系',
      params: [
        ConditionParamDefinition(
          name: 'star',
          displayName: '星曜',
          paramType: ConditionParamType.star,
        ),
        ConditionParamDefinition(
          name: 'roles',
          displayName: '角色',
          paramType: ConditionParamType.roleList,
        ),
      ],
      description: '判断星曜是否为命主/身主/度主/身度主',
    ),
    ConditionTypeDefinition(
      type: 'starFourType',
      displayName: '恩难仇用',
      category: '用神体系',
      params: [
        ConditionParamDefinition(
          name: 'star',
          displayName: '主星',
          paramType: ConditionParamType.star,
        ),
        ConditionParamDefinition(
          name: 'target',
          displayName: '参照星',
          paramType: ConditionParamType.star,
        ),
        ConditionParamDefinition(
          name: 'types',
          displayName: '关系类型',
          paramType: ConditionParamType.fourTypeList,
        ),
      ],
      description: '判断星曜间的恩难仇用关系',
    ),
    ConditionTypeDefinition(
      type: 'starHasHuaYao',
      displayName: '星有化曜',
      category: '用神体系',
      params: [
        ConditionParamDefinition(
          name: 'star',
          displayName: '星曜',
          paramType: ConditionParamType.star,
        ),
        ConditionParamDefinition(
          name: 'huaYaos',
          displayName: '化曜',
          paramType: ConditionParamType.huaYaoList,
        ),
      ],
      description: '判断星曜是否具有指定化曜',
    ),
  ];

  /// 时间条件类 (4种)
  static const List<ConditionTypeDefinition> _timeConditions = [
    ConditionTypeDefinition(
      type: 'seasonIs',
      displayName: '季节',
      category: '时间条件',
      params: [
        ConditionParamDefinition(
          name: 'seasons',
          displayName: '季节',
          paramType: ConditionParamType.seasonList,
        ),
      ],
      description: '判断出生季节',
    ),
    ConditionTypeDefinition(
      type: 'isDayBirth',
      displayName: '昼夜生',
      category: '时间条件',
      params: [
        ConditionParamDefinition(
          name: 'isDay',
          displayName: '昼生',
          paramType: ConditionParamType.boolean,
          defaultValue: true,
        ),
      ],
      description: '判断是昼生还是夜生',
    ),
    ConditionTypeDefinition(
      type: 'moonPhaseIs',
      displayName: '月相',
      category: '时间条件',
      params: [
        ConditionParamDefinition(
          name: 'phases',
          displayName: '月相',
          paramType: ConditionParamType.moonPhaseList,
        ),
      ],
      description: '判断出生时的月相',
    ),
    ConditionTypeDefinition(
      type: 'monthIs',
      displayName: '月份',
      category: '时间条件',
      params: [
        ConditionParamDefinition(
          name: 'months',
          displayName: '月份',
          paramType: ConditionParamType.gongList, // 使用地支表示月份
        ),
      ],
      description: '判断出生月份（地支）',
    ),
  ];

  /// 宫位状态类条件 (1种)
  static const List<ConditionTypeDefinition> _gongStatusConditions = [
    ConditionTypeDefinition(
      type: 'starGongStatus',
      displayName: '星曜庙旺',
      category: '宫位状态',
      params: [
        ConditionParamDefinition(
          name: 'star',
          displayName: '星曜',
          paramType: ConditionParamType.star,
        ),
        ConditionParamDefinition(
          name: 'statuses',
          displayName: '状态',
          paramType: ConditionParamType.gongStatusList,
        ),
      ],
      description: '判断星曜的庙旺陷落状态',
    ),
  ];

  /// 神煞条件类 (2种)
  static const List<ConditionTypeDefinition> _shenShaConditions = [
    ConditionTypeDefinition(
      type: 'starWithShenSha',
      displayName: '星带神煞',
      category: '神煞条件',
      params: [
        ConditionParamDefinition(
          name: 'star',
          displayName: '星曜',
          paramType: ConditionParamType.star,
        ),
        ConditionParamDefinition(
          name: 'shenShaNames',
          displayName: '神煞',
          paramType: ConditionParamType.shenShaList,
        ),
      ],
      description: '判断星曜所在宫位是否有指定神煞',
    ),
    ConditionTypeDefinition(
      type: 'gongHasShenSha',
      displayName: '宫有神煞',
      category: '神煞条件',
      params: [
        ConditionParamDefinition(
          name: 'gongIdentifier',
          displayName: '宫位',
          paramType: ConditionParamType.gongIdentifier,
        ),
        ConditionParamDefinition(
          name: 'shenShaNames',
          displayName: '神煞',
          paramType: ConditionParamType.shenShaList,
        ),
      ],
      description: '判断指定宫位是否有指定神煞',
    ),
  ];

  /// 行限条件类 (3种)
  static const List<ConditionTypeDefinition> _xianConditions = [
    ConditionTypeDefinition(
      type: 'xianAtGong',
      displayName: '行限在宫',
      category: '行限条件',
      params: [
        ConditionParamDefinition(
          name: 'gongs',
          displayName: '宫位',
          paramType: ConditionParamType.gongList,
        ),
      ],
      description: '判断行限是否在指定宫位',
    ),
    ConditionTypeDefinition(
      type: 'xianAtConstellation',
      displayName: '行限躔宿',
      category: '行限条件',
      params: [
        ConditionParamDefinition(
          name: 'constellations',
          displayName: '星宿',
          paramType: ConditionParamType.constellationList,
        ),
      ],
      description: '判断行限是否躔于指定星宿',
    ),
    ConditionTypeDefinition(
      type: 'xianMeetStar',
      displayName: '行限遇星',
      category: '行限条件',
      params: [
        ConditionParamDefinition(
          name: 'stars',
          displayName: '星曜',
          paramType: ConditionParamType.starList,
        ),
      ],
      description: '判断行限宫内是否有指定星曜',
    ),
  ];

  /// 所有条件类型列表
  static List<ConditionTypeDefinition> get allTypes => [
        ..._positionConditions,
        ..._relationshipConditions,
        ..._structureConditions,
        ..._yongShenConditions,
        ..._timeConditions,
        ..._gongStatusConditions,
        ..._shenShaConditions,
        ..._xianConditions,
      ];

  /// 根据类型名获取条件定义
  static ConditionTypeDefinition? getByType(String type) {
    try {
      return allTypes.firstWhere((t) => t.type == type);
    } catch (_) {
      return null;
    }
  }

  /// 根据分类获取条件列表
  static List<ConditionTypeDefinition> getByCategory(String category) {
    return allTypes.where((t) => t.category == category).toList();
  }

  /// 获取所有类型名称映射 (type -> displayName)
  static Map<String, String> get typeDisplayNames {
    return {for (var t in allTypes) t.type: t.displayName};
  }

  /// 判断是否为逻辑条件类型
  static bool isLogicType(String type) {
    return ['and', 'or', 'not'].contains(type);
  }

  /// 逻辑条件类型
  static const List<String> logicTypes = ['and', 'or', 'not'];

  /// 逻辑条件显示名称
  static const Map<String, String> logicTypeDisplayNames = {
    'and': '且 (AND)',
    'or': '或 (OR)',
    'not': '非 (NOT)',
  };
}

/// 选项值定义
/// 用于提供参数输入组件的选项列表
class ConditionParamOptions {
  ConditionParamOptions._();

  /// 获取所有可选星曜（七政四余十一曜）
  static List<EnumStars> get stars => [
        EnumStars.Sun,
        EnumStars.Moon,
        EnumStars.Jupiter,
        EnumStars.Mars,
        EnumStars.Saturn,
        EnumStars.Venus,
        EnumStars.Mercury,
        EnumStars.Luo,   // 罗睺
        EnumStars.Ji,    // 计都
        EnumStars.Qi,    // 紫炁
        EnumStars.Bei,   // 月孛
      ];

  /// 获取所有十二宫位
  static List<EnumTwelveGong> get gongs => EnumTwelveGong.values;

  /// 获取所有二十八宿
  static List<Enum28Constellations> get constellations =>
      Enum28Constellations.values;

  /// 获取所有运行状态
  static List<FiveStarWalkingType> get walkingStates =>
      FiveStarWalkingType.values;

  /// 获取所有恩难仇用类型
  static List<EnumStarsFourType> get fourTypes => EnumStarsFourType.values;

  /// 获取所有化曜类型
  static List<EnumGuoLaoHuaYao> get huaYaos => EnumGuoLaoHuaYao.values;

  /// 获取所有季节
  static List<FourSeasons> get seasons => FourSeasons.values;

  /// 获取所有月相
  static List<EnumMoonPhases> get moonPhases => EnumMoonPhases.values;

  /// 获取所有庙旺状态
  static List<EnumStarGongPositionStatusType> get gongStatuses =>
      EnumStarGongPositionStatusType.values;

  /// 获取所有命盘功能宫
  static List<EnumDestinyTwelveGong> get destinyGongs =>
      EnumDestinyTwelveGong.values;

  /// 四主角色选项
  static const List<String> siZhuRoles = [
    'lifeGongMaster',
    'bodyGongMaster',
    'lifeConstellationMaster',
    'bodyConstellationMaster',
  ];

  /// 四主角色显示名称
  static const Map<String, String> siZhuRoleDisplayNames = {
    'lifeGongMaster': '命主',
    'bodyGongMaster': '身主',
    'lifeConstellationMaster': '度主',
    'bodyConstellationMaster': '身度主',
  };

  /// 特殊宫位标识
  static const List<String> specialGongIdentifiers = [
    'lifeGong',
    'bodyGong',
  ];

  /// 特殊宫位显示名称
  static const Map<String, String> specialGongDisplayNames = {
    'lifeGong': '命宫',
    'bodyGong': '身宫',
  };
}
