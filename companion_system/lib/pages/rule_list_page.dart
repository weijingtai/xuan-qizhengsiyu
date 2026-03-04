/// Excel 风格格局规则列表页面（支持内联编辑 + 列宽/列序拖拽调整）
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' show Value;
import 'package:companion_system/database/drift_database.dart';
import 'package:companion_system/providers/rule_provider.dart';
import 'package:companion_system/models/enums.dart';
import 'package:companion_system/pages/dialogs/rule_dialog.dart'
    show RuleFormPage;
import 'package:companion_system/pages/settings_page.dart';
import 'package:companion_system/pages/dialogs/ai_recognition_dialog.dart'
    show AiRecognitionDialog;
import 'package:ai_core/widgets/ai_chat_view.dart';
import 'package:companion_system/providers/ai_chat_controller.dart'
    show AiChatController;

// ── 列定义（顺序即默认显示顺序）────────────────────────────────────────────

typedef _Col = ({String label, double width});

// 列索引常量（不随列序改变）：
// [0]  #          [1] 格局名称   [2] 描述(pattern) [3] 简介(rule)
// [4]  流派        [5] 书籍      [6] 吉凶           [7] 层级
// [8]  类型        [9] 范围      [10] 版本          [11] 算法(conditions)
// [12] AI识别     [13] 章节     [14] 原文           [15] 原文注解
// [16] 注解       [17] 手动校验  [18] 保存          [19] 操作
const List<_Col> _kCols = [
  (label: '#', width: 48),
  (label: '格局名称', width: 160),
  (label: '描述', width: 200),
  (label: '简介', width: 150),
  (label: '流派', width: 120),
  (label: '书籍', width: 140),
  (label: '吉凶', width: 68),
  (label: '层级', width: 60),
  (label: '类型', width: 68),
  (label: '范围', width: 76),
  (label: '版本', width: 80),
  (label: '算法', width: 280),
  (label: 'AI识别', width: 72),
  (label: '章节', width: 120),
  (label: '原文', width: 200),
  (label: '原文注解', width: 180),
  (label: '注解', width: 160),
  (label: '手动校验', width: 72),
  (label: '保存', width: 104),
  (label: '操作', width: 100),
];

const _kMinColWidth = 40.0;
const _kPrefsKeyWidths = 'rule_list_col_widths';
const _kPrefsKeyOrder = 'rule_list_col_order';

// ── 流派配色 + 书籍映射 ───────────────────────────────────────────────────────

const _kSchoolColors = <String, Color>{
  'guo_lao':  Color(0xFF6B3A2A), // 栗棕 — 果老派
  'qin_tang': Color(0xFF1A6B5A), // 青碧 — 琴堂派
  'tian_guan': Color(0xFF6A3080), // 紫金 — 天官派
};

const _kSchoolBookNames = <String, String>{
  'guo_lao': '《果老星宗》',
};

// ── 格局类型配色（八种，传统国风）────────────────────────────────────────────

const _kTypeColors = <String, Color>{
  '贵': Color(0xFFC8920A), // 金黄 — 帝王之贵
  '富': Color(0xFFB82020), // 朱砂红 — 财富之色
  '贫': Color(0xFF7A7A7A), // 铅灰
  '贱': Color(0xFF5C3D2E), // 暗褐
  '夭': Color(0xFF7B1010), // 暗赤 — 凶厄
  '寿': Color(0xFF2E7D50), // 翡翠绿 — 长寿
  '贤': Color(0xFF1A4E8B), // 青花蓝 — 智慧
  '愚': Color(0xFF7D5A3C), // 土色
};

// ── 样式常量 ──────────────────────────────────────────────────────────────────

const _kHeaderHeight = 36.0;
const _kRowHeight = 40.0;
const _kBorderColor = Color(0xFFD0D0D0);
const _kBorderSide = BorderSide(color: _kBorderColor, width: 0.5);
const _kHeaderBg = Color(0xFFF0F0F0);
const _kEvenRowBg = Colors.white;
const _kOddRowBg = Color(0xFFF7F7F7);
const _kHoverBg = Color(0xFFEBF4FF);
const _kCellStyle = TextStyle(fontSize: 13, color: Color(0xFF222222));
const _kHeaderText = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 13,
  color: Color(0xFF333333),
);

// ── 下拉选项常量 ──────────────────────────────────────────────────────────────

const _kJixiongOptions = [('吉', '吉'), ('平', '平'), ('凶', '凶')];
const _kLevelOptions = [('小', '小'), ('中', '中'), ('大', '大')];
const _kTypeOptions = [
  ('贵', '贵'), ('富', '富'), ('贫', '贫'), ('贱', '贱'),
  ('夭', '夭'), ('寿', '寿'), ('贤', '贤'), ('愚', '愚'),
];
const _kScopeOptions = [
  ('命盘', 'natal'),
  ('行限', 'xingxian'),
  ('通用', 'both'),
];

// ══════════════════════════════════════════════════════════════════════════════
// RuleListPage
// ══════════════════════════════════════════════════════════════════════════════

class RuleListPage extends StatefulWidget {
  const RuleListPage({super.key});

  @override
  State<RuleListPage> createState() => _RuleListPageState();
}

class _RuleListPageState extends State<RuleListPage> {
  List<School> _schools = [];
  Map<String, String> _patternNames = {};
  Map<String, String?> _patternDescriptions = {};

  final _hHeader = ScrollController();
  final _hBody = ScrollController();
  final _vBody = ScrollController();
  bool _syncLock = false;

  // ── 列宽 + 列序（可拖拽调整，持久化）────────────────────────────────────
  late List<double> _colWidths;
  late List<int> _colOrder; // _colOrder[pos] = colIdx

  double get _tableWidth => _colOrder.fold(0.0, (s, i) => s + _colWidths[i]);

  void _resizeCol(int colIdx, double delta) {
    setState(() {
      _colWidths[colIdx] =
          (_colWidths[colIdx] + delta).clamp(_kMinColWidth, 800.0);
    });
    _savePrefs();
  }

