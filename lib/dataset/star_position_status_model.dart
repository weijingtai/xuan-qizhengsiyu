import 'dart:convert';
import 'package:common/enums.dart';
import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/enum_star_position_status.dart';
import '../enums/enum_twelve_gong.dart';

part 'star_position_status_model.g.dart';

@DataClassName('StarPositionStatusDatasetModel')
class StarPositionStatusTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get className => text()(); // 派别
  TextColumn get star => textEnum<EnumStars>()(); // 星
  TextColumn get starPositionStatusType =>
      textEnum<EnumStarGongPositionStatusType>()(); // 星状态
  TextColumn get positionList =>
      text().map(const PositionListConverter())(); // 宫 或 宿
  TextColumn get descriptionList =>
      text().nullable().map(const StringListConverter())(); // 描述
  TextColumn get geJuList =>
      text().nullable().map(const StringListConverter())(); // 格局
}

/// 位置列表转换器
class PositionListConverter<T extends Enum>
    extends TypeConverter<List<T>, String> {
  const PositionListConverter();

  @override
  List<T> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];

    final List<dynamic> jsonList = JsonDecoder().convert(fromDb);
    return jsonList.map((e) {
      if (T == EnumTwelveGong) {
        return EnumTwelveGong.getEnumTwelveGongByZhi(e) as T;
      } else if (T == Enum28Constellations) {
        return Enum28Constellations.fromStarName(e) as T;
      }
      return e as T;
    }).toList();
  }

  @override
  String toSql(List<T> value) {
    if (value.isEmpty) return '[]';

    final List<dynamic> jsonList = value.map((e) {
      if (T == EnumTwelveGong) {
        return (e as EnumTwelveGong).name;
      } else if (T == Enum28Constellations) {
        return (e as Enum28Constellations).name;
      }
      return e.toString();
    }).toList();

    return JsonEncoder().convert(jsonList);
  }
}

/// 字符串列表转换器
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    return List<String>.from(JsonDecoder().convert(fromDb));
  }

  @override
  String toSql(List<String> value) {
    if (value.isEmpty) return '[]';
    return JsonEncoder().convert(value);
  }
}

/// 星体位置状态数据模型
@JsonSerializable(genericArgumentFactories: true)
class StarPositionStatusDatasetModel<T extends Enum> {
  final int id;
  final String className;
  final EnumStars star;
  final EnumStarGongPositionStatusType starPositionStatusType;

  final List<T> positionList;
  final List<String>? descriptionList;
  final List<String>? geJuList;

  StarPositionStatusDatasetModel({
    required this.id,
    required this.className,
    required this.star,
    required this.starPositionStatusType,
    required this.positionList,
    this.descriptionList,
    this.geJuList,
  });

  factory StarPositionStatusDatasetModel.fromData(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StarPositionStatusDatasetModel(
      id: data['${effectivePrefix}id'] as int,
      className: data['${effectivePrefix}className'] as String,
      star: EnumStars.values
          .firstWhere((e) => e.toString() == data['${effectivePrefix}star']),
      starPositionStatusType: EnumStarGongPositionStatusType.values.firstWhere(
          (e) =>
              e.toString() == data['${effectivePrefix}starPositionStatusType']),
      positionList: PositionListConverter<T>()
          .fromSql(data['${effectivePrefix}positionList'] as String),
      descriptionList: data['${effectivePrefix}descriptionList'] == null
          ? null
          : const StringListConverter()
              .fromSql(data['${effectivePrefix}descriptionList'] as String),
      geJuList: data['${effectivePrefix}geJuList'] == null
          ? null
          : const StringListConverter()
              .fromSql(data['${effectivePrefix}geJuList'] as String),
    );
  }

  // Map<String, dynamic> toJson() => {
  //       'id': id,
  //       'className': className,
  //       'star': star.toString(),
  //       'starPositionStatusType': starPositionStatusType.toString(),
  //       'positionList': const PositionListConverter().toSql(positionList),
  //       'descriptionList': descriptionList == null
  //           ? null
  //           : const StringListConverter().toSql(descriptionList!),
  //       'geJuList': geJuList == null
  //           ? null
  //           : const StringListConverter().toSql(geJuList!),
  //     };

  factory StarPositionStatusDatasetModel.fromJson(Map<String, dynamic> json) =>
      _$StarPositionStatusDatasetModelFromJson<T>(json, _positionFromJson);

  Map<String, dynamic> toJson() =>
      _$StarPositionStatusDatasetModelToJson<T>(this, _positionToJson);

  static T _positionFromJson<T>(dynamic json) {
    if (T == EnumTwelveGong) {
      return EnumTwelveGong.getEnumTwelveGongByZhi(json) as T;
    } else if (T == Enum28Constellations) {
      return Enum28Constellations.fromStarName(json) as T;
    }
    return json as T;
  }

  static dynamic _positionToJson<T>(T value) {
    if (T == EnumTwelveGong) {
      return (value as EnumTwelveGong).name;
    } else if (T == Enum28Constellations) {
      return (value as Enum28Constellations).name;
    }
    return value.toString();
  }

  /// 从JSON数据转换为指定类型的列表
  /// [T] 目标类型，目前支持 EnumTwelveGong 和 Enum28Constellations
  /// [json] 输入的JSON数据
  /// 返回转换后的类型列表
  // static List<T> _positionFromJson<T>(dynamic json) {
  //   if (json == null) {
  //     return [];
  //   }

  //   if (json is! List) {
  //     throw FormatException('输入数据必须是列表类型');
  //   }

  //   try {
  //     if (T == EnumTwelveGong) {
  //       return json
  //           .map((e) => EnumTwelveGong.getEnumTwelveGongByZhi(e))
  //           .where((e) => e != null)
  //           .toList()
  //           .cast<T>();
  //     }

  //     if (T == Enum28Constellations) {
  //       return json
  //           .map((e) => Enum28Constellations.fromStarName(e))
  //           .where((e) => e != null)
  //           .toList()
  //           .cast<T>();
  //     }

  //     // 对于其他类型，尝试直接转换
  //     return json.map((e) => e as T).where((e) => e != null).toList();
  //   } catch (e) {
  //     throw FormatException('数据转换失败: $e');
  //   }
  // }

  // static dynamic _positionToJson<T>(List<T> value) {
  //   if (T == EnumTwelveGong) {
  //     return value.map((e) => (e as EnumTwelveGong).name).toList();
  //   } else if (T == Enum28Constellations) {
  //     return value.map((e) => (e as Enum28Constellations).name).toList();
  //   }
  //   return value.map((e) => e.toString()).toList();
  // }
}
