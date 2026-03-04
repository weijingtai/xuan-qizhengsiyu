/// AI 对话控制器 — 管理 xuan-ai 聊天 Session，同时承担 AI 识别的 LLM 调用

import 'dart:convert';

import 'package:ai_core/database/ai_database.dart';
import 'package:ai_core/models/chat_message_model.dart' as ai_msg;
import 'package:ai_core/services/ai_service_impl.dart';
import 'package:ai_core/services/chat/chat_persistence_service.dart';
import 'package:ai_core/services/llm/llm_service.dart' as ai_llm;
import 'package:common/domain/ai/resolved_persona.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_provider.dart';

const _kNvidiaProviderUuid = 'cmpn0001-0000-0000-0000-000000000001';
const _kNvidiaModelUuid    = 'cmpn0001-0000-0000-0000-000000000002';
const _kNvidiaPersonaUuid  = 'cmpn0001-0000-0000-0000-000000000003';
const _kChatSessionKey = 'companion_chat_session_uuid';

/// 管理 xuan-ai 聊天 Session 的控制器。
///
/// 在 companion_system 中充当适配层：
/// 1. 在 [AiDatabase] 中自动 Bootstrap 一个 Nvidia NIM Provider/Model/Persona
/// 2. 创建或恢复一个持久化的 Chat Session
/// 3. 提供 [recognizeCondition] 通过 xuan-ai Session LLM 将自然语言转换为格局条件 JSON
class AiChatController extends ChangeNotifier {
  final AiDatabase aiDb = AiDatabase();
  late ai_llm.LlmService _llmService;
  late AiServiceImpl _aiService;
  late ChatPersistenceService _persistence;

  bool _initialized = false;
  bool _initializing = false;
  String? _error;
  String? _sessionUuid;
  ResolvedPersona? _persona;
  List<ChatMessage> _history = [];
  int _refreshKey = 0;
  String _specContent = '';

  bool get isInitialized => _initialized;
  String? get error => _error;
  String? get sessionUuid => _sessionUuid;
  ResolvedPersona? get persona => _persona;
  List<ChatMessage> get history => _history;
  int get refreshKey => _refreshKey;
  AiDatabase get db => aiDb;
  AiServiceImpl get aiService => _aiService;

  /// 由 [ChangeNotifierProxyProvider] 在 [SettingsProvider] 变化时调用。
  void onSettingsChanged(SettingsProvider settings) {
    if (_initializing) return;
    if (!_initialized) {
      _initialize(settings);
    } else {
      _updateProvider(settings);
    }
  }

  Future<void> _initialize(SettingsProvider settings) async {
    _initializing = true;
    _error = null;
    try {
      _llmService = ai_llm.LlmService(aiDb);
      _aiService = AiServiceImpl(llmService: _llmService, db: aiDb);
      _persistence = ChatPersistenceService(aiDb);

      await _ensureNvidiaProvider(settings);

      // 加载格局条件规范（注入为每次识别调用的 system prompt）
      try {
        _specContent = await rootBundle
            .loadString('assets/ge_ju_condition_spec.md');
      } catch (_) {
        _specContent = ''; // asset 不可用时降级，LLM 仍可继续
      }

      final persona = await _aiService.resolvePersona(_kNvidiaPersonaUuid);
      if (persona == null) throw Exception('无法解析 Nvidia Persona，请检查配置');
      _persona = persona;

      final prefs = await SharedPreferences.getInstance();
      final savedUuid = prefs.getString(_kChatSessionKey);

      if (savedUuid != null) {
        final result =
            await _aiService.sessionManager.resumeSession(savedUuid);
        if (result != null) {
          _sessionUuid = savedUuid;
          _history = result.messages;
          _initialized = true;
          _initializing = false;
          notifyListeners();
          return;
        }
      }

      final result =
          await _aiService.sessionManager.createSession(persona: persona);
      _sessionUuid = result.sessionUuid;
      _history = [];
      await prefs.setString(_kChatSessionKey, _sessionUuid!);
      _initialized = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _initializing = false;
    }
    notifyListeners();
  }

