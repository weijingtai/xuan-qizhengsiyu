import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/presentation/widgets/config/custom_config_section.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/projection_config.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_zhou_tian_model.dart';

void main() {
  Widget _buildTestWidget({PanelConfig? initialConfig}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: CustomConfigSection(
            initialConfig: initialConfig,
            onConfigChanged: (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('坐标系出现 4 个选项文案', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('黄道制'), findsOneWidget);
    expect(find.text('赤道制'), findsOneWidget);
    expect(find.text('天赤道制'), findsOneWidget);
    expect(find.text('似黄道恒星制'), findsOneWidget);
  });

  testWidgets('出现周天制与黄赤道换算/起点/偏移量/星宿类型卡标题', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('周天制与黄赤道换算'), findsOneWidget);
    expect(find.text('起点与偏移'), findsOneWidget);
    expect(find.text('星宿类型'), findsOneWidget);
  });

  testWidgets('出现宫位划分控件并包含三辰通载子午不等宫', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('宫位划分'), findsOneWidget);

    final dropdown = find.byWidgetPredicate(
      (w) => w is DropdownButtonFormField<HouseDivisionSystem>,
    );
    await tester.ensureVisible(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    expect(find.text('三辰通载子午'), findsWidgets);
  });

  testWidgets('选推变黄道后下拉含弧矢割圆术选项', (WidgetTester tester) async {
    // 先 pump 默认 widget，再 tap 古黄道以触发联动推荐默认
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CustomConfigSection(onConfigChanged: (_) {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 点选 似黄道恒星制 → 联动 _autoFillRecommendedDefaults 填 tuiBianHuangDao
    final pseudoRadio = find.text('似黄道恒星制');
    await tester.ensureVisible(pseudoRadio);
    await tester.pumpAndSettle();
    await tester.tap(pseudoRadio);
    await tester.pumpAndSettle();

    // 打开推变黄道算法下拉
    final diffDropdown = find.byWidgetPredicate(
      (w) => w is DropdownButtonFormField<HuangChiDaoDiffType>,
    );
    await tester.ensureVisible(diffDropdown);
    await tester.pumpAndSettle();
    await tester.tap(diffDropdown);
    await tester.pumpAndSettle();

    // 下拉菜单中应有弧矢割圆术
    expect(find.text('弧矢割圆术'), findsOneWidget, reason: '推变黄道算法子选项中应包含弧矢割圆术');
  });

  testWidgets('矛盾组合（黄道 + 365.25）出警告条', (WidgetTester tester) async {
    final cfg = PanelConfig(
      celestialCoordinateSystem: CelestialCoordinateSystem.Ecliptic,
      houseDivisionSystem: HouseDivisionSystem.equal,
      panelSystemType: PanelSystemType.Tropical,
      constellationSystemType: ConstellationSystemType.Classical,
      settleLifeType: EnumSettleLifeType.Mao,
      settleBodyType: EnumSettleBodyType.moon,
      islifeGongBySunRealTimeLocation: true,
      zhouTianModelOverride: EnumZhouTianModel.degree36525,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CustomConfigSection(
              initialConfig: cfg,
              onConfigChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 警告条应包含冲突文案
    expect(find.textContaining('与古度 365.25 冲突'), findsOneWidget);
    // 一键归正按钮应存在
    expect(find.text('一键归正'), findsOneWidget);
  });
}
