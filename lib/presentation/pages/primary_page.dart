import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:common/module.dart';

class PrimaryPage extends StatefulWidget {
  const PrimaryPage({super.key});

  @override
  State<PrimaryPage> createState() => _PrimaryPageState();
}

class _PrimaryPageState extends State<PrimaryPage> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double minSize = height > width ? width : height;
    double size = minSize * 0.75;
    return Scaffold(
        appBar: AppBar(
          title: const Text('PrimaryPage'),
        ),
        body: Container(
            alignment: Alignment.center,
            color: Colors.grey.withOpacity(.1),
            child: Center(
              child: Container(
                height: size,
                width: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(.2),
                  borderRadius: BorderRadius.circular(size / 2),
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(size, size),
                        painter: CompleteCirclePainter(color: Colors.blue),
                      ),
                      Container(
                        alignment: Alignment.center,
                        height: size - 64,
                        width: size - 64,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(.2),
                          borderRadius: BorderRadius.circular((size - 64) / 2),
                        ),
                        child: Transform.rotate(
                          angle: 45 * math.pi / 180,
                          origin: Offset.zero,
                          child: CustomPaint(
                            size: Size(size - 64, size - 64),
                            painter: CompleteCirclePainter(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        height: size - 128,
                        width: size - 128,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(.2),
                          borderRadius: BorderRadius.circular((size - 128) / 2),
                        ),
                        child: Transform.rotate(
                          angle: 60 * math.pi / 180,
                          origin: Offset.zero,
                          child: CustomPaint(
                            size: Size(size - 64, size - 64),
                            painter: CompleteCirclePainter(
                              color: Colors.brown,
                              degree: 6,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        height: size - 128 - 64,
                        width: size - 128 - 64,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(.2),
                          borderRadius: BorderRadius.circular((size - 128) / 2),
                        ),
                        child: Transform.rotate(
                          angle: 60 * math.pi / 180,
                          origin: Offset.zero,
                          child: CustomPaint(
                            size: Size(size - 128 - 64, size - 128 - 64),
                            painter: RingScalePainter(
                              ringWidth: 48,
                              tickLength: 8,
                              longTickLength: 16,
                              longTickAngles: [
                                0,
                                30,
                                60,
                                90,
                                120,
                                150,
                                180,
                                210,
                                240,
                                270,
                                300
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )));
  }
}

class DividedCircle extends StatelessWidget {
  final int divisions;
  final Widget child;

  const DividedCircle(
      {super.key, required this.divisions, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: const Size(200, 200),
          painter: DividedCirclePainter(divisions: divisions),
        ),
        SizedBox(
          width: 200,
          height: 200,
          child: child,
        ),
      ],
    );
  }
}

// class MyPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     var paint = Paint()
//       ..color = Colors.blue
//       ..strokeWidth = 10
//       ..style = PaintingStyle.stroke;
//
//     var center = Offset(size.width / 2, size.height / 2);
//     var radius = math.min(size.width / 2, size.height / 2);
//
//     // 将圆环等分为三部分
//     for (var i = 0; i < 3; i++) {
//       var startAngle = i * 2 * math.pi / 3;
//       var sweepAngle = 2 * math.pi / 3;
//       canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, paint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }
