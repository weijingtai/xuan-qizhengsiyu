import 'dart:math';
import 'dart:ui' as ui;

import 'package:el_tooltip/el_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:common/enums/enum_stars.dart';
import 'package:common/enums/enum_jia_zi.dart'; // JiaZi
import 'package:common/module.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/passage_year_panel_model.dart';

import 'package:qizhengsiyu/domain/entities/models/eleven_stars_info.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/presentation/models/ui_star_model.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_constant_resources.dart';
// import 'package:qizhengsiyu/pages/qi_zheng_si_yu_viewmodel.dart'; // 旧的 ViewModel,已废弃

import 'package:common/painter/text_circle_ring_painter.dart';
import 'package:common/painter/circle_ring_printer.dart';
import '../../domain/entities/models/body_life_model.dart';
import '../../domain/entities/models/observer_position.dart';
import '../../domain/entities/models/panel_stars_info.dart';
import '../../domain/entities/models/stars_angle.dart';
import '../../enums/enum_twelve_gong.dart';
import '../../painter/painters.dart';
import '../../painter/star_body_ring_painter.dart';
import '../../painter/star_xiu_ring_painter.dart';
import '../../qi_zheng_si_yu_ui_constant_resources.dart';
import '../widgets/rings/gong_12_dizhi.dart';

import '../widgets/rings/gong_shen_sha_ring.dart';
// star_body.dart import no longer needed after extraction
// import 'beauty_page_viewmodel.dart'; // 已替换为新的 MVVM ViewModel
import 'package:qizhengsiyu/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';
import 'package:qizhengsiyu/presentation/widgets/panel_widget.dart';
import 'package:qizhengsiyu/presentation/widgets/ring_layer.dart';
import 'package:qizhengsiyu/presentation/widgets/star_ring_layer.dart';
import 'package:qizhengsiyu/presentation/widgets/star_track_ring.dart';
import 'package:qizhengsiyu/presentation/widgets/star_body_ring.dart';
import 'package:qizhengsiyu/presentation/widgets/twelve_gong_grid_ring.dart';

import 'package:qizhengsiyu/presentation/widgets/twelve_gong_default_ring.dart';
import 'package:qizhengsiyu/presentation/widgets/destiny_twelve_gong_ring.dart';
import 'package:qizhengsiyu/presentation/widgets/center_text_circle_widget.dart';
import 'package:qizhengsiyu/controllers/panel_controller.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart'; // UI层使用的PanelConfig

import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_ui_size.dart'; // UI模型,保留在原位置

// 尺寸模型已迁移至 models/panel_ui_size.dart

class BeautyViewPage extends StatefulWidget {
  const BeautyViewPage({super.key});

  @override
  State<BeautyViewPage> createState() => _BeautyViewPageState();
}

