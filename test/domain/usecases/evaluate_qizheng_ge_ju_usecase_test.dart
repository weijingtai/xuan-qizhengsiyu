import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/repositories/ge_ju_repository_adapter.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/body_life_model.dart';
import 'package:qizhengsiyu/domain/entities/models/eleven_stars_info.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/entities/models/star_enter_info.dart';
import 'package:qizhengsiyu/domain/services/ge_ju_evaluation_service.dart';
import 'package:qizhengsiyu/domain/usecases/evaluate_qizheng_ge_ju_usecase.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';

class FakeGeJuRepo implements IGeJuRepository {
  @override Future<List<GeJuRuleContract>> loadAllRules() async => const [];
  @override Future<GeJuRuleContract?> getRuleById(String id) async => null;
  @override Future<void> saveUserRule(GeJuRuleContract rule) async {}
  @override Future<void> deleteUserRule(String id) async {}
  @override bool isBuiltInRule(String ruleId) => false;
  @override Set<String> get builtInRuleIds => const {};
  @override Future<List<GeJuConditionSetContract>> getConditionSetsForRule(String ruleId) async => const [];
  @override Future<GeJuConditionSetContract?> getConditionSetById(String id) async => null;
  @override Future<void> saveUserConditionSet(GeJuConditionSetContract cs) async {}
  @override Future<void> deleteUserConditionSet(String id) async {}
  @override Future<void> deleteUserConditionSetsForRule(String ruleId) async {}
  @override Future<List<GeJuAnnotationContract>> getAnnotationsForRule(String ruleId) async => const [];
  @override Future<GeJuAnnotationContract?> getAnnotationById(String id) async => null;
  @override Future<void> saveUserAnnotation(GeJuAnnotationContract ann) async {}
  @override Future<void> deleteUserAnnotation(String id) async {}
  @override Future<void> deleteUserAnnotationsForRule(String ruleId) async {}
  @override Future<Map<String, dynamic>> getPreference() async => const {};
  @override Future<void> savePreference(Map<String, dynamic> pref) async {}
  @override Future<void> recordDeletion(Map<String, dynamic> record) async {}
  @override void clearCache() {}
  @override Future<Map<String, List<GeJuConditionSetContract>>> loadAllConditionSetsGrouped() async => const {};
  @override Future<Map<String, List<GeJuAnnotationContract>>> loadAllAnnotationsGrouped() async => const {};
  @override Future<List<GeJuRuleContract>> loadBuiltInRules() async => const [];
  @override Future<List<GeJuRuleContract>> loadUserRules() async => const [];
}

BasePanelModel _emptyPanel() {
  return BasePanelModel(
    starAngleMapper: const {},
    enteredGongMapper: const {},
    fiveStarWalkingTypeMapper: const {},
    bodyLifeModel: BodyLifeModel(
      lifeGongInfo: GongDegree(gong: EnumTwelveGong.Mao, degree: 0.0),
      lifeConstellationInfo: ConstellationDegree(constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 0.0),
      bodyGongInfo: GongDegree(gong: EnumTwelveGong.You, degree: 0.0),
      bodyConstellationInfo: ConstellationDegree(constellation: Enum28Constellations.Kang_Jin_Long, degree: 0.0),
    ),
    twelveGongMapper: const {},
    shenShaItemMapper: const {},
    huaYaoItemMapper: const {},
    twelveZhangShengGongMapper: const {},
  );
}

void main() {
  group('EvaluateQiZhengGeJuUseCase', () {
    late GeJuEvaluationService geJuService;
    late EvaluateQiZhengGeJuUseCase useCase;

    setUp(() {
      final fakeRepo = FakeGeJuRepo();
      geJuService = GeJuEvaluationService(repository: GeJuRepositoryAdapter(fakeRepo));
      useCase = EvaluateQiZhengGeJuUseCase(geJuEvaluationService: geJuService);
    });

    test('constructs without Flutter bindings', () {
      expect(useCase, isNotNull);
    });

    test('execute returns GeJuEvaluationSummary', () async {
      final starsSet = <ElevenStarsInfo>{
        ElevenStarsInfo(
          star: EnumStars.Sun,
          angle: 68.116,
          enterInfo: EnteredInfo(
            originalStar: StarDegree(star: EnumStars.Sun, degree: 68.116),
            enterGongInfo: GongDegree(gong: EnumTwelveGong.Shen, degree: 8.116),
            enterInnInfo: ConstellationDegree(constellation: Enum28Constellations.Bi_Yue_Wu, degree: 14.916),
          ),
          fiveStarWalkingType: FiveStarWalkingType.Normal,
          walkingSpeed: 0.96,
          priority: EnumStarsPriority.Primary,
        ),
        ElevenStarsInfo(
          star: EnumStars.Moon,
          angle: 97.287,
          enterInfo: EnteredInfo(
            originalStar: StarDegree(star: EnumStars.Moon, degree: 97.287),
            enterGongInfo: GongDegree(gong: EnumTwelveGong.Shen, degree: 37.287),
            enterInnInfo: ConstellationDegree(constellation: Enum28Constellations.Bi_Yue_Wu, degree: 44.087),
          ),
          fiveStarWalkingType: FiveStarWalkingType.Normal,
          walkingSpeed: 14.45,
          priority: EnumStarsPriority.Secondary,
        ),
      };

      final summary = await useCase.execute(
        panelModel: _emptyPanel(),
        starsSet: starsSet,
        monthZhi: DiZhi.CHOU,
        yearJiaZi: JiaZi.JI_SI,
      );

      expect(summary, isNotNull);
      expect(summary.totalCount, greaterThanOrEqualTo(0));
    });

    test('invalidateCache does not throw', () {
      expect(() => useCase.invalidateCache(), returnsNormally);
    });

    test('usePreFilter getter/setter works', () {
      expect(useCase.usePreFilter, isTrue);
      useCase.usePreFilter = false;
      expect(useCase.usePreFilter, isFalse);
      useCase.usePreFilter = true;
      expect(useCase.usePreFilter, isTrue);
    });
  });
}
