import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:common/models/year_month.dart';

enum EnumGongPositionType {
  @JsonValue("同宫")
  same("同宫"),
  @JsonValue("对宫")
  opposite("对宫"),
  @JsonValue("三方")
  trine("三方"),
  @JsonValue("四正")
  square("四正"),
  @JsonValue("同络")
  conjunct("同络"),
  @JsonValue("无关")
  none("无关");

  final String name;
  const EnumGongPositionType(this.name);
}

class DingStarModel {
  bool isObvious; // 是否为明顶，明顶需要是同宫的星体
  EnumStars star; // “顶”度的星体
  EnumTwelveGong gong; // 顶度 星体所在的宫位
  double atGongDegree; // 顶度 星体在宫位的角度

  DateTime timeAt; // 顶度时间
  YearMonth ageAt; // 顶度年龄

  EnumGongPositionType positionType;

  DingStarModel({
    required this.isObvious,
    required this.star,
    required this.gong,
    required this.atGongDegree,
    required this.timeAt,
    required this.ageAt,
    required this.positionType,
  });
}

class DaXianGongModel {
  int order;
  // 地支宫位
  EnumTwelveGong diZhiGong;
  // 命理宫
  EnumDestinyTwelveGong destinyGong;
  // 开始时间
  DateTime startTime;
  // 结束时间
  DateTime endTime;
  // 开始年龄
  YearMonth startAge;
  // 结束年龄
  YearMonth endAge;
  // 行限总时间
  YearMonth totalYearMonth;

  // 限宫内星体
  List<EnumStars> palaceStars;
  // 对宫
  List<EnumStars> aspectingStars; // 受照/对照

  // 三方四正关系星体, value是排列好的
  Map<EnumTwelveGong, List<EnumStars>> trineStars; // 三方星体

  Map<EnumTwelveGong, List<EnumStars>> squareStars; // 四正星体

  // 受照、对照、同络星体
  Map<EnumTwelveGong, List<EnumStars>> conjunctStars; // 同络

  // 顺序为 顺黄道0->359°，即星盘中“逆时针方向”
  // List<ConstellationDegree> contiansConstellations;

  DaXianGongModel({
    required this.order,
    required this.diZhiGong,
    required this.destinyGong,
    required this.startTime,
    required this.endTime,
    required this.startAge,
    required this.endAge,
    required this.totalYearMonth,
    required this.palaceStars,
    required this.aspectingStars,
    required this.trineStars,
    required this.squareStars,
    required this.conjunctStars,
    // required this.contiansConstellations,
  });
}

class DaXianStarConstellationModel {
  int order;
  // 星宿
  Enum28Constellations constellation;

  // 二十八星宿存在“跨宫”的情况，由于不同“宫“行限的时长不同，所以一个星宿中
  // 可能会有不同的”行限时长“
  EnumTwelveGong partAtGong;
  YearMonth gongTotalYearMonth;

  // 开始时间
  DateTime startTime;
  // 结束时间
  DateTime endTime;
  // 开始年龄
  YearMonth startAge;
  // 结束年龄
  YearMonth endAge;
  // 行限总时间
  YearMonth totalYearMonth;

  // 宿内星体，在不同宫内的星宿，当前值需要是相同的
  List<EnumStars> mansionStars;

  // 同经星体
  Map<Enum28Constellations, List<EnumStars>> sameLongitudeStars;

  DaXianStarConstellationModel({
    required this.order,
    required this.constellation,
    required this.startTime,
    required this.endTime,
    required this.startAge,
    required this.endAge,
    required this.totalYearMonth,
    required this.mansionStars,
    required this.sameLongitudeStars,
    required this.partAtGong,
    required this.gongTotalYearMonth,
  });
}
