import 'package:common/enums.dart';
import 'package:common/utils/collections_utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tuple/tuple.dart';

part 'enum_qi_zheng.g.dart';

enum FiveStarWalkingType {
  // 逆、留、迟、常、速 （星体完整的运动规律顺序）
  // 逆、留、迟、常、速、常、迟、留、逆
  // 迟留速逆顺

  @JsonValue("速")
  Fast("速"),
  @JsonValue("常")
  Normal("常"),
  @JsonValue("迟")
  Slow("迟"),
  @JsonValue("留")
  Stay("留"),
  @JsonValue("逆")
  Retrograde("逆");

  final String name;
  const FiveStarWalkingType(this.name);

  static List<FiveStarWalkingType> fullForwardList(
      List<FiveStarWalkingType> without) {
    List<FiveStarWalkingType> result = [
      Retrograde,
      Stay,
      Slow,
      Normal,
      Fast,
      Normal,
      Slow,
      Stay
    ];
    if (without.isNotEmpty) {
      // result.removeWhere((r)=>without.contains(r));
      if (without.length == 1) {
        // 金星没有速行，所以只有一个“常行”
        return [Retrograde, Stay, Slow, Normal, Slow, Stay];
      } else {
        // 土星，没有速，及 迟
        [Retrograde, Stay, Normal, Stay];
      }
    }
    return result;
  }

  static List<FiveStarWalkingType> changeFirst(
      FiveStarWalkingType first, List<FiveStarWalkingType> list) {
    return CollectUtils.changeSeq(first, list);
    if (list.first == first) {
      return list;
    } else {
      int currentAtIndex = list.indexOf(first);
      // return [...list.sublist(currentAtIndex-1),...list.sublist(0,currentAtIndex)];
      // 逆、留、迟、常、速、常、迟、留
      // 常、速、常、迟、留、逆、留、迟、
      return [
        ...list.sublist(currentAtIndex),
        ...list.sublist(0, currentAtIndex)
      ];
    }
  }

  static List<FiveStarWalkingType> reverseToPreviousListAndChangeFirst(
      FiveStarWalkingType first, List<FiveStarWalkingType> list) {
    return CollectUtils.changeSeq(first, list, isReversed: true);
    // List<FiveStarWalkingType> result = list;
    // if (list.first != first) {
    //   int currentAtIndex = list.indexOf(first);
    //   // return [...list.sublist(currentAtIndex-1),...list.sublist(0,currentAtIndex)];
    //   // 逆、留、迟、常、速、常、迟、留
    //   // 常、速、常、迟、留、逆、留、迟、
    //   result = [
    //     ...list.sublist(currentAtIndex),
    //     ...list.sublist(0, currentAtIndex)
    //   ];
    // }
    // return [result.first, ...result.sublist(1).reversed];
  }

  // # moira 中
  // #   火星迟行 速度节点为“0.409” 大于时为正常速度，小于时为迟行
  // #   火星疾行 速度节点为“0.706” 大于时为疾行速度，小于时为正常
  // #   火星留行 速度节点为“0.074” 小于时开始成为“留行”
  // #  火星逆行节点 -0.077°
  // #   火星最快 0.778°/天  最慢 -0.386°/天
  //
  // #   金星疾行 没有疾行
  // #   金星迟行、常速 速度节点为“0.709” 大于时为正常速度，小于时为迟行
  // #   --金星留行 速度节点为“0.731” 小于时开始成为“留行”-- 有误
  // #   金星迟、留行节点 0.103°/天
  // #  金星逆行节点 -0.115°/天
  // #   金星最快 1.238°/天  最慢-0.613°/天
  //
  // #   木星迟行 速度节点为“0.048” 大于时为正常速度，小于时为迟行
  // #   木星疾行 0.23°/天 大于时为疾行速度，小于时为正常
  // #   木星留行 速度节点为“0.011” 小于时开始成为“留行”
  // # 木星逆行节点 -0.022°/天
  // #   木星最快  0.236°/天  最慢-0.134°/天
  //
  // # 水星 最快  2.2°/天   最慢 -1.348°/天【常】
  // #   水星迟行 速度节点为“0.868” 大于时为正常速度，小于时为迟行
  // #   水星疾行 速度节点"1.499",大于时为疾行速度，小于时为正常
  // #   水星留行 速度节点"0.129",大 小于时开始成为“留行”
  // # 水星逆行 -0.089°/天
  //
  // # 土星 最快  0.122°/天  最慢 -0.075°/天
  // #  土星没有迟与疾
  // #   土星留行 速度节点"0.019",大 小于时开始成为“留行”
  // #   土星逆行 节点-0.012°/天

