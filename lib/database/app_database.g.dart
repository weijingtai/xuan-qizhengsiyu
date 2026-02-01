// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $StarPositionStatusTableTable extends StarPositionStatusTable
    with
        TableInfo<$StarPositionStatusTableTable,
            StarPositionStatusDatasetModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StarPositionStatusTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _classNameMeta =
      const VerificationMeta('className');
  @override
  late final GeneratedColumn<String> className = GeneratedColumn<String>(
      'class_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<EnumStars, String> star =
      GeneratedColumn<String>('star', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<EnumStars>(
              $StarPositionStatusTableTable.$converterstar);
  @override
  late final GeneratedColumnWithTypeConverter<EnumStarGongPositionStatusType,
      String> starPositionStatusType = GeneratedColumn<String>(
          'star_position_status_type', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true)
      .withConverter<EnumStarGongPositionStatusType>(
          $StarPositionStatusTableTable.$converterstarPositionStatusType);
  @override
  late final GeneratedColumnWithTypeConverter<List<Enum>, String> positionList =
      GeneratedColumn<String>('position_list', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<Enum>>(
              $StarPositionStatusTableTable.$converterpositionList);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String>
      descriptionList = GeneratedColumn<String>(
              'description_list', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<String>?>(
              $StarPositionStatusTableTable.$converterdescriptionListn);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> geJuList =
      GeneratedColumn<String>('ge_ju_list', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<String>?>(
              $StarPositionStatusTableTable.$convertergeJuListn);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        className,
        star,
        starPositionStatusType,
        positionList,
        descriptionList,
        geJuList
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'star_position_status_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<StarPositionStatusDatasetModel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('class_name')) {
      context.handle(_classNameMeta,
          className.isAcceptableOrUnknown(data['class_name']!, _classNameMeta));
    } else if (isInserting) {
      context.missing(_classNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StarPositionStatusDatasetModel map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StarPositionStatusDatasetModel(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      className: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}class_name'])!,
      star: $StarPositionStatusTableTable.$converterstar.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}star'])!),
      starPositionStatusType: $StarPositionStatusTableTable
          .$converterstarPositionStatusType
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}star_position_status_type'])!),
      positionList: $StarPositionStatusTableTable.$converterpositionList
          .fromSql(attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}position_list'])!),
      descriptionList: $StarPositionStatusTableTable.$converterdescriptionListn
          .fromSql(attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}description_list'])),
      geJuList: $StarPositionStatusTableTable.$convertergeJuListn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}ge_ju_list'])),
    );
  }

  @override
  $StarPositionStatusTableTable createAlias(String alias) {
    return $StarPositionStatusTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EnumStars, String, String> $converterstar =
      const EnumNameConverter<EnumStars>(EnumStars.values);
  static JsonTypeConverter2<EnumStarGongPositionStatusType, String, String>
      $converterstarPositionStatusType =
      const EnumNameConverter<EnumStarGongPositionStatusType>(
          EnumStarGongPositionStatusType.values);
  static TypeConverter<List<Enum>, String> $converterpositionList =
      const PositionListConverter();
  static TypeConverter<List<String>, String> $converterdescriptionList =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterdescriptionListn =
      NullAwareTypeConverter.wrap($converterdescriptionList);
  static TypeConverter<List<String>, String> $convertergeJuList =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $convertergeJuListn =
      NullAwareTypeConverter.wrap($convertergeJuList);
}

class StarPositionStatusDatasetModel extends DataClass
    implements Insertable<StarPositionStatusDatasetModel> {
  final int id;
  final String className;
  final EnumStars star;
  final EnumStarGongPositionStatusType starPositionStatusType;
  final List<Enum> positionList;
  final List<String>? descriptionList;
  final List<String>? geJuList;
  const StarPositionStatusDatasetModel(
      {required this.id,
      required this.className,
      required this.star,
      required this.starPositionStatusType,
      required this.positionList,
      this.descriptionList,
      this.geJuList});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['class_name'] = Variable<String>(className);
    {
      map['star'] = Variable<String>(
          $StarPositionStatusTableTable.$converterstar.toSql(star));
    }
    {
      map['star_position_status_type'] = Variable<String>(
          $StarPositionStatusTableTable.$converterstarPositionStatusType
              .toSql(starPositionStatusType));
    }
    {
      map['position_list'] = Variable<String>($StarPositionStatusTableTable
          .$converterpositionList
          .toSql(positionList));
    }
    if (!nullToAbsent || descriptionList != null) {
      map['description_list'] = Variable<String>($StarPositionStatusTableTable
          .$converterdescriptionListn
          .toSql(descriptionList));
    }
    if (!nullToAbsent || geJuList != null) {
      map['ge_ju_list'] = Variable<String>(
          $StarPositionStatusTableTable.$convertergeJuListn.toSql(geJuList));
    }
    return map;
  }

  StarPositionStatusTableCompanion toCompanion(bool nullToAbsent) {
    return StarPositionStatusTableCompanion(
      id: Value(id),
      className: Value(className),
      star: Value(star),
      starPositionStatusType: Value(starPositionStatusType),
      positionList: Value(positionList),
      descriptionList: descriptionList == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionList),
      geJuList: geJuList == null && nullToAbsent
          ? const Value.absent()
          : Value(geJuList),
    );
  }

  factory StarPositionStatusDatasetModel.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StarPositionStatusDatasetModel(
      id: serializer.fromJson<int>(json['id']),
      className: serializer.fromJson<String>(json['className']),
      star: $StarPositionStatusTableTable.$converterstar
          .fromJson(serializer.fromJson<String>(json['star'])),
      starPositionStatusType: $StarPositionStatusTableTable
          .$converterstarPositionStatusType
          .fromJson(
              serializer.fromJson<String>(json['starPositionStatusType'])),
      positionList: serializer.fromJson<List<Enum>>(json['positionList']),
      descriptionList:
          serializer.fromJson<List<String>?>(json['descriptionList']),
      geJuList: serializer.fromJson<List<String>?>(json['geJuList']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'className': serializer.toJson<String>(className),
      'star': serializer.toJson<String>(
          $StarPositionStatusTableTable.$converterstar.toJson(star)),
      'starPositionStatusType': serializer.toJson<String>(
          $StarPositionStatusTableTable.$converterstarPositionStatusType
              .toJson(starPositionStatusType)),
      'positionList': serializer.toJson<List<Enum>>(positionList),
      'descriptionList': serializer.toJson<List<String>?>(descriptionList),
      'geJuList': serializer.toJson<List<String>?>(geJuList),
    };
  }

  StarPositionStatusDatasetModel copyWith(
          {int? id,
          String? className,
          EnumStars? star,
          EnumStarGongPositionStatusType? starPositionStatusType,
          List<Enum>? positionList,
          Value<List<String>?> descriptionList = const Value.absent(),
          Value<List<String>?> geJuList = const Value.absent()}) =>
      StarPositionStatusDatasetModel(
        id: id ?? this.id,
        className: className ?? this.className,
        star: star ?? this.star,
        starPositionStatusType:
            starPositionStatusType ?? this.starPositionStatusType,
        positionList: positionList ?? this.positionList,
        descriptionList: descriptionList.present
            ? descriptionList.value
            : this.descriptionList,
        geJuList: geJuList.present ? geJuList.value : this.geJuList,
      );
  StarPositionStatusDatasetModel copyWithCompanion(
      StarPositionStatusTableCompanion data) {
    return StarPositionStatusDatasetModel(
      id: data.id.present ? data.id.value : this.id,
      className: data.className.present ? data.className.value : this.className,
      star: data.star.present ? data.star.value : this.star,
      starPositionStatusType: data.starPositionStatusType.present
          ? data.starPositionStatusType.value
          : this.starPositionStatusType,
      positionList: data.positionList.present
          ? data.positionList.value
          : this.positionList,
      descriptionList: data.descriptionList.present
          ? data.descriptionList.value
          : this.descriptionList,
      geJuList: data.geJuList.present ? data.geJuList.value : this.geJuList,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StarPositionStatusDatasetModel(')
          ..write('id: $id, ')
          ..write('className: $className, ')
          ..write('star: $star, ')
          ..write('starPositionStatusType: $starPositionStatusType, ')
          ..write('positionList: $positionList, ')
          ..write('descriptionList: $descriptionList, ')
          ..write('geJuList: $geJuList')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, className, star, starPositionStatusType,
      positionList, descriptionList, geJuList);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StarPositionStatusDatasetModel &&
          other.id == this.id &&
          other.className == this.className &&
          other.star == this.star &&
          other.starPositionStatusType == this.starPositionStatusType &&
          other.positionList == this.positionList &&
          other.descriptionList == this.descriptionList &&
          other.geJuList == this.geJuList);
}

