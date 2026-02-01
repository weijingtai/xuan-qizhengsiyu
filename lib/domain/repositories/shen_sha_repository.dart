
import 'package:common/models/shen_sha_bundled.dart';
import 'package:common/models/shen_sha_gan_zhi.dart';
import 'package:common/models/shen_sha_tian_gan.dart';

import '../entities/models/di_zhi_shen_sha.dart';

abstract class ShenShaRepository {
  Future<List<TianGanShenSha>> getTianGanShenSha();
  Future<List<YearDiZhiShenSha>> getYearDiZhiShenSha();
  Future<List<MonthDiZhiShenSha>> getMonthDiZhiShenSha();
  Future<List<GanZhiShenSha>> getGanZhiShenSha();
  Future<List<BundledShenSha>> getBundledShenSha();
  Future<List<OtherShenSha>> getOtherShenSha();
}
