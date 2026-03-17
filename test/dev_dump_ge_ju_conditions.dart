/// Dev script: dump all GeJu condition data from the built-in SQLite database
/// to a JSON file for analysis.
///
/// Usage:
///   dart test test/dev_dump_ge_ju_conditions.dart
///
/// Output:
///   example/assets/tmp/ge_ju_conditions_dump.json

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/data/datasources/local/ge_ju_builtin_database.dart';

void main() {
  test('dump ge_ju conditions from built-in database', () async {
    // Open the SQLite database directly from disk (no Flutter asset bundle)
    final dbPath = '${Directory.current.path}'
        '/example/assets/qizhengsiyu/ge_ju/ge_ju_database.sqlite';
    final dbFile = File(dbPath);
    if (!dbFile.existsSync()) {
      fail('Database file not found at: $dbPath');
    }

    final db = GeJuBuiltInDatabase(NativeDatabase(dbFile, logStatements: false));

    try {
      // Query all rules
      final allRows = await db.select(db.builtinGeJuRules).get();
      final totalRows = allRows.length;

      // Separate rows with/without conditions
      final withConditions = <BuiltinGeJuRule>[];
      final withoutConditions = <BuiltinGeJuRule>[];

      for (final row in allRows) {
        if (row.conditions != null && row.conditions!.isNotEmpty) {
          withConditions.add(row);
        } else {
          withoutConditions.add(row);
        }
      }

      // Build the dump: only rows with conditions, include key fields
      final dumpList = withConditions.map((row) {
        Map<String, dynamic>? parsedConditions;
        try {
          parsedConditions =
              jsonDecode(row.conditions!) as Map<String, dynamic>;
        } catch (e) {
          parsedConditions = {'_parse_error': e.toString(), '_raw': row.conditions};
        }

        return <String, dynamic>{
          'id': row.id,
          'pattern_id': row.patternId,
          'school_id': row.schoolId,
          'jixiong': row.jixiong,
          'ge_ju_type': row.geJuType,
          'conditions': parsedConditions,
        };
      }).toList();

      // Write to JSON file
      final outputDir =
          Directory('${Directory.current.path}/example/assets/tmp');
      if (!outputDir.existsSync()) {
        outputDir.createSync(recursive: true);
      }
      final outputFile =
          File('${outputDir.path}/ge_ju_conditions_dump.json');
      const encoder = JsonEncoder.withIndent('  ');
      outputFile.writeAsStringSync(encoder.convert(dumpList));

      // --- Summary ---
      print('');
      print('====== GeJu Conditions Dump Summary ======');
      print('Database:          $dbPath');
      print('Total rules:       $totalRows');
      print('With conditions:   ${withConditions.length}');
      print('Without conditions: ${withoutConditions.length}');
      print('Output file:       ${outputFile.path}');
      print('');

      // --- Condition type frequency ---
      final typeCount = <String, int>{};
      // Also count all leaf-type occurrences (inside "and"/"or"/"not" combinators)
      final leafTypeCount = <String, int>{};
      int parseErrors = 0;

      void countTypes(Map<String, dynamic> cond, {bool isRoot = false}) {
        final type = cond['type'] as String?;
        if (type == null) return;
        if (isRoot) {
          typeCount[type] = (typeCount[type] ?? 0) + 1;
        }
        // Recurse into combinators
        if (type == 'and' || type == 'or') {
          final children = cond['conditions'] as List<dynamic>?;
          if (children != null) {
            for (final child in children) {
              if (child is Map<String, dynamic>) {
                countTypes(child);
              }
            }
          }
        } else if (type == 'not') {
          final child = cond['condition'] as Map<String, dynamic>?;
          if (child != null) {
            countTypes(child);
          }
        } else {
          // It's a leaf condition
          leafTypeCount[type] = (leafTypeCount[type] ?? 0) + 1;
        }
      }

      for (final row in withConditions) {
        try {
          final parsed = jsonDecode(row.conditions!) as Map<String, dynamic>;
          countTypes(parsed, isRoot: true);
        } catch (_) {
          parseErrors++;
        }
      }

      print('--- Root-level condition types ---');
      final sortedTypes = typeCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in sortedTypes) {
        print('  ${entry.key.padRight(30)} ${entry.value}');
      }

      print('');
      print('--- All leaf condition types (flattened) ---');
      final sortedLeafTypes = leafTypeCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in sortedLeafTypes) {
        print('  ${entry.key.padRight(30)} ${entry.value}');
      }

      if (parseErrors > 0) {
        print('');
        print('Parse errors: $parseErrors');
      }

      // --- jixiong distribution ---
      print('');
      print('--- jixiong distribution (among rows with conditions) ---');
      final jixiongCount = <String, int>{};
      for (final row in withConditions) {
        jixiongCount[row.jixiong] = (jixiongCount[row.jixiong] ?? 0) + 1;
      }
      final sortedJixiong = jixiongCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in sortedJixiong) {
        print('  ${entry.key.padRight(10)} ${entry.value}');
      }

      // --- ge_ju_type distribution ---
      print('');
      print('--- ge_ju_type distribution (among rows with conditions) ---');
      final geJuTypeCount = <String, int>{};
      for (final row in withConditions) {
        geJuTypeCount[row.geJuType] =
            (geJuTypeCount[row.geJuType] ?? 0) + 1;
      }
      final sortedGeJuType = geJuTypeCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in sortedGeJuType) {
        print('  ${entry.key.padRight(10)} ${entry.value}');
      }

      // --- school_id distribution ---
      print('');
      print('--- school_id distribution (among rows with conditions) ---');
      final schoolCount = <String, int>{};
      for (final row in withConditions) {
        schoolCount[row.schoolId] = (schoolCount[row.schoolId] ?? 0) + 1;
      }
      final sortedSchool = schoolCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in sortedSchool) {
        print('  ${entry.key.padRight(20)} ${entry.value}');
      }

      // --- Condition complexity (depth & child count) ---
      print('');
      print('--- Condition complexity ---');
      int maxDepth = 0;
      int maxChildren = 0;
      int totalLeaves = 0;

      int measureDepth(Map<String, dynamic> cond) {
        final type = cond['type'] as String?;
        if (type == 'and' || type == 'or') {
          final children = cond['conditions'] as List<dynamic>? ?? [];
          if (children.length > maxChildren) maxChildren = children.length;
          int childMax = 0;
          for (final child in children) {
            if (child is Map<String, dynamic>) {
              final d = measureDepth(child);
              if (d > childMax) childMax = d;
            }
          }
          return 1 + childMax;
        } else if (type == 'not') {
          final child = cond['condition'] as Map<String, dynamic>?;
          return 1 + (child != null ? measureDepth(child) : 0);
        } else {
          totalLeaves++;
          return 1;
        }
      }

      for (final row in withConditions) {
        try {
          final parsed = jsonDecode(row.conditions!) as Map<String, dynamic>;
          final depth = measureDepth(parsed);
          if (depth > maxDepth) maxDepth = depth;
        } catch (_) {}
      }

      print('  Max nesting depth:       $maxDepth');
      print('  Max children in and/or:  $maxChildren');
      print('  Total leaf conditions:   $totalLeaves');
      print('');

      expect(totalRows, greaterThan(0));
      expect(outputFile.existsSync(), isTrue);
    } finally {
      await db.close();
    }
  });
}
