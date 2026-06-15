import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import 'package:qizhengsiyu/domain/entities/models/hua_yao.dart';
import 'package:qizhengsiyu/domain/repositories/hua_yao_repository.dart';

// ═══════════════════════════════════════════════════════
// HuaYao Mappers (contract → product)
// ═══════════════════════════════════════════════════════

List<TianGanHuaYao> _tianGanHuaYaoFromContracts(
    List<HuaYaoRecordContract> contracts) {
  return contracts.map((c) => TianGanHuaYao.fromJson(c.raw)).toList();
}

List<DiZhiHuaYao> _diZhiHuaYaoFromContracts(
    List<HuaYaoRecordContract> contracts) {
  return contracts.map((c) => DiZhiHuaYao.fromJson(c.raw)).toList();
}

List<OthersHuaYao> _othersHuaYaoFromContracts(
    List<HuaYaoRecordContract> contracts) {
  return contracts.map((c) => OthersHuaYao.fromJson(c.raw)).toList();
}

// ═══════════════════════════════════════════════════════
// Adapter: HuaYao Repository
// ═══════════════════════════════════════════════════════

/// Wraps [QiZhengHuaYaoRepository] (contract port) and presents
/// the product-typed [HuaYaoRepository] interface.
class HuaYaoRepositoryAdapter implements HuaYaoRepository {
  final QiZhengHuaYaoRepository _port;
  HuaYaoRepositoryAdapter(this._port);

  @override
  Future<List<TianGanHuaYao>> getTianGanHuaYao() async =>
      _tianGanHuaYaoFromContracts(await _port.getTianGanHuaYao());

  @override
  Future<List<DiZhiHuaYao>> getDiZhiHuaYao() async =>
      _diZhiHuaYaoFromContracts(await _port.getDiZhiHuaYao());

  @override
  Future<List<OthersHuaYao>> getOthersHuaYao() async =>
      _othersHuaYaoFromContracts(await _port.getOthersHuaYao());
}
