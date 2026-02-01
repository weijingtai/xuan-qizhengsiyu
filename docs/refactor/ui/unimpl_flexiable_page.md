总体建议

- 将盘面从“页面”变为“可复用的核心组件”，页面只是容器组合与导航。核心盘面组件保持纯 UI，可在多个页面或卡片中嵌入。
- 建立统一的“面板控制器 + 配置”体系，让不同星盘制式、不同数据源都能用同一套组件组合展示。
- 引入自适应布局方案：尺寸、半径、文字密度、间距等不再是固定像素，而是基于容器尺寸按比例计算，适配不同分辨率与窗口大小。
- 卡片区采用栅格/Sliver 组合，支持未来的“四柱八字”“流年调整”等可编辑卡片的灵活布局与交互。
组件化方案

- 核心盘面组件
  - PanelWidget ：统一的盘面骨架，仅负责布局与层级组合（环、星体、中心）。
  - RingLayer 系列： Destiny12Ring 、 DiZhi12Ring 、 Zodiac12Ring 、 StarXiu28Ring （外观统一、接口统一）。
  - StarBodiesLayer 、 StarTrailsLayer ：星体主体与轨迹，接受 UIStarModel 列表与样式配置。
  - 全部组件只依赖入参，不直接读取 ViewModel；页面壳使用 ValueListenableBuilder / Provider 订阅并传参。
- 配置与控制
  - PanelSizeConfig ：盘面尺寸令牌（半径比例、字体、密度、间距），环半径用“容器 size × factor”计算。
  - PanelConstants/Mappers ：默认文案与 mapper（如 defaultDestiny12GongMapper ），集中管理，避免分散硬编码。
  - PanelController ：统一控制旋转、选择态、叠加层开关（如“太极点”按钮、提示层），便于在 PageView 多 Tab 场景下复用。
自适应布局

- 布局容器
  - LayoutBuilder + AspectRatio 控制盘面画布；半径按 min(width, height) 的比例计算，保证圆形不被拉伸。
  - 依据 breakpoints（如 <=600 手机、 600-1024 平板、 >=1024 桌面）调整密度、字体大小、文字环内外分配策略。
- 栅格与滚动
  - 页面用 CustomScrollView + SliverToBoxAdapter/SliverGrid/SliverList 组合盘面与卡片区。
  - 小屏优先滚动展示（盘面在上，卡片在下）；大屏采用两列或三列布局（盘面居中，卡片左右分布）。
- 文本与排版
  - 文字沿环绘制（ TextCircleRingPainter ）的字号/间距按容器尺寸动态设定。
  - GongShenShaRing/ShenShaRingV2 的内外环分配策略随屏幕密度调整（密集时优先分外环且缩短文本）。
多星盘制式

- 统一接口
  - 页面使用 TabBar + PageView ，每个 Tab 传入不同 PanelConfig （如回归制、恒星制、不同定命/定身规则）。
  - PanelWidget 不关心制式，只渲染输入的 BasePanelModel/DaXianPanelModel + mapper；差异通过配置和 mapper 注入。
- 数据驱动
  - Tab 切换时，由页面层触发 BeautyPageViewModel.calculate() 或缓存结果， PanelWidget 仅负责展示。
  - 支持同一出生时间的多制式并存：复用一个盘面组件，配置切换不同序列与绘制策略。
卡片区设计

- 统一卡片组件
  - InfoCard 基类：标题、内容、操作区（按钮/开关表单）、状态提示。
  - FourPillarsCard ：四柱八字卡片；未来支持“展开更多细节”和“进入详解”。
  - LiuNianAdjustCard ：流年调整卡片；编辑表单（选择年份/星次/权重/开关），实时影响盘面展示。
- 布局策略
  - 小屏纵向单列；平板两列；桌面自适应三列栅格（ SliverGrid 或 LayoutGrid ）。
  - 卡片支持“粘性”挂靠（ StickyHeader 效果）在盘面侧边或下方，便于交互。
交互与状态

- 太极选择
  - 抽象 TaiJiDestinyLogic + ValueNotifier<List<String>> 输出； Destiny12Ring 只订阅并渲染按钮状态。
  - 鼠标悬停显示按钮、点击选择/取消；移动端改为长按或菜单操作。
- Tooltip 与上下文菜单
  - 星体/神煞文本统一使用 Tooltip 组件；桌面显示悬停，移动端显示点击；内容由页面层传入。
- 叠加层与动画
  - RepaintBoundary 包裹各层，减少不必要重绘。
  - 旋转与淡入淡出使用 AnimatedBuilder/ImplicitlyAnimated ，避免整页刷新。
性能优化

- 绘制优化
  - CustomPainter.shouldRepaint 精准控制；按入参比较（半径/文本/颜色/角度）决定重绘。
  - 分层 RepaintBoundary ：星体层、文字环层、网格层；只在对应数据变更时重绘。
- 缓存与预生成
  - 固定文案环（如周天十二宫、二十八宿）在首次渲染后缓存路径与布局；缩放时按比例变换，减少重复测量。
