// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $QizhengsiyuPanTableTable extends QizhengsiyuPanTable
    with TableInfo<$QizhengsiyuPanTableTable, QiZhengSiYuPanEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QizhengsiyuPanTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid =
      GeneratedColumn<String>('uuid', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdatedAtMeta =
      const VerificationMeta('lastUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> lastUpdatedAt =
      GeneratedColumn<DateTime>('last_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _divinationRequestInfoUuidMeta =
      const VerificationMeta('divinationRequestInfoUuid');
  @override
  late final GeneratedColumn<String> divinationRequestInfoUuid =
      GeneratedColumn<String>(
          'divination_request_info_uuid', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<BasePanelConfig, String>
      panelConfig = GeneratedColumn<String>(
              'panel_config_json', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<BasePanelConfig>(
              $QizhengsiyuPanTableTable.$converterpanelConfig);
  @override
  late final GeneratedColumnWithTypeConverter<BasePanelModel, String>
      panelModel = GeneratedColumn<String>(
              'panel_data_json', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<BasePanelModel>(
              $QizhengsiyuPanTableTable.$converterpanelModel);
  @override
  late final GeneratedColumnWithTypeConverter<DivinationDatetimeModel, String>
      divinationDatetimeModel = GeneratedColumn<String>(
              'divination_datetime_json', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DivinationDatetimeModel>(
              $QizhengsiyuPanTableTable.$converterdivinationDatetimeModel);
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        createdAt,
        lastUpdatedAt,
        deletedAt,
        divinationRequestInfoUuid,
        panelConfig,
        panelModel,
        divinationDatetimeModel
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_qizhengsiyu_pans';
  @override
  VerificationContext validateIntegrity(
      Insertable<QiZhengSiYuPanEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_updated_at')) {
      context.handle(
          _lastUpdatedAtMeta,
          lastUpdatedAt.isAcceptableOrUnknown(
              data['last_updated_at']!, _lastUpdatedAtMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('divination_request_info_uuid')) {
      context.handle(
          _divinationRequestInfoUuidMeta,
          divinationRequestInfoUuid.isAcceptableOrUnknown(
              data['divination_request_info_uuid']!,
              _divinationRequestInfoUuidMeta));
    } else if (isInserting) {
      context.missing(_divinationRequestInfoUuidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  QiZhengSiYuPanEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QiZhengSiYuPanEntity(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      divinationRequestInfoUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}divination_request_info_uuid'])!,
      panelConfig: $QizhengsiyuPanTableTable.$converterpanelConfig.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}panel_config_json'])!),
      panelModel: $QizhengsiyuPanTableTable.$converterpanelModel.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}panel_data_json'])!),
      divinationDatetimeModel: $QizhengsiyuPanTableTable
          .$converterdivinationDatetimeModel
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}divination_datetime_json'])!),
    );
  }

  @override
  $QizhengsiyuPanTableTable createAlias(String alias) {
    return $QizhengsiyuPanTableTable(attachedDatabase, alias);
  }

  static TypeConverter<BasePanelConfig, String> $converterpanelConfig =
      const PanelConfigConverter();
  static TypeConverter<BasePanelModel, String> $converterpanelModel =
      const BasePanelModelConverter();
  static TypeConverter<DivinationDatetimeModel, String>
      $converterdivinationDatetimeModel = const DivinationDatetimeConverter();
}

class QizhengsiyuPanTableCompanion
    extends UpdateCompanion<QiZhengSiYuPanEntity> {
  final Value<String> uuid;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUpdatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> divinationRequestInfoUuid;
  final Value<BasePanelConfig> panelConfig;
  final Value<BasePanelModel> panelModel;
  final Value<DivinationDatetimeModel> divinationDatetimeModel;
  final Value<int> rowid;
  const QizhengsiyuPanTableCompanion({
    this.uuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.divinationRequestInfoUuid = const Value.absent(),
    this.panelConfig = const Value.absent(),
    this.panelModel = const Value.absent(),
    this.divinationDatetimeModel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QizhengsiyuPanTableCompanion.insert({
    required String uuid,
    required DateTime createdAt,
    required DateTime lastUpdatedAt,
    this.deletedAt = const Value.absent(),
    required String divinationRequestInfoUuid,
    required BasePanelConfig panelConfig,
    required BasePanelModel panelModel,
    required DivinationDatetimeModel divinationDatetimeModel,
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        createdAt = Value(createdAt),
        lastUpdatedAt = Value(lastUpdatedAt),
        divinationRequestInfoUuid = Value(divinationRequestInfoUuid),
        panelConfig = Value(panelConfig),
        panelModel = Value(panelModel),
        divinationDatetimeModel = Value(divinationDatetimeModel);
  static Insertable<QiZhengSiYuPanEntity> custom({
    Expression<String>? uuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUpdatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? divinationRequestInfoUuid,
    Expression<String>? panelConfig,
    Expression<String>? panelModel,
    Expression<String>? divinationDatetimeModel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdatedAt != null) 'last_updated_at': lastUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (divinationRequestInfoUuid != null)
        'divination_request_info_uuid': divinationRequestInfoUuid,
      if (panelConfig != null) 'panel_config_json': panelConfig,
      if (panelModel != null) 'panel_data_json': panelModel,
      if (divinationDatetimeModel != null)
        'divination_datetime_json': divinationDatetimeModel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QizhengsiyuPanTableCompanion copyWith(
      {Value<String>? uuid,
      Value<DateTime>? createdAt,
      Value<DateTime>? lastUpdatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? divinationRequestInfoUuid,
      Value<BasePanelConfig>? panelConfig,
      Value<BasePanelModel>? panelModel,
      Value<DivinationDatetimeModel>? divinationDatetimeModel,
      Value<int>? rowid}) {
    return QizhengsiyuPanTableCompanion(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      divinationRequestInfoUuid:
          divinationRequestInfoUuid ?? this.divinationRequestInfoUuid,
      panelConfig: panelConfig ?? this.panelConfig,
      panelModel: panelModel ?? this.panelModel,
      divinationDatetimeModel:
          divinationDatetimeModel ?? this.divinationDatetimeModel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUpdatedAt.present) {
      map['last_updated_at'] = Variable<DateTime>(lastUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (divinationRequestInfoUuid.present) {
      map['divination_request_info_uuid'] =
          Variable<String>(divinationRequestInfoUuid.value);
    }
    if (panelConfig.present) {
      map['panel_config_json'] = Variable<String>($QizhengsiyuPanTableTable
          .$converterpanelConfig
          .toSql(panelConfig.value));
    }
    if (panelModel.present) {
      map['panel_data_json'] = Variable<String>($QizhengsiyuPanTableTable
          .$converterpanelModel
          .toSql(panelModel.value));
    }
    if (divinationDatetimeModel.present) {
      map['divination_datetime_json'] = Variable<String>(
          $QizhengsiyuPanTableTable.$converterdivinationDatetimeModel
              .toSql(divinationDatetimeModel.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QizhengsiyuPanTableCompanion(')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdatedAt: $lastUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('divinationRequestInfoUuid: $divinationRequestInfoUuid, ')
          ..write('panelConfig: $panelConfig, ')
          ..write('panelModel: $panelModel, ')
          ..write('divinationDatetimeModel: $divinationDatetimeModel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GeJuRulesTableTable extends GeJuRulesTable
    with TableInfo<$GeJuRulesTableTable, GeJuRulesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeJuRulesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id =
      GeneratedColumn<String>('id', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _aliasesJsonMeta =
      const VerificationMeta('aliasesJson');
  @override
  late final GeneratedColumn<String> aliasesJson = GeneratedColumn<String>(
      'aliases_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _disambiguationNoteMeta =
      const VerificationMeta('disambiguationNote');
  @override
  late final GeneratedColumn<String> disambiguationNote =
      GeneratedColumn<String>('disambiguation_note', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
      'scope', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('natal'));
  static const VerificationMeta _coordinateSystemMeta =
      const VerificationMeta('coordinateSystem');
  @override
  late final GeneratedColumn<String> coordinateSystem = GeneratedColumn<String>(
      'coordinate_system', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _authorTypeMeta =
      const VerificationMeta('authorType');
  @override
  late final GeneratedColumn<String> authorType = GeneratedColumn<String>(
      'author_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('user'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        aliasesJson,
        disambiguationNote,
        scope,
        coordinateSystem,
        authorType,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_ge_ju_rules';
  @override
  VerificationContext validateIntegrity(Insertable<GeJuRulesTableData> instance,
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
    if (data.containsKey('aliases_json')) {
      context.handle(
          _aliasesJsonMeta,
          aliasesJson.isAcceptableOrUnknown(
              data['aliases_json']!, _aliasesJsonMeta));
    }
    if (data.containsKey('disambiguation_note')) {
      context.handle(
          _disambiguationNoteMeta,
          disambiguationNote.isAcceptableOrUnknown(
              data['disambiguation_note']!, _disambiguationNoteMeta));
    }
    if (data.containsKey('scope')) {
      context.handle(
          _scopeMeta, scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta));
    }
    if (data.containsKey('coordinate_system')) {
      context.handle(
          _coordinateSystemMeta,
          coordinateSystem.isAcceptableOrUnknown(
              data['coordinate_system']!, _coordinateSystemMeta));
    }
    if (data.containsKey('author_type')) {
      context.handle(
          _authorTypeMeta,
          authorType.isAcceptableOrUnknown(
              data['author_type']!, _authorTypeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeJuRulesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeJuRulesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      aliasesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}aliases_json'])!,
      disambiguationNote: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}disambiguation_note']),
      scope: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scope'])!,
      coordinateSystem: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}coordinate_system']),
      authorType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author_type'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $GeJuRulesTableTable createAlias(String alias) {
    return $GeJuRulesTableTable(attachedDatabase, alias);
  }
}

class GeJuRulesTableData extends DataClass
    implements Insertable<GeJuRulesTableData> {
  final String id;
  final String name;

  /// JSON: List<GeJuAlias>
  final String aliasesJson;
  final String? disambiguationNote;
  final String scope;
  final String? coordinateSystem;
  final String authorType;
  final DateTime createdAt;
  final DateTime updatedAt;
  const GeJuRulesTableData(
      {required this.id,
      required this.name,
      required this.aliasesJson,
      this.disambiguationNote,
      required this.scope,
      this.coordinateSystem,
      required this.authorType,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['aliases_json'] = Variable<String>(aliasesJson);
    if (!nullToAbsent || disambiguationNote != null) {
      map['disambiguation_note'] = Variable<String>(disambiguationNote);
    }
    map['scope'] = Variable<String>(scope);
    if (!nullToAbsent || coordinateSystem != null) {
      map['coordinate_system'] = Variable<String>(coordinateSystem);
    }
    map['author_type'] = Variable<String>(authorType);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GeJuRulesTableCompanion toCompanion(bool nullToAbsent) {
    return GeJuRulesTableCompanion(
      id: Value(id),
      name: Value(name),
      aliasesJson: Value(aliasesJson),
      disambiguationNote: disambiguationNote == null && nullToAbsent
          ? const Value.absent()
          : Value(disambiguationNote),
      scope: Value(scope),
      coordinateSystem: coordinateSystem == null && nullToAbsent
          ? const Value.absent()
          : Value(coordinateSystem),
      authorType: Value(authorType),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory GeJuRulesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeJuRulesTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      aliasesJson: serializer.fromJson<String>(json['aliasesJson']),
      disambiguationNote:
          serializer.fromJson<String?>(json['disambiguationNote']),
      scope: serializer.fromJson<String>(json['scope']),
      coordinateSystem: serializer.fromJson<String?>(json['coordinateSystem']),
      authorType: serializer.fromJson<String>(json['authorType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'aliasesJson': serializer.toJson<String>(aliasesJson),
      'disambiguationNote': serializer.toJson<String?>(disambiguationNote),
      'scope': serializer.toJson<String>(scope),
      'coordinateSystem': serializer.toJson<String?>(coordinateSystem),
      'authorType': serializer.toJson<String>(authorType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GeJuRulesTableData copyWith(
          {String? id,
          String? name,
          String? aliasesJson,
          Value<String?> disambiguationNote = const Value.absent(),
          String? scope,
          Value<String?> coordinateSystem = const Value.absent(),
          String? authorType,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      GeJuRulesTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        aliasesJson: aliasesJson ?? this.aliasesJson,
        disambiguationNote: disambiguationNote.present
            ? disambiguationNote.value
            : this.disambiguationNote,
        scope: scope ?? this.scope,
        coordinateSystem: coordinateSystem.present
            ? coordinateSystem.value
            : this.coordinateSystem,
        authorType: authorType ?? this.authorType,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  GeJuRulesTableData copyWithCompanion(GeJuRulesTableCompanion data) {
    return GeJuRulesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      aliasesJson:
          data.aliasesJson.present ? data.aliasesJson.value : this.aliasesJson,
      disambiguationNote: data.disambiguationNote.present
          ? data.disambiguationNote.value
          : this.disambiguationNote,
      scope: data.scope.present ? data.scope.value : this.scope,
      coordinateSystem: data.coordinateSystem.present
          ? data.coordinateSystem.value
          : this.coordinateSystem,
      authorType:
          data.authorType.present ? data.authorType.value : this.authorType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeJuRulesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('aliasesJson: $aliasesJson, ')
          ..write('disambiguationNote: $disambiguationNote, ')
          ..write('scope: $scope, ')
          ..write('coordinateSystem: $coordinateSystem, ')
          ..write('authorType: $authorType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, aliasesJson, disambiguationNote,
      scope, coordinateSystem, authorType, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeJuRulesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.aliasesJson == this.aliasesJson &&
          other.disambiguationNote == this.disambiguationNote &&
          other.scope == this.scope &&
          other.coordinateSystem == this.coordinateSystem &&
          other.authorType == this.authorType &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GeJuRulesTableCompanion extends UpdateCompanion<GeJuRulesTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> aliasesJson;
  final Value<String?> disambiguationNote;
  final Value<String> scope;
  final Value<String?> coordinateSystem;
  final Value<String> authorType;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const GeJuRulesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.aliasesJson = const Value.absent(),
    this.disambiguationNote = const Value.absent(),
    this.scope = const Value.absent(),
    this.coordinateSystem = const Value.absent(),
    this.authorType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GeJuRulesTableCompanion.insert({
    required String id,
    required String name,
    this.aliasesJson = const Value.absent(),
    this.disambiguationNote = const Value.absent(),
    this.scope = const Value.absent(),
    this.coordinateSystem = const Value.absent(),
    this.authorType = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<GeJuRulesTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? aliasesJson,
    Expression<String>? disambiguationNote,
    Expression<String>? scope,
    Expression<String>? coordinateSystem,
    Expression<String>? authorType,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (aliasesJson != null) 'aliases_json': aliasesJson,
      if (disambiguationNote != null) 'disambiguation_note': disambiguationNote,
      if (scope != null) 'scope': scope,
      if (coordinateSystem != null) 'coordinate_system': coordinateSystem,
      if (authorType != null) 'author_type': authorType,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GeJuRulesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? aliasesJson,
      Value<String?>? disambiguationNote,
      Value<String>? scope,
      Value<String?>? coordinateSystem,
      Value<String>? authorType,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return GeJuRulesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      aliasesJson: aliasesJson ?? this.aliasesJson,
      disambiguationNote: disambiguationNote ?? this.disambiguationNote,
      scope: scope ?? this.scope,
      coordinateSystem: coordinateSystem ?? this.coordinateSystem,
      authorType: authorType ?? this.authorType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (aliasesJson.present) {
      map['aliases_json'] = Variable<String>(aliasesJson.value);
    }
    if (disambiguationNote.present) {
      map['disambiguation_note'] = Variable<String>(disambiguationNote.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (coordinateSystem.present) {
      map['coordinate_system'] = Variable<String>(coordinateSystem.value);
    }
    if (authorType.present) {
      map['author_type'] = Variable<String>(authorType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeJuRulesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('aliasesJson: $aliasesJson, ')
          ..write('disambiguationNote: $disambiguationNote, ')
          ..write('scope: $scope, ')
          ..write('coordinateSystem: $coordinateSystem, ')
          ..write('authorType: $authorType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GeJuAnnotationsTableTable extends GeJuAnnotationsTable
    with TableInfo<$GeJuAnnotationsTableTable, GeJuAnnotationsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeJuAnnotationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id =
      GeneratedColumn<String>('id', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<String> ruleId = GeneratedColumn<String>(
      'rule_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _schoolsJsonMeta =
      const VerificationMeta('schoolsJson');
  @override
  late final GeneratedColumn<String> schoolsJson = GeneratedColumn<String>(
      'schools_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceJsonMeta =
      const VerificationMeta('sourceJson');
  @override
  late final GeneratedColumn<String> sourceJson = GeneratedColumn<String>(
      'source_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _authorTypeMeta =
      const VerificationMeta('authorType');
  @override
  late final GeneratedColumn<String> authorType = GeneratedColumn<String>(
      'author_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('user'));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
      'version', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('1.0'));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _jiXiongMeta =
      const VerificationMeta('jiXiong');
  @override
  late final GeneratedColumn<String> jiXiong = GeneratedColumn<String>(
      'ji_xiong', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _geJuTypeMeta =
      const VerificationMeta('geJuType');
  @override
  late final GeneratedColumn<String> geJuType = GeneratedColumn<String>(
      'ge_ju_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _classNameMeta =
      const VerificationMeta('className');
  @override
  late final GeneratedColumn<String> className = GeneratedColumn<String>(
      'class_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parentAnnotationIdMeta =
      const VerificationMeta('parentAnnotationId');
  @override
  late final GeneratedColumn<String> parentAnnotationId =
      GeneratedColumn<String>('parent_annotation_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parentMajorVersionMeta =
      const VerificationMeta('parentMajorVersion');
  @override
  late final GeneratedColumn<int> parentMajorVersion = GeneratedColumn<int>(
      'parent_major_version', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _relationToParentMeta =
      const VerificationMeta('relationToParent');
  @override
  late final GeneratedColumn<String> relationToParent = GeneratedColumn<String>(
      'relation_to_parent', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referencesJsonMeta =
      const VerificationMeta('referencesJson');
  @override
  late final GeneratedColumn<String> referencesJson = GeneratedColumn<String>(
      'references_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _relatedConditionSetIdsJsonMeta =
      const VerificationMeta('relatedConditionSetIdsJson');
  @override
  late final GeneratedColumn<String> relatedConditionSetIdsJson =
      GeneratedColumn<String>(
          'related_condition_set_ids_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _visibilityMeta =
      const VerificationMeta('visibility');
  @override
  late final GeneratedColumn<String> visibility = GeneratedColumn<String>(
      'visibility', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('private'));
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
      'locale', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('zh-Hans'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        ruleId,
        schoolsJson,
        sourceJson,
        authorType,
        version,
        description,
        jiXiong,
        geJuType,
        className,
        parentAnnotationId,
        parentMajorVersion,
        relationToParent,
        referencesJson,
        relatedConditionSetIdsJson,
        visibility,
        locale,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_ge_ju_annotations';
  @override
  VerificationContext validateIntegrity(
      Insertable<GeJuAnnotationsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('rule_id')) {
      context.handle(_ruleIdMeta,
          ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta));
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('schools_json')) {
      context.handle(
          _schoolsJsonMeta,
          schoolsJson.isAcceptableOrUnknown(
              data['schools_json']!, _schoolsJsonMeta));
    }
    if (data.containsKey('source_json')) {
      context.handle(
          _sourceJsonMeta,
          sourceJson.isAcceptableOrUnknown(
              data['source_json']!, _sourceJsonMeta));
    }
    if (data.containsKey('author_type')) {
      context.handle(
          _authorTypeMeta,
          authorType.isAcceptableOrUnknown(
              data['author_type']!, _authorTypeMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('ji_xiong')) {
      context.handle(_jiXiongMeta,
          jiXiong.isAcceptableOrUnknown(data['ji_xiong']!, _jiXiongMeta));
    }
    if (data.containsKey('ge_ju_type')) {
      context.handle(_geJuTypeMeta,
          geJuType.isAcceptableOrUnknown(data['ge_ju_type']!, _geJuTypeMeta));
    }
    if (data.containsKey('class_name')) {
      context.handle(_classNameMeta,
          className.isAcceptableOrUnknown(data['class_name']!, _classNameMeta));
    }
    if (data.containsKey('parent_annotation_id')) {
      context.handle(
          _parentAnnotationIdMeta,
          parentAnnotationId.isAcceptableOrUnknown(
              data['parent_annotation_id']!, _parentAnnotationIdMeta));
    }
    if (data.containsKey('parent_major_version')) {
      context.handle(
          _parentMajorVersionMeta,
          parentMajorVersion.isAcceptableOrUnknown(
              data['parent_major_version']!, _parentMajorVersionMeta));
    }
    if (data.containsKey('relation_to_parent')) {
      context.handle(
          _relationToParentMeta,
          relationToParent.isAcceptableOrUnknown(
              data['relation_to_parent']!, _relationToParentMeta));
    }
    if (data.containsKey('references_json')) {
      context.handle(
          _referencesJsonMeta,
          referencesJson.isAcceptableOrUnknown(
              data['references_json']!, _referencesJsonMeta));
    }
    if (data.containsKey('related_condition_set_ids_json')) {
      context.handle(
          _relatedConditionSetIdsJsonMeta,
          relatedConditionSetIdsJson.isAcceptableOrUnknown(
              data['related_condition_set_ids_json']!,
              _relatedConditionSetIdsJsonMeta));
    }
    if (data.containsKey('visibility')) {
      context.handle(
          _visibilityMeta,
          visibility.isAcceptableOrUnknown(
              data['visibility']!, _visibilityMeta));
    }
    if (data.containsKey('locale')) {
      context.handle(_localeMeta,
          locale.isAcceptableOrUnknown(data['locale']!, _localeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeJuAnnotationsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeJuAnnotationsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      ruleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rule_id'])!,
      schoolsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}schools_json']),
      sourceJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_json']),
      authorType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author_type'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}version'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      jiXiong: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ji_xiong']),
      geJuType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ge_ju_type']),
      className: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}class_name']),
      parentAnnotationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}parent_annotation_id']),
      parentMajorVersion: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}parent_major_version']),
      relationToParent: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}relation_to_parent']),
      referencesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}references_json'])!,
      relatedConditionSetIdsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}related_condition_set_ids_json'])!,
      visibility: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}visibility'])!,
      locale: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}locale'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $GeJuAnnotationsTableTable createAlias(String alias) {
    return $GeJuAnnotationsTableTable(attachedDatabase, alias);
  }
}

class GeJuAnnotationsTableData extends DataClass
    implements Insertable<GeJuAnnotationsTableData> {
  final String id;
  final String ruleId;

  /// JSON: List<String>?
  final String? schoolsJson;

  /// JSON: GeJuSource?
  final String? sourceJson;
  final String authorType;
  final String version;
  final String? description;
  final String? jiXiong;
  final String? geJuType;
  final String? className;
  final String? parentAnnotationId;
  final int? parentMajorVersion;
  final String? relationToParent;

  /// JSON: List<String>
  final String referencesJson;

  /// JSON: List<String>
  final String relatedConditionSetIdsJson;
  final String visibility;
  final String locale;
  final DateTime createdAt;
  final DateTime updatedAt;
  const GeJuAnnotationsTableData(
      {required this.id,
      required this.ruleId,
      this.schoolsJson,
      this.sourceJson,
      required this.authorType,
      required this.version,
      this.description,
      this.jiXiong,
      this.geJuType,
      this.className,
      this.parentAnnotationId,
      this.parentMajorVersion,
      this.relationToParent,
      required this.referencesJson,
      required this.relatedConditionSetIdsJson,
      required this.visibility,
      required this.locale,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['rule_id'] = Variable<String>(ruleId);
    if (!nullToAbsent || schoolsJson != null) {
      map['schools_json'] = Variable<String>(schoolsJson);
    }
    if (!nullToAbsent || sourceJson != null) {
      map['source_json'] = Variable<String>(sourceJson);
    }
    map['author_type'] = Variable<String>(authorType);
    map['version'] = Variable<String>(version);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || jiXiong != null) {
      map['ji_xiong'] = Variable<String>(jiXiong);
    }
    if (!nullToAbsent || geJuType != null) {
      map['ge_ju_type'] = Variable<String>(geJuType);
    }
    if (!nullToAbsent || className != null) {
      map['class_name'] = Variable<String>(className);
    }
    if (!nullToAbsent || parentAnnotationId != null) {
      map['parent_annotation_id'] = Variable<String>(parentAnnotationId);
    }
    if (!nullToAbsent || parentMajorVersion != null) {
      map['parent_major_version'] = Variable<int>(parentMajorVersion);
    }
    if (!nullToAbsent || relationToParent != null) {
      map['relation_to_parent'] = Variable<String>(relationToParent);
    }
    map['references_json'] = Variable<String>(referencesJson);
    map['related_condition_set_ids_json'] =
        Variable<String>(relatedConditionSetIdsJson);
    map['visibility'] = Variable<String>(visibility);
    map['locale'] = Variable<String>(locale);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GeJuAnnotationsTableCompanion toCompanion(bool nullToAbsent) {
    return GeJuAnnotationsTableCompanion(
      id: Value(id),
      ruleId: Value(ruleId),
      schoolsJson: schoolsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(schoolsJson),
      sourceJson: sourceJson == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceJson),
      authorType: Value(authorType),
      version: Value(version),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      jiXiong: jiXiong == null && nullToAbsent
          ? const Value.absent()
          : Value(jiXiong),
      geJuType: geJuType == null && nullToAbsent
          ? const Value.absent()
          : Value(geJuType),
      className: className == null && nullToAbsent
          ? const Value.absent()
          : Value(className),
      parentAnnotationId: parentAnnotationId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentAnnotationId),
      parentMajorVersion: parentMajorVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(parentMajorVersion),
      relationToParent: relationToParent == null && nullToAbsent
          ? const Value.absent()
          : Value(relationToParent),
      referencesJson: Value(referencesJson),
      relatedConditionSetIdsJson: Value(relatedConditionSetIdsJson),
      visibility: Value(visibility),
      locale: Value(locale),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory GeJuAnnotationsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeJuAnnotationsTableData(
      id: serializer.fromJson<String>(json['id']),
      ruleId: serializer.fromJson<String>(json['ruleId']),
      schoolsJson: serializer.fromJson<String?>(json['schoolsJson']),
      sourceJson: serializer.fromJson<String?>(json['sourceJson']),
      authorType: serializer.fromJson<String>(json['authorType']),
      version: serializer.fromJson<String>(json['version']),
      description: serializer.fromJson<String?>(json['description']),
      jiXiong: serializer.fromJson<String?>(json['jiXiong']),
      geJuType: serializer.fromJson<String?>(json['geJuType']),
      className: serializer.fromJson<String?>(json['className']),
      parentAnnotationId:
          serializer.fromJson<String?>(json['parentAnnotationId']),
      parentMajorVersion: serializer.fromJson<int?>(json['parentMajorVersion']),
      relationToParent: serializer.fromJson<String?>(json['relationToParent']),
      referencesJson: serializer.fromJson<String>(json['referencesJson']),
      relatedConditionSetIdsJson:
          serializer.fromJson<String>(json['relatedConditionSetIdsJson']),
      visibility: serializer.fromJson<String>(json['visibility']),
      locale: serializer.fromJson<String>(json['locale']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ruleId': serializer.toJson<String>(ruleId),
      'schoolsJson': serializer.toJson<String?>(schoolsJson),
      'sourceJson': serializer.toJson<String?>(sourceJson),
      'authorType': serializer.toJson<String>(authorType),
      'version': serializer.toJson<String>(version),
      'description': serializer.toJson<String?>(description),
      'jiXiong': serializer.toJson<String?>(jiXiong),
      'geJuType': serializer.toJson<String?>(geJuType),
      'className': serializer.toJson<String?>(className),
      'parentAnnotationId': serializer.toJson<String?>(parentAnnotationId),
      'parentMajorVersion': serializer.toJson<int?>(parentMajorVersion),
      'relationToParent': serializer.toJson<String?>(relationToParent),
      'referencesJson': serializer.toJson<String>(referencesJson),
      'relatedConditionSetIdsJson':
          serializer.toJson<String>(relatedConditionSetIdsJson),
      'visibility': serializer.toJson<String>(visibility),
      'locale': serializer.toJson<String>(locale),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GeJuAnnotationsTableData copyWith(
          {String? id,
          String? ruleId,
          Value<String?> schoolsJson = const Value.absent(),
          Value<String?> sourceJson = const Value.absent(),
          String? authorType,
          String? version,
          Value<String?> description = const Value.absent(),
          Value<String?> jiXiong = const Value.absent(),
          Value<String?> geJuType = const Value.absent(),
          Value<String?> className = const Value.absent(),
          Value<String?> parentAnnotationId = const Value.absent(),
          Value<int?> parentMajorVersion = const Value.absent(),
          Value<String?> relationToParent = const Value.absent(),
          String? referencesJson,
          String? relatedConditionSetIdsJson,
          String? visibility,
          String? locale,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      GeJuAnnotationsTableData(
        id: id ?? this.id,
        ruleId: ruleId ?? this.ruleId,
        schoolsJson: schoolsJson.present ? schoolsJson.value : this.schoolsJson,
        sourceJson: sourceJson.present ? sourceJson.value : this.sourceJson,
        authorType: authorType ?? this.authorType,
        version: version ?? this.version,
        description: description.present ? description.value : this.description,
        jiXiong: jiXiong.present ? jiXiong.value : this.jiXiong,
        geJuType: geJuType.present ? geJuType.value : this.geJuType,
        className: className.present ? className.value : this.className,
        parentAnnotationId: parentAnnotationId.present
            ? parentAnnotationId.value
            : this.parentAnnotationId,
        parentMajorVersion: parentMajorVersion.present
            ? parentMajorVersion.value
            : this.parentMajorVersion,
        relationToParent: relationToParent.present
            ? relationToParent.value
            : this.relationToParent,
        referencesJson: referencesJson ?? this.referencesJson,
        relatedConditionSetIdsJson:
            relatedConditionSetIdsJson ?? this.relatedConditionSetIdsJson,
        visibility: visibility ?? this.visibility,
        locale: locale ?? this.locale,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  GeJuAnnotationsTableData copyWithCompanion(
      GeJuAnnotationsTableCompanion data) {
    return GeJuAnnotationsTableData(
      id: data.id.present ? data.id.value : this.id,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      schoolsJson:
          data.schoolsJson.present ? data.schoolsJson.value : this.schoolsJson,
      sourceJson:
          data.sourceJson.present ? data.sourceJson.value : this.sourceJson,
      authorType:
          data.authorType.present ? data.authorType.value : this.authorType,
      version: data.version.present ? data.version.value : this.version,
      description:
          data.description.present ? data.description.value : this.description,
      jiXiong: data.jiXiong.present ? data.jiXiong.value : this.jiXiong,
      geJuType: data.geJuType.present ? data.geJuType.value : this.geJuType,
      className: data.className.present ? data.className.value : this.className,
      parentAnnotationId: data.parentAnnotationId.present
          ? data.parentAnnotationId.value
          : this.parentAnnotationId,
      parentMajorVersion: data.parentMajorVersion.present
          ? data.parentMajorVersion.value
          : this.parentMajorVersion,
      relationToParent: data.relationToParent.present
          ? data.relationToParent.value
          : this.relationToParent,
      referencesJson: data.referencesJson.present
          ? data.referencesJson.value
          : this.referencesJson,
      relatedConditionSetIdsJson: data.relatedConditionSetIdsJson.present
          ? data.relatedConditionSetIdsJson.value
          : this.relatedConditionSetIdsJson,
      visibility:
          data.visibility.present ? data.visibility.value : this.visibility,
      locale: data.locale.present ? data.locale.value : this.locale,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeJuAnnotationsTableData(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('schoolsJson: $schoolsJson, ')
          ..write('sourceJson: $sourceJson, ')
          ..write('authorType: $authorType, ')
          ..write('version: $version, ')
          ..write('description: $description, ')
          ..write('jiXiong: $jiXiong, ')
          ..write('geJuType: $geJuType, ')
          ..write('className: $className, ')
          ..write('parentAnnotationId: $parentAnnotationId, ')
          ..write('parentMajorVersion: $parentMajorVersion, ')
          ..write('relationToParent: $relationToParent, ')
          ..write('referencesJson: $referencesJson, ')
          ..write('relatedConditionSetIdsJson: $relatedConditionSetIdsJson, ')
          ..write('visibility: $visibility, ')
          ..write('locale: $locale, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      ruleId,
      schoolsJson,
      sourceJson,
      authorType,
      version,
      description,
      jiXiong,
      geJuType,
      className,
      parentAnnotationId,
      parentMajorVersion,
      relationToParent,
      referencesJson,
      relatedConditionSetIdsJson,
      visibility,
      locale,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeJuAnnotationsTableData &&
          other.id == this.id &&
          other.ruleId == this.ruleId &&
          other.schoolsJson == this.schoolsJson &&
          other.sourceJson == this.sourceJson &&
          other.authorType == this.authorType &&
          other.version == this.version &&
          other.description == this.description &&
          other.jiXiong == this.jiXiong &&
          other.geJuType == this.geJuType &&
          other.className == this.className &&
          other.parentAnnotationId == this.parentAnnotationId &&
          other.parentMajorVersion == this.parentMajorVersion &&
          other.relationToParent == this.relationToParent &&
          other.referencesJson == this.referencesJson &&
          other.relatedConditionSetIdsJson == this.relatedConditionSetIdsJson &&
          other.visibility == this.visibility &&
          other.locale == this.locale &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GeJuAnnotationsTableCompanion
    extends UpdateCompanion<GeJuAnnotationsTableData> {
  final Value<String> id;
  final Value<String> ruleId;
  final Value<String?> schoolsJson;
  final Value<String?> sourceJson;
  final Value<String> authorType;
  final Value<String> version;
  final Value<String?> description;
  final Value<String?> jiXiong;
  final Value<String?> geJuType;
  final Value<String?> className;
  final Value<String?> parentAnnotationId;
  final Value<int?> parentMajorVersion;
  final Value<String?> relationToParent;
  final Value<String> referencesJson;
  final Value<String> relatedConditionSetIdsJson;
  final Value<String> visibility;
  final Value<String> locale;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const GeJuAnnotationsTableCompanion({
    this.id = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.schoolsJson = const Value.absent(),
    this.sourceJson = const Value.absent(),
    this.authorType = const Value.absent(),
    this.version = const Value.absent(),
    this.description = const Value.absent(),
    this.jiXiong = const Value.absent(),
    this.geJuType = const Value.absent(),
    this.className = const Value.absent(),
    this.parentAnnotationId = const Value.absent(),
    this.parentMajorVersion = const Value.absent(),
    this.relationToParent = const Value.absent(),
    this.referencesJson = const Value.absent(),
    this.relatedConditionSetIdsJson = const Value.absent(),
    this.visibility = const Value.absent(),
    this.locale = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GeJuAnnotationsTableCompanion.insert({
    required String id,
    required String ruleId,
    this.schoolsJson = const Value.absent(),
    this.sourceJson = const Value.absent(),
    this.authorType = const Value.absent(),
    this.version = const Value.absent(),
    this.description = const Value.absent(),
    this.jiXiong = const Value.absent(),
    this.geJuType = const Value.absent(),
    this.className = const Value.absent(),
    this.parentAnnotationId = const Value.absent(),
    this.parentMajorVersion = const Value.absent(),
    this.relationToParent = const Value.absent(),
    this.referencesJson = const Value.absent(),
    this.relatedConditionSetIdsJson = const Value.absent(),
    this.visibility = const Value.absent(),
    this.locale = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        ruleId = Value(ruleId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<GeJuAnnotationsTableData> custom({
    Expression<String>? id,
    Expression<String>? ruleId,
    Expression<String>? schoolsJson,
    Expression<String>? sourceJson,
    Expression<String>? authorType,
    Expression<String>? version,
    Expression<String>? description,
    Expression<String>? jiXiong,
    Expression<String>? geJuType,
    Expression<String>? className,
    Expression<String>? parentAnnotationId,
    Expression<int>? parentMajorVersion,
    Expression<String>? relationToParent,
    Expression<String>? referencesJson,
    Expression<String>? relatedConditionSetIdsJson,
    Expression<String>? visibility,
    Expression<String>? locale,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ruleId != null) 'rule_id': ruleId,
      if (schoolsJson != null) 'schools_json': schoolsJson,
      if (sourceJson != null) 'source_json': sourceJson,
      if (authorType != null) 'author_type': authorType,
      if (version != null) 'version': version,
      if (description != null) 'description': description,
      if (jiXiong != null) 'ji_xiong': jiXiong,
      if (geJuType != null) 'ge_ju_type': geJuType,
      if (className != null) 'class_name': className,
      if (parentAnnotationId != null)
        'parent_annotation_id': parentAnnotationId,
      if (parentMajorVersion != null)
        'parent_major_version': parentMajorVersion,
      if (relationToParent != null) 'relation_to_parent': relationToParent,
      if (referencesJson != null) 'references_json': referencesJson,
      if (relatedConditionSetIdsJson != null)
        'related_condition_set_ids_json': relatedConditionSetIdsJson,
      if (visibility != null) 'visibility': visibility,
      if (locale != null) 'locale': locale,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GeJuAnnotationsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? ruleId,
      Value<String?>? schoolsJson,
      Value<String?>? sourceJson,
      Value<String>? authorType,
      Value<String>? version,
      Value<String?>? description,
      Value<String?>? jiXiong,
      Value<String?>? geJuType,
      Value<String?>? className,
      Value<String?>? parentAnnotationId,
      Value<int?>? parentMajorVersion,
      Value<String?>? relationToParent,
      Value<String>? referencesJson,
      Value<String>? relatedConditionSetIdsJson,
      Value<String>? visibility,
      Value<String>? locale,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return GeJuAnnotationsTableCompanion(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      schoolsJson: schoolsJson ?? this.schoolsJson,
      sourceJson: sourceJson ?? this.sourceJson,
      authorType: authorType ?? this.authorType,
      version: version ?? this.version,
      description: description ?? this.description,
      jiXiong: jiXiong ?? this.jiXiong,
      geJuType: geJuType ?? this.geJuType,
      className: className ?? this.className,
      parentAnnotationId: parentAnnotationId ?? this.parentAnnotationId,
      parentMajorVersion: parentMajorVersion ?? this.parentMajorVersion,
      relationToParent: relationToParent ?? this.relationToParent,
      referencesJson: referencesJson ?? this.referencesJson,
      relatedConditionSetIdsJson:
          relatedConditionSetIdsJson ?? this.relatedConditionSetIdsJson,
      visibility: visibility ?? this.visibility,
      locale: locale ?? this.locale,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<String>(ruleId.value);
    }
    if (schoolsJson.present) {
      map['schools_json'] = Variable<String>(schoolsJson.value);
    }
    if (sourceJson.present) {
      map['source_json'] = Variable<String>(sourceJson.value);
    }
    if (authorType.present) {
      map['author_type'] = Variable<String>(authorType.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (jiXiong.present) {
      map['ji_xiong'] = Variable<String>(jiXiong.value);
    }
    if (geJuType.present) {
      map['ge_ju_type'] = Variable<String>(geJuType.value);
    }
    if (className.present) {
      map['class_name'] = Variable<String>(className.value);
    }
    if (parentAnnotationId.present) {
      map['parent_annotation_id'] = Variable<String>(parentAnnotationId.value);
    }
    if (parentMajorVersion.present) {
      map['parent_major_version'] = Variable<int>(parentMajorVersion.value);
    }
    if (relationToParent.present) {
      map['relation_to_parent'] = Variable<String>(relationToParent.value);
    }
    if (referencesJson.present) {
      map['references_json'] = Variable<String>(referencesJson.value);
    }
    if (relatedConditionSetIdsJson.present) {
      map['related_condition_set_ids_json'] =
          Variable<String>(relatedConditionSetIdsJson.value);
    }
    if (visibility.present) {
      map['visibility'] = Variable<String>(visibility.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeJuAnnotationsTableCompanion(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('schoolsJson: $schoolsJson, ')
          ..write('sourceJson: $sourceJson, ')
          ..write('authorType: $authorType, ')
          ..write('version: $version, ')
          ..write('description: $description, ')
          ..write('jiXiong: $jiXiong, ')
          ..write('geJuType: $geJuType, ')
          ..write('className: $className, ')
          ..write('parentAnnotationId: $parentAnnotationId, ')
          ..write('parentMajorVersion: $parentMajorVersion, ')
          ..write('relationToParent: $relationToParent, ')
          ..write('referencesJson: $referencesJson, ')
          ..write('relatedConditionSetIdsJson: $relatedConditionSetIdsJson, ')
          ..write('visibility: $visibility, ')
          ..write('locale: $locale, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GeJuConditionSetsTableTable extends GeJuConditionSetsTable
    with TableInfo<$GeJuConditionSetsTableTable, GeJuConditionSetsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeJuConditionSetsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id =
      GeneratedColumn<String>('id', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<String> ruleId = GeneratedColumn<String>(
      'rule_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _schoolsJsonMeta =
      const VerificationMeta('schoolsJson');
  @override
  late final GeneratedColumn<String> schoolsJson = GeneratedColumn<String>(
      'schools_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceJsonMeta =
      const VerificationMeta('sourceJson');
  @override
  late final GeneratedColumn<String> sourceJson = GeneratedColumn<String>(
      'source_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _authorTypeMeta =
      const VerificationMeta('authorType');
  @override
  late final GeneratedColumn<String> authorType = GeneratedColumn<String>(
      'author_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('user'));
  static const VerificationMeta _conditionsJsonMeta =
      const VerificationMeta('conditionsJson');
  @override
  late final GeneratedColumn<String> conditionsJson = GeneratedColumn<String>(
      'conditions_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _derivedFromMeta =
      const VerificationMeta('derivedFrom');
  @override
  late final GeneratedColumn<String> derivedFrom = GeneratedColumn<String>(
      'derived_from', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _changeNoteMeta =
      const VerificationMeta('changeNote');
  @override
  late final GeneratedColumn<String> changeNote = GeneratedColumn<String>(
      'change_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _relatedAnnotationIdsJsonMeta =
      const VerificationMeta('relatedAnnotationIdsJson');
  @override
  late final GeneratedColumn<String> relatedAnnotationIdsJson =
      GeneratedColumn<String>('related_annotation_ids_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _visibilityMeta =
      const VerificationMeta('visibility');
  @override
  late final GeneratedColumn<String> visibility = GeneratedColumn<String>(
      'visibility', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('private'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        ruleId,
        label,
        schoolsJson,
        sourceJson,
        authorType,
        conditionsJson,
        derivedFrom,
        changeNote,
        relatedAnnotationIdsJson,
        visibility,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_ge_ju_condition_sets';
  @override
  VerificationContext validateIntegrity(
      Insertable<GeJuConditionSetsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('rule_id')) {
      context.handle(_ruleIdMeta,
          ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta));
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('schools_json')) {
      context.handle(
          _schoolsJsonMeta,
          schoolsJson.isAcceptableOrUnknown(
              data['schools_json']!, _schoolsJsonMeta));
    }
    if (data.containsKey('source_json')) {
      context.handle(
          _sourceJsonMeta,
          sourceJson.isAcceptableOrUnknown(
              data['source_json']!, _sourceJsonMeta));
    }
    if (data.containsKey('author_type')) {
      context.handle(
          _authorTypeMeta,
          authorType.isAcceptableOrUnknown(
              data['author_type']!, _authorTypeMeta));
    }
    if (data.containsKey('conditions_json')) {
      context.handle(
          _conditionsJsonMeta,
          conditionsJson.isAcceptableOrUnknown(
              data['conditions_json']!, _conditionsJsonMeta));
    }
    if (data.containsKey('derived_from')) {
      context.handle(
          _derivedFromMeta,
          derivedFrom.isAcceptableOrUnknown(
              data['derived_from']!, _derivedFromMeta));
    }
    if (data.containsKey('change_note')) {
      context.handle(
          _changeNoteMeta,
          changeNote.isAcceptableOrUnknown(
              data['change_note']!, _changeNoteMeta));
    }
    if (data.containsKey('related_annotation_ids_json')) {
      context.handle(
          _relatedAnnotationIdsJsonMeta,
          relatedAnnotationIdsJson.isAcceptableOrUnknown(
              data['related_annotation_ids_json']!,
              _relatedAnnotationIdsJsonMeta));
    }
    if (data.containsKey('visibility')) {
      context.handle(
          _visibilityMeta,
          visibility.isAcceptableOrUnknown(
              data['visibility']!, _visibilityMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeJuConditionSetsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeJuConditionSetsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      ruleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rule_id'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      schoolsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}schools_json']),
      sourceJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_json']),
      authorType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author_type'])!,
      conditionsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}conditions_json']),
      derivedFrom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}derived_from']),
      changeNote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}change_note']),
      relatedAnnotationIdsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}related_annotation_ids_json'])!,
      visibility: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}visibility'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $GeJuConditionSetsTableTable createAlias(String alias) {
    return $GeJuConditionSetsTableTable(attachedDatabase, alias);
  }
}

class GeJuConditionSetsTableData extends DataClass
    implements Insertable<GeJuConditionSetsTableData> {
  final String id;
  final String ruleId;
  final String label;

  /// JSON: List<String>?
  final String? schoolsJson;

  /// JSON: GeJuSource?
  final String? sourceJson;
  final String authorType;

  /// JSON: GeJuCondition?
  final String? conditionsJson;
  final String? derivedFrom;
  final String? changeNote;

  /// JSON: List<String>
  final String relatedAnnotationIdsJson;
  final String visibility;
  final DateTime createdAt;
  final DateTime updatedAt;
  const GeJuConditionSetsTableData(
      {required this.id,
      required this.ruleId,
      required this.label,
      this.schoolsJson,
      this.sourceJson,
      required this.authorType,
      this.conditionsJson,
      this.derivedFrom,
      this.changeNote,
      required this.relatedAnnotationIdsJson,
      required this.visibility,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['rule_id'] = Variable<String>(ruleId);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || schoolsJson != null) {
      map['schools_json'] = Variable<String>(schoolsJson);
    }
    if (!nullToAbsent || sourceJson != null) {
      map['source_json'] = Variable<String>(sourceJson);
    }
    map['author_type'] = Variable<String>(authorType);
    if (!nullToAbsent || conditionsJson != null) {
      map['conditions_json'] = Variable<String>(conditionsJson);
    }
    if (!nullToAbsent || derivedFrom != null) {
      map['derived_from'] = Variable<String>(derivedFrom);
    }
    if (!nullToAbsent || changeNote != null) {
      map['change_note'] = Variable<String>(changeNote);
    }
    map['related_annotation_ids_json'] =
        Variable<String>(relatedAnnotationIdsJson);
    map['visibility'] = Variable<String>(visibility);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GeJuConditionSetsTableCompanion toCompanion(bool nullToAbsent) {
    return GeJuConditionSetsTableCompanion(
      id: Value(id),
      ruleId: Value(ruleId),
      label: Value(label),
      schoolsJson: schoolsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(schoolsJson),
      sourceJson: sourceJson == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceJson),
      authorType: Value(authorType),
      conditionsJson: conditionsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(conditionsJson),
      derivedFrom: derivedFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(derivedFrom),
      changeNote: changeNote == null && nullToAbsent
          ? const Value.absent()
          : Value(changeNote),
      relatedAnnotationIdsJson: Value(relatedAnnotationIdsJson),
      visibility: Value(visibility),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory GeJuConditionSetsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeJuConditionSetsTableData(
      id: serializer.fromJson<String>(json['id']),
      ruleId: serializer.fromJson<String>(json['ruleId']),
      label: serializer.fromJson<String>(json['label']),
      schoolsJson: serializer.fromJson<String?>(json['schoolsJson']),
      sourceJson: serializer.fromJson<String?>(json['sourceJson']),
      authorType: serializer.fromJson<String>(json['authorType']),
      conditionsJson: serializer.fromJson<String?>(json['conditionsJson']),
      derivedFrom: serializer.fromJson<String?>(json['derivedFrom']),
      changeNote: serializer.fromJson<String?>(json['changeNote']),
      relatedAnnotationIdsJson:
          serializer.fromJson<String>(json['relatedAnnotationIdsJson']),
      visibility: serializer.fromJson<String>(json['visibility']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ruleId': serializer.toJson<String>(ruleId),
      'label': serializer.toJson<String>(label),
      'schoolsJson': serializer.toJson<String?>(schoolsJson),
      'sourceJson': serializer.toJson<String?>(sourceJson),
      'authorType': serializer.toJson<String>(authorType),
      'conditionsJson': serializer.toJson<String?>(conditionsJson),
      'derivedFrom': serializer.toJson<String?>(derivedFrom),
      'changeNote': serializer.toJson<String?>(changeNote),
      'relatedAnnotationIdsJson':
          serializer.toJson<String>(relatedAnnotationIdsJson),
      'visibility': serializer.toJson<String>(visibility),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GeJuConditionSetsTableData copyWith(
          {String? id,
          String? ruleId,
          String? label,
          Value<String?> schoolsJson = const Value.absent(),
          Value<String?> sourceJson = const Value.absent(),
          String? authorType,
          Value<String?> conditionsJson = const Value.absent(),
          Value<String?> derivedFrom = const Value.absent(),
          Value<String?> changeNote = const Value.absent(),
          String? relatedAnnotationIdsJson,
          String? visibility,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      GeJuConditionSetsTableData(
        id: id ?? this.id,
        ruleId: ruleId ?? this.ruleId,
        label: label ?? this.label,
        schoolsJson: schoolsJson.present ? schoolsJson.value : this.schoolsJson,
        sourceJson: sourceJson.present ? sourceJson.value : this.sourceJson,
        authorType: authorType ?? this.authorType,
        conditionsJson:
            conditionsJson.present ? conditionsJson.value : this.conditionsJson,
        derivedFrom: derivedFrom.present ? derivedFrom.value : this.derivedFrom,
        changeNote: changeNote.present ? changeNote.value : this.changeNote,
        relatedAnnotationIdsJson:
            relatedAnnotationIdsJson ?? this.relatedAnnotationIdsJson,
        visibility: visibility ?? this.visibility,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  GeJuConditionSetsTableData copyWithCompanion(
      GeJuConditionSetsTableCompanion data) {
    return GeJuConditionSetsTableData(
      id: data.id.present ? data.id.value : this.id,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      label: data.label.present ? data.label.value : this.label,
      schoolsJson:
          data.schoolsJson.present ? data.schoolsJson.value : this.schoolsJson,
      sourceJson:
          data.sourceJson.present ? data.sourceJson.value : this.sourceJson,
      authorType:
          data.authorType.present ? data.authorType.value : this.authorType,
      conditionsJson: data.conditionsJson.present
          ? data.conditionsJson.value
          : this.conditionsJson,
      derivedFrom:
          data.derivedFrom.present ? data.derivedFrom.value : this.derivedFrom,
      changeNote:
          data.changeNote.present ? data.changeNote.value : this.changeNote,
      relatedAnnotationIdsJson: data.relatedAnnotationIdsJson.present
          ? data.relatedAnnotationIdsJson.value
          : this.relatedAnnotationIdsJson,
      visibility:
          data.visibility.present ? data.visibility.value : this.visibility,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeJuConditionSetsTableData(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('label: $label, ')
          ..write('schoolsJson: $schoolsJson, ')
          ..write('sourceJson: $sourceJson, ')
          ..write('authorType: $authorType, ')
          ..write('conditionsJson: $conditionsJson, ')
          ..write('derivedFrom: $derivedFrom, ')
          ..write('changeNote: $changeNote, ')
          ..write('relatedAnnotationIdsJson: $relatedAnnotationIdsJson, ')
          ..write('visibility: $visibility, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      ruleId,
      label,
      schoolsJson,
      sourceJson,
      authorType,
      conditionsJson,
      derivedFrom,
      changeNote,
      relatedAnnotationIdsJson,
      visibility,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeJuConditionSetsTableData &&
          other.id == this.id &&
          other.ruleId == this.ruleId &&
          other.label == this.label &&
          other.schoolsJson == this.schoolsJson &&
          other.sourceJson == this.sourceJson &&
          other.authorType == this.authorType &&
          other.conditionsJson == this.conditionsJson &&
          other.derivedFrom == this.derivedFrom &&
          other.changeNote == this.changeNote &&
          other.relatedAnnotationIdsJson == this.relatedAnnotationIdsJson &&
          other.visibility == this.visibility &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GeJuConditionSetsTableCompanion
    extends UpdateCompanion<GeJuConditionSetsTableData> {
  final Value<String> id;
  final Value<String> ruleId;
  final Value<String> label;
  final Value<String?> schoolsJson;
  final Value<String?> sourceJson;
  final Value<String> authorType;
  final Value<String?> conditionsJson;
  final Value<String?> derivedFrom;
  final Value<String?> changeNote;
  final Value<String> relatedAnnotationIdsJson;
  final Value<String> visibility;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const GeJuConditionSetsTableCompanion({
    this.id = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.label = const Value.absent(),
    this.schoolsJson = const Value.absent(),
    this.sourceJson = const Value.absent(),
    this.authorType = const Value.absent(),
    this.conditionsJson = const Value.absent(),
    this.derivedFrom = const Value.absent(),
    this.changeNote = const Value.absent(),
    this.relatedAnnotationIdsJson = const Value.absent(),
    this.visibility = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GeJuConditionSetsTableCompanion.insert({
    required String id,
    required String ruleId,
    required String label,
    this.schoolsJson = const Value.absent(),
    this.sourceJson = const Value.absent(),
    this.authorType = const Value.absent(),
    this.conditionsJson = const Value.absent(),
    this.derivedFrom = const Value.absent(),
    this.changeNote = const Value.absent(),
    this.relatedAnnotationIdsJson = const Value.absent(),
    this.visibility = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        ruleId = Value(ruleId),
        label = Value(label),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<GeJuConditionSetsTableData> custom({
    Expression<String>? id,
    Expression<String>? ruleId,
    Expression<String>? label,
    Expression<String>? schoolsJson,
    Expression<String>? sourceJson,
    Expression<String>? authorType,
    Expression<String>? conditionsJson,
    Expression<String>? derivedFrom,
    Expression<String>? changeNote,
    Expression<String>? relatedAnnotationIdsJson,
    Expression<String>? visibility,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ruleId != null) 'rule_id': ruleId,
      if (label != null) 'label': label,
      if (schoolsJson != null) 'schools_json': schoolsJson,
      if (sourceJson != null) 'source_json': sourceJson,
      if (authorType != null) 'author_type': authorType,
      if (conditionsJson != null) 'conditions_json': conditionsJson,
      if (derivedFrom != null) 'derived_from': derivedFrom,
      if (changeNote != null) 'change_note': changeNote,
      if (relatedAnnotationIdsJson != null)
        'related_annotation_ids_json': relatedAnnotationIdsJson,
      if (visibility != null) 'visibility': visibility,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GeJuConditionSetsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? ruleId,
      Value<String>? label,
      Value<String?>? schoolsJson,
      Value<String?>? sourceJson,
      Value<String>? authorType,
      Value<String?>? conditionsJson,
      Value<String?>? derivedFrom,
      Value<String?>? changeNote,
      Value<String>? relatedAnnotationIdsJson,
      Value<String>? visibility,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return GeJuConditionSetsTableCompanion(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      label: label ?? this.label,
      schoolsJson: schoolsJson ?? this.schoolsJson,
      sourceJson: sourceJson ?? this.sourceJson,
      authorType: authorType ?? this.authorType,
      conditionsJson: conditionsJson ?? this.conditionsJson,
      derivedFrom: derivedFrom ?? this.derivedFrom,
      changeNote: changeNote ?? this.changeNote,
      relatedAnnotationIdsJson:
          relatedAnnotationIdsJson ?? this.relatedAnnotationIdsJson,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<String>(ruleId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (schoolsJson.present) {
      map['schools_json'] = Variable<String>(schoolsJson.value);
    }
    if (sourceJson.present) {
      map['source_json'] = Variable<String>(sourceJson.value);
    }
    if (authorType.present) {
      map['author_type'] = Variable<String>(authorType.value);
    }
    if (conditionsJson.present) {
      map['conditions_json'] = Variable<String>(conditionsJson.value);
    }
    if (derivedFrom.present) {
      map['derived_from'] = Variable<String>(derivedFrom.value);
    }
    if (changeNote.present) {
      map['change_note'] = Variable<String>(changeNote.value);
    }
    if (relatedAnnotationIdsJson.present) {
      map['related_annotation_ids_json'] =
          Variable<String>(relatedAnnotationIdsJson.value);
    }
    if (visibility.present) {
      map['visibility'] = Variable<String>(visibility.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeJuConditionSetsTableCompanion(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('label: $label, ')
          ..write('schoolsJson: $schoolsJson, ')
          ..write('sourceJson: $sourceJson, ')
          ..write('authorType: $authorType, ')
          ..write('conditionsJson: $conditionsJson, ')
          ..write('derivedFrom: $derivedFrom, ')
          ..write('changeNote: $changeNote, ')
          ..write('relatedAnnotationIdsJson: $relatedAnnotationIdsJson, ')
          ..write('visibility: $visibility, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GeJuUserPreferencesTableTable extends GeJuUserPreferencesTable
    with
        TableInfo<$GeJuUserPreferencesTableTable,
            GeJuUserPreferencesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeJuUserPreferencesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('default'));
  static const VerificationMeta _hiddenConditionSetIdsJsonMeta =
      const VerificationMeta('hiddenConditionSetIdsJson');
  @override
  late final GeneratedColumn<String> hiddenConditionSetIdsJson =
      GeneratedColumn<String>(
          'hidden_condition_set_ids_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _conditionSetSchoolsJsonMeta =
      const VerificationMeta('conditionSetSchoolsJson');
  @override
  late final GeneratedColumn<String> conditionSetSchoolsJson =
      GeneratedColumn<String>('condition_set_schools_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _hiddenAnnotationIdsJsonMeta =
      const VerificationMeta('hiddenAnnotationIdsJson');
  @override
  late final GeneratedColumn<String> hiddenAnnotationIdsJson =
      GeneratedColumn<String>('hidden_annotation_ids_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _annotationSchoolsJsonMeta =
      const VerificationMeta('annotationSchoolsJson');
  @override
  late final GeneratedColumn<String> annotationSchoolsJson =
      GeneratedColumn<String>('annotation_schools_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        hiddenConditionSetIdsJson,
        conditionSetSchoolsJson,
        hiddenAnnotationIdsJson,
        annotationSchoolsJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_ge_ju_user_preferences';
  @override
  VerificationContext validateIntegrity(
      Insertable<GeJuUserPreferencesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('hidden_condition_set_ids_json')) {
      context.handle(
          _hiddenConditionSetIdsJsonMeta,
          hiddenConditionSetIdsJson.isAcceptableOrUnknown(
              data['hidden_condition_set_ids_json']!,
              _hiddenConditionSetIdsJsonMeta));
    }
    if (data.containsKey('condition_set_schools_json')) {
      context.handle(
          _conditionSetSchoolsJsonMeta,
          conditionSetSchoolsJson.isAcceptableOrUnknown(
              data['condition_set_schools_json']!,
              _conditionSetSchoolsJsonMeta));
    }
    if (data.containsKey('hidden_annotation_ids_json')) {
      context.handle(
          _hiddenAnnotationIdsJsonMeta,
          hiddenAnnotationIdsJson.isAcceptableOrUnknown(
              data['hidden_annotation_ids_json']!,
              _hiddenAnnotationIdsJsonMeta));
    }
    if (data.containsKey('annotation_schools_json')) {
      context.handle(
          _annotationSchoolsJsonMeta,
          annotationSchoolsJson.isAcceptableOrUnknown(
              data['annotation_schools_json']!, _annotationSchoolsJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeJuUserPreferencesTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeJuUserPreferencesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      hiddenConditionSetIdsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}hidden_condition_set_ids_json'])!,
      conditionSetSchoolsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}condition_set_schools_json']),
      hiddenAnnotationIdsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}hidden_annotation_ids_json'])!,
      annotationSchoolsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}annotation_schools_json']),
    );
  }

  @override
  $GeJuUserPreferencesTableTable createAlias(String alias) {
    return $GeJuUserPreferencesTableTable(attachedDatabase, alias);
  }
}

class GeJuUserPreferencesTableData extends DataClass
    implements Insertable<GeJuUserPreferencesTableData> {
  /// 固定为 'default'
  final String id;

  /// JSON: List<String>
  final String hiddenConditionSetIdsJson;

  /// JSON: List<String>?
  final String? conditionSetSchoolsJson;

  /// JSON: List<String>
  final String hiddenAnnotationIdsJson;

  /// JSON: List<String>?
  final String? annotationSchoolsJson;
  const GeJuUserPreferencesTableData(
      {required this.id,
      required this.hiddenConditionSetIdsJson,
      this.conditionSetSchoolsJson,
      required this.hiddenAnnotationIdsJson,
      this.annotationSchoolsJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hidden_condition_set_ids_json'] =
        Variable<String>(hiddenConditionSetIdsJson);
    if (!nullToAbsent || conditionSetSchoolsJson != null) {
      map['condition_set_schools_json'] =
          Variable<String>(conditionSetSchoolsJson);
    }
    map['hidden_annotation_ids_json'] =
        Variable<String>(hiddenAnnotationIdsJson);
    if (!nullToAbsent || annotationSchoolsJson != null) {
      map['annotation_schools_json'] = Variable<String>(annotationSchoolsJson);
    }
    return map;
  }

  GeJuUserPreferencesTableCompanion toCompanion(bool nullToAbsent) {
    return GeJuUserPreferencesTableCompanion(
      id: Value(id),
      hiddenConditionSetIdsJson: Value(hiddenConditionSetIdsJson),
      conditionSetSchoolsJson: conditionSetSchoolsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(conditionSetSchoolsJson),
      hiddenAnnotationIdsJson: Value(hiddenAnnotationIdsJson),
      annotationSchoolsJson: annotationSchoolsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(annotationSchoolsJson),
    );
  }

  factory GeJuUserPreferencesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeJuUserPreferencesTableData(
      id: serializer.fromJson<String>(json['id']),
      hiddenConditionSetIdsJson:
          serializer.fromJson<String>(json['hiddenConditionSetIdsJson']),
      conditionSetSchoolsJson:
          serializer.fromJson<String?>(json['conditionSetSchoolsJson']),
      hiddenAnnotationIdsJson:
          serializer.fromJson<String>(json['hiddenAnnotationIdsJson']),
      annotationSchoolsJson:
          serializer.fromJson<String?>(json['annotationSchoolsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hiddenConditionSetIdsJson':
          serializer.toJson<String>(hiddenConditionSetIdsJson),
      'conditionSetSchoolsJson':
          serializer.toJson<String?>(conditionSetSchoolsJson),
      'hiddenAnnotationIdsJson':
          serializer.toJson<String>(hiddenAnnotationIdsJson),
      'annotationSchoolsJson':
          serializer.toJson<String?>(annotationSchoolsJson),
    };
  }

  GeJuUserPreferencesTableData copyWith(
          {String? id,
          String? hiddenConditionSetIdsJson,
          Value<String?> conditionSetSchoolsJson = const Value.absent(),
          String? hiddenAnnotationIdsJson,
          Value<String?> annotationSchoolsJson = const Value.absent()}) =>
      GeJuUserPreferencesTableData(
        id: id ?? this.id,
        hiddenConditionSetIdsJson:
            hiddenConditionSetIdsJson ?? this.hiddenConditionSetIdsJson,
        conditionSetSchoolsJson: conditionSetSchoolsJson.present
            ? conditionSetSchoolsJson.value
            : this.conditionSetSchoolsJson,
        hiddenAnnotationIdsJson:
            hiddenAnnotationIdsJson ?? this.hiddenAnnotationIdsJson,
        annotationSchoolsJson: annotationSchoolsJson.present
            ? annotationSchoolsJson.value
            : this.annotationSchoolsJson,
      );
  GeJuUserPreferencesTableData copyWithCompanion(
      GeJuUserPreferencesTableCompanion data) {
    return GeJuUserPreferencesTableData(
      id: data.id.present ? data.id.value : this.id,
      hiddenConditionSetIdsJson: data.hiddenConditionSetIdsJson.present
          ? data.hiddenConditionSetIdsJson.value
          : this.hiddenConditionSetIdsJson,
      conditionSetSchoolsJson: data.conditionSetSchoolsJson.present
          ? data.conditionSetSchoolsJson.value
          : this.conditionSetSchoolsJson,
      hiddenAnnotationIdsJson: data.hiddenAnnotationIdsJson.present
          ? data.hiddenAnnotationIdsJson.value
          : this.hiddenAnnotationIdsJson,
      annotationSchoolsJson: data.annotationSchoolsJson.present
          ? data.annotationSchoolsJson.value
          : this.annotationSchoolsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeJuUserPreferencesTableData(')
          ..write('id: $id, ')
          ..write('hiddenConditionSetIdsJson: $hiddenConditionSetIdsJson, ')
          ..write('conditionSetSchoolsJson: $conditionSetSchoolsJson, ')
          ..write('hiddenAnnotationIdsJson: $hiddenAnnotationIdsJson, ')
          ..write('annotationSchoolsJson: $annotationSchoolsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, hiddenConditionSetIdsJson,
      conditionSetSchoolsJson, hiddenAnnotationIdsJson, annotationSchoolsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeJuUserPreferencesTableData &&
          other.id == this.id &&
          other.hiddenConditionSetIdsJson == this.hiddenConditionSetIdsJson &&
          other.conditionSetSchoolsJson == this.conditionSetSchoolsJson &&
          other.hiddenAnnotationIdsJson == this.hiddenAnnotationIdsJson &&
          other.annotationSchoolsJson == this.annotationSchoolsJson);
}

class GeJuUserPreferencesTableCompanion
    extends UpdateCompanion<GeJuUserPreferencesTableData> {
  final Value<String> id;
  final Value<String> hiddenConditionSetIdsJson;
  final Value<String?> conditionSetSchoolsJson;
  final Value<String> hiddenAnnotationIdsJson;
  final Value<String?> annotationSchoolsJson;
  final Value<int> rowid;
  const GeJuUserPreferencesTableCompanion({
    this.id = const Value.absent(),
    this.hiddenConditionSetIdsJson = const Value.absent(),
    this.conditionSetSchoolsJson = const Value.absent(),
    this.hiddenAnnotationIdsJson = const Value.absent(),
    this.annotationSchoolsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GeJuUserPreferencesTableCompanion.insert({
    this.id = const Value.absent(),
    this.hiddenConditionSetIdsJson = const Value.absent(),
    this.conditionSetSchoolsJson = const Value.absent(),
    this.hiddenAnnotationIdsJson = const Value.absent(),
    this.annotationSchoolsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<GeJuUserPreferencesTableData> custom({
    Expression<String>? id,
    Expression<String>? hiddenConditionSetIdsJson,
    Expression<String>? conditionSetSchoolsJson,
    Expression<String>? hiddenAnnotationIdsJson,
    Expression<String>? annotationSchoolsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hiddenConditionSetIdsJson != null)
        'hidden_condition_set_ids_json': hiddenConditionSetIdsJson,
      if (conditionSetSchoolsJson != null)
        'condition_set_schools_json': conditionSetSchoolsJson,
      if (hiddenAnnotationIdsJson != null)
        'hidden_annotation_ids_json': hiddenAnnotationIdsJson,
      if (annotationSchoolsJson != null)
        'annotation_schools_json': annotationSchoolsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GeJuUserPreferencesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? hiddenConditionSetIdsJson,
      Value<String?>? conditionSetSchoolsJson,
      Value<String>? hiddenAnnotationIdsJson,
      Value<String?>? annotationSchoolsJson,
      Value<int>? rowid}) {
    return GeJuUserPreferencesTableCompanion(
      id: id ?? this.id,
      hiddenConditionSetIdsJson:
          hiddenConditionSetIdsJson ?? this.hiddenConditionSetIdsJson,
      conditionSetSchoolsJson:
          conditionSetSchoolsJson ?? this.conditionSetSchoolsJson,
      hiddenAnnotationIdsJson:
          hiddenAnnotationIdsJson ?? this.hiddenAnnotationIdsJson,
      annotationSchoolsJson:
          annotationSchoolsJson ?? this.annotationSchoolsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hiddenConditionSetIdsJson.present) {
      map['hidden_condition_set_ids_json'] =
          Variable<String>(hiddenConditionSetIdsJson.value);
    }
    if (conditionSetSchoolsJson.present) {
      map['condition_set_schools_json'] =
          Variable<String>(conditionSetSchoolsJson.value);
    }
    if (hiddenAnnotationIdsJson.present) {
      map['hidden_annotation_ids_json'] =
          Variable<String>(hiddenAnnotationIdsJson.value);
    }
    if (annotationSchoolsJson.present) {
      map['annotation_schools_json'] =
          Variable<String>(annotationSchoolsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeJuUserPreferencesTableCompanion(')
          ..write('id: $id, ')
          ..write('hiddenConditionSetIdsJson: $hiddenConditionSetIdsJson, ')
          ..write('conditionSetSchoolsJson: $conditionSetSchoolsJson, ')
          ..write('hiddenAnnotationIdsJson: $hiddenAnnotationIdsJson, ')
          ..write('annotationSchoolsJson: $annotationSchoolsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GeJuDeletionRecordsTableTable extends GeJuDeletionRecordsTable
    with
        TableInfo<$GeJuDeletionRecordsTableTable,
            GeJuDeletionRecordsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeJuDeletionRecordsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id =
      GeneratedColumn<String>('id', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _deletedEntityTypeMeta =
      const VerificationMeta('deletedEntityType');
  @override
  late final GeneratedColumn<String> deletedEntityType =
      GeneratedColumn<String>('deleted_entity_type', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deletedEntityIdMeta =
      const VerificationMeta('deletedEntityId');
  @override
  late final GeneratedColumn<String> deletedEntityId = GeneratedColumn<String>(
      'deleted_entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _snapshotJsonMeta =
      const VerificationMeta('snapshotJson');
  @override
  late final GeneratedColumn<String> snapshotJson = GeneratedColumn<String>(
      'snapshot_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, deletedEntityType, deletedEntityId, deletedAt, reason, snapshotJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_ge_ju_deletion_records';
  @override
  VerificationContext validateIntegrity(
      Insertable<GeJuDeletionRecordsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('deleted_entity_type')) {
      context.handle(
          _deletedEntityTypeMeta,
          deletedEntityType.isAcceptableOrUnknown(
              data['deleted_entity_type']!, _deletedEntityTypeMeta));
    } else if (isInserting) {
      context.missing(_deletedEntityTypeMeta);
    }
    if (data.containsKey('deleted_entity_id')) {
      context.handle(
          _deletedEntityIdMeta,
          deletedEntityId.isAcceptableOrUnknown(
              data['deleted_entity_id']!, _deletedEntityIdMeta));
    } else if (isInserting) {
      context.missing(_deletedEntityIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    } else if (isInserting) {
      context.missing(_deletedAtMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('snapshot_json')) {
      context.handle(
          _snapshotJsonMeta,
          snapshotJson.isAcceptableOrUnknown(
              data['snapshot_json']!, _snapshotJsonMeta));
    } else if (isInserting) {
      context.missing(_snapshotJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeJuDeletionRecordsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeJuDeletionRecordsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      deletedEntityType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}deleted_entity_type'])!,
      deletedEntityId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}deleted_entity_id'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason'])!,
      snapshotJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}snapshot_json'])!,
    );
  }

  @override
  $GeJuDeletionRecordsTableTable createAlias(String alias) {
    return $GeJuDeletionRecordsTableTable(attachedDatabase, alias);
  }
}

class GeJuDeletionRecordsTableData extends DataClass
    implements Insertable<GeJuDeletionRecordsTableData> {
  final String id;
  final String deletedEntityType;
  final String deletedEntityId;
  final DateTime deletedAt;
  final String reason;
  final String snapshotJson;
  const GeJuDeletionRecordsTableData(
      {required this.id,
      required this.deletedEntityType,
      required this.deletedEntityId,
      required this.deletedAt,
      required this.reason,
      required this.snapshotJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['deleted_entity_type'] = Variable<String>(deletedEntityType);
    map['deleted_entity_id'] = Variable<String>(deletedEntityId);
    map['deleted_at'] = Variable<DateTime>(deletedAt);
    map['reason'] = Variable<String>(reason);
    map['snapshot_json'] = Variable<String>(snapshotJson);
    return map;
  }

  GeJuDeletionRecordsTableCompanion toCompanion(bool nullToAbsent) {
    return GeJuDeletionRecordsTableCompanion(
      id: Value(id),
      deletedEntityType: Value(deletedEntityType),
      deletedEntityId: Value(deletedEntityId),
      deletedAt: Value(deletedAt),
      reason: Value(reason),
      snapshotJson: Value(snapshotJson),
    );
  }

  factory GeJuDeletionRecordsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeJuDeletionRecordsTableData(
      id: serializer.fromJson<String>(json['id']),
      deletedEntityType: serializer.fromJson<String>(json['deletedEntityType']),
      deletedEntityId: serializer.fromJson<String>(json['deletedEntityId']),
      deletedAt: serializer.fromJson<DateTime>(json['deletedAt']),
      reason: serializer.fromJson<String>(json['reason']),
      snapshotJson: serializer.fromJson<String>(json['snapshotJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deletedEntityType': serializer.toJson<String>(deletedEntityType),
      'deletedEntityId': serializer.toJson<String>(deletedEntityId),
      'deletedAt': serializer.toJson<DateTime>(deletedAt),
      'reason': serializer.toJson<String>(reason),
      'snapshotJson': serializer.toJson<String>(snapshotJson),
    };
  }

  GeJuDeletionRecordsTableData copyWith(
          {String? id,
          String? deletedEntityType,
          String? deletedEntityId,
          DateTime? deletedAt,
          String? reason,
          String? snapshotJson}) =>
      GeJuDeletionRecordsTableData(
        id: id ?? this.id,
        deletedEntityType: deletedEntityType ?? this.deletedEntityType,
        deletedEntityId: deletedEntityId ?? this.deletedEntityId,
        deletedAt: deletedAt ?? this.deletedAt,
        reason: reason ?? this.reason,
        snapshotJson: snapshotJson ?? this.snapshotJson,
      );
  GeJuDeletionRecordsTableData copyWithCompanion(
      GeJuDeletionRecordsTableCompanion data) {
    return GeJuDeletionRecordsTableData(
      id: data.id.present ? data.id.value : this.id,
      deletedEntityType: data.deletedEntityType.present
          ? data.deletedEntityType.value
          : this.deletedEntityType,
      deletedEntityId: data.deletedEntityId.present
          ? data.deletedEntityId.value
          : this.deletedEntityId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      reason: data.reason.present ? data.reason.value : this.reason,
      snapshotJson: data.snapshotJson.present
          ? data.snapshotJson.value
          : this.snapshotJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeJuDeletionRecordsTableData(')
          ..write('id: $id, ')
          ..write('deletedEntityType: $deletedEntityType, ')
          ..write('deletedEntityId: $deletedEntityId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('reason: $reason, ')
          ..write('snapshotJson: $snapshotJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, deletedEntityType, deletedEntityId, deletedAt, reason, snapshotJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeJuDeletionRecordsTableData &&
          other.id == this.id &&
          other.deletedEntityType == this.deletedEntityType &&
          other.deletedEntityId == this.deletedEntityId &&
          other.deletedAt == this.deletedAt &&
          other.reason == this.reason &&
          other.snapshotJson == this.snapshotJson);
}

class GeJuDeletionRecordsTableCompanion
    extends UpdateCompanion<GeJuDeletionRecordsTableData> {
  final Value<String> id;
  final Value<String> deletedEntityType;
  final Value<String> deletedEntityId;
  final Value<DateTime> deletedAt;
  final Value<String> reason;
  final Value<String> snapshotJson;
  final Value<int> rowid;
  const GeJuDeletionRecordsTableCompanion({
    this.id = const Value.absent(),
    this.deletedEntityType = const Value.absent(),
    this.deletedEntityId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.reason = const Value.absent(),
    this.snapshotJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GeJuDeletionRecordsTableCompanion.insert({
    required String id,
    required String deletedEntityType,
    required String deletedEntityId,
    required DateTime deletedAt,
    required String reason,
    required String snapshotJson,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deletedEntityType = Value(deletedEntityType),
        deletedEntityId = Value(deletedEntityId),
        deletedAt = Value(deletedAt),
        reason = Value(reason),
        snapshotJson = Value(snapshotJson);
  static Insertable<GeJuDeletionRecordsTableData> custom({
    Expression<String>? id,
    Expression<String>? deletedEntityType,
    Expression<String>? deletedEntityId,
    Expression<DateTime>? deletedAt,
    Expression<String>? reason,
    Expression<String>? snapshotJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deletedEntityType != null) 'deleted_entity_type': deletedEntityType,
      if (deletedEntityId != null) 'deleted_entity_id': deletedEntityId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (reason != null) 'reason': reason,
      if (snapshotJson != null) 'snapshot_json': snapshotJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GeJuDeletionRecordsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? deletedEntityType,
      Value<String>? deletedEntityId,
      Value<DateTime>? deletedAt,
      Value<String>? reason,
      Value<String>? snapshotJson,
      Value<int>? rowid}) {
    return GeJuDeletionRecordsTableCompanion(
      id: id ?? this.id,
      deletedEntityType: deletedEntityType ?? this.deletedEntityType,
      deletedEntityId: deletedEntityId ?? this.deletedEntityId,
      deletedAt: deletedAt ?? this.deletedAt,
      reason: reason ?? this.reason,
      snapshotJson: snapshotJson ?? this.snapshotJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deletedEntityType.present) {
      map['deleted_entity_type'] = Variable<String>(deletedEntityType.value);
    }
    if (deletedEntityId.present) {
      map['deleted_entity_id'] = Variable<String>(deletedEntityId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (snapshotJson.present) {
      map['snapshot_json'] = Variable<String>(snapshotJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeJuDeletionRecordsTableCompanion(')
          ..write('id: $id, ')
          ..write('deletedEntityType: $deletedEntityType, ')
          ..write('deletedEntityId: $deletedEntityId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('reason: $reason, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GeJuSchoolsTableTable extends GeJuSchoolsTable
    with TableInfo<$GeJuSchoolsTableTable, GeJuSchoolsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeJuSchoolsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id =
      GeneratedColumn<String>('id', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _briefMeta = const VerificationMeta('brief');
  @override
  late final GeneratedColumn<String> brief = GeneratedColumn<String>(
      'brief', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _featuresJsonMeta =
      const VerificationMeta('featuresJson');
  @override
  late final GeneratedColumn<String> featuresJson = GeneratedColumn<String>(
      'features_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  @override
  List<GeneratedColumn> get $columns => [id, name, brief, featuresJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_ge_ju_schools';
  @override
  VerificationContext validateIntegrity(
      Insertable<GeJuSchoolsTableData> instance,
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
    if (data.containsKey('brief')) {
      context.handle(
          _briefMeta, brief.isAcceptableOrUnknown(data['brief']!, _briefMeta));
    }
    if (data.containsKey('features_json')) {
      context.handle(
          _featuresJsonMeta,
          featuresJson.isAcceptableOrUnknown(
              data['features_json']!, _featuresJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeJuSchoolsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeJuSchoolsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      brief: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brief']),
      featuresJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}features_json'])!,
    );
  }

  @override
  $GeJuSchoolsTableTable createAlias(String alias) {
    return $GeJuSchoolsTableTable(attachedDatabase, alias);
  }
}

class GeJuSchoolsTableData extends DataClass
    implements Insertable<GeJuSchoolsTableData> {
  final String id;
  final String name;
  final String? brief;

  /// JSON: List<String>
  final String featuresJson;
  const GeJuSchoolsTableData(
      {required this.id,
      required this.name,
      this.brief,
      required this.featuresJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brief != null) {
      map['brief'] = Variable<String>(brief);
    }
    map['features_json'] = Variable<String>(featuresJson);
    return map;
  }

  GeJuSchoolsTableCompanion toCompanion(bool nullToAbsent) {
    return GeJuSchoolsTableCompanion(
      id: Value(id),
      name: Value(name),
      brief:
          brief == null && nullToAbsent ? const Value.absent() : Value(brief),
      featuresJson: Value(featuresJson),
    );
  }

  factory GeJuSchoolsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeJuSchoolsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      brief: serializer.fromJson<String?>(json['brief']),
      featuresJson: serializer.fromJson<String>(json['featuresJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'brief': serializer.toJson<String?>(brief),
      'featuresJson': serializer.toJson<String>(featuresJson),
    };
  }

  GeJuSchoolsTableData copyWith(
          {String? id,
          String? name,
          Value<String?> brief = const Value.absent(),
          String? featuresJson}) =>
      GeJuSchoolsTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        brief: brief.present ? brief.value : this.brief,
        featuresJson: featuresJson ?? this.featuresJson,
      );
  GeJuSchoolsTableData copyWithCompanion(GeJuSchoolsTableCompanion data) {
    return GeJuSchoolsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      brief: data.brief.present ? data.brief.value : this.brief,
      featuresJson: data.featuresJson.present
          ? data.featuresJson.value
          : this.featuresJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeJuSchoolsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brief: $brief, ')
          ..write('featuresJson: $featuresJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, brief, featuresJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeJuSchoolsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.brief == this.brief &&
          other.featuresJson == this.featuresJson);
}

class GeJuSchoolsTableCompanion extends UpdateCompanion<GeJuSchoolsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> brief;
  final Value<String> featuresJson;
  final Value<int> rowid;
  const GeJuSchoolsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.brief = const Value.absent(),
    this.featuresJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GeJuSchoolsTableCompanion.insert({
    required String id,
    required String name,
    this.brief = const Value.absent(),
    this.featuresJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<GeJuSchoolsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? brief,
    Expression<String>? featuresJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (brief != null) 'brief': brief,
      if (featuresJson != null) 'features_json': featuresJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GeJuSchoolsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? brief,
      Value<String>? featuresJson,
      Value<int>? rowid}) {
    return GeJuSchoolsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      brief: brief ?? this.brief,
      featuresJson: featuresJson ?? this.featuresJson,
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
    if (brief.present) {
      map['brief'] = Variable<String>(brief.value);
    }
    if (featuresJson.present) {
      map['features_json'] = Variable<String>(featuresJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeJuSchoolsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brief: $brief, ')
          ..write('featuresJson: $featuresJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $QizhengsiyuPanTableTable qizhengsiyuPanTable =
      $QizhengsiyuPanTableTable(this);
  late final $GeJuRulesTableTable geJuRulesTable = $GeJuRulesTableTable(this);
  late final $GeJuAnnotationsTableTable geJuAnnotationsTable =
      $GeJuAnnotationsTableTable(this);
  late final $GeJuConditionSetsTableTable geJuConditionSetsTable =
      $GeJuConditionSetsTableTable(this);
  late final $GeJuUserPreferencesTableTable geJuUserPreferencesTable =
      $GeJuUserPreferencesTableTable(this);
  late final $GeJuDeletionRecordsTableTable geJuDeletionRecordsTable =
      $GeJuDeletionRecordsTableTable(this);
  late final $GeJuSchoolsTableTable geJuSchoolsTable =
      $GeJuSchoolsTableTable(this);
  late final QiZhengSiYuPanDao qiZhengSiYuPanDao =
      QiZhengSiYuPanDao(this as AppDatabase);
  late final GeJuDao geJuDao = GeJuDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        qizhengsiyuPanTable,
        geJuRulesTable,
        geJuAnnotationsTable,
        geJuConditionSetsTable,
        geJuUserPreferencesTable,
        geJuDeletionRecordsTable,
        geJuSchoolsTable
      ];
}

typedef $$QizhengsiyuPanTableTableCreateCompanionBuilder
    = QizhengsiyuPanTableCompanion Function({
  required String uuid,
  required DateTime createdAt,
  required DateTime lastUpdatedAt,
  Value<DateTime?> deletedAt,
  required String divinationRequestInfoUuid,
  required BasePanelConfig panelConfig,
  required BasePanelModel panelModel,
  required DivinationDatetimeModel divinationDatetimeModel,
  Value<int> rowid,
});
typedef $$QizhengsiyuPanTableTableUpdateCompanionBuilder
    = QizhengsiyuPanTableCompanion Function({
  Value<String> uuid,
  Value<DateTime> createdAt,
  Value<DateTime> lastUpdatedAt,
  Value<DateTime?> deletedAt,
  Value<String> divinationRequestInfoUuid,
  Value<BasePanelConfig> panelConfig,
  Value<BasePanelModel> panelModel,
  Value<DivinationDatetimeModel> divinationDatetimeModel,
  Value<int> rowid,
});

class $$QizhengsiyuPanTableTableFilterComposer
    extends Composer<_$AppDatabase, $QizhengsiyuPanTableTable> {
  $$QizhengsiyuPanTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get divinationRequestInfoUuid => $composableBuilder(
      column: $table.divinationRequestInfoUuid,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<BasePanelConfig, BasePanelConfig, String>
      get panelConfig => $composableBuilder(
          column: $table.panelConfig,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<BasePanelModel, BasePanelModel, String>
      get panelModel => $composableBuilder(
          column: $table.panelModel,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DivinationDatetimeModel,
          DivinationDatetimeModel, String>
      get divinationDatetimeModel => $composableBuilder(
          column: $table.divinationDatetimeModel,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$QizhengsiyuPanTableTableOrderingComposer
    extends Composer<_$AppDatabase, $QizhengsiyuPanTableTable> {
  $$QizhengsiyuPanTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get divinationRequestInfoUuid => $composableBuilder(
      column: $table.divinationRequestInfoUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get panelConfig => $composableBuilder(
      column: $table.panelConfig, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get panelModel => $composableBuilder(
      column: $table.panelModel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get divinationDatetimeModel => $composableBuilder(
      column: $table.divinationDatetimeModel,
      builder: (column) => ColumnOrderings(column));
}

class $$QizhengsiyuPanTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $QizhengsiyuPanTableTable> {
  $$QizhengsiyuPanTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedAt => $composableBuilder(
      column: $table.lastUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get divinationRequestInfoUuid => $composableBuilder(
      column: $table.divinationRequestInfoUuid, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BasePanelConfig, String> get panelConfig =>
      $composableBuilder(
          column: $table.panelConfig, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BasePanelModel, String> get panelModel =>
      $composableBuilder(
          column: $table.panelModel, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DivinationDatetimeModel, String>
      get divinationDatetimeModel => $composableBuilder(
          column: $table.divinationDatetimeModel, builder: (column) => column);
}

class $$QizhengsiyuPanTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QizhengsiyuPanTableTable,
    QiZhengSiYuPanEntity,
    $$QizhengsiyuPanTableTableFilterComposer,
    $$QizhengsiyuPanTableTableOrderingComposer,
    $$QizhengsiyuPanTableTableAnnotationComposer,
    $$QizhengsiyuPanTableTableCreateCompanionBuilder,
    $$QizhengsiyuPanTableTableUpdateCompanionBuilder,
    (
      QiZhengSiYuPanEntity,
      BaseReferences<_$AppDatabase, $QizhengsiyuPanTableTable,
          QiZhengSiYuPanEntity>
    ),
    QiZhengSiYuPanEntity,
    PrefetchHooks Function()> {
  $$QizhengsiyuPanTableTableTableManager(
      _$AppDatabase db, $QizhengsiyuPanTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QizhengsiyuPanTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QizhengsiyuPanTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QizhengsiyuPanTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastUpdatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> divinationRequestInfoUuid = const Value.absent(),
            Value<BasePanelConfig> panelConfig = const Value.absent(),
            Value<BasePanelModel> panelModel = const Value.absent(),
            Value<DivinationDatetimeModel> divinationDatetimeModel =
                const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QizhengsiyuPanTableCompanion(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            divinationRequestInfoUuid: divinationRequestInfoUuid,
            panelConfig: panelConfig,
            panelModel: panelModel,
            divinationDatetimeModel: divinationDatetimeModel,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required DateTime createdAt,
            required DateTime lastUpdatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required String divinationRequestInfoUuid,
            required BasePanelConfig panelConfig,
            required BasePanelModel panelModel,
            required DivinationDatetimeModel divinationDatetimeModel,
            Value<int> rowid = const Value.absent(),
          }) =>
              QizhengsiyuPanTableCompanion.insert(
            uuid: uuid,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt,
            deletedAt: deletedAt,
            divinationRequestInfoUuid: divinationRequestInfoUuid,
            panelConfig: panelConfig,
            panelModel: panelModel,
            divinationDatetimeModel: divinationDatetimeModel,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QizhengsiyuPanTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QizhengsiyuPanTableTable,
    QiZhengSiYuPanEntity,
    $$QizhengsiyuPanTableTableFilterComposer,
    $$QizhengsiyuPanTableTableOrderingComposer,
    $$QizhengsiyuPanTableTableAnnotationComposer,
    $$QizhengsiyuPanTableTableCreateCompanionBuilder,
    $$QizhengsiyuPanTableTableUpdateCompanionBuilder,
    (
      QiZhengSiYuPanEntity,
      BaseReferences<_$AppDatabase, $QizhengsiyuPanTableTable,
          QiZhengSiYuPanEntity>
    ),
    QiZhengSiYuPanEntity,
    PrefetchHooks Function()>;
typedef $$GeJuRulesTableTableCreateCompanionBuilder = GeJuRulesTableCompanion
    Function({
  required String id,
  required String name,
  Value<String> aliasesJson,
  Value<String?> disambiguationNote,
  Value<String> scope,
  Value<String?> coordinateSystem,
  Value<String> authorType,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$GeJuRulesTableTableUpdateCompanionBuilder = GeJuRulesTableCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> aliasesJson,
  Value<String?> disambiguationNote,
  Value<String> scope,
  Value<String?> coordinateSystem,
  Value<String> authorType,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$GeJuRulesTableTableFilterComposer
    extends Composer<_$AppDatabase, $GeJuRulesTableTable> {
  $$GeJuRulesTableTableFilterComposer({
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

  ColumnFilters<String> get aliasesJson => $composableBuilder(
      column: $table.aliasesJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get disambiguationNote => $composableBuilder(
      column: $table.disambiguationNote,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scope => $composableBuilder(
      column: $table.scope, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coordinateSystem => $composableBuilder(
      column: $table.coordinateSystem,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authorType => $composableBuilder(
      column: $table.authorType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$GeJuRulesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GeJuRulesTableTable> {
  $$GeJuRulesTableTableOrderingComposer({
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

  ColumnOrderings<String> get aliasesJson => $composableBuilder(
      column: $table.aliasesJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get disambiguationNote => $composableBuilder(
      column: $table.disambiguationNote,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scope => $composableBuilder(
      column: $table.scope, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coordinateSystem => $composableBuilder(
      column: $table.coordinateSystem,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorType => $composableBuilder(
      column: $table.authorType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$GeJuRulesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GeJuRulesTableTable> {
  $$GeJuRulesTableTableAnnotationComposer({
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

  GeneratedColumn<String> get aliasesJson => $composableBuilder(
      column: $table.aliasesJson, builder: (column) => column);

  GeneratedColumn<String> get disambiguationNote => $composableBuilder(
      column: $table.disambiguationNote, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get coordinateSystem => $composableBuilder(
      column: $table.coordinateSystem, builder: (column) => column);

  GeneratedColumn<String> get authorType => $composableBuilder(
      column: $table.authorType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GeJuRulesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GeJuRulesTableTable,
    GeJuRulesTableData,
    $$GeJuRulesTableTableFilterComposer,
    $$GeJuRulesTableTableOrderingComposer,
    $$GeJuRulesTableTableAnnotationComposer,
    $$GeJuRulesTableTableCreateCompanionBuilder,
    $$GeJuRulesTableTableUpdateCompanionBuilder,
    (
      GeJuRulesTableData,
      BaseReferences<_$AppDatabase, $GeJuRulesTableTable, GeJuRulesTableData>
    ),
    GeJuRulesTableData,
    PrefetchHooks Function()> {
  $$GeJuRulesTableTableTableManager(
      _$AppDatabase db, $GeJuRulesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeJuRulesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GeJuRulesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GeJuRulesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> aliasesJson = const Value.absent(),
            Value<String?> disambiguationNote = const Value.absent(),
            Value<String> scope = const Value.absent(),
            Value<String?> coordinateSystem = const Value.absent(),
            Value<String> authorType = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GeJuRulesTableCompanion(
            id: id,
            name: name,
            aliasesJson: aliasesJson,
            disambiguationNote: disambiguationNote,
            scope: scope,
            coordinateSystem: coordinateSystem,
            authorType: authorType,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> aliasesJson = const Value.absent(),
            Value<String?> disambiguationNote = const Value.absent(),
            Value<String> scope = const Value.absent(),
            Value<String?> coordinateSystem = const Value.absent(),
            Value<String> authorType = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              GeJuRulesTableCompanion.insert(
            id: id,
            name: name,
            aliasesJson: aliasesJson,
            disambiguationNote: disambiguationNote,
            scope: scope,
            coordinateSystem: coordinateSystem,
            authorType: authorType,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GeJuRulesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GeJuRulesTableTable,
    GeJuRulesTableData,
    $$GeJuRulesTableTableFilterComposer,
    $$GeJuRulesTableTableOrderingComposer,
    $$GeJuRulesTableTableAnnotationComposer,
    $$GeJuRulesTableTableCreateCompanionBuilder,
    $$GeJuRulesTableTableUpdateCompanionBuilder,
    (
      GeJuRulesTableData,
      BaseReferences<_$AppDatabase, $GeJuRulesTableTable, GeJuRulesTableData>
    ),
    GeJuRulesTableData,
    PrefetchHooks Function()>;
typedef $$GeJuAnnotationsTableTableCreateCompanionBuilder
    = GeJuAnnotationsTableCompanion Function({
  required String id,
  required String ruleId,
  Value<String?> schoolsJson,
  Value<String?> sourceJson,
  Value<String> authorType,
  Value<String> version,
  Value<String?> description,
  Value<String?> jiXiong,
  Value<String?> geJuType,
  Value<String?> className,
  Value<String?> parentAnnotationId,
  Value<int?> parentMajorVersion,
  Value<String?> relationToParent,
  Value<String> referencesJson,
  Value<String> relatedConditionSetIdsJson,
  Value<String> visibility,
  Value<String> locale,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$GeJuAnnotationsTableTableUpdateCompanionBuilder
    = GeJuAnnotationsTableCompanion Function({
  Value<String> id,
  Value<String> ruleId,
  Value<String?> schoolsJson,
  Value<String?> sourceJson,
  Value<String> authorType,
  Value<String> version,
  Value<String?> description,
  Value<String?> jiXiong,
  Value<String?> geJuType,
  Value<String?> className,
  Value<String?> parentAnnotationId,
  Value<int?> parentMajorVersion,
  Value<String?> relationToParent,
  Value<String> referencesJson,
  Value<String> relatedConditionSetIdsJson,
  Value<String> visibility,
  Value<String> locale,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$GeJuAnnotationsTableTableFilterComposer
    extends Composer<_$AppDatabase, $GeJuAnnotationsTableTable> {
  $$GeJuAnnotationsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ruleId => $composableBuilder(
      column: $table.ruleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get schoolsJson => $composableBuilder(
      column: $table.schoolsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceJson => $composableBuilder(
      column: $table.sourceJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authorType => $composableBuilder(
      column: $table.authorType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jiXiong => $composableBuilder(
      column: $table.jiXiong, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get geJuType => $composableBuilder(
      column: $table.geJuType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get className => $composableBuilder(
      column: $table.className, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentAnnotationId => $composableBuilder(
      column: $table.parentAnnotationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get parentMajorVersion => $composableBuilder(
      column: $table.parentMajorVersion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relationToParent => $composableBuilder(
      column: $table.relationToParent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referencesJson => $composableBuilder(
      column: $table.referencesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relatedConditionSetIdsJson => $composableBuilder(
      column: $table.relatedConditionSetIdsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get visibility => $composableBuilder(
      column: $table.visibility, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locale => $composableBuilder(
      column: $table.locale, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$GeJuAnnotationsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GeJuAnnotationsTableTable> {
  $$GeJuAnnotationsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ruleId => $composableBuilder(
      column: $table.ruleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get schoolsJson => $composableBuilder(
      column: $table.schoolsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceJson => $composableBuilder(
      column: $table.sourceJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorType => $composableBuilder(
      column: $table.authorType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jiXiong => $composableBuilder(
      column: $table.jiXiong, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get geJuType => $composableBuilder(
      column: $table.geJuType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get className => $composableBuilder(
      column: $table.className, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentAnnotationId => $composableBuilder(
      column: $table.parentAnnotationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get parentMajorVersion => $composableBuilder(
      column: $table.parentMajorVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relationToParent => $composableBuilder(
      column: $table.relationToParent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referencesJson => $composableBuilder(
      column: $table.referencesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relatedConditionSetIdsJson => $composableBuilder(
      column: $table.relatedConditionSetIdsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get visibility => $composableBuilder(
      column: $table.visibility, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locale => $composableBuilder(
      column: $table.locale, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$GeJuAnnotationsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GeJuAnnotationsTableTable> {
  $$GeJuAnnotationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ruleId =>
      $composableBuilder(column: $table.ruleId, builder: (column) => column);

  GeneratedColumn<String> get schoolsJson => $composableBuilder(
      column: $table.schoolsJson, builder: (column) => column);

  GeneratedColumn<String> get sourceJson => $composableBuilder(
      column: $table.sourceJson, builder: (column) => column);

  GeneratedColumn<String> get authorType => $composableBuilder(
      column: $table.authorType, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get jiXiong =>
      $composableBuilder(column: $table.jiXiong, builder: (column) => column);

  GeneratedColumn<String> get geJuType =>
      $composableBuilder(column: $table.geJuType, builder: (column) => column);

  GeneratedColumn<String> get className =>
      $composableBuilder(column: $table.className, builder: (column) => column);

  GeneratedColumn<String> get parentAnnotationId => $composableBuilder(
      column: $table.parentAnnotationId, builder: (column) => column);

  GeneratedColumn<int> get parentMajorVersion => $composableBuilder(
      column: $table.parentMajorVersion, builder: (column) => column);

  GeneratedColumn<String> get relationToParent => $composableBuilder(
      column: $table.relationToParent, builder: (column) => column);

  GeneratedColumn<String> get referencesJson => $composableBuilder(
      column: $table.referencesJson, builder: (column) => column);

  GeneratedColumn<String> get relatedConditionSetIdsJson => $composableBuilder(
      column: $table.relatedConditionSetIdsJson, builder: (column) => column);

  GeneratedColumn<String> get visibility => $composableBuilder(
      column: $table.visibility, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GeJuAnnotationsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GeJuAnnotationsTableTable,
    GeJuAnnotationsTableData,
    $$GeJuAnnotationsTableTableFilterComposer,
    $$GeJuAnnotationsTableTableOrderingComposer,
    $$GeJuAnnotationsTableTableAnnotationComposer,
    $$GeJuAnnotationsTableTableCreateCompanionBuilder,
    $$GeJuAnnotationsTableTableUpdateCompanionBuilder,
    (
      GeJuAnnotationsTableData,
      BaseReferences<_$AppDatabase, $GeJuAnnotationsTableTable,
          GeJuAnnotationsTableData>
    ),
    GeJuAnnotationsTableData,
    PrefetchHooks Function()> {
  $$GeJuAnnotationsTableTableTableManager(
      _$AppDatabase db, $GeJuAnnotationsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeJuAnnotationsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GeJuAnnotationsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GeJuAnnotationsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> ruleId = const Value.absent(),
            Value<String?> schoolsJson = const Value.absent(),
            Value<String?> sourceJson = const Value.absent(),
            Value<String> authorType = const Value.absent(),
            Value<String> version = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> jiXiong = const Value.absent(),
            Value<String?> geJuType = const Value.absent(),
            Value<String?> className = const Value.absent(),
            Value<String?> parentAnnotationId = const Value.absent(),
            Value<int?> parentMajorVersion = const Value.absent(),
            Value<String?> relationToParent = const Value.absent(),
            Value<String> referencesJson = const Value.absent(),
            Value<String> relatedConditionSetIdsJson = const Value.absent(),
            Value<String> visibility = const Value.absent(),
            Value<String> locale = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GeJuAnnotationsTableCompanion(
            id: id,
            ruleId: ruleId,
            schoolsJson: schoolsJson,
            sourceJson: sourceJson,
            authorType: authorType,
            version: version,
            description: description,
            jiXiong: jiXiong,
            geJuType: geJuType,
            className: className,
            parentAnnotationId: parentAnnotationId,
            parentMajorVersion: parentMajorVersion,
            relationToParent: relationToParent,
            referencesJson: referencesJson,
            relatedConditionSetIdsJson: relatedConditionSetIdsJson,
            visibility: visibility,
            locale: locale,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String ruleId,
            Value<String?> schoolsJson = const Value.absent(),
            Value<String?> sourceJson = const Value.absent(),
            Value<String> authorType = const Value.absent(),
            Value<String> version = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> jiXiong = const Value.absent(),
            Value<String?> geJuType = const Value.absent(),
            Value<String?> className = const Value.absent(),
            Value<String?> parentAnnotationId = const Value.absent(),
            Value<int?> parentMajorVersion = const Value.absent(),
            Value<String?> relationToParent = const Value.absent(),
            Value<String> referencesJson = const Value.absent(),
            Value<String> relatedConditionSetIdsJson = const Value.absent(),
            Value<String> visibility = const Value.absent(),
            Value<String> locale = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              GeJuAnnotationsTableCompanion.insert(
            id: id,
            ruleId: ruleId,
            schoolsJson: schoolsJson,
            sourceJson: sourceJson,
            authorType: authorType,
            version: version,
            description: description,
            jiXiong: jiXiong,
            geJuType: geJuType,
            className: className,
            parentAnnotationId: parentAnnotationId,
            parentMajorVersion: parentMajorVersion,
            relationToParent: relationToParent,
            referencesJson: referencesJson,
            relatedConditionSetIdsJson: relatedConditionSetIdsJson,
            visibility: visibility,
            locale: locale,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GeJuAnnotationsTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $GeJuAnnotationsTableTable,
        GeJuAnnotationsTableData,
        $$GeJuAnnotationsTableTableFilterComposer,
        $$GeJuAnnotationsTableTableOrderingComposer,
        $$GeJuAnnotationsTableTableAnnotationComposer,
        $$GeJuAnnotationsTableTableCreateCompanionBuilder,
        $$GeJuAnnotationsTableTableUpdateCompanionBuilder,
        (
          GeJuAnnotationsTableData,
          BaseReferences<_$AppDatabase, $GeJuAnnotationsTableTable,
              GeJuAnnotationsTableData>
        ),
        GeJuAnnotationsTableData,
        PrefetchHooks Function()>;
typedef $$GeJuConditionSetsTableTableCreateCompanionBuilder
    = GeJuConditionSetsTableCompanion Function({
  required String id,
  required String ruleId,
  required String label,
  Value<String?> schoolsJson,
  Value<String?> sourceJson,
  Value<String> authorType,
  Value<String?> conditionsJson,
  Value<String?> derivedFrom,
  Value<String?> changeNote,
  Value<String> relatedAnnotationIdsJson,
  Value<String> visibility,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$GeJuConditionSetsTableTableUpdateCompanionBuilder
    = GeJuConditionSetsTableCompanion Function({
  Value<String> id,
  Value<String> ruleId,
  Value<String> label,
  Value<String?> schoolsJson,
  Value<String?> sourceJson,
  Value<String> authorType,
  Value<String?> conditionsJson,
  Value<String?> derivedFrom,
  Value<String?> changeNote,
  Value<String> relatedAnnotationIdsJson,
  Value<String> visibility,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$GeJuConditionSetsTableTableFilterComposer
    extends Composer<_$AppDatabase, $GeJuConditionSetsTableTable> {
  $$GeJuConditionSetsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ruleId => $composableBuilder(
      column: $table.ruleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get schoolsJson => $composableBuilder(
      column: $table.schoolsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceJson => $composableBuilder(
      column: $table.sourceJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authorType => $composableBuilder(
      column: $table.authorType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conditionsJson => $composableBuilder(
      column: $table.conditionsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get derivedFrom => $composableBuilder(
      column: $table.derivedFrom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get changeNote => $composableBuilder(
      column: $table.changeNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relatedAnnotationIdsJson => $composableBuilder(
      column: $table.relatedAnnotationIdsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get visibility => $composableBuilder(
      column: $table.visibility, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$GeJuConditionSetsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GeJuConditionSetsTableTable> {
  $$GeJuConditionSetsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ruleId => $composableBuilder(
      column: $table.ruleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get schoolsJson => $composableBuilder(
      column: $table.schoolsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceJson => $composableBuilder(
      column: $table.sourceJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorType => $composableBuilder(
      column: $table.authorType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conditionsJson => $composableBuilder(
      column: $table.conditionsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get derivedFrom => $composableBuilder(
      column: $table.derivedFrom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get changeNote => $composableBuilder(
      column: $table.changeNote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relatedAnnotationIdsJson => $composableBuilder(
      column: $table.relatedAnnotationIdsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get visibility => $composableBuilder(
      column: $table.visibility, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$GeJuConditionSetsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GeJuConditionSetsTableTable> {
  $$GeJuConditionSetsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ruleId =>
      $composableBuilder(column: $table.ruleId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get schoolsJson => $composableBuilder(
      column: $table.schoolsJson, builder: (column) => column);

  GeneratedColumn<String> get sourceJson => $composableBuilder(
      column: $table.sourceJson, builder: (column) => column);

  GeneratedColumn<String> get authorType => $composableBuilder(
      column: $table.authorType, builder: (column) => column);

  GeneratedColumn<String> get conditionsJson => $composableBuilder(
      column: $table.conditionsJson, builder: (column) => column);

  GeneratedColumn<String> get derivedFrom => $composableBuilder(
      column: $table.derivedFrom, builder: (column) => column);

  GeneratedColumn<String> get changeNote => $composableBuilder(
      column: $table.changeNote, builder: (column) => column);

  GeneratedColumn<String> get relatedAnnotationIdsJson => $composableBuilder(
      column: $table.relatedAnnotationIdsJson, builder: (column) => column);

  GeneratedColumn<String> get visibility => $composableBuilder(
      column: $table.visibility, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GeJuConditionSetsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GeJuConditionSetsTableTable,
    GeJuConditionSetsTableData,
    $$GeJuConditionSetsTableTableFilterComposer,
    $$GeJuConditionSetsTableTableOrderingComposer,
    $$GeJuConditionSetsTableTableAnnotationComposer,
    $$GeJuConditionSetsTableTableCreateCompanionBuilder,
    $$GeJuConditionSetsTableTableUpdateCompanionBuilder,
    (
      GeJuConditionSetsTableData,
      BaseReferences<_$AppDatabase, $GeJuConditionSetsTableTable,
          GeJuConditionSetsTableData>
    ),
    GeJuConditionSetsTableData,
    PrefetchHooks Function()> {
  $$GeJuConditionSetsTableTableTableManager(
      _$AppDatabase db, $GeJuConditionSetsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeJuConditionSetsTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$GeJuConditionSetsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GeJuConditionSetsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> ruleId = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<String?> schoolsJson = const Value.absent(),
            Value<String?> sourceJson = const Value.absent(),
            Value<String> authorType = const Value.absent(),
            Value<String?> conditionsJson = const Value.absent(),
            Value<String?> derivedFrom = const Value.absent(),
            Value<String?> changeNote = const Value.absent(),
            Value<String> relatedAnnotationIdsJson = const Value.absent(),
            Value<String> visibility = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GeJuConditionSetsTableCompanion(
            id: id,
            ruleId: ruleId,
            label: label,
            schoolsJson: schoolsJson,
            sourceJson: sourceJson,
            authorType: authorType,
            conditionsJson: conditionsJson,
            derivedFrom: derivedFrom,
            changeNote: changeNote,
            relatedAnnotationIdsJson: relatedAnnotationIdsJson,
            visibility: visibility,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String ruleId,
            required String label,
            Value<String?> schoolsJson = const Value.absent(),
            Value<String?> sourceJson = const Value.absent(),
            Value<String> authorType = const Value.absent(),
            Value<String?> conditionsJson = const Value.absent(),
            Value<String?> derivedFrom = const Value.absent(),
            Value<String?> changeNote = const Value.absent(),
            Value<String> relatedAnnotationIdsJson = const Value.absent(),
            Value<String> visibility = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              GeJuConditionSetsTableCompanion.insert(
            id: id,
            ruleId: ruleId,
            label: label,
            schoolsJson: schoolsJson,
            sourceJson: sourceJson,
            authorType: authorType,
            conditionsJson: conditionsJson,
            derivedFrom: derivedFrom,
            changeNote: changeNote,
            relatedAnnotationIdsJson: relatedAnnotationIdsJson,
            visibility: visibility,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GeJuConditionSetsTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $GeJuConditionSetsTableTable,
        GeJuConditionSetsTableData,
        $$GeJuConditionSetsTableTableFilterComposer,
        $$GeJuConditionSetsTableTableOrderingComposer,
        $$GeJuConditionSetsTableTableAnnotationComposer,
        $$GeJuConditionSetsTableTableCreateCompanionBuilder,
        $$GeJuConditionSetsTableTableUpdateCompanionBuilder,
        (
          GeJuConditionSetsTableData,
          BaseReferences<_$AppDatabase, $GeJuConditionSetsTableTable,
              GeJuConditionSetsTableData>
        ),
        GeJuConditionSetsTableData,
        PrefetchHooks Function()>;
typedef $$GeJuUserPreferencesTableTableCreateCompanionBuilder
    = GeJuUserPreferencesTableCompanion Function({
  Value<String> id,
  Value<String> hiddenConditionSetIdsJson,
  Value<String?> conditionSetSchoolsJson,
  Value<String> hiddenAnnotationIdsJson,
  Value<String?> annotationSchoolsJson,
  Value<int> rowid,
});
typedef $$GeJuUserPreferencesTableTableUpdateCompanionBuilder
    = GeJuUserPreferencesTableCompanion Function({
  Value<String> id,
  Value<String> hiddenConditionSetIdsJson,
  Value<String?> conditionSetSchoolsJson,
  Value<String> hiddenAnnotationIdsJson,
  Value<String?> annotationSchoolsJson,
  Value<int> rowid,
});

class $$GeJuUserPreferencesTableTableFilterComposer
    extends Composer<_$AppDatabase, $GeJuUserPreferencesTableTable> {
  $$GeJuUserPreferencesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hiddenConditionSetIdsJson => $composableBuilder(
      column: $table.hiddenConditionSetIdsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conditionSetSchoolsJson => $composableBuilder(
      column: $table.conditionSetSchoolsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hiddenAnnotationIdsJson => $composableBuilder(
      column: $table.hiddenAnnotationIdsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get annotationSchoolsJson => $composableBuilder(
      column: $table.annotationSchoolsJson,
      builder: (column) => ColumnFilters(column));
}

class $$GeJuUserPreferencesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GeJuUserPreferencesTableTable> {
  $$GeJuUserPreferencesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hiddenConditionSetIdsJson => $composableBuilder(
      column: $table.hiddenConditionSetIdsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conditionSetSchoolsJson => $composableBuilder(
      column: $table.conditionSetSchoolsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hiddenAnnotationIdsJson => $composableBuilder(
      column: $table.hiddenAnnotationIdsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get annotationSchoolsJson => $composableBuilder(
      column: $table.annotationSchoolsJson,
      builder: (column) => ColumnOrderings(column));
}

class $$GeJuUserPreferencesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GeJuUserPreferencesTableTable> {
  $$GeJuUserPreferencesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hiddenConditionSetIdsJson => $composableBuilder(
      column: $table.hiddenConditionSetIdsJson, builder: (column) => column);

  GeneratedColumn<String> get conditionSetSchoolsJson => $composableBuilder(
      column: $table.conditionSetSchoolsJson, builder: (column) => column);

  GeneratedColumn<String> get hiddenAnnotationIdsJson => $composableBuilder(
      column: $table.hiddenAnnotationIdsJson, builder: (column) => column);

  GeneratedColumn<String> get annotationSchoolsJson => $composableBuilder(
      column: $table.annotationSchoolsJson, builder: (column) => column);
}

class $$GeJuUserPreferencesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GeJuUserPreferencesTableTable,
    GeJuUserPreferencesTableData,
    $$GeJuUserPreferencesTableTableFilterComposer,
    $$GeJuUserPreferencesTableTableOrderingComposer,
    $$GeJuUserPreferencesTableTableAnnotationComposer,
    $$GeJuUserPreferencesTableTableCreateCompanionBuilder,
    $$GeJuUserPreferencesTableTableUpdateCompanionBuilder,
    (
      GeJuUserPreferencesTableData,
      BaseReferences<_$AppDatabase, $GeJuUserPreferencesTableTable,
          GeJuUserPreferencesTableData>
    ),
    GeJuUserPreferencesTableData,
    PrefetchHooks Function()> {
  $$GeJuUserPreferencesTableTableTableManager(
      _$AppDatabase db, $GeJuUserPreferencesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeJuUserPreferencesTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$GeJuUserPreferencesTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GeJuUserPreferencesTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> hiddenConditionSetIdsJson = const Value.absent(),
            Value<String?> conditionSetSchoolsJson = const Value.absent(),
            Value<String> hiddenAnnotationIdsJson = const Value.absent(),
            Value<String?> annotationSchoolsJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GeJuUserPreferencesTableCompanion(
            id: id,
            hiddenConditionSetIdsJson: hiddenConditionSetIdsJson,
            conditionSetSchoolsJson: conditionSetSchoolsJson,
            hiddenAnnotationIdsJson: hiddenAnnotationIdsJson,
            annotationSchoolsJson: annotationSchoolsJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> hiddenConditionSetIdsJson = const Value.absent(),
            Value<String?> conditionSetSchoolsJson = const Value.absent(),
            Value<String> hiddenAnnotationIdsJson = const Value.absent(),
            Value<String?> annotationSchoolsJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GeJuUserPreferencesTableCompanion.insert(
            id: id,
            hiddenConditionSetIdsJson: hiddenConditionSetIdsJson,
            conditionSetSchoolsJson: conditionSetSchoolsJson,
            hiddenAnnotationIdsJson: hiddenAnnotationIdsJson,
            annotationSchoolsJson: annotationSchoolsJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GeJuUserPreferencesTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $GeJuUserPreferencesTableTable,
        GeJuUserPreferencesTableData,
        $$GeJuUserPreferencesTableTableFilterComposer,
        $$GeJuUserPreferencesTableTableOrderingComposer,
        $$GeJuUserPreferencesTableTableAnnotationComposer,
        $$GeJuUserPreferencesTableTableCreateCompanionBuilder,
        $$GeJuUserPreferencesTableTableUpdateCompanionBuilder,
        (
          GeJuUserPreferencesTableData,
          BaseReferences<_$AppDatabase, $GeJuUserPreferencesTableTable,
              GeJuUserPreferencesTableData>
        ),
        GeJuUserPreferencesTableData,
        PrefetchHooks Function()>;
typedef $$GeJuDeletionRecordsTableTableCreateCompanionBuilder
    = GeJuDeletionRecordsTableCompanion Function({
  required String id,
  required String deletedEntityType,
  required String deletedEntityId,
  required DateTime deletedAt,
  required String reason,
  required String snapshotJson,
  Value<int> rowid,
});
typedef $$GeJuDeletionRecordsTableTableUpdateCompanionBuilder
    = GeJuDeletionRecordsTableCompanion Function({
  Value<String> id,
  Value<String> deletedEntityType,
  Value<String> deletedEntityId,
  Value<DateTime> deletedAt,
  Value<String> reason,
  Value<String> snapshotJson,
  Value<int> rowid,
});

class $$GeJuDeletionRecordsTableTableFilterComposer
    extends Composer<_$AppDatabase, $GeJuDeletionRecordsTableTable> {
  $$GeJuDeletionRecordsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedEntityType => $composableBuilder(
      column: $table.deletedEntityType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedEntityId => $composableBuilder(
      column: $table.deletedEntityId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get snapshotJson => $composableBuilder(
      column: $table.snapshotJson, builder: (column) => ColumnFilters(column));
}

class $$GeJuDeletionRecordsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GeJuDeletionRecordsTableTable> {
  $$GeJuDeletionRecordsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedEntityType => $composableBuilder(
      column: $table.deletedEntityType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedEntityId => $composableBuilder(
      column: $table.deletedEntityId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get snapshotJson => $composableBuilder(
      column: $table.snapshotJson,
      builder: (column) => ColumnOrderings(column));
}

class $$GeJuDeletionRecordsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GeJuDeletionRecordsTableTable> {
  $$GeJuDeletionRecordsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deletedEntityType => $composableBuilder(
      column: $table.deletedEntityType, builder: (column) => column);

  GeneratedColumn<String> get deletedEntityId => $composableBuilder(
      column: $table.deletedEntityId, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get snapshotJson => $composableBuilder(
      column: $table.snapshotJson, builder: (column) => column);
}

class $$GeJuDeletionRecordsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GeJuDeletionRecordsTableTable,
    GeJuDeletionRecordsTableData,
    $$GeJuDeletionRecordsTableTableFilterComposer,
    $$GeJuDeletionRecordsTableTableOrderingComposer,
    $$GeJuDeletionRecordsTableTableAnnotationComposer,
    $$GeJuDeletionRecordsTableTableCreateCompanionBuilder,
    $$GeJuDeletionRecordsTableTableUpdateCompanionBuilder,
    (
      GeJuDeletionRecordsTableData,
      BaseReferences<_$AppDatabase, $GeJuDeletionRecordsTableTable,
          GeJuDeletionRecordsTableData>
    ),
    GeJuDeletionRecordsTableData,
    PrefetchHooks Function()> {
  $$GeJuDeletionRecordsTableTableTableManager(
      _$AppDatabase db, $GeJuDeletionRecordsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeJuDeletionRecordsTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$GeJuDeletionRecordsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GeJuDeletionRecordsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> deletedEntityType = const Value.absent(),
            Value<String> deletedEntityId = const Value.absent(),
            Value<DateTime> deletedAt = const Value.absent(),
            Value<String> reason = const Value.absent(),
            Value<String> snapshotJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GeJuDeletionRecordsTableCompanion(
            id: id,
            deletedEntityType: deletedEntityType,
            deletedEntityId: deletedEntityId,
            deletedAt: deletedAt,
            reason: reason,
            snapshotJson: snapshotJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String deletedEntityType,
            required String deletedEntityId,
            required DateTime deletedAt,
            required String reason,
            required String snapshotJson,
            Value<int> rowid = const Value.absent(),
          }) =>
              GeJuDeletionRecordsTableCompanion.insert(
            id: id,
            deletedEntityType: deletedEntityType,
            deletedEntityId: deletedEntityId,
            deletedAt: deletedAt,
            reason: reason,
            snapshotJson: snapshotJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GeJuDeletionRecordsTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $GeJuDeletionRecordsTableTable,
        GeJuDeletionRecordsTableData,
        $$GeJuDeletionRecordsTableTableFilterComposer,
        $$GeJuDeletionRecordsTableTableOrderingComposer,
        $$GeJuDeletionRecordsTableTableAnnotationComposer,
        $$GeJuDeletionRecordsTableTableCreateCompanionBuilder,
        $$GeJuDeletionRecordsTableTableUpdateCompanionBuilder,
        (
          GeJuDeletionRecordsTableData,
          BaseReferences<_$AppDatabase, $GeJuDeletionRecordsTableTable,
              GeJuDeletionRecordsTableData>
        ),
        GeJuDeletionRecordsTableData,
        PrefetchHooks Function()>;
typedef $$GeJuSchoolsTableTableCreateCompanionBuilder
    = GeJuSchoolsTableCompanion Function({
  required String id,
  required String name,
  Value<String?> brief,
  Value<String> featuresJson,
  Value<int> rowid,
});
typedef $$GeJuSchoolsTableTableUpdateCompanionBuilder
    = GeJuSchoolsTableCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> brief,
  Value<String> featuresJson,
  Value<int> rowid,
});

class $$GeJuSchoolsTableTableFilterComposer
    extends Composer<_$AppDatabase, $GeJuSchoolsTableTable> {
  $$GeJuSchoolsTableTableFilterComposer({
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

  ColumnFilters<String> get brief => $composableBuilder(
      column: $table.brief, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get featuresJson => $composableBuilder(
      column: $table.featuresJson, builder: (column) => ColumnFilters(column));
}

class $$GeJuSchoolsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GeJuSchoolsTableTable> {
  $$GeJuSchoolsTableTableOrderingComposer({
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

  ColumnOrderings<String> get brief => $composableBuilder(
      column: $table.brief, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get featuresJson => $composableBuilder(
      column: $table.featuresJson,
      builder: (column) => ColumnOrderings(column));
}

class $$GeJuSchoolsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GeJuSchoolsTableTable> {
  $$GeJuSchoolsTableTableAnnotationComposer({
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

  GeneratedColumn<String> get brief =>
      $composableBuilder(column: $table.brief, builder: (column) => column);

  GeneratedColumn<String> get featuresJson => $composableBuilder(
      column: $table.featuresJson, builder: (column) => column);
}

class $$GeJuSchoolsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GeJuSchoolsTableTable,
    GeJuSchoolsTableData,
    $$GeJuSchoolsTableTableFilterComposer,
    $$GeJuSchoolsTableTableOrderingComposer,
    $$GeJuSchoolsTableTableAnnotationComposer,
    $$GeJuSchoolsTableTableCreateCompanionBuilder,
    $$GeJuSchoolsTableTableUpdateCompanionBuilder,
    (
      GeJuSchoolsTableData,
      BaseReferences<_$AppDatabase, $GeJuSchoolsTableTable,
          GeJuSchoolsTableData>
    ),
    GeJuSchoolsTableData,
    PrefetchHooks Function()> {
  $$GeJuSchoolsTableTableTableManager(
      _$AppDatabase db, $GeJuSchoolsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeJuSchoolsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GeJuSchoolsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GeJuSchoolsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> brief = const Value.absent(),
            Value<String> featuresJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GeJuSchoolsTableCompanion(
            id: id,
            name: name,
            brief: brief,
            featuresJson: featuresJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> brief = const Value.absent(),
            Value<String> featuresJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GeJuSchoolsTableCompanion.insert(
            id: id,
            name: name,
            brief: brief,
            featuresJson: featuresJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GeJuSchoolsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GeJuSchoolsTableTable,
    GeJuSchoolsTableData,
    $$GeJuSchoolsTableTableFilterComposer,
    $$GeJuSchoolsTableTableOrderingComposer,
    $$GeJuSchoolsTableTableAnnotationComposer,
    $$GeJuSchoolsTableTableCreateCompanionBuilder,
    $$GeJuSchoolsTableTableUpdateCompanionBuilder,
    (
      GeJuSchoolsTableData,
      BaseReferences<_$AppDatabase, $GeJuSchoolsTableTable,
          GeJuSchoolsTableData>
    ),
    GeJuSchoolsTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$QizhengsiyuPanTableTableTableManager get qizhengsiyuPanTable =>
      $$QizhengsiyuPanTableTableTableManager(_db, _db.qizhengsiyuPanTable);
  $$GeJuRulesTableTableTableManager get geJuRulesTable =>
      $$GeJuRulesTableTableTableManager(_db, _db.geJuRulesTable);
  $$GeJuAnnotationsTableTableTableManager get geJuAnnotationsTable =>
      $$GeJuAnnotationsTableTableTableManager(_db, _db.geJuAnnotationsTable);
  $$GeJuConditionSetsTableTableTableManager get geJuConditionSetsTable =>
      $$GeJuConditionSetsTableTableTableManager(
          _db, _db.geJuConditionSetsTable);
  $$GeJuUserPreferencesTableTableTableManager get geJuUserPreferencesTable =>
      $$GeJuUserPreferencesTableTableTableManager(
          _db, _db.geJuUserPreferencesTable);
  $$GeJuDeletionRecordsTableTableTableManager get geJuDeletionRecordsTable =>
      $$GeJuDeletionRecordsTableTableTableManager(
          _db, _db.geJuDeletionRecordsTable);
  $$GeJuSchoolsTableTableTableManager get geJuSchoolsTable =>
      $$GeJuSchoolsTableTableTableManager(_db, _db.geJuSchoolsTable);
}
