// T-Q3-ARCH-02 / T-Q5-ARCH-02: Domain-to-data layer deny-list scan.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Domain-to-Data Layer Boundary (T-Q3-ARCH-02 / T-Q5-ARCH-02)', () {
    test('lib/domain has no unapproved data-layer dependencies', () {
      final violations = _scanFiles(
        directory: Directory('lib/domain'),
        denyPattern: _denyPattern,
      );
      expect(
        violations,
        isEmpty,
        reason:
            'Domain layer has unapproved data-layer dependencies:\n${violations.join('\n')}',
      );
    });
  });
}

final _denyPattern = RegExp(
  r'(^|/)data/|LocalDataSource|RepositoryImpl|SystemDefinitionLocalDataSource',
);

List<String> _scanFiles({
  required Directory directory,
  required RegExp denyPattern,
}) {
  if (!directory.existsSync()) {
    return ['Directory ${directory.path} does not exist'];
  }

  final violations = <String>[];
  for (final entity in directory.listSync(recursive: true)) {
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
  return violations;
}
