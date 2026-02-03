import 'package:flutter/material.dart';

/// 七政四余模块入口选择页
class QiZhengSiYuHomePage extends StatelessWidget {
  const QiZhengSiYuHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('七政四余'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildEntryCard(
            context,
            icon: Icons.blur_circular,
            title: '命盘排盘',
            subtitle: '七政四余星盘计算与显示',
            route: '/qizhengsiyu/panel',
          ),
          const SizedBox(height: 12),
          _buildEntryCard(
            context,
            icon: Icons.auto_awesome,
            title: '格局管理',
            subtitle: '查看、编辑格局规则',
            route: '/qizhengsiyu/ge_ju/list',
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
