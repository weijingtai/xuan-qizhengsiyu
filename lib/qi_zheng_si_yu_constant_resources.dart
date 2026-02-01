import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart'; // 使用domain层的模型

import 'enums/enum_qi_zheng.dart';
import 'enums/enum_twelve_gong.dart';
import 'domain/entities/models/star_inn_gong_degree.dart'; // 使用domain层的模型

const EightGua_NaJia_Gong = {
  "乾": EnumTwelveGong.Hai,
  "坎": EnumTwelveGong.Zi,
  "艮": EnumTwelveGong.Yin,
  "震": EnumTwelveGong.Mao,
  "巽": EnumTwelveGong.Si,
  "离": EnumTwelveGong.Wu,
  "坤": EnumTwelveGong.Shen,
  "兑": EnumTwelveGong.You,
};

class QiZhengSiYuConstantResources {
  // 古宿，黄道回归，未矫正
  // 黄道回归 古宿
  @JsonValue("黄道回归制古宿")
  static final Map<Enum28Constellations, ConstellationGongDegreeInfo>
      ZodiacTropicalOriginalClassicStarsInnSystemMapper = {
    Enum28Constellations.Lou_Jin_Gou: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Lou_Jin_Gou,
        degreeStartAt: 15.9,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Xu, degree: 15.9),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Xu, degree: 26.3),
        totalDegree: 10.4),
    Enum28Constellations.Wei_Tu_Zhi: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Wei_Tu_Zhi,
        degreeStartAt: 26.3,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Xu, degree: 26.3),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 11.1),
        totalDegree: 14.8),
    Enum28Constellations.Mao_Ri_Ji: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Mao_Ri_Ji,
        degreeStartAt: 41.1,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 11.1),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 23.2),
        totalDegree: 12.1),
    Enum28Constellations.Bi_Yue_Wu: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Bi_Yue_Wu,
        degreeStartAt: 53.2,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 23.2),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 9),
        totalDegree: 15.8),
    Enum28Constellations.Zi_Huo_Hou: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Zi_Huo_Hou,
        degreeStartAt: 69,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 9),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 10),
        totalDegree: 1),
    Enum28Constellations.Shen_Shui_Yuan: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Shen_Shui_Yuan,
        degreeStartAt: 70,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 10),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 21.8),
        totalDegree: 11.8),
    Enum28Constellations.Jing_Mu_Han: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Jing_Mu_Han,
        degreeStartAt: 81.8,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 21.8),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Wei, degree: 22.3),
        totalDegree: 30.5),
    Enum28Constellations.Gui_Jin_Yang: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Gui_Jin_Yang,
        degreeStartAt: 112.3,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Wei, degree: 22.3),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Wei, degree: 25.2),
        totalDegree: 2.9),
    Enum28Constellations.Liu_Tu_Zhang: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Liu_Tu_Zhang,
        degreeStartAt: 115.2,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Wei, degree: 25.2),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 10.5),
        totalDegree: 15.3),
    Enum28Constellations.Xing_Ri_Ma: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Xing_Ri_Ma,
        degreeStartAt: 130.5,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 10.5),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 16.4),
        totalDegree: 5.9),
    Enum28Constellations.Zhang_Yue_Lu: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Zhang_Yue_Lu,
        degreeStartAt: 136.4,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 16.4),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Si, degree: 1.4),
        totalDegree: 15),
    Enum28Constellations.Yi_Huo_She: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Yi_Huo_She,
        degreeStartAt: 151.4,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Si, degree: 1.4),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Si, degree: 20.1),
        totalDegree: 18.7),
    Enum28Constellations.Zhen_Shui_Yin: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Zhen_Shui_Yin,
        degreeStartAt: 170.1,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Si, degree: 20.1),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 7.2),
        totalDegree: 17.1),
    Enum28Constellations.Jiao_Mu_Jiao: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Jiao_Mu_Jiao,
        degreeStartAt: 187.2,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 7.2),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 20),
        totalDegree: 12.8),
    Enum28Constellations.Kang_Jin_Long: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Kang_Jin_Long,
        degreeStartAt: 200,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 20),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 28.9),
        totalDegree: 8.9),
    Enum28Constellations.Di_Tu_Lu: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Di_Tu_Lu,
        degreeStartAt: 208.9,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 28.9),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 15.2),
        totalDegree: 16.3),
    Enum28Constellations.Fang_Ri_Tu: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Fang_Ri_Tu,
        degreeStartAt: 225.2,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 15.2),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 20.6),
        totalDegree: 5.4),
    Enum28Constellations.Xin_Yue_Hu: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Xin_Yue_Hu,
        degreeStartAt: 230.6,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 20.6),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 27),
        totalDegree: 6.4),
    Enum28Constellations.Wei_Huo_Hu: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Wei_Huo_Hu,
        degreeStartAt: 237,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 27),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Yin, degree: 15.6),
        totalDegree: 18.6),
    Enum28Constellations.Ji_Shui_Bao: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Ji_Shui_Bao,
        degreeStartAt: 255.6,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Yin, degree: 15.6),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Yin, degree: 26.3),
        totalDegree: 10.7),
    Enum28Constellations.Dou_Mu_Xie: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Dou_Mu_Xie,
        degreeStartAt: 266.3,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Yin, degree: 26.3),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chou, degree: 20.1),
        totalDegree: 23.8),
    Enum28Constellations.Niu_Jin_Niu: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Niu_Jin_Niu,
        degreeStartAt: 290.1,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chou, degree: 20.1),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chou, degree: 28),
        totalDegree: 7.9),
    Enum28Constellations.Nv_Tu_Fu: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Nv_Tu_Fu,
        degreeStartAt: 298,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chou, degree: 28),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 8.9),
        totalDegree: 10.9),
    Enum28Constellations.Xu_Ri_Shu: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Xu_Ri_Shu,
        degreeStartAt: 308.9,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 8.9),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 18.3),
        totalDegree: 9.4),
    Enum28Constellations.Wei_Yue_Yan: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Wei_Yue_Yan,
        degreeStartAt: 318.3,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 18.3),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 3.6),
        totalDegree: 15.3),
    Enum28Constellations.Shi_Huo_Zhu: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Shi_Huo_Zhu,
        degreeStartAt: 333.6,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 3.6),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 19.4),
        totalDegree: 15.8),
    Enum28Constellations.Bi_Shui_Yu: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Bi_Shui_Yu,
        degreeStartAt: 349.4,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 19.4),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 28.3),
        totalDegree: 8.9),
    Enum28Constellations.Kui_Mu_Lang: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Kui_Mu_Lang,
        degreeStartAt: 358.3,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 28.3),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Xu, degree: 15.9),
        totalDegree: 17.6),
  };

  // 古宿，矫正，黄道回归制，相比较 原始《郑氏星案》偏移14.098° 这里取 14°
  // 然后就是校正古宿制，在古宿下面，勾选岁差校正，即得此制。采用黄道回归制（七政四余制）下，以太阳春分点为坐标零点（戌宫0点，黄经0度）
  // 黄道回归 古宿矫正
  @JsonValue("黄道回归制古宿矫正")
  static final Map<Enum28Constellations, ConstellationGongDegreeInfo>
      ZodiacTropicalCorrectedClassicStarsInnSystemMapper = {
    Enum28Constellations.Bi_Shui_Yu: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Bi_Shui_Yu,
        degreeStartAt: 3.50,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Xu, degree: 3.50),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Xu, degree: 12.40),
        totalDegree: 8.90),
    Enum28Constellations.Kui_Mu_Lang: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Kui_Mu_Lang,
        degreeStartAt: 12.40,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Xu, degree: 12.40),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 0.00),
        totalDegree: 17.60),
    Enum28Constellations.Lou_Jin_Gou: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Lou_Jin_Gou,
        degreeStartAt: 30.00,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 0.00),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 10.40),
        totalDegree: 10.40),
    Enum28Constellations.Wei_Tu_Zhi: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Wei_Tu_Zhi,
        degreeStartAt: 40.40,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 10.40),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 25.20),
        totalDegree: 14.80),
    Enum28Constellations.Mao_Ri_Ji: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Mao_Ri_Ji,
        degreeStartAt: 55.20,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 25.20),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 7.30),
        totalDegree: 12.10),
    Enum28Constellations.Bi_Yue_Wu: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Bi_Yue_Wu,
        degreeStartAt: 67.30,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 7.30),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 23.10),
        totalDegree: 15.80),
    Enum28Constellations.Zi_Huo_Hou: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Zi_Huo_Hou,
        degreeStartAt: 83.10,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 23.10),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 24.10),
        totalDegree: 1.00),
    Enum28Constellations.Shen_Shui_Yuan: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Shen_Shui_Yuan,
        degreeStartAt: 84.10,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 24.10),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Wei, degree: 5.90),
        totalDegree: 11.80),
    Enum28Constellations.Jing_Mu_Han: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Jing_Mu_Han,
        degreeStartAt: 95.90,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Wei, degree: 5.90),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 6.40),
        totalDegree: 30.50),
    Enum28Constellations.Gui_Jin_Yang: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Gui_Jin_Yang,
        degreeStartAt: 126.40,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 6.40),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 9.30),
        totalDegree: 2.90),
    Enum28Constellations.Liu_Tu_Zhang: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Liu_Tu_Zhang,
        degreeStartAt: 129.30,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 9.30),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 24.60),
        totalDegree: 15.30),
    Enum28Constellations.Xing_Ri_Ma: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Xing_Ri_Ma,
        degreeStartAt: 144.60,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 24.60),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Si, degree: 0.50),
        totalDegree: 5.90),
    Enum28Constellations.Zhang_Yue_Lu: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Zhang_Yue_Lu,
        degreeStartAt: 150.50,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Si, degree: 0.50),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Si, degree: 15.50),
        totalDegree: 15.00),
    Enum28Constellations.Yi_Huo_She: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Yi_Huo_She,
        degreeStartAt: 165.50,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Si, degree: 15.50),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 4.20),
        totalDegree: 18.70),
    Enum28Constellations.Zhen_Shui_Yin: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Zhen_Shui_Yin,
        degreeStartAt: 184.20,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 4.20),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 21.30),
        totalDegree: 17.10),
    Enum28Constellations.Jiao_Mu_Jiao: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Jiao_Mu_Jiao,
        degreeStartAt: 201.30,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 21.30),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 4.10),
        totalDegree: 12.80),
    Enum28Constellations.Kang_Jin_Long: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Kang_Jin_Long,
        degreeStartAt: 214.10,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 4.10),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 13.00),
        totalDegree: 8.90),
    Enum28Constellations.Di_Tu_Lu: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Di_Tu_Lu,
        degreeStartAt: 223.00,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 13.00),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 29.30),
        totalDegree: 16.30),
    Enum28Constellations.Fang_Ri_Tu: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Fang_Ri_Tu,
        degreeStartAt: 239.30,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 29.30),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Yin, degree: 4.70),
        totalDegree: 5.40),
    Enum28Constellations.Xin_Yue_Hu: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Xin_Yue_Hu,
        degreeStartAt: 244.70,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Yin, degree: 4.70),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Yin, degree: 11.10),
        totalDegree: 6.40),
    Enum28Constellations.Wei_Huo_Hu: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Wei_Huo_Hu,
        degreeStartAt: 251.10,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Yin, degree: 11.10),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Yin, degree: 29.70),
        totalDegree: 18.60),
    Enum28Constellations.Ji_Shui_Bao: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Ji_Shui_Bao,
        degreeStartAt: 269.70,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Yin, degree: 29.70),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chou, degree: 10.40),
        totalDegree: 10.70),
    Enum28Constellations.Dou_Mu_Xie: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Dou_Mu_Xie,
        degreeStartAt: 280.40,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chou, degree: 10.40),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 4.20),
        totalDegree: 23.80),
    Enum28Constellations.Niu_Jin_Niu: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Niu_Jin_Niu,
        degreeStartAt: 304.20,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 4.20),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 12.10),
        totalDegree: 7.90),
    Enum28Constellations.Nv_Tu_Fu: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Nv_Tu_Fu,
        degreeStartAt: 312.10,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 12.10),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 23.00),
        totalDegree: 10.90),
    Enum28Constellations.Xu_Ri_Shu: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Xu_Ri_Shu,
        degreeStartAt: 323.00,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 23.00),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 2.40),
        totalDegree: 9.40),
    Enum28Constellations.Wei_Yue_Yan: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Wei_Yue_Yan,
        degreeStartAt: 332.40,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 2.40),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 17.70),
        totalDegree: 15.30),
    Enum28Constellations.Shi_Huo_Zhu: ConstellationGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: Enum28Constellations.Shi_Huo_Zhu,
        degreeStartAt: 347.70,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 17.70),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Xu, degree: 3.50),
        totalDegree: 15.80),
  };

  // 今宿 2024-01-01 为基准时间
  // 黄道回归 今宿
  @JsonValue("黄道回归制今宿")
  static final Map<Enum28Constellations, ConstellationGongDegreeInfo>
      ZodiacTropicalModernStarsInnSystemMapper = {
    Enum28Constellations.Bi_Shui_Yu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Bi_Shui_Yu,
        degreeStartAt: 10.59,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Xu, degree: 10.59),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Xu, degree: 22.81),
        totalDegree: 12.22),
    Enum28Constellations.Kui_Mu_Lang: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Kui_Mu_Lang,
        degreeStartAt: 22.81,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Xu, degree: 22.81),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 4.33),
        totalDegree: 11.52),
    Enum28Constellations.Lou_Jin_Gou: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Lou_Jin_Gou,
        degreeStartAt: 34.33,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 4.33),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 17.30),
        totalDegree: 12.97),
    Enum28Constellations.Wei_Tu_Zhi: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Wei_Tu_Zhi,
        degreeStartAt: 47.30,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 17.30),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 29.78),
        totalDegree: 12.48),
    Enum28Constellations.Mao_Ri_Ji: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Mao_Ri_Ji,
        degreeStartAt: 59.78,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 29.78),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 8.85),
        totalDegree: 9.07),
    Enum28Constellations.Bi_Yue_Wu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Bi_Yue_Wu,
        degreeStartAt: 68.85,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 8.85),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 24.05),
        totalDegree: 15.20),
    Enum28Constellations.Zi_Huo_Hou: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Zi_Huo_Hou,
        degreeStartAt: 84.05,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 24.05),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 25.05),
        totalDegree: 1.00),
    Enum28Constellations.Shen_Shui_Yuan: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Shen_Shui_Yuan,
        degreeStartAt: 85.05,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 25.05),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Wei, degree: 5.66),
        totalDegree: 10.62),
    Enum28Constellations.Jing_Mu_Han: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Jing_Mu_Han,
        degreeStartAt: 95.66,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Wei, degree: 5.66),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 6.11),
        totalDegree: 30.45),
    Enum28Constellations.Gui_Jin_Yang: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Gui_Jin_Yang,
        degreeStartAt: 126.11,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 6.11),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 11.10),
        totalDegree: 4.99),
    Enum28Constellations.Liu_Tu_Zhang: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Liu_Tu_Zhang,
        degreeStartAt: 131.10,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 11.10),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 27.08),
        totalDegree: 15.98),
    Enum28Constellations.Xing_Ri_Ma: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Xing_Ri_Ma,
        degreeStartAt: 147.08,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 27.08),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Si, degree: 5.08),
        totalDegree: 7.99),
    Enum28Constellations.Zhang_Yue_Lu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Zhang_Yue_Lu,
        degreeStartAt: 155.08,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Si, degree: 5.08),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Si, degree: 24.15),
        totalDegree: 19.07),
    Enum28Constellations.Yi_Huo_She: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Yi_Huo_She,
        degreeStartAt: 174.15,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Si, degree: 24.15),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 11.08),
        totalDegree: 16.93),
    Enum28Constellations.Zhen_Shui_Yin: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Zhen_Shui_Yin,
        degreeStartAt: 191.08,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 11.08),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 23.89),
        totalDegree: 12.81),
    Enum28Constellations.Jiao_Mu_Jiao: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Jiao_Mu_Jiao,
        degreeStartAt: 203.89,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 23.89),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 4.87),
        totalDegree: 10.99),
    Enum28Constellations.Kang_Jin_Long: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Kang_Jin_Long,
        degreeStartAt: 214.87,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 4.87),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 15.46),
        totalDegree: 10.59),
    Enum28Constellations.Di_Tu_Lu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Di_Tu_Lu,
        degreeStartAt: 225.46,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 15.46),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Yin, degree: 3.31),
        totalDegree: 17.85),
    Enum28Constellations.Fang_Ri_Tu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Fang_Ri_Tu,
        degreeStartAt: 243.31,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Yin, degree: 3.31),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Yin, degree: 8.16),
        totalDegree: 4.85),
    Enum28Constellations.Xin_Yue_Hu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Xin_Yue_Hu,
        degreeStartAt: 248.16,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Yin, degree: 8.16),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Yin, degree: 16.41),
        totalDegree: 8.25),
    Enum28Constellations.Wei_Huo_Hu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Wei_Huo_Hu,
        degreeStartAt: 256.41,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Yin, degree: 16.41),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chou, degree: 1.61),
        totalDegree: 15.20),
    Enum28Constellations.Ji_Shui_Bao: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Ji_Shui_Bao,
        degreeStartAt: 271.61,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chou, degree: 1.61),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chou, degree: 10.55),
        totalDegree: 8.94),
    Enum28Constellations.Dou_Mu_Xie: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Dou_Mu_Xie,
        degreeStartAt: 280.55,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chou, degree: 10.55),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 4.46),
        totalDegree: 23.92),
    Enum28Constellations.Niu_Jin_Niu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Niu_Jin_Niu,
        degreeStartAt: 304.46,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 4.46),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 12.13),
        totalDegree: 7.67),
    Enum28Constellations.Nv_Tu_Fu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Nv_Tu_Fu,
        degreeStartAt: 312.13,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 12.13),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 23.80),
        totalDegree: 11.67),
    Enum28Constellations.Xu_Ri_Shu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Xu_Ri_Shu,
        degreeStartAt: 323.80,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 23.80),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 3.77),
        totalDegree: 9.97),
    Enum28Constellations.Wei_Yue_Yan: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Wei_Yue_Yan,
        degreeStartAt: 333.77,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 3.77),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 23.84),
        totalDegree: 20.07),
    Enum28Constellations.Shi_Huo_Zhu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: Enum28Constellations.Shi_Huo_Zhu,
        degreeStartAt: 353.84,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 23.84),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Xu, degree: 10.59),
        totalDegree: 16.75),
  };

  // 黄道恒星制

  // 黄道恒星制星宿度数映射表
  @JsonValue("黄道恒星制")
  static final Map<Enum28Constellations, ConstellationGongDegreeInfo>
      ZodiacSiderealStarsInnSystemMapper = {
    Enum28Constellations.Lou_Jin_Gou: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Lou_Jin_Gou,
        degreeStartAt: 15.9,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Xu, degree: 15.9),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Xu, degree: 26.3),
        totalDegree: 10.4),
    Enum28Constellations.Wei_Tu_Zhi: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Wei_Tu_Zhi,
        degreeStartAt: 26.3,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Xu, degree: 26.3),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 11.1),
        totalDegree: 14.8),
    Enum28Constellations.Mao_Ri_Ji: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Mao_Ri_Ji,
        degreeStartAt: 41.1,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 11.1),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 23.2),
        totalDegree: 12.1),
    Enum28Constellations.Bi_Yue_Wu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Bi_Yue_Wu,
        degreeStartAt: 53.2,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 23.2),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 9.0),
        totalDegree: 15.8),
    Enum28Constellations.Zi_Huo_Hou: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Zi_Huo_Hou,
        degreeStartAt: 69.0,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 9.0),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 10.0),
        totalDegree: 1.0),
    Enum28Constellations.Shen_Shui_Yuan: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Shen_Shui_Yuan,
        degreeStartAt: 70.0,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 10.0),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 21.8),
        totalDegree: 11.8),
    Enum28Constellations.Jing_Mu_Han: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Jing_Mu_Han,
        degreeStartAt: 81.8,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 21.8),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Wei, degree: 22.3),
        totalDegree: 30.5),
    Enum28Constellations.Gui_Jin_Yang: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Gui_Jin_Yang,
        degreeStartAt: 112.3,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Wei, degree: 22.3),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Wei, degree: 25.2),
        totalDegree: 2.9),
    Enum28Constellations.Liu_Tu_Zhang: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Liu_Tu_Zhang,
        degreeStartAt: 115.2,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Wei, degree: 25.2),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 10.5),
        totalDegree: 15.3),
    Enum28Constellations.Xing_Ri_Ma: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Xing_Ri_Ma,
        degreeStartAt: 130.5,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 10.5),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 16.4),
        totalDegree: 5.9),
    Enum28Constellations.Zhang_Yue_Lu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Zhang_Yue_Lu,
        degreeStartAt: 136.4,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 16.4),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Si, degree: 1.4),
        totalDegree: 15.0),
    Enum28Constellations.Yi_Huo_She: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Yi_Huo_She,
        degreeStartAt: 151.4,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Si, degree: 1.4),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Si, degree: 20.1),
        totalDegree: 18.7),
    Enum28Constellations.Zhen_Shui_Yin: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Zhen_Shui_Yin,
        degreeStartAt: 170.1,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Si, degree: 20.1),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 7.2),
        totalDegree: 17.1),
    Enum28Constellations.Jiao_Mu_Jiao: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Jiao_Mu_Jiao,
        degreeStartAt: 187.2,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 7.2),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 20.0),
        totalDegree: 12.8),
    Enum28Constellations.Kang_Jin_Long: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Kang_Jin_Long,
        degreeStartAt: 200.0,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 20.0),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 28.9),
        totalDegree: 8.9),
    Enum28Constellations.Di_Tu_Lu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Di_Tu_Lu,
        degreeStartAt: 208.9,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 28.9),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 15.2),
        totalDegree: 16.3),
    Enum28Constellations.Fang_Ri_Tu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Fang_Ri_Tu,
        degreeStartAt: 225.2,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 15.2),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 20.6),
        totalDegree: 5.4),
    Enum28Constellations.Xin_Yue_Hu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Xin_Yue_Hu,
        degreeStartAt: 230.6,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 20.6),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 27.0),
        totalDegree: 6.4),
    Enum28Constellations.Wei_Huo_Hu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Wei_Huo_Hu,
        degreeStartAt: 237.0,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 27.0),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Yin, degree: 15.6),
        totalDegree: 18.6),
    Enum28Constellations.Ji_Shui_Bao: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Ji_Shui_Bao,
        degreeStartAt: 255.6,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Yin, degree: 15.6),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Yin, degree: 26.3),
        totalDegree: 10.7),
    Enum28Constellations.Dou_Mu_Xie: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Dou_Mu_Xie,
        degreeStartAt: 266.3,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Yin, degree: 26.3),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chou, degree: 20.1),
        totalDegree: 23.8),
    Enum28Constellations.Niu_Jin_Niu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Niu_Jin_Niu,
        degreeStartAt: 290.1,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chou, degree: 20.1),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chou, degree: 28.0),
        totalDegree: 7.9),
    Enum28Constellations.Nv_Tu_Fu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Nv_Tu_Fu,
        degreeStartAt: 298.0,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chou, degree: 28.0),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 8.9),
        totalDegree: 10.9),
    Enum28Constellations.Xu_Ri_Shu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Xu_Ri_Shu,
        degreeStartAt: 308.9,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 8.9),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 18.3),
        totalDegree: 9.4),
    Enum28Constellations.Wei_Yue_Yan: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Wei_Yue_Yan,
        degreeStartAt: 318.3,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 18.3),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 3.6),
        totalDegree: 15.3),
    Enum28Constellations.Shi_Huo_Zhu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Shi_Huo_Zhu,
        degreeStartAt: 333.6,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 3.6),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 19.4),
        totalDegree: 15.8),
    Enum28Constellations.Bi_Shui_Yu: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Bi_Shui_Yu,
        degreeStartAt: 349.4,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 19.4),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 28.3),
        totalDegree: 8.9),
    Enum28Constellations.Kui_Mu_Lang: ConstellationGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Kui_Mu_Lang,
        degreeStartAt: 358.3,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 28.3),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Xu, degree: 15.9),
        totalDegree: 17.6),
  };

  // 赤道恒星制
  // 赤道恒星制星宿度数映射表
  // 基于传统赤道28星宿度数，总度数为365.25度
  @JsonValue("赤道恒星制")
  static final Map<Enum28Constellations, ConstellationGongDegreeInfo>
      EquatorialSiderealStarsInnSystemMapper = {
    // 东方青龙七宿 - 总度数：78度
    Enum28Constellations.Jiao_Mu_Jiao: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Jiao_Mu_Jiao,
        degreeStartAt: 0.0,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 0.0),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 12.75),
        totalDegree: 12.75),
    Enum28Constellations.Kang_Jin_Long: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Kang_Jin_Long,
        degreeStartAt: 12.75,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 12.75),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 22.5),
        totalDegree: 9.75),
    Enum28Constellations.Di_Tu_Lu: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Di_Tu_Lu,
        degreeStartAt: 22.5,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 22.5),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 8.75),
        totalDegree: 16.25),
    Enum28Constellations.Fang_Ri_Tu: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Fang_Ri_Tu,
        degreeStartAt: 38.75,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 8.75),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 14.5),
        totalDegree: 5.75),
    Enum28Constellations.Xin_Yue_Hu: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Xin_Yue_Hu,
        degreeStartAt: 44.5,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 14.5),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 20.5),
        totalDegree: 6.0),
    Enum28Constellations.Wei_Huo_Hu: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Wei_Huo_Hu,
        degreeStartAt: 50.5,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chen, degree: 20.5),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Si, degree: 8.5),
        totalDegree: 18.0),
    Enum28Constellations.Ji_Shui_Bao: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Ji_Shui_Bao,
        degreeStartAt: 68.5,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Si, degree: 8.5),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Si, degree: 18.0),
        totalDegree: 9.5),

    // 北方玄武七宿 - 总度数：94度
    Enum28Constellations.Dou_Mu_Xie: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Dou_Mu_Xie,
        degreeStartAt: 78.0,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Si, degree: 18.0),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 10.75),
        totalDegree: 22.75),
    Enum28Constellations.Niu_Jin_Niu: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Niu_Jin_Niu,
        degreeStartAt: 100.75,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 10.75),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 17.75),
        totalDegree: 7.0),
    Enum28Constellations.Nv_Tu_Fu: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Nv_Tu_Fu,
        degreeStartAt: 107.75,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 17.75),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 28.75),
        totalDegree: 11.0),
    Enum28Constellations.Xu_Ri_Shu: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Xu_Ri_Shu,
        degreeStartAt: 118.75,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Wu, degree: 28.75),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Wei, degree: 8.0),
        totalDegree: 9.25),
    Enum28Constellations.Wei_Yue_Yan: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Wei_Yue_Yan,
        degreeStartAt: 128.0,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Wei, degree: 8.0),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Wei, degree: 24.0),
        totalDegree: 16.0),
    Enum28Constellations.Shi_Huo_Zhu: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Shi_Huo_Zhu,
        degreeStartAt: 144.0,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Wei, degree: 24.0),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 12.25),
        totalDegree: 18.25),
    Enum28Constellations.Bi_Shui_Yu: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Bi_Shui_Yu,
        degreeStartAt: 162.25,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 12.25),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 22.0),
        totalDegree: 9.75),

    // 西方白虎七宿 - 总度数：83.5度
    Enum28Constellations.Kui_Mu_Lang: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Kui_Mu_Lang,
        degreeStartAt: 172.0,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Shen, degree: 22.0),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 10.0),
        totalDegree: 18.0),
    Enum28Constellations.Lou_Jin_Gou: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Lou_Jin_Gou,
        degreeStartAt: 190.0,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 10.0),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 22.75),
        totalDegree: 12.75),
    Enum28Constellations.Wei_Tu_Zhi: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Wei_Tu_Zhi,
        degreeStartAt: 202.75,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.You, degree: 22.75),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Xu, degree: 8.0),
        totalDegree: 15.25),
    Enum28Constellations.Mao_Ri_Ji: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Mao_Ri_Ji,
        degreeStartAt: 218.0,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Xu, degree: 8.0),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Xu, degree: 19.0),
        totalDegree: 11.0),
    Enum28Constellations.Bi_Yue_Wu: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Bi_Yue_Wu,
        degreeStartAt: 229.0,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Xu, degree: 19.0),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 5.5),
        totalDegree: 16.5),
    Enum28Constellations.Zi_Huo_Hou: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Zi_Huo_Hou,
        degreeStartAt: 245.5,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 5.5),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 6.0),
        totalDegree: 0.5),
    Enum28Constellations.Shen_Shui_Yuan: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Shen_Shui_Yuan,
        degreeStartAt: 246.0,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 6.0),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 15.5),
        totalDegree: 9.5),

    // 南方朱雀七宿 - 总度数：109.75度
    Enum28Constellations.Jing_Mu_Han: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Jing_Mu_Han,
        degreeStartAt: 255.5,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Hai, degree: 15.5),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 15.75),
        totalDegree: 30.25),
    Enum28Constellations.Gui_Jin_Yang: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Gui_Jin_Yang,
        degreeStartAt: 285.75,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 15.75),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 18.25),
        totalDegree: 2.5),
    Enum28Constellations.Liu_Tu_Zhang: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Liu_Tu_Zhang,
        degreeStartAt: 288.25,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Zi, degree: 18.25),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chou, degree: 1.75),
        totalDegree: 13.5),
    Enum28Constellations.Xing_Ri_Ma: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Xing_Ri_Ma,
        degreeStartAt: 301.75,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chou, degree: 1.75),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chou, degree: 8.5),
        totalDegree: 6.75),
    Enum28Constellations.Zhang_Yue_Lu: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Zhang_Yue_Lu,
        degreeStartAt: 308.5,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chou, degree: 8.5),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Chou, degree: 26.25),
        totalDegree: 17.75),
    Enum28Constellations.Yi_Huo_She: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Yi_Huo_She,
        degreeStartAt: 326.25,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Chou, degree: 26.25),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Yin, degree: 16.5),
        totalDegree: 20.25),
    Enum28Constellations.Zhen_Shui_Yin: ConstellationGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: Enum28Constellations.Zhen_Shui_Yin,
        degreeStartAt: 346.5,
        startAtGongDegree: GongDegree(gong: EnumTwelveGong.Yin, degree: 16.5),
        endAtGongDegree: GongDegree(gong: EnumTwelveGong.Mao, degree: 0.0),
        totalDegree: 18.75),
  };

  static List<FiveStarWalkingType> getFullForwardList(EnumStars star) {
    switch (star) {
      case EnumStars.Mars:
      case EnumStars.Jupiter:
      case EnumStars.Mercury:
        return FiveStarWalkingType.fullForwardList([]);
      case EnumStars.Saturn:
        // 土星没有疾行与迟行
        return FiveStarWalkingType.fullForwardList(
            [FiveStarWalkingType.Fast, FiveStarWalkingType.Slow]);
      case EnumStars.Venus:
        // 金星没有疾行
        return FiveStarWalkingType.fullForwardList([FiveStarWalkingType.Fast]);
      default:
        // 日月，永远为常
        return [FiveStarWalkingType.Normal];
    }
  }
}

