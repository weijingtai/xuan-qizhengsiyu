/// AI 识别对话框 — 将自然语言转化为格局条件 JSON
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:companion_system/database/drift_database.dart';
import 'package:companion_system/providers/ai_chat_controller.dart';
import 'package:companion_system/widgets/condition_json_tree.dart';

/// 对话框返回值结构
class AiRecognitionResult {
  final String conditionsJson;
  final bool shouldSave; // true=写入DB+isVerified, false=仅更新内存

  const AiRecognitionResult({
    required this.conditionsJson,
    required this.shouldSave,
  });
}

/// AI 识别对话框
///
/// 打开方式：
/// ```dart
/// final result = await AiRecognitionDialog.show(
///   context,
///   rule: rule,
///   patternName: patternName,
///   patternDescription: patternDescription,
/// );
/// ```
class AiRecognitionDialog extends StatefulWidget {
  final Rule rule;
  final String patternName;
  final String? patternDescription;

  const AiRecognitionDialog({
    super.key,
    required this.rule,
    required this.patternName,
    this.patternDescription,
  });

  static Future<AiRecognitionResult?> show(
    BuildContext context, {
    required Rule rule,
    required String patternName,
    String? patternDescription,
  }) {
    return showDialog<AiRecognitionResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AiRecognitionDialog(
        rule: rule,
        patternName: patternName,
        patternDescription: patternDescription,
      ),
    );
  }

  @override
  State<AiRecognitionDialog> createState() => _AiRecognitionDialogState();
}

class _AiRecognitionDialogState extends State<AiRecognitionDialog>
    with SingleTickerProviderStateMixin {
  final _inputCtrl = TextEditingController();

  late TabController _tabCtrl;

  String? _newConditionsJson; // LLM 返回的新 JSON，null = 未发送
  bool _isLoading = false;
  String? _error;

  // 格式化 JSON 用于显示
  String _formatJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '（无）';
    try {
      final obj = jsonDecode(raw);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(obj);
    } catch (_) {
      return raw;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final input = _inputCtrl.text.trim();
    if (input.isEmpty) {
      setState(() => _error = '请输入自然语言描述后再发送。');
      return;
    }

    final controller = context.read<AiChatController>();
    if (!controller.isInitialized) {
      setState(() => _error = '未配置 API Key，请先在右上角「设置」中填写。');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await controller.recognizeCondition(
        naturalLanguage: input,
        currentJson: widget.rule.conditions,
      );
      if (result == null) throw Exception('LLM 未返回有效 JSON，请检查描述或重试。');
      if (mounted) {
        setState(() {
          _newConditionsJson = result;
          _isLoading = false;
          _tabCtrl.animateTo(1);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _confirm() {
    if (_newConditionsJson == null) return;
    Navigator.of(context).pop(AiRecognitionResult(
      conditionsJson: _newConditionsJson!,
      shouldSave: false,
    ));
  }

  void _save() {
    if (_newConditionsJson == null) return;
    Navigator.of(context).pop(AiRecognitionResult(
      conditionsJson: _newConditionsJson!,
      shouldSave: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920, maxHeight: 800),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  _buildInfoSection(),
                  const SizedBox(height: 16),
                  _buildInputSection(),
                  const SizedBox(height: 16),
                  _buildComparisonSection(),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    _buildErrorBanner(_error!),
                  ],
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ── 头部 ────────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(60),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology_outlined, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'AI识别 — ${widget.patternName}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: '取消',
          ),
        ],
      ),
    );
  }

  // ── 只读信息区 ───────────────────────────────────────────────────────────────

  Widget _buildInfoSection() {
    final rule = widget.rule;
    return ExpansionTile(
      initiallyExpanded: true,
      tilePadding: EdgeInsets.zero,
      title: Text(
        '格局信息（只读）',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
      children: [
        _InfoRow(label: '格局名', value: widget.patternName),
        if (widget.patternDescription != null && widget.patternDescription!.isNotEmpty)
          _InfoRow(label: '描述', value: widget.patternDescription!),
        if (rule.brief != null && rule.brief!.isNotEmpty)
          _InfoRow(label: '简介', value: rule.brief!),
        if (rule.assertion != null && rule.assertion!.isNotEmpty)
          _InfoRow(label: '断言', value: rule.assertion!),
        if (rule.chapter != null && rule.chapter!.isNotEmpty)
          _InfoRow(label: '章节', value: rule.chapter!),
        if (rule.originalText != null && rule.originalText!.isNotEmpty)
          _InfoRow(label: '原文', value: rule.originalText!),
        if (rule.notes != null && rule.notes!.isNotEmpty)
          _InfoRow(label: '原文注解', value: rule.notes!),
        if (rule.explanation != null && rule.explanation!.isNotEmpty)
          _InfoRow(label: '注解', value: rule.explanation!),
      ],
    );
  }

  // ── 输入区 ───────────────────────────────────────────────────────────────────

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '自然语言描述',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _inputCtrl,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: '参照原文，用自然语言描述格局的判断条件，例如：\n「木星与土星同宫，且月亮在四正宫之一」',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _isLoading ? null : _send,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_outlined, size: 18),
            label: Text(_isLoading ? '识别中…' : '发送'),
          ),
        ),
      ],
    );
  }

  // ── 对比区 ───────────────────────────────────────────────────────────────────

  Widget _buildComparisonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          controller: _tabCtrl,
          tabs: [
            const Tab(text: '旧版本'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('新版本'),
                  if (_newConditionsJson != null) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 300,
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _buildVersionPanel(widget.rule.conditions, isNew: false),
              _buildVersionPanel(_newConditionsJson, isNew: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVersionPanel(String? conditionsJson, {required bool isNew}) {
    final formattedJson = _formatJson(conditionsJson);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 算法 Cell 树形可视化
          Text(
            '算法 Cell',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 6),
          ConditionJsonTree.fromString(conditionsJson),
          const Divider(height: 24),

          // JSON 文本
          Row(
            children: [
              Text(
                'JSON',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              const Spacer(),
              if (conditionsJson != null)
                IconButton(
                  icon: const Icon(Icons.copy_outlined, size: 16),
                  tooltip: '复制 JSON',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: conditionsJson));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('JSON 已复制'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isNew
                  ? Colors.green.shade50
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isNew ? Colors.green.shade200 : Colors.grey.shade300,
              ),
            ),
            child: conditionsJson == null
                ? Text(
                    isNew ? '（等待 AI 识别结果…）' : '（无）',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                  )
                : SelectableText(
                    formattedJson,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── 错误横幅 ──────────────────────────────────────────────────────────────────

  Widget _buildErrorBanner(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              error,
              style: TextStyle(color: Colors.red.shade800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ── 底部按钮 ──────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    final hasResult = _newConditionsJson != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          const Spacer(),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: hasResult ? _confirm : null,
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('确认（不保存）'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: hasResult ? _save : null,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('保存 ✓'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 信息行 Widget ────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