  /// 更新 Provider 的 API Key / baseUrl / model，并刷新 Persona 缓存。
  Future<void> _updateProvider(SettingsProvider settings) async {
    await _ensureNvidiaProvider(settings, updateOnly: true);
    final newPersona = await _aiService.resolvePersona(_kNvidiaPersonaUuid);
    if (newPersona != null) {
      _persona = newPersona;
      _refreshKey++;
      notifyListeners();
    }
  }

  /// 通过 xuan-ai Session LLM 将自然语言描述转换为格局条件 JSON。
  ///
  /// - 复用同一个 Session，多次识别共享上下文历史
  /// - 识别请求和结果立即写入 Session，Chat Window 即时可见
  /// - [naturalLanguage]: 用户输入的自然语言描述
  /// - [currentJson]: 当前条件 JSON（可选，供 LLM 参考）
  /// - 返回提取到的 JSON 字符串，或 null（LLM 返回 null / 解析失败）
  Future<String?> recognizeCondition({
    required String naturalLanguage,
    String? currentJson,
  }) async {
    if (!_initialized || _sessionUuid == null) return null;

    // 1. system prompt = 角色说明 + spec 规范文档
    final systemContent =
        '你是一个七政四余格局条件 JSON 编写助手。\n'
        '只输出 JSON，不要任何解释、Markdown 包裹或代码块标记。\n'
        '如果无法生成有效条件，输出 null。\n\n'
        '以下是格局条件规范：\n\n$_specContent';

    // 2. 从 DB 加载 Session 历史（最近 20 条，保留多轮上下文）
    final dbMessages = await _persistence.getMessages(_sessionUuid!);
    final recent = dbMessages.length > 20
        ? dbMessages.sublist(dbMessages.length - 20)
        : dbMessages;

    // 3. 构建本次 user message
    final userContent = StringBuffer();
    if (currentJson != null && currentJson.trim().isNotEmpty) {
      userContent.writeln('[当前 conditions JSON（仅供参考）]');
      userContent.writeln(currentJson);
      userContent.writeln();
    }
    userContent.writeln('[自然语言描述]');
    userContent.writeln(naturalLanguage);
    userContent.write('\n请输出符合规范的 conditions JSON 对象。只输出 JSON，不要解释。');

    // 4. 组合 messages 列表
    final messages = <ai_msg.ChatMessageModel>[
      ai_msg.ChatMessageModel.system(systemContent),
      ...recent
          .where((m) => m.role == 'user' || m.role == 'assistant')
          .map((m) => m.role == 'user'
              ? ai_msg.ChatMessageModel.user(m.content)
              : ai_msg.ChatMessageModel.assistant(m.content)),
      ai_msg.ChatMessageModel.user(userContent.toString()),
    ];

    // 5. 调用 xuan-ai LlmService（复用 Session）
    final response = await _llmService.chatCompletion(
      modelUuid: _kNvidiaModelUuid,
      messages: messages,
      temperature: 0.2,
      maxTokens: 4096,
      sessionUuid: _sessionUuid,
    );

    final rawContent = response.content ?? '';
    final json = _extractJson(rawContent);

    // 6. 持久化到 Session — Chat Window 即时可见
    await _persistence.addMessage(
      sessionUuid: _sessionUuid!,
      role: 'user',
      content: userContent.toString(),
    );
    await _persistence.addMessage(
      sessionUuid: _sessionUuid!,
      role: 'assistant',
      content: json != null
          ? '```json\n${_prettyJson(json)}\n```'
          : '（无法识别，请检查描述或重试）',
    );

    // 7. 刷新 Chat Window
    final result =
        await _aiService.sessionManager.resumeSession(_sessionUuid!);
    if (result != null) _history = result.messages;
    _refreshKey++;
    notifyListeners();

    return json;
  }

  String _prettyJson(String raw) {
    try {
      final obj = jsonDecode(raw);
      return const JsonEncoder.withIndent('  ').convert(obj);
    } catch (_) {
      return raw;
    }
  }

  String? _extractJson(String raw) {
    final trimmed = raw.trim();
    final jsonBlockRegex =
        RegExp(r'```(?:json)?\s*([\s\S]*?)```', multiLine: true);
    final match = jsonBlockRegex.firstMatch(trimmed);
    if (match != null) {
      final candidate = match.group(1)!.trim();
      if (_isValidJson(candidate)) return candidate;
    }
    if (_isValidJson(trimmed)) return trimmed;
    final start = trimmed.indexOf('{');
    if (start != -1) {
      final candidate = trimmed.substring(start);
      final end = candidate.lastIndexOf('}');
      if (end != -1) {
        final extracted = candidate.substring(0, end + 1);
        if (_isValidJson(extracted)) return extracted;
      }
    }
    if (trimmed.toLowerCase() == 'null') return null;
    return null;
  }

