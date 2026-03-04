/// 规则新建/编辑表单页
library;

import 'package:flutter/material.dart';
import 'package:companion_system/database/drift_database.dart';
import 'package:companion_system/pages/dialogs/pattern_dialog.dart'
    show FormSection;
import 'package:drift/drift.dart' show Value;

class RuleFormPage extends StatefulWidget {
  final AppDatabase db;
  final Rule? rule; // null = 新建, non-null = 编辑

  const RuleFormPage({super.key, required this.db, this.rule});

  @override
  State<RuleFormPage> createState() => _RuleFormPageState();
}

class _RuleFormPageState extends State<RuleFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _conditionsCtrl = TextEditingController();
  final _assertionCtrl = TextEditingController();
  final _briefCtrl = TextEditingController();
  final _chapterCtrl = TextEditingController();
  final _originalTextCtrl = TextEditingController();
  final _explanationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _versionCtrl = TextEditingController(text: '1.0.0');
  final _versionRemarkCtrl = TextEditingController();

  List<Pattern> _patterns = [];
  List<School> _schools = [];
  String? _selectedPatternId;
  String? _selectedSchoolId;
  String _jixiong = '吉';
  String _level = '中';
  String _geJuType = '贵';
  String _scope = 'both';
  String? _coordinateSystem;

  bool _isSaving = false;
  bool _isLoading = true;

  static const _jixiongOptions = ['吉', '平', '凶'];
  static const _levelOptions = ['小', '中', '大'];
  static const _geJuTypeOptions = ['贵', '富', '贫', '贱', '夭', '寿', '贤', '愚'];
  static const _scopeOptions = [
    ('natal', '仅命盘'),
    ('xingxian', '仅行限'),
    ('both', '通用'),
  ];
  static const _coordinateOptions = [
    (null, '不限'),
    ('ecliptic', '黄道制'),
    ('equatorial', '赤道制'),
  ];

  bool get _isEdit => widget.rule != null;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (_isEdit) {
      final r = widget.rule!;
      _conditionsCtrl.text = r.conditions ?? '';
      _assertionCtrl.text = r.assertion ?? '';
      _briefCtrl.text = r.brief ?? '';
      _chapterCtrl.text = r.chapter ?? '';
      _originalTextCtrl.text = r.originalText ?? '';
      _explanationCtrl.text = r.explanation ?? '';
      _notesCtrl.text = r.notes ?? '';
      _versionCtrl.text = r.version;
      _versionRemarkCtrl.text = r.versionRemark ?? '';
      _selectedPatternId = r.patternId;
      _selectedSchoolId = r.schoolId;
      _jixiong = r.jixiong;
      _level = r.level;
      _geJuType = r.geJuType;
      _scope = r.scope;
      _coordinateSystem = r.coordinateSystem;
    }
  }

  Future<void> _loadData() async {
    final patterns = await widget.db.select(widget.db.geJuPatterns).get();
    final schools = await widget.db.select(widget.db.geJuSchools).get();
    if (mounted) {
      setState(() {
        _patterns = patterns;
        _schools = schools;
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatternId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请选择格局')));
      return;
    }
    if (_selectedSchoolId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请选择流派')));
      return;
    }
    setState(() => _isSaving = true);

    String? n(String s) => s.trim().isEmpty ? null : s.trim();

    try {
      final now = DateTime.now();
      if (_isEdit) {
        await (widget.db.update(widget.db.geJuRules)
              ..where((r) => r.id.equals(widget.rule!.id)))
            .write(GeJuRulesCompanion(
          patternId: Value(_selectedPatternId!),
          schoolId: Value(_selectedSchoolId!),
          jixiong: Value(_jixiong),
          level: Value(_level),
          geJuType: Value(_geJuType),
          scope: Value(_scope),
          coordinateSystem: Value(_coordinateSystem),
          conditions: Value(n(_conditionsCtrl.text)),
          assertion: Value(n(_assertionCtrl.text)),
          brief: Value(n(_briefCtrl.text)),
          chapter: Value(n(_chapterCtrl.text)),
          originalText: Value(n(_originalTextCtrl.text)),
          explanation: Value(n(_explanationCtrl.text)),
          notes: Value(n(_notesCtrl.text)),
          version: Value(_versionCtrl.text.trim()),
          versionRemark: Value(n(_versionRemarkCtrl.text)),
          updatedAt: Value(now),
        ));
      } else {
        await widget.db.into(widget.db.geJuRules).insert(
              GeJuRulesCompanion.insert(
                patternId: _selectedPatternId!,
                schoolId: _selectedSchoolId!,
                jixiong: _jixiong,
                level: _level,
                geJuType: _geJuType,
                scope: _scope,
                version: _versionCtrl.text.trim(),
                createdAt: now,
                updatedAt: now,
                coordinateSystem: Value(_coordinateSystem),
                conditions: Value(n(_conditionsCtrl.text)),
                assertion: Value(n(_assertionCtrl.text)),
                brief: Value(n(_briefCtrl.text)),
                chapter: Value(n(_chapterCtrl.text)),
                originalText: Value(n(_originalTextCtrl.text)),
                explanation: Value(n(_explanationCtrl.text)),
                notes: Value(n(_notesCtrl.text)),
                versionRemark: Value(n(_versionRemarkCtrl.text)),
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
        title: Text(_isEdit ? '编辑规则' : '新建规则'),
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
          else if (!_isLoading)
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(_isEdit ? '保存' : '新建'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // --- 关联 ---
                  FormSection(label: '关联', children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPatternId,
                      decoration: const InputDecoration(
                        labelText: '格局 *',
                        border: OutlineInputBorder(),
                      ),
                      items: _patterns
                          .map((p) => DropdownMenuItem(
                              value: p.id, child: Text(p.name)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedPatternId = v),
                      validator: (v) => v == null ? '请选择格局' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSchoolId,
                      decoration: const InputDecoration(
                        labelText: '流派 *',
                        border: OutlineInputBorder(),
                      ),
                      items: _schools
                          .map((s) => DropdownMenuItem(
                              value: s.id, child: Text(s.name)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedSchoolId = v),
                      validator: (v) => v == null ? '请选择流派' : null,
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // --- 性质 ---
                  FormSection(label: '性质', children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _jixiong,
                            decoration: const InputDecoration(
                              labelText: '吉凶 *',
                              border: OutlineInputBorder(),
                            ),
                            items: _jixiongOptions
                                .map((v) => DropdownMenuItem(
                                    value: v, child: Text(v)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _jixiong = v);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _level,
                            decoration: const InputDecoration(
                              labelText: '层级 *',
                              border: OutlineInputBorder(),
                            ),
                            items: _levelOptions
                                .map((v) => DropdownMenuItem(
                                    value: v, child: Text(v)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _level = v);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _geJuType,
                            decoration: const InputDecoration(
                              labelText: '类型 *',
                              border: OutlineInputBorder(),
                            ),
                            items: _geJuTypeOptions
                                .map((v) => DropdownMenuItem(
                                    value: v, child: Text(v)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _geJuType = v);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _scope,
                            decoration: const InputDecoration(
                              labelText: '适用范围 *',
                              border: OutlineInputBorder(),
                            ),
                            items: _scopeOptions
                                .map((t) => DropdownMenuItem(
                                    value: t.$1, child: Text(t.$2)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _scope = v);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String?>(
                            initialValue: _coordinateSystem,
                            decoration: const InputDecoration(
                              labelText: '坐标系',
                              border: OutlineInputBorder(),
                            ),
                            items: _coordinateOptions
                                .map((t) => DropdownMenuItem(
                                    value: t.$1, child: Text(t.$2)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _coordinateSystem = v),
                          ),
                        ),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // --- 内容 ---
                  FormSection(label: '内容', children: [
                    TextFormField(
                      controller: _conditionsCtrl,
                      decoration: const InputDecoration(
                        labelText: '条件',
                        border: OutlineInputBorder(),
                        hintText: '格局成立的条件...',
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _assertionCtrl,
                      decoration: const InputDecoration(
                        labelText: '断语',
                        border: OutlineInputBorder(),
                        hintText: '格局的断语...',
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _briefCtrl,
                      decoration: const InputDecoration(
                        labelText: '简介',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _originalTextCtrl,
                      decoration: const InputDecoration(
                        labelText: '原文',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _explanationCtrl,
                      decoration: const InputDecoration(
                        labelText: '解释',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // --- 出处与版本 ---
                  FormSection(label: '出处与版本', children: [
                    TextFormField(
                      controller: _chapterCtrl,
                      decoration: const InputDecoration(
                        labelText: '章节/出处',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesCtrl,
                      decoration: const InputDecoration(
                        labelText: '备注',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _versionCtrl,
                            decoration: const InputDecoration(
                              labelText: '版本 *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? '请输入版本号'
                                    : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _versionRemarkCtrl,
                            decoration: const InputDecoration(
                              labelText: '版本备注',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
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
                    label: Text(_isEdit ? '保存规则' : '新建规则'),
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
    _conditionsCtrl.dispose();
    _assertionCtrl.dispose();
    _briefCtrl.dispose();
    _chapterCtrl.dispose();
    _originalTextCtrl.dispose();
    _explanationCtrl.dispose();
    _notesCtrl.dispose();
    _versionCtrl.dispose();
    _versionRemarkCtrl.dispose();
    super.dispose();
  }
}