class _BeautyViewPageState extends State<BeautyViewPage>
    with TickerProviderStateMixin {
  static final Logger logger = Logger(
    output: ConsoleOutput(),
    printer: PrettyPrinter(
      methodCount: 2, // Number of method calls to be displayed
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      // Should each log print contain a timestamp
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
  static const List<String> destinyList = <String>[
    "命宫",
    "财帛",
    "兄弟",
    "田宅",
    "男女",
    "奴仆",
    "夫妻",
    "疾厄",
    "迁移",
    "官禄",
    "福德",
    "相貌",
  ];
  final GlobalKey key1 = GlobalKey();
  final GlobalKey key2 = GlobalKey();

  late PanelController _panelController;

  late AnimationController _jupiterController; // 木星
  late AnimationController _saturnController; // 土星
  late AnimationController _venusController; // 金星
  late AnimationController _mercuryController; // 水星
  late AnimationController _marsController; // 火星

  late AnimationController _sunController; // 太阳
  late AnimationController _moonController; // 月亮

  late AnimationController _luoHouJiDuController; // 罗睺 计都
  late AnimationController _yueBeiController; // 月孛
  late AnimationController _ziQiController; // 紫炁

  double yuStarSize = 16;
  double zhengStarSize = 26;
  double yinYangStarSize = 32;

  late QiZhengSiYuPanSizeDataModel panelSizeDataModel;

  Future<void> devInit() async {
    final vm = context.read<QiZhengSiYuViewModel>();
    await vm.init();

    // 使用默认测试数据:直接设置 ObserverPosition
    // TODO: 后续可以从数据库加载真实数据
    final testDateTime = DateTime(1990, 1, 1, 12, 0);
    final testObserver = ObserverPosition(
      dateTime: testDateTime,
      latitude: 39.9042, // 北京纬度
      longitude: 116.4074, // 北京经度
      altitude: 0,
      timezone: 'Asia/Shanghai',
      isDayBirth: true,
      yearGanZhi: JiaZi.GENG_WU, // 庚午年 (1990)
      monthGanZhi: JiaZi.WU_ZI, // 戊子月
      dayGanZhi: JiaZi.JIA_XU, // 甲戌日
      timeGanZhi: JiaZi.GENG_WU, // 庚午时
    );

    await vm.calculate(testObserver);
  }

  Future<DivinationInfoModel> loadDiviniation() async {
    var divinations = await context
        .read<DevEnterPageViewModel>()
        .appDatabase
        .divinationsDao
        .getAllDivinations();
    var seeker = await context
        .read<DevEnterPageViewModel>()
        .appDatabase
        .seekersDao
        .getSeekersByDivinationUuid(divinations.last.uuid);
    var res = DivinationInfoModel(
        divination: divinations.last, divinationDatetime: seeker.first);

    return res;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    devInit().then((value) {
      logger.d("devInit finished");
    });
    // 0°02′02‘’ 一天
    _jupiterController = AnimationController(
        vsync: this, duration: const Duration(seconds: 1062))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _jupiterController.repeat();
        }
      });

    // 土星 0°00′59'' 一天
    _saturnController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2197))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _saturnController.repeat();
        }
      });

    // 金星 1°33′ 一天
    _venusController = AnimationController(
        vsync: this, duration: const Duration(seconds: 1393))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _venusController.repeat();
        }
      });

    // 水星 4°5′ 一天
    _mercuryController =
        AnimationController(vsync: this, duration: const Duration(seconds: 88))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _mercuryController.repeat();
            }
          });

    // 火星 0°32′ 一天
    _marsController =
        AnimationController(vsync: this, duration: const Duration(seconds: 675))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _marsController.repeat();
            }
          });

    _sunController =
        AnimationController(vsync: this, duration: const Duration(seconds: 360))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _sunController.repeat();
            }
          });
    // 月亮 13°10′35" 一天
    _moonController =
        AnimationController(vsync: this, duration: const Duration(seconds: 27))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _moonController.repeat();
            }
          });

    _luoHouJiDuController =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _luoHouJiDuController.repeat();
            }
          });
    _yueBeiController =
        AnimationController(vsync: this, duration: const Duration(seconds: 18))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _yueBeiController.repeat();
            }
          });
    _ziQiController =
        AnimationController(vsync: this, duration: const Duration(seconds: 14))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _ziQiController.repeat();
            }
          });
    panelSizeDataModel = QiZhengSiYuPanSizeDataModel(
        starBodyRadius: 16,
        centerSize: 140,
        diZhi12GongHeight: 50,
        zodiac12GongHeight: 24,
        starSeq12GongHeight: 0,
        destiny12GongHeight: 70, // 增加命理十二宫的径向高度,避免文字挤在一起
        lifeStarRingHeight: 48, // 64
        starXiu28RingHeight: 36, // 660
        innerShenShaHeight: 90,
        outerShenShaHeight: 90,
        showFateLifeStarRing: true);

    // 创建默认 PanelConfig 并初始化控制器
    final defaultPanelConfig = PanelConfig(
      celestialCoordinateSystem: CelestialCoordinateSystem.ecliptic,
      houseDivisionSystem: HouseDivisionSystem.equal,
      panelSystemType: PanelSystemType.tropical,
      constellationSystemType: ConstellationSystemType.classical,
      settleLifeType: EnumSettleLifeType.Mao,
      settleBodyType: EnumSettleBodyType.moon,
      islifeGongBySunRealTimeLocation: true,
    );

    final vm = context.read<QiZhengSiYuViewModel>();
    _panelController = QiZhengPanelController(
      config: defaultPanelConfig,
      basePanel: vm.uiBasePanelListenable,
      // TODO: 大限盘功能待实现 - 类型不匹配需要适配层
      daXianPanel: ValueNotifier(null), // 暂时使用空notifier
      innerStars: vm.uiBasicLifeStarsListenable,
      outerStars: vm.uiFateLifeStarsListenable,
      rotationDeg: 30,
    );

    // 在首帧后读取路由参数并应用配置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is PanelConfig) {
        _panelController.updateConfig(args);
        final vm = context.read<QiZhengSiYuViewModel>();
        vm.setOverridePanelConfig(args);
        vm.init().then((_) {
          if (vm.lifeObserver != null) {
            vm.calculate(vm.lifeObserver!);
          }
        });
      }
    });

    // panelSizeDataModel = QiZhengSiYuPanSizeDataModel(
    //     starBodyRadius: 16 + 4,
    //     centerSize: 172,
    //     diZhi12GongHeight: 60,
    //     zodiac12GongHeight: 42,
    //     starSeq12GongHeight: 0,
    //     destiny12GongHeight: 64,
    //     lifeStarRingHeight: 16 * 4, // 564
    //     starXiu28RingHeight: 48, // 660
    //     innerShenShaHeight: 128,
    //     outerShenShaHeight: 128,
    //     showFateLifeStarRing: true);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _jupiterController.dispose();
    _saturnController.dispose();
    _venusController.dispose();
    _mercuryController.dispose();
    _marsController.dispose();

    _sunController.dispose();
    _moonController.dispose();

    _luoHouJiDuController.dispose();
    _yueBeiController.dispose();
    _ziQiController.dispose();
    showTaiJiDianButtonNotifier.dispose();
    _destiny12GongListNotifier.dispose();
    _selectedTaiJiDestiny12GongListNotifier.dispose();
    _panelController.dispose();
    super.dispose();
  }

  bool isFirst = true;
  ValueNotifier<bool> showTaiJiDianButtonNotifier = ValueNotifier(false);
  ValueNotifier<bool> showStarHuaJiInfoNotifier = ValueNotifier(false);

  double get centerSize => panelSizeDataModel.centerSize;
  double get diZhi12GongInner => panelSizeDataModel.diZhi12GongInner;
  double get diZhi12GongOuter => panelSizeDataModel.diZhi12GongOuter;
  double get zodiac12GongSizeInner => panelSizeDataModel.zodiac12GongSizeInner;
  double get zodiac12GongSizeOuter => panelSizeDataModel.zodiac12GongSizeOuter;
  double get starSeq12GongSizeInner =>
      panelSizeDataModel.starSeq12GongSizeInner;
  double get starSeq12GongSizeOuter =>
      panelSizeDataModel.starSeq12GongSizeOuter;
  double get destiny12GongSizeInner =>
      panelSizeDataModel.destiny12GongSizeInner;
  double get destiny12GongSizeOuter =>
      panelSizeDataModel.destiny12GongSizeOuter;
  double get fateLifeStarOuterSize =>
      panelSizeDataModel.innerLifeStarRingOuterSize; //564
  double get fateLifeStarTrackSize =>
      panelSizeDataModel.innerLifeStarRingTrackSize;
  double get fateLifeStarInnerSize =>
      panelSizeDataModel.innerLifeStarRingInnerSize;
  double get starXiu28RingSizeOuter =>
      panelSizeDataModel.starXiu28RingSizeOuter; // 660
  double get starXiu28RingSizeInner =>
      panelSizeDataModel.starXiu28RingSizeInner; // 616 - 80 = 536
  double get basicLifeStarRingInnerSize =>
      panelSizeDataModel.outerLifeStarRingInnerSize; // starXiu28RingSizeOuter
  double get basicLifeStarBodyTrackSize =>
      panelSizeDataModel.outerLifeStarRingTrackSize;
  double get basicLifeStarRingOuterSize =>
      panelSizeDataModel.outerLifeStarRingOuterSize;

  /// _destiny12GongListNotifier list#index 对应地支方位 0-子 1-亥 ...
  ///

  final ValueNotifier<List<String>> _destiny12GongListNotifier = ValueNotifier([
    "命宫",
    "财帛",
    "兄弟",
    "田宅",
    "男女",
    "奴仆",
    "夫妻",
    "疾厄",
    "迁移",
    "官禄",
    "福德",
    "相貌",
  ]);

  /// _selectedTaiJiDestiny12GongListNotifier list#index 对应地支方位 0-子 1-亥
  final ValueNotifier<List<String>?> _selectedTaiJiDestiny12GongListNotifier =
      ValueNotifier(null);
  TextStyle destinyTextStyle = GoogleFonts.maShanZheng(
      color: Colors.black87,
      fontSize: 28,
      fontWeight: FontWeight.normal,
      height: 1.0,
      shadows: [
        BoxShadow(
          color: Colors.black45.withOpacity(.2),
          spreadRadius: 1,
          blurRadius: 1,
          offset: const Offset(1, 1), // changes position of shadow
        )
      ]);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double minSize = height > width ? width : height;
    // double panelMaxSize = minSize * .8;
    double panelMaxSize = 1700;
    logger.d("盘最大Size为$panelMaxSize");
    // 星体半径 16
    double starBodyRadius = panelSizeDataModel.starBodyRadius;
    // 本命盘星轨内环
    double starInnRangeMiddleSize = 520 + 96;
    // 本命盘星轨外环
    double basicLifeStarCenterCircleSize =
        starInnRangeMiddleSize + starBodyRadius * 2 + 12;

    // double fateLifeStarCenterCircleSize= starInnRangeMiddleSize+starBodyRadius*2+12;

    if (isFirst) {
      Future.delayed(const Duration(seconds: 3), () {
        isFirst = false;
        // calculatePanel();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('七政四余'),
        actions: [
          IconButton(
            tooltip: '配置',
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed('/qizhengsiyu/config');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Container(
            //   padding: const EdgeInsets.all(15),
            //   child: ValueListenableBuilder(
            //     valueListenable: showStarHuaJiInfoNotifier,
            //     builder: (ctx, show, _) {
            //       return Switch(
            //           value: show,
            //           onChanged: (n) {
            //             showStarHuaJiInfoNotifier.value = n;
            //           });
            //     },
            //   ),
            // ),
            AspectRatio(
              aspectRatio: 1,
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final panelSize = constraints.biggest.shortestSide;
                  logger.d("面板计算尺寸为$panelSize");
                  // 计算缩放比例，确保整个面板在画布内完整可见
                  final baseCanvasSize =
                      panelSizeDataModel.outerShenShaSizeOuter;
                  final scale = panelSize / baseCanvasSize;
                  return ValueListenableBuilder<double>(
                    valueListenable: _panelController.rotationDeg,
                    builder: (ctx, rotation, _) {
                      return PanelWidget(
                        canvasSize: panelSize,
                        rotationDeg: rotation,
                        child: Transform.scale(
                          scale: scale < 1 ? scale : 1,
                          child: SizedBox(
                            width: baseCanvasSize,
                            height: baseCanvasSize,
                            child: panel(starBodyRadius),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget center(BasePanelModel basePanel) {
    return Container(
        width: centerSize,
        height: centerSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(centerSize),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: CenterTextCircleWidget(
          bodyLifeModel: basePanel.bodyLifeModel,
          size: centerSize,
        ));
  }

  Widget fourZhu(BodyLifeModel bodyLifeModel) {
    TextStyle titleTextStyle =
        TextStyle(fontSize: 14, height: 1.2, color: Colors.black38);
    TextStyle infoTextStyle =
        TextStyle(fontSize: 14, height: 1.2, fontWeight: FontWeight.bold);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text.rich(TextSpan(text: "命主:", style: titleTextStyle, children: [
                TextSpan(
                    text: bodyLifeModel.lifeGong.sevenZheng.singleName,
                    style: infoTextStyle.copyWith(
                        color: QiZhengSiYuUIConstantResources
                            .zhengColorMap[bodyLifeModel.lifeGong.sevenZheng])),
              ])),
              Text.rich(TextSpan(text: "度主:", style: titleTextStyle, children: [
                TextSpan(
                    text:
                        bodyLifeModel.lifeConstellatioin.sevenZheng.singleName,
                    style: infoTextStyle.copyWith(
                        color: QiZhengSiYuUIConstantResources.zhengColorMap[
                            bodyLifeModel.lifeConstellatioin.sevenZheng]))
              ])),
            ]),
        SizedBox(
          width: 24,
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text.rich(TextSpan(text: "身主:", style: titleTextStyle, children: [
                TextSpan(
                    text: bodyLifeModel.bodyGong.sevenZheng.singleName,
                    style: infoTextStyle.copyWith(
                        color: QiZhengSiYuUIConstantResources
                            .zhengColorMap[bodyLifeModel.bodyGong.sevenZheng]))
              ])),
              Text.rich(TextSpan(text: "身度:", style: titleTextStyle, children: [
                TextSpan(
                    text: bodyLifeModel.bodyConstellation.sevenZheng.singleName,
                    style: infoTextStyle.copyWith(
                        color: QiZhengSiYuUIConstantResources.zhengColorMap[
                            bodyLifeModel.bodyConstellation.sevenZheng]))
              ])),
            ])
      ],
    );
  }

  Widget eigthChatPanel(ObserverPosition observer) {
    // ValueListenableBuilder<ObserverPosition?>(
    // valueListenable: context
    //     .read<QiZhengSiYuViewModel>()
    //     .observerPositionNotifier,
    // builder: (ctx, position, _) {
    //   if (position == null) {
    //     return SizedBox();
    //   }
    //   return eigthChatPanel(position);
    // }),

    TextStyle titleStyle = TextStyle(fontSize: 12, height: 1.0);
    TextStyle ganZhiStyle = TextStyle(fontSize: 16, height: 1.0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "运",
              style: titleStyle,
            ),
            Text("癸", style: ganZhiStyle),
            Text("卯", style: ganZhiStyle),
          ],
        ),
        SizedBox(
          width: 6,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("流", style: titleStyle),
            Text("辛", style: ganZhiStyle),
            Text("丑", style: ganZhiStyle),
          ],
        ),
        SizedBox(
          width: 6,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "年",
              style: titleStyle,
            ),
            Text(observer.yearGanZhi.gan.name, style: ganZhiStyle),
            Text(observer.yearGanZhi.zhi.name, style: ganZhiStyle),
          ],
        ),
        SizedBox(
          width: 6,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("月", style: titleStyle),
            Text(observer.monthGanZhi.gan.name, style: ganZhiStyle),
            Text(observer.monthGanZhi.zhi.name, style: ganZhiStyle),
          ],
        ),
        SizedBox(
          width: 6,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "日",
              style: titleStyle,
            ),
            Text(observer.dayGanZhi.gan.name, style: ganZhiStyle),
            Text(observer.dayGanZhi.zhi.name, style: ganZhiStyle),
          ],
        ),
        SizedBox(
          width: 6,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("时", style: titleStyle),
            Text(observer.timeGanZhi.gan.name, style: ganZhiStyle),
            Text(observer.timeGanZhi.zhi.name, style: ganZhiStyle),
          ],
        )
      ],
    );
  }

  Widget panel(
    double starBodyRadius,
  ) {
    // 黄道十二宫 从白羊开始
    List<String> zodiacList = <String>[
      "白羊",
      "金牛",
      "双子",
      "巨蟹",
      "狮子",
      "处女",
      "天秤",
      "天蝎",
      "射手",
      "摩羯",
      "水瓶",
      "双鱼",
    ];
    // TextStyle zodiacTextStyle = TextStyle(color: Colors.grey, fontSize: 12,fontFamily: 'KaiTi',fontWeight: FontWeight.w300,height: 1.2);
    TextStyle zodiacTextStyle = GoogleFonts.longCang(
        color: const Color.fromRGBO(66, 76, 80, 1),
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.0);
    List<Text> zodiacTextList = zodiacList
        .map((e) => Text(
              e,
              style: zodiacTextStyle,
            ))
        .toList();

    // 十二星次 从大梁开始
    List<String> starSeqList = <String>[
      "降娄",
      "大梁",
      "实沈",
      "鹑首",
      "鹑火",
      "鹑尾",
      "寿星",
      "大火",
      "析木",
      "星纪",
      "玄枵",
      "娵訾",
    ];
    // TextStyle starTextStyle = TextStyle(color: Colors.grey, fontSize: 12,fontFamily: 'KaiTi',fontWeight: FontWeight.w300,height: 1.2);
    TextStyle starTextStyle = GoogleFonts.zhiMangXing(
        color: const Color.fromRGBO(80, 97, 109, 1),
        fontSize: 12,
        fontWeight: FontWeight.normal,
        height: 1.0);
    List<Text> starSeqTextList = starSeqList
        .map((e) => Text(
              e,
              style: starTextStyle,
            ))
        .toList();
    // 命理十二宫 从命宫开始
    // List<String> destinyList = <String>["命宫①", "财帛②", "兄弟③", "田宅④", "男女⑤", "奴仆⑥", "夫妻⑦", "疾厄⑧", "迁移⑨", "官禄⑩", "福德⑪", "相貌⑫",];
    // TextStyle destinyTextStyle = TextStyle(color: Colors.black, fontSize: 20,fontFamily: 'KaiTi',fontWeight: FontWeight.w400);

    List<Text> destinySeqTextList = destinyList
        .map((e) => Text(
              e,
              style: destinyTextStyle.copyWith(
                  decoration: e == destinyList[0]
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  fontWeight:
                      e == destinyList[0] ? FontWeight.w600 : FontWeight.w500),
            ))
        .toList();

    double rotating = 0;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Container(
        //   alignment: Alignment.center,
        //   height: diZhi12GongOuter,
        //   width: diZhi12GongOuter,
        //   decoration: BoxDecoration(
        //     // color: Colors.red.withOpacity(.1),
        //     borderRadius: BorderRadius.circular(diZhi12GongOuter),
        //     // border: Border.all(color: Colors.black,width: 1),
        //   ),
        //   child: Transform.rotate(
        //     angle: 75 * pi / 180,
        //     origin: Offset.zero,
        //     child: CustomPaint(
        //         size: Size(diZhi12GongOuter, diZhi12GongOuter),
        //         painter: TwelveZhiGongCircleRingPrinter(
        //           innerRadius: 86,
        //           outerRadius: 148,
        //           twelveGongList: [
        //             EnumTwelveGong.Xu,
        //             EnumTwelveGong.Hai,
        //             EnumTwelveGong.Zi,
        //             EnumTwelveGong.Chou,
        //             EnumTwelveGong.Yin,
        //             EnumTwelveGong.Mao,
        //             EnumTwelveGong.Chen,
        //             EnumTwelveGong.Si,
        //             EnumTwelveGong.Wu,
        //             EnumTwelveGong.Wei,
        //             EnumTwelveGong.Shen,
        //             EnumTwelveGong.You,
        //           ],
        //           starColorMapper: QiZhengSiYuUIConstantResources.zhengColorMap,
        //           isAntiClockwise: false,
        //           innerPadding: 3,
        //           isReverseText: false,
        //           isHorizontalText: false,
        //           textStyle: GoogleFonts.maShanZheng(
        //             height: 1.2,
        //             fontSize: 16,
        //             color: Colors.black87,
        //           ),
        //         )),
        //   ),
        // ),

        // 十二地支宫（统一为 RingLayer）
        RingLayer(
          showTrack: false,
          showGrid: false,
          gridBuilder: () => TwelveGongGridRingWidget(
            innerSize: diZhi12GongInner,
            outerSize: diZhi12GongOuter,
          ),
          bodyRotationAngle: -30 * pi / 180,
          bodyBuilder: () => ValueListenableBuilder<ZhouTianModel?>(
              valueListenable:
                  context.read<QiZhengSiYuViewModel>().uiZhouTianModelNotifier,
              builder: (ctx, zhouTianModel, _) {
                if (zhouTianModel == null) {
                  return const SizedBox();
                }
                return build12DiZhiGong(
                  diZhi12GongOuter * .5,
                  diZhi12GongInner * .5,
                  zhouTianModel,
                );
              }),
        ),
        // 黄道十二宫（统一为 RingLayer）
        RingLayer(
          showTrack: false,
          showGrid: false,
          gridBuilder: () => TwelveGongGridRingWidget(
            innerSize: zodiac12GongSizeInner,
            outerSize: zodiac12GongSizeOuter,
          ),
          bodyRotationAngle: -30 * pi / 180,
          bodyBuilder: () => zhouTian12GongRing(
            zodiac12GongSizeInner * .5,
            zodiac12GongSizeOuter * .5,
          ),
        ),
        // 命理十二宫（统一为 RingLayer）
        RingLayer(
          showTrack: false,
          showGrid: true,
          gridBuilder: () => TwelveGongGridRingWidget(
            innerSize: destiny12GongSizeInner,
            outerSize: destiny12GongSizeOuter,
          ),
          bodyRotationAngle: -30 * pi / 180,
          bodyBuilder: () => buildMingLi12GongRing(
            destiny12GongSizeInner, // DestinyTwelveGongRingWidget期望直径,不是半径
            destiny12GongSizeOuter, // DestinyTwelveGongRingWidget期望直径,不是半径
          ),
        ),
        // 二十八星宿环（统一为 RingLayer）
        RingLayer(
          showTrack: true,
          showGrid: false,
          trackRotationAngle: rotating * pi / 180,
          trackBuilder: () => Container(
            width: starXiu28RingSizeOuter,
            height: starXiu28RingSizeOuter,
            alignment: Alignment.center,
            child: CustomPaint(
              size: Size(starXiu28RingSizeOuter, starXiu28RingSizeOuter),
              painter: IndicatorScalePainter(
                ringWidth: 40,
                tickLength: 7,
                indicatorAngle: 45.1,
              ),
            ),
          ),
          gridBuilder: () => TwelveGongGridRingWidget(
            innerSize: starXiu28RingSizeInner,
            outerSize: starXiu28RingSizeOuter,
          ),
          bodyRotationAngle: rotating * pi / 180,
          bodyBuilder: () => starXiuRing(starXiu28RingSizeOuter, 40),
        ),

        // ShenSha grids refactored into RingLayer below to keep stacking consistent
        const SizedBox(),
        const SizedBox(),

        // 本命盘星轨（轨道在下）
        StarRingLayer(
          starsListenable:
              context.read<QiZhengSiYuViewModel>().uiFateLifeStarsNotifier,
          outerSize: fateLifeStarOuterSize,
          innerSize: fateLifeStarInnerSize,
          showTrack: true,
          showGrid: false,
          trackRotationAngle: rotating * pi / 180,
          bodyRotationAngle: -(rotating - 90) * pi / 180,
          trackBuilder: (stars) => InnerStarTrackRingWidget(
            stars: stars,
            outerSize: fateLifeStarOuterSize,
            innerSize: fateLifeStarInnerSize,
            trackSize: fateLifeStarTrackSize,
          ),
          gridBuilder: twelveGongGridBuilder,
          bodyBuilder: (stars) => InnerStarBodyRotatingWidget(
            stars: stars,
            outerSize: fateLifeStarOuterSize,
            trackSize: fateLifeStarTrackSize,
            starBodySize: panelSizeDataModel.starBodySize,
            allStarsShowNotifier: showStarHuaJiInfoNotifier,
          ),
        ),

        StarRingLayer(
          starsListenable:
              context.read<QiZhengSiYuViewModel>().uiBasicLifeStarsNotifier,
          outerSize: basicLifeStarRingOuterSize,
          innerSize: basicLifeStarRingInnerSize,
          showTrack: true,
          showGrid: false,
          trackRotationAngle: rotating * pi / 180,
          bodyRotationAngle: -(rotating - 90) * pi / 180,
          trackBuilder: (stars) => OuterStarTrackRingWidget(
            stars: stars,
            outerSize: basicLifeStarRingOuterSize,
            innerSize: basicLifeStarRingInnerSize,
            trackSize: basicLifeStarBodyTrackSize,
          ),
          gridBuilder: twelveGongGridBuilder,
          bodyBuilder: (stars) => OuterStarBodyRotatingWidget(
            stars: stars,
            outerSize: basicLifeStarRingOuterSize,
            trackSize: basicLifeStarBodyTrackSize,
            starBodySize: panelSizeDataModel.starBodySize,
            allStarsShowNotifier: showStarHuaJiInfoNotifier,
          ),
        ),

        // 神煞（内圈）
        RingLayer(
          showTrack: false,
          showGrid: false,
          gridBuilder: () => TwelveGongGridRingWidget(
            innerSize: panelSizeDataModel.innerShenShaSizeInner,
            outerSize: panelSizeDataModel.innerShenShaSizeOuter,
          ),
          bodyRotationAngle: -30 * pi / 180,
          bodyBuilder: () => ValueListenableBuilder<BasePanelModel?>(
            valueListenable:
                context.read<QiZhengSiYuViewModel>().uiBasePanelNotifier,
            builder: (ctx, basePanel, child) {
              if (basePanel == null) {
                return child!;
              }
              return ValueListenableBuilder<ZhouTianModel?>(
                  valueListenable: context
                      .read<QiZhengSiYuViewModel>()
                      .uiZhouTianModelNotifier,
                  builder: (ctx, zhouTianModel, _) {
                    if (zhouTianModel == null) {
                      return child!;
                    }
                    return AllShenShaRing(
                      outerRadius:
                          panelSizeDataModel.innerShenShaSizeOuter * .5,
                      innerRadius:
                          panelSizeDataModel.innerShenShaSizeInner * .5,
                      shenShaMapper: basePanel.shenShaItemMapper,
                      gongOrder: EnumTwelveGong.listAll,
                      zhouTianModel: zhouTianModel,
                    );
                  });
            },
            child: Container(
              width: panelSizeDataModel.innerShenShaSizeOuter,
              height: panelSizeDataModel.innerShenShaSizeOuter,
            ),
          ),
        ),

        // 流年神煞（外圈）
        RingLayer(
          showTrack: false,
          showGrid: false,
          gridBuilder: () => TwelveGongGridRingWidget(
            innerSize: panelSizeDataModel.outerShenShaSizeInner,
            outerSize: panelSizeDataModel.outerShenShaSizeOuter,
          ),
          bodyRotationAngle: -30 * pi / 180,
          bodyBuilder: () {
            return ValueListenableBuilder<PassageYearPanelModel?>(
                valueListenable:
                    context.read<QiZhengSiYuViewModel>().uiDaXianPanelNotifier,
                builder: (ctx, daXianPanel, child) {
                  if (daXianPanel == null) {
                    return child!;
                  }
                  return ValueListenableBuilder<ZhouTianModel?>(
                      valueListenable: context
                          .read<QiZhengSiYuViewModel>()
                          .uiZhouTianModelNotifier,
                      builder: (ctx, zhouTianModel, _) {
                        if (zhouTianModel == null) {
                          return child!;
                        }
                        return AllShenShaRing(
                          outerRadius:
                              panelSizeDataModel.outerShenShaSizeOuter * .5,
                          innerRadius:
                              panelSizeDataModel.outerShenShaSizeInner * .5,
                          shenShaMapper: daXianPanel.shenShaItemMapper,
                          gongOrder: EnumTwelveGong.listAll,
                          zhouTianModel: zhouTianModel,
                        );
                      });
                },
                child: Container(
                  width: panelSizeDataModel.outerShenShaSizeOuter,
                  height: panelSizeDataModel.outerShenShaSizeOuter,
                ));
          },
        ),

        Transform.rotate(
          angle: -30 * pi / 180,
          child: ValueListenableBuilder<BasePanelModel?>(
              valueListenable:
                  context.read<QiZhengSiYuViewModel>().uiBasePanelNotifier,
              builder: (ctx, baseModel, _) {
                if (baseModel == null) {
                  // 显示中心占位以避免空白
                  return Container(
                    width: centerSize,
                    height: centerSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(centerSize),
                      border: Border.all(color: Colors.black54, width: 1),
                    ),
                    child: const Text("加载中..."),
                  );
                }
                return center(baseModel);
              }),
        ),
      ],
    );
  }

  Widget build12DiZhiGong(
      double outerRadius, double innerRadius, ZhouTianModel zhouTianModel) {
    TextStyle firstTextStyle =
        TextStyle(fontSize: 18, height: 1.0, color: Colors.black87, shadows: [
      Shadow(
        color: Colors.black26,
        offset: Offset(1, 1),
        blurRadius: 3,
      ),
    ]);
    TextStyle secondTextStyle =
        TextStyle(fontSize: 12, height: 1.0, color: Colors.black87, shadows: [
      Shadow(
        color: Colors.black26,
        offset: Offset(1, 1),
        blurRadius: 3,
      ),
    ]);
    // double outerRadius = 100;
    // double innerRadius = outerRadius - 50;
    return Gong12DiZhiRing(
      zhouTianModel: zhouTianModel,
      outerRadius: outerRadius,
      innerRadius: innerRadius,
      // angleOffset: 3,
      shenShaMapper: {
        EnumTwelveGong.Zi: [
          Text("子", style: firstTextStyle),
          Text("坎", style: secondTextStyle),
          Text("土", style: secondTextStyle)
        ],
        EnumTwelveGong.Chou: [
          Text("丑", style: firstTextStyle),
          Text("艮", style: secondTextStyle),
          Text("土", style: secondTextStyle)
        ],
        EnumTwelveGong.Yin: [
          Text("寅", style: firstTextStyle),
          Text("艮", style: secondTextStyle),
          Text("木", style: secondTextStyle)
        ],
        EnumTwelveGong.Mao: [
          Text("卯", style: firstTextStyle),
          Text("震", style: secondTextStyle),
          Text("火", style: secondTextStyle)
        ],
        EnumTwelveGong.Chen: [
          Text("辰", style: firstTextStyle),
          Text("巽", style: secondTextStyle),
          Text("金", style: secondTextStyle)
        ],
        EnumTwelveGong.Si: [
          Text("巳", style: firstTextStyle),
          Text("巽", style: secondTextStyle),
          Text("水", style: secondTextStyle)
        ],
        EnumTwelveGong.Wu: [
          Text("午", style: firstTextStyle),
          Text("离", style: secondTextStyle),
          Text("日", style: secondTextStyle)
        ],
        EnumTwelveGong.Wei: [
          Text("未", style: firstTextStyle),
          Text("坤", style: secondTextStyle),
          Text("月", style: secondTextStyle)
        ],
        EnumTwelveGong.Shen: [
          Text("申", style: firstTextStyle),
          Text("坤", style: secondTextStyle),
          Text("水", style: secondTextStyle)
        ],
        EnumTwelveGong.You: [
          Text("酉", style: firstTextStyle),
          Text("兑", style: secondTextStyle),
          Text("金", style: secondTextStyle)
        ],
        EnumTwelveGong.Xu: [
          Text("戌", style: firstTextStyle),
          Text("乾", style: secondTextStyle),
          Text("火", style: secondTextStyle)
        ],
        EnumTwelveGong.Hai: [
          Text("亥", style: firstTextStyle),
          Text("乾", style: secondTextStyle),
          Text("木", style: secondTextStyle)
        ],
      },
    );
  }

  Widget innerShenShaRing(double innerSize, double outerSize) {
    TextStyle textStyle = const TextStyle(
      fontSize: 18,
      color: Colors.black87,
      height: 1.0,
      fontWeight: FontWeight.w400,
    );
    return Stack(
        alignment: Alignment.center,
        children: List.generate(
            6,
            (i) => innerShenShaEachGong(i, innerSize, outerSize, textStyle,
                i <= 3 && i >= 8 ? i * 30 : -i * 30)).toList());
  }

  Widget innerShenShaEachGong(int number, double innerSize, double outerSize,
      TextStyle textStyle, double basicRotatedAngle) {
    List<String> twelveZhangShengShenSha = [
      "长生",
      "沐浴",
      "冠带",
      "临官",
      "帝旺",
      "衰",
      "病",
      "死",
      "墓",
      "绝",
      "胎",
      "养"
    ];

    return Transform.rotate(
      angle: -(number * 30) * (pi / 180),
      // angle: 0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...List.generate(
              1,
              (i) => eachShenShaVertical(
                  twelveZhangShengShenSha[i],
                  4.2 * i + 2.0,
                  basicRotatedAngle,
                  outerSize,
                  textStyle)).toList(growable: false),
          ...List.generate(
              6,
              (i) => eachShenShaVertical(
                  twelveZhangShengShenSha[i + 6],
                  4.2 * i + 2.0,
                  basicRotatedAngle,
                  outerSize - 120,
                  textStyle)).toList(growable: false),
        ],
      ),
    );

    if ([0, 1, 4, 5].contains(number)) {
      return Transform.rotate(
        angle: -(number * 30) * (pi / 180),
        // angle: 0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ...List.generate(
                7,
                (i) => eachShenShaVertical(
                    twelveZhangShengShenSha[i],
                    4.2 * i + 2.0,
                    basicRotatedAngle,
                    outerSize,
                    textStyle)).toList(growable: false),
            ...List.generate(
                6,
                (i) => eachShenShaVertical(
                    twelveZhangShengShenSha[i + 6],
                    4.2 * i + 2.0,
                    basicRotatedAngle,
                    outerSize - 120,
                    textStyle)).toList(growable: false),
          ],
        ),
      );
    } else {
      return Transform.rotate(
        // angle: -((number - 3) * 30) * (pi / 180),
        angle: -(150 - 30 * (number - 3)) * (pi / 180),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ...List.generate(
                7,
                (i) => eachShenShaHorizontal(
                    twelveZhangShengShenSha[i],
                    4.2 * i + 2.0,
                    basicRotatedAngle,
                    outerSize,
                    textStyle)).toList(growable: false),
            ...List.generate(
                6,
                (i) => eachShenShaHorizontal(
                    twelveZhangShengShenSha[i + 6],
                    4.2 * i + 2.0,
                    basicRotatedAngle,
                    outerSize - 120,
                    textStyle)).toList(growable: false),
          ],
        ),
      );
    }
  }

  Widget eachShenShaHorizontal(String shenShaName, double rotateOffset,
      double fontBasicRotated, double height, TextStyle textStyle) {
    List<String> nameList = shenShaName.split("");
    return Transform.rotate(
      angle: rotateOffset * (pi / 180),
      // angle: 0,
      child: Container(
        alignment: Alignment.centerRight,
        height: 32,
        width: height,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        // decoration: BoxDecoration(
        // TODO: DevHelper Color
        // color: Colors.blue.withOpacity(.1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RotatedBox(
              quarterTurns: 0,
              child: Container(
                  height: 22,
                  width: 54,
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.teal),
                  alignment: Alignment.center,
                  child: Row(
                      mainAxisAlignment: nameList.length > -1
                          ? MainAxisAlignment.spaceAround
                          : MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: nameList
                          .map(
                            (singleName) => Transform.rotate(
                                angle: pi / 178,
                                child: Text(
                                  singleName,
                                  style: textStyle,
                                )),
                          )
                          .toList())),
            ),
            const Expanded(child: SizedBox()),
            RotatedBox(
              quarterTurns: 0,
              child: Container(
                  height: 24,
                  width: 56,
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: Colors.amber),
                  alignment: Alignment.center,
                  child: Row(
                      mainAxisAlignment: nameList.length > 1
                          ? MainAxisAlignment.spaceAround
                          : MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: nameList
                          .map(
                            (singleName) => Transform.rotate(
                                angle: pi / 180,
                                child: Text(
                                  singleName,
                                  style: textStyle,
                                )),
                          )
                          .toList())),
            ),
          ],
        ),
      ),
    );
  }

  Widget eachShenShaVertical(String shenShaName, double rotateOffset,
      double fontBasicRotated, double height, TextStyle textStyle) {
    List<String> nameList = shenShaName.split("");
    return Transform.rotate(
      angle: rotateOffset * (pi / 180),
      // angle: 0,
      child: Container(
        alignment: Alignment.center,
        height: height,
        width: 32,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
            // border: BorderSide(color: Colors.black87, width: 1),
            // 底部 border
            border: Border(
          bottom: BorderSide(color: Colors.yellow, width: 1),
        )),
        // decoration: BoxDecoration(
        // TODO: DevHelper Color
        // color: Colors.blue.withOpacity(.1)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RotatedBox(
              quarterTurns: 2,
              child: Container(
                  height: 56,
                  width: 24,
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: Colors.teal),
                  alignment: Alignment.center,
                  child: Column(
                      mainAxisAlignment: nameList.length > 1
                          ? MainAxisAlignment.spaceAround
                          : MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: nameList
                          .map(
                            (singleName) => Transform.rotate(
                                angle: pi / 180,
                                child: Text(
                                  singleName,
                                  style: textStyle,
                                )),
                          )
                          .toList())),
            ),
            const Expanded(child: SizedBox()),
            RotatedBox(
              quarterTurns: 2,
              child: Container(
                  height: 56,
                  width: 24,
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: Colors.cyan),
                  alignment: Alignment.center,
                  child: Column(
                      mainAxisAlignment: nameList.length > 1
                          ? MainAxisAlignment.spaceAround
                          : MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: nameList
                          .map(
                            (singleName) => Transform.rotate(
                                angle: pi / 180,
                                child: Text(
                                  singleName,
                                  style: textStyle,
                                )),
                          )
                          .toList())),
            ),
          ],
        ),
      ),
    );
  }

  Widget innerStarTrackRing(List<UIStarModel> uiFateStarList) {
    return Container(
      width: fateLifeStarOuterSize,
      height: fateLifeStarOuterSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(fateLifeStarOuterSize),
        border: Border.all(color: Colors.black87, width: 1),
      ),
      child: CustomPaint(
        size: Size(fateLifeStarOuterSize, fateLifeStarOuterSize), // 设置画布大小
        painter: InnerLifeStarRangePainter(
          stars: uiFateStarList,
          starsColorMap: QiZhengSiYuUIConstantResources.starsColorMap,
          outerSize: fateLifeStarOuterSize,
          innerSize: fateLifeStarInnerSize,
          trackSize: fateLifeStarTrackSize,
          textStyle: GoogleFonts.notoSans(
              fontSize: 24.0,
              height: 1,
              // color: Color.fromRGBO(55, 53, 52, 1),
              color: Colors.black87,
              fontWeight: FontWeight.normal,
              shadows: [
                BoxShadow(
                  color: Colors.black38.withOpacity(.3),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(1, 1), // changes position of shadow
                )
              ]),
        ),
      ),
    );
  }

  // Star body rotation functions have been extracted to
  // `qizhengsiyu/lib/widgets/star_body_ring.dart` as
  // `InnerStarBodyRotatingWidget` and `OuterStarBodyRotatingWidget`.

  Widget outerStarTrackRing(List<UIStarModel> uiBasicLifeStarList) {
    logger.d("-------- ${uiBasicLifeStarList.length}");
    logger.d(
        "---- ${uiBasicLifeStarList.map((e) => e.star.singleName).join(",")}");
    return Container(
      width: basicLifeStarRingOuterSize,
      height: basicLifeStarRingOuterSize,
      decoration: BoxDecoration(
        // color: Colors.yellow,
        borderRadius: BorderRadius.circular(basicLifeStarRingOuterSize),
        border: Border.all(color: Colors.black87, width: 1),
      ),
      child: CustomPaint(
        // size: Size(basicLifeStarCenterCircleSize + starBodyRadius * 4, basicLifeStarCenterCircleSize + starBodyRadius * 4), // 设置画布大小
        size: Size(
            basicLifeStarRingOuterSize, basicLifeStarRingOuterSize), // 设置画布大小
        painter: OuterLifeStarRangePainter(
          stars: uiBasicLifeStarList,
          starsColorMap: QiZhengSiYuUIConstantResources.starsColorMap,
          outerSize: basicLifeStarRingOuterSize,
          innerSize: basicLifeStarRingInnerSize,
          trackSize: basicLifeStarBodyTrackSize,
          textStyle: GoogleFonts.notoSans(
              fontSize: 24.0,
              height: 1,
              // color: Color.fromRGBO(55, 53, 52, 1),
              color: Colors.black87,
              fontWeight: FontWeight.normal,
              shadows: [
                BoxShadow(
                  color: Colors.black38.withOpacity(.3),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(1, 1), // changes position of shadow
                )
              ]),
        ),
      ),
    );
  }

  UIStarsAngle correctBasicLifeAngle(
      StarsAngle starsAngle, double basicLifeStarCenterCircleSize) {
    double? uiSunAngle;
    double? uiMoonAngle;
    double? uiVenusAngle;
    double? uiJupiterAngle;
    double? uiMarsAngle;
    double? uiSaturnAngle;
    double? uiWaterAngle;
    double? uiSouthNodeAngle;
    double? uiNorthNodeAngle;
    double? uiBeiNodeAngle;
    double? uiQiAngle;
    double miniCollisionDistance = 48;
    double cosValue =
        (2 * basicLifeStarCenterCircleSize * basicLifeStarCenterCircleSize -
                miniCollisionDistance * miniCollisionDistance) /
            (2 * basicLifeStarCenterCircleSize * basicLifeStarCenterCircleSize);
    double acosValue = acos(cosValue);
    double minCollision = acosValue * (180 / pi); // 当小于等于这个值时 两个星体碰撞

    double diffDegree = 0;
    if (starsAngle.venus < starsAngle.sun) {
      diffDegree = starsAngle.sun - starsAngle.venus;
    } else {
      diffDegree = starsAngle.venus - starsAngle.sun;
    }
    double needDegreeInTotal = minCollision - diffDegree;
    double needDegreeAddEach = needDegreeInTotal * .5;
    if (starsAngle.venus < starsAngle.sun) {
      uiSunAngle = starsAngle.sun + needDegreeAddEach;
      uiVenusAngle = starsAngle.venus - needDegreeAddEach;
    } else {
      uiSunAngle = starsAngle.sun - needDegreeAddEach;
      uiVenusAngle = starsAngle.venus + needDegreeAddEach;
    }

    // create UIStarsAngle from StarsAngle

    return UIStarsAngle.from(starsAngle,
        uiSunAngle: uiSunAngle,
        uiMoonAngle: uiMoonAngle,
        uiVenusAngle: uiVenusAngle,
        uiJupiterAngle: uiJupiterAngle,
        uiMarsAngle: uiMarsAngle,
        uiSaturnAngle: uiSaturnAngle,
        uiWaterAngle: uiWaterAngle,
        uiSouthNodeAngle: uiSouthNodeAngle,
        uiNorthNodeAngle: uiNorthNodeAngle,
        uiBeiNodeAngle: uiBeiNodeAngle,
        uiQiAngle: uiQiAngle);
  }

  Widget basicLifeStarPanelHelperCircle(double size) {
    return Container(
      width: size,
      height: size,
      // width: 520+32+10,
      // height: 520+32+10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size),
        border: Border.all(color: Colors.black.withOpacity(.1), width: 1),
      ),
    );
  }

  Widget fatePanelStarDefault(
      EnumStars star, double degree, double offsetWidth, double size,
      {int offsetWidthTimes = 0}) {
    Color backgroundColor = QiZhengSiYuUIConstantResources.starsColorMap[star]!;
    double oWidth = offsetWidth;
    if (offsetWidthTimes != 0) {
      if (offsetWidthTimes < 0) {
        int owt = offsetWidthTimes * -1;
        oWidth = offsetWidth + offsetWidth * (owt - 1) / 2;
      } else {
        oWidth = offsetWidth + offsetWidth * (offsetWidthTimes - 1) / 2;
      }
    }
    return Transform.rotate(
        angle: (120 - degree) * pi / 180,
        child: Container(
          width: 32 + oWidth,
          // height: 560,
          // height: 610,
          height: size,
          // color: Colors.blue.withOpacity(.1),
          alignment: Alignment.topCenter,
          child: ElTooltip(
            showModal: false,
            showChildAboveOverlay: false,
            content: const Text("tooltip"),
            child: CustomPaint(
              size: const Size(32, 650 - 600 - 4),
              painter: MyCirclePainter(
                  toOuter: true,
                  starName: star.singleName,
                  starAngle: degree,
                  // angle:((360-degree) * pi) / 180,
                  radians: ((360 - (120 - degree)) * pi) / 180,
                  offsetTimes: offsetWidthTimes,
                  backgroundColor: backgroundColor,
                  textStyle: GoogleFonts.notoSans(
                      fontSize: 20.0,
                      height: 1,
                      // color: Color.fromRGBO(55, 53, 52, 1),
                      color:
                          QiZhengSiYuUIConstantResources.starsColorMap[star]!,
                      fontWeight: FontWeight.normal,
                      shadows: [
                        BoxShadow(
                          color: Colors.black38.withOpacity(.1),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset:
                              const Offset(1, 1), // changes position of shadow
                        )
                      ])),
            ),
          ),
        ));
  }

  Widget lifePanelUIStarDefault(UIStarModel uiStar) {
    Color backgroundColor =
        QiZhengSiYuUIConstantResources.starsColorMap[uiStar.star]!;
    return Transform.rotate(
        angle: (120 - uiStar.angle) * pi / 180,
        child: Container(
          width: 32,
          height: 706,
          // color: Colors.blue.withOpacity(.1),
          alignment: Alignment.topCenter,
          child: ElTooltip(
            showModal: false,
            showChildAboveOverlay: false,
            content: const Text("tooltip"),
            // child: Container(),
            child: CustomPaint(
              size: const Size(32, 48),
              painter: StarBodyPainter(
                  star: uiStar,
                  // angle:((360-degree) * pi) / 180,
                  radians: ((360 - (120 - uiStar.angle)) * pi) / 180,
                  backgroundColor: backgroundColor,
                  textStyle: GoogleFonts.notoSans(
                      fontSize: 20.0,
                      height: 1,
                      // color: Color.fromRGBO(55, 53, 52, 1),
                      color: QiZhengSiYuUIConstantResources
                          .starsColorMap[uiStar.star]!,
                      fontWeight: FontWeight.normal,
                      shadows: [
                        BoxShadow(
                          color: Colors.black38.withOpacity(.3),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset:
                              const Offset(1, 1), // changes position of shadow
                        )
                      ])),
            ),
          ),
        ));
  }

  Widget lifePanelStarDefault(EnumStars star, double degree, double offsetWidth,
      {int offsetWidthTimes = 0}) {
    Color backgroundColor = QiZhengSiYuUIConstantResources.starsColorMap[star]!;
    return Transform.rotate(
        angle: (120 - degree) * pi / 180,
        child: Container(
          width: 32,
          // height: 560,
          // height: 610,
          // height: 610 + 64+32,
          height: 706,
          // color: Colors.blue.withOpacity(.1),
          alignment: Alignment.topCenter,
          child: ElTooltip(
            showModal: false,
            showChildAboveOverlay: false,
            content: const Text("tooltip"),
            child: FutureBuilder(
              future: loadImage(),
              builder: (
                ctx,
                asyncSnap,
              ) {
                return CustomPaint(
                  size: const Size(32, 650 - 600 - 4),
                  painter: MyCirclePainter(
                      starName: star.singleName,
                      starAngle: degree,
                      // angle:((360-degree) * pi) / 180,
                      radians: ((360 - (120 - degree)) * pi) / 180,
                      offsetTimes: offsetWidthTimes,
                      backgroundColor: backgroundColor,
                      textStyle: GoogleFonts.notoSans(
                          fontSize: 20.0,
                          height: 1,
                          // color: Color.fromRGBO(55, 53, 52, 1),
                          color: QiZhengSiYuUIConstantResources
                              .starsColorMap[star]!,
                          fontWeight: FontWeight.normal,
                          shadows: [
                            BoxShadow(
                              color: Colors.black38.withOpacity(.3),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: const Offset(
                                  1, 1), // changes position of shadow
                            )
                          ])),
                );
              },
            ),
          ),
        ));
  }

  Widget lifePanelStar(ElevenStarsInfo star, double offsetWidth,
      {int offsetWidthTimes = 0}) {
    Color backgroundColor =
        QiZhengSiYuUIConstantResources.starsColorMap[star.star]!;
    double oWidth = offsetWidth;
    if (offsetWidthTimes != 0) {
      if (offsetWidthTimes < 0) {
        int owt = offsetWidthTimes * -1;
        oWidth = offsetWidth + offsetWidth * (owt - 1) / 2;
      } else {
        oWidth = offsetWidth + offsetWidth * (offsetWidthTimes - 1) / 2;
      }
    }
    return Transform.rotate(
      // angle: (120 * pi) / 180,
      angle: 0,
      child: Transform.rotate(
          angle: (120 - star.angle) * pi / 180,
          child: Container(
            width: 32 + oWidth,
            // height: 560,
            // height: 610,
            height: 610 + 64 + 32,
            // color: Colors.blue.withOpacity(.1),
            alignment: Alignment.topCenter,
            child: ElTooltip(
              showModal: false,
              showChildAboveOverlay: false,
              content: const Text("tooltip"),
              child: FutureBuilder(
                future: loadImage(),
                builder: (
                  ctx,
                  asyncSnap,
                ) {
                  // if (asyncSnap.hasData && asyncSnap.data != null){
                  //   return CustomPaint(
                  //     size: Size(32, 650-600-4),
                  //     painter: PlanetPainter(
                  //         starName:starName,
                  //         angle:((360-degree) * pi) / 180,
                  //         offsetTimes: offsetWidthTimes,
                  //         image: asyncSnap.data!
                  //     ),
                  //   );
                  // }
                  // if (asyncSnap.hasError){
                  //   print(asyncSnap.error);
                  // }
                  return CustomPaint(
                    size: const Size(32, 650 - 600 - 4),
                    painter: MyCirclePainter(
                        starName: star.star.singleName,
                        // angle:((360-degree) * pi) / 180,
                        radians: ((360 - (120 - star.angle)) * pi) / 180,
                        starAngle: star.angle,
                        offsetTimes: offsetWidthTimes,
                        backgroundColor: backgroundColor,
                        textStyle: GoogleFonts.notoSans(
                            fontSize: 20.0,
                            height: 1,
                            // color: Color.fromRGBO(55, 53, 52, 1),
                            color: QiZhengSiYuUIConstantResources
                                .starsColorMap[star.star]!,
                            fontWeight: FontWeight.normal,
                            shadows: [
                              BoxShadow(
                                color: Colors.black38.withOpacity(.1),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: const Offset(
                                    1, 1), // changes position of shadow
                              )
                            ])),
                  );
                },
              ),
            ),
          )),
    );
  }

  Widget fatePanelStar(FiveStarWalkingInfo walkingInfo, double size) {
    Map<FiveStarWalkingType, Color> colorMap = {
      FiveStarWalkingType.Retrograde: Colors.black,
      FiveStarWalkingType.Fast: Colors.red,
      FiveStarWalkingType.Normal: Colors.blue,
      FiveStarWalkingType.Slow: Colors.brown,
      FiveStarWalkingType.Stay: Colors.blueGrey
    };
    Color backgroundColor = colorMap[walkingInfo.walkingType]!;
    double oWidth = 0;
    int offsetWidthTimes = 0;
    double offsetWidth = 0;
    if (offsetWidthTimes != 0) {
      if (offsetWidthTimes < 0) {
        int owt = offsetWidthTimes * -1;
        oWidth = offsetWidth + offsetWidth * (owt - 1) / 2;
      } else {
        oWidth = offsetWidth + offsetWidth * (offsetWidthTimes - 1) / 2;
      }
    }
    final textStyle = GoogleFonts.notoSans(
        fontSize: 20.0,
        height: 1,
        // color: Color.fromRGBO(55, 53, 52, 1),
        color: QiZhengSiYuUIConstantResources.zhengColorMap[walkingInfo.star]!,
        fontWeight: FontWeight.normal,
        shadows: [
          BoxShadow(
            color: Colors.black38.withOpacity(.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(1, 1), // changes position of shadow
          )
        ]);
    return Transform.rotate(
        angle: (120 - walkingInfo.angle) * pi / 180,
        child: Container(
          width: 32 + oWidth,
          height: size,
          // height: 610,
          // color: Colors.blue.withOpacity(.1),
          alignment: Alignment.topCenter,
          child: ElTooltip(
            showModal: false,
            showChildAboveOverlay: false,
            content: const Text("tooltip"),
            child: FutureBuilder(
              future: loadImage(),
              builder: (
                ctx,
                asyncSnap,
              ) {
                return CustomPaint(
                  size: const Size(32, 650 - 600 - 4),
                  painter: MyCirclePainter(
                      starName: walkingInfo.star.singleName,
                      // angle:((360-degree) * pi) / 180,
                      textStyle: textStyle,
                      radians: ((360 - (120 - walkingInfo.angle)) * pi) / 180,
                      starAngle: walkingInfo.angle,
                      offsetTimes: offsetWidthTimes,
                      backgroundColor: backgroundColor,
                      toOuter: true),
                );
              },
            ),
          ),
        ));
  }

  Future<ui.Image> loadImage() async {
    var data = await rootBundle.load(
        'assets/planets/mars-bubbles-50.png'); // Replace with your image path
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: 40, targetWidth: 42);
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  Widget star(String starName, double degree) {
    return Transform.rotate(
        angle: (degree * pi) / 180,
        child: Container(
          width: 32,
          // height: 560,
          height: 650,
          color: Colors.blue.withOpacity(.1),
          padding: const EdgeInsets.only(top: 8),
          alignment: Alignment.topCenter,
          child: Transform.rotate(
            angle: ((360 - degree) * pi) / 180,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black87.withOpacity(.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Text(
                starName,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.normal, height: 1),
              ),
            ),
          ),
        ));
  }

  // 二十八星宿 刻度环
  Widget starXiuRing(double size, double ringWidth) {
    double outerRadius = size / 2;
    return RepaintBoundary(
      child: Container(
          width: size, //
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(.4), width: 1),
            // color: Colors黑...withOpacity(.1),
            borderRadius: BorderRadius.circular(outerRadius),
          ),
          child: CustomPaint(
            size: Size(size, size),
            painter: StarXiuRingPainter(
              outerSize: starXiu28RingSizeOuter,
              innerSize: starXiu28RingSizeInner,
              mapper: QiZhengSiYuConstantResources
                  .ZodiacTropicalModernStarsInnSystemMapper,
              sevenZhengColorMapper:
                  QiZhengSiYuUIConstantResources.zhengColorMap,
            ),
          )),
    );
  }

  Widget rulingRing(double size, double ringWidth) {
    double outerRadius = size / 2;
    return RepaintBoundary(
      child: Align(
        alignment: Alignment.center,
        child: Stack(
          children: [
            Container(
                width: size, //
                height: size,
                alignment: Alignment.center,
                child: CustomPaint(
                  size: Size(size, size),
                  painter: IndicatorScalePainter(
                      ringWidth: ringWidth,
                      tickLength: 7,
                      indicatorAngle: 45.1),
                )),
            Container(
                width: size, //
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.grey.withOpacity(.4), width: 1),
                  // color: Colors黑...withOpacity(.1),
                  borderRadius: BorderRadius.circular(outerRadius),
                ),
                child: CustomPaint(
                  size: Size(size, size),
                  painter: StarXiuRingPainter(
                    outerSize: starXiu28RingSizeOuter,
                    innerSize: starXiu28RingSizeInner,
                    mapper: QiZhengSiYuConstantResources
                        .ZodiacTropicalModernStarsInnSystemMapper,
                    sevenZhengColorMapper:
                        QiZhengSiYuUIConstantResources.zhengColorMap,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget drawRing(double size, double ringWidth, List<String> contentList,
      TextStyle textStyle,
      {double innerPadding = 2}) {
    double outerRadius = size / 2;
    double innerRadius = outerRadius - ringWidth;
    return Container(
        alignment: Alignment.center,
        height: size,
        width: size,
        decoration: BoxDecoration(
          // color: Colors.red.withOpacity(.1),
          borderRadius: BorderRadius.circular(size),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Transform.rotate(
          angle: 105 * pi / 180,
          origin: Offset.zero,
          child: CustomPaint(
            size: Size(size, size),
            painter: CircleRingPainter(
              innerRadius: innerRadius,
              outerRadius: outerRadius,
              textList: contentList,
              isAntiClockwise: true,
              innerPadding: innerPadding,
              isReverseText: false,
              isHorizontalText: true,
              textStyle: textStyle.copyWith(height: 1.2),
            ),
          ),
        ));
  }

  // 命理十二宫环已抽取为组件：`DestinyTwelveGongRingWidget`，位于
  // `qizhengsiyu/lib/widgets/destiny_twelve_gong_ring.dart`。

  // 命理十二宫宫位单元已抽取至组件私有方法，参见
  // `DestinyTwelveGongRingWidget._eachDestiny12Gong`。

  // 命理十二宫文本环（纯文本演示）已移除，统一使用组件构建。

  // 命理十二宫选中太极环已抽取为组件：`SelectedTaiJiDestinyTwelveGongRingWidget`，位于
  // `qizhengsiyu/lib/widgets/destiny_twelve_gong_ring.dart`。

  // Grid-only ring is now provided by `TwelveGongGridRingWidget` in
  // `qizhengsiyu/lib/widgets/twelve_gong_grid_ring.dart`.

  // 文本环已抽取为组件：`TwelveGongTextRingWidget`，位于
  // `qizhengsiyu/lib/widgets/twelve_gong_text_ring.dart`。

  // 周天12宫
  Widget zhouTian12GongRing(double innerSize, double outerSize) {
    return zodicalRing(innerSize, outerSize);
  }

  Widget zodicalRing(double innerSize, double outerSize) {
    return generateDefault12GongRing(
        innerSize, outerSize, defaultZodiac12GongMapper);
  }

  Widget starSeqRing(double innerSize, double outerSize) {
    return generateDefault12GongRing(
        innerSize, outerSize, defaultStarSeq12GongMapper);
  }

  Widget buildMingLi12GongRing(double innerSize, double outerSize) {
    return Stack(
      children: [
        ValueListenableBuilder<BasePanelModel?>(
          valueListenable:
              context.read<QiZhengSiYuViewModel>().uiBasePanelNotifier,
          builder: (ctx, basePanel, child) {
            final List<String> contentList = basePanel == null
                ? defaultDestiny12GongMapper.values
                    .map((arr) => arr.first)
                    .toList(growable: false)
                : basePanel.twelveGongMapper.values
                    .map((v) => v.name)
                    .toList(growable: false);
            return DestinyTwelveGongRingWidget(
              innerSize: innerSize,
              outerSize: outerSize,
              contentList: contentList,
              textStyle: destinyTextStyle,
              showTaiJiButtonNotifier: showTaiJiDianButtonNotifier,
              onSelectTaiJiByGongName: selectTaiJiDestinyByGongName,
              onUnselectTaiJi: unselectTaiJiDestiny,
            );
          },
        ),
        ValueListenableBuilder<List<String>?>(
          valueListenable: _selectedTaiJiDestiny12GongListNotifier,
          builder: (ctx, selectedList, child) {
            return SelectedTaiJiDestinyTwelveGongRingWidget(
              innerSize: innerSize,
              outerSize: outerSize,
              contentList: selectedList,
              textStyle: destinyTextStyle,
              showTaiJiDianButtonNotifier: showTaiJiDianButtonNotifier,
              onSelectTaiJi: selectTaiJiDestiny,
              onUnselectTaiJi: unselectTaiJiDestiny,
            );
          },
        ),
      ],
    );
  }

  Map<EnumTwelveGong, List<String>> defaultStarSeq12GongMapper = {
    EnumTwelveGong.Zi: ["玄枵"],
    EnumTwelveGong.Chou: ["星纪"],
    EnumTwelveGong.Yin: ["析木"],
    EnumTwelveGong.Mao: ["大火"],
    EnumTwelveGong.Chen: ["寿星"],
    EnumTwelveGong.Si: ["鹑尾"],
    EnumTwelveGong.Wu: ["鹑火"],
    EnumTwelveGong.Wei: ["鹑首"],
    EnumTwelveGong.Shen: ["实沈"],
    EnumTwelveGong.You: ["大梁"],
    EnumTwelveGong.Xu: ["降娄"],
    EnumTwelveGong.Hai: ["娵訾"],
  };

  Map<EnumTwelveGong, List<String>> defaultZodiac12GongMapper = {
    EnumTwelveGong.Zi: ["水瓶"],
    EnumTwelveGong.Chou: ["摩羯"],
    EnumTwelveGong.Yin: ["射手"],
    EnumTwelveGong.Mao: ["天蝎"],
    EnumTwelveGong.Chen: ["天枰"],
    EnumTwelveGong.Si: ["处女"],
    EnumTwelveGong.Wu: ["狮子"],
    EnumTwelveGong.Wei: ["巨蟹"],
    EnumTwelveGong.Shen: ["双子"],
    EnumTwelveGong.You: ["金牛"],
    EnumTwelveGong.Xu: ["白羊"],
    EnumTwelveGong.Hai: ["双鱼"],
  };

  Map<EnumTwelveGong, List<String>> defaultDestiny12GongMapper = {
    EnumTwelveGong.Zi: ["命宫"],
    EnumTwelveGong.Chou: ["相貌"],
    EnumTwelveGong.Yin: ["福德"],
    EnumTwelveGong.Mao: ["官禄"],
    EnumTwelveGong.Chen: ["迁移"],
    EnumTwelveGong.Si: ["疾厄"],
    EnumTwelveGong.Wu: ["夫妻"],
    EnumTwelveGong.Wei: ["奴仆"],
    EnumTwelveGong.Shen: ["男女"],
    EnumTwelveGong.You: ["田宅"],
    EnumTwelveGong.Xu: ["兄弟"],
    EnumTwelveGong.Hai: ["财帛"],
  };
  // 默认十二宫环构建函数已迁移至：
  // `qizhengsiyu/lib/widgets/twelve_gong_default_ring.dart`。
  // 继续使用同名方法 `generateDefault12GongRing`。

  Widget draw12GongRing(
      double innerSize, double outerSize, List<Text> contentList,
      {double innerPadding = 2}) {
    double outerRadius = outerSize * .5;
    double innerRadius = innerSize * .5;
    return Container(
        alignment: Alignment.center,
        height: outerSize,
        width: outerSize,
        decoration: BoxDecoration(
          // color: Colors.red.withOpacity(.1),
          borderRadius: BorderRadius.circular(outerSize),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Transform.rotate(
          angle: 75 * pi / 180,
          // angle: 0,
          origin: Offset.zero,
          child: CustomPaint(
            size: Size(outerSize, outerSize),
            painter: RingSheetPainter(
              innerRadius: innerRadius,
              outerRadius: outerRadius,
            ),
            // painter:TextCircleRingPainter(
            //   innerRadius: innerRadius,
            //   outerRadius: outerRadius,
            //   textList: contentList,
            //   isAntiClockwise: true,
            //   innerPadding: 0,
            //   isReverseText: false,
            //   isHorizontalText: true,
            // ),
          ),
        ));
  }

  Widget drawRingWithTextList(
      double size, double ringWidth, List<Text> contentList,
      {double innerPadding = 2}) {
    double outerRadius = size / 2;
    double innerRadius = outerRadius - ringWidth;
    return Container(
        alignment: Alignment.center,
        height: size,
        width: size,
        decoration: BoxDecoration(
          // color: Colors.red.withOpacity(.1),
          borderRadius: BorderRadius.circular(size),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Transform.rotate(
          angle: 75 * pi / 180,
          origin: Offset.zero,
          child: CustomPaint(
            size: Size(size, size),
            painter: TextCircleRingPainter(
              innerRadius: innerRadius,
              outerRadius: outerRadius,
              textList: contentList,
              isAntiClockwise: true,
              innerPadding: innerPadding,
              isReverseText: false,
              isHorizontalText: true,
            ),
          ),
        ));
  }

  /// gongIndex 0-11 子-亥
  void selectTaiJiDestinyByGongName(String selectedGongName) {
    // 根据给定gongIndex
    List<String> tmpDefaultList = destinyList.map((d) => d).toList();
    List<String> tmpDestinyList =
        _destiny12GongListNotifier.value.map((d) => d).toList();
    int selectedIndex = _destiny12GongListNotifier.value
        .indexWhere((x) => x == selectedGongName);
    String taiJiAtGong = _destiny12GongListNotifier.value[selectedIndex];
    logger.i("user select as TaiJi, which is $taiJiAtGong");
    int index = tmpDefaultList.indexOf(taiJiAtGong);
    // 将_tmpList 从 gongIndex 处分成两个

    List<String> tmpList1 = tmpDefaultList.sublist(12 - index);
    List<String> tmpList2 = tmpDefaultList.sublist(0, 12 - index);
    logger.d("_tmpList1 $tmpList1");
    logger.d("_tmpList2 $tmpList2");
    // 将_tmpList2 拼接在 _tmpList1 前面
    _selectedTaiJiDestiny12GongListNotifier.value = tmpList1 + tmpList2;
    logger.i(_selectedTaiJiDestiny12GongListNotifier.value);
  }

  /// gongIndex 0-11 子-亥
  void selectTaiJiDestiny(int selectedIndex) {
    // 根据给定gongIndex
    List<String> tmpDefaultList = destinyList.map((d) => d).toList();
    List<String> tmpDestinyList =
        _destiny12GongListNotifier.value.map((d) => d).toList();
    String taiJiAtGong = _destiny12GongListNotifier.value[selectedIndex];
    logger
        .i("user select index:$selectedIndex as TaiJi, which is $taiJiAtGong");
    int index = tmpDefaultList.indexOf(taiJiAtGong);
    // 将_tmpList 从 gongIndex 处分成两个

    List<String> tmpList1 = tmpDefaultList.sublist(12 - index);
    List<String> tmpList2 = tmpDefaultList.sublist(0, 12 - index);
    logger.d("_tmpList1 $tmpList1");
    logger.d("_tmpList2 $tmpList2");
    // 将_tmpList2 拼接在 _tmpList1 前面
    _selectedTaiJiDestiny12GongListNotifier.value = tmpList1 + tmpList2;
    logger.i(_selectedTaiJiDestiny12GongListNotifier.value);
  }

  void unselectTaiJiDestiny() {
    _selectedTaiJiDestiny12GongListNotifier.value = null;
  }
}
