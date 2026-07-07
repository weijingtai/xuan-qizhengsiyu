import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/presentation/widgets/config/custom_config_section.dart';

void main() {
  testWidgets('逐宿覆写编辑器展开后有 TextFormField', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: CustomConfigSection(
            onConfigChanged: (_) {},
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final tileFinder = find.text('逐宿覆写');
    await tester.ensureVisible(tileFinder);
    await tester.pumpAndSettle();
    await tester.tap(tileFinder);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 验证宿名渲染和输入字段存在
    expect(find.text('角'), findsOneWidget);
    expect(find.byType(TextFormField), findsAtLeast(1));
  });
}
