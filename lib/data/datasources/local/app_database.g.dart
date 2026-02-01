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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $QizhengsiyuPanTableTable qizhengsiyuPanTable =
      $QizhengsiyuPanTableTable(this);
  late final QiZhengSiYuPanDao qiZhengSiYuPanDao =
      QiZhengSiYuPanDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [qizhengsiyuPanTable];
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$QizhengsiyuPanTableTableTableManager get qizhengsiyuPanTable =>
      $$QizhengsiyuPanTableTableTableManager(_db, _db.qizhengsiyuPanTable);
}
