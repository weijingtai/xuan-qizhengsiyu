import 'package:common/models/shen_sha_bundled.dart';
import 'package:common/models/shen_sha_gan_zhi.dart';
import 'package:common/models/shen_sha_tian_gan.dart';
import 'package:qizhengsiyu/domain/entities/models/di_zhi_shen_sha.dart';
import 'package:qizhengsiyu/domain/repositories/shen_sha_repository.dart';

class ShenShaService {
  final ShenShaRepository repository;

  ShenShaService({required this.repository});

  Future<List<TianGanShenSha>> getTianGanShenSha() {
    return repository.getTianGanShenSha();
  }

  Future<List<YearDiZhiShenSha>> getYearDiZhiShenSha() {
    return repository.getYearDiZhiShenSha();
  }

  Future<List<MonthDiZhiShenSha>> getMonthDiZhiShenSha() {
    return repository.getMonthDiZhiShenSha();
  }

  Future<List<GanZhiShenSha>> getGanZhiShenSha() {
    return repository.getGanZhiShenSha();
  }

  Future<List<BundledShenSha>> getBundledShenSha() {
    return repository.getBundledShenSha();
  }

  Future<List<OtherShenSha>> getOtherShenSha() {
    return repository.getOtherShenSha();
  }
}
