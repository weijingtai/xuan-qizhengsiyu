import 'package:qizhengsiyu/enums/enum_zi_qi_algorithm.dart';
import 'zi_qi_algorithm.dart';

/// 紫气算法管理器：按流派解析算法，并提供注册扩展点。
///
/// 扩展新流派：实现 ZiQiAlgorithm，然后 registry.register(新枚举值, 实例)。
class ZiQiAlgorithmRegistry {
  final Map<EnumZiQiAlgorithm, ZiQiAlgorithm> _map;

  ZiQiAlgorithmRegistry(Map<EnumZiQiAlgorithm, ZiQiAlgorithm> map)
      : _map = Map.of(map);

  ZiQiAlgorithm resolve(EnumZiQiAlgorithm which) =>
      _map[which] ?? _map[EnumZiQiAlgorithm.guoLaoQinTang]!;

  void register(EnumZiQiAlgorithm key, ZiQiAlgorithm algo) => _map[key] = algo;
}
