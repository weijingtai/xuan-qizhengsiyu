import 'package:drift/drift.dart';

/// 用户创建的格局规则表
class GeJuRulesTable extends Table {
  @override
  String get tableName => 't_ge_ju_rules';

  TextColumn get id => text().withLength(min: 1)();
  TextColumn get name => text()();
  /// JSON: List<GeJuAlias>
  TextColumn get aliasesJson => text().withDefault(const Constant('[]')).named('aliases_json')();
  TextColumn get disambiguationNote => text().nullable().named('disambiguation_note')();
  TextColumn get scope => text().withDefault(const Constant('natal'))();
  TextColumn get coordinateSystem => text().nullable().named('coordinate_system')();
  TextColumn get authorType => text().withDefault(const Constant('user')).named('author_type')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

/// 用户创建的注解表
class GeJuAnnotationsTable extends Table {
  @override
  String get tableName => 't_ge_ju_annotations';

  TextColumn get id => text().withLength(min: 1)();
  TextColumn get ruleId => text().named('rule_id')();
  /// JSON: List<String>?
  TextColumn get schoolsJson => text().nullable().named('schools_json')();
  /// JSON: GeJuSource?
  TextColumn get sourceJson => text().nullable().named('source_json')();
  TextColumn get authorType => text().withDefault(const Constant('user')).named('author_type')();
  TextColumn get version => text().withDefault(const Constant('1.0'))();
  TextColumn get description => text().nullable()();
  TextColumn get jiXiong => text().nullable().named('ji_xiong')();
  TextColumn get geJuType => text().nullable().named('ge_ju_type')();
  TextColumn get className => text().nullable().named('class_name')();
  TextColumn get parentAnnotationId => text().nullable().named('parent_annotation_id')();
  IntColumn get parentMajorVersion => integer().nullable().named('parent_major_version')();
  TextColumn get relationToParent => text().nullable().named('relation_to_parent')();
  /// JSON: List<String>
  TextColumn get referencesJson => text().withDefault(const Constant('[]')).named('references_json')();
  /// JSON: List<String>
  TextColumn get relatedConditionSetIdsJson => text().withDefault(const Constant('[]')).named('related_condition_set_ids_json')();
  TextColumn get visibility => text().withDefault(const Constant('private'))();
  TextColumn get locale => text().withDefault(const Constant('zh-Hans'))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

/// 用户创建的判断方案表
class GeJuConditionSetsTable extends Table {
  @override
  String get tableName => 't_ge_ju_condition_sets';

  TextColumn get id => text().withLength(min: 1)();
  TextColumn get ruleId => text().named('rule_id')();
  TextColumn get label => text()();
  /// JSON: List<String>?
  TextColumn get schoolsJson => text().nullable().named('schools_json')();
  /// JSON: GeJuSource?
  TextColumn get sourceJson => text().nullable().named('source_json')();
  TextColumn get authorType => text().withDefault(const Constant('user')).named('author_type')();
  /// JSON: GeJuCondition?
  TextColumn get conditionsJson => text().nullable().named('conditions_json')();
  TextColumn get derivedFrom => text().nullable().named('derived_from')();
  TextColumn get changeNote => text().nullable().named('change_note')();
  /// JSON: List<String>
  TextColumn get relatedAnnotationIdsJson => text().withDefault(const Constant('[]')).named('related_annotation_ids_json')();
  TextColumn get visibility => text().withDefault(const Constant('private'))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

/// 用户偏好表（单行）
class GeJuUserPreferencesTable extends Table {
  @override
  String get tableName => 't_ge_ju_user_preferences';

  /// 固定为 'default'
  TextColumn get id => text().withDefault(const Constant('default'))();
  /// JSON: List<String>
  TextColumn get hiddenConditionSetIdsJson => text().withDefault(const Constant('[]')).named('hidden_condition_set_ids_json')();
  /// JSON: List<String>?
  TextColumn get conditionSetSchoolsJson => text().nullable().named('condition_set_schools_json')();
  /// JSON: List<String>
  TextColumn get hiddenAnnotationIdsJson => text().withDefault(const Constant('[]')).named('hidden_annotation_ids_json')();
  /// JSON: List<String>?
  TextColumn get annotationSchoolsJson => text().nullable().named('annotation_schools_json')();

  @override
  Set<Column> get primaryKey => {id};
}

/// 用户自定义流派表
class GeJuSchoolsTable extends Table {
  @override
  String get tableName => 't_ge_ju_schools';

  TextColumn get id => text().withLength(min: 1)();
  TextColumn get name => text()();
  TextColumn get brief => text().nullable()();
  /// JSON: List<String>
  TextColumn get featuresJson => text().withDefault(const Constant('[]')).named('features_json')();

  @override
  Set<Column> get primaryKey => {id};
}

/// 删除审计记录表
class GeJuDeletionRecordsTable extends Table {
  @override
  String get tableName => 't_ge_ju_deletion_records';

  TextColumn get id => text().withLength(min: 1)();
  TextColumn get deletedEntityType => text().named('deleted_entity_type')();
  TextColumn get deletedEntityId => text().named('deleted_entity_id')();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at')();
  TextColumn get reason => text()();
  TextColumn get snapshotJson => text().named('snapshot_json')();

  @override
  Set<Column> get primaryKey => {id};
}
