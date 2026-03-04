/// Nvidia NIM (OpenAI 兼容) LLM 服务
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:companion_system/providers/settings_provider.dart';

class LlmException implements Exception {
  final String message;
  LlmException(this.message);

  @override
  String toString() => message;
}

/// 非 LLM（文本生成）模型的关键词黑名单。
/// 凡 model id 包含这些关键词的，视为非 LLM，过滤掉。
const _kNonLlmKeywords = <String>[
  // 向量嵌入 / 重排序
  'embed', 'rerank', 'retrieval', 'nv-embed', 'nv-rerank',
  // 图像生成
  'stable-diffusion', 'flux', 'sdxl', 'imagen', 'dall-e',
  'kandinsky', 'playground-v', 'juggernaut', 'realvisxl',
  'inpaint', 'controlnet', 'upscale',
  // 视频
  'video', 'cosmos-',
  // 语音识别 / 语音合成
  'parakeet', 'canary', 'fastpitch', 'radtts', 'hifigan',
  '-tts', 'tts-1', 'whisper', 'speech-to-text',
  // 生物科学 / 化学 / 物理
  'protein', 'gnina', 'diffdock', 'molmim', 'openfold',
  'alignn', 'esmfold', 'genmol', 'megamolbart', 'physicsnemo',
  'genesis', 'bionemo', 'evo-1', 'alphafold', 'equidock',
];

class LlmService {
  // ── 文本生成（主功能）──────────────────────────────────────────────────────

  /// 将自然语言描述转化为格局条件 JSON 字符串。
  ///
  /// 返回值是可直接存入 `conditions` 字段的 JSON 字符串。
  /// 如果 LLM 返回 `null` 则返回 null。
  /// 失败时抛出 [LlmException]。
  Future<String?> convertToConditionJson({
    required SettingsProvider settings,
    required String conditionSpec,
    required String naturalLanguage,
    String? currentJson,
  }) async {
    if (!settings.isConfigured) {
      throw LlmException('未配置 API Key，请先在设置中填写。');
    }

    final uri = Uri.parse('${settings.baseUrl}/chat/completions');

    final userContent = StringBuffer();
    userContent.writeln('[条件规范]');
    userContent.writeln(conditionSpec);
    if (currentJson != null && currentJson.trim().isNotEmpty) {
      userContent.writeln('\n[当前conditions JSON（仅供参考）]');
      userContent.writeln(currentJson);
    }
    userContent.writeln('\n[自然语言描述]');
    userContent.writeln(naturalLanguage);
    userContent
        .writeln('\n请根据以上信息，输出符合规范的 conditions JSON 对象。只输出 JSON，不要解释。');

    final body = jsonEncode({
      'model': settings.modelName,
      'messages': [
        {'role': 'system', 'content': settings.systemPrompt},
        {'role': 'user', 'content': userContent.toString()},
      ],
      'temperature': 0.2,
      'max_tokens': 4096,
    });

    late http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer ${settings.apiKey}',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 120));
    } catch (e) {
      throw LlmException('网络请求失败：$e');
    }

    if (response.statusCode != 200) {
      String detail = '';
      try {
        final err = jsonDecode(utf8.decode(response.bodyBytes));
        detail = (err['error']?['message'] as String?) ?? err.toString();
      } catch (_) {
        detail = response.body;
      }
      throw LlmException('API 返回错误 ${response.statusCode}：$detail');
    }

    late Map<String, dynamic> decoded;
    try {
      decoded =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (e) {
      throw LlmException('响应解析失败：$e');
    }

    final content =
        decoded['choices']?[0]?['message']?['content'] as String?;
    if (content == null || content.trim().isEmpty) {
      throw LlmException('LLM 未返回有效内容。');
    }

    return _extractJson(content);
  }

  // ── 获取可用 LLM 模型列表 ──────────────────────────────────────────────────

  /// 从 Nvidia NIM（或兼容 OpenAI 的 API）获取所有可用的 LLM 模型列表。
  ///
  /// 调用 `GET {baseUrl}/models`，过滤掉非文本生成类模型（图像/视频/语音/生物科学等）。
  /// 返回按字母排序的模型 ID 列表。
  Future<List<String>> fetchAvailableModels(SettingsProvider settings) async {
    if (!settings.isConfigured) {
      throw LlmException('未配置 API Key，请先在设置中填写。');
    }

    final uri = Uri.parse('${settings.baseUrl}/models');

    late http.Response response;
    try {
      response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${settings.apiKey}',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
    } catch (e) {
      throw LlmException('网络请求失败：$e');
    }

    if (response.statusCode != 200) {
      String detail = '';
      try {
        final err = jsonDecode(utf8.decode(response.bodyBytes));
        detail = (err['error']?['message'] as String?) ?? err.toString();
      } catch (_) {
        detail = response.body;
      }
      throw LlmException('获取模型列表失败 ${response.statusCode}：$detail');
    }

    late Map<String, dynamic> decoded;
    try {
      decoded =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (e) {
      throw LlmException('响应解析失败：$e');
    }

    final data = decoded['data'] as List? ?? [];
    final allIds = data
        .map((m) => (m as Map<String, dynamic>)['id'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    final llmModels = allIds.where(_isLlmModel).toList()..sort();
    return llmModels;
  }

  /// 判断一个 model id 是否属于文本生成（LLM）类模型。
  bool _isLlmModel(String id) {
    final lower = id.toLowerCase();
    return !_kNonLlmKeywords.any((kw) => lower.contains(kw));
  }

  // ── 内部工具 ───────────────────────────────────────────────────────────────

  /// 从 LLM 响应中提取 JSON 字符串。
  /// 支持 ```json...``` 包裹、纯 JSON，以及首次出现 { 之后的内容。
  String? _extractJson(String raw) {
    final trimmed = raw.trim();

    // 尝试 ```json...``` 包裹
    final jsonBlockRegex =
        RegExp(r'```(?:json)?\s*([\s\S]*?)```', multiLine: true);
    final match = jsonBlockRegex.firstMatch(trimmed);
    if (match != null) {
      final candidate = match.group(1)!.trim();
      if (_isValidJson(candidate)) return candidate;
    }

    // 直接尝试解析
    if (_isValidJson(trimmed)) return trimmed;

    // 找第一个 { 开始
    final start = trimmed.indexOf('{');
    if (start != -1) {
      final candidate = trimmed.substring(start);
      final end = candidate.lastIndexOf('}');
      if (end != -1) {
        final extracted = candidate.substring(0, end + 1);
        if (_isValidJson(extracted)) return extracted;
      }
    }

    // 如果 LLM 明确返回 null
    if (trimmed.toLowerCase() == 'null') return null;

    throw LlmException('无法从 LLM 响应中提取有效 JSON。\n\n原始响应：\n$raw');
  }

  bool _isValidJson(String s) {
    try {
      jsonDecode(s);
      return true;
    } catch (_) {
      return false;
    }
  }
}
