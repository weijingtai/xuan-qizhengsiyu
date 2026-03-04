/// 主页

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:companion_system/database/drift_database.dart';
import 'package:companion_system/providers/rule_provider.dart';
import 'package:companion_system/pages/rule_list_page.dart';
import 'package:companion_system/pages/pattern_management_page.dart';
import 'package:companion_system/pages/school_management_page.dart';
import 'package:companion_system/pages/import_page.dart';
import 'package:companion_system/pages/chat_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('七政四余格局数据维护系统'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        children: [
          _buildCard(
            context,
            icon: Icons.format_list_bulleted,
            title: '所有格局',
            subtitle: '查看和管理格局规则',
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RuleListPage()),
              );
            },
          ),
          _buildCard(
            context,
            icon: Icons.category,
            title: 'Pattern管理',
            subtitle: '管理格局元信息',
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PatternManagementPage()),
              );
            },
          ),
          _buildCard(
            context,
            icon: Icons.school,
            title: 'School管理',
            subtitle: '管理流派典籍',
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SchoolManagementPage()),
              );
            },
          ),
          _buildCard(
            context,
            icon: Icons.import_export,
            title: '导入导出',
            subtitle: '批量导入导出数据',
            color: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ImportPage()),
              );
            },
          ),
          _buildCard(
            context,
            icon: Icons.chat_outlined,
            title: 'AI对话',
            subtitle: '查看识别记录，与助手对话',
            color: Colors.deepPurple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatPage()),
              );
            },
          ),
          _buildCard(
            context,
            icon: Icons.settings,
            title: '设置',
            subtitle: '系统设置和配置',
            color: Colors.grey,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('设置功能开发中...')),
              );
            },
          ),
          _buildCard(
            context,
            icon: Icons.info,
            title: '关于',
            subtitle: '查看系统信息',
            color: Colors.teal,
            onTap: () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('七政四余格局数据维护系统'),
            SizedBox(height: 16),
            Text('版本: 1.0.0'),
            Text('这是一个用于管理和维护七政四余格局数据的工具。'),
            SizedBox(height: 16),
            Text('功能:'),
            Text('- 格局规则管理'),
            Text('- Pattern元信息管理'),
            Text('- School流派管理'),
            Text('- 数据导入导出'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
