import 'dart:convert';
import 'package:drift/drift.dart';

import '../../../domain/entities/models/panel_config.dart';

class PanelConfigConverter extends TypeConverter<BasePanelConfig, String> {
  const PanelConfigConverter();

  @override
  BasePanelConfig fromSql(String fromDb) {
    return BasePanelConfig.fromJson(jsonDecode(fromDb));
  }

  @override
  String toSql(BasePanelConfig value) {
    return jsonEncode(value.toJson());
  }
}
