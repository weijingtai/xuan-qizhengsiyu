/// JSON 导入页面
library;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:companion_system/database/drift_database.dart';
import 'package:companion_system/services/json_import_service.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  _ImportState _state = _ImportState.idle;
  String _currentFile = '';
  int _totalFiles = 0;
  int _doneFiles = 0;
  ImportResult? _result;

  Future<void> _pickAndImport() async {
    final dirPath = await getDirectoryPath(
      confirmButtonText: '选择此文件夹',
    );
    if (dirPath == null || !mounted) return;

    setState(() {
      _state = _ImportState.importing;
      _currentFile = '';
      _totalFiles = 0;
      _doneFiles = 0;
      _result = null;
    });

    final db = context.read<AppDatabase>();
    final service = JsonImportService(db);

    final result = await service.importFromDirectory(
      dirPath,
      onProgress: (file, total, done) {
        if (mounted) {
          setState(() {
            _currentFile = file;
            _totalFiles = total;
            _doneFiles = done;
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _state = _ImportState.done;
        _result = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('从 JSON 导入格局数据'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: switch (_state) {
          _ImportState.idle => _buildIdle(),
          _ImportState.importing => _buildImporting(),
          _ImportState.done => _buildDone(),
        },
      ),
    );
  }

  Widget _buildIdle() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.purple[300]),
          const SizedBox(height: 24),
          Text(
            '从 JSON 文件夹导入格局数据',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            '请选择包含 *ge_ju*.json 文件的文件夹\n（如 example/assets/qizhengsiyu/ge_ju）',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          const _InfoTable(),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _pickAndImport,
            icon: const Icon(Icons.folder_open),
            label: const Text('选择 ge_ju 文件夹'),
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImporting() {
    final progress =
        _totalFiles > 0 ? _doneFiles / _totalFiles : 0.0;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sync, size: 64, color: Colors.purple),
          const SizedBox(height: 24),
          Text(
            '正在导入...',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          LinearProgressIndicator(value: progress == 0 ? null : progress),
          const SizedBox(height: 12),
          Text(
            _currentFile.isEmpty
                ? '准备中...'
                : '$_currentFile  ($_doneFiles / $_totalFiles)',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDone() {
    final r = _result!;
    final hasErrors = r.errors.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Icon(
                  hasErrors ? Icons.warning_amber : Icons.check_circle,
                  size: 72,
                  color: hasErrors ? Colors.orange : Colors.green,
                ),
                const SizedBox(height: 12),
                Text(
                  hasErrors ? '导入完成（有部分错误）' : '导入成功！',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 统计表
          _ResultTable(result: r),
          if (hasErrors) ...[
            const SizedBox(height: 24),
            Text('错误详情 (${r.errors.length})',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: SelectableText(
                r.errors.join('\n'),
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
          ],
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => setState(() {
                  _state = _ImportState.idle;
                  _result = null;
                }),
                icon: const Icon(Icons.refresh),
                label: const Text('再次导入'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('返回主页'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _ImportState { idle, importing, done }

class _InfoTable extends StatelessWidget {
  const _InfoTable();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('字段映射规则',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _row('jiXiong', '大吉→(吉,大) / 吉→(吉,中) / 小吉→(吉,小) 等'),
            _row('conditions', '原样存为 JSON 字符串'),
            _row('books', '自动创建对应流派（已有则跳过）'),
            _row('className', '自动创建对应分类（已有则跳过）'),
            _row('重复记录', '已存在的格局/规则自动跳过'),
          ],
        ),
      ),
    );
  }

  Widget _row(String key, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(key,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13)),
          ),
          Expanded(
              child: Text(val,
                  style:
                      TextStyle(fontSize: 13, color: Colors.grey[700]))),
        ],
      ),
    );
  }
}

class _ResultTable extends StatelessWidget {
  final ImportResult result;
  const _ResultTable({required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('导入统计',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _statRow(Icons.category, '格局 (Pattern)', result.patternsImported, Colors.green),
            _statRow(Icons.rule, '规则 (Rule)', result.rulesImported, Colors.blue),
            _statRow(Icons.folder, '新建分类', result.categoriesCreated, Colors.orange),
            _statRow(Icons.school, '新建流派', result.schoolsCreated, Colors.purple),
            _statRow(Icons.skip_next, '跳过 (重复)', result.skipped, Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _statRow(IconData icon, String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          Text(
            '$count',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color),
          ),
        ],
      ),
    );
  }
}
