import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/spec/si_yu_group_spec.dart';
import 'package:qizhengsiyu/presentation/widgets/config/si_yu_group_editor.dart';

void main() {
  testWidgets('编辑某四余组并回调 spec', (tester) async {
    SiYuGroupSpec? picked;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SiYuGroupEditor(
          group: SiYuGroup.ziQi,
          spec: const SiYuGroupSpec(
            kind: 'linear_ziqi',
            params: {'dailyMotion': 0.0352},
          ),
          coordinate: CelestialCoordinateSystem.Ecliptic,
          onChanged: (spec) => picked = spec,
        ),
      ),
    ));

    // 应能显示推算类型 dropdown 并含有 linear_ziqi 等
    expect(find.text('果老紫气平行'), findsOneWidget);

    // Find textfield with label text '日行度数 (dailyMotion)'
    final dailyMotionFinder = find.ancestor(
      of: find.text('0.0352'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(dailyMotionFinder, '0.04');
    await tester.pump();

    expect(picked, isNotNull);
    expect(picked!.params['dailyMotion'], 0.04);
  });
}
