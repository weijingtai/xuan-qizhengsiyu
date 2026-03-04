import 'package:drift/drift.dart';

/// 格局元信息表
@DataClassName('Pattern')
class GeJuPatterns extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get englishName => text().named('english_name').nullable()();
  TextColumn get pinyin => text().nullable()();
  TextColumn get aliases => text().nullable()();
  TextColumn get categoryId => text().named('category_id')();
  TextColumn get keywords => text().nullable()();
  TextColumn get tags => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get originNotes => text().named('origin_notes').nullable()();
  IntColumn get referenceCount => integer().named('reference_count').withDefault(const Constant(0))();
  IntColumn get ruleCount => integer().named('rule_count').withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

/// 流派/典籍表
@DataClassName('School')
class GeJuSchools extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get era => text().nullable()();
  TextColumn get founder => text().nullable()();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive => boolean().named('is_active').withDefault(const Constant(true))();
  IntColumn get ruleCount => integer().named('rule_count').withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

/// 格局规则表
@DataClassName('Rule')
class GeJuRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get patternId => text().named('pattern_id')();
  TextColumn get schoolId => text().named('school_id')();
  TextColumn get jixiong => text()(); // '吉', '平', '凶'
  TextColumn get level => text()(); // '小', '中', '大'
  TextColumn get geJuType => text().named('ge_ju_type')();
  TextColumn get scope => text()();
  TextColumn get coordinateSystem => text().named('coordinate_system').nullable()();
  TextColumn get conditions => text().nullable()();
  TextColumn get assertion => text().nullable()();
  TextColumn get brief => text().nullable()();
  TextColumn get chapter => text().nullable()();
  TextColumn get originalText => text().named('original_text').nullable()();
  TextColumn get explanation => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get version => text()();
  TextColumn get versionRemark => text().named('version_remark').nullable()();
  BoolColumn get isActive => boolean().named('is_active').withDefault(const Constant(true))();
  BoolColumn get isVerified => boolean().named('is_verified').withDefault(const Constant(false))();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  IntColumn get viewCount => integer().named('view_count').withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  List<Set<Column>>? get uniqueKeys => [
    {patternId, schoolId}, // 防止同一格局在同一流派有重复规则
  ];
}

/// 版本历史表
@DataClassName('RuleVersion')
class GeJuVersions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ruleId => integer().named('rule_id')();
  TextColumn get version => text()();
  TextColumn get versionRemark => text().named('version_remark').nullable()();
  TextColumn get operationType => text().named('operation_type')();
  TextColumn get changedFields => text().named('changed_fields').nullable()();
  TextColumn get snapshot => text()();
  TextColumn get diffFromPrevious => text().named('diff_from_previous').nullable()();
  TextColumn get createdBy => text().named('created_by').withDefault(const Constant('admin'))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
}

/// 分类表
@DataClassName('Category')
class GeJuCategories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get order => integer().withDefault(const Constant(0))();
  TextColumn get parentId => text().named('parent_id').nullable()();
  BoolColumn get isActive => boolean().named('is_active').withDefault(const Constant(true))();
  IntColumn get patternCount => integer().named('pattern_count').withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}
