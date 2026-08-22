import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/datamodel/divination_request_info_datamodel.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/body_life_model.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/usecases/save_calculated_panel_usecase.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';

class FakePanRepo implements IQiZhengSiYuPanRepository {
  final Map<String, QiZhengSiYuPanContract> _store = {};

  @override
  Future<void> save(QiZhengSiYuPanContract contract) async {
    _store[contract.uuid] = contract;
  }

  @override
  Future<QiZhengSiYuPanContract?> findByUuid(String uuid) async => _store[uuid];

  @override
  Future<void> update(QiZhengSiYuPanContract contract) async {
    _store[contract.uuid] = contract;
  }

  @override
  Future<void> delete(String uuid) async => _store.remove(uuid);

  @override
  Future<void> permanentlyDelete(String uuid) async => _store.remove(uuid);

  @override
  Future<List<QiZhengSiYuPanContract>> findAllActive() async => _store.values.toList();

  @override
  Future<List<QiZhengSiYuPanContract>> findByDivinationUuid(String divinationUuid) async =>
      _store.values.where((c) => c.divinationRequestInfoUuid == divinationUuid).toList();

  @override
  Future<List<QiZhengSiYuPanContract>> findByDateRange(DateTime startDate, DateTime endDate) async => const [];

  @override
  Future<PaginatedResult<QiZhengSiYuPanContract>> findWithPagination({int page = 1, int pageSize = 20}) async =>
      const PaginatedResult(items: [], totalCount: 0, page: 1, pageSize: 20, totalPages: 0);

  @override
  Future<List<QiZhengSiYuPanContract>> search({String? divinationUuid, DateTime? startDate, DateTime? endDate, int? limit}) async => const [];

  @override
  Future<int> getTotalCount() async => 0;

  @override
  Future<int> getTodayCount() async => 0;

  @override
  Future<List<QiZhengSiYuPanContract>> getRecent({int limit = 10}) async => const [];

  @override
  Future<bool> existsByUuid(String uuid) async => _store.containsKey(uuid);

  @override
  Future<void> saveBatch(List<QiZhengSiYuPanContract> contracts) async {}

  @override
  Future<int> cleanupExpiredData({int daysOld = 30}) async => 0;

  // L0 Kernel Slice methods
  @override
  Future<Result<QiZhengSiYuPanContract?>> get(String id, RequestContext ctx) async => Ok(_store[id]);
  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async => Ok(_store.containsKey(id));
  @override
  Future<Result<Rev>> put(QiZhengSiYuPanContract entity, RequestContext ctx, {Precondition pre = const Unconditional()}) async {
    _store[entity.uuid] = entity;
    return Ok(Rev(entity.uuid));
  }
  @override
  Future<Result<Page<QiZhengSiYuPanContract>>> query(Map<String, Object?> spec, PageRequest page, RequestContext ctx) async {
    return Ok(Page(items: _store.values.toList()));
  }
  @override
  Future<Result<int>> count(Map<String, Object?> spec, RequestContext ctx) async => Ok(_store.length);
  @override
  Future<Result<void>> softDelete(String id, RequestContext ctx, {Precondition pre = const Unconditional()}) async {
    _store.remove(id);
    return const Ok(null);
  }
  @override
  Future<Result<void>> restore(String id, RequestContext ctx) async => const Ok(null);
  @override
  Future<Result<QiZhengSiYuPanContract?>> getIncludingDeleted(String id, RequestContext ctx) async => Ok(_store[id]);
  @override
  Future<Result<BatchOutcome<String>>> putAll(List<QiZhengSiYuPanContract> entities, RequestContext ctx) async {
    final results = <({String id, Result<Rev> result})>[];
    for (final e in entities) {
      _store[e.uuid] = e;
      results.add((id: e.uuid, result: Ok(Rev(e.uuid))));
    }
    return Ok(BatchOutcome(results));
  }
  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async => Ok(await body());
}

DivinationDatetimeModel _testDatetime() {
  const jsonStr = r'''
  {
    "uuid": "dt-1",
    "isDst": false,
    "isSeersLocation": false,
    "observer": {
      "type": "标准时间",
      "timezoneStr": "Asia/Shanghai",
      "isManualCalibration": false
    },
    "datetime": "1990-01-01T12:00:00.000",
    "yearJiaZi": "己巳",
    "monthJiaZi": "丙子",
    "dayJiaZi": "甲子",
    "timeJiaZi": "庚午",
    "lunarMonth": 11,
    "lunarDay": 5,
    "jieQiInfo": {
      "jieQi": "立春",
      "startAt": "1990-01-01T00:00:00.000",
      "endAt": "1990-01-15T00:00:00.000"
    },
    "isLeapMonth": false
  }
  ''';
  return DivinationDatetimeModel.fromJson(
    jsonDecode(jsonStr) as Map<String, dynamic>,
  );
}

