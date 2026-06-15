// T-Q4-RETIRE-*: Consumer scan evidence for retire-after-Q4/internal-only fields.
//
// Per acceptance criteria §4, fields classified as retire-after-Q4 must have
// zero remaining UI consumers in lib/presentation + lib/controllers before
// Q5 safe cleanup.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Fields classified as retire-after-Q4 per Q4.3a.
/// These fields should have NO remaining UI consumers before Q5 cleanup.
const _retireAfterQ4Fields = [
  // Add field names here as Q4.3a classification completes.
  // Format: 'fieldName' — scan will look for this identifier in
  // lib/presentation and lib/controllers .dart files.
  //
  // Examples (to be confirmed by Q4.3a):
  // 'uiDaXianPanelNotifier',  // if classified as retire
];

/// Fields classified as internal-only (never had UI consumers).
const _internalOnlyFields = [
  // Add field names here as Q4.3a classification completes.
];

void main() {
  group('Retire-after-Q4 Consumer Scan (T-Q4-RETIRE-*)', () {
    test('retire-after-Q4 fields have zero UI consumers', () {
      if (_retireAfterQ4Fields.isEmpty) {
        // No fields classified yet — placeholder passes.
        return;
      }

      final violations = <String>[];
      final dirs = [
        Directory('lib/presentation'),
        Directory('lib/controllers'),
      ];

      for (final fieldName in _retireAfterQ4Fields) {
        for (final dir in dirs) {
          if (!dir.existsSync()) continue;
          for (final entity in dir.listSync(recursive: true)) {
            if (entity is! File || !entity.path.endsWith('.dart')) continue;
            final lines = entity.readAsLinesSync();
            for (var i = 0; i < lines.length; i++) {
              final line = lines[i];
              if (line.contains(fieldName)) {
                final trimmed = line.trim();
                // Skip declarations/definitions, only flag consumers
                if (!trimmed.startsWith('//') &&
                    !trimmed.startsWith('*') &&
                    !trimmed.contains('final ') &&
                    !trimmed.contains('late ') &&
                    !trimmed.contains('ValueNotifier')) {
                  violations.add(
                    '${entity.path}:${i + 1}: consumer of "$fieldName": $trimmed',
                  );
                }
              }
            }
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Retire-after-Q4 fields still have UI consumers:\n${violations.join('\n')}',
      );
    });

    test('internal-only fields have zero UI consumers', () {
      if (_internalOnlyFields.isEmpty) return;

      final violations = <String>[];
      final dirs = [
        Directory('lib/presentation'),
        Directory('lib/controllers'),
      ];

      for (final fieldName in _internalOnlyFields) {
        for (final dir in dirs) {
          if (!dir.existsSync()) continue;
          for (final entity in dir.listSync(recursive: true)) {
            if (entity is! File || !entity.path.endsWith('.dart')) continue;
            final lines = entity.readAsLinesSync();
            for (var i = 0; i < lines.length; i++) {
              if (lines[i].contains(fieldName)) {
                violations.add(
                  '${entity.path}:${i + 1}: consumer of "$fieldName"',
                );
              }
            }
          }
        }
      }

      expect(violations, isEmpty,
          reason:
              'Internal-only fields have UI consumers:\n${violations.join('\n')}');
    });
  });
}
