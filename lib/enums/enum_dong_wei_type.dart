import 'package:json_annotation/json_annotation.dart';

enum DongWeiDaXianMingGongCountingType {
  // 命宫起点固定15度
  @JsonValue('hundredSix')
  HundredSix, // 子宫固定15年
  // 古代方式计算
  @JsonValue('Ancient')
  Ancient, // 0~3 度 11年 3~6 度 12年 6~9 度 13年 9~12 度 14年 12~15 度 15年 15~18 度 16年 18~21 度 17年 21~24 度 18年 24~27 度 19年 27~30 度 20年
  // 现代方式计算
  @JsonValue('Modern')
  Modern, // 以10年为基础 加太阳入宫度数转换为年 3°/12月 + 10年
}
