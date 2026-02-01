import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

class DiZhiGongInfo {
  EnumTwelveGong diZhiGong;
  String diZhiGongName;
  Map<EnumTwelveGong, double> gongDegreeMapper;
  DiZhiGongInfo({
    required this.diZhiGong,
    required this.diZhiGongName,
    required this.gongDegreeMapper,
  });
  static Map<EnumTwelveGong, double> zodicMapper = {
    EnumTwelveGong.Zi: 30.0,
    EnumTwelveGong.Chou: 30.0,
    EnumTwelveGong.Yin: 30.0,
    EnumTwelveGong.Mao: 30.0,
    EnumTwelveGong.Chen: 30.0,
    EnumTwelveGong.Si: 30.0,
    EnumTwelveGong.Wu: 30.0,
    EnumTwelveGong.Wei: 30.0,
    EnumTwelveGong.Shen: 30.0,
    EnumTwelveGong.You: 30.0,
    EnumTwelveGong.Xu: 30.0,
    EnumTwelveGong.Hai: 30.0,
  };

  // 赤道十二宫等分 365.25°，每宫 30.4375 ≈ 30.44°
  static Map<EnumTwelveGong, double> equatorialEqualMapper = {
    EnumTwelveGong.Zi: 30.44,
    EnumTwelveGong.Chou: 30.44,
    EnumTwelveGong.Yin: 30.44,
    EnumTwelveGong.Mao: 30.44,
    EnumTwelveGong.Chen: 30.44,
    EnumTwelveGong.Si: 30.44,
    EnumTwelveGong.Wu: 30.44,
    EnumTwelveGong.Wei: 30.44,
    EnumTwelveGong.Shen: 30.44,
    EnumTwelveGong.You: 30.44,
    EnumTwelveGong.Xu: 30.44,
    EnumTwelveGong.Hai: 30.44,
  };
  // 赤道十二宫，午未分法
  static Map<EnumTwelveGong, double> equatorialWuWeiMapper = {
    EnumTwelveGong.Zi: 30.0,
    EnumTwelveGong.Chou: 30.0,
    EnumTwelveGong.Yin: 30.0,
    EnumTwelveGong.Mao: 30.0,
    EnumTwelveGong.Chen: 30.0,
    EnumTwelveGong.Si: 30.0,
    EnumTwelveGong.Wu: 32.6,
    EnumTwelveGong.Wei: 32.6,
    EnumTwelveGong.Shen: 30.0,
    EnumTwelveGong.You: 30.0,
    EnumTwelveGong.Xu: 30.0,
    EnumTwelveGong.Hai: 30.0,
  };

  // 赤道十二宫，子午卯酉分法
  static Map<EnumTwelveGong, double> equatorialFourZhengMapper = {
    EnumTwelveGong.Zi: 31.3,
    EnumTwelveGong.Chou: 30.0,
    EnumTwelveGong.Yin: 30.0,
    EnumTwelveGong.Mao: 31.3,
    EnumTwelveGong.Chen: 30.0,
    EnumTwelveGong.Si: 30.0,
    EnumTwelveGong.Wu: 31.3,
    EnumTwelveGong.Wei: 30.0,
    EnumTwelveGong.Shen: 30.0,
    EnumTwelveGong.You: 31.3,
    EnumTwelveGong.Xu: 30.0,
    EnumTwelveGong.Hai: 30.0,
  };
}
