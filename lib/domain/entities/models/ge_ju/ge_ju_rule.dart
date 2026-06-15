import 'package:metaphysics_core/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju_model.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'ge_ju_alias.dart';
import 'ge_ju_condition.dart';
import 'ge_ju_variant.dart';

/// 格局适用范围
enum GeJuScope {
  @JsonValue("natal")
  natal, // 仅命盘
  @JsonValue("xingxian")
  xingxian, // 仅行限
  @JsonValue("both")
  both, // 通用
}

/// 格局规则定义（薄锚点）
///
/// Rule 是格局的身份锚点，只持有名称和属性分类信息。
/// 实质内容由 GeJuAnnotation（文字层）和 GeJuConditionSet（逻辑层）分别承载。
class GeJuRule {
  /// 唯一标识ID
  final String id;

  /// 格局名称
  final String name;

  /// 别名列表
  final List<GeJuAlias> aliases;

  /// 消歧注释（当多个同名格局需要区分时使用）
  final String? disambiguationNote;

  /// 适用范围
  final GeJuScope scope;

  /// 适用坐标系（如果特定格局依赖特定坐标系）
  /// null 表示通用或跟随用户设置
  final CelestialCoordinateSystem? coordinateSystem;

  /// 作者类型: 'built-in' | 'user'
  final String authorType;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  // ══ Legacy 兼容字段（仅用于过渡期间） ══

  /// Legacy: 格局变体列表（已弃用，仅用于 assets JSON 解析兼容）
  @Deprecated('Use GeJuAnnotation + GeJuConditionSet instead')
  final List<GeJuVariant> variants;

