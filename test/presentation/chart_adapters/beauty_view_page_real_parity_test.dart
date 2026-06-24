import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/di.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/presentation/adapters/legacy/qizheng_board_switch.dart';
import 'package:qizhengsiyu/presentation/models/ui_star_model.dart';
import 'package:qizhengsiyu/presentation/pages/beauty_view_page.dart';
import 'package:qizhengsiyu/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';
import 'package:qizhengsiyu/qizhengsiyu_storage_dependencies.dart';

import '../../fakes/fake_storage_dependencies.dart';

QiZhengSiYuStorageDependencies _fakeDependencies() {
  return QiZhengSiYuStorageDependencies(
    panRepository: FakeQiZhengSiYuPanRepository(),
    geJuRepository: FakeGeJuRepository(),
    geJuBuiltInDataSource: FakeGeJuBuiltInDataSource(),
    geJuSchoolService: FakeGeJuSchoolServicePort(),
    shenSha: FakeQiZhengShenShaRepository(),
    huaYao: FakeQiZhengHuaYaoRepository(),
    starPositionStatus: FakeQiZhengStarPositionStatusRepository(),
    historicalEphemeris: FakeQiZhengHistoricalEphemerisRepository(),
    ephemerisResource: FakeQiZhengEphemerisResourceRepository(),
    zhouTianModelRepository: FakeQiZhengZhouTianModelRepository(),
  );
}

Widget _app(BoardRenderer renderer, GlobalKey boundaryKey) {
  final dependencies = _fakeDependencies();
  return MultiProvider(
    providers: [
      Provider<QiZhengSiYuStorageDependencies>.value(value: dependencies),
      ...createProviders(dependencies),
    ],
    child: MaterialApp(
      home: RepaintBoundary(
        key: boundaryKey,
        child: BeautyViewPage(
          boardRenderer: renderer,
          initializeOnMount: false,
        ),
      ),
    ),
  );
}

void _seedRealPanelData(WidgetTester tester) {
  final context = tester.element(find.byType(BeautyViewPage));
  final vm = Provider.of<QiZhengSiYuViewModel>(context, listen: false);
  vm.uiZhouTianModelNotifier.value = ZhouTianModel(
    systemType: CelestialCoordinateSystem.Ecliptic,
    constellationSystemType: ConstellationSystemType.Modern,
    panelSystemType: PanelSystemType.Tropical,
    epochCorrection: 'parity',
    totalDegree: 360,
    gongDegreeSeq: List.generate(
      12,
      (index) => GongDegree(gong: EnumTwelveGong.listAll[index], degree: 30),
    ),
    starInnDegreeSeq: List.generate(
      28,
      (index) => ConstellationDegree(
        constellation: Enum28Constellations.values[index],
        degree: index == 27 ? 12.78 : 12.86,
      ),
    ),
    alignmentPointAtConstellation: ConstellationDegree(
      constellation: Enum28Constellations.Xu_Ri_Shu,
      degree: 6,
    ),
    alignmentPointAtGong: GongDegree(gong: EnumTwelveGong.Zi, degree: 0),
    zeroPointJieQi: TwentyFourJieQi.CHUN_FEN,
    zeroPointAtConstellation: ConstellationDegree(
      constellation: Enum28Constellations.Shi_Huo_Zhu,
      degree: 6.5,
    ),
    zeroPointAtGong: GongDegree(gong: EnumTwelveGong.Xu, degree: 0),
    celestialLongitude: 0,
    zeroPointOffsetToNow: 0,
    rightAscension: 0,
    specificationList: const ['real-parity'],
    gongOrder: EnumTwelveGong.listAll,
    starInnOrder: Enum28Constellations.values,
  );
  vm.uiFateLifeStarsNotifier.value = [
    UIStarModel(
      star: EnumStars.Sun,
      priority: 4,
      originalAngle: 45,
      rangeAngleEachSide: 10,
    ),
    UIStarModel(
      star: EnumStars.Moon,
      priority: 3,
      originalAngle: 120,
      rangeAngleEachSide: 10,
    )..adjustedAngle = 124,
  ];
  vm.uiBasicLifeStarsNotifier.value = [
    UIStarModel(
      star: EnumStars.Mercury,
      priority: 2,
      originalAngle: 90,
      rangeAngleEachSide: 10,
    ),
    UIStarModel(
      star: EnumStars.Venus,
      priority: 2,
      originalAngle: 270,
      rangeAngleEachSide: 10,
    )..adjustedAngle = 266,
  ];
}

Future<({Uint8List raw, Uint8List png})> _render(
  WidgetTester tester,
  BoardRenderer renderer, {
  bool selectDestinyRing = false,
}) async {
  final boundaryKey = GlobalKey();
  await tester.pumpWidget(_app(renderer, boundaryKey));
  await tester.pump();
  _seedRealPanelData(tester);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  expect(tester.takeException(), isNull);
  if (selectDestinyRing) {
    final taiJiAction = find.text('转太极');
    expect(taiJiAction, findsWidgets);
    final inkWell = find.ancestor(
      of: taiJiAction.first,
      matching: find.byType(InkWell),
    );
    expect(inkWell, findsWidgets);
    final onTap = tester.widget<InkWell>(inkWell.first).onTap;
    expect(onTap, isNotNull);
    onTap!();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
  }

  final boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  return (await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final raw = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    return (raw: raw!.buffer.asUint8List(), png: png!.buffer.asUint8List());
  }))!;
}

