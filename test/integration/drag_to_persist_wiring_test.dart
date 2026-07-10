import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;

import 'package:qizhengsiyu/data/datasources/local/app_database.dart';
import 'package:qizhengsiyu/data/datasources/local/daos/alignment_point_candidate_dao.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/star_inn_gong_degree.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/presentation/widgets/calibration/star_xiu_drag_calibration.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_constant_resources.dart';

ZhouTianModel _model() => ZhouTianModel(
      systemType: CelestialCoordinateSystem.Ecliptic,
      constellationSystemType: ConstellationSystemType.Classical,
      panelSystemType: PanelSystemType.Tropical,
      epochCorrection: 'none',
      totalDegree: 60.0,
      gongDegreeSeq: [
        GongDegree(gong: EnumTwelveGong.Zi, degree: 10),
        GongDegree(gong: EnumTwelveGong.Chou, degree: 10),
        GongDegree(gong: EnumTwelveGong.Yin, degree: 10),
        GongDegree(gong: EnumTwelveGong.Mao, degree: 10),
        GongDegree(gong: EnumTwelveGong.Chen, degree: 10),
        GongDegree(gong: EnumTwelveGong.Si, degree: 10),
      ],
      starInnDegreeSeq: [
        ConstellationDegree(
            constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 10),
        ConstellationDegree(
            constellation: Enum28Constellations.Kang_Jin_Long, degree: 20),
        ConstellationDegree(
            constellation: Enum28Constellations.Di_Tu_Lu, degree: 30),
      ],
      alignmentPointAtConstellation: ConstellationDegree(
          constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 5),
      alignmentPointAtGong: GongDegree(gong: EnumTwelveGong.Mao, degree: 0),
      zeroPointJieQi: TwentyFourJieQi.CHUN_FEN,
      zeroPointAtConstellation: ConstellationDegree(
          constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 5),
      zeroPointAtGong: GongDegree(gong: EnumTwelveGong.Mao, degree: 0),
      celestialLongitude: 0.0,
      zeroPointOffsetToNow: 0.0,
      rightAscension: 0.0,
      specificationList: const [],
      gongOrder: [
        EnumTwelveGong.Zi,
        EnumTwelveGong.Chou,
        EnumTwelveGong.Yin,
        EnumTwelveGong.Mao,
        EnumTwelveGong.Chen,
        EnumTwelveGong.Si,
      ],
      starInnOrder: [
        Enum28Constellations.Jiao_Mu_Jiao,
        Enum28Constellations.Kang_Jin_Long,
        Enum28Constellations.Di_Tu_Lu,
      ],
    );

Map<Enum28Constellations, ConstellationGongDegreeInfo> _mapper() => {
      Enum28Constellations.Jiao_Mu_Jiao: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Jiao_Mu_Jiao,
        degreeStartAt: 0, totalDegree: 10,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 0),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 10),
      ),
      Enum28Constellations.Kang_Jin_Long: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Kang_Jin_Long,
        degreeStartAt: 10, totalDegree: 20,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 10),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 0),
      ),
      Enum28Constellations.Di_Tu_Lu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Di_Tu_Lu,
        degreeStartAt: 30, totalDegree: 30,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 0),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Si, degree: 0),
      ),
    };

Map<EnumStars, Color> _colorMap() => {
      EnumStars.Sun: Colors.red, EnumStars.Moon: Colors.blue,
      EnumStars.Mars: Colors.orange, EnumStars.Jupiter: Colors.green,
      EnumStars.Mercury: Colors.purple, EnumStars.Saturn: Colors.brown,
      EnumStars.Venus: Colors.pink, EnumStars.Luo: Colors.grey,
      EnumStars.Ji: Colors.black,
    };

void main() {
  group('2-E 接线验证: 拖拽 → 配置写入 + 候选保存', () {
    testWidgets('onDragEnd 产出的值可同时写入 BasePanelConfig 和候选服务', (tester) async {
      ConstellationDegree? dragResult;
      BasePanelConfig? savedConfig;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: StarXiuDragCalibration(
              outerSize: 300,
              innerSize: 200,
              mapper: _mapper(),
              sevenZhengColorMapper: _colorMap(),
              zhouTianModel: _model(),
              initialAlignmentPoint: ConstellationDegree(
                  constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 5),
              onDragEnd: (value) {
                dragResult = value;
                // 模拟写配置: 通过 copyWith 保存 alignmentPointOverride
                savedConfig =
                    BasePanelConfig.defaultBasicPanelConfig().copyWith(
                  alignmentPointOverride: value,
                );
              },
            ),
          ),
        ),
      ));
      await tester.pump();

      final center = tester.getCenter(find.byType(StarXiuDragCalibration));
      final gesture = await tester.startGesture(center + const Offset(100, 0));
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      // onDragEnd 被调用
      expect(dragResult, isNotNull);
      expect(dragResult!.constellation, Enum28Constellations.Kang_Jin_Long);

      // 写入 config
      expect(savedConfig, isNotNull);
      expect(savedConfig!.alignmentPointOverride?.constellation,
          Enum28Constellations.Kang_Jin_Long);

      // 配置写入后，该 override 可通过序列化往返并不丢失
      final roundTripped = BasePanelConfig.fromJson(
          jsonDecode(jsonEncode(savedConfig!.toJson())) as Map<String, dynamic>);
      expect(roundTripped.alignmentPointOverride?.constellation,
          Enum28Constellations.Kang_Jin_Long);
      expect(roundTripped.alignmentPointOverride?.degree,
          closeTo(dragResult!.degree, 1e-6));
    });

    test('候选服务: save+list+delete 全链路可用', () async {
      final db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
      final service = AlignmentPointCandidateService(AlignmentPointCandidateDao(db));

      final uuid = await service.saveCandidate(
        name: '手动标定点',
        alignmentPoint: ConstellationDegree(
            constellation: Enum28Constellations.Xu_Ri_Shu, degree: 1.6275),
        sourceNote: '来自拖拽校准',
      );

      final all = await service.listAll();
      expect(all.length, 1);
      expect(all.first.uuid, uuid);

      await service.delete(uuid);
      expect((await service.listAll()).length, 0);

      await db.close();
    });
  });
}
