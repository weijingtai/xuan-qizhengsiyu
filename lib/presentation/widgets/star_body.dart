import 'package:flutter/material.dart';
import 'package:qizhengsiyu/presentation/models/ui_star_model.dart';

class StarBody extends StatefulWidget {
  double starSize;
  TextStyle textStyle;
  UIStarModel starBody;
  Duration duration;
  final ValueNotifier<bool> allStarsShowNotifier;

  StarBody(
      {super.key,
      required this.starBody,
      required this.starSize,
      required this.allStarsShowNotifier,
      this.textStyle =
          const TextStyle(height: 1.0, fontSize: 18, color: Colors.black87),
      this.duration = const Duration(milliseconds: 200)});

  @override
  State<StarBody> createState() => _StarBodyState();
}

class _StarBodyState extends State<StarBody> {
  bool pinned = false;
  ValueNotifier<bool> showTinyInfoNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    pinned = widget.allStarsShowNotifier.value;
    showTinyInfoNotifier.value = widget.allStarsShowNotifier.value;

    widget.allStarsShowNotifier.addListener(() {
      pinned = widget.allStarsShowNotifier.value;
      showTinyInfoNotifier.value = widget.allStarsShowNotifier.value;
    });
  }

  @override
  void dispose() {
    showTinyInfoNotifier.dispose(); // 确保释放
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle starStatusStyle =
        const TextStyle(height: 1, color: Colors.black87, fontSize: 14);
    return InkWell(
      borderRadius: BorderRadius.circular(widget.starSize),
      onHover: (isOn) {
        // print("mouse hover ${isOn}");
        if (!isOn) {
          // 鼠标从其中离开
          if (!pinned) {
            showTinyInfoNotifier.value = false;
          }
        } else {
          showTinyInfoNotifier.value = true;
        }
        // print(
        // "mouse hover ${isOn} ${showTinyInfoNotifier.value} - pinned:${pinned}");
      },
      onDoubleTap: () {
        widget.allStarsShowNotifier.value = !widget.allStarsShowNotifier.value;
      },
      onTap: () {
        if (widget.allStarsShowNotifier.value) {
          return;
        }
        pinned = !pinned;
      },
      child: Container(
        width: widget.starSize,
        height: widget.starSize,
        // color: Colors.orange.withOpacity(.1),
        alignment: Alignment.center,
        child: ValueListenableBuilder(
            valueListenable: showTinyInfoNotifier,
            builder: (ctx, show, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: show ? 1 : 0,
                    duration: widget.duration,
                    child: AnimatedContainer(
                      duration: widget.duration,
                      width: show
                          ? widget.starSize
                          : starStatusStyle.fontSize! * 2,
                      height: show
                          ? widget.starSize
                          : starStatusStyle.fontSize! * 2,
                      decoration: BoxDecoration(
                          color: widget.textStyle.color!.withOpacity(.2),
                          borderRadius: BorderRadius.circular(widget.starSize)),
                      // padding: EdgeInsets.all(widget.starSize * .1),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                "速",
                                style: starStatusStyle,
                              ),
                              const Expanded(child: SizedBox())
                            ],
                          ),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("荫", style: starStatusStyle),
                                Text("财", style: starStatusStyle)
                              ])
                        ],
                      ),
                    ),
                  ),
                  AnimatedScale(
                    scale: show ? .9 : 1,
                    duration: widget.duration,
                    child: Container(
                      // width: widget.starSize - 8,
                      // height: widget.starSize - 8,
                      // color: Colors.blue.withOpacity(.1),
                      // decoration: BoxDecoration(
                      // borderRadius: BorderRadius.circular(widget.starSize),
                      // color: widget.textStyle.color!.withOpacity(.2)),
                      alignment: Alignment.center,
                      child: Text(
                        widget.starBody.star.singleName,
                        style: widget.textStyle,
                      ),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}
