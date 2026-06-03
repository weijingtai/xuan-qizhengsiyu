import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

EnumTwelveGong movePalace(EnumTwelveGong palace, int offset) {
  return EnumTwelveGong.values[((palace.index + offset) % 12 + 12) % 12];
}

int forwardDistance(EnumTwelveGong from, EnumTwelveGong to) {
  return (to.index - from.index + 12) % 12;
}
