import 'package:metaphysics_core/enums.dart';

enum SiYuGroup { luoJi, yueBo, ziQi }

/// 四余算法组统一策略：一次产出本组所有星的位置(度，坐标框架由算法自持)。
abstract interface class SiYuGroupAlgorithm {
  String get id;
  Set<EnumStars> get bodies;
  Map<EnumStars, double> computePositions({
    required double julianDay,
    required DateTime datetime,
  });
}
