import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_school.dart';
import 'package:qizhengsiyu/presentation/viewmodels/ge_ju_school_list_viewmodel.dart';

/// 流派列表页面
class GeJuSchoolListPage extends StatefulWidget {
  const GeJuSchoolListPage({super.key});

  @override
  State<GeJuSchoolListPage> createState() => _GeJuSchoolListPageState();
}

class _GeJuSchoolListPageState extends State<GeJuSchoolListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GeJuSchoolListViewModel>().loadSchools();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('流派管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '新建流派',
            onPressed: () => _navigateToEditor(context),
          ),
        ],
      ),
      body: Consumer<GeJuSchoolListViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.errorMessage!,
                      style: TextStyle(color: Colors.red.shade700)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.loadSchools,
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.schools.isEmpty) {
            return const Center(child: Text('暂无流派'));
          }

          return ListView.separated(
            itemCount: viewModel.schools.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final school = viewModel.schools[index];
              return _buildSchoolTile(context, viewModel, school);
            },
          );
        },
      ),
    );
  }

  Widget _buildSchoolTile(
    BuildContext context,
    GeJuSchoolListViewModel viewModel,
    GeJuSchool school,
  ) {
    final isBuiltIn = viewModel.isBuiltIn(school.id);
    return ListTile(
      leading: Icon(
        isBuiltIn ? Icons.lock_outline : Icons.person_outline,
        color: isBuiltIn ? Colors.grey : Theme.of(context).primaryColor,
      ),
      title: Text(school.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (school.brief != null && school.brief!.isNotEmpty)
            Text(school.brief!, maxLines: 2, overflow: TextOverflow.ellipsis),
          if (school.features.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 4,
                runSpacing: 2,
                children: school.features
                    .map((f) => Chip(
                          label: Text(f, style: const TextStyle(fontSize: 11)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
      isThreeLine: school.brief != null || school.features.isNotEmpty,
      trailing: isBuiltIn
          ? null
          : PopupMenuButton<String>(
              onSelected: (action) {
                if (action == 'edit') {
                  _navigateToEditor(context, schoolId: school.id);
                } else if (action == 'delete') {
                  _confirmDelete(context, viewModel, school);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('编辑')),
                const PopupMenuItem(value: 'delete', child: Text('删除')),
              ],
            ),
      onTap: () => _navigateToEditor(context, schoolId: school.id),
    );
  }

  void _navigateToEditor(BuildContext context, {String? schoolId}) {
    Navigator.pushNamed(
      context,
      '/qizhengsiyu/ge_ju/school/edit',
      arguments: schoolId,
    ).then((_) {
      context.read<GeJuSchoolListViewModel>().loadSchools();
    });
  }

  Future<void> _confirmDelete(
    BuildContext context,
    GeJuSchoolListViewModel viewModel,
    GeJuSchool school,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除流派 "${school.name}" 吗？'),
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
      final success = await viewModel.deleteSchool(school.id);
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage ?? '删除失败')),
        );
      }
    }
  }
}
