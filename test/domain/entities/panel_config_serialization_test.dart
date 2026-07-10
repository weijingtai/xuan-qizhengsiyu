import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/entities/models/projection_config.dart';
import 'package:qizhengsiyu/enums/enum_zhou_tian_model.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_zero_point_ref.dart';
import 'package:qizhengsiyu/enums/enum_constellation_offset_tier.dart';
import 'package:metaphysics_core/enums.dart';

void main() {
  Map<String, dynamic> _roundtrip(BasePanelConfig config) {
    final jsonString = jsonEncode(config.toJson());
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  group('BasePanelConfig 序列化往返（含新字段）', () {
    test('zhouTianModelOverride 往返保真', () {
      final original = BasePanelConfig.defaultBasicPanelConfig().copyWith(
        zhouTianModelOverride: EnumZhouTianModel.degree36525,
      );
      final json = _roundtrip(original);
      final restored = BasePanelConfig.fromJson(json);
      expect(restored.zhouTianModelOverride, EnumZhouTianModel.degree36525);
    });

    test('projectionOverride 往返保真', () {
      final projConfig = ProjectionConfig(
        strategy: MappingStrategy.tuiBianHuangDao,
        huangChiDaoDiffType: HuangChiDaoDiffType.jiyuan,
        epsilonDeg: 23.90,
        springEquinoxAnchor: 6.0,
      );
      final original = BasePanelConfig.defaultBasicPanelConfig().copyWith(
        projectionOverride: projConfig,
      );
      final json = _roundtrip(original);
      final restored = BasePanelConfig.fromJson(json);
      expect(restored.projectionOverride?.strategy,
          MappingStrategy.tuiBianHuangDao);
      expect(restored.projectionOverride?.huangChiDaoDiffType,
          HuangChiDaoDiffType.jiyuan);
      expect(restored.projectionOverride?.epsilonDeg, 23.90);
      expect(restored.projectionOverride?.springEquinoxAnchor, 6.0);
    });

    test('两个新字段同时往返保真', () {
      final projConfig = ProjectionConfig(
        strategy: MappingStrategy.tuiBianHuangDao,
        huangChiDaoDiffType: HuangChiDaoDiffType.shoushi,
        epsilonDeg: 24.0,
        springEquinoxAnchor: 0.0,
      );
      final original = BasePanelConfig.defaultBasicPanelConfig().copyWith(
        zhouTianModelOverride: EnumZhouTianModel.degree36525,
        projectionOverride: projConfig,
      );
      final json = _roundtrip(original);
      final restored = BasePanelConfig.fromJson(json);
      expect(restored.zhouTianModelOverride, EnumZhouTianModel.degree36525);
      expect(restored.projectionOverride?.strategy,
          MappingStrategy.tuiBianHuangDao);
    });

    test('旧 JSON 缺新字段 → null 不抛异常（向后兼容）', () {
      final oldJson = <String, dynamic>{
        'celestialCoordinateSystem': '黄道制',
        'panelSystemType': '回归制',
        'constellationSystemType': '古宿制',
        'houseDivisionSystem': '等宫制',
        'settleLifeType': 'byMao',
        'settleBodyType': 'byTaiYin',
        'lifeCountingToGong': '卯',
        'bodyCountingToGong': '酉',
        'islifeGongBySunRealTimeLocation': true,
      };
      final restored = BasePanelConfig.fromJson(oldJson);
      expect(restored.zhouTianModelOverride, isNull,
          reason: '旧 JSON 不含 zhouTianModelOverride 应回 null');
      expect(restored.projectionOverride, isNull,
          reason: '旧 JSON 不含 projectionOverride 应回 null');
      expect(
          restored.celestialCoordinateSystem, CelestialCoordinateSystem.Ecliptic);
      expect(restored.panelSystemType, PanelSystemType.Tropical);
    });

    test('默认配置新字段为 null（保持默认行为）', () {
      final config = BasePanelConfig.defaultBasicPanelConfig();
      expect(config.zhouTianModelOverride, isNull);
      expect(config.projectionOverride, isNull);
    });

    test('PanelConfig 子类也透传新字段', () {
      final panelConfig = PanelConfig.defaultPanelConfig();
      expect(panelConfig.zhouTianModelOverride, isNull);
      expect(panelConfig.projectionOverride, isNull);
    });

    test('A层新字段 zeroPointRef/offsetTier/偏移/逐宿覆写 往返保真', () {
      final cfg = BasePanelConfig.defaultBasicPanelConfig().copyWith(
        zeroPointRef: EnumZeroPointRef.dongzhi,
        offsetTier: ConstellationOffsetTier.adjusted,
        constellationOffsetDeg: 14.0,
        starInnDegreeOverrides: {Enum28Constellations.Jiao_Mu_Jiao: 12.3},
      );
      final round = BasePanelConfig.fromJson(cfg.toJson());
      expect(round.zeroPointRef, EnumZeroPointRef.dongzhi);
      expect(round.offsetTier, ConstellationOffsetTier.adjusted);
      expect(round.constellationOffsetDeg, 14.0);
      expect(round.starInnDegreeOverrides?[Enum28Constellations.Jiao_Mu_Jiao], 12.3);
    });

    test('alignmentPointOverride 往返保真', () {
      final original = BasePanelConfig.defaultBasicPanelConfig().copyWith(
        alignmentPointOverride: ConstellationDegree(
            constellation: Enum28Constellations.Xu_Ri_Shu, degree: 6.0),
      );
      final json = _roundtrip(original);
      final restored = BasePanelConfig.fromJson(json);
      expect(restored.alignmentPointOverride?.constellation,
          Enum28Constellations.Xu_Ri_Shu);
      expect(restored.alignmentPointOverride?.degree, 6.0);
    });

    test('默认配置 alignmentPointOverride 为 null', () {
      expect(BasePanelConfig.defaultBasicPanelConfig().alignmentPointOverride,
          isNull);
      expect(
          PanelConfig.defaultPanelConfig().alignmentPointOverride, isNull);
    });

    test('旧 JSON 缺 A层新字段 → null，不抛异常', () {
      final legacy = BasePanelConfig.defaultBasicPanelConfig().toJson()
        ..remove('zeroPointRef')
        ..remove('offsetTier')
        ..remove('constellationOffsetDeg')
        ..remove('starInnDegreeOverrides');
      final cfg = BasePanelConfig.fromJson(legacy);
      expect(cfg.zeroPointRef, isNull);
      expect(cfg.starInnDegreeOverrides, isNull);
    });
  });
}