- 刷新与订阅
  - 使用细粒度 ValueListenableBuilder ，只重建改变的组件；例如仅 uiBasicLifeStarsNotifier 变化时刷新星体层，不影响文字环。
测试与预览

- 快速回归
  - 给每个环组件添加 demo 构造器（传固定 mapper），用于单独预览确认视觉。
  - 添加断言测试验证角度分配与文本布局策略在不同容器尺寸下不崩溃。
- 预览方法
  - 集成到一个 PanelPreviewPage ，支持切换 PanelSizeConfig 和 mapper ；用于比对重构前后视觉。
你可能没考虑到的点

- 键盘和无鼠标环境：为“太极点”“流年调整”提供键盘导航与焦点样式，保证可用性。
- 国际化与多字体：文本沿环排版需要考虑不同语言的字宽与断行策略；提前抽象 TextMeasurer 。
- 弹性密度与拥挤策略：当屏幕太小，神煞项目太多时，提供折叠、分页或缩略显示策略，避免文字重叠。
- 缩放与拖动：后期可以提供盘面缩放/拖动手势（移动端），但现阶段先稳住静态布局。
- 打印/导出：盘面作为纯组件更容易导出图片或 PDF；建议在绘制层保留导出接口。
下一步行动

- 将现有盘面改造为 PanelWidget （骨架组件），页面壳仅做数据订阅与组合。
- 抽取四类环组件，并统一入参与样式；迁移默认 mapper 与尺寸常量到 config 。
- 用 LayoutBuilder + 比例半径改造尺寸计算，适配不同分辨率；建立三档 breakpoints。
- 在 PageView + TabBar 中复用 PanelWidget ，以不同 PanelConfig /mapper 展示多制式。
- 增加卡片区（先放占位 InfoCard ），保持未来扩展（四柱、流年调整）接口稳定。
如果你愿意，我可以先起 PanelWidget 雏形与一个 Destiny12Ring 组件封装，把当前盘面替换为新组件结构；完成后我们做一次预览比对，确认视觉不变，再逐步迁出其他环与星体层。


很好的问题。保持“组件只依赖入参”的前提下，这类“鼠标交互+辅助线”的功能可以通过一个专用的叠加层组件来实现：页面壳负责把鼠标位置转换成“角度入参”，盘面组件只接受角度并绘制，不直接读取 ViewModel。这既简洁又高效。

实现思路

- 增加一个 RadialGuidesLayer 叠加层，用于捕获鼠标/触控位置、计算与圆心的角度，并用 CustomPainter 绘制“当前指向”半径线与“每45°导向线”。
- PanelWidget 保持纯展示；页面壳在 Stack 中把盘面与 RadialGuidesLayer叠加。这样各 Tab、卡片都能灵活复用，不耦合数据层。
- 支持统一旋转偏移和自适应尺寸：所有线条按容器 Size 比例计算半径，兼容不同屏幕分辨率。
组件 API 设计

- RadialGuidesLayer（Stateful）
  - child: Widget（被叠加的盘面）
  - enabled: bool（开关）
  - rotationDeg: double（与盘面一致的旋转偏移）
  - fixedStepDeg: double（默认 45）
  - showFixedGuides: bool（是否显示固定导向线）
  - color/strokeWidth/padding：样式控制
  - onAngleChanged: ValueChanged
    （回调给外层，必要时联动其他 UI）


