// T-Q4-VM-02: ViewModel layer boundary test.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ViewModel Boundary (T-Q4-VM-02)', () {
    test('ViewModel layer has no unapproved data/rootBundle/storage/services dependencies', () {
      final violations = _scanFiles(
        directories: [Directory('lib/presentation/viewmodels')],
        singleFiles: [File('lib/presentation/pages/beauty_page_viewmodel.dart')],
        denyPattern: _denyPattern,
      );
      expect(
        violations,
        isEmpty,
        reason:
            'ViewModel layer has unapproved dependencies:\n${violations.join('\n')}',
      );
    });
  });
}

final _denyPattern = RegExp(
  r'(^|/)data/|rootBundle|persistence_drift|persistence_assets|AppDatabase|'
  r'RepositoryImpl|LocalDataSourceImpl|package:flutter/services\.dart',
);

List<String> _scanFiles({
  required List<Directory> directories,
  required List<File> singleFiles,
  required RegExp denyPattern,
}) {
  final files = <File>[
    ...singleFiles,
    for (final dir in directories)
      if (dir.existsSync())
        ...dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')),
  ];

  final violations = <String>[];
  for (final file in files.where((f) => f.existsSync())) {
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (denyPattern.hasMatch(line)) {
        violations.add('${file.path}:${i + 1}: ${line.trim()}');
      }
    }
  }
  return violations;
}
