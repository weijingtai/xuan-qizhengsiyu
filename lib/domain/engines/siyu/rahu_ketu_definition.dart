import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';

/// 罗睺、计都各自的黄经。
class RahuKetuLongitudes {
  final double luo; // 罗睺
  final double ji;  // 计都
  const RahuKetuLongitudes({required this.luo, required this.ji});
}

/// 罗计升降交点归属「定义层」——全模块最易写反之处，隔离成纯函数并由单测锁死。
///
/// ⚠️ 旧法（默认）= 罗睺取降交点、计都取升交点，与印度/西占惯例相反。
/// 切勿凭直觉改动，改动前先看 test/domain/engines/siyu/rahu_ketu_definition_test.dart。
class RahuKetuDefinition {
  const RahuKetuDefinition._();

  /// [northNode]：月球平升交点黄经（sweph SE_MEAN_NODE 输出）。
  static RahuKetuLongitudes assign({
    required double northNode,
    required EnumRahuKetuConvention convention,
  }) {
    final asc = _normalize360(northNode);        // 升交点
    final desc = _normalize360(northNode + 180); // 降交点
    switch (convention) {
      case EnumRahuKetuConvention.luoJiangJiSheng: // 旧法：罗=降, 计=升
        return RahuKetuLongitudes(luo: desc, ji: asc);
      case EnumRahuKetuConvention.luoShengJiJiang: // 新法：罗=升, 计=降
        return RahuKetuLongitudes(luo: asc, ji: desc);
    }
  }

  static double _normalize360(double d) {
    var r = d % 360;
    if (r < 0) r += 360;
    return r;
  }
}
