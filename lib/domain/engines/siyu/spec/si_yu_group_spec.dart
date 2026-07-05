import 'package:json_annotation/json_annotation.dart';

part 'si_yu_group_spec.g.dart';

@JsonSerializable(explicitToJson: true)
class SiYuGroupSpec {
  final String kind;
  final Map<String, double> params;
  final List<SiYuSegmentSpec>? segments;
  final int? rahuKetuConventionIndex;
  const SiYuGroupSpec({required this.kind, this.params = const {},
      this.segments, this.rahuKetuConventionIndex});
  factory SiYuGroupSpec.fromJson(Map<String, dynamic> j) => _$SiYuGroupSpecFromJson(j);
  Map<String, dynamic> toJson() => _$SiYuGroupSpecToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SiYuSegmentSpec {
  final double fromJulianDay;
  final SiYuGroupSpec spec;
  const SiYuSegmentSpec({required this.fromJulianDay, required this.spec});
  factory SiYuSegmentSpec.fromJson(Map<String, dynamic> j) => _$SiYuSegmentSpecFromJson(j);
  Map<String, dynamic> toJson() => _$SiYuSegmentSpecToJson(this);
}
