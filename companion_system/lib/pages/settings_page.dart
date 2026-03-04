/// LLM API 设置页面
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:companion_system/providers/settings_provider.dart';
import 'package:companion_system/services/llm_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _llmService = LlmService();

  late TextEditingController _apiKeyCtrl;
  late TextEditingController _baseUrlCtrl;
  late TextEditingController _modelNameCtrl;
  late TextEditingController _systemPromptCtrl;

  bool _obscureApiKey = true;
  bool _isSaving = false;
  bool _isFetchingModels = false;
  String? _fetchModelError;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _apiKeyCtrl = TextEditingController(text: settings.apiKey);
    _baseUrlCtrl = TextEditingController(text: settings.baseUrl);
    _modelNameCtrl = TextEditingController(text: settings.modelName);
    _systemPromptCtrl = TextEditingController(text: settings.systemPrompt);
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    _baseUrlCtrl.dispose();
    _modelNameCtrl.dispose();
    _systemPromptCtrl.dispose();
    super.dispose();
  }

  // ── 保存设置 ─────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await context.read<SettingsProvider>().save(
            apiKey: _apiKeyCtrl.text.trim(),
            baseUrl: _baseUrlCtrl.text.trim(),
            modelName: _modelNameCtrl.text.trim(),
            systemPrompt: _systemPromptCtrl.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('设置已保存'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── 获取 Nvidia LLM 模型列表 ──────────────────────────────────────────────

  Future<void> _fetchModels() async {
    final apiKey = _apiKeyCtrl.text.trim();
    final baseUrl = _baseUrlCtrl.text.trim();

    if (apiKey.isEmpty) {
      setState(() => _fetchModelError = '请先填写 API Key');
      return;
    }

    setState(() {
      _isFetchingModels = true;
      _fetchModelError = null;
    });

    // 临时使用当前输入框的值构建虚拟 settings（不触发 SharedPreferences 写入）
    final tmpSettings = _TempSettings(
      apiKey: apiKey,
      baseUrl: baseUrl.isEmpty ? 'https://integrate.api.nvidia.com/v1' : baseUrl,
      modelName: _modelNameCtrl.text.trim(),
      systemPrompt: _systemPromptCtrl.text.trim(),
    );

    try {
      final models = await _llmService.fetchAvailableModels(tmpSettings);
      if (!mounted) return;
      setState(() => _isFetchingModels = false);

      if (models.isEmpty) {
        setState(() => _fetchModelError = '未找到可用的 LLM 模型，请检查 API Key 或 Base URL');
        return;
      }

      // 弹出模型选择对话框
      final selected = await showDialog<String>(
        context: context,
        builder: (_) => _ModelPickerDialog(models: models),
      );
      if (selected != null && mounted) {
        setState(() => _modelNameCtrl.text = selected);
      }
    } on LlmException catch (e) {
      if (mounted) {
        setState(() {
          _isFetchingModels = false;
          _fetchModelError = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFetchingModels = false;
          _fetchModelError = '未知错误：$e';
        });
      }
    }
  }

  // ── 查看条件规范 ──────────────────────────────────────────────────────────

  Future<void> _viewConditionSpec() async {
    String spec;
    try {
      spec = await rootBundle.loadString('assets/ge_ju_condition_spec.md');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败：$e'), backgroundColor: Colors.red),
        );
      }
      return;
    }
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (_) => _SpecViewerDialog(spec: spec),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LLM 设置'),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Nvidia NIM API 配置'),
            const SizedBox(height: 12),

            // ── API Key ──────────────────────────────────────────────────────
            TextFormField(
              controller: _apiKeyCtrl,
              obscureText: _obscureApiKey,
              decoration: InputDecoration(
                labelText: 'API Key *',
                hintText: 'nvapi-xxxxxx...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.vpn_key_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureApiKey ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscureApiKey = !_obscureApiKey),
                ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'API Key 不能为空' : null,
            ),
            const SizedBox(height: 16),

            // ── Base URL ─────────────────────────────────────────────────────
            TextFormField(
              controller: _baseUrlCtrl,
              decoration: const InputDecoration(
                labelText: 'Base URL（可选）',
                hintText: 'https://integrate.api.nvidia.com/v1',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link_outlined),
                helperText: '留空使用默认 Nvidia NIM 地址',
              ),
            ),
            const SizedBox(height: 16),

            // ── 模型名称 + 获取按钮 ──────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _modelNameCtrl,
                    decoration: const InputDecoration(
                      labelText: '模型名称（可选）',
                      hintText: 'meta/llama-3.3-70b-instruct',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.smart_toy_outlined),
                      helperText: '留空使用默认模型；或点击右侧按钮从 API 获取',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _isFetchingModels
                      ? const SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : Tooltip(
                          message: '从 API 获取可用 LLM 模型列表',
                          child: OutlinedButton.icon(
                            onPressed: _fetchModels,
                            icon: const Icon(Icons.cloud_download_outlined,
                                size: 18),
                            label: const Text('获取模型'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                            ),
                          ),
                        ),
                ),
              ],
            ),

            // 错误提示
            if (_fetchModelError != null) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade700, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _fetchModelError!,
                        style:
                            TextStyle(color: Colors.red.shade800, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── System Prompt ────────────────────────────────────────────────
            _buildSectionHeader('System Prompt（可选）'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _systemPromptCtrl,
              minLines: 4,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'System Prompt',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                helperText: '留空使用默认 Prompt',
              ),
            ),

            const SizedBox(height: 24),

            // ── 条件规范查看 ─────────────────────────────────────────────────
            _buildSectionHeader('格局条件规范'),
            const SizedBox(height: 8),
            Text(
              'ge_ju_condition_spec.md 定义了所有支持的条件类型及 JSON 格式，'
              'LLM 会依据此规范将自然语言转化为 JSON。',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _viewConditionSpec,
              icon: const Icon(Icons.description_outlined, size: 18),
              label: const Text('查看完整条件规范'),
            ),

            const SizedBox(height: 32),

            // ── 保存按钮 ─────────────────────────────────────────────────────
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Icons.save),
              label: const Text('保存设置'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

// ── 临时 settings 对象（仅用于 fetchAvailableModels，不写磁盘）────────────────

/// 轻量级 settings 适配，仅用于 [LlmService.fetchAvailableModels] 调用时
/// 传入当前输入框的值，避免用户必须先保存才能获取模型列表。
class _TempSettings implements SettingsProvider {
  @override
  final String apiKey;
  @override
  final String baseUrl;
  @override
  final String modelName;
  @override
  final String systemPrompt;

  _TempSettings({
    required this.apiKey,
    required this.baseUrl,
    required this.modelName,
    required this.systemPrompt,
  });

  @override
  bool get isConfigured => apiKey.isNotEmpty;

  // ── ChangeNotifier stubs（不需要实际通知）────────────────────────────────
  @override
  void addListener(void Function() listener) {}
  @override
  void removeListener(void Function() listener) {}
  @override
  bool get hasListeners => false;
  @override
  void notifyListeners() {}
  @override
  void dispose() {}
  @override
  Future<void> load() async {}
  @override
  Future<void> save({
    required String apiKey,
    required String baseUrl,
    required String modelName,
    required String systemPrompt,
  }) async {}
}

// ── 模型选择对话框 ────────────────────────────────────────────────────────────

class _ModelPickerDialog extends StatefulWidget {
  final List<String> models;
  const _ModelPickerDialog({required this.models});

  @override
  State<_ModelPickerDialog> createState() => _ModelPickerDialogState();
}

class _ModelPickerDialogState extends State<_ModelPickerDialog> {
  final _searchCtrl = TextEditingController();
  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.models;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    final kw = q.trim().toLowerCase();
    setState(() {
      _filtered = kw.isEmpty
          ? widget.models
          : widget.models
              .where((m) => m.toLowerCase().contains(kw))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 640),
        child: Column(
          children: [
            // 标题
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  const Icon(Icons.smart_toy_outlined, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '选择 LLM 模型（共 ${widget.models.length} 个）',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // 搜索框
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '搜索模型名称...',
                  prefixIcon: Icon(Icons.search, size: 18),
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
                onChanged: _onSearch,
              ),
            ),
            const SizedBox(height: 8),
            // 提示
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '已过滤掉图像生成、语音、视频、生物科学等非 LLM 类模型',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ),
            const Divider(height: 12),
            // 列表
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(child: Text('没有匹配的模型'))
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final m = _filtered[i];
                        return ListTile(
                          dense: true,
                          leading:
                              const Icon(Icons.memory_outlined, size: 18),
                          title: Text(
                            m,
                            style: const TextStyle(
                                fontSize: 13, fontFamily: 'monospace'),
                          ),
                          onTap: () => Navigator.of(context).pop(m),
                        );
                      },
                    ),
            ),
            // 底部按钮
            const Divider(height: 1),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 条件规范查看对话框 ─────────────────────────────────────────────────────────

