import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju_model.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'ge_ju_condition.dart';

/// 格局适用范围
enum GeJuScope {
  @JsonValue("natal")
  natal, // 仅命盘
  @JsonValue("xingxian")
  xingxian, // 仅行限
  @JsonValue("both")
  both, // 通用
}

/// 格局规则定义
/// 扩展自基础 GeJuModel，增加了具体的判断逻辑
class GeJuRule extends GeJuModel {
  /// 唯一标识ID
  final String id;

  /// 出处（具体篇章或作者）
  final String source;

  /// 适用范围
  final GeJuScope scope;

  /// 核心判断条件（通过组合模式构建的条件树）
  final GeJuCondition? conditions;

  /// 适用坐标系（如果特定格局依赖特定坐标系）
  /// null 表示通用或跟随用户设置
  final CelestialCoordinateSystem? coordinateSystem;

  GeJuRule({
    required this.id,
    required String name,
    required String className,
    required String books,
    required String description,
    required this.source,
    required JiXiongEnum jiXiong,
    required GeJuType geJuType,
    required this.scope,
    this.conditions,
    this.coordinateSystem,
  }) : super(
          name: name,
          className: className,
          books: books,
          description: description,
          jiXiong: jiXiong,
          geJuType: geJuType,
        );

  factory GeJuRule.fromJson(Map<String, dynamic> json) {
    return GeJuRule(
      id: json['id'] as String,
      name: json['name'] as String,
      className: json['className'] as String? ?? "未分类",
      books: json['books'] as String? ?? "",
      description: json['description'] as String? ?? "",
      source: json['source'] as String? ?? "",
      jiXiong: $enumDecodeNullable(_$JiXiongEnumEnumMap, json['jiXiong']) ??
          JiXiongEnum.PING,
      geJuType: $enumDecodeNullable(_$GeJuTypeEnumMap, json['geJuType']) ??
          GeJuType.pin,
      scope: $enumDecodeNullable(_$GeJuScopeEnumMap, json['scope']) ??
          GeJuScope.natal,
      conditions: json['conditions'] != null
          ? GeJuCondition.fromJson(json['conditions'] as Map<String, dynamic>)
          : null,
      coordinateSystem: $enumDecodeNullable(
          _$CelestialCoordinateSystemEnumMap, json['coordinateSystem']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'className': className,
      'books': books,
      'description': description,
      'source': source,
      'jiXiong': _$JiXiongEnumEnumMap[jiXiong],
      'geJuType': _$GeJuTypeEnumMap[geJuType],
      'scope': _$GeJuScopeEnumMap[scope],
      'conditions': conditions?.toJson(),
      'coordinateSystem': _$CelestialCoordinateSystemEnumMap[coordinateSystem],
    };
  }
}

const _$JiXiongEnumEnumMap = {
  JiXiongEnum.JI: '吉',
  JiXiongEnum.XIONG: '凶',
  JiXiongEnum.PING: '平',
};

const _$GeJuTypeEnumMap = {
  GeJuType.pin: '贫',
  GeJuType.jian: '贱',
  GeJuType.fu: '富',
  GeJuType.gui: '贵',
  GeJuType.yao: '夭',
  GeJuType.shou: '寿',
  GeJuType.xian: '贤',
  GeJuType.yu: '愚',
};

const _$GeJuScopeEnumMap = {
  GeJuScope.natal: 'natal',
  GeJuScope.xingxian: 'xingxian',
  GeJuScope.both: 'both',
};

const _$CelestialCoordinateSystemEnumMap = {
  CelestialCoordinateSystem.ecliptic: '黄道制',
  CelestialCoordinateSystem.equatorial: '赤道制',
  CelestialCoordinateSystem.skyEquatorial: '天赤道制',
  CelestialCoordinateSystem.pseudoEcliptic: '似黄道恒星制',
};
