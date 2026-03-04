/// LLM API 设置 Provider
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kKeyApiKey = 'prefs_llm_api_key';
const _kKeyBaseUrl = 'prefs_llm_base_url';
const _kKeyModelName = 'prefs_llm_model_name';
const _kKeySystemPrompt = 'prefs_llm_system_prompt';

const _kDefaultBaseUrl = 'https://integrate.api.nvidia.com/v1';
const _kDefaultModelName = 'meta/llama-3.3-70b-instruct';
const _kDefaultSystemPrompt =
    '你是一个中国古代星命学（七政四余）格局判断条件的 JSON 编写助手。'
    '给定条件规范文档、用户的自然语言描述（可能参考原文和注解），'
    '你需要输出符合规范的 conditions 字段 JSON 对象。'
    '只输出 JSON，不要任何解释、Markdown 包裹或代码块标记。'
    '如果无法生成有效条件，输出 null。';

class SettingsProvider extends ChangeNotifier {
  String _apiKey = '';
  String _baseUrl = _kDefaultBaseUrl;
  String _modelName = _kDefaultModelName;
  String _systemPrompt = _kDefaultSystemPrompt;

  String get apiKey => _apiKey;
  String get baseUrl => _baseUrl.isEmpty ? _kDefaultBaseUrl : _baseUrl;
  String get modelName => _modelName.isEmpty ? _kDefaultModelName : _modelName;
  String get systemPrompt =>
      _systemPrompt.isEmpty ? _kDefaultSystemPrompt : _systemPrompt;

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_kKeyApiKey) ?? '';
    _baseUrl = prefs.getString(_kKeyBaseUrl) ?? _kDefaultBaseUrl;
    _modelName = prefs.getString(_kKeyModelName) ?? _kDefaultModelName;
    _systemPrompt =
        prefs.getString(_kKeySystemPrompt) ?? _kDefaultSystemPrompt;
    notifyListeners();
  }

  Future<void> save({
    required String apiKey,
    required String baseUrl,
    required String modelName,
    required String systemPrompt,
  }) async {
    _apiKey = apiKey;
    _baseUrl = baseUrl.isEmpty ? _kDefaultBaseUrl : baseUrl;
    _modelName = modelName.isEmpty ? _kDefaultModelName : modelName;
    _systemPrompt = systemPrompt.isEmpty ? _kDefaultSystemPrompt : systemPrompt;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKeyApiKey, _apiKey);
    await prefs.setString(_kKeyBaseUrl, _baseUrl);
    await prefs.setString(_kKeyModelName, _modelName);
    await prefs.setString(_kKeySystemPrompt, _systemPrompt);
    notifyListeners();
  }
}
