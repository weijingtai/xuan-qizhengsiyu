import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../enums/four_season_relationship_type.dart';

part 'four_season_model.g.dart';

@JsonSerializable()
class StarAndReason {
  final EnumStars star;
  final List<String> reason;
  const StarAndReason(this.star, this.reason);

  factory StarAndReason.fromJson(Map<String, dynamic> json) =>
      _$StarAndReasonFromJson(json);

  Map<String, dynamic> toJson() => _$StarAndReasonToJson(this);
}

@JsonSerializable()
class FourSeasonStar {
  final EnumStars star;
  final Map<FourSeasons, Map<FourSeasonRelationshipType, Set<StarAndReason>>>
      fourSeasonRelationshipMapper;
  const FourSeasonStar(this.star, this.fourSeasonRelationshipMapper);

  factory FourSeasonStar.fromJson(Map<String, dynamic> json) =>
      _$FourSeasonStarFromJson(json);

  Map<String, dynamic> toJson() => _$FourSeasonStarToJson(this);
}
