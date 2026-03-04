/// Pattern管理页面

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:companion_system/database/drift_database.dart';
import 'package:companion_system/pages/dialogs/pattern_dialog.dart'
    show PatternFormPage;

class PatternManagementPage extends StatefulWidget {
  const PatternManagementPage({super.key});

  @override
  State<PatternManagementPage> createState() => _PatternManagementPageState();
}

class _PatternManagementPageState extends State<PatternManagementPage> {
  late AppDatabase _db;
  final _searchController = TextEditingController();
  List<Pattern> _patterns = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _db = context.read<AppDatabase>();
    _loadPatterns();
  }

  Future<void> _loadPatterns() async {
    setState(() => _isLoading = true);
    try {
      final patterns = await _db.select(_db.geJuPatterns).get();
      setState(() {
        _patterns = patterns;
        _isLoading = false;
      });
    } catch (e) {
      print('加载格局失败: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePattern(String patternId) async {
    try {
      await (_db.delete(_db.geJuPatterns)
            ..where((p) => p.id.equals(patternId)))
          .go();
      await _loadPatterns();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除成功')),
        );
      }
    } catch (e) {
      print('删除失败: $e');
    }
  }

  void _showDeleteDialog(String patternId, String patternName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除格局 "$patternName" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              _deletePattern(patternId);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pattern管理'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatterns,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '搜索格局名称...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                Expanded(
                  child: _patterns.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.category_outlined,
                                  size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text('暂无格局数据',
                                  style: Theme.of(context).textTheme.titleMedium),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _patterns.length,
                          itemBuilder: (context, index) {
                            final pattern = _patterns[index];
                            final keyword = _searchController.text;
                            if (keyword.isNotEmpty &&
                                !pattern.name.contains(keyword)) {
                              return const SizedBox.shrink();
                            }

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: ListTile(
                                leading: Icon(Icons.category,
                                    color: Theme.of(context).primaryColor),
                                title: Text(pattern.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                        '拼音: ${pattern.pinyin ?? "未设置"}',
                                        style: const TextStyle(fontSize: 12)),
                                    Text(
                                        '描述: ${pattern.description ?? "无"}',
                                        style: const TextStyle(fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                                trailing: SizedBox(
                                  width: 100,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            size: 20, color: Colors.blue),
                                        onPressed: () async {
                                          final saved =
                                              await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => PatternFormPage(
                                                  db: _db, pattern: pattern),
                                            ),
                                          );
                                          if (saved == true) _loadPatterns();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            size: 20, color: Colors.red),
                                        onPressed: () =>
                                            _showDeleteDialog(pattern.id, pattern.name),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final saved = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => PatternFormPage(db: _db),
            ),
          );
          if (saved == true) _loadPatterns();
        },
        tooltip: '新建格局',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
