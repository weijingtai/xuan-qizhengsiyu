import 'dart:math';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qizhengsiyu/presentation/widgets/panel_widget.dart';
import 'package:qizhengsiyu/presentation/widgets/ring_layer.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/shen_sha.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_ui_size.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/painter/chart_style/chart_style_resolver.dart';
import 'package:qizhengsiyu/presentation/adapters/legacy/qizheng_legacy_board.dart';
import 'package:qizhengsiyu/presentation/models/ui_star_model.dart';
import 'package:qizhengsiyu/presentation/widgets/destiny_twelve_gong_ring.dart';
import 'package:qizhengsiyu/presentation/widgets/rings/gong_12_dizhi.dart';
import 'package:qizhengsiyu/presentation/widgets/rings/gong_shen_sha_ring.dart';
import 'package:qizhengsiyu/presentation/widgets/twelve_gong_default_ring.dart';
import 'package:qizhengsiyu/presentation/widgets/twelve_gong_grid_ring.dart';
import 'package:qizhengsiyu/painter/painters.dart';
import 'package:qizhengsiyu/painter/star_xiu_ring_painter.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_constant_resources.dart';
import 'package:metaphysics_chart_ui/metaphysics_chart_ui.dart'
    hide
        InnerStarBodyRotatingWidget,
        InnerStarTrackRingWidget,
        OuterStarBodyRotatingWidget,
        OuterStarTrackRingWidget,
        PanelWidget,
        RingLayer,
        StarRingLayer,
        TwelveGongGridRingWidget;
import 'package:qizhengsiyu/presentation/widgets/star_body.dart';