/// 星盘坐标系统类型
/// 整合了黄赤道类型、恒星/回归系统以及星宿校正类型
class PanelCelesticalInfo {
  /// 黄赤道类型（黄道制/赤道制/似黄道恒星制）
  final CelestialCoordinateSystem eclipticEquatorialType;

  /// 恒星/回归系统
  final PanelSystemType siderealTropicalSystem;

  /// 星宿校正类型（古宿/今宿/矫正古宿）
  final ConstellationSystemType constellationCorrectionType;

  /// 对应的星盘类型
  final StarPanelType starPanelType;

  /// 名称
  final String name;

  /// 描述
  final String description;

  /// 基准时间（用于岁差计算）
  final DateTime? referenceDate;

  PanelCelesticalInfo({
    required this.eclipticEquatorialType,
    required this.siderealTropicalSystem,
    required this.constellationCorrectionType,
    required this.starPanelType,
    required this.name,
    required this.description,
    this.referenceDate,
  });

  /// 黄道恒星古宿制
  static PanelCelesticalInfo eclipticSiderealClassical = PanelCelesticalInfo(
    eclipticEquatorialType: CelestialCoordinateSystem.ecliptic,
    siderealTropicalSystem: PanelSystemType.sidereal,
    constellationCorrectionType: ConstellationSystemType.classical,
    starPanelType:
        StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
    name: "黄道恒星古宿制",
    description: "基于《郑氏星案》的黄道恒星制，使用古代固定星宿位置，不考虑岁差影响",
  );

