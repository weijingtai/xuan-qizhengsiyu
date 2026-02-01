import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../enums/enum_stars_four_type.dart';


part 'stars_four_relationship.g.dart';

@JsonSerializable()
class StarsFourRelationship {
  final EnumStars star;
  final String className; // 派别类型

  final Map<EnumStarsFourType, Set<EnumStars>> fourRelationshipMapper;
  const StarsFourRelationship(
      this.star, this.className, this.fourRelationshipMapper);

  factory StarsFourRelationship.fromJson(Map<String, dynamic> json) =>
      _$StarsFourRelationshipFromJson(json);

  Map<String, dynamic> toJson() => _$StarsFourRelationshipToJson(this);
}
