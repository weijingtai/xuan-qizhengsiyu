// T-Q5-ARCH-01: Domain Flutter deny-list scan.
//
// Scans lib/domain for package:flutter/(services|foundation|rendering|material|widgets).dart
// and rootBundle. Expected: zero matches (Q5 cleanup complete).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Domain Flutter Deny-List (T-Q5-ARCH-01)', () {
    test('lib/domain has zero Flutter package imports', () {
      final violations = _scanFiles(
        directory: Directory('lib/domain'),
        denyPattern: _denyPattern,
      );
      expect(
        violations,
        isEmpty,
        reason:
            'Domain layer has unapproved Flutter dependencies:\n${violations.join('\n')}',
      );
    });

    test('lib/domain has no rootBundle usage', () {
      final violations = _scanFiles(
        directory: Directory('lib/domain'),
        denyPattern: RegExp(r'rootBundle'),
      );
      expect(
        violations,
        isEmpty,
        reason:
            'Domain layer still uses rootBundle:\n${violations.join('\n')}',
      );
    });
  });
}

final _denyPattern = RegExp(
  r'package:flutter/(services|foundation|rendering|material|widgets)\.dart|rootBundle',
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
          // Skip comments
          final trimmed = line.trim();
          if (trimmed.startsWith('//') || trimmed.startsWith('*')) continue;
          violations.add('${entity.path}:${i + 1}: $trimmed');
        }
      }
    }
  }
  return violations;
}