  /// 黄道回归矫正古宿制
  static PanelCelesticalInfo eclipticTropicalCorrectedClassical =
      PanelCelesticalInfo(
    eclipticEquatorialType: CelestialCoordinateSystem.ecliptic,
    siderealTropicalSystem: PanelSystemType.tropical,
    constellationCorrectionType: ConstellationSystemType.adjustedClassical,
    starPanelType:
        StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
    name: "黄道回归矫正古宿制",
    description: "在古宿基础上进行岁差校正，以春分点为零点，偏移约14度",
  );

  /// 黄道回归今宿制
  static final PanelCelesticalInfo eclipticTropicalModern = PanelCelesticalInfo(
    eclipticEquatorialType: CelestialCoordinateSystem.ecliptic,
    siderealTropicalSystem: PanelSystemType.tropical,
    constellationCorrectionType: ConstellationSystemType.modern,
    starPanelType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
    name: "黄道回归今宿制",
    description: "采用现代天文观测数据，以2024年1月1日为基准时间，角宿位于戌宫6.5度起",
    referenceDate: DateTime(2024, 1, 1),
  );

  /// 赤道恒星古宿制
  static PanelCelesticalInfo equatorialSiderealClassical = PanelCelesticalInfo(
    eclipticEquatorialType: CelestialCoordinateSystem.equatorial,
    siderealTropicalSystem: PanelSystemType.sidereal,
    constellationCorrectionType: ConstellationSystemType.classical,
    starPanelType:
        StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
    name: "赤道恒星古宿制",
    description: "以赤道面划分十二宫，结合固定恒星位置，确保四象与地支方位严格对应",
  );

