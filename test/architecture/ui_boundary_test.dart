import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UI boundary has no unapproved data/rootBundle dependencies', () {
    final violations = _scanUiBoundary();
    final unexpected = violations
        .where((violation) => !_baselineAllowedViolations.contains(violation))
        .toList();

    expect(unexpected, isEmpty);
  });
}

final _denyPattern = RegExp(
  r'(^|/)data/|rootBundle|persistence_drift|persistence_assets|AppDatabase|'
  r'QiZhengSiYuPanRepository|ShenShaRepositoryImpl|HuaYaoRepositoryImpl|'
  r'LocalDataSourceImpl|SaveCalculatedPanelUseCase\(|CalculateFateDongWeiUseCase\(',
);

List<String> _scanUiBoundary() {
  final files = <File>[
    ..._dartFiles(Directory('lib/presentation')),
    ..._dartFiles(Directory('lib/controllers')),
    File('lib/navigator.dart'),
  ];

  final violations = <String>[];
  for (final file in files.where((file) => file.existsSync())) {
    final lines = file.readAsLinesSync();
    for (var index = 0; index < lines.length; index += 1) {
      final line = lines[index];
      if (_denyPattern.hasMatch(line)) {
        violations.add('${file.path}: ${line.trim()}');
      }
    }
  }
  return violations;
}

const _baselineAllowedViolations = {
  "lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart: import 'package:qizhengsiyu/data/datasources/local/hua_yao_local_data_source.dart';",
  "lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart: import 'package:qizhengsiyu/data/repositories/hua_yao_repository_impl.dart';",
  "lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart: import 'package:qizhengsiyu/data/datasources/local/shen_sha_local_data_source.dart';",
  "lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart: import 'package:qizhengsiyu/data/repositories/shen_sha_repository_impl.dart';",
  "lib/presentation/pages/beauty_page_viewmodel.dart: import 'package:qizhengsiyu/data/datasources/local/hua_yao_local_data_source.dart';",
  "lib/presentation/pages/beauty_page_viewmodel.dart: import 'package:qizhengsiyu/data/repositories/hua_yao_repository_impl.dart';",
  "lib/presentation/pages/beauty_page_viewmodel.dart: import '../../data/datasources/local/shen_sha_local_data_source.dart';",
  "lib/presentation/pages/beauty_page_viewmodel.dart: import '../../data/repositories/shen_sha_repository_impl.dart';",
  "lib/presentation/pages/beauty_page_viewmodel.dart: rootBundle.loadString('assets/shen_sha/74_shensha_tiangan.json'),",
  "lib/presentation/pages/beauty_page_viewmodel.dart: rootBundle.loadString('assets/shen_sha/74_shensha_dizhi_year.json'),",
  "lib/presentation/pages/beauty_page_viewmodel.dart: rootBundle.loadString('assets/shen_sha/74_shensha_dizhi_month.json'),",
  "lib/presentation/pages/beauty_page_viewmodel.dart: rootBundle.loadString('assets/shen_sha/74_shensha_ganzhi.json'),",
  "lib/presentation/pages/beauty_page_viewmodel.dart: rootBundle.loadString('assets/shen_sha/74_shensha_bundle.json'),",
  "lib/presentation/pages/beauty_page_viewmodel.dart: rootBundle.loadString('assets/shen_sha/74_shensha_others.json'),",
  "lib/presentation/pages/beauty_page_viewmodel.dart: repository: ShenShaRepositoryImpl(",
  "lib/presentation/pages/beauty_page_viewmodel.dart: localDataSource: ShenShaLocalDataSourceImpl())));",
  "lib/presentation/pages/beauty_page_viewmodel.dart: rootBundle.loadString('assets/shen_sha/74_huayao_tiangan.json'),",
  "lib/presentation/pages/beauty_page_viewmodel.dart: rootBundle.loadString('assets/shen_sha/74_huayao_dizhi.json'),",
  "lib/presentation/pages/beauty_page_viewmodel.dart: rootBundle.loadString('assets/shen_sha/74_huayao_others.json'),",
  "lib/presentation/pages/beauty_page_viewmodel.dart: repository: HuaYaoRepositoryImpl(",
  "lib/presentation/pages/beauty_page_viewmodel.dart: localDataSource: HuaYaoLocalDataSourceImpl())));",
  "lib/presentation/pages/beauty_page_viewmodel.dart: //       SaveCalculatedPanelUseCase(_database.basePanelDao);",
  "lib/presentation/pages/beauty_view_page.dart: var data = await rootBundle.load(",
  "lib/presentation/viewmodels/ge_ju_editor_viewmodel.dart: import 'package:qizhengsiyu/data/contract_mappers/qizhengsiyu_contract_mappers.dart';",
  "lib/presentation/viewmodels/ge_ju_school_editor_viewmodel.dart: import 'package:qizhengsiyu/data/contract_mappers/qizhengsiyu_contract_mappers.dart';",
  "lib/presentation/viewmodels/ge_ju_school_list_viewmodel.dart: import 'package:qizhengsiyu/data/contract_mappers/qizhengsiyu_contract_mappers.dart';",
};

Iterable<File> _dartFiles(Directory directory) sync* {
  if (!directory.existsSync()) return;
  for (final entity in directory.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      yield entity;
    }
  }
}
