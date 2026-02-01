import 'package:json_annotation/json_annotation.dart';

enum UIEnumPanelRing {
  @JsonValue("命主")
  PersonInfo("命主层", "安身立命基础信息，命主八字等"),
  @JsonValue("地支")
  DiZhi12Gong("地支宫", "十二地支宫，八卦，属性，琴堂派中的八字填实等"),
  @JsonValue("十二宫")
  TwelveGong("十二宫", "黄道十二宫名字，赤道十二星次"),
  @JsonValue("命理宫")
  DestinyGong("命理宫", "十二命理宫层"),
  @JsonValue("本命星轨")
  BasicTrack("本命星轨", "本命星盘，显示星耀运行的位置轨道"),
  @JsonValue("流年星轨")
  FateTrack("流年星轨", "流年星盘，显示星耀运行位置的轨道"),
  @JsonValue("星宿环")
  StarInn("星宿标度环", "显示星宿宿度的环"),
  @JsonValue("本命神煞")
  BasicShenSha("本命神煞", "显示本命神煞的环"),
  @JsonValue("流年")
  FateShenSha("流年神煞", "显示流年神煞");

  // TODO: 缺少洞微大限外围的年龄，以及自然年
  // TODO: 需要思考多种流年运限

  final String name;
  final String description;
  static List<UIEnumPanelRing> get moria => const [
        PersonInfo,
        DiZhi12Gong,
        TwelveGong,
        DestinyGong,
        FateTrack,
        StarInn,
        BasicTrack,
        FateShenSha,
        BasicShenSha
      ];

  const UIEnumPanelRing(this.name, this.description);
}
