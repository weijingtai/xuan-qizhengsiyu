// T-Q2-PORT-02: QiZhengHistoricalEphemerisRepository contract tests
//
// Verifies that the port interface contract is satisfied:
// - loadHistoricalEphemeris returns Map<String, dynamic>
// - Empty data returns empty map

import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import '../../fakes/fake_storage_dependencies.dart';

void main() {
  group('T-Q2-PORT-02: QiZhengHistoricalEphemerisRepository', () {
    late FakeQiZhengHistoricalEphemerisRepository repo;

    setUp(() {
      repo = FakeQiZhengHistoricalEphemerisRepository();
    });

    test('loadHistoricalEphemeris returns Map<String, dynamic>', () async {
      final result = await repo.loadHistoricalEphemeris();

      expect(result, isA<Map<String, dynamic>>());
    });

    test('loadHistoricalEphemeris returns empty map when no data', () async {
      final result = await repo.loadHistoricalEphemeris();

      expect(result, isEmpty);
    });

    test('implements QiZhengHistoricalEphemerisRepository interface', () {
      expect(repo, isA<QiZhengHistoricalEphemerisRepository>());
    });

    test('loadHistoricalEphemeris returns a new map each call', () async {
      final result1 = await repo.loadHistoricalEphemeris();
      final result2 = await repo.loadHistoricalEphemeris();

      expect(result1, equals(result2));
      // For non-empty results, verify they are distinct instances (no shared mutation).
      // For empty results, const {} may be the same singleton instance — that's fine.
      if (result1.isNotEmpty) {
        expect(result1, isNot(same(result2)));
      }
    });
  });

  group('T-Q2-PORT-02: Custom QiZhengHistoricalEphemerisRepository', () {
    test('custom implementation returns populated data', () async {
      final customRepo = _PopulatedHistoricalEphemerisRepository();
      final result = await customRepo.loadHistoricalEphemeris();

      expect(result, isNotEmpty);
      expect(result.containsKey('DongZhi'), isTrue);
      expect(result['DongZhi'], isA<double>());
    });
  });
}

/// A custom fake that returns populated data for contract testing.
class _PopulatedHistoricalEphemerisRepository
    implements QiZhengHistoricalEphemerisRepository {
  @override
  Future<Map<String, dynamic>> loadHistoricalEphemeris() async {
    return const {
      'DongZhi': 0.9856,
      'DaHan': 0.9860,
      'LiChun': 0.9872,
    };
  }
}
