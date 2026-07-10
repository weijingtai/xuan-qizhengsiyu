// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alignment_point_candidate_dao.dart';

// ignore_for_file: type=lint
mixin _$AlignmentPointCandidateDaoMixin on DatabaseAccessor<AppDatabase> {
  $AlignmentPointCandidateTableTable get alignmentPointCandidateTable =>
      attachedDatabase.alignmentPointCandidateTable;
  AlignmentPointCandidateDaoManager get managers =>
      AlignmentPointCandidateDaoManager(this);
}

class AlignmentPointCandidateDaoManager {
  final _$AlignmentPointCandidateDaoMixin _db;
  AlignmentPointCandidateDaoManager(this._db);
  $$AlignmentPointCandidateTableTableTableManager
  get alignmentPointCandidateTable =>
      $$AlignmentPointCandidateTableTableTableManager(
        _db.attachedDatabase,
        _db.alignmentPointCandidateTable,
      );
}
