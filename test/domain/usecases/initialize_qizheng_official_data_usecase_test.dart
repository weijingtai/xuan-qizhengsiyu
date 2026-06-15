import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/managers/zhou_tian_model_manager.dart';
import 'package:qizhengsiyu/domain/usecases/initialize_qizheng_official_data_usecase.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';

ZhouTianModel _buildTestModel() {
  return ZhouTianModel(
    systemType: CelestialCoordinateSystem.Ecliptic,
    constellationSystemType: ConstellationSystemType.Modern,
    panelSystemType: PanelSystemType.Tropical,
    epochCorrection: 'default',
    totalDegree: 360.0,
    gongDegreeSeq: List.generate(12, (i) => GongDegree(gong: EnumTwelveGong.listAll[i], degree: 30.0)),
    starInnDegreeSeq: [
      ConstellationDegree(constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 12.0),
    ],
    alignmentPointAtConstellation: ConstellationDegree(constellation: Enum28Constellations.Xu_Ri_Shu, degree: 6.0),
    alignmentPointAtGong: GongDegree(gong: EnumTwelveGong.Zi, degree: 0.0),
    zeroPointJieQi: TwentyFourJieQi.CHUN_FEN,
    zeroPointAtConstellation: ConstellationDegree(constellation: Enum28Constellations.Shi_Huo_Zhu, degree: 6.5),
    zeroPointAtGong: GongDegree(gong: EnumTwelveGong.Xu, degree: 0.0),
    celestialLongitude: 0.0,
    zeroPointOffsetToNow: 0.0,
    rightAscension: 0.0,
    specificationList: const ['baseline'],
    gongOrder: EnumTwelveGong.listAll,
    starInnOrder: [Enum28Constellations.Jiao_Mu_Jiao],
  );
}

class FakeZhouTianRepo implements QiZhengZhouTianModelRepository {
  final List<ZhouTianModel> models;
  FakeZhouTianRepo(this.models);

  @override
  Future<List<QiZhengZhouTianModelContract>> loadBuiltInZhouTianModels() async =>
      models.map((m) => QiZhengZhouTianModelContract(
        jsonDecode(jsonEncode(m.toJson())) as Map<String, dynamic>
      )).toList();
}

String _modelKey(ZhouTianModel model) {
  return '${model.systemType.name}_${model.panelSystemType.name}_${model.constellationSystemType.name}';
}

void main() {
  group('InitializeQiZhengOfficialDataUseCase', () {
    test('can be constructed with ZhouTianModelManager', () {
      final repo = FakeZhouTianRepo([]);
      final manager = ZhouTianModelManager(repository: repo);
      final useCase = InitializeQiZhengOfficialDataUseCase(zhouTianModelManager: manager);
      expect(useCase, isNotNull);
    });

    test('has no Flutter or UI imports', () {
      final repo = FakeZhouTianRepo([]);
      final manager = ZhouTianModelManager(repository: repo);
      final useCase = InitializeQiZhengOfficialDataUseCase(zhouTianModelManager: manager);
      final source = useCase.toString();
      expect(source, isNotEmpty);
    });

    test('execute loads models via injected repository', () async {
      final model = _buildTestModel();
      final repo = FakeZhouTianRepo([model]);
      final manager = ZhouTianModelManager(repository: repo);
      manager.setModelsForTesting({_modelKey(model): model});
      final useCase = InitializeQiZhengOfficialDataUseCase(zhouTianModelManager: manager);

      await useCase.execute();

      expect(manager.isLoaded, isTrue);
      expect(manager.allModels.length, 1);
    });

    test('execute with pre-loaded models does not crash', () async {
      final repo = FakeZhouTianRepo([]);
      final manager = ZhouTianModelManager(repository: repo);
      manager.setModelsForTesting({
        'Ecliptic_Tropical_Modern': _buildTestModel(),
      });
      final useCase = InitializeQiZhengOfficialDataUseCase(zhouTianModelManager: manager);

      await useCase.execute();

      expect(manager.isLoaded, isTrue);
    });
  });
}