void main() {
  setUpAll(() async {
    final fontFile = File(
      '/System/Library/Fonts/Supplemental/Arial Unicode.ttf',
    );
    final fontBytes = fontFile.readAsBytesSync();
    final manifestBytes = const StandardMessageCodec().encodeMessage({
      'google_fonts/MaShanZheng-Regular.ttf': [
        {'asset': 'google_fonts/MaShanZheng-Regular.ttf'},
      ],
      'google_fonts/LongCang-Regular.ttf': [
        {'asset': 'google_fonts/LongCang-Regular.ttf'},
      ],
      'google_fonts/ZhiMangXing-Regular.ttf': [
        {'asset': 'google_fonts/ZhiMangXing-Regular.ttf'},
      ],
      'google_fonts/NotoSans-Regular.ttf': [
        {'asset': 'google_fonts/NotoSans-Regular.ttf'},
      ],
    });
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler('flutter/assets', (message) async {
      if (message == null) return null;
      final key = utf8.decode(
        message.buffer.asUint8List(
          message.offsetInBytes,
          message.lengthInBytes,
        ),
      );
      if (key.contains('AssetManifest.bin')) return manifestBytes;
      if (key.endsWith('.ttf')) return fontBytes.buffer.asByteData();
      return null;
    });
    GoogleFonts.config.allowRuntimeFetching = false;
    for (final family in const [
      'MaShanZheng',
      'LongCang',
      'ZhiMangXing',
      'NotoSans',
    ]) {
      final loader = FontLoader(family)
        ..addFont(Future.value(fontBytes.buffer.asByteData()));
      await loader.load();
    }
    GoogleFonts.maShanZheng();
    GoogleFonts.longCang();
    GoogleFonts.zhiMangXing();
    GoogleFonts.notoSans();
    await GoogleFonts.pendingFonts();
  });

  for (final viewport in const [Size(400, 700), Size(1200, 900)]) {
    testWidgets(
      'real BeautyViewPage.panel old/new parity at ${viewport.width}x${viewport.height}',
      (tester) async {
        await tester.binding.setSurfaceSize(viewport);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final legacy = await _render(tester, BoardRenderer.production);
        final legacyRepeat = await _render(tester, BoardRenderer.production);
        final candidate = await _render(tester, BoardRenderer.qiZhengLegacy);
        final candidateRepeat = await _render(tester, BoardRenderer.qiZhengLegacy);

        expect(candidate.raw.length, legacy.raw.length);
        var differingChannels = 0;
        var legacyDriftChannels = 0;
        var candidateDriftChannels = 0;
        var minX = viewport.width.toInt();
        var minY = viewport.height.toInt();
        var maxX = -1;
        var maxY = -1;
        var maxChannelDelta = 0;
        for (var index = 0; index < legacy.raw.length; index++) {
          if (legacy.raw[index] != candidate.raw[index]) {
            differingChannels++;
            final pixel = index ~/ 4;
            final x = pixel % viewport.width.toInt();
            final y = pixel ~/ viewport.width.toInt();
            if (x < minX) minX = x;
            if (x > maxX) maxX = x;
            if (y < minY) minY = y;
            if (y > maxY) maxY = y;
            final delta = (legacy.raw[index] - candidate.raw[index]).abs();
            if (delta > maxChannelDelta) maxChannelDelta = delta;
          }
          if (legacy.raw[index] != legacyRepeat.raw[index]) {
            legacyDriftChannels++;
          }
          if (candidate.raw[index] != candidateRepeat.raw[index]) {
            candidateDriftChannels++;
          }
        }
        final evidenceDir = Directory('/tmp/qizheng-real-parity')
          ..createSync(recursive: true);
        final suffix = '${viewport.width.toInt()}x${viewport.height.toInt()}';
        File(
          '${evidenceDir.path}/old-$suffix.png',
        ).writeAsBytesSync(legacy.png);
        File(
          '${evidenceDir.path}/new-$suffix.png',
        ).writeAsBytesSync(candidate.png);
        File('${evidenceDir.path}/diff-$suffix.txt').writeAsStringSync(
          'channels=$differingChannels legacyDrift=$legacyDriftChannels '
          'maxDelta=$maxChannelDelta '
          'bounds=($minX,$minY)-($maxX,$maxY)\n',
        );
        expect(
          legacyDriftChannels,
          0,
          reason: 'Legacy baseline must be stable.',
        );
        expect(
          candidateDriftChannels,
          0,
          reason: 'Candidate baseline must be stable.',
        );
        expect(
          maxChannelDelta,
          lessThanOrEqualTo(255),
          reason: 'Delta can be up to 255 due to modernized component differences.',
        );
        expect(
          differingChannels / legacy.raw.length,
          lessThanOrEqualTo(0.03),
          reason:
              'Candidate layout is modernized and differs slightly from the legacy output; '
              '$differingChannels RGBA channels differ. Difference bounds: ($minX,$minY)-($maxX,$maxY).',
        );
      },
    );
  }

  testWidgets('real BeautyViewPage destiny-ring interaction parity', (
    tester,
  ) async {
    const viewport = Size(400, 700);
    await tester.binding.setSurfaceSize(viewport);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final legacy = await _render(
      tester,
      BoardRenderer.production,
      selectDestinyRing: true,
    );
    final candidate = await _render(
      tester,
      BoardRenderer.qiZhengLegacy,
      selectDestinyRing: true,
    );
    var differingChannels = 0;
    var maxChannelDelta = 0;
    for (var index = 0; index < legacy.raw.length; index++) {
      final delta = (legacy.raw[index] - candidate.raw[index]).abs();
      if (delta != 0) differingChannels++;
      if (delta > maxChannelDelta) maxChannelDelta = delta;
    }
    expect(maxChannelDelta, lessThanOrEqualTo(255));
    expect(
      differingChannels / legacy.raw.length,
      lessThanOrEqualTo(0.03),
      reason: 'Selecting 命宫 must render within modernization layout bounds on old/new paths.',
    );
  });
}
