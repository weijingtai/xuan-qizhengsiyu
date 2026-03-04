// AI 对话页面 — 基于 xuan-ai 的 AiChatView

import 'package:ai_core/widgets/ai_chat_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_chat_controller.dart';

/// AI 对话页面。
///
/// 直接使用 xuan-ai 的 [AiChatView] 渲染聊天界面，
/// 状态由 [AiChatController] 集中管理。
///
/// 当 [AiChatController.refreshKey] 变化时（识别结果注入后），
/// [AiChatView] 以 [ValueKey] 强制重建，加载最新 DB 历史。
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AiChatController>();

    if (!controller.isInitialized) {
      if (controller.error != null) {
        return Scaffold(
          appBar: AppBar(title: const Text('AI 对话')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    '初始化失败',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    controller.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '请检查 API Key 和 Base URL 配置是否正确。',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final persona = controller.persona;
    final sessionUuid = controller.sessionUuid;

    if (persona == null || sessionUuid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI 对话')),
        body: const Center(
          child: Text('配置错误，请检查 API Key 和模型设置。'),
        ),
      );
    }

    return AiChatView(
      key: ValueKey(controller.refreshKey),
      persona: persona,
      sessionUuid: sessionUuid,
      db: controller.db,
      aiService: controller.aiService,
      history: controller.history,
      welcomeMessage: '您好！我是格局助手。\n\n'
          '您可以在这里查看所有 AI 识别记录，也可以直接提问。',
    );
  }
}
