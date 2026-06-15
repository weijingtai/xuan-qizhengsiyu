// T-Q2-PORT-03: QiZhengEphemerisResourceRepository contract tests
//
// Verifies that the port interface contract is satisfied:
// - loadEphemerisResource returns String
// - Empty data returns empty string

import 'package:flutter_test/flutter_test.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import '../../fakes/fake_storage_dependencies.dart';

void main() {
  group('T-Q2-PORT-03: QiZhengEphemerisResourceRepository', () {
    late FakeQiZhengEphemerisResourceRepository repo;

    setUp(() {
      repo = FakeQiZhengEphemerisResourceRepository();
    });

    test('loadEphemerisResource returns String', () async {
      final result = await repo.loadEphemerisResource('test_resource');

      expect(result, isA<String>());
    });

    test('loadEphemerisResource returns empty string when no data', () async {
      final result = await repo.loadEphemerisResource('test_resource');

      expect(result, isEmpty);
    });

    test('implements QiZhengEphemerisResourceRepository interface', () {
      expect(repo, isA<QiZhengEphemerisResourceRepository>());
    });

    test('loadEphemerisResource accepts resourceName parameter', () async {
      // Verify the method signature accepts a String resourceName parameter
      final result = await repo.loadEphemerisResource('sepl_se1.ephe');
      expect(result, isA<String>());
    });
  });

  group('T-Q2-PORT-03: Custom QiZhengEphemerisResourceRepository', () {
    test('custom implementation returns populated string', () async {
      final customRepo = _PopulatedEphemerisResourceRepository();
      final result = await customRepo.loadEphemerisResource('sepl_se1.ephe');

      expect(result, isNotEmpty);
      expect(result, equals('mock_ephemeris_data'));
    });

    test('custom implementation handles different resource names', () async {
      final customRepo = _PopulatedEphemerisResourceRepository();

      final result1 = await customRepo.loadEphemerisResource('sepl_se1.ephe');
      final result2 = await customRepo.loadEphemerisResource('semo_18.se1');

      expect(result1, isNotEmpty);
      expect(result2, isNotEmpty);
    });
  });
}

/// A custom fake that returns populated data for contract testing.
class _PopulatedEphemerisResourceRepository
    implements QiZhengEphemerisResourceRepository {
  @override
  Future<String> loadEphemerisResource(String resourceName) async {
    return 'mock_ephemeris_data';
  }
}
