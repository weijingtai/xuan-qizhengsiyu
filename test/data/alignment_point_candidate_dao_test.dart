import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNull;

import 'package:qizhengsiyu/data/datasources/local/app_database.dart';
import 'package:qizhengsiyu/data/datasources/local/daos/alignment_point_candidate_dao.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';

void main() {
  group('AlignmentPointCandidateTable DAO 往返测试', () {
    late AppDatabase db;
    late AlignmentPointCandidateDao dao;
    late AlignmentPointCandidateService service;

    setUp(() {
      db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
      dao = AlignmentPointCandidateDao(db);
      service = AlignmentPointCandidateService(dao);
    });

    tearDown(() async {
      await db.close();
    });

    test('insert + listAll: 创建候选后查询回同一 uuid', () async {
      final alignmentPoint = ConstellationDegree(
        constellation: Enum28Constellations.Jiao_Mu_Jiao,
        degree: 6.5,
      );

      final uuid = await service.saveCandidate(
        name: '测试候选 1',
        alignmentPoint: alignmentPoint,
        sourceNote: '参照三辰通载/开禧历对比后手动校准',
      );

      final all = await service.listAll();
      expect(all.length, 1);

      final row = all.first;
      expect(row.uuid, equals(uuid));
      expect(row.name, equals('测试候选 1'));
      expect(row.alignmentPoint.constellation, Enum28Constellations.Jiao_Mu_Jiao);
      expect(row.alignmentPoint.degree, closeTo(6.5, 1e-9));
      expect(row.sourceNote, equals('参照三辰通载/开禧历对比后手动校准'));
      expect(row.deletedAt, isNull);
    });

    test('insert + softDelete: 软删除后 listAll 不含该条', () async {
      final uuid = await service.saveCandidate(
        name: '待删除候选',
        alignmentPoint: ConstellationDegree(
          constellation: Enum28Constellations.Xu_Ri_Shu,
          degree: 1.6275,
        ),
      );

      expect((await service.listAll()).length, 1);

      await service.delete(uuid);
      expect((await service.listAll()).length, 0);
    });

    test('insert 多条后 listAll 返回全部，数据正确', () async {
      await service.saveCandidate(
        name: '候选 A',
        alignmentPoint: ConstellationDegree(
          constellation: Enum28Constellations.Xu_Ri_Shu, degree: 6),
      );
      await service.saveCandidate(
        name: '候选 B',
        alignmentPoint: ConstellationDegree(
          constellation: Enum28Constellations.Kui_Mu_Lang, degree: 9.75),
      );

      final all = await service.listAll();
      expect(all.length, 2);
      final names = all.map((r) => r.name).toSet();
      expect(names, containsAll(['候选 A', '候选 B']));
      final b = all.firstWhere((r) => r.name == '候选 B');
      expect(b.alignmentPoint.constellation, Enum28Constellations.Kui_Mu_Lang);
      expect(b.alignmentPoint.degree, closeTo(9.75, 1e-9));
    });

    test('ConstellationDegree 精度保持 (浮点 ±0.0001)', () async {
      final values = [0.0, 1.6275, 6.0, 9.75, 30.4380];
      for (final degree in values) {
        final uuid = await service.saveCandidate(
          name: '精度测试 $degree',
          alignmentPoint: ConstellationDegree(
            constellation: Enum28Constellations.Lou_Jin_Gou, degree: degree),
        );

        final all = await service.listAll();
        final row = all.firstWhere((r) => r.uuid == uuid);
        expect(row.alignmentPoint.constellation, Enum28Constellations.Lou_Jin_Gou);
        expect(row.alignmentPoint.degree, closeTo(degree, 1e-4));
      }
    });

    test('sourceNote 可空: null 传值往返为 null', () async {
      final uuid = await service.saveCandidate(
        name: '无备注候选',
        alignmentPoint: ConstellationDegree(
          constellation: Enum28Constellations.Wei_Tu_Zhi, degree: 0),
        sourceNote: null,
      );

      final all = await service.listAll();
      final row = all.firstWhere((r) => r.uuid == uuid);
      expect(row.sourceNote, isNull);
    });
  });
}
