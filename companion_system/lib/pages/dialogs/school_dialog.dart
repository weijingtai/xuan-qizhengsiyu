/// 流派新建/编辑表单页
library;

import 'package:flutter/material.dart';
import 'package:companion_system/database/drift_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:companion_system/pages/dialogs/pattern_dialog.dart'
    show FormSection;

class SchoolFormPage extends StatefulWidget {
  final AppDatabase db;
  final School? school; // null = 新建, non-null = 编辑

  const SchoolFormPage({super.key, required this.db, this.school});

  @override
  State<SchoolFormPage> createState() => _SchoolFormPageState();
}

class _SchoolFormPageState extends State<SchoolFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _eraCtrl = TextEditingController();
  final _founderCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  String _selectedType = 'book';
  bool _isSaving = false;

  static const _typeOptions = [
    ('book', '典籍'),
    ('tradition', '流派'),
    ('custom', '自定义'),
  ];

  bool get _isEdit => widget.school != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final s = widget.school!;
      _nameCtrl.text = s.name;
      _eraCtrl.text = s.era ?? '';
      _founderCtrl.text = s.founder ?? '';
      _descriptionCtrl.text = s.description ?? '';
      _selectedType = s.type;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    String? n(String s) => s.trim().isEmpty ? null : s.trim();

    try {
      if (_isEdit) {
        await (widget.db.update(widget.db.geJuSchools)
              ..where((s) => s.id.equals(widget.school!.id)))
            .write(GeJuSchoolsCompanion(
          name: Value(_nameCtrl.text.trim()),
          type: Value(_selectedType),
          era: Value(n(_eraCtrl.text)),
          founder: Value(n(_founderCtrl.text)),
          description: Value(n(_descriptionCtrl.text)),
        ));
      } else {
        final id = 's_${DateTime.now().millisecondsSinceEpoch}';
        await widget.db.into(widget.db.geJuSchools).insert(
              GeJuSchoolsCompanion.insert(
                id: id,
                name: _nameCtrl.text.trim(),
                type: _selectedType,
                createdAt: DateTime.now(),
                era: Value(n(_eraCtrl.text)),
                founder: Value(n(_founderCtrl.text)),
                description: Value(n(_descriptionCtrl.text)),
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
        title: Text(_isEdit ? '编辑流派' : '新建流派'),
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
                  labelText: '流派/典籍名称 *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '请输入名称' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: '类型 *',
                  border: OutlineInputBorder(),
                ),
                items: _typeOptions
                    .map((t) =>
                        DropdownMenuItem(value: t.$1, child: Text(t.$2)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedType = v);
                },
              ),
            ]),
            const SizedBox(height: 20),
            FormSection(label: '作者与时代', children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _founderCtrl,
                      decoration: const InputDecoration(
                        labelText: '创始人/作者',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _eraCtrl,
                      decoration: const InputDecoration(
                        labelText: '时代（如：汉、唐、明）',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 20),
            FormSection(label: '描述', children: [
              TextFormField(
                controller: _descriptionCtrl,
                decoration: const InputDecoration(
                  labelText: '描述',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ]),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(_isEdit ? '保存流派' : '新建流派'),
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
    _eraCtrl.dispose();
    _founderCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }
}
