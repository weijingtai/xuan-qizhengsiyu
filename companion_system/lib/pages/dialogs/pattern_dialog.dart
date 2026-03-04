/// 格局新建/编辑表单页
library;

import 'package:flutter/material.dart';
import 'package:companion_system/database/drift_database.dart';
import 'package:drift/drift.dart' show Value;

class PatternFormPage extends StatefulWidget {
  final AppDatabase db;
  final Pattern? pattern; // null = 新建, non-null = 编辑

  const PatternFormPage({super.key, required this.db, this.pattern});

  @override
  State<PatternFormPage> createState() => _PatternFormPageState();
}

class _PatternFormPageState extends State<PatternFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _pinyinCtrl = TextEditingController();
  final _englishNameCtrl = TextEditingController();
  final _aliasesCtrl = TextEditingController();
  final _keywordsCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _originNotesCtrl = TextEditingController();

  List<Category> _categories = [];
  String? _selectedCategoryId;
  bool _isSaving = false;

  bool get _isEdit => widget.pattern != null;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (_isEdit) {
      final p = widget.pattern!;
      _nameCtrl.text = p.name;
      _pinyinCtrl.text = p.pinyin ?? '';
      _englishNameCtrl.text = p.englishName ?? '';
      _aliasesCtrl.text = p.aliases ?? '';
      _keywordsCtrl.text = p.keywords ?? '';
      _tagsCtrl.text = p.tags ?? '';
      _descriptionCtrl.text = p.description ?? '';
      _originNotesCtrl.text = p.originNotes ?? '';
      _selectedCategoryId = p.categoryId;
    }
  }

  Future<void> _loadCategories() async {
    final cats = await widget.db.select(widget.db.geJuCategories).get();
    setState(() {
      _categories = cats;
      if (!_isEdit && cats.isNotEmpty) {
        _selectedCategoryId ??= cats.first.id;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请选择分类')));
      return;
    }
    setState(() => _isSaving = true);

    String? n(String s) => s.trim().isEmpty ? null : s.trim();

    try {
      if (_isEdit) {
        await (widget.db.update(widget.db.geJuPatterns)
              ..where((p) => p.id.equals(widget.pattern!.id)))
            .write(GeJuPatternsCompanion(
          name: Value(_nameCtrl.text.trim()),
          pinyin: Value(n(_pinyinCtrl.text)),
          englishName: Value(n(_englishNameCtrl.text)),
          aliases: Value(n(_aliasesCtrl.text)),
          keywords: Value(n(_keywordsCtrl.text)),
          tags: Value(n(_tagsCtrl.text)),
          description: Value(n(_descriptionCtrl.text)),
          originNotes: Value(n(_originNotesCtrl.text)),
          categoryId: Value(_selectedCategoryId!),
        ));
      } else {
        final id = 'p_${DateTime.now().millisecondsSinceEpoch}';
        await widget.db.into(widget.db.geJuPatterns).insert(
              GeJuPatternsCompanion.insert(
                id: id,
                name: _nameCtrl.text.trim(),
                categoryId: _selectedCategoryId!,
                createdAt: DateTime.now(),
                pinyin: Value(n(_pinyinCtrl.text)),
                englishName: Value(n(_englishNameCtrl.text)),
                aliases: Value(n(_aliasesCtrl.text)),
                keywords: Value(n(_keywordsCtrl.text)),
                tags: Value(n(_tagsCtrl.text)),
                description: Value(n(_descriptionCtrl.text)),
                originNotes: Value(n(_originNotesCtrl.text)),
              ),
            );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('保存失败: $e')));
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? '编辑格局' : '新建格局'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(_isEdit ? '保存' : '新建'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            FormSection(label: '基本信息', children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: '格局名称 *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '请输入格局名称' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pinyinCtrl,
                      decoration: const InputDecoration(
                        labelText: '拼音',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _englishNameCtrl,
                      decoration: const InputDecoration(
                        labelText: '英文名',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: '分类 *',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
                validator: (v) => v == null ? '请选择分类' : null,
              ),
            ]),
            const SizedBox(height: 20),
            FormSection(label: '标签与索引', children: [
              TextFormField(
                controller: _aliasesCtrl,
                decoration: const InputDecoration(
                  labelText: '别名（逗号分隔）',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _keywordsCtrl,
                decoration: const InputDecoration(
                  labelText: '关键词',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tagsCtrl,
                decoration: const InputDecoration(
                  labelText: '标签',
                  border: OutlineInputBorder(),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            FormSection(label: '描述与出处', children: [
              TextFormField(
                controller: _descriptionCtrl,
                decoration: const InputDecoration(
                  labelText: '描述',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _originNotesCtrl,
                decoration: const InputDecoration(
                  labelText: '出处备注',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ]),
            const SizedBox(height: 32),
            // 底部保存按钮（方便滚动到底部时保存）
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(_isEdit ? '保存格局' : '新建格局'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _pinyinCtrl.dispose();
    _englishNameCtrl.dispose();
    _aliasesCtrl.dispose();
    _keywordsCtrl.dispose();
    _tagsCtrl.dispose();
    _descriptionCtrl.dispose();
    _originNotesCtrl.dispose();
    super.dispose();
  }
}

/// 带标题的表单分组（公共组件，供各表单页复用）
class FormSection extends StatelessWidget {
  final String label;
  final List<Widget> children;
  const FormSection({super.key, required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        const Divider(height: 12),
        ...children,
      ],
    );
  }
}