  /// 获取对应的星宿映射表
  Map<Enum28Constellations, ConstellationGongDegreeInfo> get starXiuMapper =>
      starPanelType.mapper;

  /// 根据给定的参数获取对应的星盘坐标系统类型
  static PanelCelesticalInfo? fromTypes({
    required CelestialCoordinateSystem eclipticEquatorialType,
    required PanelSystemType siderealTropicalSystem,
    required ConstellationSystemType correctionType,
  }) {
    if (eclipticEquatorialType == CelestialCoordinateSystem.ecliptic) {
      if (siderealTropicalSystem == PanelSystemType.sidereal) {
        if (correctionType == ConstellationSystemType.classical) {
          return eclipticSiderealClassical;
        }
      } else if (siderealTropicalSystem == PanelSystemType.tropical) {
        if (correctionType == ConstellationSystemType.adjustedClassical) {
          return eclipticTropicalCorrectedClassical;
        } else if (correctionType == ConstellationSystemType.modern) {
          return eclipticTropicalModern;
        }
      }
    } else if (eclipticEquatorialType == CelestialCoordinateSystem.equatorial) {
      if (siderealTropicalSystem == PanelSystemType.sidereal) {
        if (correctionType == ConstellationSystemType.classical) {
          return equatorialSiderealClassical;
        }
      }
    }

    return null; // 返回null表示没有找到匹配的类型
  }
}

enum StarPanelType {
  @JsonValue("黄道回归制古宿")
  ZodiacTropicalOriginalClassicStarsInnSystemMapper("黄道回归古宿", 0, []),
  @JsonValue("黄道回归制矫正古宿")
  ZodiacTropicalCorrectedClassicStarsInnSystemMapper("黄道回归矫正古宿", 0, []),

  @JsonValue("赤道恒星制")
  EquatorialSiderealStarsInnSystemMapper("赤道恒星制", 0, []),
  @JsonValue("黄道恒星制")
  ZodiacSiderealStarsInnSystemMapper("黄道恒星制", 0, []),
  // ZodiacTropicalModernStarsInnSystemMapper("黄道回归今宿",0,[]);
  // 角木蛟 6.5° 为 戌宫0°
  @JsonValue("黄道回归制今宿")
  ZodiacTropicalModernStarsInnSystemMapper("黄道回归今宿", 6.5, [
    Enum28Constellations.Shi_Huo_Zhu,
    Enum28Constellations.Bi_Shui_Yu,
    Enum28Constellations.Kui_Mu_Lang,
    Enum28Constellations.Lou_Jin_Gou,
    Enum28Constellations.Wei_Tu_Zhi,
    Enum28Constellations.Mao_Ri_Ji,
    Enum28Constellations.Bi_Yue_Wu,
    Enum28Constellations.Zi_Huo_Hou,
    Enum28Constellations.Shen_Shui_Yuan,
    Enum28Constellations.Jing_Mu_Han,
    Enum28Constellations.Gui_Jin_Yang,
    Enum28Constellations.Liu_Tu_Zhang,
    Enum28Constellations.Xing_Ri_Ma,
    Enum28Constellations.Zhang_Yue_Lu,
    Enum28Constellations.Yi_Huo_She,
    Enum28Constellations.Zhen_Shui_Yin,
    Enum28Constellations.Jiao_Mu_Jiao,
    Enum28Constellations.Kang_Jin_Long,
    Enum28Constellations.Di_Tu_Lu,
    Enum28Constellations.Fang_Ri_Tu,
    Enum28Constellations.Xin_Yue_Hu,
    Enum28Constellations.Wei_Huo_Hu,
    Enum28Constellations.Ji_Shui_Bao,
    Enum28Constellations.Dou_Mu_Xie,
    Enum28Constellations.Niu_Jin_Niu,
    Enum28Constellations.Nv_Tu_Fu,
    Enum28Constellations.Xu_Ri_Shu,
    Enum28Constellations.Wei_Yue_Yan,
  ]);

