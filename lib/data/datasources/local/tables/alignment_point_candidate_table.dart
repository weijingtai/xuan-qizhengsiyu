import 'package:drift/drift.dart';
import '../../../models/converters/constellation_degree_converter.dart';

class AlignmentPointCandidateTable extends Table {
  @override
  String get tableName => 't_alignment_point_candidates';

  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  TextColumn get name => text().withLength(min: 1).named('name')();
  TextColumn get alignmentPoint =>
      text().map(const ConstellationDegreeConverter()).named('alignment_point_json')();
  TextColumn get sourceNote => text().nullable().named('source_note')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  @override
  Set<Column> get primaryKey => {uuid};
}
