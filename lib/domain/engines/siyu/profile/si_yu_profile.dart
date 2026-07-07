import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/spec/si_yu_group_spec.dart';

class SiYuProfile {
  final String id, name;
  final CelestialCoordinateSystem coordinate;
  final Map<SiYuGroup, SiYuGroupSpec> groups;
  const SiYuProfile({required this.id, required this.name,
      required this.coordinate, required this.groups});
}
