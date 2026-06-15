import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Import Boundary Tests', () {
    test('Self-proof: matcher catches forbidden patterns in sample text', () {
      final sampleContent = "import 'package:qizhengsiyu/data/datasources/local_source.dart';";
      expect(_hasViolation(sampleContent, _uiDenyPattern), isTrue);

      final sampleFlutter = "import 'package:flutter/services.dart';";
      expect(_hasViolation(sampleFlutter, _domainFlutterDenyPattern), isTrue);
    });

    test('UI layer has no unapproved data/rootBundle/storage dependencies', () {
      final violations = _scanFiles(
        directories: [Directory('lib/presentation'), Directory('lib/controllers')],
        singleFiles: [File('lib/navigator.dart')],
        denyPattern: _uiDenyPattern,
      );
      expect(violations, isEmpty, reason: 'Unexpected UI boundary violations found:\n${violations.join('\n')}');
    });

    test('ViewModel layer has no unapproved data/rootBundle/storage/services dependencies', () {
      final violations = _scanFiles(
        directories: [Directory('lib/presentation/viewmodels')],
        singleFiles: [File('lib/presentation/pages/beauty_page_viewmodel.dart')],
        denyPattern: _viewModelDenyPattern,
      );
      expect(violations, isEmpty, reason: 'Unexpected ViewModel boundary violations found:\n${violations.join('\n')}');
    });

    test('UseCase layer has no unapproved Flutter/UI/data/storage dependencies', () {
      final violations = _scanFiles(
        directories: [Directory('lib/domain/usecases')],
        singleFiles: [],
        denyPattern: _useCaseDenyPattern,
      );
      expect(violations, isEmpty, reason: 'Unexpected UseCase boundary violations found:\n${violations.join('\n')}');
    });

    test('Domain layer has no unapproved Flutter dependencies', () {
      final violations = _scanFiles(
        directories: [Directory('lib/domain')],
        singleFiles: [],
        denyPattern: _domainFlutterDenyPattern,
      );
      expect(violations, isEmpty, reason: 'Unexpected Domain Flutter boundary violations found:\n${violations.join('\n')}');
    });

    test('Domain layer has no unapproved data-layer dependencies', () {
      final violations = _scanFiles(
        directories: [Directory('lib/domain')],
        singleFiles: [],
        denyPattern: _domainDataDenyPattern,
      );
      expect(violations, isEmpty, reason: 'Unexpected Domain Data boundary violations found:\n${violations.join('\n')}');
    });
  });
}

final _uiDenyPattern = RegExp(
  r'(^|/)data/|rootBundle|persistence_drift|persistence_assets|AppDatabase|'
  r'QiZhengSiYuPanRepository|ShenShaRepositoryImpl|HuaYaoRepositoryImpl|'
  r'LocalDataSourceImpl|SaveCalculatedPanelUseCase\(|CalculateFateDongWeiUseCase\(',
);

final _viewModelDenyPattern = RegExp(
  r'(^|/)data/|rootBundle|persistence_drift|persistence_assets|AppDatabase|'
  r'RepositoryImpl|LocalDataSourceImpl|package:flutter/services.dart',
);

final _useCaseDenyPattern = RegExp(
  r'package:flutter/(material|widgets|services|rendering)\.dart|presentation/|'
  r'pages/|widgets/|BuildContext|rootBundle|AppDatabase|RepositoryImpl|'
  r'LocalDataSourceImpl|(^|/)data/',
);

final _domainFlutterDenyPattern = RegExp(
  r'package:flutter/(services|foundation|rendering|material|widgets)\.dart|rootBundle',
);

final _domainDataDenyPattern = RegExp(
  r'(^|/)data/|LocalDataSource|RepositoryImpl|SystemDefinitionLocalDataSource',
);

bool _hasViolation(String line, RegExp pattern) {
  return pattern.hasMatch(line);
}

List<String> _scanFiles({
  required List<Directory> directories,
  required List<File> singleFiles,
  required RegExp denyPattern,
}) {
  final files = <File>[
    ...singleFiles,
    for (final dir in directories) ..._dartFiles(dir),
  ];

  final violations = <String>[];
  for (final file in files.where((f) => f.existsSync())) {
    final lines = file.readAsLinesSync();
    for (var index = 0; index < lines.length; index += 1) {
      final line = lines[index];
      if (denyPattern.hasMatch(line)) {
        violations.add('${file.path}:${index + 1}: ${line.trim()}');
      }
    }
  }
  return violations;
}

Iterable<File> _dartFiles(Directory directory) sync* {
  if (!directory.existsSync()) return;
  for (final entity in directory.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      yield entity;
    }
  }
}
