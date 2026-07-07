import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/presentation/widgets/config/custom_config_section.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';

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

  testWidgets('出现周天制与黄赤道换算/起点/偏移量/星宿类型卡标题',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('周天制与黄赤道换算'), findsOneWidget);
    expect(find.text('起点与偏移'), findsOneWidget);
    expect(find.text('星宿类型'), findsOneWidget);
  });
}