class StarPositionStatusTableCompanion
    extends UpdateCompanion<StarPositionStatusDatasetModel> {
  final Value<int> id;
  final Value<String> className;
  final Value<EnumStars> star;
  final Value<EnumStarGongPositionStatusType> starPositionStatusType;
  final Value<List<Enum>> positionList;
  final Value<List<String>?> descriptionList;
  final Value<List<String>?> geJuList;
  const StarPositionStatusTableCompanion({
    this.id = const Value.absent(),
    this.className = const Value.absent(),
    this.star = const Value.absent(),
    this.starPositionStatusType = const Value.absent(),
    this.positionList = const Value.absent(),
    this.descriptionList = const Value.absent(),
    this.geJuList = const Value.absent(),
  });
  StarPositionStatusTableCompanion.insert({
    this.id = const Value.absent(),
    required String className,
    required EnumStars star,
    required EnumStarGongPositionStatusType starPositionStatusType,
    required List<Enum> positionList,
    this.descriptionList = const Value.absent(),
    this.geJuList = const Value.absent(),
  })  : className = Value(className),
        star = Value(star),
        starPositionStatusType = Value(starPositionStatusType),
        positionList = Value(positionList);
  static Insertable<StarPositionStatusDatasetModel> custom({
    Expression<int>? id,
    Expression<String>? className,
    Expression<String>? star,
    Expression<String>? starPositionStatusType,
    Expression<String>? positionList,
    Expression<String>? descriptionList,
    Expression<String>? geJuList,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (className != null) 'class_name': className,
      if (star != null) 'star': star,
      if (starPositionStatusType != null)
        'star_position_status_type': starPositionStatusType,
      if (positionList != null) 'position_list': positionList,
      if (descriptionList != null) 'description_list': descriptionList,
      if (geJuList != null) 'ge_ju_list': geJuList,
    });
  }

  StarPositionStatusTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? className,
      Value<EnumStars>? star,
      Value<EnumStarGongPositionStatusType>? starPositionStatusType,
      Value<List<Enum>>? positionList,
      Value<List<String>?>? descriptionList,
      Value<List<String>?>? geJuList}) {
    return StarPositionStatusTableCompanion(
      id: id ?? this.id,
      className: className ?? this.className,
      star: star ?? this.star,
      starPositionStatusType:
          starPositionStatusType ?? this.starPositionStatusType,
      positionList: positionList ?? this.positionList,
      descriptionList: descriptionList ?? this.descriptionList,
      geJuList: geJuList ?? this.geJuList,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (className.present) {
      map['class_name'] = Variable<String>(className.value);
    }
    if (star.present) {
      map['star'] = Variable<String>(
          $StarPositionStatusTableTable.$converterstar.toSql(star.value));
    }
    if (starPositionStatusType.present) {
      map['star_position_status_type'] = Variable<String>(
          $StarPositionStatusTableTable.$converterstarPositionStatusType
              .toSql(starPositionStatusType.value));
    }
    if (positionList.present) {
      map['position_list'] = Variable<String>($StarPositionStatusTableTable
          .$converterpositionList
          .toSql(positionList.value));
    }
    if (descriptionList.present) {
      map['description_list'] = Variable<String>($StarPositionStatusTableTable
          .$converterdescriptionListn
          .toSql(descriptionList.value));
    }
    if (geJuList.present) {
      map['ge_ju_list'] = Variable<String>($StarPositionStatusTableTable
          .$convertergeJuListn
          .toSql(geJuList.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StarPositionStatusTableCompanion(')
          ..write('id: $id, ')
          ..write('className: $className, ')
          ..write('star: $star, ')
          ..write('starPositionStatusType: $starPositionStatusType, ')
          ..write('positionList: $positionList, ')
          ..write('descriptionList: $descriptionList, ')
          ..write('geJuList: $geJuList')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StarPositionStatusTableTable starPositionStatusTable =
      $StarPositionStatusTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [starPositionStatusTable];
}

typedef $$StarPositionStatusTableTableCreateCompanionBuilder
    = StarPositionStatusTableCompanion Function({
  Value<int> id,
  required String className,
  required EnumStars star,
  required EnumStarGongPositionStatusType starPositionStatusType,
  required List<Enum> positionList,
  Value<List<String>?> descriptionList,
  Value<List<String>?> geJuList,
});
typedef $$StarPositionStatusTableTableUpdateCompanionBuilder
    = StarPositionStatusTableCompanion Function({
  Value<int> id,
  Value<String> className,
  Value<EnumStars> star,
  Value<EnumStarGongPositionStatusType> starPositionStatusType,
  Value<List<Enum>> positionList,
  Value<List<String>?> descriptionList,
  Value<List<String>?> geJuList,
});

class $$StarPositionStatusTableTableFilterComposer
    extends Composer<_$AppDatabase, $StarPositionStatusTableTable> {
  $$StarPositionStatusTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get className => $composableBuilder(
      column: $table.className, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<EnumStars, EnumStars, String> get star =>
      $composableBuilder(
          column: $table.star,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<EnumStarGongPositionStatusType,
          EnumStarGongPositionStatusType, String>
      get starPositionStatusType => $composableBuilder(
          column: $table.starPositionStatusType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<List<Enum>, List<Enum>, String>
      get positionList => $composableBuilder(
          column: $table.positionList,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
      get descriptionList => $composableBuilder(
          column: $table.descriptionList,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
      get geJuList => $composableBuilder(
          column: $table.geJuList,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$StarPositionStatusTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StarPositionStatusTableTable> {
  $$StarPositionStatusTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get className => $composableBuilder(
      column: $table.className, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get star => $composableBuilder(
      column: $table.star, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get starPositionStatusType => $composableBuilder(
      column: $table.starPositionStatusType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get positionList => $composableBuilder(
      column: $table.positionList,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descriptionList => $composableBuilder(
      column: $table.descriptionList,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get geJuList => $composableBuilder(
      column: $table.geJuList, builder: (column) => ColumnOrderings(column));
}

class $$StarPositionStatusTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StarPositionStatusTableTable> {
  $$StarPositionStatusTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get className =>
      $composableBuilder(column: $table.className, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EnumStars, String> get star =>
      $composableBuilder(column: $table.star, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EnumStarGongPositionStatusType, String>
      get starPositionStatusType => $composableBuilder(
          column: $table.starPositionStatusType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<Enum>, String> get positionList =>
      $composableBuilder(
          column: $table.positionList, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get descriptionList =>
      $composableBuilder(
          column: $table.descriptionList, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get geJuList =>
      $composableBuilder(column: $table.geJuList, builder: (column) => column);
}

class $$StarPositionStatusTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StarPositionStatusTableTable,
    StarPositionStatusDatasetModel,
    $$StarPositionStatusTableTableFilterComposer,
    $$StarPositionStatusTableTableOrderingComposer,
    $$StarPositionStatusTableTableAnnotationComposer,
    $$StarPositionStatusTableTableCreateCompanionBuilder,
    $$StarPositionStatusTableTableUpdateCompanionBuilder,
    (
      StarPositionStatusDatasetModel,
      BaseReferences<_$AppDatabase, $StarPositionStatusTableTable,
          StarPositionStatusDatasetModel>
    ),
    StarPositionStatusDatasetModel,
    PrefetchHooks Function()> {
  $$StarPositionStatusTableTableTableManager(
      _$AppDatabase db, $StarPositionStatusTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StarPositionStatusTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$StarPositionStatusTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StarPositionStatusTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> className = const Value.absent(),
            Value<EnumStars> star = const Value.absent(),
            Value<EnumStarGongPositionStatusType> starPositionStatusType =
                const Value.absent(),
            Value<List<Enum>> positionList = const Value.absent(),
            Value<List<String>?> descriptionList = const Value.absent(),
            Value<List<String>?> geJuList = const Value.absent(),
          }) =>
              StarPositionStatusTableCompanion(
            id: id,
            className: className,
            star: star,
            starPositionStatusType: starPositionStatusType,
            positionList: positionList,
            descriptionList: descriptionList,
            geJuList: geJuList,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String className,
            required EnumStars star,
            required EnumStarGongPositionStatusType starPositionStatusType,
            required List<Enum> positionList,
            Value<List<String>?> descriptionList = const Value.absent(),
            Value<List<String>?> geJuList = const Value.absent(),
          }) =>
              StarPositionStatusTableCompanion.insert(
            id: id,
            className: className,
            star: star,
            starPositionStatusType: starPositionStatusType,
            positionList: positionList,
            descriptionList: descriptionList,
            geJuList: geJuList,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StarPositionStatusTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $StarPositionStatusTableTable,
        StarPositionStatusDatasetModel,
        $$StarPositionStatusTableTableFilterComposer,
        $$StarPositionStatusTableTableOrderingComposer,
        $$StarPositionStatusTableTableAnnotationComposer,
        $$StarPositionStatusTableTableCreateCompanionBuilder,
        $$StarPositionStatusTableTableUpdateCompanionBuilder,
        (
          StarPositionStatusDatasetModel,
          BaseReferences<_$AppDatabase, $StarPositionStatusTableTable,
              StarPositionStatusDatasetModel>
        ),
        StarPositionStatusDatasetModel,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StarPositionStatusTableTableTableManager get starPositionStatusTable =>
      $$StarPositionStatusTableTableTableManager(
          _db, _db.starPositionStatusTable);
}
