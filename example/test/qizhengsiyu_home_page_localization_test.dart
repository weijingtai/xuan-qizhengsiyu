// ignore_for_file: lines_longer_than_80_chars

/// 回归测试：QiZhengSiYuHomePage 在 MaterialApp 配置
/// `localizationsDelegates: AppLocalizations.localizationsDelegates` 后
/// 能正常构建，不再抛 `TypeErrorImpl: Unexpected null value`。
///
/// 背景：页面内 `AppLocalizations.of(context)!.geJuRulesDesc` 用 `!` 强解包，
/// 若 MaterialApp 未注册 AppLocalizations delegate，Localizations.of 返回 null
/// → 构建期抛 null。本测试模拟真实装配（与 example/lib/main.dart 相同配置），
/// 若有人再次移除 delegates，本测试立即变红。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/l10n/generated/app_localizations.dart';
import 'package:qizhengsiyu/presentation/pages/qizhengsiyu_home_page.dart';

void main() {
  testWidgets('QiZhengSiYuHomePage 在配置 localizationsDelegates 后构建不抛 null',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const QiZhengSiYuHomePage(),
      ),
    );

    // 构建成功（无异常抛出）；页面标题与入口卡片可见。
    expect(find.text('七政四余'), findsOneWidget);
    expect(find.text('命盘排盘'), findsOneWidget);
    expect(find.text('格局管理'), findsOneWidget);
  });
}