DivinationRequestInfoDataModel _testRequestInfo() {
  return DivinationRequestInfoDataModel(
    uuid: 'req-1',
    createdAt: DateTime(2026),
    divinationTypeUuid: 'type-1',
  );
}

BasePanelConfig _testConfig() {
  return BasePanelConfig(
    celestialCoordinateSystem: CelestialCoordinateSystem.Ecliptic,
    houseDivisionSystem: HouseDivisionSystem.equal,
    panelSystemType: PanelSystemType.Tropical,
    constellationSystemType: ConstellationSystemType.Modern,
    settleLifeType: EnumSettleLifeType.Mao,
    settleBodyType: EnumSettleBodyType.moon,
    islifeGongBySunRealTimeLocation: true,
  );
}

BasePanelModel _emptyPanel() {
  return BasePanelModel(
    starAngleMapper: const {},
    enteredGongMapper: const {},
    fiveStarWalkingTypeMapper: const {},
    bodyLifeModel: BodyLifeModel(
      lifeGongInfo: GongDegree(gong: EnumTwelveGong.Mao, degree: 0.0),
      lifeConstellationInfo: ConstellationDegree(constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 0.0),
      bodyGongInfo: GongDegree(gong: EnumTwelveGong.You, degree: 0.0),
      bodyConstellationInfo: ConstellationDegree(constellation: Enum28Constellations.Kang_Jin_Long, degree: 0.0),
    ),
    twelveGongMapper: const {},
    shenShaItemMapper: const {},
    huaYaoItemMapper: const {},
    twelveZhangShengGongMapper: const {},
  );
}

class FakeRecordRepo implements QiZhengRecordRepository {
  final Map<String, QiZhengSiYuPanContract> _records = {};

  @override
  Future<String> saveRecord(QiZhengSiYuPanContract record) async {
    _records[record.uuid] = record;
    return record.uuid;
  }

  @override
  Future<List<QiZhengSiYuPanContract>> getAllRecords() async => _records.values.toList();

  @override
  Future<QiZhengSiYuPanContract?> getRecordByUuid(String uuid) async => _records[uuid];

  @override
  Future<bool> softDeleteRecord(String uuid) async {
    return _records.remove(uuid) != null;
  }

  @override
  Stream<List<QiZhengSiYuPanContract>> watchAllRecords() => Stream.value(_records.values.toList());

  // L0 Kernel Slice methods
  @override
  Future<Result<QiZhengSiYuPanContract?>> get(String id, RequestContext ctx) async => Ok(_records[id]);
  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async => Ok(_records.containsKey(id));
  @override
  Future<Result<Rev>> put(QiZhengSiYuPanContract entity, RequestContext ctx, {Precondition pre = const Unconditional()}) async {
    _records[entity.uuid] = entity;
    return Ok(Rev(entity.uuid));
  }
  @override
  Future<Result<Page<QiZhengSiYuPanContract>>> query(Map<String, Object?> spec, PageRequest page, RequestContext ctx) async {
    return Ok(Page(items: _records.values.toList()));
  }
  @override
  Future<Result<int>> count(Map<String, Object?> spec, RequestContext ctx) async => Ok(_records.length);
  @override
  Future<Result<void>> softDelete(String id, RequestContext ctx, {Precondition pre = const Unconditional()}) async {
    _records.remove(id);
    return const Ok(null);
  }
  @override
  Future<Result<void>> restore(String id, RequestContext ctx) async => const Ok(null);
  @override
  Future<Result<QiZhengSiYuPanContract?>> getIncludingDeleted(String id, RequestContext ctx) async => Ok(_records[id]);
  @override
  Stream<Result<List<QiZhengSiYuPanContract>>> watch(Map<String, Object?> spec, RequestContext ctx) {
    return Stream.value(Ok(_records.values.toList()));
  }
  @override
  Future<Result<BatchOutcome<String>>> putAll(List<QiZhengSiYuPanContract> entities, RequestContext ctx) async {
    final results = <({String id, Result<Rev> result})>[];
    for (final e in entities) {
      _records[e.uuid] = e;
      results.add((id: e.uuid, result: Ok(Rev(e.uuid))));
    }
    return Ok(BatchOutcome(results));
  }
  @override
  Future<Result<R>> inTransaction<R>(Future<R> Function() body) async => Ok(await body());
}

