import 'dart:convert';

import 'package:common/enums.dart';
import 'package:drift/drift.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_alias.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition_set.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_deletion_record.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_source.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_user_preference.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju_model.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import '../app_database.dart';
import '../tables/ge_ju_tables.dart';

part 'ge_ju_dao.g.dart';

@DriftAccessor(tables: [
  GeJuRulesTable,
  GeJuAnnotationsTable,
  GeJuConditionSetsTable,
  GeJuUserPreferencesTable,
  GeJuDeletionRecordsTable,
])
class GeJuDao extends DatabaseAccessor<AppDatabase> with _$GeJuDaoMixin {
  GeJuDao(AppDatabase db) : super(db);

  // ══════════════════════════════════════════
  // Rule CRUD
  // ══════════════════════════════════════════

  Future<void> insertRule(GeJuRule rule) async {
    await into(geJuRulesTable).insert(
      GeJuRulesTableCompanion.insert(
        id: rule.id,
        name: rule.name,
        aliasesJson: Value(jsonEncode(rule.aliases.map((a) => a.toJson()).toList())),
        disambiguationNote: Value(rule.disambiguationNote),
        scope: Value(_scopeToString(rule.scope)),
        coordinateSystem: Value(_coordinateSystemToString(rule.coordinateSystem)),
        authorType: Value(rule.authorType),
        createdAt: rule.createdAt,
        updatedAt: rule.updatedAt,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<GeJuRule?> getRuleById(String id) async {
    final query = select(geJuRulesTable)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? _rowToRule(row) : null;
  }

  Future<List<GeJuRule>> getAllRules() async {
    final rows = await select(geJuRulesTable).get();
    return rows.map(_rowToRule).toList();
  }

  Future<void> updateRule(GeJuRule rule) async {
    await (update(geJuRulesTable)..where((t) => t.id.equals(rule.id))).write(
      GeJuRulesTableCompanion(
        name: Value(rule.name),
        aliasesJson: Value(jsonEncode(rule.aliases.map((a) => a.toJson()).toList())),
        disambiguationNote: Value(rule.disambiguationNote),
        scope: Value(_scopeToString(rule.scope)),
        coordinateSystem: Value(_coordinateSystemToString(rule.coordinateSystem)),
        updatedAt: Value(rule.updatedAt),
      ),
    );
  }

  Future<void> deleteRule(String id) async {
    await (delete(geJuRulesTable)..where((t) => t.id.equals(id))).go();
  }

  // ══════════════════════════════════════════
  // ConditionSet CRUD
  // ══════════════════════════════════════════

  Future<void> insertConditionSet(GeJuConditionSet cs) async {
    await into(geJuConditionSetsTable).insert(
      GeJuConditionSetsTableCompanion.insert(
        id: cs.id,
        ruleId: cs.ruleId,
        label: cs.label,
        schoolsJson: Value(cs.schools != null ? jsonEncode(cs.schools) : null),
        sourceJson: Value(cs.source != null ? jsonEncode(cs.source!.toJson()) : null),
        authorType: Value(cs.authorType),
        conditionsJson: Value(cs.conditions != null ? jsonEncode(cs.conditions!.toJson()) : null),
        derivedFrom: Value(cs.derivedFrom),
        changeNote: Value(cs.changeNote),
        relatedAnnotationIdsJson: Value(jsonEncode(cs.relatedAnnotationIds)),
        visibility: Value(cs.visibility),
        createdAt: cs.createdAt,
        updatedAt: cs.updatedAt,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<List<GeJuConditionSet>> getConditionSetsForRule(String ruleId) async {
    final query = select(geJuConditionSetsTable)
      ..where((t) => t.ruleId.equals(ruleId));
    final rows = await query.get();
    return rows.map(_rowToConditionSet).toList();
  }

  Future<GeJuConditionSet?> getConditionSetById(String id) async {
    final query = select(geJuConditionSetsTable)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? _rowToConditionSet(row) : null;
  }

  Future<void> updateConditionSet(GeJuConditionSet cs) async {
    await (update(geJuConditionSetsTable)..where((t) => t.id.equals(cs.id))).write(
      GeJuConditionSetsTableCompanion(
        label: Value(cs.label),
        schoolsJson: Value(cs.schools != null ? jsonEncode(cs.schools) : null),
        sourceJson: Value(cs.source != null ? jsonEncode(cs.source!.toJson()) : null),
        conditionsJson: Value(cs.conditions != null ? jsonEncode(cs.conditions!.toJson()) : null),
        derivedFrom: Value(cs.derivedFrom),
        changeNote: Value(cs.changeNote),
        relatedAnnotationIdsJson: Value(jsonEncode(cs.relatedAnnotationIds)),
        updatedAt: Value(cs.updatedAt),
      ),
    );
  }

  Future<void> deleteConditionSet(String id) async {
    await (delete(geJuConditionSetsTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteConditionSetsForRule(String ruleId) async {
    await (delete(geJuConditionSetsTable)..where((t) => t.ruleId.equals(ruleId))).go();
  }

  // ══════════════════════════════════════════
  // Annotation CRUD
  // ══════════════════════════════════════════

  Future<void> insertAnnotation(GeJuAnnotation ann) async {
    await into(geJuAnnotationsTable).insert(
      GeJuAnnotationsTableCompanion.insert(
        id: ann.id,
        ruleId: ann.ruleId,
        schoolsJson: Value(ann.schools != null ? jsonEncode(ann.schools) : null),
        sourceJson: Value(ann.source != null ? jsonEncode(ann.source!.toJson()) : null),
        authorType: Value(ann.authorType),
        version: Value(ann.version),
        description: Value(ann.description),
        jiXiong: Value(ann.jiXiong != null ? ann.jiXiong!.name : null),
        geJuType: Value(ann.geJuType != null ? ann.geJuType!.name : null),
        className: Value(ann.className),
        parentAnnotationId: Value(ann.parentAnnotationId),
        parentMajorVersion: Value(ann.parentMajorVersion),
        relationToParent: Value(ann.relationToParent),
        referencesJson: Value(jsonEncode(ann.references)),
        relatedConditionSetIdsJson: Value(jsonEncode(ann.relatedConditionSetIds)),
        visibility: Value(ann.visibility),
        locale: Value(ann.locale),
        createdAt: ann.createdAt,
        updatedAt: ann.updatedAt,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<List<GeJuAnnotation>> getAnnotationsForRule(String ruleId) async {
    final query = select(geJuAnnotationsTable)
      ..where((t) => t.ruleId.equals(ruleId));
    final rows = await query.get();
    return rows.map(_rowToAnnotation).toList();
  }

  Future<GeJuAnnotation?> getAnnotationById(String id) async {
    final query = select(geJuAnnotationsTable)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? _rowToAnnotation(row) : null;
  }

  Future<void> updateAnnotation(GeJuAnnotation ann) async {
    await (update(geJuAnnotationsTable)..where((t) => t.id.equals(ann.id))).write(
      GeJuAnnotationsTableCompanion(
        schoolsJson: Value(ann.schools != null ? jsonEncode(ann.schools) : null),
        sourceJson: Value(ann.source != null ? jsonEncode(ann.source!.toJson()) : null),
        version: Value(ann.version),
        description: Value(ann.description),
        jiXiong: Value(ann.jiXiong != null ? ann.jiXiong!.name : null),
        geJuType: Value(ann.geJuType != null ? ann.geJuType!.name : null),
        className: Value(ann.className),
        parentAnnotationId: Value(ann.parentAnnotationId),
        parentMajorVersion: Value(ann.parentMajorVersion),
        relationToParent: Value(ann.relationToParent),
        referencesJson: Value(jsonEncode(ann.references)),
        relatedConditionSetIdsJson: Value(jsonEncode(ann.relatedConditionSetIds)),
        updatedAt: Value(ann.updatedAt),
      ),
    );
  }

  Future<void> deleteAnnotation(String id) async {
    await (delete(geJuAnnotationsTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteAnnotationsForRule(String ruleId) async {
    await (delete(geJuAnnotationsTable)..where((t) => t.ruleId.equals(ruleId))).go();
  }

  // ══════════════════════════════════════════
  // UserPreference
  // ══════════════════════════════════════════

  Future<GeJuUserPreference> getPreference() async {
    final query = select(geJuUserPreferencesTable)
      ..where((t) => t.id.equals('default'));
    final row = await query.getSingleOrNull();
    if (row == null) return GeJuUserPreference.defaultPreference;
    return _rowToUserPreference(row);
  }

  Future<void> savePreference(GeJuUserPreference pref) async {
    await into(geJuUserPreferencesTable).insert(
      GeJuUserPreferencesTableCompanion.insert(
        id: Value('default'),
        hiddenConditionSetIdsJson: Value(jsonEncode(pref.hiddenConditionSetIds)),
        conditionSetSchoolsJson: Value(pref.conditionSetSchools != null ? jsonEncode(pref.conditionSetSchools) : null),
        hiddenAnnotationIdsJson: Value(jsonEncode(pref.hiddenAnnotationIds)),
        annotationSchoolsJson: Value(pref.annotationSchools != null ? jsonEncode(pref.annotationSchools) : null),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  // ══════════════════════════════════════════
  // DeletionRecord
  // ══════════════════════════════════════════

  Future<void> insertDeletionRecord(GeJuDeletionRecord record) async {
    await into(geJuDeletionRecordsTable).insert(
      GeJuDeletionRecordsTableCompanion.insert(
        id: record.id,
        deletedEntityType: record.deletedEntityType,
        deletedEntityId: record.deletedEntityId,
        deletedAt: record.deletedAt,
        reason: record.reason,
        snapshotJson: record.snapshotJson,
      ),
    );
  }

  // ══════════════════════════════════════════
  // Row → Domain mappers
  // ══════════════════════════════════════════

  GeJuRule _rowToRule(GeJuRulesTableData row) {
    List<GeJuAlias> aliases = [];
    try {
      final list = jsonDecode(row.aliasesJson) as List;
      aliases = list.map((e) => GeJuAlias.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {}

    return GeJuRule(
      id: row.id,
      name: row.name,
      aliases: aliases,
      disambiguationNote: row.disambiguationNote,
      scope: _stringToScope(row.scope),
      coordinateSystem: _stringToCoordinateSystem(row.coordinateSystem),
      authorType: row.authorType,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  GeJuConditionSet _rowToConditionSet(GeJuConditionSetsTableData row) {
    List<String>? schools;
    if (row.schoolsJson != null) {
      try {
        schools = (jsonDecode(row.schoolsJson!) as List).cast<String>();
      } catch (_) {}
    }

    GeJuSource? source;
    if (row.sourceJson != null) {
      try {
        source = GeJuSource.fromJson(jsonDecode(row.sourceJson!) as Map<String, dynamic>);
      } catch (_) {}
    }

    GeJuCondition? conditions;
    if (row.conditionsJson != null) {
      try {
        conditions = GeJuCondition.fromJson(jsonDecode(row.conditionsJson!) as Map<String, dynamic>);
      } catch (_) {}
    }

    List<String> relatedAnnotationIds = [];
    try {
      relatedAnnotationIds = (jsonDecode(row.relatedAnnotationIdsJson) as List).cast<String>();
    } catch (_) {}

    return GeJuConditionSet(
      id: row.id,
      ruleId: row.ruleId,
      label: row.label,
      schools: schools,
      source: source,
      authorType: row.authorType,
      conditions: conditions,
      derivedFrom: row.derivedFrom,
      changeNote: row.changeNote,
      relatedAnnotationIds: relatedAnnotationIds,
      visibility: row.visibility,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  GeJuAnnotation _rowToAnnotation(GeJuAnnotationsTableData row) {
    List<String>? schools;
    if (row.schoolsJson != null) {
      try {
        schools = (jsonDecode(row.schoolsJson!) as List).cast<String>();
      } catch (_) {}
    }

    GeJuSource? source;
    if (row.sourceJson != null) {
      try {
        source = GeJuSource.fromJson(jsonDecode(row.sourceJson!) as Map<String, dynamic>);
      } catch (_) {}
    }

    List<String> references = [];
    try {
      references = (jsonDecode(row.referencesJson) as List).cast<String>();
    } catch (_) {}

    List<String> relatedCsIds = [];
    try {
      relatedCsIds = (jsonDecode(row.relatedConditionSetIdsJson) as List).cast<String>();
    } catch (_) {}

    return GeJuAnnotation(
      id: row.id,
      ruleId: row.ruleId,
      schools: schools,
      source: source,
      authorType: row.authorType,
      version: row.version,
      description: row.description,
      jiXiong: row.jiXiong != null ? _stringToJiXiong(row.jiXiong!) : null,
      geJuType: row.geJuType != null ? _stringToGeJuType(row.geJuType!) : null,
      className: row.className,
      parentAnnotationId: row.parentAnnotationId,
      parentMajorVersion: row.parentMajorVersion,
      relationToParent: row.relationToParent,
      references: references,
      relatedConditionSetIds: relatedCsIds,
      visibility: row.visibility,
      locale: row.locale,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  GeJuUserPreference _rowToUserPreference(GeJuUserPreferencesTableData row) {
    List<String> hiddenCsIds = [];
    try {
      hiddenCsIds = (jsonDecode(row.hiddenConditionSetIdsJson) as List).cast<String>();
    } catch (_) {}

    List<String>? csSchools;
    if (row.conditionSetSchoolsJson != null) {
      try {
        csSchools = (jsonDecode(row.conditionSetSchoolsJson!) as List).cast<String>();
      } catch (_) {}
    }

    List<String> hiddenAnnIds = [];
    try {
      hiddenAnnIds = (jsonDecode(row.hiddenAnnotationIdsJson) as List).cast<String>();
    } catch (_) {}

    List<String>? annSchools;
    if (row.annotationSchoolsJson != null) {
      try {
        annSchools = (jsonDecode(row.annotationSchoolsJson!) as List).cast<String>();
      } catch (_) {}
    }

    return GeJuUserPreference(
      hiddenConditionSetIds: hiddenCsIds,
      conditionSetSchools: csSchools,
      hiddenAnnotationIds: hiddenAnnIds,
      annotationSchools: annSchools,
    );
  }

  // ══════════════════════════════════════════
  // Enum helpers
  // ══════════════════════════════════════════

  static String _scopeToString(GeJuScope scope) {
    switch (scope) {
      case GeJuScope.natal: return 'natal';
      case GeJuScope.xingxian: return 'xingxian';
      case GeJuScope.both: return 'both';
    }
  }

  static GeJuScope _stringToScope(String s) {
    switch (s) {
      case 'natal': return GeJuScope.natal;
      case 'xingxian': return GeJuScope.xingxian;
      case 'both': return GeJuScope.both;
      default: return GeJuScope.natal;
    }
  }

  static String? _coordinateSystemToString(CelestialCoordinateSystem? cs) {
    if (cs == null) return null;
    return cs.name;
  }

  static CelestialCoordinateSystem? _stringToCoordinateSystem(String? s) {
    if (s == null) return null;
    try {
      return CelestialCoordinateSystem.values.byName(s);
    } catch (_) {
      return null;
    }
  }

  static JiXiongEnum _stringToJiXiong(String s) {
    try {
      return JiXiongEnum.values.byName(s);
    } catch (_) {
      return JiXiongEnum.PING;
    }
  }

  static GeJuType _stringToGeJuType(String s) {
    try {
      return GeJuType.values.byName(s);
    } catch (_) {
      return GeJuType.pin;
    }
  }
}