  bool _isValidJson(String s) {
    try {
      jsonDecode(s);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // Bootstrap
  // ============================================================

  Future<void> _ensureNvidiaProvider(
    SettingsProvider settings, {
    bool updateOnly = false,
  }) async {
    final now = DateTime.now();

    // 1. Provider
    final existingProvider =
        await aiDb.llmProvidersDao.getByUuid(_kNvidiaProviderUuid);
    if (existingProvider == null) {
      if (!updateOnly) {
        await aiDb.llmProvidersDao.upsert(
          LlmProvidersCompanion(
            uuid: const Value(_kNvidiaProviderUuid),
            name: const Value('Nvidia NIM'),
            baseUrl: Value(settings.baseUrl),
            encryptedApiKey: Value(settings.apiKey),
            configJson: Value('{"model":"${settings.modelName}"}'),
            isEnabled: const Value(true),
            isDefault: const Value(true),
            createdAt: Value(now),
            lastUpdatedAt: Value(now),
          ),
        );
      }
    } else {
      await aiDb.llmProvidersDao.upsert(
        LlmProvidersCompanion(
          uuid: const Value(_kNvidiaProviderUuid),
          name: const Value('Nvidia NIM'),
          baseUrl: Value(settings.baseUrl),
          encryptedApiKey: Value(settings.apiKey),
          configJson: Value('{"model":"${settings.modelName}"}'),
          isEnabled: const Value(true),
          isDefault: const Value(true),
          createdAt: Value(existingProvider.createdAt),
          lastUpdatedAt: Value(now),
        ),
      );
    }

    if (updateOnly) return;

    final defaultProvider = await aiDb.llmProvidersDao.getDefault();
    if (defaultProvider == null) {
      await aiDb.llmProvidersDao.setDefault(_kNvidiaProviderUuid);
    }

    // 2. Model
    final existingModel =
        await aiDb.llmModelsDao.getByUuid(_kNvidiaModelUuid);
    if (existingModel == null) {
      await aiDb.llmModelsDao.upsert(
        LlmModelsCompanion(
          uuid: const Value(_kNvidiaModelUuid),
          providerUuid: const Value(_kNvidiaProviderUuid),
          displayName: Value(settings.modelName),
          modelId: Value(settings.modelName),
          modelType: const Value('chat'),
          maxContextLength: const Value(128000),
          maxOutputTokens: const Value(4096),
          isEnabled: const Value(true),
          isDefault: const Value(true),
          createdAt: Value(now),
          lastUpdatedAt: Value(now),
        ),
      );
    }

    final defaultModel = await aiDb.llmModelsDao.getDefault();
    if (defaultModel == null) {
      await aiDb.llmModelsDao.setDefault(_kNvidiaModelUuid);
    }

    // 3. Persona
    final existingPersona =
        await aiDb.aiPersonasDao.getByUuid(_kNvidiaPersonaUuid);
    if (existingPersona == null) {
      await aiDb.aiPersonasDao.insertPersona(
        AiPersonasCompanion(
          uuid: const Value(_kNvidiaPersonaUuid),
          name: const Value('格局助手'),
          description: const Value('七政四余格局智能助手，支持识别记录查看与自由对话。'),
          modelUuid: const Value(_kNvidiaModelUuid),
          temperature: const Value(0.7),
          topP: const Value(0.9),
          maxTokens: const Value(2048),
          isEnabled: const Value(true),
          isDefault: const Value(true),
          createdAt: Value(now),
          lastUpdatedAt: Value(now),
        ),
      );
    }

    final defaultPersona = await aiDb.aiPersonasDao.getDefault();
    if (defaultPersona == null) {
      await aiDb.aiPersonasDao.setDefault(_kNvidiaPersonaUuid);
    }
  }

  @override
  void dispose() {
    if (_initialized) {
      _aiService.dispose();
    }
    aiDb.close();
    super.dispose();
  }
}