  final String name;
  final List<Enum28Constellations> starInnOrder;
  final double firstAtZeroDegree;
  const StarPanelType(this.name, this.firstAtZeroDegree, this.starInnOrder);
  Map<Enum28Constellations, ConstellationGongDegreeInfo> get mapper {
    switch (this) {
      case StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper:
        return QiZhengSiYuConstantResources
            .ZodiacTropicalOriginalClassicStarsInnSystemMapper;
      case StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper:
        return QiZhengSiYuConstantResources
            .ZodiacTropicalCorrectedClassicStarsInnSystemMapper;
      case StarPanelType.ZodiacTropicalModernStarsInnSystemMapper:
        return QiZhengSiYuConstantResources
            .ZodiacTropicalModernStarsInnSystemMapper;
      case StarPanelType.EquatorialSiderealStarsInnSystemMapper:
        return QiZhengSiYuConstantResources
            .EquatorialSiderealStarsInnSystemMapper;
      case StarPanelType.ZodiacSiderealStarsInnSystemMapper:
        // TODO: Handle this case.
        return QiZhengSiYuConstantResources
            .EquatorialSiderealStarsInnSystemMapper;
    }
  }

  static Map<Enum28Constellations, ConstellationGongDegreeInfo>
      getStarXiuMapper(PanelCelesticalInfo panelCelesticalInfo) {
    if (panelCelesticalInfo.eclipticEquatorialType ==
        CelestialCoordinateSystem.ecliptic) {
      if (panelCelesticalInfo.siderealTropicalSystem ==
              PanelSystemType.sidereal ||
          panelCelesticalInfo.constellationCorrectionType ==
              ConstellationSystemType.classical) {
        throw UnimplementedError(
            "安身立命时，确定命度。位置的命盘制式，[赤道制、黄道制、似黄道回归制]，当前进提供<黄道制>没有黄道恒星制");
      } else {
        if (panelCelesticalInfo.constellationCorrectionType ==
            ConstellationSystemType.classical) {
          /// 古宿
          return QiZhengSiYuConstantResources
              .ZodiacTropicalOriginalClassicStarsInnSystemMapper;
        } else if (panelCelesticalInfo.constellationCorrectionType ==
            ConstellationSystemType.adjustedClassical) {
          /// 古宿矫正
          return QiZhengSiYuConstantResources
              .ZodiacTropicalCorrectedClassicStarsInnSystemMapper;
        } else if (panelCelesticalInfo.constellationCorrectionType ==
            ConstellationSystemType.modern) {
          /// 今宿
          return QiZhengSiYuConstantResources
              .ZodiacTropicalModernStarsInnSystemMapper;
        }
      }
    } else if (panelCelesticalInfo.eclipticEquatorialType ==
        CelestialCoordinateSystem.equatorial) {
      throw UnimplementedError("安身立命时，确定命度。当前并没有提供<赤道制>");
    } else if (panelCelesticalInfo.eclipticEquatorialType ==
        CelestialCoordinateSystem.pseudoEcliptic) {
      throw UnimplementedError("安身立命时，确定命度。当前并没有提供<似黄道回归制>");
    } else {
      throw UnimplementedError(
          "安身立命时，确定命度。位置的命盘制式，[赤道制、黄道制、似黄道回归制]，当前进提供<黄道制>");
    }
    throw UnimplementedError("安身立命时，确定命度。 未找到任何制式的星宿信息");
  }
}
