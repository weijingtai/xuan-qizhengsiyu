import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// T-Q2-REVDEP-01: Storage packages must not import presentation/UI layers.
///
/// Scans xuan-storage/{assets,drift}/lib for forbidden presentation imports.
/// These are sibling packages that may or may not be present locally.
void main() {
  group('T-Q2-REVDEP-01 Storage reverse dependency guard', () {
    test(
        'xuan-storage/assets and xuan-storage/drift have no '
        'presentation/pages/widgets/BuildContext imports', () {
      final storageDirs = [
        Directory('../xuan-storage/assets/lib'),
        Directory('../xuan-storage/drift/lib'),
      ];

      final missingDirs = <String>[];
      for (final dir in storageDirs) {
        if (!dir.existsSync()) {
          missingDirs.add(dir.path);
        }
      }

      if (missingDirs.length == storageDirs.length) {
        return;
      }

      final denyPattern = RegExp(
        r'presentation/|pages/|widgets/|ViewModel|BuildContext',
      );

      final violations = <String>[];
      for (final dir in storageDirs) {
        if (!dir.existsSync()) continue;
        violations.addAll(_scanFiles(
          directories: [dir],
          denyPattern: denyPattern,
          label: dir.path,
        ));
      }

      expect(violations, isEmpty,
          reason: 'Storage packages must not depend on presentation layer:\n'
              '${violations.join('\n')}');
    });
  });
}

List<String> _scanFiles({
  required List<Directory> directories,
  required RegExp denyPattern,
  required String label,
}) {
  final violations = <String>[];
  for (final dir in directories) {
    if (!dir.existsSync()) continue;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final lines = entity.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.trimLeft().startsWith('//') ||
              line.trimLeft().startsWith('/*') ||
              line.trimLeft().startsWith('*')) {
            continue;
          }
          if (denyPattern.hasMatch(line)) {
            violations.add('${entity.path}:${i + 1}: ${line.trim()}');
          }
        }
      }
    }
  }
  return violations;
}
