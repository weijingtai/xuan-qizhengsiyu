import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:common/models/divination_datetime.dart';

class DivinationDatetimeConverter extends TypeConverter<DivinationDatetimeModel, String> {
  const DivinationDatetimeConverter();

  @override
  DivinationDatetimeModel fromSql(String fromDb) {
    return DivinationDatetimeModel.fromJson(jsonDecode(fromDb));
  }

  @override
  String toSql(DivinationDatetimeModel value) {
    return jsonEncode(value.toJson());
  }
}