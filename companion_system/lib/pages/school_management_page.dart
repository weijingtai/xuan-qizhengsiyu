/// School管理页面

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:companion_system/database/drift_database.dart';
import 'package:companion_system/pages/dialogs/school_dialog.dart'
    show SchoolFormPage;

class SchoolManagementPage extends StatefulWidget {
  const SchoolManagementPage({super.key});

  @override
  State<SchoolManagementPage> createState() => _SchoolManagementPageState();
}

class _SchoolManagementPageState extends State<SchoolManagementPage> {
  late AppDatabase _db;
  final _searchController = TextEditingController();
  List<School> _schools = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _db = context.read<AppDatabase>();
    _loadSchools();
  }

  Future<void> _loadSchools() async {
    setState(() => _isLoading = true);
    try {
      final schools = await _db.select(_db.geJuSchools).get();
      setState(() {
        _schools = schools;
        _isLoading = false;
      });
    } catch (e) {
      print('加载流派失败: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSchool(String schoolId) async {
    try {
      await (_db.delete(_db.geJuSchools)
            ..where((s) => s.id.equals(schoolId)))
          .go();
      await _loadSchools();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除成功')),
        );
      }
    } catch (e) {
      print('删除失败: $e');
    }
  }

  void _showDeleteDialog(String schoolId, String schoolName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除流派 "$schoolName" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              _deleteSchool(schoolId);
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
        title: const Text('School管理'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSchools,
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
                      hintText: '搜索流派名称...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                Expanded(
                  child: _schools.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.school_outlined,
                                  size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text('暂无流派数据',
                                  style: Theme.of(context).textTheme.titleMedium),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _schools.length,
                          itemBuilder: (context, index) {
                            final school = _schools[index];
                            final keyword = _searchController.text;
                            if (keyword.isNotEmpty &&
                                !school.name.contains(keyword)) {
                              return const SizedBox.shrink();
                            }

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: ListTile(
                                leading: Icon(Icons.school,
                                    color: Theme.of(context).primaryColor),
                                title: Text(school.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('类型: ${school.type}',
                                        style: const TextStyle(fontSize: 12)),
                                    Text(
                                        '时代: ${school.era ?? "未设置"}',
                                        style: const TextStyle(fontSize: 12)),
                                    Text(
                                        '创始人: ${school.founder ?? "未设置"}',
                                        style: const TextStyle(fontSize: 12)),
                                    Text(
                                        '规则数: ${school.ruleCount}',
                                        style: const TextStyle(fontSize: 12)),
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
                                              builder: (_) => SchoolFormPage(
                                                  db: _db, school: school),
                                            ),
                                          );
                                          if (saved == true) _loadSchools();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            size: 20, color: Colors.red),
                                        onPressed: () =>
                                            _showDeleteDialog(school.id, school.name),
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
              builder: (_) => SchoolFormPage(db: _db),
            ),
          );
          if (saved == true) _loadSchools();
        },
        tooltip: '新建流派',
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