  GeJuRule({
    required this.id,
    required this.name,
    this.aliases = const [],
    this.disambiguationNote,
    required this.scope,
    this.coordinateSystem,
    this.authorType = 'built-in',
    DateTime? createdAt,
    DateTime? updatedAt,
    // ignore: deprecated_member_use_from_same_package
    this.variants = const [],
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 是否为内置规则
  bool get isBuiltIn => authorType == 'built-in';

  /// 是否为用户规则
  bool get isUser => authorType == 'user';

  // ══ Legacy Backward Compatibility Getters ══
  // 从第一个 variant 委托获取，供过渡期使用

  @Deprecated('Use GeJuAnnotation.description instead')
  String get description =>
      // ignore: deprecated_member_use_from_same_package
      variants.isNotEmpty ? variants.first.description : "";

  @Deprecated('Use GeJuAnnotation.className instead')
  String get className =>
      // ignore: deprecated_member_use_from_same_package
      variants.isNotEmpty ? variants.first.className : "未分类";

  @Deprecated('Use GeJuAnnotation.source instead')
  String get source =>
      // ignore: deprecated_member_use_from_same_package
      variants.isNotEmpty ? variants.first.source : "";

  @Deprecated('Use GeJuAnnotation.books / GeJuSource instead')
  String get books =>
      // ignore: deprecated_member_use_from_same_package
      variants.isNotEmpty ? variants.first.books : "";

  @Deprecated('Use GeJuAnnotation.jiXiong instead')
  JiXiongEnum get jiXiong =>
      // ignore: deprecated_member_use_from_same_package
      variants.isNotEmpty ? variants.first.jiXiong : JiXiongEnum.PING;

  @Deprecated('Use GeJuAnnotation.geJuType instead')
  GeJuType get geJuType =>
      // ignore: deprecated_member_use_from_same_package
      variants.isNotEmpty ? variants.first.geJuType : GeJuType.pin;

  @Deprecated('Use GeJuConditionSet.conditions instead')
  GeJuCondition? get conditions =>
      // ignore: deprecated_member_use_from_same_package
      variants.isNotEmpty ? variants.first.conditions : null;

  /// 创建副本
  GeJuRule copyWith({
    String? id,
    String? name,
    List<GeJuAlias>? aliases,
    String? disambiguationNote,
    GeJuScope? scope,
    CelestialCoordinateSystem? coordinateSystem,
    String? authorType,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<GeJuVariant>? variants,
  }) {
    return GeJuRule(
      id: id ?? this.id,
      name: name ?? this.name,
      aliases: aliases ?? this.aliases,
      disambiguationNote: disambiguationNote ?? this.disambiguationNote,
      scope: scope ?? this.scope,
      coordinateSystem: coordinateSystem ?? this.coordinateSystem,
      authorType: authorType ?? this.authorType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // ignore: deprecated_member_use_from_same_package
      variants: variants ?? this.variants,
    );
  }

  factory GeJuRule.fromJson(Map<String, dynamic> json) {
    // Parse variants for legacy compatibility
    var variantsList = <GeJuVariant>[];

    if (json['variants'] != null) {
      variantsList = (json['variants'] as List)
          .map((e) => GeJuVariant.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['conditions'] != null || json['description'] != null) {
      // Legacy Format Support: Construct a variant from flat fields
      variantsList.add(GeJuVariant(
        source: json['source'] as String? ?? "",
        description: json['description'] as String? ?? "",
        conditions: json['conditions'] != null
            ? GeJuCondition.fromJson(json['conditions'] as Map<String, dynamic>)
            : null,
        books: json['books'] as String? ?? "",
        className: json['className'] as String? ?? "未分类",
        jiXiong: $enumDecodeNullable(_$JiXiongEnumEnumMap, json['jiXiong']) ??
            JiXiongEnum.PING,
        geJuType: $enumDecodeNullable(_$GeJuTypeEnumMap, json['geJuType']) ??
            GeJuType.pin,
      ));
    }

    // Parse aliases
    var aliasesList = <GeJuAlias>[];
    if (json['aliases'] != null) {
      aliasesList = (json['aliases'] as List)
          .map((e) => GeJuAlias.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return GeJuRule(
      id: json['id'] as String,
      name: json['name'] as String,
      aliases: aliasesList,
      disambiguationNote: json['disambiguationNote'] as String?,
      scope: $enumDecodeNullable(_$GeJuScopeEnumMap, json['scope']) ??
          GeJuScope.natal,
      coordinateSystem: $enumDecodeNullable(
          _$CelestialCoordinateSystemEnumMap, json['coordinateSystem']),
      authorType: json['authorType'] as String? ?? 'built-in',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      variants: variantsList,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'name': name,
      'scope': _$GeJuScopeEnumMap[scope],
      'authorType': authorType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };

    if (aliases.isNotEmpty) {
      json['aliases'] = aliases.map((e) => e.toJson()).toList();
    }
    if (disambiguationNote != null) {
      json['disambiguationNote'] = disambiguationNote;
    }
    if (coordinateSystem != null) {
      json['coordinateSystem'] = _$CelestialCoordinateSystemEnumMap[coordinateSystem];
    }
    // ignore: deprecated_member_use_from_same_package
    if (variants.isNotEmpty) {
      // ignore: deprecated_member_use_from_same_package
      json['variants'] = variants.map((e) => e.toJson()).toList();
    }

    return json;
  }
}

const _$JiXiongEnumEnumMap = {
  JiXiongEnum.DA_JI: '大吉',
  JiXiongEnum.JI: '吉',
  JiXiongEnum.XIAO_JI: '小吉',
  JiXiongEnum.PING: '平',
  JiXiongEnum.XIAO_XIONG: '小凶',
  JiXiongEnum.XIONG: '凶',
  JiXiongEnum.DA_XIONG: '大凶',
  JiXiongEnum.WEI_ZHI: '未知',
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
  CelestialCoordinateSystem.Ecliptic: '黄道制',
  CelestialCoordinateSystem.Equatorial: '赤道制',
  CelestialCoordinateSystem.SkyEquatorial: '天赤道制',
  CelestialCoordinateSystem.PseudoEcliptic: '似黄道恒星制',
};