class _SpecViewerDialog extends StatefulWidget {
  final String spec;
  const _SpecViewerDialog({required this.spec});

  @override
  State<_SpecViewerDialog> createState() => _SpecViewerDialogState();
}

class _SpecViewerDialogState extends State<_SpecViewerDialog> {
  final _searchCtrl = TextEditingController();
  String _filterText = '';
  bool _copied = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<String> get _lines {
    final lines = widget.spec.split('\n');
    if (_filterText.isEmpty) return lines;
    final kw = _filterText.toLowerCase();
    return lines.where((l) => l.toLowerCase().contains(kw)).toList();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.spec));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final lines = _lines;
    return Dialog(
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 760),
        child: Column(
          children: [
            // 标题栏
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '格局条件规范 — ge_ju_condition_spec.md',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _copied ? Icons.check : Icons.copy_outlined,
                      color: _copied ? Colors.green : null,
                      size: 18,
                    ),
                    tooltip: _copied ? '已复制' : '复制全文',
                    onPressed: _copy,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // 搜索框
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: '在规范中搜索...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon: _filterText.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _filterText = '');
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 12),
                ),
                onChanged: (v) => setState(() => _filterText = v),
              ),
            ),
            if (_filterText.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '匹配 ${lines.length} 行',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ),
              ),
            const Divider(height: 8),
            // 内容
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    lines.join('\n'),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            // 底部
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Text(
                    '共 ${widget.spec.split('\n').length} 行',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('关闭'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
