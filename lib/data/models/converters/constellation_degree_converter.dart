import 'dart:convert';
import 'package:drift/drift.dart';

import '../../../domain/entities/models/naming_degree_pair.dart';

class ConstellationDegreeConverter extends TypeConverter<ConstellationDegree, String> {
  const ConstellationDegreeConverter();

  @override
  ConstellationDegree fromSql(String fromDb) {
    return ConstellationDegree.fromJson(jsonDecode(fromDb));
  }

  @override
  String toSql(ConstellationDegree value) {
    return jsonEncode(value.toJson());
  }
}
