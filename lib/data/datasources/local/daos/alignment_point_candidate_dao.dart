import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/alignment_point_candidate_table.dart';
import '../../../../domain/entities/models/naming_degree_pair.dart';

part 'alignment_point_candidate_dao.g.dart';

@DriftAccessor(tables: [AlignmentPointCandidateTable])
class AlignmentPointCandidateDao extends DatabaseAccessor<AppDatabase>
    with _$AlignmentPointCandidateDaoMixin {
  AlignmentPointCandidateDao(AppDatabase db) : super(db);

  Future<void> insertCandidate({
    required String uuid,
    required String name,
    required ConstellationDegree alignmentPoint,
    String? sourceNote,
  }) {
    final now = DateTime.now();
    return into(alignmentPointCandidateTable).insert(
      AlignmentPointCandidateTableCompanion.insert(
        uuid: uuid,
        name: name,
        alignmentPoint: alignmentPoint,
        sourceNote: Value(sourceNote),
        createdAt: now,
        lastUpdatedAt: now,
      ),
    );
  }

  Future<List<AlignmentPointCandidateTableData>> listAll() {
    return (select(alignmentPointCandidateTable)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.lastUpdatedAt)]))
        .get();
  }

  Future<void> softDelete(String uuid) {
    return (update(alignmentPointCandidateTable)..where((t) => t.uuid.equals(uuid)))
        .write(AlignmentPointCandidateTableCompanion(deletedAt: Value(DateTime.now())));
  }
}

class AlignmentPointCandidateService {
  static const _uuid = Uuid();

  final AlignmentPointCandidateDao _dao;

  AlignmentPointCandidateService(this._dao);

  Future<String> saveCandidate({
    required String name,
    required ConstellationDegree alignmentPoint,
    String? sourceNote,
  }) async {
    final uuid = 'user_${_uuid.v4()}';
    await _dao.insertCandidate(
      uuid: uuid,
      name: name,
      alignmentPoint: alignmentPoint,
      sourceNote: sourceNote,
    );
    return uuid;
  }

  Future<List<AlignmentPointCandidateTableData>> listAll() => _dao.listAll();

  Future<void> delete(String uuid) => _dao.softDelete(uuid);
}