void main() {
  setUpAll(() async {
    final systemFont = File(
      '/System/Library/Fonts/Supplemental/Arial Unicode.ttf',
    );
    final fontFile = systemFont.existsSync()
        ? systemFont
        : File(
            '/Users/jingtaiwei/Git/Public/xuan-migration/xuan-qizhengsiyu/build/unit_test_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf',
          );
    final fontBytes = fontFile.readAsBytesSync();

    final manifestBytes = const StandardMessageCodec().encodeMessage({
      'google_fonts/NotoSans-Regular.ttf': [
        {'asset': 'google_fonts/NotoSans-Regular.ttf'},
      ],
      'google_fonts/MaShanZheng-Regular.ttf': [
        {'asset': 'google_fonts/MaShanZheng-Regular.ttf'},
      ],
    });

    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    Future<ByteData?>? Function(ByteData?)? handler;

    handler = (ByteData? message) async {
      if (message == null) return null;
      final list = message.buffer.asUint8List(
        message.offsetInBytes,
        message.lengthInBytes,
      );
      final key = utf8.decode(list);
      if (key == 'AssetManifest.bin' || key.contains('AssetManifest.bin')) {
        return manifestBytes;
      }
      if (key.endsWith('.ttf') || key.contains('.ttf')) {
        return fontBytes.buffer.asByteData();
      }

      // Temporarily remove mock handler and delegate to real channel
      messenger.setMockMessageHandler('flutter/assets', null);
      try {
        return await messenger.send('flutter/assets', message);
      } finally {
        messenger.setMockMessageHandler('flutter/assets', handler);
      }
    };

    messenger.setMockMessageHandler('flutter/assets', handler);
    GoogleFonts.config.allowRuntimeFetching = false;

    // Synchronously register fonts so they are instantly ready
    final fontLoader1 = FontLoader('NotoSans');
    fontLoader1.addFont(Future.value(fontBytes.buffer.asByteData()));
    await fontLoader1.load();

    final fontLoader1Reg = FontLoader('NotoSans_regular');
    fontLoader1Reg.addFont(Future.value(fontBytes.buffer.asByteData()));
    await fontLoader1Reg.load();

    final fontLoader2 = FontLoader('MaShanZheng');
    fontLoader2.addFont(Future.value(fontBytes.buffer.asByteData()));
    await fontLoader2.load();

    final fontLoader2Reg = FontLoader('MaShanZheng_regular');
    fontLoader2Reg.addFont(Future.value(fontBytes.buffer.asByteData()));
    await fontLoader2Reg.load();

    final fontLoader3 = FontLoader('Noto Sans');
    fontLoader3.addFont(Future.value(fontBytes.buffer.asByteData()));
    await fontLoader3.load();

    final fontLoader4 = FontLoader('Ma Shan Zheng');
    fontLoader4.addFont(Future.value(fontBytes.buffer.asByteData()));
    await fontLoader4.load();
  });

  group('QiZheng Legacy Board Parity & Sensitivity Tests', () {
    // Generate deterministic test fixture
    final panelSizeDataModel = QiZhengSiYuPanSizeDataModel(
      starBodyRadius: 16,
      centerSize: 140,
      diZhi12GongHeight: 50,
      zodiac12GongHeight: 24,
      starSeq12GongHeight: 0,
      destiny12GongHeight: 70,
      lifeStarRingHeight: 48,
      starXiu28RingHeight: 36,
      innerShenShaHeight: 90,
      outerShenShaHeight: 90,
      showFateLifeStarRing: true,
    );

    final innerStars = [
      UIStarModel(
        star: EnumStars.Sun,
        priority: 4,
        originalAngle: 45.0,
        rangeAngleEachSide: 10.0,
      ),
      UIStarModel(
        star: EnumStars.Moon,
        priority: 3,
        originalAngle: 120.0,
        rangeAngleEachSide: 10.0,
      ),
    ];

    final outerStars = [
      UIStarModel(
        star: EnumStars.Mercury,
        priority: 2,
        originalAngle: 90.0,
        rangeAngleEachSide: 10.0,
      ),
      UIStarModel(
        star: EnumStars.Venus,
        priority: 2,
        originalAngle: 270.0,
        rangeAngleEachSide: 10.0,
      ),
    ];

    final zhouTianModel = ZhouTianModel(
      systemType: CelestialCoordinateSystem.Ecliptic,
      constellationSystemType: ConstellationSystemType.Modern,
      panelSystemType: PanelSystemType.Tropical,
      epochCorrection: 'default',
      totalDegree: 360.0,
      gongDegreeSeq: List.generate(
        12,
        (i) => GongDegree(gong: EnumTwelveGong.listAll[i], degree: 30.0),
      ),
      starInnDegreeSeq: List.generate(
        28,
        (i) => ConstellationDegree(
          constellation: Enum28Constellations.values[i],
          degree: i < 27 ? 12.86 : 12.78,
        ),
      ),
      alignmentPointAtConstellation: ConstellationDegree(
        constellation: Enum28Constellations.Xu_Ri_Shu,
        degree: 6.0,
      ),
      alignmentPointAtGong: GongDegree(gong: EnumTwelveGong.Zi, degree: 0.0),
      zeroPointJieQi: TwentyFourJieQi.CHUN_FEN,
      zeroPointAtConstellation: ConstellationDegree(
        constellation: Enum28Constellations.Shi_Huo_Zhu,
        degree: 6.5,
      ),
      zeroPointAtGong: GongDegree(gong: EnumTwelveGong.Xu, degree: 0.0),
      celestialLongitude: 0.0,
      zeroPointOffsetToNow: 0.0,
      rightAscension: 0.0,
      specificationList: const ['baseline'],
      gongOrder: EnumTwelveGong.listAll,
      starInnOrder: Enum28Constellations.values,
    );

    final innerShenShaMapper = {
      EnumTwelveGong.Zi: [ShenSha("TaiSui", JiXiongEnum.JI, null, null)],
      EnumTwelveGong.Chou: [ShenSha("SuiPo", JiXiongEnum.XIONG, null, null)],
    };

    final outerShenShaMapper = {
      EnumTwelveGong.Zi: [ShenSha("TianXi", JiXiongEnum.DA_JI, null, null)],
      EnumTwelveGong.Chou: [ShenSha("HongLuan", JiXiongEnum.JI, null, null)],
    };

    final allStarsShowNotifier = ValueNotifier<bool>(true);

    testWidgets(
      'Live visual parity between old composition and unified adapter',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1052, 1052));
        final boundaryKeyRef = GlobalKey();
        final boundaryKeyCand = GlobalKey();

        // Render the Legacy Production Board (Reference)
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: RepaintBoundary(
                  key: boundaryKeyRef,
                  child: SizedBox(
                    width: 1052,
                    height: 1052,
                    child: LegacyProductionBoard(
                      panelSizeDataModel: panelSizeDataModel,
                      innerStars: innerStars,
                      outerStars: outerStars,
                      centerWidget: const Text('Center'),
                      zhouTianModel: zhouTianModel,
                      innerShenShaMapper: innerShenShaMapper,
                      outerShenShaMapper: outerShenShaMapper,
                      allStarsShowNotifier: allStarsShowNotifier,
                      rotating: 15.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final Uint8List refBytes =
            await tester.runAsync(() async {
                  final boundary =
                      boundaryKeyRef.currentContext!.findRenderObject()
                          as RenderRepaintBoundary;
                  final ui.Image img = await boundary.toImage(pixelRatio: 1.0);
                  final ByteData? bd = await img.toByteData(
                    format: ui.ImageByteFormat.rawRgba,
                  );
                  return bd!.buffer.asUint8List();
                })
                as Uint8List;

        // Render the QiZhengLegacyBoard (Candidate)
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: RepaintBoundary(
                  key: boundaryKeyCand,
                  child: SizedBox(
                    width: 1052,
                    height: 1052,
                    child: QiZhengLegacyBoard(
                      panelSizeDataModel: panelSizeDataModel,
                      innerStars: innerStars,
                      outerStars: outerStars,
                      centerWidget: const Text('Center'),
                      zhouTianModel: zhouTianModel,
                      innerShenShaMapper: innerShenShaMapper,
                      outerShenShaMapper: outerShenShaMapper,
                      allStarsShowNotifier: allStarsShowNotifier,
                      rotating: 15.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final Uint8List candBytes =
            await tester.runAsync(() async {
                  final boundary =
                      boundaryKeyCand.currentContext!.findRenderObject()
                          as RenderRepaintBoundary;
                  final ui.Image img = await boundary.toImage(pixelRatio: 1.0);
                  final ByteData? bd = await img.toByteData(
                    format: ui.ImageByteFormat.rawRgba,
                  );
                  return bd!.buffer.asUint8List();
                })
                as Uint8List;

        // Assert strict pixel equivalence: exactly zero differing bytes
        int diffCount = 0;
        for (int i = 0; i < candBytes.length; i++) {
          if ((candBytes[i] - refBytes[i]).abs() > 0) {
            diffCount++;
          }
        }
        expect(
          diffCount,
          equals(0),
          reason: 'Pixel parity failed: $diffCount differing bytes',
        );
      },
    );

    testWidgets('Sensitivity Test: visual parity fails when inputs differ', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1052, 1052));
      final boundaryKeyRef = GlobalKey();
      final boundaryKeyCand = GlobalKey();

      // Legacy Board with rotating = 15.0
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: boundaryKeyRef,
                child: SizedBox(
                  width: 1052,
                  height: 1052,
                  child: LegacyProductionBoard(
                    panelSizeDataModel: panelSizeDataModel,
                    innerStars: innerStars,
                    outerStars: outerStars,
                    centerWidget: const Text('Center'),
                    zhouTianModel: zhouTianModel,
                    innerShenShaMapper: innerShenShaMapper,
                    outerShenShaMapper: outerShenShaMapper,
                    allStarsShowNotifier: allStarsShowNotifier,
                    rotating: 15.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Uint8List refBytes =
          await tester.runAsync(() async {
                final boundary =
                    boundaryKeyRef.currentContext!.findRenderObject()
                        as RenderRepaintBoundary;
                final ui.Image img = await boundary.toImage(pixelRatio: 1.0);
                final ByteData? bd = await img.toByteData(
                  format: ui.ImageByteFormat.rawRgba,
                );
                return bd!.buffer.asUint8List();
              })
              as Uint8List;

      // QiZhengLegacyBoard with rotating = 45.0 (differs)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: boundaryKeyCand,
                child: SizedBox(
                  width: 1052,
                  height: 1052,
                  child: QiZhengLegacyBoard(
                    panelSizeDataModel: panelSizeDataModel,
                    innerStars: innerStars,
                    outerStars: outerStars,
                    centerWidget: const Text('Center'),
                    zhouTianModel: zhouTianModel,
                    innerShenShaMapper: innerShenShaMapper,
                    outerShenShaMapper: outerShenShaMapper,
                    allStarsShowNotifier: allStarsShowNotifier,
                    rotating: 45.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Uint8List candBytes =
          await tester.runAsync(() async {
                final boundary =
                    boundaryKeyCand.currentContext!.findRenderObject()
                        as RenderRepaintBoundary;
                final ui.Image img = await boundary.toImage(pixelRatio: 1.0);
                final ByteData? bd = await img.toByteData(
                  format: ui.ImageByteFormat.rawRgba,
                );
                return bd!.buffer.asUint8List();
              })
              as Uint8List;

      // Assert that differences are captured
      expect(candBytes, isNot(equals(refBytes)));
    });

    // Star-sequence ring enabled scenario
    testWidgets('Parity with star-sequence ring enabled', (
      WidgetTester tester,
    ) async {
      final starSeqPanelSizeDataModel = QiZhengSiYuPanSizeDataModel(
        starBodyRadius: 16,
        centerSize: 140,
        diZhi12GongHeight: 50,
        zodiac12GongHeight: 24,
        starSeq12GongHeight: 24, // enabled with same height as zodiac
        destiny12GongHeight: 70,
        lifeStarRingHeight: 48,
        starXiu28RingHeight: 36,
        innerShenShaHeight: 90,
        outerShenShaHeight: 90,
        showFateLifeStarRing: true,
      );

      const double canvasSize = 1100;
      await tester.binding.setSurfaceSize(const Size(canvasSize, canvasSize));
      final boundaryKeyRef = GlobalKey();
      final boundaryKeyCand = GlobalKey();

      // Legacy Production Board with star-seq enabled
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: boundaryKeyRef,
                child: SizedBox(
                  width: canvasSize,
                  height: canvasSize,
                  child: LegacyProductionBoard(
                    panelSizeDataModel: starSeqPanelSizeDataModel,
                    innerStars: innerStars,
                    outerStars: outerStars,
                    centerWidget: const Text('Center'),
                    zhouTianModel: zhouTianModel,
                    innerShenShaMapper: innerShenShaMapper,
                    outerShenShaMapper: outerShenShaMapper,
                    allStarsShowNotifier: allStarsShowNotifier,
                    rotating: 15.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Uint8List refBytes =
          await tester.runAsync(() async {
                final boundary =
                    boundaryKeyRef.currentContext!.findRenderObject()
                        as RenderRepaintBoundary;
                final ui.Image img = await boundary.toImage(pixelRatio: 1.0);
                final ByteData? bd = await img.toByteData(
                  format: ui.ImageByteFormat.rawRgba,
                );
                return bd!.buffer.asUint8List();
              })
              as Uint8List;

      // QiZhengLegacyBoard with star-seq enabled
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: boundaryKeyCand,
                child: SizedBox(
                  width: canvasSize,
                  height: canvasSize,
                  child: QiZhengLegacyBoard(
                    panelSizeDataModel: starSeqPanelSizeDataModel,
                    innerStars: innerStars,
                    outerStars: outerStars,
                    centerWidget: const Text('Center'),
                    zhouTianModel: zhouTianModel,
                    innerShenShaMapper: innerShenShaMapper,
                    outerShenShaMapper: outerShenShaMapper,
                    allStarsShowNotifier: allStarsShowNotifier,
                    rotating: 15.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Uint8List candBytes =
          await tester.runAsync(() async {
                final boundary =
                    boundaryKeyCand.currentContext!.findRenderObject()
                        as RenderRepaintBoundary;
                final ui.Image img = await boundary.toImage(pixelRatio: 1.0);
                final ByteData? bd = await img.toByteData(
                  format: ui.ImageByteFormat.rawRgba,
                );
                return bd!.buffer.asUint8List();
              })
              as Uint8List;

      // Strict pixel parity: exactly zero differing pixels
      int diffCount = 0;
      for (int i = 0; i < candBytes.length; i++) {
        if ((candBytes[i] - refBytes[i]).abs() > 0) {
          diffCount++;
        }
      }
      expect(
        diffCount,
        equals(0),
        reason: 'Star-seq ring parity: $diffCount differing bytes',
      );
    });

    testWidgets(
      'StarTrackBand migration preserves innerStars and outerStars on separate sides with correct properties',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: QiZhengLegacyBoard(
                panelSizeDataModel: panelSizeDataModel,
                innerStars: innerStars,
                outerStars: outerStars,
                centerWidget: const Text('Center'),
                zhouTianModel: zhouTianModel,
                rotating: 15.0,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final bands = tester.widgetList<StarTrackBand>(find.byType(StarTrackBand)).toList();
        expect(bands, hasLength(2), reason: 'Should have two StarTrackBand instances');

        final innerBand = bands[0];
        final outerBand = bands[1];

        // Verify inner band properties
        expect(innerBand.innerRadius, equals(panelSizeDataModel.innerLifeStarRingInnerSize / 2));
        expect(innerBand.degreeTrackWidth, equals((panelSizeDataModel.innerLifeStarRingOuterSize - panelSizeDataModel.innerLifeStarRingTrackSize) / 2));
        expect(innerBand.innerStarRing, isNotNull);
        expect(innerBand.outerStarRing, isNull);
        expect(innerBand.startAngleOffset, equals(15.0));
        expect(innerBand.direction, equals(AngularDirection.counterClockwise));

        final innerItems = innerBand.innerStarRing!.items;
        expect(innerItems, hasLength(innerStars.length));
        for (int i = 0; i < innerStars.length; i++) {
          final star = innerStars[i];
          final item = innerItems.firstWhere((it) => it.id == star.star.name);
          expect(item.displayDegree, equals(star.angle));
          expect(item.markerDegree, equals(star.originalAngle));
          expect(item.indicatorStyle, isNotNull);
          // Verify child is StarBody
          expect(find.descendant(of: find.byWidget(innerBand), matching: find.byType(StarBody)), findsNWidgets(2));
        }

        // Verify outer band properties
        expect(outerBand.innerRadius, equals(panelSizeDataModel.outerLifeStarRingInnerSize / 2));
        expect(outerBand.degreeTrackWidth, equals((panelSizeDataModel.outerLifeStarRingTrackSize - panelSizeDataModel.outerLifeStarRingInnerSize) / 2));
        expect(outerBand.innerStarRing, isNull);
        expect(outerBand.outerStarRing, isNotNull);
        expect(outerBand.startAngleOffset, equals(15.0));
        expect(outerBand.direction, equals(AngularDirection.counterClockwise));

        final outerItems = outerBand.outerStarRing!.items;
        expect(outerItems, hasLength(outerStars.length));
        for (int i = 0; i < outerStars.length; i++) {
          final star = outerStars[i];
          final item = outerItems.firstWhere((it) => it.id == star.star.name);
          expect(item.displayDegree, equals(star.angle));
          expect(item.markerDegree, equals(star.originalAngle));
          expect(item.indicatorStyle, isNotNull);
          expect(find.descendant(of: find.byWidget(outerBand), matching: find.byType(StarBody)), findsNWidgets(2));
        }
      },
    );
  });
}

// ---------------------------------------------------------------------------
// Legacy Production Board Widget built from original page logic
// ---------------------------------------------------------------------------
class LegacyProductionBoard extends StatelessWidget {
  final QiZhengSiYuPanSizeDataModel panelSizeDataModel;
  final List<UIStarModel> innerStars;
  final List<UIStarModel> outerStars;
  final Widget centerWidget;
  final ZhouTianModel? zhouTianModel;
  final List<String>? destinyContentList;
  final TextStyle? destinyTextStyle;
  final Map<EnumTwelveGong, List<ShenSha>>? innerShenShaMapper;
  final Map<EnumTwelveGong, List<ShenSha>>? outerShenShaMapper;
  final ValueNotifier<bool>? allStarsShowNotifier;
  final double rotating;

  const LegacyProductionBoard({
    super.key,
    required this.panelSizeDataModel,
    required this.innerStars,
    required this.outerStars,
    required this.centerWidget,
    this.zhouTianModel,
    this.destinyContentList,
    this.destinyTextStyle,
    this.innerShenShaMapper,
    this.outerShenShaMapper,
    this.allStarsShowNotifier,
    this.rotating = 0,
  });

  @override
  Widget build(BuildContext context) {
    final styleResolver = const FallbackChartStyleResolver();
    final chartStyle = styleResolver.resolve(Brightness.light);
    final palette = styleResolver.resolvePalette(Brightness.light);

    final TextStyle firstTextStyle = TextStyle(
      fontSize: 18,
      height: 1.0,
      color: Colors.black87,
      shadows: const [
        Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 3),
      ],
    );
    final TextStyle secondTextStyle = TextStyle(
      fontSize: 12,
      height: 1.0,
      color: Colors.black87,
      shadows: const [
        Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 3),
      ],
    );

    return PanelWidget(
      canvasSize: panelSizeDataModel.outerShenShaSizeOuter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(angle: -30 * pi / 180, child: centerWidget),

          // 1. 十二地支宫
          RingLayer(
            showTrack: false,
            showGrid: false,
            gridBuilder: () => TwelveGongGridRingWidget(
              innerSize: panelSizeDataModel.diZhi12GongInner,
              outerSize: panelSizeDataModel.diZhi12GongOuter,
            ),
            bodyRotationAngle: -30 * pi / 180,
            bodyBuilder: () {
              if (zhouTianModel == null) return const SizedBox();
              return Gong12DiZhiRing(
                zhouTianModel: zhouTianModel!,
                outerRadius: panelSizeDataModel.diZhi12GongOuter * 0.5,
                innerRadius: panelSizeDataModel.diZhi12GongInner * 0.5,
                shenShaMapper: {
                  EnumTwelveGong.Zi: [
                    Text("子", style: firstTextStyle),
                    Text("坎", style: secondTextStyle),
                    Text("土", style: secondTextStyle),
                  ],
                  EnumTwelveGong.Chou: [
                    Text("丑", style: firstTextStyle),
                    Text("艮", style: secondTextStyle),
                    Text("土", style: secondTextStyle),
                  ],
                  EnumTwelveGong.Yin: [
                    Text("寅", style: firstTextStyle),
                    Text("艮", style: secondTextStyle),
                    Text("木", style: secondTextStyle),
                  ],
                  EnumTwelveGong.Mao: [
                    Text("卯", style: firstTextStyle),
                    Text("震", style: secondTextStyle),
                    Text("火", style: secondTextStyle),
                  ],
                  EnumTwelveGong.Chen: [
                    Text("辰", style: firstTextStyle),
                    Text("巽", style: secondTextStyle),
                    Text("金", style: secondTextStyle),
                  ],
                  EnumTwelveGong.Si: [
                    Text("巳", style: firstTextStyle),
                    Text("巽", style: secondTextStyle),
                    Text("水", style: secondTextStyle),
                  ],
                  EnumTwelveGong.Wu: [
                    Text("午", style: firstTextStyle),
                    Text("离", style: secondTextStyle),
                    Text("日", style: secondTextStyle),
                  ],
                  EnumTwelveGong.Wei: [
                    Text("未", style: firstTextStyle),
                    Text("坤", style: secondTextStyle),
                    Text("月", style: secondTextStyle),
                  ],
                  EnumTwelveGong.Shen: [
                    Text("申", style: firstTextStyle),
                    Text("坤", style: secondTextStyle),
                    Text("水", style: secondTextStyle),
                  ],
                  EnumTwelveGong.You: [
                    Text("酉", style: firstTextStyle),
                    Text("兑", style: secondTextStyle),
                    Text("金", style: secondTextStyle),
                  ],
                  EnumTwelveGong.Xu: [
                    Text("戌", style: firstTextStyle),
                    Text("乾", style: secondTextStyle),
                    Text("火", style: secondTextStyle),
                  ],
                  EnumTwelveGong.Hai: [
                    Text("亥", style: firstTextStyle),
                    Text("乾", style: secondTextStyle),
                    Text("木", style: secondTextStyle),
                  ],
                },
              );
            },
          ),

          // 2. 黄道十二宫
          RingLayer(
            showTrack: false,
            showGrid: false,
            gridBuilder: () => TwelveGongGridRingWidget(
              innerSize: panelSizeDataModel.zodiac12GongSizeInner,
              outerSize: panelSizeDataModel.zodiac12GongSizeOuter,
            ),
            bodyRotationAngle: -30 * pi / 180,
            bodyBuilder: () => generateDefault12GongRing(
              panelSizeDataModel.zodiac12GongSizeInner * 0.5,
              panelSizeDataModel.zodiac12GongSizeOuter * 0.5,
              QiZhengLegacyBoard.defaultZodiac12GongMapper,
            ),
          ),

          // 3. 星序宫
          if (panelSizeDataModel.starSeq12GongHeight > 0)
            RingLayer(
              showTrack: false,
              showGrid: false,
              gridBuilder: () => TwelveGongGridRingWidget(
                innerSize: panelSizeDataModel.starSeq12GongSizeInner,
                outerSize: panelSizeDataModel.starSeq12GongSizeOuter,
              ),
              bodyRotationAngle: -30 * pi / 180,
              bodyBuilder: () => generateDefault12GongRing(
                panelSizeDataModel.starSeq12GongSizeInner * 0.5,
                panelSizeDataModel.starSeq12GongSizeOuter * 0.5,
                QiZhengLegacyBoard.defaultStarSeq12GongMapper,
              ),
            ),

          // 4. 命理十二宫
          RingLayer(
            showTrack: false,
            showGrid: true,
            gridBuilder: () => TwelveGongGridRingWidget(
              innerSize: panelSizeDataModel.destiny12GongSizeInner,
              outerSize: panelSizeDataModel.destiny12GongSizeOuter,
            ),
            bodyRotationAngle: -30 * pi / 180,
            bodyBuilder: () {
              final contentList =
                  destinyContentList ?? QiZhengLegacyBoard.defaultDestinyList;
              final style =
                  destinyTextStyle ??
                  GoogleFonts.maShanZheng(
                    color: Colors.black87,
                    fontSize: 28,
                    fontWeight: FontWeight.normal,
                    height: 1.0,
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  );
              return DestinyTwelveGongRingWidget(
                innerSize: panelSizeDataModel.destiny12GongSizeInner,
                outerSize: panelSizeDataModel.destiny12GongSizeOuter,
                contentList: contentList,
                textStyle: style,
                onSelectTaiJiByGongName: (_) {},
                onUnselectTaiJi: () {},
              );
            },
          ),

          // 4. 二十八星宿环
          RingLayer(
            showTrack: true,
            showGrid: false,
            trackRotationAngle: rotating * pi / 180,
            trackBuilder: () => Container(
              width: panelSizeDataModel.starXiu28RingSizeOuter,
              height: panelSizeDataModel.starXiu28RingSizeOuter,
              alignment: Alignment.center,
              child: CustomPaint(
                size: Size(
                  panelSizeDataModel.starXiu28RingSizeOuter,
                  panelSizeDataModel.starXiu28RingSizeOuter,
                ),
                painter: IndicatorScalePainter(
                  ringWidth: 40,
                  tickLength: 7,
                  indicatorAngle: 45.1,
                  style: chartStyle,
                ),
              ),
            ),
            gridBuilder: () => TwelveGongGridRingWidget(
              innerSize: panelSizeDataModel.starXiu28RingSizeInner,
              outerSize: panelSizeDataModel.starXiu28RingSizeOuter,
            ),
            bodyRotationAngle: rotating * pi / 180,
            bodyBuilder: () => RepaintBoundary(
              child: Container(
                width: panelSizeDataModel.starXiu28RingSizeOuter,
                height: panelSizeDataModel.starXiu28RingSizeOuter,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(
                    panelSizeDataModel.starXiu28RingSizeOuter * 0.5,
                  ),
                ),
                child: CustomPaint(
                  size: Size(
                    panelSizeDataModel.starXiu28RingSizeOuter,
                    panelSizeDataModel.starXiu28RingSizeOuter,
                  ),
                  painter: StarXiuRingPainter(
                    outerSize: panelSizeDataModel.starXiu28RingSizeOuter,
                    innerSize: panelSizeDataModel.starXiu28RingSizeInner,
                    mapper: QiZhengSiYuConstantResources
                        .ZodiacTropicalModernStarsInnSystemMapper,
                    sevenZhengColorMapper: palette.zhengColorMap,
                    style: chartStyle,
                  ),
                ),
              ),
            ),
          ),

          // 5 & 6. Inner Star Track & Body (represented by fateLifeStars in old code)
          StarTrackBand(
            innerRadius: panelSizeDataModel.innerLifeStarRingInnerSize / 2,
            degreeTrackWidth: (panelSizeDataModel.innerLifeStarRingOuterSize -
                    panelSizeDataModel.innerLifeStarRingTrackSize) /
                2,
            innerStarRing: StarBodyRingSpec(
              width: (panelSizeDataModel.innerLifeStarRingTrackSize -
                      panelSizeDataModel.innerLifeStarRingInnerSize) /
                  2,
              items: innerStars.map((s) {
                final color = palette.starColor(s.star);
                final textStyle = GoogleFonts.notoSans(
                  fontSize: 24.0,
                  height: 1,
                  color: color,
                  fontWeight: FontWeight.normal,
                  shadows: [
                    BoxShadow(
                      color: Colors.black38.withValues(alpha: .3),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(1, 1),
                    )
                  ],
                );
                return StarBodyRingItem(
                  id: s.star.name,
                  child: StarBody(
                    starBody: s,
                    starSize: panelSizeDataModel.starBodyRadius * 2,
                    allStarsShowNotifier:
                        allStarsShowNotifier ?? ValueNotifier<bool>(false),
                    textStyle: textStyle,
                  ),
                  displayDegree: s.angle,
                  markerDegree: s.originalAngle,
                  indicatorStyle: StarIndicatorStyle(
                    color: color,
                    strokeWidth: 0.5,
                    markerRadius: 2.0,
                  ),
                );
              }).toList(),
            ),
            degreeTrackStyle: DegreeTrackStyle(
              minorLength: 0,
              mediumLength: 0,
              majorLength: 0,
              color: chartStyle.colors.border,
              strokeWidth: 0.5,
            ),
            startAngleOffset: rotating,
            direction: AngularDirection.counterClockwise,
          ),

          // 7 & 8. Outer Star Track & Body (represented by basicLifeStars in old code)
          StarTrackBand(
            innerRadius: panelSizeDataModel.outerLifeStarRingInnerSize / 2,
            degreeTrackWidth: (panelSizeDataModel.outerLifeStarRingTrackSize -
                    panelSizeDataModel.outerLifeStarRingInnerSize) /
                2,
            outerStarRing: StarBodyRingSpec(
              width: (panelSizeDataModel.outerLifeStarRingOuterSize -
                      panelSizeDataModel.outerLifeStarRingTrackSize) /
                  2,
              items: outerStars.map((s) {
                final color = palette.starColor(s.star);
                final textStyle = GoogleFonts.notoSans(
                  fontSize: 24.0,
                  height: 1,
                  color: color,
                  fontWeight: FontWeight.normal,
                  shadows: [
                    BoxShadow(
                      color: Colors.black38.withValues(alpha: .3),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(1, 1),
                    )
                  ],
                );
                return StarBodyRingItem(
                  id: s.star.name,
                  child: StarBody(
                    starBody: s,
                    starSize: panelSizeDataModel.starBodyRadius * 2,
                    allStarsShowNotifier:
                        allStarsShowNotifier ?? ValueNotifier<bool>(false),
                    textStyle: textStyle,
                  ),
                  displayDegree: s.angle,
                  markerDegree: s.originalAngle,
                  indicatorStyle: StarIndicatorStyle(
                    color: color,
                    strokeWidth: 0.5,
                    markerRadius: 2.0,
                  ),
                );
              }).toList(),
            ),
            degreeTrackStyle: DegreeTrackStyle(
              minorLength: 0,
              mediumLength: 0,
              majorLength: 0,
              color: chartStyle.colors.border,
              strokeWidth: 0.5,
            ),
            startAngleOffset: rotating,
            direction: AngularDirection.counterClockwise,
          ),

          // 9. Inner ShenSha
          RingLayer(
            showTrack: false,
            showGrid: false,
            gridBuilder: () => TwelveGongGridRingWidget(
              innerSize: panelSizeDataModel.innerShenShaSizeInner,
              outerSize: panelSizeDataModel.innerShenShaSizeOuter,
            ),
            bodyRotationAngle: -30 * pi / 180,
            bodyBuilder: () {
              if (innerShenShaMapper == null || zhouTianModel == null) {
                return const SizedBox();
              }
              return AllShenShaRing(
                outerRadius: panelSizeDataModel.innerShenShaSizeOuter * 0.5,
                innerRadius: panelSizeDataModel.innerShenShaSizeInner * 0.5,
                shenShaMapper: innerShenShaMapper!,
                gongOrder: EnumTwelveGong.listAll,
                zhouTianModel: zhouTianModel!,
              );
            },
          ),

          // 10. Outer ShenSha
          RingLayer(
            showTrack: false,
            showGrid: false,
            gridBuilder: () => TwelveGongGridRingWidget(
              innerSize: panelSizeDataModel.outerShenShaSizeInner,
              outerSize: panelSizeDataModel.outerShenShaSizeOuter,
            ),
            bodyRotationAngle: -30 * pi / 180,
            bodyBuilder: () {
              if (outerShenShaMapper == null || zhouTianModel == null) {
                return const SizedBox();
              }
              return AllShenShaRing(
                outerRadius: panelSizeDataModel.outerShenShaSizeOuter * 0.5,
                innerRadius: panelSizeDataModel.outerShenShaSizeInner * 0.5,
                shenShaMapper: outerShenShaMapper!,
                gongOrder: EnumTwelveGong.listAll,
                zhouTianModel: zhouTianModel!,
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mock Http Overrides to intercept GoogleFonts download and return mock font bytes
// ---------------------------------------------------------------------------
class TestHttpOverrides extends HttpOverrides {
  final Uint8List fontBytes;
  TestHttpOverrides(this.fontBytes);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return TestHttpClient(fontBytes);
  }
}

class TestHttpClient implements HttpClient {
  final Uint8List fontBytes;
  TestHttpClient(this.fontBytes);

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return TestHttpClientRequest(fontBytes);
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return TestHttpClientRequest(fontBytes);
  }

  @override
  set connectionTimeout(Duration? value) {}
  @override
  set userAgent(String? value) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestHttpClientRequest implements HttpClientRequest {
  final Uint8List fontBytes;
  TestHttpClientRequest(this.fontBytes);

  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  bool persistentConnection = true;

  @override
  int contentLength = 0;

  @override
  bool bufferOutput = true;

  @override
  final HttpHeaders headers = TestHttpHeaders();

  @override
  void add(List<int> data) {}

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future addStream(Stream<List<int>> stream) async {}

  @override
  void write(Object? object) {}

  @override
  void writeAll(Iterable objects, [String separator = ""]) {}

  @override
  void writeCharCode(int charCode) {}

  @override
  void writeln([Object? object = ""]) {}

  @override
  Future<HttpClientResponse> get done async =>
      TestHttpClientResponse(fontBytes);

  @override
  Future<HttpClientResponse> close() async {
    return TestHttpClientResponse(fontBytes);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestHttpHeaders implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void forEach(void Function(String name, List<String> values) action) {}

  @override
  List<String>? operator [](String name) => null;

  @override
  String? value(String name) => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestHttpClientResponse implements HttpClientResponse {
  final Uint8List fontBytes;
  TestHttpClientResponse(this.fontBytes);

  @override
  final HttpHeaders headers = TestHttpHeaders();

  @override
  int get statusCode => 200;

  @override
  bool get isRedirect => false;

  @override
  String get reasonPhrase => "OK";

  @override
  List<RedirectInfo> get redirects => const [];

  @override
  bool get persistentConnection => true;

  @override
  int get contentLength => fontBytes.length;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([fontBytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