  void _moveCol(int fromPos, int toPos) {
    if (fromPos == toPos) return;
    setState(() {
      final item = _colOrder.removeAt(fromPos);
      _colOrder.insert(toPos, item);
    });
    _savePrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final wJson = prefs.getString(_kPrefsKeyWidths);
    final oJson = prefs.getString(_kPrefsKeyOrder);
    if (!mounted || wJson == null || oJson == null) return;
    try {
      final ws = List<double>.from(
          (jsonDecode(wJson) as List).map((e) => (e as num).toDouble()));
      final os = List<int>.from(
          (jsonDecode(oJson) as List).map((e) => (e as num).toInt()));
      if (ws.length == _kCols.length &&
          os.length == _kCols.length &&
          os.toSet().length == _kCols.length) {
        setState(() {
          _colWidths = ws;
          _colOrder = os;
        });
      }
    } catch (_) {}
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefsKeyWidths, jsonEncode(_colWidths));
    await prefs.setString(_kPrefsKeyOrder, jsonEncode(_colOrder));
  }

  // ── 分页 ──────────────────────────────────────────────────────────────────
  int _currentPage = 0;
  int _pageSize = 50;
  void _resetPage() => setState(() => _currentPage = 0);

  @override
  void initState() {
    super.initState();
    _colWidths = _kCols.map((c) => c.width).toList();
    _colOrder = List.generate(_kCols.length, (i) => i);
    _hHeader.addListener(_syncHeaderToBody);
    _hBody.addListener(_syncBodyToHeader);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPrefs();
      if (mounted) {
        context.read<RuleProvider>().loadRules();
        _loadLookups();
      }
    });
  }

  void _syncHeaderToBody() {
    if (_syncLock) return;
    _syncLock = true;
    if (_hBody.hasClients) _hBody.jumpTo(_hHeader.offset);
    _syncLock = false;
  }

  void _syncBodyToHeader() {
    if (_syncLock) return;
    _syncLock = true;
    if (_hHeader.hasClients) _hHeader.jumpTo(_hBody.offset);
    _syncLock = false;
  }

  @override
  void dispose() {
    _hHeader.dispose();
    _hBody.dispose();
    _vBody.dispose();
    super.dispose();
  }

  Future<void> _loadLookups() async {
    final db = context.read<AppDatabase>();
    final schools = await db.select(db.geJuSchools).get();
    final patterns = await db.select(db.geJuPatterns).get();
    if (!mounted) return;
    setState(() {
      _schools = schools;
      _patternNames = {for (final p in patterns) p.id: p.name};
      _patternDescriptions = {for (final p in patterns) p.id: p.description};
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('格局规则列表'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'LLM 设置',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
          Tooltip(
            message: '重置列宽和列序',
            child: IconButton(
              icon: const Icon(Icons.view_column_outlined),
              onPressed: () {
                setState(() {
                  _colWidths = _kCols.map((c) => c.width).toList();
                  _colOrder = List.generate(_kCols.length, (i) => i);
                });
                _savePrefs();
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
            onPressed: () {
              context.read<RuleProvider>().loadRules();
              _loadLookups();
            },
          ),
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.chat_outlined),
              tooltip: 'AI 对话',
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        width: 480,
        child: SafeArea(
          child: Consumer<AiChatController>(
            builder: (ctx, controller, _) {
              if (!controller.isInitialized) {
                if (controller.error != null) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        SelectableText(
                          controller.error!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '请检查 API Key 和 Base URL 配置。',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              }
              final persona = controller.persona;
              final sessionUuid = controller.sessionUuid;
              if (persona == null || sessionUuid == null) {
                return const Center(child: Text('配置错误，请检查 API Key 和模型设置。'));
              }
              return AiChatView(
                key: ValueKey(controller.refreshKey),
                persona: persona,
                sessionUuid: sessionUuid,
                db: controller.db,
                aiService: controller.aiService,
                history: controller.history,
                welcomeMessage: '您好！我是格局助手。\n\n'
                    '您可以查看 AI 识别记录，也可以直接提问。',
              );
            },
          ),
        ),
      ),
      body: Column(
        children: [
          _FilterBar(schools: _schools, onFilterChanged: _resetPage),
          // ── 固定表头 ─────────────────────────────────────────
          Container(
            height: _kHeaderHeight,
            decoration: const BoxDecoration(
              color: _kHeaderBg,
              border: Border(
                bottom: BorderSide(color: Color(0xFFAAAAAA), width: 1.5),
              ),
            ),
            child: SingleChildScrollView(
              controller: _hHeader,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                width: _tableWidth,
                height: _kHeaderHeight,
                child: Row(
                  children: List.generate(_colOrder.length, (pos) {
                    final colIdx = _colOrder[pos];
                    return DragTarget<int>(
                      onAcceptWithDetails: (details) => _moveCol(details.data, pos),
                      builder: (_, candidates, __) {
                        final isTarget = candidates.isNotEmpty;
                        return LongPressDraggable<int>(
                          data: pos,
                          delay: const Duration(milliseconds: 350),
                          feedback: Material(
                            elevation: 8,
                            color: Colors.transparent,
                            child: Container(
                              width: _colWidths[colIdx],
                              height: _kHeaderHeight,
                              alignment: Alignment.centerLeft,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                border: Border.all(
                                    color: Colors.blue.shade400, width: 1.5),
                              ),
                              child: Text(_kCols[colIdx].label,
                                  style: _kHeaderText),
                            ),
                          ),
                          childWhenDragging: Container(
                            width: _colWidths[colIdx],
                            height: _kHeaderHeight,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              border: const Border(right: _kBorderSide),
                            ),
                          ),
                          child: Stack(
                            children: [
                              _ResizableHeaderCell(
                                label: _kCols[colIdx].label,
                                width: _colWidths[colIdx],
                                onResize: (d) => _resizeCol(colIdx, d),
                              ),
                              if (isTarget)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withValues(alpha: 0.12),
                                      border: Border(
                                        left: BorderSide(
                                            color: Colors.blue.shade400,
                                            width: 2.5),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
          // ── 分页栏 ───────────────────────────────────────────
          Consumer<RuleProvider>(
            builder: (_, provider, __) {
              final total = provider.rules.length;
              final totalPages =
                  (total / _pageSize).ceil().clamp(1, 99999);
              return _PaginationBar(
                currentPage: _currentPage.clamp(0, totalPages - 1),
                totalPages: totalPages,
                totalItems: total,
                pageSize: _pageSize,
                onPageChanged: (p) => setState(() => _currentPage = p),
                onPageSizeChanged: (s) => setState(() {
                  _pageSize = s;
                  _currentPage = 0;
                }),
              );
            },
          ),
          // ── 状态栏 ───────────────────────────────────────────
          Consumer<RuleProvider>(
            builder: (_, provider, __) => Container(
              height: 26,
              color: const Color(0xFFF0F0F0),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text('共 ${provider.rules.length} 条',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey)),
                  if (provider.searchKeyword.isNotEmpty ||
                      provider.selectedSchoolId != null ||
                      provider.selectedJixiong != null) ...[
                    const Text(' · ',
                        style: TextStyle(color: Colors.grey)),
                    Text('已过滤',
                        style: TextStyle(
                            fontSize: 12, color: Colors.orange[700])),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '新建规则',
        onPressed: () async {
          final db = context.read<AppDatabase>();
          final provider = context.read<RuleProvider>();
          final saved = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => RuleFormPage(db: db)),
          );
          if (saved == true && mounted) provider.loadRules();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<RuleProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(provider.errorMessage!),
                const SizedBox(height: 12),
                ElevatedButton(
                    onPressed: provider.loadRules, child: const Text('重试')),
              ],
            ),
          );
        }
        if (provider.rules.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text('暂无数据', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        final allRules = provider.rules;
        final totalPages =
            (allRules.length / _pageSize).ceil().clamp(1, 99999);
        final safePage = _currentPage.clamp(0, totalPages - 1);
        final start = safePage * _pageSize;
        final end = (start + _pageSize).clamp(0, allRules.length);
        final rules = allRules.sublist(start, end);

        return Scrollbar(
          controller: _vBody,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _vBody,
            child: Scrollbar(
              controller: _hBody,
              thumbVisibility: true,
              notificationPredicate: (n) => n.depth == 1,
              child: SingleChildScrollView(
                controller: _hBody,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: _tableWidth,
                  child: Column(
                    children: List.generate(rules.length, (i) {
                      final rule = rules[i];
                      return _HoverableRow(
                        key: ValueKey(rule.id),
                        index: start + i,
                        rule: rule,
                        colWidths: _colWidths,
                        colOrder: _colOrder,
                        patternName:
                            _patternNames[rule.patternId] ?? rule.patternId,
                        patternDescription:
                            _patternDescriptions[rule.patternId] ?? '',
                        allSchools: _schools,
                        provider: provider,
                        onReloadLookups: _loadLookups,
                        onShowDetail: _showRuleDetail,
                        onShowDelete: _showDeleteDialog,
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── 详情弹窗 ──────────────────────────────────────────────────────────────

  void _showRuleDetail(BuildContext context, Rule rule) {
    final patternName = _patternNames[rule.patternId] ?? rule.patternId;
    final school =
        _schools.where((s) => s.id == rule.schoolId).firstOrNull;
    final schoolName = school?.name ?? rule.schoolId;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(patternName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_patternDescriptions[rule.patternId] != null)
                _detailRow('描述', _patternDescriptions[rule.patternId]!,
                    multi: true),
              _detailRow('流派', schoolName),
              _detailRow('书籍',
                  _kSchoolBookNames[rule.schoolId] ?? ''),
              _detailRow('吉凶', '${rule.jixiong}（${rule.level}）'),
              _detailRow('类型', rule.geJuType),
              _detailRow('范围', _scopeLabel(rule.scope)),
              _detailRow('版本', rule.version),
              if (rule.brief != null)
                _detailRow('简介', rule.brief!, multi: true),
              if (rule.conditions != null)
                _conditionDetailRow(rule.conditions!),
              if (rule.chapter != null)
                _detailRow('章节', rule.chapter!),
              if (rule.originalText != null)
                _detailRow('原文', rule.originalText!, multi: true),
              if (rule.explanation != null)
                _detailRow('原文注解', rule.explanation!, multi: true),
              if (rule.notes != null)
                _detailRow('注解', rule.notes!, multi: true),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('关闭')),
          TextButton(
            onPressed: () async {
              final db = context.read<AppDatabase>();
              final provider = context.read<RuleProvider>();
              Navigator.of(dialogCtx).pop();
              final saved = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                    builder: (_) => RuleFormPage(db: db, rule: rule)),
              );
              if (saved == true && mounted) {
                provider.loadRules();
                _loadLookups();
              }
            },
            child: const Text('编辑'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, Rule rule, RuleProvider provider) {
    final name = _patternNames[rule.patternId] ?? rule.patternId;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除规则「$name」吗？此操作不可恢复。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('取消')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogCtx);
              provider.deleteRule(rule.id);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  static Widget _conditionDetailRow(String condJson) {
    Map<String, dynamic>? cond;
    try {
      cond = jsonDecode(condJson) as Map<String, dynamic>;
    } catch (_) {}
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 72,
            child: Text('算法:',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: cond != null
                ? _ConditionTreeNode(cond: cond, depth: 0)
                : Text(condJson,
                    style: const TextStyle(
                        color: Colors.red,
                        fontFamily: 'monospace',
                        fontSize: 11)),
          ),
        ],
      ),
    );
  }

  static Widget _detailRow(String label, String value,
      {bool multi = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 72,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              child: Text(value,
                  maxLines: multi ? null : 2,
                  overflow:
                      multi ? null : TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _FilterBar
// ══════════════════════════════════════════════════════════════════════════════

class _FilterBar extends StatelessWidget {
  final List<School> schools;
  final VoidCallback onFilterChanged;
  const _FilterBar({required this.schools, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    return Consumer<RuleProvider>(
      builder: (context, provider, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: const Border(bottom: BorderSide(color: _kBorderColor)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 220,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: '搜索...',
                  prefixIcon: Icon(Icons.search, size: 18),
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                ),
                onChanged: (v) {
                  provider.setSearchKeyword(v);
                  onFilterChanged();
                },
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 140,
              child: DropdownButton<String>(
                hint: const Text('流派'),
                value: provider.selectedSchoolId,
                isExpanded: true,
                isDense: true,
                items: [
                  const DropdownMenuItem(value: null, child: Text('全部流派')),
                  ...schools.map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(s.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: _kSchoolColors[s.id])),
                      )),
                ],
                onChanged: (v) {
                  provider.setSelectedSchoolId(v);
                  onFilterChanged();
                },
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: DropdownButton<Jixiong>(
                hint: const Text('吉凶'),
                value: provider.selectedJixiong,
                isExpanded: true,
                isDense: true,
                items: const [
                  DropdownMenuItem(value: null, child: Text('全部')),
                  DropdownMenuItem(value: Jixiong.ji, child: Text('吉')),
                  DropdownMenuItem(value: Jixiong.ping, child: Text('平')),
                  DropdownMenuItem(value: Jixiong.xiong, child: Text('凶')),
                ],
                onChanged: (v) {
                  provider.setSelectedJixiong(v);
                  onFilterChanged();
                },
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () {
                provider.clearFilters();
                onFilterChanged();
              },
              icon: const Icon(Icons.filter_alt_off, size: 16),
              label: const Text('清除'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _PaginationBar
// ══════════════════════════════════════════════════════════════════════════════

class _PaginationBar extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final void Function(int) onPageChanged;
  final void Function(int) onPageSizeChanged;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  @override
  State<_PaginationBar> createState() => _PaginationBarState();
}

class _PaginationBarState extends State<_PaginationBar> {
  late final TextEditingController _jumpCtrl;

  @override
  void initState() {
    super.initState();
    _jumpCtrl = TextEditingController(text: '${widget.currentPage + 1}');
  }

  @override
  void didUpdateWidget(covariant _PaginationBar old) {
    super.didUpdateWidget(old);
    if (old.currentPage != widget.currentPage) {
      _jumpCtrl.text = '${widget.currentPage + 1}';
    }
  }

  @override
  void dispose() {
    _jumpCtrl.dispose();
    super.dispose();
  }

  void _jump() {
    final page = int.tryParse(_jumpCtrl.text.trim());
    if (page != null) {
      widget.onPageChanged((page - 1).clamp(0, widget.totalPages - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.currentPage;
    final tp = widget.totalPages;
    final start = p * widget.pageSize + 1;
    final end =
        ((p + 1) * widget.pageSize).clamp(0, widget.totalItems);

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F8F8),
        border: Border(
          top: BorderSide(color: _kBorderColor),
          bottom: BorderSide(color: _kBorderColor),
        ),
      ),
      child: Row(
        children: [
          const Text('每页:', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          DropdownButton<int>(
            value: widget.pageSize,
            isDense: true,
            underline: const SizedBox(),
            items: [20, 50, 100, 200]
                .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text('$s 行',
                          style: const TextStyle(fontSize: 12)),
                    ))
                .toList(),
            onChanged: (s) {
              if (s != null) widget.onPageSizeChanged(s);
            },
          ),
          const SizedBox(width: 16),
          Text('共 ${widget.totalItems} 条  ·  $start–$end',
              style:
                  const TextStyle(fontSize: 12, color: Colors.grey)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.first_page),
            iconSize: 18,
            tooltip: '首页',
            splashRadius: 16,
            onPressed: p > 0 ? () => widget.onPageChanged(0) : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            iconSize: 18,
            tooltip: '上一页',
            splashRadius: 16,
            onPressed:
                p > 0 ? () => widget.onPageChanged(p - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('第 ${p + 1} / $tp 页',
                style: const TextStyle(fontSize: 12)),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            iconSize: 18,
            tooltip: '下一页',
            splashRadius: 16,
            onPressed:
                p < tp - 1 ? () => widget.onPageChanged(p + 1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            iconSize: 18,
            tooltip: '末页',
            splashRadius: 16,
            onPressed:
                p < tp - 1 ? () => widget.onPageChanged(tp - 1) : null,
          ),
          const SizedBox(width: 16),
          const Text('跳至', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          SizedBox(
            width: 44,
            height: 26,
            child: TextField(
              controller: _jumpCtrl,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _jump(),
            ),
          ),
          const SizedBox(width: 4),
          const Text('页', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          SizedBox(
            height: 26,
            child: TextButton(
              onPressed: _jump,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
              ),
              child: const Text('GO', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _ResizableHeaderCell — 可拖拽调整列宽的表头格
// ══════════════════════════════════════════════════════════════════════════════

class _ResizableHeaderCell extends StatefulWidget {
  final String label;
  final double width;
  final void Function(double delta) onResize;

  const _ResizableHeaderCell({
    required this.label,
    required this.width,
    required this.onResize,
  });

  @override
  State<_ResizableHeaderCell> createState() => _ResizableHeaderCellState();
}

class _ResizableHeaderCellState extends State<_ResizableHeaderCell> {
  bool _handleHovered = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: _kHeaderHeight,
      child: Stack(
        children: [
          Container(
            width: widget.width,
            height: _kHeaderHeight,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 8, right: 14),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: _handleHovered
                      ? Colors.blue.shade400
                      : _kBorderColor,
                  width: _handleHovered ? 2.0 : 0.5,
                ),
              ),
            ),
            child: Text(widget.label,
                style: _kHeaderText, overflow: TextOverflow.ellipsis),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 6,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              onEnter: (_) => setState(() => _handleHovered = true),
              onExit: (_) => setState(() => _handleHovered = false),
              child: GestureDetector(
                onHorizontalDragUpdate: (d) =>
                    widget.onResize(d.delta.dx),
                onHorizontalDragStart: (_) =>
                    setState(() => _handleHovered = true),
                onHorizontalDragEnd: (_) =>
                    setState(() => _handleHovered = false),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _HoverableRow
// ══════════════════════════════════════════════════════════════════════════════

class _HoverableRow extends StatefulWidget {
  final int index;
  final Rule rule;
  final List<double> colWidths;
  final List<int> colOrder; // 列显示顺序
  final String patternName;
  final String patternDescription;
  final List<School> allSchools;
  final RuleProvider provider;
  final VoidCallback onReloadLookups;
  final void Function(BuildContext, Rule) onShowDetail;
  final void Function(BuildContext, Rule, RuleProvider) onShowDelete;

  const _HoverableRow({
    super.key,
    required this.index,
    required this.rule,
    required this.colWidths,
    required this.colOrder,
    required this.patternName,
    required this.patternDescription,
    required this.allSchools,
    required this.provider,
    required this.onReloadLookups,
    required this.onShowDetail,
    required this.onShowDelete,
  });

  @override
  State<_HoverableRow> createState() => _HoverableRowState();
}

class _HoverableRowState extends State<_HoverableRow> {
  bool _hovered = false;

  late String _dDescription;
  late String _dBrief;
  late String _dSchoolId;
  late String _dJixiong;
  late String _dLevel;
  late String _dGeJuType;
  late String _dScope;
  late String _dVersion;
  late String _dConditions;
  late String _dChapter;
  late String _dOriginalText;
  late String _dExplanation;
  late String _dNotes;

  void _initDraft() {
    final r = widget.rule;
    _dDescription = widget.patternDescription;
    _dBrief = r.brief ?? '';
    _dSchoolId = r.schoolId;
    _dJixiong = r.jixiong;
    _dLevel = r.level;
    _dGeJuType = r.geJuType;
    _dScope = r.scope;
    _dVersion = r.version;
    _dConditions = r.conditions ?? '';
    _dChapter = r.chapter ?? '';
    _dOriginalText = r.originalText ?? '';
    _dExplanation = r.explanation ?? '';
    _dNotes = r.notes ?? '';
  }

  bool get _isDirty {
    final r = widget.rule;
    return _dDescription != widget.patternDescription ||
        _dBrief != (r.brief ?? '') ||
        _dSchoolId != r.schoolId ||
        _dJixiong != r.jixiong ||
        _dLevel != r.level ||
        _dGeJuType != r.geJuType ||
        _dScope != r.scope ||
        _dVersion != r.version ||
        _dConditions != (r.conditions ?? '') ||
        _dChapter != (r.chapter ?? '') ||
        _dOriginalText != (r.originalText ?? '') ||
        _dExplanation != (r.explanation ?? '') ||
        _dNotes != (r.notes ?? '');
  }

  @override
  void initState() {
    super.initState();
    _initDraft();
  }

  @override
  void didUpdateWidget(covariant _HoverableRow old) {
    super.didUpdateWidget(old);
    final r = widget.rule;
    final o = old.rule;
    if (widget.patternDescription != old.patternDescription ||
        r.brief != o.brief ||
        r.schoolId != o.schoolId ||
        r.jixiong != o.jixiong ||
        r.level != o.level ||
        r.geJuType != o.geJuType ||
        r.scope != o.scope ||
        r.version != o.version ||
        r.conditions != o.conditions ||
        r.chapter != o.chapter ||
        r.originalText != o.originalText ||
        r.explanation != o.explanation ||
        r.notes != o.notes) {
      _initDraft();
    }
  }

  Color get _bg {
    if (_hovered) return _kHoverBg;
    return widget.index.isEven ? _kEvenRowBg : _kOddRowBg;
  }

  void _save() {
    widget.provider.updateRule(
      widget.rule.id,
      GeJuRulesCompanion(
        schoolId: Value(_dSchoolId),
        jixiong: Value(_dJixiong),
        level: Value(_dLevel),
        geJuType: Value(_dGeJuType),
        scope: Value(_dScope),
        version: Value(_dVersion),
        brief: Value(_dBrief.isEmpty ? null : _dBrief),
        conditions: Value(_dConditions.isEmpty ? null : _dConditions),
        chapter: Value(_dChapter.isEmpty ? null : _dChapter),
        originalText:
            Value(_dOriginalText.isEmpty ? null : _dOriginalText),
        explanation:
            Value(_dExplanation.isEmpty ? null : _dExplanation),
        notes: Value(_dNotes.isEmpty ? null : _dNotes),
        isVerified: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    if (_dDescription != widget.patternDescription) {
      widget.provider
          .updatePatternDescription(
        widget.rule.patternId,
        _dDescription.isEmpty ? null : _dDescription,
      )
          .then((_) => widget.onReloadLookups());
    }
  }

  // ── 按列索引构建单元格 ──────────────────────────────────────────────────

  Widget _buildCell(BuildContext context, int colIdx, double w) {
    final rule = widget.rule;
    final schoolOptions =
        widget.allSchools.map((s) => (s.name, s.id)).toList();

    switch (colIdx) {
      case 0: // # 序号
        return GestureDetector(
          onTap: () => widget.onShowDetail(context, rule),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: _Cell(
              text: '${widget.index + 1}',
              width: w,
              align: Alignment.center,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ),
        );
      case 1: // 格局名称
        return GestureDetector(
          onTap: () => widget.onShowDetail(context, rule),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: _Cell(
              text: widget.patternName,
              width: w,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        );
      case 2: // 描述（pattern.description）
        return _TextEditCell(
          text: _dDescription,
          width: w,
          onSave: (v) => setState(() => _dDescription = v),
        );
      case 3: // 简介
        return _TextEditCell(
          text: _dBrief,
          width: w,
          onSave: (v) => setState(() => _dBrief = v),
        );
      case 4: // 流派（带颜色）
        return _DropdownEditCell(
          value: _dSchoolId,
          width: w,
          options: schoolOptions,
          selectedStyle: (v) => TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _kSchoolColors[v] ?? Colors.grey[700]!,
          ),
          itemStyle: (v) => TextStyle(
            fontSize: 13,
            color: _kSchoolColors[v] ?? _kCellStyle.color!,
          ),
          onSave: (v) => setState(() => _dSchoolId = v),
        );
      case 5: // 书籍（只读，从 schoolId 派生，显示《》书名）
        return _Cell(
          text: _kSchoolBookNames[rule.schoolId] ?? '',
          width: w,
          style: const TextStyle(
              fontSize: 13, color: Color(0xFF555555), fontStyle: FontStyle.italic),
        );
      case 6: // 吉凶（彩色）
        return _DropdownEditCell(
          value: _dJixiong,
          width: w,
          options: _kJixiongOptions,
          selectedStyle: (v) => TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: switch (v) {
              '吉' => Colors.green[700]!,
              '凶' => Colors.red[700]!,
              _ => Colors.grey[600]!,
            },
          ),
          onSave: (v) => setState(() => _dJixiong = v),
        );
      case 7: // 层级
        return _DropdownEditCell(
          value: _dLevel,
          width: w,
          options: _kLevelOptions,
          onSave: (v) => setState(() => _dLevel = v),
        );
      case 8: // 类型（八种国风配色）
        return _DropdownEditCell(
          value: _dGeJuType,
          width: w,
          options: _kTypeOptions,
          selectedStyle: (v) => TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _kTypeColors[v] ?? _kCellStyle.color!,
          ),
          itemStyle: (v) => TextStyle(
            fontSize: 13,
            color: _kTypeColors[v] ?? _kCellStyle.color!,
          ),
          onSave: (v) => setState(() => _dGeJuType = v),
        );
      case 9: // 范围
        return _DropdownEditCell(
          value: _dScope,
          width: w,
          options: _kScopeOptions,
          onSave: (v) => setState(() => _dScope = v),
        );
      case 10: // 版本
        return _TextEditCell(
          text: _dVersion,
          width: w,
          onSave: (v) => setState(() => _dVersion = v),
        );
      case 11: // 算法（conditions JSON）内联可视化
        return _ConditionInlineCell(
          jsonText: _dConditions,
          width: w,
          onSave: (v) => setState(() => _dConditions = v),
        );
      case 12: // AI识别
        return _AiCell(
          width: w,
          rule: rule,
          patternName: widget.patternName,
          patternDescription: widget.patternDescription.isNotEmpty
              ? widget.patternDescription
              : null,
          currentConditions: _dConditions,
          provider: widget.provider,
          onUpdateConditions: (newJson) =>
              setState(() => _dConditions = newJson),
        );
      case 13: // 章节
        return _TextEditCell(
          text: _dChapter,
          width: w,
          onSave: (v) => setState(() => _dChapter = v),
        );
      case 14: // 原文
        return _TextEditCell(
          text: _dOriginalText,
          width: w,
          onSave: (v) => setState(() => _dOriginalText = v),
        );
      case 15: // 原文注解
        return _TextEditCell(
          text: _dExplanation,
          width: w,
          onSave: (v) => setState(() => _dExplanation = v),
        );
      case 16: // 注解
        return _TextEditCell(
          text: _dNotes,
          width: w,
          onSave: (v) => setState(() => _dNotes = v),
        );
      case 17: // 手动校验
        return _VerifyCell(
          verified: rule.isVerified,
          width: w,
          onToggle: (v) => widget.provider.updateRule(
            rule.id,
            GeJuRulesCompanion(isVerified: Value(v)),
          ),
        );
      case 18: // 保存 + 回滚
        return _SaveCell(
          dirty: _isDirty,
          width: w,
          onSave: _save,
          onRollback: () => setState(_initDraft),
        );
      case 19: // 操作
        return SizedBox(
          width: w,
          height: _kRowHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionBtn(
                icon: Icons.visibility_outlined,
                tooltip: '查看详情',
                color: Colors.blueGrey,
                onPressed: () => widget.onShowDetail(context, rule),
              ),
              _ActionBtn(
                icon: Icons.edit_note,
                tooltip: '编辑完整表单',
                color: Colors.blue,
                onPressed: () async {
                  final db = context.read<AppDatabase>();
                  final saved = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => RuleFormPage(db: db, rule: rule)),
                  );
                  if (saved == true && mounted) {
                    widget.provider.loadRules();
                    widget.onReloadLookups();
                  }
                },
              ),
              _ActionBtn(
                icon: Icons.delete_outline,
                tooltip: '删除',
                color: Colors.red,
                onPressed: () =>
                    widget.onShowDelete(context, rule, widget.provider),
              ),
            ],
          ),
        );
      default:
        return _Cell(text: '', width: w);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        height: _kRowHeight,
        decoration: BoxDecoration(
          color: _bg,
          border: const Border(bottom: _kBorderSide),
        ),
        child: Row(
          children: List.generate(widget.colOrder.length, (pos) {
            final colIdx = widget.colOrder[pos];
            return _buildCell(context, colIdx, widget.colWidths[colIdx]);
          }),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _DropdownEditCell
// ══════════════════════════════════════════════════════════════════════════════

class _DropdownEditCell extends StatelessWidget {
  final String value;
  final double width;
  final List<(String, String)> options;
  final void Function(String) onSave;
  final TextStyle Function(String)? selectedStyle;
  final TextStyle Function(String)? itemStyle; // 下拉列表项样式

  const _DropdownEditCell({
    required this.value,
    required this.width,
    required this.options,
    required this.onSave,
    this.selectedStyle,
    this.itemStyle,
  });

  @override
  Widget build(BuildContext context) {
    final safeOptions = options.any((o) => o.$2 == value)
        ? options
        : [...options, (value, value)];

    return Container(
      width: width,
      height: _kRowHeight,
      padding: const EdgeInsets.only(left: 4),
      decoration:
          const BoxDecoration(border: Border(right: _kBorderSide)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          iconSize: 14,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          style: _kCellStyle,
          selectedItemBuilder: selectedStyle == null
              ? null
              : (ctx) => safeOptions
                  .map((o) => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          o.$1,
                          style: selectedStyle!.call(o.$2),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
          items: safeOptions
              .map((o) => DropdownMenuItem<String>(
                    value: o.$2,
                    child: Text(o.$1,
                        style: itemStyle?.call(o.$2) ?? _kCellStyle),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null && v != value) onSave(v);
          },
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _TextEditCell
// ══════════════════════════════════════════════════════════════════════════════

class _TextEditCell extends StatefulWidget {
  final String text;
  final double width;
  final void Function(String) onSave;

  const _TextEditCell({
    required this.text,
    required this.width,
    required this.onSave,
  });

  @override
  State<_TextEditCell> createState() => _TextEditCellState();
}

class _TextEditCellState extends State<_TextEditCell> {
  bool _editing = false;
  late final TextEditingController _ctrl;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.text);
    _focus = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _TextEditCell old) {
    super.didUpdateWidget(old);
    if (!_editing && old.text != widget.text) {
      _ctrl.text = widget.text;
    }
  }

  void _onFocusChange() {
    if (!_focus.hasFocus && _editing) _commit();
  }

  void _startEditing() {
    setState(() => _editing = true);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _commit() {
    setState(() => _editing = false);
    final newVal = _ctrl.text.trim();
    if (newVal != widget.text) widget.onSave(newVal);
  }

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return Container(
        width: widget.width,
        height: _kRowHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.blue.shade300, width: 1.5),
            bottom: BorderSide(color: Colors.blue.shade300, width: 1.5),
            left: BorderSide(color: Colors.blue.shade300, width: 1.5),
            right: _kBorderSide,
          ),
        ),
        child: TextField(
          controller: _ctrl,
          focusNode: _focus,
          style: _kCellStyle,
          decoration: const InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            border: InputBorder.none,
            isDense: true,
          ),
          onSubmitted: (_) => _commit(),
        ),
      );
    }
    return GestureDetector(
      onDoubleTap: _startEditing,
      child: MouseRegion(
        cursor: SystemMouseCursors.text,
        child: Container(
          width: widget.width,
          height: _kRowHeight,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration:
              const BoxDecoration(border: Border(right: _kBorderSide)),
          child: Text(widget.text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: _kCellStyle),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 只读单元格
// ══════════════════════════════════════════════════════════════════════════════

class _Cell extends StatelessWidget {
  final String text;
  final double width;
  final Alignment align;
  final TextStyle? style;

  const _Cell({
    required this.text,
    required this.width,
    this.align = Alignment.centerLeft,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: _kRowHeight,
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration:
          const BoxDecoration(border: Border(right: _kBorderSide)),
      child: Text(text,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: style ?? _kCellStyle),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 操作按钮
// ══════════════════════════════════════════════════════════════════════════════

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;

  const _ActionBtn({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _VerifyCell
// ══════════════════════════════════════════════════════════════════════════════

class _VerifyCell extends StatelessWidget {
  final bool verified;
  final double width;
  final void Function(bool) onToggle;

  const _VerifyCell({
    required this.verified,
    required this.width,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: _kRowHeight,
      alignment: Alignment.center,
      decoration:
          const BoxDecoration(border: Border(right: _kBorderSide)),
      child: Tooltip(
        message: verified ? '已校验' : '未校验',
        child: SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: verified,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            activeColor: Colors.green[600],
            onChanged: (v) => onToggle(v ?? false),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _AiCell
// ══════════════════════════════════════════════════════════════════════════════

class _AiCell extends StatefulWidget {
  final double width;
  final Rule rule;
  final String patternName;
  final String? patternDescription;
  final String currentConditions;
  final RuleProvider provider;
  final void Function(String) onUpdateConditions;

  const _AiCell({
    required this.width,
    required this.rule,
    required this.patternName,
    this.patternDescription,
    required this.currentConditions,
    required this.provider,
    required this.onUpdateConditions,
  });

  @override
  State<_AiCell> createState() => _AiCellState();
}

class _AiCellState extends State<_AiCell> {
  bool _working = false;

  Future<void> _openDialog() async {
    if (_working) return;
    setState(() => _working = true);
    try {
      final result = await AiRecognitionDialog.show(
        context,
        rule: widget.rule,
        patternName: widget.patternName,
        patternDescription: widget.patternDescription,
      );
      if (result != null && mounted) {
        widget.onUpdateConditions(result.conditionsJson);
        if (result.shouldSave) {
          await widget.provider.updateRule(
            widget.rule.id,
            GeJuRulesCompanion(
              conditions: Value(result.conditionsJson),
              isVerified: const Value(true),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final verified = widget.rule.isVerified;
    return Container(
      width: widget.width,
      height: _kRowHeight,
      alignment: Alignment.center,
      decoration: const BoxDecoration(border: Border(right: _kBorderSide)),
      child: _working
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            )
          : Tooltip(
              message: verified ? 'AI识别（已校验）' : 'AI识别',
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.psychology_outlined,
                      size: 16,
                      color: verified ? Colors.green[700] : Colors.blue[600],
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    onPressed: _openDialog,
                  ),
                  if (verified)
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Icon(
                        Icons.check_circle,
                        size: 9,
                        color: Colors.green[700],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _SaveCell
// ══════════════════════════════════════════════════════════════════════════════

class _SaveCell extends StatelessWidget {
  final bool dirty;
  final double width;
  final VoidCallback onSave;
  final VoidCallback onRollback;

  const _SaveCell({
    required this.dirty,
    required this.width,
    required this.onSave,
    required this.onRollback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: _kRowHeight,
      alignment: Alignment.center,
      decoration:
          const BoxDecoration(border: Border(right: _kBorderSide)),
      child: dirty
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 26,
                  child: FilledButton.tonal(
                    onPressed: onSave,
                    style: FilledButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8),
                      backgroundColor: Colors.green[50],
                      foregroundColor: Colors.green[800],
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('保存'),
                  ),
                ),
                const SizedBox(width: 3),
                Tooltip(
                  message: '撤销修改',
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.undo,
                          size: 14, color: Colors.orange[600]),
                      onPressed: onRollback,
                    ),
                  ),
                ),
              ],
            )
          : Text('—',
              style: TextStyle(color: Colors.grey[300], fontSize: 13)),
    );
  }
}

// ── 工具函数 ──────────────────────────────────────────────────────────────────

String _scopeLabel(String scope) => switch (scope) {
      'natal' => '命盘',
      'xingxian' => '行限',
      _ => '通用',
    };

// ══════════════════════════════════════════════════════════════════════════════
// 算法（conditions）可视化 — 辅助函数
// ══════════════════════════════════════════════════════════════════════════════

const _kStarLabels = <String, String>{
  'Sun': '日', 'Moon': '月',
  'Mercury': '水', 'Venus': '金', 'Mars': '火',
  'Jupiter': '木', 'Saturn': '土',
  'Luo': '罗', 'Ji': '计', 'Qi': '气', 'Bei': '孛',
  'NorthNode': '罗', 'SouthNode': '计',
};

const _kGongLabels = <String, String>{
  'Zi': '子', 'Chou': '丑', 'Yin': '寅', 'Mao': '卯',
  'Chen': '辰', 'Si': '巳', 'Wu': '午', 'Wei': '未',
  'Shen': '申', 'You': '酉', 'Xu': '戌', 'Hai': '亥',
};

String _starLabel(String s) => _kStarLabels[s] ?? s;
String _gongLabel(String g) => _kGongLabels[g] ?? g;
String _joinStarList(List<dynamic> l) =>
    l.map((s) => _starLabel(s.toString())).join('');
String _joinGongList(List<dynamic> l) =>
    l.map((g) => _gongLabel(g.toString())).join('/');

// ── 枚举英文名 → 中文 ─────────────────────────────────────────────────────────

/// 星曜庙旺状态（EnumStarGongPositionStatusType）
const _kStatusLabels = <String, String>{
  'Miao': '庙', 'Wang': '旺', 'Xi': '喜', 'Le': '乐',
  'Nu': '怒', 'Xian': '陷', 'Zheng': '正垣', 'Pian': '偏垣',
  'Yuan': '垣', 'Dian': '殿', 'Xiong': '凶', 'Gui': '贵',
};

/// 行星运行状态（FiveStarWalkingType）
const _kWalkingLabels = <String, String>{
  'Fast': '速', 'Normal': '常', 'Slow': '迟',
  'Stay': '留', 'Retrograde': '逆',
};

/// 月相（EnumMoonPhases）
const _kMoonPhaseLabels = <String, String>{
  'New': '新月', 'E_Mei': '峨眉', 'Shang_Xian': '上弦', 'Ying_Tu': '盈凸',
  'Full': '满月', 'Kui_Tu': '亏凸', 'Xia_Xian': '下弦', 'Can_Yue': '残月',
};

/// 四季（FourSeasons）
const _kSeasonLabels = <String, String>{
  'Spring': '春', 'Summer': '夏', 'Autumn': '秋', 'Winter': '冬',
  'SPRING': '春', 'SUMMER': '夏', 'AUTUMN': '秋', 'WINTER': '冬',
};

/// 命盘十二宫（EnumDestinyTwelveGong）
const _kDestinyGongLabels = <String, String>{
  'Ming': '命宫', 'CaiBo': '财帛', 'XiongDi': '兄弟', 'TianZhai': '田宅',
  'NanNv': '男女', 'NuPu': '奴仆', 'FuQi': '夫妻',  'JiE': '疾厄',
  'QianYi': '迁移', 'GuanLu': '官禄', 'FuDe': '福德', 'XiangMao': '相貌',
};

String _statusLabel(String s) => _kStatusLabels[s] ?? s;
String _walkLabel(String s)   => _kWalkingLabels[s] ?? s;
String _moonLabel(String s)   => _kMoonPhaseLabels[s] ?? s;
String _seasonLabel(String s) => _kSeasonLabels[s] ?? s;
String _destGongLabel(String s) => _kDestinyGongLabels[s] ?? s;


String _leafLabel(Map<String, dynamic> c) {
  final type = c['type'] as String? ?? '';
  try {
    switch (type) {
      case 'starInGong':
        return '${_starLabel(c['star'])}入${_joinGongList(c['gongs'] as List)}宫';
      case 'starInConstellation':
        return '${_starLabel(c['star'])}躔${(c['constellations'] as List).join('/')}宿';
      case 'starWalkingState':
        return '${_starLabel(c['star'])}行'
            '${(c['states'] as List).map((e) => _walkLabel(e.toString())).join('/')}';
      case 'starInKongWang':
        return '${_starLabel(c['star'])}落空亡';
      case 'sameGong':
        return '${_joinStarList(c['stars'] as List)}同宫';
      case 'sameConstellation':
        return '${_joinStarList(c['stars'] as List)}同宿';
      case 'oppositeGong':
        return '${_joinStarList(c['stars'] as List)}对照';
      case 'trineGong':
        return '${_joinStarList(c['stars'] as List)}三合';
      case 'squareGong':
        return '${_joinStarList(c['stars'] as List)}四正';
      case 'sameJing':
        return '${_joinStarList(c['stars'] as List)}同经';
      case 'sameLuo':
        return '${_joinStarList(c['stars'] as List)}同络';
      case 'lifeGongAt':
        return '命宫在${_joinGongList(c['gongs'] as List)}';
      case 'lifeConstellationAt':
        return '命度躔${(c['constellations'] as List).join('/')}';
      case 'starGuardLife':
        return '${_starLabel(c['star'])}临命';
      case 'starInDestinyGong':
        return '${_starLabel(c['star'])}在'
            '${_destGongLabel(c['destinyGong'] as String? ?? '')}';
      case 'starIsSiZhu':
        return '${_starLabel(c['star'])}为四柱星';
      case 'starFourType':
        return '${_starLabel(c['star'])}四类型';
      case 'starHasHuaYao':
        return '${_starLabel(c['star'])}有化曜';
      case 'seasonIs':
        return '生于${(c['seasons'] as List).map((e) => _seasonLabel(e.toString())).join('/')}季';
      case 'isDayBirth':
        return (c['isDay'] as bool? ?? true) ? '昼生' : '夜生';
      case 'moonPhaseIs':
        return '月相：${(c['phases'] as List).map((e) => _moonLabel(e.toString())).join('/')}';
      case 'monthIs':
        return '生于${_joinGongList(c['months'] as List)}月';
      case 'starGongStatus':
        return '${_starLabel(c['star'])}'
            '${(c['statuses'] as List).map((e) => _statusLabel(e.toString())).join('/')}';
      case 'starWithShenSha':
        return '${_starLabel(c['star'])}与神煞共处';
      case 'gongHasShenSha':
        return '宫位含神煞';
      case 'xianAtGong':
        return '限至${_joinGongList((c['gongs'] as List? ?? []))}宫';
      case 'xianAtConstellation':
        return '限躔星宿';
      case 'xianMeetStar':
        return '限遇${_starLabel((c['star'] as String?) ?? '')}';
      case 'gongZhao':
        return '${_starLabel(c['starA'] as String? ?? '')}拱照${_starLabel(c['starB'] as String? ?? '')}';
      case 'jiaGong':
        return '${_starLabel(c['starA'] as String? ?? '')}${_starLabel(c['starB'] as String? ?? '')}'
            '夹${_gongLabel(c['targetGong'] as String? ?? '')}宫';
      case 'sixHarmony':
        return '${_starLabel(c['starA'] as String? ?? '')}${_starLabel(c['starB'] as String? ?? '')}六合';
      case 'starInFourZheng':
        return '${_starLabel(c['star'] as String? ?? '')}入四正宫';
      default:
        return type;
    }
  } catch (_) {
    return type;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _ConditionInlineCell — 算法列内联可视化单元格
// 视图模式：RichText 内联展示条件逻辑（且/或/非 + 叶子短语）
// 编辑模式：双击进入 JSON 文本编辑（Esc/失焦提交）
// ══════════════════════════════════════════════════════════════════════════════

class _ConditionInlineCell extends StatefulWidget {
  final String jsonText;
  final double width;
  final void Function(String) onSave;

  const _ConditionInlineCell({
    required this.jsonText,
    required this.width,
    required this.onSave,
  });

  @override
  State<_ConditionInlineCell> createState() => _ConditionInlineCellState();
}

class _ConditionInlineCellState extends State<_ConditionInlineCell> {
  // ── 语义色常量：各元素类型在 Chip 内的文字色 ──────────────────────────
  static const _cStar   = Color(0xFFB71C1C); // 星体：深红
  static const _cGong   = Color(0xFF00796B); // 地支宫：青色
  static const _cDest   = Color(0xFF1565C0); // 命理宫：深蓝
  static const _cConst  = Color(0xFF2E7D32); // 星宿：深绿
  static const _cStatus = Color(0xFF6D4C00); // 庙旺喜忌：深金
  static const _cLabel  = Color(0xFF546E7A); // 介词/连接词：灰蓝
  static const _cOrSep  = Color(0xFFE65100); // 多值 OR 分隔：橙色

  void _openEditor(BuildContext ctx) {
    showDialog<void>(
      context: ctx,
      builder: (_) => _JsonEditDialog(
        initialText: widget.jsonText,
        onSave: (v) {
          if (v.trim() != widget.jsonText) widget.onSave(v.trim());
        },
      ),
    );
  }

  Map<String, dynamic>? _tryParse(String text) {
    if (text.trim().isEmpty) return null;
    try {
      return jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ── 每类条件的 Chip 配色 ───────────────────────────────────────────
  static ({Color bg, Color border, Color text}) _chipStyle(String type) =>
      switch (type) {
        // 位置类：蓝色系（星在哪宫/宿）
        'starInGong' || 'starInConstellation' || 'starInDestinyGong' || 'starInFourZheng' => (
            bg: const Color(0xFFE3F2FD),
            border: const Color(0xFF1976D2),
            text: const Color(0xFF0D47A1),
          ),
        // 关系类：紫色系（同宫/对照/三合/四正/同经/同络/夹宫/六合）
        'sameGong' ||
        'sameConstellation' ||
        'oppositeGong' ||
        'trineGong' ||
        'squareGong' ||
        'sameJing' ||
        'sameLuo' ||
        'jiaGong' ||
        'sixHarmony' =>
          (
            bg: const Color(0xFFF3E5F5),
            border: const Color(0xFF7B1FA2),
            text: const Color(0xFF4A148C),
          ),
        // 命宫结构类：橙色系（临命/命宫在/拱照）
        'starGuardLife' || 'lifeGongAt' || 'lifeConstellationAt' || 'gongZhao' => (
            bg: const Color(0xFFFFF3E0),
            border: const Color(0xFFF57C00),
            text: const Color(0xFFE65100),
          ),
        // 星曜状态类：金黄系（庙旺/运行/空亡）
        'starGongStatus' ||
        'starWalkingState' ||
        'starInKongWang' ||
        'starIsSiZhu' ||
        'starFourType' ||
        'starHasHuaYao' =>
          (
            bg: const Color(0xFFFFF9C4),
            border: const Color(0xFFF9A825),
            text: const Color(0xFF6D4C00),
          ),
        // 时间类：绿色系（季节/昼夜/月相/月份）
        'seasonIs' || 'isDayBirth' || 'moonPhaseIs' || 'monthIs' => (
            bg: const Color(0xFFE8F5E9),
            border: const Color(0xFF388E3C),
            text: const Color(0xFF1B5E20),
          ),
        // 神煞/行限类：玫红系
        'starWithShenSha' ||
        'gongHasShenSha' ||
        'xianAtGong' ||
        'xianAtConstellation' ||
        'xianMeetStar' =>
          (
            bg: const Color(0xFFFCE4EC),
            border: const Color(0xFFC2185B),
            text: const Color(0xFF880E4F),
          ),
        _ => (
            bg: const Color(0xFFF5F5F5),
            border: const Color(0xFF9E9E9E),
            text: const Color(0xFF424242),
          ),
      };

  // ── 叶子 Chip ──────────────────────────────────────────────────────
  Widget _leafChip(Map<String, dynamic> c) {
    final style = _chipStyle(c['type'] as String? ?? '');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: style.border, width: 1.0),
      ),
      child: _richLeafWidget(c),
    );
  }

  // ── 条件内容富文本（星/宫/宿/状态 分色显示）─────────────────────────
  Widget _richLeafWidget(Map<String, dynamic> c) {
    final type = c['type'] as String? ?? '';

    // 局部 TextSpan 构建辅助
    TextSpan ts(String t, Color col, {bool bold = false}) => TextSpan(
          text: t,
          style: TextStyle(
              color: col,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal));
    TextSpan star(String n) => ts(_starLabel(n), _cStar, bold: true);
    TextSpan gong(String n) => ts(_gongLabel(n), _cGong, bold: true);
    TextSpan destG(String n) => ts(_destGongLabel(n), _cDest, bold: true);
    TextSpan constN(String n) => ts(n, _cConst, bold: true);
    TextSpan statusN(String n) => ts(_statusLabel(n), _cStatus, bold: true);
    TextSpan lbl(String t) => ts(t, _cLabel);
    TextSpan orSep() => ts(' | ', _cOrSep);

    List<InlineSpan> spans;
    try {
      switch (type) {
        case 'starInGong':
          final s = c['star'] as String? ?? '';
          final gongs = (c['gongs'] as List? ?? []).cast<String>();
          spans = [star(s), lbl('入')];
          for (int i = 0; i < gongs.length; i++) {
            if (i > 0) spans.add(orSep());
            spans.add(gong(gongs[i]));
          }
          spans.add(lbl('宫'));
        case 'starInConstellation':
          final s = c['star'] as String? ?? '';
          final consts = (c['constellations'] as List? ?? []).cast<String>();
          spans = [star(s), lbl('躔')];
          for (int i = 0; i < consts.length; i++) {
            if (i > 0) spans.add(orSep());
            spans.add(constN(consts[i]));
          }
          spans.add(lbl('宿'));
        case 'starWalkingState':
          final s = c['star'] as String? ?? '';
          final states = (c['states'] as List? ?? []).cast<String>();
          spans = [star(s), lbl('行')];
          for (int i = 0; i < states.length; i++) {
            if (i > 0) spans.add(orSep());
            spans.add(ts(_walkLabel(states[i]), _cStatus, bold: true));
          }
        case 'starInKongWang':
          spans = [star(c['star'] as String? ?? ''), lbl('落空亡')];
        case 'sameGong':
          final stars = (c['stars'] as List? ?? []).cast<String>();
          spans = [...stars.map(star), lbl('同宫')];
        case 'sameConstellation':
          final stars = (c['stars'] as List? ?? []).cast<String>();
          spans = [...stars.map(star), lbl('同宿')];
        case 'oppositeGong':
          final stars = (c['stars'] as List? ?? []).cast<String>();
          spans = [...stars.map(star), lbl('对照')];
        case 'trineGong':
          final stars = (c['stars'] as List? ?? []).cast<String>();
          spans = [...stars.map(star), lbl('三合')];
        case 'squareGong':
          final stars = (c['stars'] as List? ?? []).cast<String>();
          spans = [...stars.map(star), lbl('四正')];
        case 'sameJing':
          final stars = (c['stars'] as List? ?? []).cast<String>();
          spans = [...stars.map(star), lbl('同经')];
        case 'sameLuo':
          final stars = (c['stars'] as List? ?? []).cast<String>();
          spans = [...stars.map(star), lbl('同络')];
        case 'lifeGongAt':
          final gongs = (c['gongs'] as List? ?? []).cast<String>();
          spans = [lbl('命宫在')];
          for (int i = 0; i < gongs.length; i++) {
            if (i > 0) spans.add(orSep());
            spans.add(gong(gongs[i]));
          }
        case 'lifeConstellationAt':
          final consts = (c['constellations'] as List? ?? []).cast<String>();
          spans = [lbl('命度躔')];
          for (int i = 0; i < consts.length; i++) {
            if (i > 0) spans.add(orSep());
            spans.add(constN(consts[i]));
          }
        case 'starGuardLife':
          spans = [star(c['star'] as String? ?? ''), lbl('临命')];
        case 'starInDestinyGong':
          spans = [
            star(c['star'] as String? ?? ''),
            lbl('在'),
            destG(c['destinyGong'] as String? ?? ''),
          ];
        case 'starIsSiZhu':
          spans = [star(c['star'] as String? ?? ''), lbl('为四柱星')];
        case 'starFourType':
          spans = [star(c['star'] as String? ?? ''), lbl('四类型')];
        case 'starHasHuaYao':
          spans = [star(c['star'] as String? ?? ''), lbl('有化曜')];
        case 'seasonIs':
          final seasons = (c['seasons'] as List? ?? []).cast<String>();
          spans = [lbl('生于')];
          for (int i = 0; i < seasons.length; i++) {
            if (i > 0) spans.add(orSep());
            spans.add(ts(_seasonLabel(seasons[i]), _cConst, bold: true));
          }
          spans.add(lbl('季'));
        case 'isDayBirth':
          spans = [lbl((c['isDay'] as bool? ?? true) ? '昼生' : '夜生')];
        case 'moonPhaseIs':
          final phases = (c['phases'] as List? ?? []).cast<String>();
          spans = [lbl('月相：')];
          for (int i = 0; i < phases.length; i++) {
            if (i > 0) spans.add(orSep());
            spans.add(ts(_moonLabel(phases[i]), _cConst, bold: true));
          }
        case 'monthIs':
          final months = (c['months'] as List? ?? []).cast<String>();
          spans = [lbl('生于')];
          for (int i = 0; i < months.length; i++) {
            if (i > 0) spans.add(orSep());
            spans.add(gong(months[i]));
          }
          spans.add(lbl('月'));
        case 'starGongStatus':
          final s = c['star'] as String? ?? '';
          final statuses = (c['statuses'] as List? ?? []).cast<String>();
          spans = [star(s)];
          for (int i = 0; i < statuses.length; i++) {
            if (i > 0) spans.add(orSep());
            spans.add(statusN(statuses[i]));
          }
        case 'starWithShenSha':
          spans = [star(c['star'] as String? ?? ''), lbl('与神煞共处')];
        case 'gongHasShenSha':
          spans = [lbl('宫位含神煞')];
        case 'xianAtGong':
          final gongs = (c['gongs'] as List? ?? []).cast<String>();
          spans = [lbl('限至')];
          for (int i = 0; i < gongs.length; i++) {
            if (i > 0) spans.add(orSep());
            spans.add(gong(gongs[i]));
          }
          spans.add(lbl('宫'));
        case 'xianAtConstellation':
          spans = [lbl('限躔星宿')];
        case 'xianMeetStar':
          spans = [lbl('限遇'), star(c['star'] as String? ?? '')];
        case 'gongZhao':
          spans = [
            star(c['starA'] as String? ?? ''),
            lbl('拱照'),
            star(c['starB'] as String? ?? ''),
          ];
        case 'jiaGong':
          spans = [
            star(c['starA'] as String? ?? ''),
            star(c['starB'] as String? ?? ''),
            lbl('夹'),
            gong(c['targetGong'] as String? ?? ''),
            lbl('宫'),
          ];
        case 'sixHarmony':
          spans = [
            star(c['starA'] as String? ?? ''),
            star(c['starB'] as String? ?? ''),
            lbl('六合'),
          ];
        case 'starInFourZheng':
          spans = [star(c['star'] as String? ?? ''), lbl('入四正宫')];
        default:
          spans = [lbl(type)];
      }
    } catch (_) {
      spans = [lbl(type)];
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12, height: 1.2),
        children: spans,
      ),
      maxLines: 1,
      overflow: TextOverflow.fade,
    );
  }

  // ── 逻辑运算符徽章（NOT）─────────────────────────────────────────────
  Widget _logicBadge(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Text(text,
          style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
              height: 1.2)),
    );
  }

  // ── 连接符 AND（黑色）/ OR（橙色）────────────────────────────────
  Widget _connector(String text, Color color) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text(text,
            style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3)),
      );

  // ── 嵌套逻辑组（左侧竖线 + 零垂直 padding，不占行高）────────────
  Widget _nestedWidget(Map<String, dynamic> cond) {
    final t = cond['type'] as String? ?? '';
    final color = t == 'and'
        ? const Color(0xFF1565C0)
        : t == 'or'
            ? const Color(0xFFE65100)
            : const Color(0xFFC62828);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.only(left: 5, right: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        border: Border(left: BorderSide(color: color, width: 2.5)),
      ),
      child: _buildChipRow(cond),
    );
  }

  // ── 主 Chip Row 构建 ──────────────────────────────────────────────
  Widget _buildChipRow(Map<String, dynamic> cond) {
    final type = cond['type'] as String? ?? '';

    if (type == 'and' || type == 'or') {
      final isAnd = type == 'and';
      final color =
          isAnd ? const Color(0xFF1565C0) : const Color(0xFFE65100);
      final connText = isAnd ? 'AND' : 'OR';
      final children = (cond['conditions'] as List? ?? [])
          .cast<Map<String, dynamic>>();

      final items = <Widget>[];
      for (int i = 0; i < children.length; i++) {
        if (i > 0) items.add(_connector(connText, color));
        final child = children[i];
        final ct = child['type'] as String? ?? '';
        items.add((ct == 'and' || ct == 'or' || ct == 'not')
            ? _nestedWidget(child)
            : _leafChip(child));
      }
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: items,
      );
    }

    if (type == 'not') {
      const color = Color(0xFFC62828);
      final inner = cond['condition'] as Map<String, dynamic>?;
      if (inner == null) {
        return _logicBadge('NOT', color);
      }
      final innerType = inner['type'] as String? ?? '';
      final innerWidget =
          (innerType == 'and' || innerType == 'or' || innerType == 'not')
              ? _nestedWidget(inner)
              : _leafChip(inner);
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [_logicBadge('NOT', color), innerWidget],
      );
    }

    return _leafChip(cond);
  }

  // ── Build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cond = _tryParse(widget.jsonText);
    final isEmpty = widget.jsonText.trim().isEmpty;

    Widget content;
    if (isEmpty) {
      content = const SizedBox.shrink();
    } else if (cond == null) {
      content = Text('⚠ JSON错误',
          style: TextStyle(color: Colors.red[400], fontSize: 11));
    } else {
      content = ClipRect(
        child: Align(
          alignment: Alignment.centerLeft,
          heightFactor: 1.0,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: _buildChipRow(cond),
          ),
        ),
      );
    }

    return GestureDetector(
      onDoubleTap: () => _openEditor(context),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: widget.width,
          height: _kRowHeight,
          alignment: Alignment.centerLeft,
          padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration:
              const BoxDecoration(border: Border(right: _kBorderSide)),
          child: content,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// JSON 编辑弹窗
// ══════════════════════════════════════════════════════════════════════════════

class _JsonEditDialog extends StatefulWidget {
  final String initialText;
  final void Function(String) onSave;

  const _JsonEditDialog({required this.initialText, required this.onSave});

  @override
  State<_JsonEditDialog> createState() => _JsonEditDialogState();
}

class _JsonEditDialogState extends State<_JsonEditDialog> {
  late final TextEditingController _ctrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _prettyJson(widget.initialText));
  }

  String _prettyJson(String raw) {
    try {
      return const JsonEncoder.withIndent('  ').convert(jsonDecode(raw));
    } catch (_) {
      return raw;
    }
  }

  void _format() {
    try {
      final pretty = _prettyJson(_ctrl.text);
      setState(() {
        _ctrl.text = pretty;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  void _save() {
    try {
      jsonDecode(_ctrl.text); // validate
      widget.onSave(_ctrl.text.trim());
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.data_object, size: 18, color: Color(0xFF1565C0)),
          SizedBox(width: 8),
          Text('编辑条件 JSON',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      content: SizedBox(
        width: 580,
        child: TextField(
          controller: _ctrl,
          maxLines: 16,
          minLines: 6,
          style: const TextStyle(
              fontSize: 12, fontFamily: 'monospace', height: 1.5),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            errorText: _error,
            errorMaxLines: 3,
            isDense: true,
            contentPadding: const EdgeInsets.all(10),
          ),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: _format,
          icon: const Icon(Icons.auto_fix_high, size: 14),
          label: const Text('格式化'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save, size: 14),
          label: const Text('保存'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}



class _ConditionTreeNode extends StatelessWidget {
  final Map<String, dynamic> cond;
  final int depth;

  const _ConditionTreeNode({required this.cond, required this.depth});

  @override
  Widget build(BuildContext context) {
    final type = cond['type'] as String? ?? '';

    // ── AND / OR ────────────────────────────────────────────────────
    if (type == 'and' || type == 'or') {
      final children = (cond['conditions'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      final isAnd = type == 'and';
      final color =
          isAnd ? const Color(0xFF1565C0) : const Color(0xFFE65100);
      final label = isAnd ? '全部满足' : '任意满足';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CondLogicHeader(
              label: label, color: color, count: children.length),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: color.withValues(alpha: 0.3),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < children.length; i++) ...[
                          if (i > 0) const SizedBox(height: 4),
                          _ConditionTreeNode(
                              cond: children[i], depth: depth + 1),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // ── NOT ─────────────────────────────────────────────────────────
    if (type == 'not') {
      final inner = cond['condition'] as Map<String, dynamic>?;
      const color = Color(0xFFC62828);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CondLogicHeader(label: '不满足（非）', color: color),
          if (inner != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: _ConditionTreeNode(cond: inner, depth: depth + 1),
            ),
        ],
      );
    }

    // ── Leaf ─────────────────────────────────────────────────────────
    return _CondLeafNode(label: _leafLabel(cond));
  }
}

class _CondLogicHeader extends StatelessWidget {
  final String label;
  final Color color;
  final int? count;

  const _CondLogicHeader(
      {required this.label, required this.color, this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border:
            Border.all(color: color.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color)),
          if (count != null) ...[
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count',
                  style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}

class _CondLeafNode extends StatelessWidget {
  final String label;

  const _CondLeafNode({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFDDDDDD), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.fiber_manual_record,
              size: 5, color: Color(0xFF888888)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF333333))),
          ),
        ],
      ),
    );
  }
}
