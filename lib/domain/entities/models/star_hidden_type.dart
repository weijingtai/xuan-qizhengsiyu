class StarHiddenType {
  /// 星体在太阳周围时判断的方式
  /// 如：1. 果老星宗中认为星耀与太阳同宫尤其是在距离6度内被视为“伏藏”名为，日晦星微
  ///     2. 天官派《乾元秘旨》中 太阳所爱宫位3度范围内出现主星，则星职被太压根接管。叫做阳夺星权

  // key 是最小度数
  final Map<int, String> starHiddenDegreeMapper;
  final String name;
  final String source;
  final List<String> descriptionList;
  final bool requiredInSameGong;
  StarHiddenType(
      {required this.name,
      required this.source,
      required this.descriptionList,
      required this.starHiddenDegreeMapper,
      required this.requiredInSameGong});

  final StarHiddenType guoLao = StarHiddenType(
      name: "日晦星微",
      requiredInSameGong: true,
      source: "果老星宗",
      descriptionList: [
        "明确提出「日晦星微」理论：任何星曜与太阳同宫（尤其是距离6度以内），均被视作伏藏（古称「晦朔遇星」）。",
        "判定标准：昼生人太阳强势：同宫星曜力量被压制90%以上（如金星伴日反成「熔金」之凶）夜生人稍减：压制约60%，但计都、罗睺等余星伏藏时反有特殊用法"
      ],
      starHiddenDegreeMapper: {
        6: "日晦星微"
      });
  final StarHiddenType tianGuan = StarHiddenType(
      name: "阳夺星权",
      requiredInSameGong: true,
      source: "乾元秘旨",
      descriptionList: [
        "发展出「阳夺星权」法则：太阳所在宫位3度范围内出现主星，则该星职能被太阳接管（如太阳与紫气同宫，宗教缘分会转向太阳代表的父系/权威路径）"
      ],
      starHiddenDegreeMapper: {
        3: "阳夺星权"
      });
  // 港台传承
  final StarHiddenType modenGangTai = StarHiddenType(
      name: "伏藏应事",
      requiredInSameGong: true,
      source: "港台传承派",
      descriptionList: [
        "严格遵循「日周天15度伏藏区」：在推演流年星盘时，若流曜进入当年太阳所在宫位的15度范围，即按「伏藏应事」断吉凶"
      ],
      starHiddenDegreeMapper: {
        15: "伏藏应事"
      });

  // 大陆
  final StarHiddenType modernMotherLand = StarHiddenType(
      name: "日照星辉",
      requiredInSameGong: true,
      source: "大陆新派",
      descriptionList: [
        "弱化伏藏概念，改用「日照星辉」分级制（如1-3度「灼伤」、3-6度「半伏」、6-10度「余光」）",
        "在择日术中保留应用：手术择日避开水星伏藏期（防止信息误判），科举考试则选木星伏藏日（压制竞争者）"
      ],
      starHiddenDegreeMapper: {
        3: "灼伤",
        6: "半伏",
        10: "余光"
      });
}
