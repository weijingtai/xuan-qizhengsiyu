import 'dart:convert';
import 'package:drift/drift.dart';

import '../../../domain/entities/models/base_panel_model.dart';

class BasePanelModelConverter extends TypeConverter<BasePanelModel, String> {
  const BasePanelModelConverter();

  @override
  BasePanelModel fromSql(String fromDb) {
    return BasePanelModel.fromJson(jsonDecode(fromDb));
  }

  @override
  String toSql(BasePanelModel value) {
    return jsonEncode(value.toJson());
  }
}