  // tuple6.item1 最快速度，item2 逆行最快，item3 逆行，item4 留行，item5疾行，item6 迟行
  static Map<EnumStars,
          Tuple6<double, double, double, double, double?, double?>>
      moirasFiveStartsMapper = {
    EnumStars.Mars: const Tuple6(0.778, -0.386, -0.077, 0.074, 0.706, 0.409),
    EnumStars.Venus: const Tuple6(1.238, -0.613, -0.115, 0.103, null, 0.709),
    EnumStars.Jupiter: const Tuple6(0.236, -0.134, 0.022, 0.011, 0.23, 0.048),
    EnumStars.Mercury: const Tuple6(2.2, -1.348, -0.089, 0.129, 1.499, 0.868),
    EnumStars.Saturn: const Tuple6(0.122, -0.075, -0.012, 0.019, null, null),
  };
}

@JsonSerializable()
class StarWalkingTypeThreshold {
  final EnumStars star;
  // 阈值使用的参数  当前多为moira
  final String thresholdName;
  final double maxSpeed; // 最快
  final double maxRetrogradeThreshold; //最大逆行速度
  final double retrogradeThreshold; // 逆行

  final double stayThreshold; // 留行
  final double? fastThreshold; // 疾行
  final double? slowThreshold; // 迟行

  StarWalkingTypeThreshold({
    required this.star,
    required this.thresholdName,
    required this.maxSpeed,
    required this.maxRetrogradeThreshold,
    required this.retrogradeThreshold,
    required this.stayThreshold,
    required this.fastThreshold,
    required this.slowThreshold,
  });

  // EnumStars.Mars: const Tuple6(0.778, -0.386, -0.077, 0.074, 0.706, 0.409),
  // EnumStars.Venus: const Tuple6(1.238, -0.613, -0.115, 0.103, null, 0.709),
  // EnumStars.Jupiter: const Tuple6(0.236, -0.134, 0.022, 0.011, 0.23, 0.048),
  // EnumStars.Mercury: const Tuple6(2.2, -1.348, -0.089, 0.129, 1.499, 0.868),
  // EnumStars.Saturn: const Tuple6(0.122, -0.075, -0.012, 0.019, null, null),

  static Map<EnumStars, StarWalkingTypeThreshold>
      moirasFiveStarsThresholdMapper = {
    EnumStars.Mars: StarWalkingTypeThreshold(
      star: EnumStars.Mars,
      thresholdName: "moira",
      maxSpeed: 0.778,
      maxRetrogradeThreshold: -0.386,
      retrogradeThreshold: -0.077,
      stayThreshold: 0.074,
      fastThreshold: 0.706,
      slowThreshold: 0.409,
    ),
    EnumStars.Venus: StarWalkingTypeThreshold(
      star: EnumStars.Venus,
      thresholdName: "moira",
      maxSpeed: 1.238,
      maxRetrogradeThreshold: -0.613,
      retrogradeThreshold: -0.115,
      stayThreshold: 0.103,
      fastThreshold: null,
      slowThreshold: 0.709,
    ),
    EnumStars.Jupiter: StarWalkingTypeThreshold(
      star: EnumStars.Jupiter,
      thresholdName: "moira",
      maxSpeed: 0.236,
      maxRetrogradeThreshold: -0.134,
      retrogradeThreshold: 0.022,
      stayThreshold: 0.011,
      fastThreshold: 0.23,
      slowThreshold: 0.048,
    ),
    EnumStars.Mercury: StarWalkingTypeThreshold(
      star: EnumStars.Mercury,
      thresholdName: "moira",
      maxSpeed: 2.2,
      maxRetrogradeThreshold: -1.348,
      retrogradeThreshold: -0.089,
      stayThreshold: 0.129,
      fastThreshold: 1.499,
      slowThreshold: 0.868,
    ),
    EnumStars.Saturn: StarWalkingTypeThreshold(
      star: EnumStars.Saturn,
      thresholdName: "moira",
      maxSpeed: 0.122,
      maxRetrogradeThreshold: -0.075,
      retrogradeThreshold: -0.012,
      stayThreshold: 0.019,
      fastThreshold: null,
      slowThreshold: null,
    ),
  };

  factory StarWalkingTypeThreshold.fromJson(Map<String, dynamic> json) =>
      _$StarWalkingTypeThresholdFromJson(json);
  Map<String, dynamic> toJson() => _$StarWalkingTypeThresholdToJson(this);
}
