import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_school.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';

// ═══════════════════════════════════════════════════════
// GeJu School Contract ↔ Domain mappers
// ═══════════════════════════════════════════════════════

GeJuSchoolContract geJuSchoolToContract(GeJuSchool school) {
  return GeJuSchoolContract(
    id: school.id,
    name: school.name,
    brief: school.brief,
    features: school.features,
  );
}

GeJuSchool geJuSchoolFromContract(GeJuSchoolContract contract) {
  return GeJuSchool(
    id: contract.id,
    name: contract.name,
    brief: contract.brief,
    features: contract.features,
  );
}

// ═══════════════════════════════════════════════════════
// Adapter: GeJu School Service
// ═══════════════════════════════════════════════════════

/// Wraps [GeJuSchoolServicePort] (contract port) and presents
/// product-typed methods (GeJuSchool ↔ GeJuSchoolContract).
class GeJuSchoolServiceAdapter {
  final GeJuSchoolServicePort _port;
  GeJuSchoolServiceAdapter(this._port);

  Future<List<GeJuSchool>> getAllSchools() async {
    final contracts = await _port.getAllSchools();
    return contracts.map(geJuSchoolFromContract).toList();
  }

  Future<GeJuSchool?> getSchoolById(String id) async {
    final contract = await _port.getSchoolById(id);
    return contract != null ? geJuSchoolFromContract(contract) : null;
  }

  Future<GeJuSchool> createSchool({
    required String name,
    String? brief,
    List<String> features = const [],
  }) async {
    final contract =
        await _port.createSchool(name: name, brief: brief, features: features);
    return geJuSchoolFromContract(contract);
  }

  Future<void> updateSchool(GeJuSchool school) =>
      _port.updateSchool(geJuSchoolToContract(school));

  Future<void> deleteSchool(String id) => _port.deleteSchool(id);

  void clearCache() => _port.clearCache();
}