```dart
    import 'dart:math' as math;
import 'package:flutter/material.dart';

class RadialGuidesLayer extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final double rotationDeg;
  final double fixedStepDeg;
  final bool showFixedGuides;
  final Color color;
  final double strokeWidth;
  final double padding;
  final ValueChanged<double>? onAngleChanged;

  const RadialGuidesLayer({
    super.key,
    required this.child,
    this.enabled = true,
    this.rotationDeg = 0,
    this.fixedStepDeg = 45,
    this.showFixedGuides = true,
    this.color = const Color(0xFFEF4444),
    this.strokeWidth = 1.5,
    this.padding = 8,
    this.onAngleChanged,
  });

  @override
  State<RadialGuidesLayer> createState() => _RadialGuidesLayerState();
}

class _RadialGuidesLayerState extends State<RadialGuidesLayer> {
  final GlobalKey _overlayKey = GlobalKey();
  double? _angleDeg; // null 表示不展示当前指向线

  void _updateAngle(Offset globalPosition) {
    if (!widget.enabled) return;
    final ctx = _overlayKey.currentContext;
    if (ctx == null) return;

    final box = ctx.findRenderObject() as RenderBox;
    final local = box.globalToLocal(globalPosition);
    final size = box.size;
    final center = Offset(size.width / 2, size.height / 2);
    final dx = local.dx - center.dx;
    final dy = local.dy - center.dy;

    var deg = math.atan2(dy, dx) * 180 / math.pi;
    if (deg < 0) deg += 360; // 归一化到 [0,360)
    setState(() => _angleDeg = deg);
    if (widget.onAngleChanged != null) {
      widget.onAngleChanged!(deg);
    }
  }

  void _clearAngle() {
    setState(() => _angleDeg = null);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 被叠加的盘面
        RepaintBoundary(child: widget.child),
        // 叠加层：捕获指针并绘制辅助线
        Positioned.fill(
          child: Container(
            key: _overlayKey,
            // 捕获鼠标悬停/移动/触控拖动
            child: Listener(
              onPointerHover: (e) => _updateAngle(e.position),
              onPointerMove: (e) => _updateAngle(e.position),
              onPointerDown: (e) => _updateAngle(e.position),
              child: MouseRegion(
                onExit: (e) => _clearAngle(),
                child: CustomPaint(
                  painter: _RadialGuidesPainter(
                    angleDeg: _angleDeg,
                    rotationDeg: widget.rotationDeg,
                    fixedStepDeg: widget.fixedStepDeg,
                    showFixedGuides: widget.showFixedGuides,
                    color: widget.color,
                    strokeWidth: widget.strokeWidth,
                    padding: widget.padding,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RadialGuidesPainter extends CustomPainter {
  final double? angleDeg;
  final double rotationDeg;
  final double fixedStepDeg;
  final bool showFixedGuides;
  final Color color;
  final double strokeWidth;
  final double padding;

  _RadialGuidesPainter({
    required this.angleDeg,
    required this.rotationDeg,
    required this.fixedStepDeg,
    required this.showFixedGuides,
    required this.color,
    required this.strokeWidth,
    required this.padding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - padding;
    final basePaint = Paint()
      ..color = color.withOpacity(0.25)
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;
    final strongPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth * 1.5
      ..isAntiAlias = true;

    // 固定导向线（每 fixedStepDeg 度一条）
    if (showFixedGuides && fixedStepDeg > 0) {
      for (double d = 0; d < 360; d += fixedStepDeg) {
        final rad = (d + rotationDeg) * math.pi / 180;
        final end = center + Offset(math.cos(rad) * radius, math.sin(rad) * radius);
        canvas.drawLine(center, end, basePaint);
      }
    }

    // 当前指向线（从圆心到鼠标所在角度）
    if (angleDeg != null) {
      final rad = (angleDeg! + rotationDeg) * math.pi / 180;
      final end = center + Offset(math.cos(rad) * radius, math.sin(rad) * radius);
      canvas.drawLine(center, end, strongPaint);
      // 端点小圆，增强感知
      canvas.drawCircle(end, strokeWidth * 1.8, strongPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadialGuidesPainter old) {
    return angleDeg != old.angleDeg ||
        rotationDeg != old.rotationDeg ||
        fixedStepDeg != old.fixedStepDeg ||
        showFixedGuides != old.showFixedGuides ||
        color != old.color ||
        strokeWidth != old.strokeWidth ||
        padding != old.padding;
  }
}
```
```dart
class PanelMainWidget extends StatelessWidget {
  const PanelMainWidget({
    super.key,
    required this.sizeConfig,
    required this.basePanel,
    required this.daXianPanel,
    required this.basicStars,
    required this.fateStars,
    this.rotationDeg = 0,
  });

  final PanelSizeConfig sizeConfig;
  final BasePanelModel? basePanel;
  final DaXianPanelModel? daXianPanel;
  final List<UIStarModel> basicStars;
  final List<UIStarModel> fateStars;
  final double rotationDeg;

  @override
  Widget build(BuildContext context) {
    // 这里用现有的各 Ring/Star 层组件组合出盘面
    final panel = /* 你的盘面组合组件 */ Container(color: Colors.transparent);

    return RadialGuidesLayer(
      child: panel,
      rotationDeg: rotationDeg,
      fixedStepDeg: 45,
      showFixedGuides: true,
      enabled: true, // 支持开关
      onAngleChanged: (deg) {
        // 需要的话，将角度回传给外层（例如显示在状态栏）
      },
    );
  }
}
```

为何简洁高效

- 组件只依赖入参：盘面组件不用关心鼠标、只画它的内容；但我们通过叠加层把交互转化为“角度入参”，保持纯粹。
- 性能好：叠加层 RepaintBoundary 分层， shouldRepaint 仅角度/样式变化时重绘；固定导向线是轻量线段绘制。
- 易扩展：后续可加入“角度读数”、“锁定某角度”、“角度吸附（如 15°/30°）”等高级功能，叠加层即可完成。
多制式与多 Tab 场景

- 每个 Tab 的 PanelWidget 都包一层 RadialGuidesLayer；不同制式通过传不同 rotationDeg 与 sizeConfig 即可保持一致体验。
- PageView 切换时不需要重新实例化叠加层，保留局部状态即可；或选择统一在页面壳管理角度状态。
自适应与移动端

- 角度计算使用容器 Size，不依赖固定像素；不同分辨率下半径和线长自适应。
- 移动端通过 Listener.onPointerMove/onPointerDown 同样支持拖动显示指向线；MouseRegion 仅桌面有效，移动端无阻碍。