void main() {
  final _ctx = RequestContext(scopeUid: 'local-anonymous');
  group('SaveCalculatedPanelUseCase', () {
    late FakePanRepo repo;
    late FakeRecordRepo recordRepo;
    late SaveCalculatedPanelUseCase useCase;

    setUp(() {
      repo = FakePanRepo();
      recordRepo = FakeRecordRepo();
      useCase = SaveCalculatedPanelUseCase(
        qiZhengSiYuPanRepository: repo,
        recordRepository: recordRepo,
      );
    });

    test('constructs without Flutter bindings', () {
      expect(useCase, isNotNull);
    });

    test('execute saves panel and returns entity', () async {
      final panelModel = _emptyPanel();

      final entity = await useCase.execute(
        basicPanelModel: panelModel,
        panelConfig: _testConfig(),
        divinationDatetimeModel: _testDatetime(),
        requestInfo: _testRequestInfo(),
      );

      expect(entity.uuid, isNotEmpty);
      expect(entity.divinationRequestInfoUuid, 'req-1');
      expect(entity.panelConfig.toJson(), _testConfig().toJson());
      expect(entity.divinationDatetimeModel.uuid, 'dt-1');
      expect(repo._store.length, 1);
    });

    test('update returns false for non-existent entity', () async {
      final panelModel = _emptyPanel();
      final result = await useCase.update(
        uuid: 'nonexistent',
        basicPanelModel: panelModel,
        panelConfig: _testConfig(),
        divinationDatetimeModel: _testDatetime(),
        requestInfo: _testRequestInfo(),
      );
      expect(result, isFalse);
    });

    test('update succeeds after execute', () async {
      final panelModel = _emptyPanel();

      final entity = await useCase.execute(
        basicPanelModel: panelModel,
        panelConfig: _testConfig(),
        divinationDatetimeModel: _testDatetime(),
        requestInfo: _testRequestInfo(),
      );

      final updated = await useCase.update(
        uuid: entity.uuid,
        basicPanelModel: panelModel,
        panelConfig: _testConfig(),
        divinationDatetimeModel: _testDatetime(),
        requestInfo: _testRequestInfo(),
      );
      expect(updated, isTrue);
    });

    test('getByUuid returns entity after execute', () async {
      final panelModel = _emptyPanel();

      final entity = await useCase.execute(
        basicPanelModel: panelModel,
        panelConfig: _testConfig(),
        divinationDatetimeModel: _testDatetime(),
        requestInfo: _testRequestInfo(),
      );

      final retrieved = await useCase.getByUuid(entity.uuid);
      expect(retrieved, isNotNull);
      expect(retrieved!.uuid, entity.uuid);
    });

    test('getByDivinationUuid returns entities', () async {
      final panelModel = _emptyPanel();

      await useCase.execute(
        basicPanelModel: panelModel,
        panelConfig: _testConfig(),
        divinationDatetimeModel: _testDatetime(),
        requestInfo: _testRequestInfo(),
      );
      await useCase.execute(
        basicPanelModel: panelModel,
        panelConfig: _testConfig(),
        divinationDatetimeModel: _testDatetime(),
        requestInfo: _testRequestInfo(),
      );

      final results = await useCase.getByDivinationUuid('req-1');
      expect(results, hasLength(2));
    });

    test('delete returns 0 for non-existent entity', () async {
      final result = await useCase.delete('nonexistent');
      expect(result, 0);
    });

    test('delete returns 1 after execute', () async {
      final panelModel = _emptyPanel();

      final entity = await useCase.execute(
        basicPanelModel: panelModel,
        panelConfig: _testConfig(),
        divinationDatetimeModel: _testDatetime(),
        requestInfo: _testRequestInfo(),
      );

      final result = await useCase.delete(entity.uuid);
      expect(result, 1);

      final afterDelete = await useCase.getByUuid(entity.uuid);
      expect(afterDelete, isNull);
    });

    test('execute dual-writes to pan repo and record repo', () async {
      final panelModel = _emptyPanel();

      final entity = await useCase.execute(
        basicPanelModel: panelModel,
        panelConfig: _testConfig(),
        divinationDatetimeModel: _testDatetime(),
        requestInfo: _testRequestInfo(),
      );

      expect(repo._store[entity.uuid], isNotNull);
      expect(recordRepo.get(entity.uuid, _ctx), completion(isNotNull));
    });
  });
}
