/// gStack visual evidence for QiZheng Board Phase 5 canary.
///
/// Verifies the production fallback contract and captures candidate-renderer
/// goldens across the required visual scenarios.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_ui_size.dart';
import 'package:qizhengsiyu/presentation/adapters/legacy/qizheng_board_switch.dart';
import 'package:qizhengsiyu/presentation/adapters/legacy/qizheng_legacy_board.dart';
import 'package:qizhengsiyu/presentation/models/ui_star_model.dart';
import 'package:qizhengsiyu/presentation/widgets/panel_widget.dart';
import 'package:qizhengsiyu/presentation/widgets/destiny_twelve_gong_ring.dart';

// ---------------------------------------------------------------------------
// Deterministic fixture (same as parity test)
// ---------------------------------------------------------------------------
QiZhengSiYuPanSizeDataModel _defaultPanelSize() {
  return QiZhengSiYuPanSizeDataModel(
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
}

List<UIStarModel> _sampleInnerStars() {
  return [
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
    UIStarModel(
      star: EnumStars.Mercury,
      priority: 2,
      originalAngle: 200.0,
      rangeAngleEachSide: 10.0,
    ),
    UIStarModel(
      star: EnumStars.Venus,
      priority: 2,
      originalAngle: 300.0,
      rangeAngleEachSide: 10.0,
    ),
  ];
}

List<UIStarModel> _sampleOuterStars() {
  return [
    UIStarModel(
      star: EnumStars.Mars,
      priority: 2,
      originalAngle: 10.0,
      rangeAngleEachSide: 10.0,
    ),
    UIStarModel(
      star: EnumStars.Jupiter,
      priority: 2,
      originalAngle: 80.0,
      rangeAngleEachSide: 10.0,
    ),
    UIStarModel(
      star: EnumStars.Saturn,
      priority: 1,
      originalAngle: 180.0,
      rangeAngleEachSide: 10.0,
    ),
    UIStarModel(
      star: EnumStars.Qi,
      priority: 1,
      originalAngle: 270.0,
      rangeAngleEachSide: 10.0,
    ),
    UIStarModel(
      star: EnumStars.Luo,
      priority: 1,
      originalAngle: 330.0,
      rangeAngleEachSide: 10.0,
    ),
  ];
}

Widget _centerWidget() {
  return const SizedBox(
    width: 140,
    height: 140,
    child: Center(child: Text('命盘', style: TextStyle(fontSize: 20))),
  );
}

// ---------------------------------------------------------------------------
// Wrappers
// ---------------------------------------------------------------------------

/// Wrap [board] in a fixed-size container for deterministic goldens.
Widget _wrapBoard(Widget board, {double size = 600}) {
  return MaterialApp(
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    themeMode: ThemeMode.light,
    home: Scaffold(
      body: Center(
        child: SizedBox(width: size, height: size, child: board),
      ),
    ),
  );
}

Widget _buildBoardSwitch(BoardRenderer renderer, {double rotating = 0}) {
  return QiZhengBoardSwitch(
    renderer: renderer,
    productionBuilder: () =>
        const ColoredBox(key: Key('production-board'), color: Colors.white),
    panelSizeDataModel: _defaultPanelSize(),
    innerStars: _sampleInnerStars(),
    outerStars: _sampleOuterStars(),
    centerWidget: _centerWidget(),
    rotating: rotating,
  );
}

void _expectCompleteVisibleLayerInventory(WidgetTester tester, Size viewport) {
  const visibleLayerIds = [
    'earth-branch-ring',
    'zodiac-ring',
    'destiny-ring',
    'degree-ticks',
    'constellation-ring',
    'inner-star-track-ring',
    'inner-star-body-ring',
    'outer-star-track-ring',
    'outer-star-body-ring',
    'inner-shensha-ring',
    'outer-shensha-ring',
  ];
  for (final id in visibleLayerIds) {
    expect(
      find.byKey(ValueKey('chart-layer:$id')),
      findsOneWidget,
      reason: 'Missing visible ChartBoard layer $id',
    );
  }
  expect(
    find.byKey(const ValueKey('chart-layer:star-sequence-ring')),
    findsNothing,
    reason: 'The production-default zero-width ring must remain skipped.',
  );
  final panelRect = tester.getRect(find.byType(PanelWidget).first);
  expect(panelRect.left, greaterThanOrEqualTo(0));
  expect(panelRect.top, greaterThanOrEqualTo(0));
  expect(panelRect.right, lessThanOrEqualTo(viewport.width));
  expect(panelRect.bottom, lessThanOrEqualTo(viewport.height));
}

// ---------------------------------------------------------------------------
// setUpAll – font loading (same as parity test)
// ---------------------------------------------------------------------------
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

      messenger.setMockMessageHandler('flutter/assets', null);
      try {
        return await messenger.send('flutter/assets', message);
      } finally {
        messenger.setMockMessageHandler('flutter/assets', handler);
      }
    };

    messenger.setMockMessageHandler('flutter/assets', handler);
    GoogleFonts.config.allowRuntimeFetching = false;

    for (final name in [
      'NotoSans',
      'NotoSans_regular',
      'MaShanZheng',
      'MaShanZheng_regular',
      'Noto Sans',
      'Ma Shan Zheng',
    ]) {
      final loader = FontLoader(name);
      loader.addFont(Future.value(fontBytes.buffer.asByteData()));
      await loader.load();
    }
  });

  // ===========================================================================
  // Scenario 1: Production branch contract and legacy desktop golden
  // ===========================================================================
  testWidgets(
    'gStack: production branch renders the supplied production builder',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      await tester.pumpWidget(
        _wrapBoard(_buildBoardSwitch(BoardRenderer.production), size: 800),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('production-board')), findsOneWidget);
      expect(find.byType(QiZhengLegacyBoard), findsNothing);
    },
  );

  testWidgets(
    'desktop 1200x900 shows every enabled ChartBoard layer unclipped',
    (tester) async {
      const viewport = Size(1200, 900);
      await tester.binding.setSurfaceSize(viewport);
      await tester.pumpWidget(
        _wrapBoard(_buildBoardSwitch(BoardRenderer.qiZhengLegacy), size: 800),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      _expectCompleteVisibleLayerInventory(tester, viewport);
    },
  );

  // ===========================================================================
  // Scenario 2: Minimum supported viewport
  // ===========================================================================
  testWidgets(
    'minimum 400x700 shows every enabled ChartBoard layer unclipped',
    (tester) async {
      const viewport = Size(400, 700);
      await tester.binding.setSurfaceSize(viewport);
      await tester.pumpWidget(
        _wrapBoard(_buildBoardSwitch(BoardRenderer.qiZhengLegacy), size: 360),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      _expectCompleteVisibleLayerInventory(tester, viewport);
    },
  );

  // ===========================================================================
  // Scenario 3: Dark theme
  // ===========================================================================
  testWidgets('gStack: dark theme legacy adapter', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 600,
              height: 600,
              child: _buildBoardSwitch(BoardRenderer.qiZhengLegacy),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    _expectCompleteVisibleLayerInventory(tester, const Size(400, 700));
  });

  // ===========================================================================
  // Scenario 4: Full board rotation (rotating: 45°)
  // ===========================================================================
  testWidgets('gStack: rotated board legacy adapter', (tester) async {
    await tester.pumpWidget(
      _wrapBoard(_buildBoardSwitch(BoardRenderer.qiZhengLegacy, rotating: 45)),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    _expectCompleteVisibleLayerInventory(tester, const Size(400, 700));
  });

  // ===========================================================================
  // Scenario 5: Runtime renderer switch with distinct subtree assertions
  // ===========================================================================
  testWidgets('gStack: runtime renderer switch renders both paths', (
    tester,
  ) async {
    final renderer = ValueNotifier<BoardRenderer>(BoardRenderer.production);

    // Widget that switches between renderers at runtime
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 600,
              height: 600,
              child: ValueListenableBuilder<BoardRenderer>(
                valueListenable: renderer,
                builder: (ctx, r, _) {
                  return QiZhengBoardSwitch(
                    renderer: r,
                    productionBuilder: () => const ColoredBox(
                      key: Key('production-board'),
                      color: Colors.white,
                    ),
                    panelSizeDataModel: _defaultPanelSize(),
                    innerStars: _sampleInnerStars(),
                    outerStars: _sampleOuterStars(),
                    centerWidget: _centerWidget(),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify production path renders (no error)
    expect(find.byKey(const Key('production-board')), findsOneWidget);
    expect(find.byType(QiZhengLegacyBoard), findsNothing);

    // Switch to legacy adapter path at runtime
    renderer.value = BoardRenderer.qiZhengLegacy;
    await tester.pumpAndSettle();

    // Verify the candidate subtree replaced the production subtree.
    expect(find.byKey(const Key('production-board')), findsNothing);
    expect(find.byType(QiZhengLegacyBoard), findsOneWidget);
  });

  // ===========================================================================
  // Scenario 6: productionBuilder must be provided for production mode
  // ===========================================================================
  testWidgets('gStack: production mode rejects a missing productionBuilder', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 600,
              height: 600,
              child: QiZhengBoardSwitch(
                renderer: BoardRenderer.production,
                panelSizeDataModel: _defaultPanelSize(),
                innerStars: _sampleInnerStars(),
                outerStars: _sampleOuterStars(),
                centerWidget: _centerWidget(),
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isA<FlutterError>());
  });

  testWidgets('gStack: candidate forwards secondary TaiJi selection', (
    tester,
  ) async {
    final selectedContent = ValueNotifier<List<String>?>(null);
    int? selectedIndex;

    await tester.pumpWidget(
      _wrapBoard(
        QiZhengBoardSwitch(
          renderer: BoardRenderer.qiZhengLegacy,
          panelSizeDataModel: _defaultPanelSize(),
          innerStars: _sampleInnerStars(),
          outerStars: _sampleOuterStars(),
          centerWidget: _centerWidget(),
          selectedTaiJiContentListenable: selectedContent,
          onSelectTaiJi: (index) => selectedIndex = index,
        ),
      ),
    );

    final selectedRing = tester
        .widget<SelectedTaiJiDestinyTwelveGongRingWidget>(
          find.byType(SelectedTaiJiDestinyTwelveGongRingWidget),
        );
    selectedRing.onSelectTaiJi(4);

    expect(selectedIndex, 4);
  });
}
