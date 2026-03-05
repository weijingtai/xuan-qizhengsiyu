// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ge_ju_builtin_database.dart';

// ignore_for_file: type=lint
class $BuiltinGeJuPatternsTable extends BuiltinGeJuPatterns
    with TableInfo<$BuiltinGeJuPatternsTable, BuiltinGeJuPattern> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BuiltinGeJuPatternsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _aliasesMeta =
      const VerificationMeta('aliases');
  @override
  late final GeneratedColumn<String> aliases = GeneratedColumn<String>(
      'aliases', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, aliases];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ge_ju_patterns';
  @override
  VerificationContext validateIntegrity(Insertable<BuiltinGeJuPattern> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('aliases')) {
      context.handle(_aliasesMeta,
          aliases.isAcceptableOrUnknown(data['aliases']!, _aliasesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BuiltinGeJuPattern map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BuiltinGeJuPattern(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      aliases: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}aliases']),
    );
  }

  @override
  $BuiltinGeJuPatternsTable createAlias(String alias) {
    return $BuiltinGeJuPatternsTable(attachedDatabase, alias);
  }
}

class BuiltinGeJuPattern extends DataClass
    implements Insertable<BuiltinGeJuPattern> {
  final String id;
  final String name;
  final String? aliases;
  const BuiltinGeJuPattern(
      {required this.id, required this.name, this.aliases});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || aliases != null) {
      map['aliases'] = Variable<String>(aliases);
    }
    return map;
  }

  BuiltinGeJuPatternsCompanion toCompanion(bool nullToAbsent) {
    return BuiltinGeJuPatternsCompanion(
      id: Value(id),
      name: Value(name),
      aliases: aliases == null && nullToAbsent
          ? const Value.absent()
          : Value(aliases),
    );
  }

  factory BuiltinGeJuPattern.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BuiltinGeJuPattern(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      aliases: serializer.fromJson<String?>(json['aliases']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'aliases': serializer.toJson<String?>(aliases),
    };
  }

  BuiltinGeJuPattern copyWith(
          {String? id,
          String? name,
          Value<String?> aliases = const Value.absent()}) =>
      BuiltinGeJuPattern(
        id: id ?? this.id,
        name: name ?? this.name,
        aliases: aliases.present ? aliases.value : this.aliases,
      );
  BuiltinGeJuPattern copyWithCompanion(BuiltinGeJuPatternsCompanion data) {
    return BuiltinGeJuPattern(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      aliases: data.aliases.present ? data.aliases.value : this.aliases,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BuiltinGeJuPattern(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('aliases: $aliases')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, aliases);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BuiltinGeJuPattern &&
          other.id == this.id &&
          other.name == this.name &&
          other.aliases == this.aliases);
}

