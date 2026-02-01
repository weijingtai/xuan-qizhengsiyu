import 'package:qizhengsiyu/domain/entities/models/hua_yao.dart';
import 'package:qizhengsiyu/domain/repositories/hua_yao_repository.dart';

class HuaYaoService {
  final HuaYaoRepository repository;

  HuaYaoService({required this.repository});

  Future<List<TianGanHuaYao>> getTianGanHuaYao() {
    return repository.getTianGanHuaYao();
  }

  Future<List<DiZhiHuaYao>> getDiZhiHuaYao() {
    return repository.getDiZhiHuaYao();
  }

  Future<List<OthersHuaYao>> getOthersHuaYao() {
    return repository.getOthersHuaYao();
  }
}
