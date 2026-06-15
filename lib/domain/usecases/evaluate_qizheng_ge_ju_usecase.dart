import 'package:metaphysics_core/enums.dart';
import '../entities/models/base_panel_model.dart';
import '../entities/models/eleven_stars_info.dart';
import '../entities/models/ge_ju/ge_ju_result.dart';
import '../services/ge_ju_evaluation_service.dart';
import '../../enums/enum_panel_system_type.dart';

class EvaluateQiZhengGeJuUseCase {
  final GeJuEvaluationService geJuEvaluationService;

  EvaluateQiZhengGeJuUseCase({
    required this.geJuEvaluationService,
  });

  Future<GeJuEvaluationSummary> execute({
    required BasePanelModel panelModel,
    required Set<ElevenStarsInfo> starsSet,
    required DiZhi monthZhi,
    required JiaZi yearJiaZi,
    CelestialCoordinateSystem coordinateSystem =
        CelestialCoordinateSystem.Ecliptic,
    Set<String> preferredSchools = const {'guo_lao'},
    bool onlyMatched = false,
  }) async {
    return geJuEvaluationService.evaluateNatalChart(
      panelModel: panelModel,
      starsSet: starsSet,
      monthZhi: monthZhi,
      yearJiaZi: yearJiaZi,
      coordinateSystem: coordinateSystem,
      preferredSchools: preferredSchools,
      onlyMatched: onlyMatched,
    );
  }

  void invalidateCache() {
    geJuEvaluationService.invalidateRuleDataCache();
  }

  bool get usePreFilter => geJuEvaluationService.usePreFilter;

  set usePreFilter(bool value) {
    geJuEvaluationService.usePreFilter = value;
  }
}
