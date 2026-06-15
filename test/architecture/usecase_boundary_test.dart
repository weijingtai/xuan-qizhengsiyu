// T-Q3-NEG-01: UseCase layer boundary — forbidden imports.
//
// Scans lib/domain/usecases for forbidden patterns.
// Also includes A1 self-proof for save_calculated_panel_usecase.dart.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('T-Q3-NEG-01 UseCase boundary', () {
    test('UseCase layer has no forbidden imports', () {
      final dir = Directory('lib/domain/usecases');
      if (!dir.existsSync()) {
        fail('lib/domain/usecases directory not found');
      }

      final violations = _scanFiles(
        directories: [dir],
        denyPattern: _denyPattern,
        baseline: _baselineAllowed,
      );

      expect(violations, isEmpty,
          reason:
              'UseCase layer has forbidden imports:\n${violations.join('\n')}');
    });
  });
}

final _denyPattern = RegExp(
  r'package:flutter/(material|widgets|services|rendering)\.dart|presentation/|'
  r'pages/|widgets/|BuildContext|rootBundle|AppDatabase|RepositoryImpl|'
  r'LocalDataSourceImpl|(^|/)data/',
);

// Empty baseline: after Q3.5, usecases/ should have zero violations.
const _baselineAllowed = <String>{};

List<String> _scanFiles({
  required List<Directory> directories,
  required RegExp denyPattern,
  required Set<String> baseline,
}) {
  final violations = <String>[];
  for (final dir in directories) {
    if (!dir.existsSync()) continue;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final lines = entity.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (denyPattern.hasMatch(line)) {
            violations.add('${entity.path}:${i + 1}: ${line.trim()}');
          }
        }
      }
    }
  }
  return violations;
}
