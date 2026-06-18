import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Import Guard: no xuan_config in lib/', () {
    test('lib/ has zero imports of package:xuan_config', () {
      final violations = _scanFiles(
        directories: [Directory('lib')],
        denyPattern: RegExp(r'package:xuan_config'),
      );
      expect(violations, isEmpty,
          reason: 'package:xuan_config must not appear in lib/:\n'
              '${violations.join('\n')}');
    });

    test('Painter files must not import xuan_config directly', () {
      final violations = _scanFiles(
        directories: [
          Directory('lib/painter'),
          Directory('lib/presentation/widgets/rings'),
        ],
        denyPattern: RegExp(r'package:xuan_config'),
      );
      expect(violations, isEmpty,
          reason: 'Painter files must not import xuan_config:\n'
              '${violations.join('\n')}');
    });
  });
}

List<String> _scanFiles({
  required List<Directory> directories,
  required RegExp denyPattern,
}) {
  final files = <File>[
    for (final dir in directories) ..._dartFiles(dir),
  ];

  final violations = <String>[];
  for (final file in files.where((f) => f.existsSync())) {
    final lines = file.readAsLinesSync();
    for (var index = 0; index < lines.length; index += 1) {
      final line = lines[index];
      if (denyPattern.hasMatch(line)) {
        violations.add('${file.path}:${index + 1}: ${line.trim()}');
      }
    }
  }
  return violations;
}

Iterable<File> _dartFiles(Directory directory) sync* {
  if (!directory.existsSync()) return;
  for (final entity in directory.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      yield entity;
    }
  }
}
