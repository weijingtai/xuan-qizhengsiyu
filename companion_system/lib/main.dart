/// 主应用入口

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:companion_system/providers/rule_provider.dart';
import 'package:companion_system/providers/settings_provider.dart';
import 'package:companion_system/providers/ai_chat_controller.dart';
import 'package:companion_system/pages/main_page.dart';
import 'package:companion_system/database/drift_database.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      Provider<AppDatabase>(
        create: (ctx) => AppDatabase(),
        dispose: (ctx, db) => db.close(),
      ),
      ChangeNotifierProvider<RuleProvider>(
        create: (ctx) => RuleProvider(ctx.read<AppDatabase>()),
      ),
      ChangeNotifierProvider<SettingsProvider>(
        create: (ctx) => SettingsProvider()..load(),
      ),
      // AiChatController 依赖 SettingsProvider，使用 ProxyProvider 自动跟随配置变化
      ChangeNotifierProxyProvider<SettingsProvider, AiChatController>(
        create: (_) => AiChatController(),
        update: (_, settings, controller) {
          controller!.onSettingsChanged(settings);
          return controller;
        },
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '七政四余格局数据维护系统',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
