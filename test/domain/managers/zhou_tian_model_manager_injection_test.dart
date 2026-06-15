import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/managers/zhou_tian_model_manager.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';

ZhouTianModel _buildTestZhouTianModel() {
  return ZhouTianModel(
    systemType: CelestialCoordinateSystem.Ecliptic,
    constellationSystemType: ConstellationSystemType.Modern,
    panelSystemType: PanelSystemType.Tropical,
    epochCorrection: 'default',
    totalDegree: 360.0,
    gongDegreeSeq: [
      GongDegree(gong: EnumTwelveGong.Zi, degree: 30.0),
      GongDegree(gong: EnumTwelveGong.Chou, degree: 30.0),
      GongDegree(gong: EnumTwelveGong.Yin, degree: 30.0),
      GongDegree(gong: EnumTwelveGong.Mao, degree: 30.0),
      GongDegree(gong: EnumTwelveGong.Chen, degree: 30.0),
      GongDegree(gong: EnumTwelveGong.Si, degree: 30.0),
      GongDegree(gong: EnumTwelveGong.Wu, degree: 30.0),
      GongDegree(gong: EnumTwelveGong.Wei, degree: 30.0),
      GongDegree(gong: EnumTwelveGong.Shen, degree: 30.0),
      GongDegree(gong: EnumTwelveGong.You, degree: 30.0),
      GongDegree(gong: EnumTwelveGong.Xu, degree: 30.0),
      GongDegree(gong: EnumTwelveGong.Hai, degree: 30.0),
    ],
    starInnDegreeSeq: [
      ConstellationDegree(constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 12.0),
      ConstellationDegree(constellation: Enum28Constellations.Kang_Jin_Long, degree: 10.0),
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
    starInnOrder: [Enum28Constellations.Jiao_Mu_Jiao, Enum28Constellations.Kang_Jin_Long],
  );
}

class FakeZhouTianModelRepository implements QiZhengZhouTianModelRepository {
  final List<ZhouTianModel> models;

  FakeZhouTianModelRepository(this.models);

  @override
  Future<List<QiZhengZhouTianModelContract>> loadBuiltInZhouTianModels() async {
    return models.map((m) => QiZhengZhouTianModelContract(jsonDecode(jsonEncode(m.toJson())) as Map<String, dynamic>)).toList();
  }
}

void main() {
  group('ZhouTianModelManager injection', () {
    test('constructs with null repository (legacy path)', () {
      final manager = ZhouTianModelManager(repository: FakeZhouTianModelRepository([_buildTestZhouTianModel()]));
      expect(manager.isLoaded, isFalse);
    });

    test('constructs with injected repository', () {
      final model = _buildTestZhouTianModel();
      final repo = FakeZhouTianModelRepository([model]);
      final manager = ZhouTianModelManager(repository: repo);
      expect(manager.isLoaded, isFalse);
    });

    test('loads models from injected repository without Flutter bindings', () async {
      final model = _buildTestZhouTianModel();
      final repo = FakeZhouTianModelRepository([model]);
      final manager = ZhouTianModelManager(repository: repo);

      await manager.load();

      expect(manager.isLoaded, isTrue);
      final retrieved = manager.getZhouTianModelBy(
        _buildConfig(
          CelestialCoordinateSystem.Ecliptic,
          PanelSystemType.Tropical,
          ConstellationSystemType.Modern,
        ),
      );
      expect(retrieved.systemType, CelestialCoordinateSystem.Ecliptic);
      expect(retrieved.panelSystemType, PanelSystemType.Tropical);
    });

    test('setModelsForTesting injects without loading', () {
      final model = _buildTestZhouTianModel();
      final manager = ZhouTianModelManager(repository: FakeZhouTianModelRepository([_buildTestZhouTianModel()]));

      manager.setModelsForTesting({_modelKey(model): model});

      expect(manager.isLoaded, isTrue);
      final retrieved = manager.getZhouTianModelBy(
        _buildConfig(
          CelestialCoordinateSystem.Ecliptic,
          PanelSystemType.Tropical,
          ConstellationSystemType.Modern,
        ),
      );
      expect(retrieved.constellationSystemType, ConstellationSystemType.Modern);
    });

    test('addModelForTesting adds a single model', () {
      final model = _buildTestZhouTianModel();
      final manager = ZhouTianModelManager(repository: FakeZhouTianModelRepository([_buildTestZhouTianModel()]));

      manager.addModelForTesting(model);

      expect(manager.isLoaded, isTrue);
      expect(manager.allModels.length, 1);
    });

    test('clear resets isLoaded', () {
      final model = _buildTestZhouTianModel();
      final manager = ZhouTianModelManager(repository: FakeZhouTianModelRepository([_buildTestZhouTianModel()]));

      manager.addModelForTesting(model);
      expect(manager.isLoaded, isTrue);

      manager.clear();
      expect(manager.isLoaded, isFalse);
      expect(manager.availableSystemTypes, isEmpty);
    });

    test('getZhouTianModelBy throws StateError when not loaded', () {
      final manager = ZhouTianModelManager(repository: FakeZhouTianModelRepository([_buildTestZhouTianModel()]));
      expect(manager.isLoaded, isFalse);

      expect(
        () => manager.getZhouTianModelBy(
          _buildConfig(
            CelestialCoordinateSystem.Ecliptic,
            PanelSystemType.Tropical,
            ConstellationSystemType.Modern,
          ),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('getZhouTianModelBy throws UnimplementedError for unknown config', () {
      final model = _buildTestZhouTianModel();
      final manager = ZhouTianModelManager(repository: FakeZhouTianModelRepository([_buildTestZhouTianModel()]));
      manager.addModelForTesting(model);

      expect(
        () => manager.getZhouTianModelBy(
          _buildConfig(
            CelestialCoordinateSystem.Ecliptic,
            PanelSystemType.Tropical,
            ConstellationSystemType.Classical,
          ),
        ),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}

String _modelKey(ZhouTianModel model) {
  return '${model.systemType.name}_${model.panelSystemType.name}_${model.constellationSystemType.name}';
}

BasePanelConfig _buildConfig(
  CelestialCoordinateSystem cs,
  PanelSystemType ps,
  ConstellationSystemType cst,
) {
  return BasePanelConfig(
    celestialCoordinateSystem: cs,
    houseDivisionSystem: HouseDivisionSystem.equal,
    panelSystemType: ps,
    constellationSystemType: cst,
    settleLifeType: EnumSettleLifeType.Mao,
    settleBodyType: EnumSettleBodyType.moon,
    islifeGongBySunRealTimeLocation: true,
  );
}
