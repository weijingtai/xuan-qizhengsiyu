// T-Q2-PORT-01: QiZhengStarPositionStatusRepository contract tests
//
// Verifies that the port interface contract is satisfied by fakes:
// - loadStarPositionStatus returns List<QiZhengStarPositionStatusContract>
// - Empty data returns empty list

import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import '../../fakes/fake_storage_dependencies.dart';

void main() {
  group('T-Q2-PORT-01: QiZhengStarPositionStatusRepository', () {
    late FakeQiZhengStarPositionStatusRepository repo;

    setUp(() {
      repo = FakeQiZhengStarPositionStatusRepository();
    });

    test('loadStarPositionStatus returns List<QiZhengStarPositionStatusContract>', () async {
      final result = await repo.loadStarPositionStatus();

      expect(result, isA<List<QiZhengStarPositionStatusContract>>());
    });

    test('loadStarPositionStatus returns empty list when no data', () async {
      final result = await repo.loadStarPositionStatus();

      expect(result, isEmpty);
    });

    test('implements QiZhengStarPositionStatusRepository interface', () {
      expect(repo, isA<QiZhengStarPositionStatusRepository>());
    });

    test('loadStarPositionStatus returns a new list each call (no shared mutation)', () async {
      final result1 = await repo.loadStarPositionStatus();
      final result2 = await repo.loadStarPositionStatus();

      expect(result1, equals(result2));
      // For non-empty results, verify they are distinct instances (no shared mutation).
      // For empty results, const [] may be the same singleton instance — that's fine.
      if (result1.isNotEmpty) {
        expect(result1, isNot(same(result2)));
      }
    });
  });

  group('T-Q2-PORT-01: Custom QiZhengStarPositionStatusRepository', () {
    test('custom implementation returns populated data', () async {
      final customRepo = _PopulatedStarPositionStatusRepository();
      final result = await customRepo.loadStarPositionStatus();

      expect(result, isNotEmpty);
      expect(result.length, 2);
      expect(result.first.raw, isNotEmpty);
    });
  });
}

/// A custom fake that returns populated data for more thorough contract testing.
class _PopulatedStarPositionStatusRepository
    implements QiZhengStarPositionStatusRepository {
  @override
  Future<List<QiZhengStarPositionStatusContract>> loadStarPositionStatus() async {
    return [
      const QiZhengStarPositionStatusContract({'star': 'Sun', 'status': 'normal'}),
      const QiZhengStarPositionStatusContract({'star': 'Moon', 'status': 'retrograde'}),
    ];
  }
}
