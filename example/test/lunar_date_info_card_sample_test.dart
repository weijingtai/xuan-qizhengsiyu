import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/presentation/widgets/lunar_date_info_card_v2.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../lib/lunar_date_info_card_sample.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('renders the deterministic lunar date information card', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(432, 240));
    tester.binding.platformDispatcher.textScaleFactorTestValue = 0.75;
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.binding.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(const LunarDateInfoCardSampleApp());

    expect(find.byType(LunarDateInfoCardV2), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('2023年12月27日'), findsOneWidget);
    expect(find.text('甲子年 冬月十五日 子时'), findsOneWidget);
    expect(find.text('冬至 12/22', findRichText: true), findsOneWidget);
    expect(find.text('日出'), findsOneWidget);
    expect(find.text('月落'), findsOneWidget);
    expect(find.text('05:17'), findsOneWidget);
    expect(find.text('18:42'), findsOneWidget);
    expect(find.text('09:44'), findsOneWidget);
    expect(find.text('23:44'), findsOneWidget);
    expect(find.text('经度 116.4074°, 纬度 39.9042°'), findsOneWidget);
    expect(find.text('时区: Asia/Shanghai'), findsOneWidget);
    expect(find.text('静态示例'), findsOneWidget);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
