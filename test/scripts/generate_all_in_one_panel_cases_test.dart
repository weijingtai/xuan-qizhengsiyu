import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all-in-one generation script emits complete panel cases', () async {
    final outputPath =
        'test/resources/qizhengsiyu_all_in_one_panel_cases.json';

    final result = await Process.run(
      'node',
      [
        'scripts/generate_all_in_one_panel_cases.mjs',
        '--manifest=test/resources/qizhengsiyu_all_in_one_panel_manifest.json',
        '--out=$outputPath',
      ],
    );

    expect(result.exitCode, 0, reason: result.stderr as String?);

    final generated =
        jsonDecode(await File(outputPath).readAsString()) as Map<String, dynamic>;
    final cases = generated['cases'] as List<dynamic>;

    expect(cases, isNotEmpty);
    final first = cases.first as Map<String, dynamic>;
    final fullPanel = first['fullPanel'] as Map<String, dynamic>;
    expect(first['input'], contains('birthDateTime'));
    expect(first['input'], contains('location'));
    expect(fullPanel['starAngleMapper'], hasLength(11));
    expect(fullPanel['enteredGongMapper'], hasLength(11));
    expect(fullPanel['shenShaMapper'], hasLength(12));
    expect(fullPanel['huaYaoStarPairList'], hasLength(41));
    expect(fullPanel['starAngleMapper']['日']['angle'], 68.116);
  });
}
