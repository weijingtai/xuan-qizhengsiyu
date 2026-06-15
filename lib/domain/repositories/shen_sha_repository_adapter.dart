import 'package:metaphysics_core/models/shen_sha_bundled.dart';
import 'package:metaphysics_core/models/shen_sha_gan_zhi.dart';
import 'package:metaphysics_core/models/shen_sha_tian_gan.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import 'package:qizhengsiyu/domain/entities/models/di_zhi_shen_sha.dart';
import 'package:qizhengsiyu/domain/repositories/shen_sha_repository.dart';

// ═══════════════════════════════════════════════════════
// ShenSha Mappers (contract → product)
// ═══════════════════════════════════════════════════════

List<TianGanShenSha> _tianGanShenShaFromContracts(
    List<ShenShaRecordContract> contracts) {
  return contracts.map((c) => TianGanShenSha.fromJson(c.raw)).toList();
}

List<YearDiZhiShenSha> _yearDiZhiShenShaFromContracts(
    List<ShenShaRecordContract> contracts) {
  return contracts.map((c) => YearDiZhiShenSha.fromJson(c.raw)).toList();
}

List<MonthDiZhiShenSha> _monthDiZhiShenShaFromContracts(
    List<ShenShaRecordContract> contracts) {
  return contracts.map((c) => MonthDiZhiShenSha.fromJson(c.raw)).toList();
}

List<GanZhiShenSha> _ganZhiShenShaFromContracts(
    List<ShenShaRecordContract> contracts) {
  return contracts.map((c) => GanZhiShenSha.fromJson(c.raw)).toList();
}

List<BundledShenSha> _bundledShenShaFromContracts(
    List<ShenShaRecordContract> contracts) {
  return contracts.map((c) => BundledShenSha.fromJson(c.raw)).toList();
}

List<OtherShenSha> _otherShenShaFromContracts(
    List<ShenShaRecordContract> contracts) {
  return contracts.map((c) => OtherShenSha.fromJson(c.raw)).toList();
}

// ═══════════════════════════════════════════════════════
// Adapter: ShenSha Repository
// ═══════════════════════════════════════════════════════

/// Wraps [QiZhengShenShaRepository] (contract port) and presents
/// the product-typed [ShenShaRepository] interface.
class ShenShaRepositoryAdapter implements ShenShaRepository {
  final QiZhengShenShaRepository _port;
  ShenShaRepositoryAdapter(this._port);

  @override
  Future<List<TianGanShenSha>> getTianGanShenSha() async =>
      _tianGanShenShaFromContracts(await _port.getTianGanShenSha());

  @override
  Future<List<YearDiZhiShenSha>> getYearDiZhiShenSha() async =>
      _yearDiZhiShenShaFromContracts(await _port.getYearDiZhiShenSha());

  @override
  Future<List<MonthDiZhiShenSha>> getMonthDiZhiShenSha() async =>
      _monthDiZhiShenShaFromContracts(await _port.getMonthDiZhiShenSha());

  @override
  Future<List<GanZhiShenSha>> getGanZhiShenSha() async =>
      _ganZhiShenShaFromContracts(await _port.getGanZhiShenSha());

  @override
  Future<List<BundledShenSha>> getBundledShenSha() async =>
      _bundledShenShaFromContracts(await _port.getBundledShenSha());

  @override
  Future<List<OtherShenSha>> getOtherShenSha() async =>
      _otherShenShaFromContracts(await _port.getOtherShenSha());
}
