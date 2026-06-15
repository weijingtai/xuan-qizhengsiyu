import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';

/// Dependency bundle for qizhengsiyu storage ports.
///
/// Constructed by the host (composition root) and injected into
/// [createProviders] so the product never touches concrete persistence.
class QiZhengSiYuStorageDependencies {
  const QiZhengSiYuStorageDependencies({
    required this.panRepository,
    required this.geJuRepository,
    required this.geJuBuiltInDataSource,
    required this.geJuSchoolService,
    required this.shenSha,
    required this.huaYao,
    required this.starPositionStatus,
    required this.historicalEphemeris,
    required this.ephemerisResource,
    required this.zhouTianModelRepository,
  });

  final IQiZhengSiYuPanRepository panRepository;
  final IGeJuRepository geJuRepository;
  final GeJuBuiltInDataSource geJuBuiltInDataSource;
  final GeJuSchoolServicePort geJuSchoolService;
  final QiZhengShenShaRepository shenSha;
  final QiZhengHuaYaoRepository huaYao;
  final QiZhengStarPositionStatusRepository starPositionStatus;
  final QiZhengHistoricalEphemerisRepository historicalEphemeris;
  final QiZhengEphemerisResourceRepository ephemerisResource;
  final QiZhengZhouTianModelRepository zhouTianModelRepository;
}
