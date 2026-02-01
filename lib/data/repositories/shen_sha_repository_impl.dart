import 'package:common/models/shen_sha_bundled.dart';
import 'package:common/models/shen_sha_tian_gan.dart';
import 'package:qizhengsiyu/data/datasources/local/shen_sha_local_data_source.dart';
import 'package:qizhengsiyu/domain/repositories/shen_sha_repository.dart';
import 'package:common/models/shen_sha_gan_zhi.dart';

import '../../domain/entities/models/di_zhi_shen_sha.dart';

class ShenShaRepositoryImpl implements ShenShaRepository {
  final ShenShaLocalDataSource localDataSource;

  ShenShaRepositoryImpl({required this.localDataSource});

  @override
  Future<List<TianGanShenSha>> getTianGanShenSha() {
    return localDataSource.getTianGanShenSha();
  }

  @override
  Future<List<YearDiZhiShenSha>> getYearDiZhiShenSha() {
    return localDataSource.getYearDiZhiShenSha();
  }

  @override
  Future<List<MonthDiZhiShenSha>> getMonthDiZhiShenSha() {
    return localDataSource.getMonthDiZhiShenSha();
  }

  @override
  Future<List<GanZhiShenSha>> getGanZhiShenSha() {
    return localDataSource.getGanZhiShenSha();
  }

  @override
  Future<List<BundledShenSha>> getBundledShenSha() {
    return localDataSource.getBundledShenSha();
  }

  @override
  Future<List<OtherShenSha>> getOtherShenSha() {
    return localDataSource.getOtherShenSha();
  }
}
