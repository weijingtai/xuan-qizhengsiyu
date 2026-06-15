import 'dart:convert';
import 'dart:io';

class BasePanelFixture {
  static const goldenBasePanelPath = 'test/resources/base_panel_model.json';
  static const goldenStarPositionSnapshotPath =
      'test/resources/golden_base_star_positions.json';
  static const decouplingContractFixturePath =
      'test/resources/qizhengsiyu_decoupling_contract_fixture.json';
  static const calculationRegressionCasesPath =
      'test/resources/qizhengsiyu_time_calculation_cases.json';
  static const allInOnePanelCasesPath =
      'test/resources/qizhengsiyu_all_in_one_panel_cases.json';

  static Future<Map<String, dynamic>> loadGoldenBasePanelJson() async {
    final content = await File(goldenBasePanelPath).readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> loadGoldenStarPositionSnapshot() async {
    final content = await File(goldenStarPositionSnapshotPath).readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> loadDecouplingContractFixture() async {
    final content = await File(decouplingContractFixturePath).readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> loadCalculationRegressionCases() async {
    final content = await File(calculationRegressionCasesPath).readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> loadAllInOnePanelCases() async {
    final content = await File(allInOnePanelCasesPath).readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  }
}
