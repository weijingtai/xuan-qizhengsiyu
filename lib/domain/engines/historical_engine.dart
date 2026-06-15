import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/entities/models/star_position_raw_data.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';

import '../entities/models/panel_config.dart';
import '../entities/models/star_angle_raw_info.dart';
import 'i_calculation_engine.dart';

abstract interface class ISystemDefinitionSource {
  Future<ZhouTianModel> getSystemDefinition(String fileName);
}

/// “天赤道制”计算引擎。
///
/// 负责加载天赤道制的坐标系定义，并根据其特有的规则（查表、迭代）进行计算。
class HistoricalEngine implements ICalculationEngine {
  final ISystemDefinitionSource _systemDefinitionSource;
  final QiZhengHistoricalEphemerisRepository _ephemerisRepository;

  HistoricalEngine({
    required ISystemDefinitionSource systemDefinitionSource,
    required QiZhengHistoricalEphemerisRepository ephemerisRepository,
  })  : _systemDefinitionSource = systemDefinitionSource,
        _ephemerisRepository = ephemerisRepository;

  @override
  Future<ZhouTianModel> getSystemDefinition(BasePanelConfig config) {
    // For the historical engine, we always load the specific definition file.
    return _systemDefinitionSource.getSystemDefinition('tian_chi_dao_system.json');
  }

  @override
  Future<List<StarPositionRawData>> calculateStarPositions(
      DateTime birthDate, ObserverPosition position, BasePanelConfig config) async {
    final zhouTianModel = await getSystemDefinition(config);

    // 1. Load the sun speeds data
    final sunSpeeds = await _ephemerisRepository.loadHistoricalEphemeris();

    // 2. Find the start of the year (simplified)
    // TODO: This is a major simplification. A real implementation needs a robust solar term calculator.
    final year = birthDate.year;
    final zeroPointJieQiName = zhouTianModel.zeroPointJieQi.toString().split('.').last; // e.g., "DongZhi"
    // Assume DongZhi is always Dec 21st for this placeholder
    final startDate = DateTime(year - 1, 12, 21);

    // 3. Calculate elapsed days
    final difference = birthDate.difference(startDate);
    final elapsedDays = difference.inDays;

    // 4. Calculate position by accumulating daily speed
    double sunAngle = 0;
    for (int i = 0; i < elapsedDays; i++) {
      final currentDate = startDate.add(Duration(days: i));
      // TODO: This is also a simplification. We need to know the current solar term for each day.
      // For now, we'll just use the speed of the starting solar term.
      final dailySpeed = sunSpeeds[zeroPointJieQiName] as double;
      sunAngle += dailySpeed;
    }

    // 5. Normalize the angle
    sunAngle = sunAngle % zhouTianModel.totalDegree;

    final rawInfo = StarAngleRawInfo(
      panelSystemType: config.panelSystemType,
      coordinateSystem: config.celestialCoordinateSystem,
      angle: sunAngle,
      speed: sunSpeeds[zeroPointJieQiName] as double, // Placeholder speed
    );

    final sunPosition = StarPositionRawData(
      starType: EnumStars.Sun,
      angleRawInfoSet: {rawInfo},
    );

    // Return only the Sun's position for now
    return [sunPosition];
  }
}
