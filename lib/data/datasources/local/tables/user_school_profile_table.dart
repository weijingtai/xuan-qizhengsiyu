import 'package:drift/drift.dart';
import '../../../models/converters/panel_config_converter.dart';

class UserSchoolProfileTable extends Table {
  @override
  String get tableName => 't_user_school_profiles';

  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  TextColumn get name => text().named('name')();
  TextColumn get school => text().named('school')();
  TextColumn get classicBook => text().named('classic_book')();
  TextColumn get panelConfig =>
      text().map(const PanelConfigConverter()).named('panel_config_json')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  @override
  Set<Column> get primaryKey => {uuid};
}
