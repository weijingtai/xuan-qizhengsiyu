
import '../entities/models/hua_yao.dart';

abstract class HuaYaoRepository {
  Future<List<TianGanHuaYao>> getTianGanHuaYao();
  Future<List<DiZhiHuaYao>> getDiZhiHuaYao();
  Future<List<OthersHuaYao>> getOthersHuaYao();
}
