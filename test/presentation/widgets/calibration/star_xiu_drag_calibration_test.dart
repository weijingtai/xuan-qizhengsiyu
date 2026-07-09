import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';

import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/entities/models/star_inn_gong_degree.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/presentation/widgets/calibration/star_xiu_drag_calibration.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_constant_resources.dart';

ZhouTianModel _threeConstellationModel() => ZhouTianModel(
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

const _panelType = StarPanelType.ZodiacTropicalModernStarsInnSystemMapper;

Map<Enum28Constellations, ConstellationGongDegreeInfo> _simpleMapper() => {
      Enum28Constellations.Jiao_Mu_Jiao: ConstellationGongDegreeInfo(
        starType: _panelType,
        starXiu: Enum28Constellations.Jiao_Mu_Jiao,
        degreeStartAt: 0,
        totalDegree: 10,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 0),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 10),
      ),
      Enum28Constellations.Kang_Jin_Long: ConstellationGongDegreeInfo(
        starType: _panelType,
        starXiu: Enum28Constellations.Kang_Jin_Long,
        degreeStartAt: 10,
        totalDegree: 20,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 10),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 0),
      ),
      Enum28Constellations.Di_Tu_Lu: ConstellationGongDegreeInfo(
        starType: _panelType,
        starXiu: Enum28Constellations.Di_Tu_Lu,
        degreeStartAt: 30,
        totalDegree: 30,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 0),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Si, degree: 0),
      ),
    };

Map<EnumStars, Color> _simpleColorMap() => {
      EnumStars.Sun: Colors.red,
      EnumStars.Moon: Colors.blue,
      EnumStars.Mars: Colors.orange,
      EnumStars.Jupiter: Colors.green,
      EnumStars.Mercury: Colors.purple,
      EnumStars.Saturn: Colors.brown,
      EnumStars.Venus: Colors.pink,
      EnumStars.Luo: Colors.grey,
      EnumStars.Ji: Colors.black,
    };

void main() {
  group('StarXiuDragCalibration Widget', () {
    Widget buildWidget({
      bool enabled = true,
      ValueChanged<ConstellationDegree>? onDragEnd,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: StarXiuDragCalibration(
              outerSize: 300,
              innerSize: 200,
              mapper: _simpleMapper(),
              sevenZhengColorMapper: _simpleColorMap(),
              zhouTianModel: _threeConstellationModel(),
              initialAlignmentPoint: ConstellationDegree(
                  constellation: Enum28Constellations.Jiao_Mu_Jiao,
                  degree: 5),
              enabled: enabled,
              onDragEnd: onDragEnd,
            ),
          ),
        ),
      );
    }

    testWidgets('初始时读数不显示（未拖拽）', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.byType(StarXiuDragCalibration), findsOneWidget);
      expect(find.textContaining('当前:'), findsNothing);
    });

    testWidgets('拖拽后实时读数出现', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      final widgetCenter = tester.getCenter(find.byType(StarXiuDragCalibration));

      // 从圆心右侧 100px 处顺时针拖拽 90°
      final gesture = await tester.startGesture(
        widgetCenter + const Offset(100, 0),
      );
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      // 顺时针 π/4 从角5° → 亢2.50°
      expect(find.textContaining('当前:'), findsOneWidget);
      expect(find.textContaining('亢'), findsOneWidget);
      expect(find.textContaining('2.50'), findsOneWidget);
    });

    testWidgets('禁用手势时拖拽不响应', (tester) async {
      await tester.pumpWidget(buildWidget(enabled: false));
      await tester.pump();

      final widgetCenter = tester.getCenter(find.byType(StarXiuDragCalibration));

      await tester.timedDragFrom(
        widgetCenter + const Offset(100, 0),
        const Offset(0, -100),
        const Duration(milliseconds: 100),
      );
      await tester.pump();

      expect(find.textContaining('当前:'), findsNothing);
    });

    testWidgets('拖拽结束后 onDragEnd 回调被调用并传递正确对齐点', (tester) async {
      ConstellationDegree? recorded;
      await tester.pumpWidget(buildWidget(
        onDragEnd: (v) => recorded = v,
      ));
      await tester.pump();

      final widgetCenter = tester.getCenter(find.byType(StarXiuDragCalibration));

      final gesture = await tester.startGesture(
        widgetCenter + const Offset(100, 0),
      );
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(recorded, isNotNull);
      // 顺时针 π/4 = 7.5° → 角5° + 7.5° = 12.5° → 亢2.50°
      expect(recorded!.constellation, Enum28Constellations.Kang_Jin_Long);
      expect(recorded!.degree, closeTo(2.5, 0.1));
    });

    testWidgets('多次拖拽累积生效', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      final widgetCenter = tester.getCenter(find.byType(StarXiuDragCalibration));

      // 第一段拖拽
      var gesture = await tester.startGesture(
        widgetCenter + const Offset(100, 0),
      );
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      // 第一段后应显示亢2.50°
      expect(find.textContaining('2.50'), findsOneWidget);

      // 第二段拖拽（继续用上次结束位置）
      gesture = await tester.startGesture(
        widgetCenter + const Offset(100, 100),
      );
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      // 星宿名应已更换（累计角度已跨过亢）
      final textFinder = find.textContaining('当前:');
      expect(textFinder, findsOneWidget);
    });

    testWidgets('Widget 正常渲染', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byType(StarXiuDragCalibration), findsOneWidget);
    });
  });
}
