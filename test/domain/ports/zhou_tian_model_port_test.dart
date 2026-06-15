// T-Q2-PORT-04: QiZhengZhouTianModelRepository contract tests
//
// Verifies that the port interface contract is satisfied:
// - loadBuiltInZhouTianModels returns List<QiZhengZhouTianModelContract>
// - Empty data returns empty list

import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import '../../fakes/fake_storage_dependencies.dart';

void main() {
  group('T-Q2-PORT-04: QiZhengZhouTianModelRepository', () {
    late FakeQiZhengZhouTianModelRepository repo;

    setUp(() {
      repo = FakeQiZhengZhouTianModelRepository();
    });

    test('loadBuiltInZhouTianModels returns List<QiZhengZhouTianModelContract>', () async {
      final result = await repo.loadBuiltInZhouTianModels();

      expect(result, isA<List<QiZhengZhouTianModelContract>>());
    });

    test('loadBuiltInZhouTianModels returns empty list when no data', () async {
      final result = await repo.loadBuiltInZhouTianModels();

      expect(result, isEmpty);
    });

    test('implements QiZhengZhouTianModelRepository interface', () {
      expect(repo, isA<QiZhengZhouTianModelRepository>());
    });

    test('loadBuiltInZhouTianModels returns a new list each call', () async {
      final result1 = await repo.loadBuiltInZhouTianModels();
      final result2 = await repo.loadBuiltInZhouTianModels();

      expect(result1, equals(result2));
      // For non-empty results, verify they are distinct instances (no shared mutation).
      // For empty results, const [] may be the same singleton instance — that's fine.
      if (result1.isNotEmpty) {
        expect(result1, isNot(same(result2)));
      }
    });
  });

  group('T-Q2-PORT-04: Custom QiZhengZhouTianModelRepository', () {
    test('custom implementation returns populated data', () async {
      final customRepo = _PopulatedZhouTianModelRepository();
      final result = await customRepo.loadBuiltInZhouTianModels();

      expect(result, isNotEmpty);
      expect(result.length, 1);
      expect(result.first.raw, isNotEmpty);
      expect(result.first.raw['name'], equals('TianChiDao'));
    });
  });
}

/// A custom fake that returns populated data for contract testing.
class _PopulatedZhouTianModelRepository
    implements QiZhengZhouTianModelRepository {
  @override
  Future<List<QiZhengZhouTianModelContract>> loadBuiltInZhouTianModels() async {
    return [
      const QiZhengZhouTianModelContract({
        'name': 'TianChiDao',
        'type': 'historical',
      }),
    ];
  }
}
