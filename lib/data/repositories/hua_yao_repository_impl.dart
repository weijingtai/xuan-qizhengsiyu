import 'package:qizhengsiyu/data/datasources/local/hua_yao_local_data_source.dart';
import 'package:qizhengsiyu/domain/repositories/hua_yao_repository.dart';

import '../../domain/entities/models/hua_yao.dart';

class HuaYaoRepositoryImpl implements HuaYaoRepository {
  final HuaYaoLocalDataSource localDataSource;

  HuaYaoRepositoryImpl({required this.localDataSource});

  @override
  Future<List<TianGanHuaYao>> getTianGanHuaYao() {
    return localDataSource.getTianGanHuaYao();
  }

  @override
  Future<List<DiZhiHuaYao>> getDiZhiHuaYao() {
    return localDataSource.getDiZhiHuaYao();
  }

  @override
  Future<List<OthersHuaYao>> getOthersHuaYao() {
    return localDataSource.getOthersHuaYao();
  }
}
