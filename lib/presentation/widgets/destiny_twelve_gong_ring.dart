import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 命理十二宫环（交互版）：支持“转太极”和选中状态显示。
class DestinyTwelveGongRingWidget extends StatelessWidget {
  final double innerSize;
  final double outerSize;
  final List<String> contentList; // 12项：命宫、财帛、兄弟...
  final List<String>? zhuanTaiJiList; // 如果不为空，则每宫显示对应的“转太极后的宫名”
  final ValueNotifier<bool>? showTaiJiButtonNotifier; // 鼠标悬停时显示“转太极”按钮
  final TextStyle textStyle; // 页面传入的命理字体样式
  final void Function(String gongName) onSelectTaiJiByGongName;
  final VoidCallback onUnselectTaiJi;

  const DestinyTwelveGongRingWidget({
    super.key,
    required this.innerSize,
    required this.outerSize,
    required this.contentList,
    required this.onSelectTaiJiByGongName,
    required this.onUnselectTaiJi,
    this.zhuanTaiJiList,
    this.showTaiJiButtonNotifier,
    this.textStyle = const TextStyle(
      color: Colors.black87,
      fontSize: 28,
      fontWeight: FontWeight.normal,
      height: 1.0,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 30 * pi / 180,
      child: ClipOval(
        child: MouseRegion(
          hitTestBehavior: HitTestBehavior.translucent,
          onEnter: (event) {
            if (showTaiJiButtonNotifier != null) {
              showTaiJiButtonNotifier!.value = true;
            }
          },
          onExit: (event) {
            if (showTaiJiButtonNotifier != null) {
              showTaiJiButtonNotifier!.value = false;
            }
          },
          child: Semantics(
            explicitChildNodes: true,
            child: Container(
              alignment: Alignment.center,
              height: outerSize,
              width: outerSize,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(outerSize),
              ),
              child: Stack(
                children: [
                  ...List.generate(
                    12,
                    (i) => Transform.rotate(
                      angle: -(i * 30 + 75) * pi / 180,
                      origin: Offset.zero,
                      child: _eachDestiny12Gong(
                        context,
                        gongName: contentList[i],
                        zhuanTaiJiGongName:
                            zhuanTaiJiList != null ? zhuanTaiJiList![i] : null,
                        reversedDisplay: i >= 3 && i <= 8,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _eachDestiny12Gong(
    BuildContext context, {
    required String gongName,
    required String? zhuanTaiJiGongName,
    required bool reversedDisplay,
  }) {
    Widget taiJiButton;
    if (zhuanTaiJiGongName == null) {
      // 未选择太极：显示“转太极”按钮，受鼠标悬停显隐控制
      final baseButton = Text(
        "转太极",
        style: textStyle.copyWith(
          fontSize: 18,
          color: Colors.teal,
          fontWeight: FontWeight.w300,
          decorationStyle: ui.TextDecorationStyle.solid,
        ),
      );
      Widget content;
      if (showTaiJiButtonNotifier != null) {
        content = ValueListenableBuilder<bool>(
          valueListenable: showTaiJiButtonNotifier!,
          builder: (ctx, show, _) {
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: show ? .6 : .2,
              child: baseButton,
            );
          },
        );
      } else {
        content = AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: .2,
          child: baseButton,
        );
      }
      taiJiButton = InkWell(
        borderRadius: BorderRadius.circular(48),
        onTap: () => onSelectTaiJiByGongName(gongName),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          width: 64,
          alignment: Alignment.center,
          child: content,
        ),
      );
    } else {
      // 已选择太极：显示结果以及清除按钮
      taiJiButton = InkWell(
        onTap: onUnselectTaiJi,
        child: Container(
          width: 64,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(child: SizedBox()),
              Text(
                zhuanTaiJiGongName,
                style: textStyle.copyWith(
                  fontSize: 18,
                  color: zhuanTaiJiGongName == "命宫"
                      ? Colors.red
                      : (textStyle.color ?? Colors.black87),
                  fontWeight: zhuanTaiJiGongName == "命宫"
                      ? FontWeight.w500
                      : FontWeight.w300,
                  decorationStyle: ui.TextDecorationStyle.solid,
                ),
              ),
              InkWell(
                onTap: onUnselectTaiJi,
                child: const Icon(Icons.dangerous_outlined,
                    size: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final Widget gong = AnimatedOpacity(
      opacity: zhuanTaiJiGongName == null ? 1 : .4,
      duration: const Duration(milliseconds: 200),
      child: Text(
        gongName,
        style: textStyle.copyWith(
          color: gongName == "命宫"
              ? Colors.red
              : (textStyle.color ?? Colors.black87),
        ),
      ),
    );

    final List<Widget> widgets = [];
    if (reversedDisplay) {
      widgets.addAll([taiJiButton, gong]);
    } else {
      widgets.addAll([gong, taiJiButton]);
    }

    return Column(
      children: [
        const Expanded(child: SizedBox()),
        Transform.rotate(
          angle: reversedDisplay ? pi : 0,
          child: Container(
            alignment: Alignment.bottomCenter,
            width: 64, // 增加容器宽度，给文字更多空间
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widgets,
            ),
          ),
        ),
        const SizedBox(height: 4), // 增加文字距离外边缘的间距，避免压线
      ],
    );
  }
}

/// 命理十二宫环（选择太极点版）：当 contentList 为 null 时，显示可点击的“太极点”。
class SelectedTaiJiDestinyTwelveGongRingWidget extends StatelessWidget {
  final double innerSize;
  final double outerSize;
  final List<String>? contentList; // null 表示显示“太极点”供选择
  final ValueListenable<bool>? showTaiJiDianButtonNotifier; // 控制“太极点”显隐
  final void Function(int selectedIndex) onSelectTaiJi; // 选择太极点回调
  final VoidCallback onUnselectTaiJi; // 清除选择回调
  final TextStyle textStyle;

  const SelectedTaiJiDestinyTwelveGongRingWidget({
    super.key,
    required this.innerSize,
    required this.outerSize,
    required this.onSelectTaiJi,
    required this.onUnselectTaiJi,
    this.contentList,
    this.showTaiJiDianButtonNotifier,
    this.textStyle = const TextStyle(
      color: Colors.black87,
      fontSize: 28,
      fontWeight: FontWeight.normal,
      height: 1.0,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 30 * pi / 180,
      child: Container(
        alignment: Alignment.center,
        height: outerSize,
        width: outerSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(outerSize),
        ),
        child: Stack(
          children: [
            if (contentList != null)
              ...List.generate(
                12,
                (i) => Transform.rotate(
                  angle: -(i * 30 + 75) * pi / 180,
                  origin: Offset.zero,
                  child: Column(
                    children: [
                      const Expanded(child: SizedBox()),
                      Transform.rotate(
                        angle: (i >= 3 && i <= 9) ? pi : 0,
                        child: Container(
                          height: 42,
                          width: 64,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Expanded(child: SizedBox()),
                              Text(
                                contentList![i],
                                style: textStyle.copyWith(
                                  fontSize: 18,
                                  color: contentList![i] == "命宫"
                                      ? Colors.red
                                      : Colors.black45,
                                  fontWeight: contentList![i] == "命宫"
                                      ? FontWeight.w500
                                      : FontWeight.w300,
                                  decorationStyle: ui.TextDecorationStyle.solid,
                                ),
                              ),
                              InkWell(
                                onTap: onUnselectTaiJi,
                                child: const Icon(Icons.dangerous_outlined,
                                    size: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28), // 增加间距,避免文字压线
                    ],
                  ),
                ),
              )
            else
              ...List.generate(
                12,
                (i) => Transform.rotate(
                  angle: -(i * 30 + 75) * pi / 180,
                  origin: Offset.zero,
                  child: Column(
                    children: [
                      const Expanded(child: SizedBox()),
                      Transform.rotate(
                        angle: (i >= 3 && i <= 8) ? pi : 0,
                        child: InkWell(
                          onTap: () => onSelectTaiJi(i),
                          child: _buildTaiJiDianButton(context),
                        ),
                      ),
                      const SizedBox(height: 20), // 增加间距，保持一致性
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaiJiDianButton(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      width: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.teal[100]!.withOpacity(.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        "太极点",
        style: textStyle.copyWith(
          fontSize: 18,
          color: Colors.black45,
          fontWeight: FontWeight.w300,
          decorationStyle: ui.TextDecorationStyle.solid,
        ),
      ),
    );

    if (showTaiJiDianButtonNotifier != null) {
      return ValueListenableBuilder<bool>(
        valueListenable: showTaiJiDianButtonNotifier!,
        builder: (ctx, isShow, _) {
          return isShow ? child : const SizedBox(height: 24);
        },
      );
    }
    return child;
  }
}
