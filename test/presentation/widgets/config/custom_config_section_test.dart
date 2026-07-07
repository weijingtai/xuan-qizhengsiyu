import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';
import 'package:qizhengsiyu/presentation/widgets/config/custom_config_section.dart';

void main() {
  testWidgets('CustomConfigSection renders Rahu/Ketu definition and reacts to changes',
      (WidgetTester tester) async {
    PanelConfig? callbackConfig;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CustomConfigSection(
              initialConfig: PanelConfig.defaultPanelConfig(),
              onConfigChanged: (cfg) {
                callbackConfig = cfg;
              },
            ),
          ),
        ),
      ),
    );

    // Verify widget builds
    expect(find.text('罗计升降交点定义'), findsOneWidget);
    expect(find.text('罗降计升（古法）'), findsOneWidget);
    expect(find.text('罗升计降（新法）'), findsOneWidget);

    // Initial state check
    expect(callbackConfig, isNull);

    // Tap on the new convention
    final newConventionRadio = find.byWidgetPredicate(
      (w) => w is RadioListTile<EnumRahuKetuConvention> &&
          w.subtitle is Text &&
          (w.subtitle as Text).data!.contains('清后期'),
    );
    await tester.ensureVisible(newConventionRadio);
    await tester.pumpAndSettle();
    await tester.tap(newConventionRadio);
    await tester.pumpAndSettle();

    // Verify callback was triggered and updated config to new convention
    expect(callbackConfig, isNotNull);
    expect(
        callbackConfig!.rahuKetuConvention, EnumRahuKetuConvention.luoShengJiJiang);

    // Warning text should be visible when new convention is selected
    expect(find.text('与古法正统罗计相反、吉凶互换，仅供比对参考！'), findsOneWidget);
  });
}