class BuiltinGeJuPatternsCompanion extends UpdateCompanion<BuiltinGeJuPattern> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> aliases;
  final Value<int> rowid;
  const BuiltinGeJuPatternsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.aliases = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BuiltinGeJuPatternsCompanion.insert({
    required String id,
    required String name,
    this.aliases = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<BuiltinGeJuPattern> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? aliases,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (aliases != null) 'aliases': aliases,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BuiltinGeJuPatternsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? aliases,
      Value<int>? rowid}) {
    return BuiltinGeJuPatternsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      aliases: aliases ?? this.aliases,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (aliases.present) {
      map['aliases'] = Variable<String>(aliases.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BuiltinGeJuPatternsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('aliases: $aliases, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BuiltinGeJuSchoolsTable extends BuiltinGeJuSchools
    with TableInfo<$BuiltinGeJuSchoolsTable, BuiltinGeJuSchool> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BuiltinGeJuSchoolsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ge_ju_schools';
  @override
  VerificationContext validateIntegrity(Insertable<BuiltinGeJuSchool> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BuiltinGeJuSchool map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BuiltinGeJuSchool(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $BuiltinGeJuSchoolsTable createAlias(String alias) {
    return $BuiltinGeJuSchoolsTable(attachedDatabase, alias);
  }
}

class BuiltinGeJuSchool extends DataClass
    implements Insertable<BuiltinGeJuSchool> {
  final String id;
  final String name;
  const BuiltinGeJuSchool({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  BuiltinGeJuSchoolsCompanion toCompanion(bool nullToAbsent) {
    return BuiltinGeJuSchoolsCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory BuiltinGeJuSchool.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BuiltinGeJuSchool(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  BuiltinGeJuSchool copyWith({String? id, String? name}) => BuiltinGeJuSchool(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  BuiltinGeJuSchool copyWithCompanion(BuiltinGeJuSchoolsCompanion data) {
    return BuiltinGeJuSchool(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BuiltinGeJuSchool(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BuiltinGeJuSchool &&
          other.id == this.id &&
          other.name == this.name);
}

class BuiltinGeJuSchoolsCompanion extends UpdateCompanion<BuiltinGeJuSchool> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const BuiltinGeJuSchoolsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BuiltinGeJuSchoolsCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<BuiltinGeJuSchool> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BuiltinGeJuSchoolsCompanion copyWith(
      {Value<String>? id, Value<String>? name, Value<int>? rowid}) {
    return BuiltinGeJuSchoolsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BuiltinGeJuSchoolsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BuiltinGeJuRulesTable extends BuiltinGeJuRules
    with TableInfo<$BuiltinGeJuRulesTable, BuiltinGeJuRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BuiltinGeJuRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _patternIdMeta =
      const VerificationMeta('patternId');
  @override
  late final GeneratedColumn<String> patternId = GeneratedColumn<String>(
      'pattern_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _schoolIdMeta =
      const VerificationMeta('schoolId');
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
      'school_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _jixiongMeta =
      const VerificationMeta('jixiong');
  @override
  late final GeneratedColumn<String> jixiong = GeneratedColumn<String>(
      'jixiong', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _geJuTypeMeta =
      const VerificationMeta('geJuType');
  @override
  late final GeneratedColumn<String> geJuType = GeneratedColumn<String>(
      'ge_ju_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
      'scope', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _conditionsMeta =
      const VerificationMeta('conditions');
  @override
  late final GeneratedColumn<String> conditions = GeneratedColumn<String>(
      'conditions', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _briefMeta = const VerificationMeta('brief');
  @override
  late final GeneratedColumn<String> brief = GeneratedColumn<String>(
      'brief', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _explanationMeta =
      const VerificationMeta('explanation');
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
      'explanation', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
      'version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        patternId,
        schoolId,
        jixiong,
        geJuType,
        scope,
        conditions,
        brief,
        explanation,
        version,
        isActive
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ge_ju_rules';
  @override
  VerificationContext validateIntegrity(Insertable<BuiltinGeJuRule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pattern_id')) {
      context.handle(_patternIdMeta,
          patternId.isAcceptableOrUnknown(data['pattern_id']!, _patternIdMeta));
    } else if (isInserting) {
      context.missing(_patternIdMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(_schoolIdMeta,
          schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta));
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('jixiong')) {
      context.handle(_jixiongMeta,
          jixiong.isAcceptableOrUnknown(data['jixiong']!, _jixiongMeta));
    } else if (isInserting) {
      context.missing(_jixiongMeta);
    }
    if (data.containsKey('ge_ju_type')) {
      context.handle(_geJuTypeMeta,
          geJuType.isAcceptableOrUnknown(data['ge_ju_type']!, _geJuTypeMeta));
    } else if (isInserting) {
      context.missing(_geJuTypeMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(
          _scopeMeta, scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta));
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('conditions')) {
      context.handle(
          _conditionsMeta,
          conditions.isAcceptableOrUnknown(
              data['conditions']!, _conditionsMeta));
    }
    if (data.containsKey('brief')) {
      context.handle(
          _briefMeta, brief.isAcceptableOrUnknown(data['brief']!, _briefMeta));
    }
    if (data.containsKey('explanation')) {
      context.handle(
          _explanationMeta,
          explanation.isAcceptableOrUnknown(
              data['explanation']!, _explanationMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BuiltinGeJuRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BuiltinGeJuRule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      patternId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pattern_id'])!,
      schoolId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}school_id'])!,
      jixiong: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}jixiong'])!,
      geJuType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ge_ju_type'])!,
      scope: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scope'])!,
      conditions: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}conditions']),
      brief: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brief']),
      explanation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}explanation']),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}version'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $BuiltinGeJuRulesTable createAlias(String alias) {
    return $BuiltinGeJuRulesTable(attachedDatabase, alias);
  }
}

class BuiltinGeJuRule extends DataClass implements Insertable<BuiltinGeJuRule> {
  final int id;
  final String patternId;
  final String schoolId;
  final String jixiong;
  final String geJuType;
  final String scope;
  final String? conditions;
  final String? brief;
  final String? explanation;
  final String version;
  final bool isActive;
  const BuiltinGeJuRule(
      {required this.id,
      required this.patternId,
      required this.schoolId,
      required this.jixiong,
      required this.geJuType,
      required this.scope,
      this.conditions,
      this.brief,
      this.explanation,
      required this.version,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pattern_id'] = Variable<String>(patternId);
    map['school_id'] = Variable<String>(schoolId);
    map['jixiong'] = Variable<String>(jixiong);
    map['ge_ju_type'] = Variable<String>(geJuType);
    map['scope'] = Variable<String>(scope);
    if (!nullToAbsent || conditions != null) {
      map['conditions'] = Variable<String>(conditions);
    }
    if (!nullToAbsent || brief != null) {
      map['brief'] = Variable<String>(brief);
    }
    if (!nullToAbsent || explanation != null) {
      map['explanation'] = Variable<String>(explanation);
    }
    map['version'] = Variable<String>(version);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  BuiltinGeJuRulesCompanion toCompanion(bool nullToAbsent) {
    return BuiltinGeJuRulesCompanion(
      id: Value(id),
      patternId: Value(patternId),
      schoolId: Value(schoolId),
      jixiong: Value(jixiong),
      geJuType: Value(geJuType),
      scope: Value(scope),
      conditions: conditions == null && nullToAbsent
          ? const Value.absent()
          : Value(conditions),
      brief:
          brief == null && nullToAbsent ? const Value.absent() : Value(brief),
      explanation: explanation == null && nullToAbsent
          ? const Value.absent()
          : Value(explanation),
      version: Value(version),
      isActive: Value(isActive),
    );
  }

  factory BuiltinGeJuRule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BuiltinGeJuRule(
      id: serializer.fromJson<int>(json['id']),
      patternId: serializer.fromJson<String>(json['patternId']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      jixiong: serializer.fromJson<String>(json['jixiong']),
      geJuType: serializer.fromJson<String>(json['geJuType']),
      scope: serializer.fromJson<String>(json['scope']),
      conditions: serializer.fromJson<String?>(json['conditions']),
      brief: serializer.fromJson<String?>(json['brief']),
      explanation: serializer.fromJson<String?>(json['explanation']),
      version: serializer.fromJson<String>(json['version']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'patternId': serializer.toJson<String>(patternId),
      'schoolId': serializer.toJson<String>(schoolId),
      'jixiong': serializer.toJson<String>(jixiong),
      'geJuType': serializer.toJson<String>(geJuType),
      'scope': serializer.toJson<String>(scope),
      'conditions': serializer.toJson<String?>(conditions),
      'brief': serializer.toJson<String?>(brief),
      'explanation': serializer.toJson<String?>(explanation),
      'version': serializer.toJson<String>(version),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  BuiltinGeJuRule copyWith(
          {int? id,
          String? patternId,
          String? schoolId,
          String? jixiong,
          String? geJuType,
          String? scope,
          Value<String?> conditions = const Value.absent(),
          Value<String?> brief = const Value.absent(),
          Value<String?> explanation = const Value.absent(),
          String? version,
          bool? isActive}) =>
      BuiltinGeJuRule(
        id: id ?? this.id,
        patternId: patternId ?? this.patternId,
        schoolId: schoolId ?? this.schoolId,
        jixiong: jixiong ?? this.jixiong,
        geJuType: geJuType ?? this.geJuType,
        scope: scope ?? this.scope,
        conditions: conditions.present ? conditions.value : this.conditions,
        brief: brief.present ? brief.value : this.brief,
        explanation: explanation.present ? explanation.value : this.explanation,
        version: version ?? this.version,
        isActive: isActive ?? this.isActive,
      );
  BuiltinGeJuRule copyWithCompanion(BuiltinGeJuRulesCompanion data) {
    return BuiltinGeJuRule(
      id: data.id.present ? data.id.value : this.id,
      patternId: data.patternId.present ? data.patternId.value : this.patternId,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      jixiong: data.jixiong.present ? data.jixiong.value : this.jixiong,
      geJuType: data.geJuType.present ? data.geJuType.value : this.geJuType,
      scope: data.scope.present ? data.scope.value : this.scope,
      conditions:
          data.conditions.present ? data.conditions.value : this.conditions,
      brief: data.brief.present ? data.brief.value : this.brief,
      explanation:
          data.explanation.present ? data.explanation.value : this.explanation,
      version: data.version.present ? data.version.value : this.version,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BuiltinGeJuRule(')
          ..write('id: $id, ')
          ..write('patternId: $patternId, ')
          ..write('schoolId: $schoolId, ')
          ..write('jixiong: $jixiong, ')
          ..write('geJuType: $geJuType, ')
          ..write('scope: $scope, ')
          ..write('conditions: $conditions, ')
          ..write('brief: $brief, ')
          ..write('explanation: $explanation, ')
          ..write('version: $version, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, patternId, schoolId, jixiong, geJuType,
      scope, conditions, brief, explanation, version, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BuiltinGeJuRule &&
          other.id == this.id &&
          other.patternId == this.patternId &&
          other.schoolId == this.schoolId &&
          other.jixiong == this.jixiong &&
          other.geJuType == this.geJuType &&
          other.scope == this.scope &&
          other.conditions == this.conditions &&
          other.brief == this.brief &&
          other.explanation == this.explanation &&
          other.version == this.version &&
          other.isActive == this.isActive);
}

class BuiltinGeJuRulesCompanion extends UpdateCompanion<BuiltinGeJuRule> {
  final Value<int> id;
  final Value<String> patternId;
  final Value<String> schoolId;
  final Value<String> jixiong;
  final Value<String> geJuType;
  final Value<String> scope;
  final Value<String?> conditions;
  final Value<String?> brief;
  final Value<String?> explanation;
  final Value<String> version;
  final Value<bool> isActive;
  const BuiltinGeJuRulesCompanion({
    this.id = const Value.absent(),
    this.patternId = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.jixiong = const Value.absent(),
    this.geJuType = const Value.absent(),
    this.scope = const Value.absent(),
    this.conditions = const Value.absent(),
    this.brief = const Value.absent(),
    this.explanation = const Value.absent(),
    this.version = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  BuiltinGeJuRulesCompanion.insert({
    this.id = const Value.absent(),
    required String patternId,
    required String schoolId,
    required String jixiong,
    required String geJuType,
    required String scope,
    this.conditions = const Value.absent(),
    this.brief = const Value.absent(),
    this.explanation = const Value.absent(),
    required String version,
    this.isActive = const Value.absent(),
  })  : patternId = Value(patternId),
        schoolId = Value(schoolId),
        jixiong = Value(jixiong),
        geJuType = Value(geJuType),
        scope = Value(scope),
        version = Value(version);
  static Insertable<BuiltinGeJuRule> custom({
    Expression<int>? id,
    Expression<String>? patternId,
    Expression<String>? schoolId,
    Expression<String>? jixiong,
    Expression<String>? geJuType,
    Expression<String>? scope,
    Expression<String>? conditions,
    Expression<String>? brief,
    Expression<String>? explanation,
    Expression<String>? version,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patternId != null) 'pattern_id': patternId,
      if (schoolId != null) 'school_id': schoolId,
      if (jixiong != null) 'jixiong': jixiong,
      if (geJuType != null) 'ge_ju_type': geJuType,
      if (scope != null) 'scope': scope,
      if (conditions != null) 'conditions': conditions,
      if (brief != null) 'brief': brief,
      if (explanation != null) 'explanation': explanation,
      if (version != null) 'version': version,
      if (isActive != null) 'is_active': isActive,
    });
  }

  BuiltinGeJuRulesCompanion copyWith(
      {Value<int>? id,
      Value<String>? patternId,
      Value<String>? schoolId,
      Value<String>? jixiong,
      Value<String>? geJuType,
      Value<String>? scope,
      Value<String?>? conditions,
      Value<String?>? brief,
      Value<String?>? explanation,
      Value<String>? version,
      Value<bool>? isActive}) {
    return BuiltinGeJuRulesCompanion(
      id: id ?? this.id,
      patternId: patternId ?? this.patternId,
      schoolId: schoolId ?? this.schoolId,
      jixiong: jixiong ?? this.jixiong,
      geJuType: geJuType ?? this.geJuType,
      scope: scope ?? this.scope,
      conditions: conditions ?? this.conditions,
      brief: brief ?? this.brief,
      explanation: explanation ?? this.explanation,
      version: version ?? this.version,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (patternId.present) {
      map['pattern_id'] = Variable<String>(patternId.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (jixiong.present) {
      map['jixiong'] = Variable<String>(jixiong.value);
    }
    if (geJuType.present) {
      map['ge_ju_type'] = Variable<String>(geJuType.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (conditions.present) {
      map['conditions'] = Variable<String>(conditions.value);
    }
    if (brief.present) {
      map['brief'] = Variable<String>(brief.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BuiltinGeJuRulesCompanion(')
          ..write('id: $id, ')
          ..write('patternId: $patternId, ')
          ..write('schoolId: $schoolId, ')
          ..write('jixiong: $jixiong, ')
          ..write('geJuType: $geJuType, ')
          ..write('scope: $scope, ')
          ..write('conditions: $conditions, ')
          ..write('brief: $brief, ')
          ..write('explanation: $explanation, ')
          ..write('version: $version, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

abstract class _$GeJuBuiltInDatabase extends GeneratedDatabase {
  _$GeJuBuiltInDatabase(QueryExecutor e) : super(e);
  $GeJuBuiltInDatabaseManager get managers => $GeJuBuiltInDatabaseManager(this);
  late final $BuiltinGeJuPatternsTable builtinGeJuPatterns =
      $BuiltinGeJuPatternsTable(this);
  late final $BuiltinGeJuSchoolsTable builtinGeJuSchools =
      $BuiltinGeJuSchoolsTable(this);
  late final $BuiltinGeJuRulesTable builtinGeJuRules =
      $BuiltinGeJuRulesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [builtinGeJuPatterns, builtinGeJuSchools, builtinGeJuRules];
}

typedef $$BuiltinGeJuPatternsTableCreateCompanionBuilder
    = BuiltinGeJuPatternsCompanion Function({
  required String id,
  required String name,
  Value<String?> aliases,
  Value<int> rowid,
});
typedef $$BuiltinGeJuPatternsTableUpdateCompanionBuilder
    = BuiltinGeJuPatternsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> aliases,
  Value<int> rowid,
});

class $$BuiltinGeJuPatternsTableFilterComposer
    extends Composer<_$GeJuBuiltInDatabase, $BuiltinGeJuPatternsTable> {
  $$BuiltinGeJuPatternsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aliases => $composableBuilder(
      column: $table.aliases, builder: (column) => ColumnFilters(column));
}

class $$BuiltinGeJuPatternsTableOrderingComposer
    extends Composer<_$GeJuBuiltInDatabase, $BuiltinGeJuPatternsTable> {
  $$BuiltinGeJuPatternsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aliases => $composableBuilder(
      column: $table.aliases, builder: (column) => ColumnOrderings(column));
}

class $$BuiltinGeJuPatternsTableAnnotationComposer
    extends Composer<_$GeJuBuiltInDatabase, $BuiltinGeJuPatternsTable> {
  $$BuiltinGeJuPatternsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get aliases =>
      $composableBuilder(column: $table.aliases, builder: (column) => column);
}

class $$BuiltinGeJuPatternsTableTableManager extends RootTableManager<
    _$GeJuBuiltInDatabase,
    $BuiltinGeJuPatternsTable,
    BuiltinGeJuPattern,
    $$BuiltinGeJuPatternsTableFilterComposer,
    $$BuiltinGeJuPatternsTableOrderingComposer,
    $$BuiltinGeJuPatternsTableAnnotationComposer,
    $$BuiltinGeJuPatternsTableCreateCompanionBuilder,
    $$BuiltinGeJuPatternsTableUpdateCompanionBuilder,
    (
      BuiltinGeJuPattern,
      BaseReferences<_$GeJuBuiltInDatabase, $BuiltinGeJuPatternsTable,
          BuiltinGeJuPattern>
    ),
    BuiltinGeJuPattern,
    PrefetchHooks Function()> {
  $$BuiltinGeJuPatternsTableTableManager(
      _$GeJuBuiltInDatabase db, $BuiltinGeJuPatternsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BuiltinGeJuPatternsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BuiltinGeJuPatternsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BuiltinGeJuPatternsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> aliases = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BuiltinGeJuPatternsCompanion(
            id: id,
            name: name,
            aliases: aliases,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> aliases = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BuiltinGeJuPatternsCompanion.insert(
            id: id,
            name: name,
            aliases: aliases,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BuiltinGeJuPatternsTableProcessedTableManager = ProcessedTableManager<
    _$GeJuBuiltInDatabase,
    $BuiltinGeJuPatternsTable,
    BuiltinGeJuPattern,
    $$BuiltinGeJuPatternsTableFilterComposer,
    $$BuiltinGeJuPatternsTableOrderingComposer,
    $$BuiltinGeJuPatternsTableAnnotationComposer,
    $$BuiltinGeJuPatternsTableCreateCompanionBuilder,
    $$BuiltinGeJuPatternsTableUpdateCompanionBuilder,
    (
      BuiltinGeJuPattern,
      BaseReferences<_$GeJuBuiltInDatabase, $BuiltinGeJuPatternsTable,
          BuiltinGeJuPattern>
    ),
    BuiltinGeJuPattern,
    PrefetchHooks Function()>;
typedef $$BuiltinGeJuSchoolsTableCreateCompanionBuilder
    = BuiltinGeJuSchoolsCompanion Function({
  required String id,
  required String name,
  Value<int> rowid,
});
typedef $$BuiltinGeJuSchoolsTableUpdateCompanionBuilder
    = BuiltinGeJuSchoolsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> rowid,
});

class $$BuiltinGeJuSchoolsTableFilterComposer
    extends Composer<_$GeJuBuiltInDatabase, $BuiltinGeJuSchoolsTable> {
  $$BuiltinGeJuSchoolsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$BuiltinGeJuSchoolsTableOrderingComposer
    extends Composer<_$GeJuBuiltInDatabase, $BuiltinGeJuSchoolsTable> {
  $$BuiltinGeJuSchoolsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$BuiltinGeJuSchoolsTableAnnotationComposer
    extends Composer<_$GeJuBuiltInDatabase, $BuiltinGeJuSchoolsTable> {
  $$BuiltinGeJuSchoolsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$BuiltinGeJuSchoolsTableTableManager extends RootTableManager<
    _$GeJuBuiltInDatabase,
    $BuiltinGeJuSchoolsTable,
    BuiltinGeJuSchool,
    $$BuiltinGeJuSchoolsTableFilterComposer,
    $$BuiltinGeJuSchoolsTableOrderingComposer,
    $$BuiltinGeJuSchoolsTableAnnotationComposer,
    $$BuiltinGeJuSchoolsTableCreateCompanionBuilder,
    $$BuiltinGeJuSchoolsTableUpdateCompanionBuilder,
    (
      BuiltinGeJuSchool,
      BaseReferences<_$GeJuBuiltInDatabase, $BuiltinGeJuSchoolsTable,
          BuiltinGeJuSchool>
    ),
    BuiltinGeJuSchool,
    PrefetchHooks Function()> {
  $$BuiltinGeJuSchoolsTableTableManager(
      _$GeJuBuiltInDatabase db, $BuiltinGeJuSchoolsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BuiltinGeJuSchoolsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BuiltinGeJuSchoolsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BuiltinGeJuSchoolsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BuiltinGeJuSchoolsCompanion(
            id: id,
            name: name,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<int> rowid = const Value.absent(),
          }) =>
              BuiltinGeJuSchoolsCompanion.insert(
            id: id,
            name: name,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BuiltinGeJuSchoolsTableProcessedTableManager = ProcessedTableManager<
    _$GeJuBuiltInDatabase,
    $BuiltinGeJuSchoolsTable,
    BuiltinGeJuSchool,
    $$BuiltinGeJuSchoolsTableFilterComposer,
    $$BuiltinGeJuSchoolsTableOrderingComposer,
    $$BuiltinGeJuSchoolsTableAnnotationComposer,
    $$BuiltinGeJuSchoolsTableCreateCompanionBuilder,
    $$BuiltinGeJuSchoolsTableUpdateCompanionBuilder,
    (
      BuiltinGeJuSchool,
      BaseReferences<_$GeJuBuiltInDatabase, $BuiltinGeJuSchoolsTable,
          BuiltinGeJuSchool>
    ),
    BuiltinGeJuSchool,
    PrefetchHooks Function()>;
typedef $$BuiltinGeJuRulesTableCreateCompanionBuilder
    = BuiltinGeJuRulesCompanion Function({
  Value<int> id,
  required String patternId,
  required String schoolId,
  required String jixiong,
  required String geJuType,
  required String scope,
  Value<String?> conditions,
  Value<String?> brief,
  Value<String?> explanation,
  required String version,
  Value<bool> isActive,
});
typedef $$BuiltinGeJuRulesTableUpdateCompanionBuilder
    = BuiltinGeJuRulesCompanion Function({
  Value<int> id,
  Value<String> patternId,
  Value<String> schoolId,
  Value<String> jixiong,
  Value<String> geJuType,
  Value<String> scope,
  Value<String?> conditions,
  Value<String?> brief,
  Value<String?> explanation,
  Value<String> version,
  Value<bool> isActive,
});

class $$BuiltinGeJuRulesTableFilterComposer
    extends Composer<_$GeJuBuiltInDatabase, $BuiltinGeJuRulesTable> {
  $$BuiltinGeJuRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get patternId => $composableBuilder(
      column: $table.patternId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get schoolId => $composableBuilder(
      column: $table.schoolId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jixiong => $composableBuilder(
      column: $table.jixiong, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get geJuType => $composableBuilder(
      column: $table.geJuType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scope => $composableBuilder(
      column: $table.scope, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conditions => $composableBuilder(
      column: $table.conditions, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brief => $composableBuilder(
      column: $table.brief, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));
}

class $$BuiltinGeJuRulesTableOrderingComposer
    extends Composer<_$GeJuBuiltInDatabase, $BuiltinGeJuRulesTable> {
  $$BuiltinGeJuRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get patternId => $composableBuilder(
      column: $table.patternId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get schoolId => $composableBuilder(
      column: $table.schoolId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jixiong => $composableBuilder(
      column: $table.jixiong, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get geJuType => $composableBuilder(
      column: $table.geJuType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scope => $composableBuilder(
      column: $table.scope, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conditions => $composableBuilder(
      column: $table.conditions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brief => $composableBuilder(
      column: $table.brief, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$BuiltinGeJuRulesTableAnnotationComposer
    extends Composer<_$GeJuBuiltInDatabase, $BuiltinGeJuRulesTable> {
  $$BuiltinGeJuRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get patternId =>
      $composableBuilder(column: $table.patternId, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get jixiong =>
      $composableBuilder(column: $table.jixiong, builder: (column) => column);

  GeneratedColumn<String> get geJuType =>
      $composableBuilder(column: $table.geJuType, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get conditions => $composableBuilder(
      column: $table.conditions, builder: (column) => column);

  GeneratedColumn<String> get brief =>
      $composableBuilder(column: $table.brief, builder: (column) => column);

  GeneratedColumn<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$BuiltinGeJuRulesTableTableManager extends RootTableManager<
    _$GeJuBuiltInDatabase,
    $BuiltinGeJuRulesTable,
    BuiltinGeJuRule,
    $$BuiltinGeJuRulesTableFilterComposer,
    $$BuiltinGeJuRulesTableOrderingComposer,
    $$BuiltinGeJuRulesTableAnnotationComposer,
    $$BuiltinGeJuRulesTableCreateCompanionBuilder,
    $$BuiltinGeJuRulesTableUpdateCompanionBuilder,
    (
      BuiltinGeJuRule,
      BaseReferences<_$GeJuBuiltInDatabase, $BuiltinGeJuRulesTable,
          BuiltinGeJuRule>
    ),
    BuiltinGeJuRule,
    PrefetchHooks Function()> {
  $$BuiltinGeJuRulesTableTableManager(
      _$GeJuBuiltInDatabase db, $BuiltinGeJuRulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BuiltinGeJuRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BuiltinGeJuRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BuiltinGeJuRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> patternId = const Value.absent(),
            Value<String> schoolId = const Value.absent(),
            Value<String> jixiong = const Value.absent(),
            Value<String> geJuType = const Value.absent(),
            Value<String> scope = const Value.absent(),
            Value<String?> conditions = const Value.absent(),
            Value<String?> brief = const Value.absent(),
            Value<String?> explanation = const Value.absent(),
            Value<String> version = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              BuiltinGeJuRulesCompanion(
            id: id,
            patternId: patternId,
            schoolId: schoolId,
            jixiong: jixiong,
            geJuType: geJuType,
            scope: scope,
            conditions: conditions,
            brief: brief,
            explanation: explanation,
            version: version,
            isActive: isActive,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String patternId,
            required String schoolId,
            required String jixiong,
            required String geJuType,
            required String scope,
            Value<String?> conditions = const Value.absent(),
            Value<String?> brief = const Value.absent(),
            Value<String?> explanation = const Value.absent(),
            required String version,
            Value<bool> isActive = const Value.absent(),
          }) =>
              BuiltinGeJuRulesCompanion.insert(
            id: id,
            patternId: patternId,
            schoolId: schoolId,
            jixiong: jixiong,
            geJuType: geJuType,
            scope: scope,
            conditions: conditions,
            brief: brief,
            explanation: explanation,
            version: version,
            isActive: isActive,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BuiltinGeJuRulesTableProcessedTableManager = ProcessedTableManager<
    _$GeJuBuiltInDatabase,
    $BuiltinGeJuRulesTable,
    BuiltinGeJuRule,
    $$BuiltinGeJuRulesTableFilterComposer,
    $$BuiltinGeJuRulesTableOrderingComposer,
    $$BuiltinGeJuRulesTableAnnotationComposer,
    $$BuiltinGeJuRulesTableCreateCompanionBuilder,
    $$BuiltinGeJuRulesTableUpdateCompanionBuilder,
    (
      BuiltinGeJuRule,
      BaseReferences<_$GeJuBuiltInDatabase, $BuiltinGeJuRulesTable,
          BuiltinGeJuRule>
    ),
    BuiltinGeJuRule,
    PrefetchHooks Function()>;

class $GeJuBuiltInDatabaseManager {
  final _$GeJuBuiltInDatabase _db;
  $GeJuBuiltInDatabaseManager(this._db);
  $$BuiltinGeJuPatternsTableTableManager get builtinGeJuPatterns =>
      $$BuiltinGeJuPatternsTableTableManager(_db, _db.builtinGeJuPatterns);
  $$BuiltinGeJuSchoolsTableTableManager get builtinGeJuSchools =>
      $$BuiltinGeJuSchoolsTableTableManager(_db, _db.builtinGeJuSchools);
  $$BuiltinGeJuRulesTableTableManager get builtinGeJuRules =>
      $$BuiltinGeJuRulesTableTableManager(_db, _db.builtinGeJuRules);
}
