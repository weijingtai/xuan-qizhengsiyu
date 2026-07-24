import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// 架构门禁: presentation 层禁止 import 或实例化引擎/计算器/计算装配服务。
/// 按 import 路径段匹配;display models(/liu_yun/models/)与 Repository 接口不受限。
/// 注释行不扫(仓内存在注释提及 calculator 的合法文件,如 lunar_date_info_card_v2)。
const _forbiddenImports = [
  '/domain/engines/',
  '/domain/managers/panel_system_resolver',
  '/domain/services/yuan_le_panel_builder',
  '/domain/services/generate_base_panel_service',
  'celestial_rise_set_calculator',
  'solar_time_calculator',
  'solar_lunar_datetime_helper',
  'lunar_adapter',
  '/liu_yun/services/',
];

/// 实例化 token(堵 umbrella export 绕行);只扫非注释行。
const _forbiddenTokens = [
  'CalculationEngineFactory',
  'CelestialRiseSetCalculator.',
  'SolarTimeCalculator(',
  'SolarLunarDateTimeHelper.',
  'LunarAdapter.',
  'PanelSystemResolver(',
  'YunLiuService(',
  'SchoolConfigResolver(',
];

bool _isComment(String t) =>
    t.startsWith('//') || t.startsWith('*') || t.startsWith('///');

List<String> scanViolations(String dirPath) {
  final violations = <String>[];
  for (final f in Directory(dirPath)
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))) {
    for (final line in f.readAsLinesSync()) {
      final t = line.trimLeft();
      if (_isComment(t)) continue;
      final importHit =
          t.startsWith('import') && _forbiddenImports.any(t.contains);
      final tokenHit = _forbiddenTokens.any(t.contains);
      if (importHit || tokenHit) violations.add('${f.path}: $line');
    }
  }
  return violations;
}

void main() {
  test('扫描器自检: 能捕获合成的违规(防假绿)', () {
    const fakeImport = "import 'package:qizhengsiyu/domain/engines/x.dart';";
    expect(_forbiddenImports.any(fakeImport.contains), isTrue);
    expect(
        _forbiddenTokens.any('final l = LunarAdapter.fromDate(d);'.contains),
        isTrue);
  });

  test('presentation 层零引擎泄漏(import + 实例化)', () {
    final violations = scanViolations('lib/presentation');
    expect(violations, isEmpty,
        reason: 'presentation 泄漏:\n${violations.join('\n')}');
  });
}
