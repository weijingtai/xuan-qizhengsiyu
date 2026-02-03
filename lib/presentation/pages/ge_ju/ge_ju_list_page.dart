import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju_model.dart';
import 'package:qizhengsiyu/presentation/viewmodels/ge_ju_list_viewmodel.dart';
import 'package:qizhengsiyu/presentation/widgets/ge_ju/ge_ju_list_tile.dart';

/// 格局列表页面
class GeJuListPage extends StatefulWidget {
  const GeJuListPage({super.key});

  @override
  State<GeJuListPage> createState() => _GeJuListPageState();
}

class _GeJuListPageState extends State<GeJuListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GeJuListViewModel>().loadRules();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('格局管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '新建格局',
            onPressed: () => _navigateToEditor(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterBar(),
          Expanded(child: _buildRulesList()),
          _buildStatsBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Consumer<GeJuListViewModel>(
      builder: (context, viewModel, _) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索格局名称、描述...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: viewModel.searchKeyword.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        viewModel.search('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: viewModel.search,
          ),
        );
      },
    );
  }

  Widget _buildFilterBar() {
    return Consumer<GeJuListViewModel>(
      builder: (context, viewModel, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              // 分类筛选
              _buildDropdownFilter<String?>(
                label: '分类',
                value: viewModel.selectedCategory,
                items: [
                  const DropdownMenuItem(value: null, child: Text('全部')),
                  ...viewModel.categories.map((c) =>
                      DropdownMenuItem(value: c, child: Text(c))),
                ],
                onChanged: viewModel.filterByCategory,
              ),
              const SizedBox(width: 8),
              // 吉凶筛选
              _buildDropdownFilter<JiXiongEnum?>(
                label: '吉凶',
                value: viewModel.selectedJiXiong,
                items: const [
                  DropdownMenuItem(value: null, child: Text('全部')),
                  DropdownMenuItem(value: JiXiongEnum.JI, child: Text('吉')),
                  DropdownMenuItem(value: JiXiongEnum.XIONG, child: Text('凶')),
                  DropdownMenuItem(value: JiXiongEnum.PING, child: Text('平')),
                ],
                onChanged: viewModel.filterByJiXiong,
              ),
              const SizedBox(width: 8),
              // 类型筛选
              _buildDropdownFilter<GeJuType?>(
                label: '类型',
                value: viewModel.selectedType,
                items: [
                  const DropdownMenuItem(value: null, child: Text('全部')),
                  ...GeJuType.values.map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(_getGeJuTypeLabel(t)),
                      )),
                ],
                onChanged: viewModel.filterByType,
              ),
              const SizedBox(width: 8),
              // 范围筛选
              _buildDropdownFilter<GeJuScope?>(
                label: '范围',
                value: viewModel.selectedScope,
                items: const [
                  DropdownMenuItem(value: null, child: Text('全部')),
                  DropdownMenuItem(value: GeJuScope.natal, child: Text('命盘')),
                  DropdownMenuItem(value: GeJuScope.xingxian, child: Text('行限')),
                  DropdownMenuItem(value: GeJuScope.both, child: Text('通用')),
                ],
                onChanged: viewModel.filterByScope,
              ),
              const SizedBox(width: 8),
              // 来源筛选
              _buildDropdownFilter<bool?>(
                label: '来源',
                value: viewModel.sourceFilter,
                items: const [
                  DropdownMenuItem(value: null, child: Text('全部')),
                  DropdownMenuItem(value: true, child: Text('内置')),
                  DropdownMenuItem(value: false, child: Text('自定义')),
                ],
                onChanged: viewModel.filterBySource,
              ),
              if (viewModel.hasActiveFilters) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('清除'),
                  onPressed: viewModel.clearFilters,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDropdownFilter<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          hint: Text(label),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildRulesList() {
    return Consumer<GeJuListViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  viewModel.errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: viewModel.loadRules,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        if (viewModel.rules.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  viewModel.hasActiveFilters ? '没有匹配的格局' : '暂无格局数据',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: viewModel.refreshRules,
          child: ListView.separated(
            itemCount: viewModel.rules.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final rule = viewModel.rules[index];
              final isBuiltIn = viewModel.isBuiltIn(rule.id);
              return GeJuListTile(
                rule: rule,
                isBuiltIn: isBuiltIn,
                onTap: () => _navigateToDetail(context, rule),
                onDelete: isBuiltIn
                    ? null
                    : () => _confirmDelete(context, viewModel, rule),
                onDuplicate: () => _duplicateRule(context, rule),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatsBar() {
    return Consumer<GeJuListViewModel>(
      builder: (context, viewModel, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '显示 ${viewModel.rules.length} 条',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                '总计 ${viewModel.totalCount} | 内置 ${viewModel.builtInCount} | 自定义 ${viewModel.userCount}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToEditor(BuildContext context, {String? ruleId}) {
    Navigator.pushNamed(
      context,
      ruleId == null ? '/qizhengsiyu/ge_ju/create' : '/qizhengsiyu/ge_ju/edit',
      arguments: ruleId,
    ).then((_) {
      // 返回时刷新列表
      context.read<GeJuListViewModel>().refreshRules();
    });
  }

  void _navigateToDetail(BuildContext context, GeJuRule rule) {
    final viewModel = context.read<GeJuListViewModel>();
    Navigator.pushNamed(
      context,
      '/qizhengsiyu/ge_ju/detail',
      arguments: {
        'rule': rule,
        'isBuiltIn': viewModel.isBuiltIn(rule.id),
      },
    ).then((_) {
      // 返回时刷新列表
      context.read<GeJuListViewModel>().refreshRules();
    });
  }

  Future<void> _confirmDelete(
    BuildContext context,
    GeJuListViewModel viewModel,
    GeJuRule rule,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除格局 "${rule.name}" 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await viewModel.deleteRule(rule.id);
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage ?? '删除失败')),
        );
      }
    }
  }

  void _duplicateRule(BuildContext context, GeJuRule rule) {
    Navigator.pushNamed(
      context,
      '/qizhengsiyu/ge_ju/create',
      arguments: {'duplicate': rule.id},
    ).then((_) {
      context.read<GeJuListViewModel>().refreshRules();
    });
  }

  String _getGeJuTypeLabel(GeJuType type) {
    switch (type) {
      case GeJuType.pin:
        return '贫';
      case GeJuType.jian:
        return '贱';
      case GeJuType.fu:
        return '富';
      case GeJuType.gui:
        return '贵';
      case GeJuType.yao:
        return '夭';
      case GeJuType.shou:
        return '寿';
      case GeJuType.xian:
        return '贤';
      case GeJuType.yu:
        return '愚';
    }
  }
}
