import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/managers/ge_ju/ge_ju_rule_parser.dart';
import 'package:qizhengsiyu/domain/managers/ge_ju/ge_ju_text_parser.dart';

void main() {
  test('Convert ge_ju_1.txt to JSON', () async {
    final file = File('example/assets/tmp/ge_ju_1.txt');
    if (!file.existsSync()) {
      print("File not found: ${file.path}");
      return;
    }

    final content = await file.readAsString();
    final rules = GeJuTextParser.parseText(content);

    print("Parsed ${rules.length} rules.");

    // Filter valid rules (those with conditions extracted, or at least parsed correctly)
    // For now, we output all of them to see the result

    final jsonOutput = jsonEncode(rules.map((e) => e.toJson()).toList());

    // Save to a new file for inspection
    final outputFile = File('example/assets/tmp/ge_ju_1_converted.json');
    await outputFile.writeAsString(jsonOutput);

    print("Saved JSON to ${outputFile.path}");

    // Verify we can read it back
    final reReadRules = GeJuRuleParser.parseRules(jsonOutput);
    expect(reReadRules.length, rules.length);
    print("Verification successful: Re-read ${reReadRules.length} rules.");
  });
}
