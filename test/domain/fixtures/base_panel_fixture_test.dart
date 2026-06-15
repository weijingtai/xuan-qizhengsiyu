import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/base_panel_fixture.dart';

void main() {
  group('base panel fixture', () {
    test('loads the current golden star position snapshot', () async {
      final snapshot = await BasePanelFixture.loadGoldenStarPositionSnapshot();

      expect(snapshot['caseId'], 'golden_base_star_positions_v1');

      expect(
        snapshot['starAngles']['日']['angle'] as double,
        closeTo(68.116, 0.0005),
      );
      expect(
        snapshot['starAngles']['月']['angle'] as double,
        closeTo(97.287, 0.0005),
      );
      expect(snapshot['starAngles'], hasLength(11));
      for (final star in snapshot['starAngles'].values) {
        final starData = star as Map<String, dynamic>;
        expect(_hasAtMostThreeDecimals(starData['angle'] as double), isTrue);
      }

      final sun = snapshot['enteredPositions']['日'] as Map<String, dynamic>;
      expect(sun['gong'], '申');
      expect(sun['gongDegree'] as double, closeTo(8.116, 0.0000000001));
      expect(sun['constellation'], '毕');
      expect(
        sun['constellationDegree'] as double,
        closeTo(14.916, 0.0000000001),
      );

      final moon = snapshot['enteredPositions']['月'] as Map<String, dynamic>;
      expect(moon['gong'], '未');
      expect(moon['gongDegree'] as double, closeTo(7.287, 0.0000000001));
      expect(moon['constellation'], '井');
      expect(
        moon['constellationDegree'] as double,
        closeTo(15.487, 0.0000000001),
      );

      expect(snapshot['fiveStarWalkingTypes'], {
        '木': '常',
        '土': '常',
        '火': '常',
        '水': '速',
        '金': '常',
      });

      for (final position in snapshot['enteredPositions'].values) {
        final positionData = position as Map<String, dynamic>;
        expect(
          _hasAtMostThreeDecimals(positionData['gongDegree'] as double),
          isTrue,
        );
        expect(
          _hasAtMostThreeDecimals(
            positionData['constellationDegree'] as double,
          ),
          isTrue,
        );
      }
    });

    test(
      'loads decoupling contract data for each architecture layer',
      () async {
        final fixture = await BasePanelFixture.loadDecouplingContractFixture();

        expect(fixture['caseId'], 'qizhengsiyu_decoupling_contract_v1');
        expect(fixture['goldenSnapshotRef'], 'golden_base_star_positions_v1');

        final uiInput = fixture['uiLayerInput'] as Map<String, dynamic>;
        expect(uiInput['allowedConsumer'], 'UI');
        expect(
          uiInput['forbiddenDependencies'],
          containsAll(['Repository', 'UseCase']),
        );
        expect(uiInput, isNot(contains('repositoryTable')));
        expect(uiInput, isNot(contains('useCaseClass')));

        final viewModelCommand =
            fixture['viewModelCommand'] as Map<String, dynamic>;
        expect(viewModelCommand['allowedConsumer'], 'ViewModel');
        expect(viewModelCommand['emitsUseCase'], 'CalculateBasePanelUseCase');
        expect(viewModelCommand['forbiddenDependencies'], contains('Drift'));

        final useCaseRequest =
            fixture['useCaseRequest'] as Map<String, dynamic>;
        expect(useCaseRequest['allowedConsumer'], 'UseCase');
        expect(useCaseRequest['repositoryPort'], 'QiZhengSiYuPanRepository');
        expect(
          useCaseRequest['forbiddenDependencies'],
          containsAll(['BuildContext', 'Widget']),
        );

        final repositorySeed =
            fixture['repositorySeed'] as Map<String, dynamic>;
        expect(repositorySeed['allowedConsumer'], 'Repository');
        expect(repositorySeed['storageContract'], 'panel_snapshot_json');
        expect(
          repositorySeed['payload']['snapshotRef'],
          'golden_base_star_positions_v1',
        );
      },
    );

    test('loads time-based calculation regression cases', () async {
      final cases = await BasePanelFixture.loadCalculationRegressionCases();

      expect(cases['caseSetId'], 'qizhengsiyu_time_calculation_cases_v1');
      expect(cases['cases'], hasLength(greaterThanOrEqualTo(5)));

      for (final item in cases['cases'] as List<dynamic>) {
        final testCase = item as Map<String, dynamic>;
        final input = testCase['input'] as Map<String, dynamic>;
        final expected = testCase['expected'] as Map<String, dynamic>;

        final birthDateTime = DateTime.parse(input['birthDateTime'] as String);
        expect(
          _roundAngleTo3(_ziQiFromCurrentReference(birthDateTime)),
          closeTo(expected['ziQiAngle'] as double, 0.0005),
          reason: testCase['id'] as String,
        );
        expect(
          _hasAtMostThreeDecimals(expected['ziQiAngle'] as double),
          isTrue,
          reason: testCase['id'] as String,
        );
        expect(expected['starSnapshotContract'], contains('starAngles'));
        expect(expected['starSnapshotContract'], contains('enteredPositions'));
      }
    });

    test('loads all-in-one full panel cases', () async {
      final caseSet = await BasePanelFixture.loadAllInOnePanelCases();

      expect(caseSet['caseSetId'], 'qizhengsiyu_all_in_one_panel_cases_v1');

      final cases = caseSet['cases'] as List<dynamic>;
      expect(cases, isNotEmpty);

      final firstCase = cases.first as Map<String, dynamic>;
      expect(firstCase['input'], contains('birthDateTime'));
      expect(firstCase['input'], contains('location'));

      final fullPanel = firstCase['fullPanel'] as Map<String, dynamic>;
      expect(fullPanel['starAngleMapper'], hasLength(11));
      expect(fullPanel['enteredGongMapper'], hasLength(11));
      expect(fullPanel['fiveStarWalkingTypeMapper'], hasLength(5));
      expect(fullPanel, contains('bodyLifeModel'));
      expect(fullPanel, contains('twelveGongMapper'));
      expect(fullPanel, contains('shenShaMapper'));
      expect(fullPanel, contains('huaYaoStarPairList'));
      expect(fullPanel, contains('twelveZhangShengGongMapper'));
      expect(
        _hasAtMostThreeDecimals(
          fullPanel['starAngleMapper']['日']['angle'] as double,
        ),
        isTrue,
      );
    });
  });
}

double _roundAngleTo3(double value) {
  return (value * 1000).roundToDouble() / 1000;
}

bool _hasAtMostThreeDecimals(double value) {
  return (value * 1000 - (value * 1000).round()).abs() < 0.0000001;
}

double _ziQiFromCurrentReference(DateTime dateTime) {
  final referenceDateTimeUtc = DateTime.utc(2013, 4, 8, 18, 58);
  const referencePositionDegrees = 284.0;
  const dailyRateDegrees = 0.0352;

  final diff = dateTime.difference(referenceDateTimeUtc);
  final daysDiff = diff.inMinutes / (24 * 60.0);
  final angleDiff = daysDiff * dailyRateDegrees;
  final rawPosition = referencePositionDegrees + angleDiff;
  final result = rawPosition % 360.0;
  return result < 0 ? result + 360.0 : result;
}
