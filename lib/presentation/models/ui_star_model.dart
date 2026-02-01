import 'package:common/enums.dart';
import 'package:equatable/equatable.dart';
import 'package:tuple/tuple.dart';

mixin Compare<T> implements Comparable<T> {
  bool operator <=(T other) => compareTo(other) <= 0;
  bool operator >=(T other) => compareTo(other) >= 0;
  bool operator <(T other) => compareTo(other) < 0;
  bool operator >(T other) => compareTo(other) > 0;
}

mixin Edge implements StarEdgeAngle {}

class UIStarModel extends Equatable with Compare<UIStarModel>, Edge {
  final EnumStars star;
  final double originalAngle; // 原始角度
  late final double rangeAngleEachSide;
  final int priority; // 优先级（4最高）
  Map<UIStarModel, Tuple2<double?, double?>> inRangeStar = {};

  /// ***Edges item1 为左边 ，item2 为右边 ， item3 为中间点
  late final Tuple3<double, double, double> originalEdges;
  Tuple3<double, double, double>? adjustedEdges;
  double? adjustedAngle; // 调整后角度
  int adjustCount = 0; // 调整次数（用于指数退避）
  bool? previousAdjustedDirection =
      false; // null 为之前未进行调整， false表示前一次调整为向左“-”，true表示前一次调整为向右“+”
  double get angle => adjustedAngle ?? originalAngle;

  @override
  double get centerAngle => edges.item3;

  // item1 为左边缘， item2为右边缘， item3为局中点间距角度
  @override
  Tuple3<double, double, double> get edges => adjustedEdges ?? originalEdges;

  UIStarModel({
    required this.star,
    required this.priority,
    required this.originalAngle,
    required this.rangeAngleEachSide,
  }) {
    // TODO: 使用静态函数替换重复代码
    originalEdges = UIStarModel.getAngleRange(angle, rangeAngleEachSide);
  }

  UIStarModel generateEasyCalculate() {
    return UIStarModel(
        star: star,
        priority: priority,
        originalAngle: originalAngle + 360,
        rangeAngleEachSide: rangeAngleEachSide);
  }

  UIStarModel clone() {
    // 先复制基本类型属性
    UIStarModel cloned = UIStarModel(
      star: star,
      priority: priority,
      originalAngle: originalAngle,
      rangeAngleEachSide: rangeAngleEachSide,
    )
      ..adjustedAngle = adjustedAngle
      ..adjustCount = adjustCount
      ..previousAdjustedDirection = previousAdjustedDirection;

    // 深拷贝 inRangeStar
    cloned.inRangeStar = {};
    inRangeStar.forEach((key, value) {
      // 这里假设 key 不需要深拷贝，如果需要可以调用 key.clone()
      cloned.inRangeStar[key] = Tuple2(value.item1, value.item2);
    });

    // 深拷贝 adjustedEdges
    if (adjustedEdges != null) {
      cloned.adjustedEdges = Tuple3(
          adjustedEdges!.item1, adjustedEdges!.item2, adjustedEdges!.item3);
    }

    return cloned;
  }

  /// @Return Item1 为左边缘， item2为右边缘， item3为局中点间距角度
  static Tuple3<double, double, double> getAngleRange(
      double angle, double minAngleDiff) {
    // 需要处理0°与360°
    double leftAngleEdge = angle - minAngleDiff;
    if (leftAngleEdge < 0) {
      leftAngleEdge = 360 + leftAngleEdge;
    }
    double rightAngleEdge = angle + minAngleDiff;
    if (rightAngleEdge > 360) {
      rightAngleEdge = rightAngleEdge - 360;
    }
    return Tuple3(leftAngleEdge, rightAngleEdge, angle);
  }

  /// 比较两个星体的
  static double getMinDiffAngleOfTwoStar(UIStarModel star1, UIStarModel star2) {
    return star1.rangeAngleEachSide >= star2.rangeAngleEachSide
        ? star1.rangeAngleEachSide
        : star2.rangeAngleEachSide;
  }

  // 结果包含ball在edgeAngle边缘之上，即ball.angle == edgeAngle.item1 || ball.angle == edgeAngle.item2, 返回结果为0
  // 返回值为tuple3，item1 表示是否在range内，true在其中；false不在,
  // 1. 当在range范围内（即item1 == true）
  //    item2第一个值为距edgeAngle左侧边缘的角度，另一值为null，此时说明ball距离有值的以便边缘最近
  //    item3第二个值为距edgeAngle右侧边缘的角度，另一值为null，此时说明ball距离有值的以便边缘最近
  //    当item2和item3 同时不为null时 说明在中间
  // 2. 当不在range范围内（即item1 == false）
  //    item2第一个值为距edgeAngle左侧边缘的角度，另一值为null，此时说明ball距离有值的以便边缘最近
  //    item3第二个值为距edgeAngle右侧边缘的角度，另一值为null，此时说明ball距离有值的以便边缘最近
  //    当item2和item3 同时为null时 说明在中点的180°

  // 当为item的值为null时说明不在这一次
  // 放返回值为null时，说明不在范围内
  ///
  /// 方法说明，本函数分别使用 edges 和 other.angle 进行比较，也就是说
  /// 当存在adjustedXXX 时，则使用adjustedXXX，否则使用originalXXX
  @override
  Tuple3<bool, double?, double?> inRangeAngle(Edge other) {
    // 1. 首先确定给定edgeAngle 不是在0°附近
    if (edges.item1 > edges.item2) {
      // 说明给定edgeAngle 是在0°附近
      if (other.centerAngle <= edges.item2) {
        // 说明ball在给定range的右侧
        double tmpAngle = edges.item2 - other.centerAngle;
        if (edges.item3 == tmpAngle) {
          return Tuple3(true, edges.item3, edges.item3);
        }
        return Tuple3(true, null, edges.item2 - other.centerAngle);
      } else if (other.centerAngle >= edges.item1) {
        double tmpAngle = other.centerAngle - edges.item1;
        if (edges.item3 == tmpAngle) {
          return Tuple3(true, edges.item3, edges.item3);
        }
        return Tuple3(true, other.centerAngle - edges.item1, null);
      } else {
        // 不在范围内
        double toLeftOffsetAngle = edges.item1 - other.centerAngle;
        double toRightOffsetAngle = other.centerAngle - edges.item2;
        if (toLeftOffsetAngle < toRightOffsetAngle) {
          return Tuple3(false, toLeftOffsetAngle, null);
        } else if (toLeftOffsetAngle > toRightOffsetAngle) {
          return Tuple3(false, null, toRightOffsetAngle);
        } else {
          // 在对角线
          return Tuple3(false, toLeftOffsetAngle, toRightOffsetAngle);
        }
      }
    } else {
      // print("ok ~~~  ${other.centerAngle}  ${edges.item1} ${edges.item2}");
      if (other.centerAngle == edges.item1) {
        return const Tuple3(true, 0, null);
      }
      if (other.centerAngle == edges.item2) {
        return const Tuple3(true, null, 0);
      }
      // print(other.centerAngle > edges.item1 && other.centerAngle < edges.item2);
      if (other.centerAngle > edges.item1 && other.centerAngle < edges.item2) {
        // 说明ball在给定range的右侧
        double leftOffsetAngle = other.centerAngle - edges.item1;
        double rightOffsetAngle = edges.item2 - other.centerAngle;
        // print("${leftOffsetAngle} ------ ${rightOffsetAngle}");
        if (leftOffsetAngle < rightOffsetAngle) {
          return Tuple3(true, leftOffsetAngle, null);
        } else if (leftOffsetAngle > rightOffsetAngle) {
          return Tuple3(true, null, rightOffsetAngle);
        } else {
          return Tuple3(true, leftOffsetAngle, rightOffsetAngle);
        }
      } else {
        // 不在范围内
        if (other.centerAngle < edges.item1) {
          double toLeftOffsetAngle = edges.item1 - other.centerAngle;
          return Tuple3(false, toLeftOffsetAngle, null);
        } else if (other.centerAngle > edges.item2) {
          double toRightOffsetAngle = other.centerAngle - edges.item2;
          return Tuple3(false, null, toRightOffsetAngle);
        } else {
          return const Tuple3(false, null, null);
        }
      }
    }
  }

  /// @return 返回所有在范围内的星体，但不返回在范围多少度内
  ///
  /// 方法说明，检测是否在范围内是依据另外一个星体的angle属性，
  /// 所以判断依据为，当有adjustedAngle时，则依据adjustedAngle，否则依据originalAngle
  Set<UIStarModel> setupInRangeAngle(List<UIStarModel> others) {
    Map<UIStarModel, Tuple2<double?, double?>> result = {};
    for (var o in others) {
      if (o.star == star) {
        continue;
      }
      final checkResult = inRangeAngle(o);
      if (checkResult.item1) {
        result[o] = Tuple2(checkResult.item2, checkResult.item3);
      }
    }
    inRangeStar = result;
    return result.keys.toSet();
  }

  void toRightAdjustAngle(double angle) {
    adjustAngle(angle);
  }

  void toLeftAdjustAngle(double angle) {
    adjustAngle(angle * -1);
  }

  // 调整角度的方法，同时增加调整次数
  // addAngle 为负数是向左，为正时相右
  void adjustAngle(double addAngle) {
    if (addAngle == 0) return;
    adjustedAngle = correctCircleAngle(addAngle + angle);
    adjustedEdges = Tuple3(
        correctCircleAngle(adjustedAngle! - rangeAngleEachSide),
        correctCircleAngle(adjustedAngle! + rangeAngleEachSide),
        adjustedAngle!);

    previousAdjustedDirection = addAngle > 0;
    adjustCount++;
  }

  double correctCircleAngle(double angle) {
    if (angle < 0) {
      return 360 + angle;
    }
    if (angle >= 360) {
      return angle - 360;
    }
    return angle;
  }

  @override
  String toString() {
    return 'UIStarModel{star: $star,priority: $priority,rangeAngleEachSide: $rangeAngleEachSide, originalAngle: $originalAngle, adjustedAngle: $adjustedAngle, adjustCount: $adjustCount}';
  }

  @override
  // TODO: implement props
  List<Object?> get props => [star, originalAngle];

  @override
  int compareTo(UIStarModel other) {
    // TODO: implement compareTo
    return other.star == star ? 0 : 1;
  }

  /// @Description:
  /// 角度调整策略：
  ///   1. 如果两个星体angle相同则两个星体同时背向调整，
  ///   2. 当两个星体angle不同时，以调用此方法的星体为基本，调整 other星体的角度
  ///
  /// 返回调整后的UIConstellationModel，如果两个星体不相交则返回null
  @override
  UIConstellationModel? addStar(UIStarModel other) {
    // 1. 首先比较两个星体谁的 edge范围大
    double otherStarEdgeRange =
        shortestAngleDifference(other.edges.item1, other.edges.item2);
    double thisStarEdgeRange =
        shortestAngleDifference(edges.item1, edges.item2);

    // 2. 使用范围大者来检查范围小者是否在其范围内
    double miniDiffAngle = 0;
    Tuple3<bool, double?, double?> checkResult = inRangeAngle(other);
    if (thisStarEdgeRange >= otherStarEdgeRange) {
      miniDiffAngle = rangeAngleEachSide;
    } else {
      miniDiffAngle = other.rangeAngleEachSide;
    }

    // 3. 查看是否在范围内
    if (!checkResult.item1) {
      // 不在范围内返回null，结束之;
      return null;
    }
    // 4. 如果在范围内，则调整角度
    if (other.angle == angle) {
      // 3.1. 两个角度重叠，各退一步
      other.toRightAdjustAngle(miniDiffAngle * .5);
      toLeftAdjustAngle(miniDiffAngle * .5);
      return UIConstellationModel(orderedStars: [this, other]);
    }

    if (checkResult.item1) {
      // 调整other使其在范围之外
      if (checkResult.item2 != null) {
        other.toLeftAdjustAngle(checkResult.item2!);
      } else if (checkResult.item3 != null) {
        other.toRightAdjustAngle(checkResult.item3!);
      }
      return UIConstellationModel(orderedStars: [this, other]);
    }
    return null;
  }

  static double shortestAngleDifference(double angle1, double angle2) {
    // 计算直接差值
    double diff1 = (angle1 - angle2).abs();
    // 计算反向差值
    double diff2 = 360 - diff1;
    // 返回较小的差值
    return diff1 < diff2 ? diff1 : diff2;
  }
}

abstract interface class StarEdgeAngle {
  Tuple3<double, double, double> get edges;
  // 结果包含ball在edgeAngle边缘之上，即ball.angle == edgeAngle.item1 || ball.angle == edgeAngle.item2, 返回结果为0
  // 返回值为tuple3，item1 表示是否在range内，true在其中；false不在,
  // 1. 当在range范围内（即item1 == true）
  //    item2第一个值为距edgeAngle左侧边缘的角度，另一值为null，此时说明ball距离有值的以便边缘最近
  //    item3第二个值为距edgeAngle右侧边缘的角度，另一值为null，此时说明ball距离有值的以便边缘最近
  //    当item2和item3 同时不为null时 说明在中间
  // 2. 当不在range范围内（即item1 == false）
  //    item2第一个值为距edgeAngle左侧边缘的角度，另一值为null，此时说明ball距离有值的以便边缘最近
  //    item3第二个值为距edgeAngle右侧边缘的角度，另一值为null，此时说明ball距离有值的以便边缘最近
  //    当item2和item3 同时为null时 说明在中点的180°

  // 当为item的值为null时说明不在这一次
  // 放返回值为null时，说明不在范围内
  ///
  /// 方法说明，本函数分别使用 edges 和 other.angle 进行比较，也就是说
  /// 当存在adjustedXXX 时，则使用adjustedXXX，否则使用originalXXX
  Tuple3<bool, double?, double?> inRangeAngle(Edge other);

  double get centerAngle => edges.item3;

  // 返回值为null时，说明不在范围内
  UIConstellationModel? addStar(UIStarModel star);
}

class UIConstellationModel with Edge {
  List<UIStarModel> orderedStars = [];
  late Tuple3<double, double, double> _scalebleEdges;

  // item1 为左边缘， item2为右边缘， item3为局中点间距角度
  @override
  Tuple3<double, double, double> get edges => _scalebleEdges;

  @override
  double get centerAngle => edges.item3;

  UIConstellationModel({required this.orderedStars}) {
    _scalebleEdges = caculateScalebleEdges(orderedStars);
  }

  @override
  UIConstellationModel? addStar(UIStarModel star) {
    if (!inRangeAngle(star).item1) {
      // 不在范围内
      return null;
    }
    orderedStars.add(star);
    orderedStars = sortStar(orderedStars);
    _scalebleEdges = caculateScalebleEdges(orderedStars);
    return this;
  }

  /// @Description:
  ///   根据给定体星体列表，first 和 last 的 edges 进行计算，并返回
  ///   WARNING：stars列表必须为UIConstellationModel#sortStar方法排序后的列表
  static Tuple3<double, double, double> caculateScalebleEdges(
      List<UIStarModel> stars) {
    return Tuple3(
        stars.first.edges.item1,
        stars.last.edges.item2,
        calculateMidpointAngle(
            stars.first.edges.item1, stars.last.edges.item2));
  }

  static List<UIStarModel> sortStar(List<UIStarModel> stars) {
    Map<double, List<UIStarModel>> mapper = {};
    for (var star in stars) {
      if (mapper.containsKey(star.angle)) {
        mapper[star.angle]!.add(star);
      } else {
        mapper[star.angle] = [star];
      }
    }
    List<double> sortedAngleResult =
        sortCircularAngles(stars.map((e) => e.angle).toList());
    List<UIStarModel> sortedResult = [];
    for (var angle in sortedAngleResult) {
      sortedResult.addAll(mapper[angle]!);
    }
    return sortedResult;
  }

  static List<double> sortCircularAngles(List<double> angles) {
    var lists = angles.toSet().toList()..sort();
    // print(lists);
    // 找到中间数
    var anchor = lists[lists.length ~/ 2];
    // 删除中间点避免重复计算
    lists.removeAt(lists.length ~/ 2);
    // 确定360°距离当前位置有多少度数
    var zeroToAnchor = anchor;
    // 锚点以左应该有的数字
    Map<double, double> anchorLeftMapper = {};
    // 锚点以右应该有的数字
    Map<double, double> anchorRightMapper = {};
    for (int i = 0; i < lists.length; i++) {
      // 分别进行计算
      final current = lists[i];
      if (anchor < current) {
        // 1. 360 - _current
        // 以毛掉anchor 为原点， 当前数字 距离锚点左的距离
        var toAnchorLeft = 360 - current + zeroToAnchor;
        // 以毛掉anchor 为原点， 当前数字 距离锚点右的距离
        var toAnchorRight = current - zeroToAnchor;
        if (toAnchorLeft > toAnchorRight) {
          anchorLeftMapper[toAnchorRight] = current;
        } else {
          anchorRightMapper[toAnchorLeft] = current;
        }
      } else {
        // if anchor > _current
        var toAnchorLeft = anchor - current;
        var toAnchorRight = 360 - (anchor - current);
        // if (_current == 0){
        //   print("${_toAnchorLeft} ${_toAnchorRight}");
        // }
        if (toAnchorLeft > toAnchorRight) {
          anchorLeftMapper[toAnchorRight] = current;
        } else {
          anchorRightMapper[toAnchorLeft] = current;
        }
      }
    }
    List<double> sortedLeftKeys = anchorLeftMapper.keys.toList()..sort();

    List<double> sortedRightKeys = anchorRightMapper.keys.toList()..sort();
    List<double> rightNumber =
        sortedLeftKeys.map((e) => anchorLeftMapper[e]!).toList();
    // print("~~~~~~");
    // print(sortedRightKeys);
    List<double> leftNumbers =
        sortedRightKeys.reversed.map((e) => anchorRightMapper[e]!).toList();
    // print(leftNumbers);
    // print(anchor);
    // print(rightNumber);
    //
    // print("------");
    return [...leftNumbers, anchor, ...rightNumber];
  }

  // 结果包含ball在edgeAngle边缘之上，即ball.angle == edgeAngle.item1 || ball.angle == edgeAngle.item2, 返回结果为0
  // 返回值为tuple3，item1 表示是否在range内，true在其中；false不在,
  // 1. 当在range范围内（即item1 == true）
  //    item2第一个值为距edgeAngle左侧边缘的角度，另一值为null，此时说明ball距离有值的以便边缘最近
  //    item3第二个值为距edgeAngle右侧边缘的角度，另一值为null，此时说明ball距离有值的以便边缘最近
  //    当item2和item3 同时不为null时 说明在中间
  // 2. 当不在range范围内（即item1 == false）
  //    item2第一个值为距edgeAngle左侧边缘的角度，另一值为null，此时说明ball距离有值的以便边缘最近
  //    item3第二个值为距edgeAngle右侧边缘的角度，另一值为null，此时说明ball距离有值的以便边缘最近
  //    当item2和item3 同时为null时 说明在中点的180°

  // 当为item的值为null时说明不在这一次
  // 放返回值为null时，说明不在范围内
  ///
  /// 方法说明，本函数分别使用 edges 和 other.angle 进行比较，也就是说
  /// 当存在adjustedXXX 时，则使用adjustedXXX，否则使用originalXXX
  @override
  Tuple3<bool, double?, double?> inRangeAngle(Edge other) {
    // 1. 首先确定给定edgeAngle 不是在0°附近
    if (edges.item1 > edges.item2) {
      // 说明给定edgeAngle 是在0°附近
      if (other.centerAngle <= edges.item2) {
        // 说明ball在给定range的右侧
        double tmpAngle = edges.item2 - other.centerAngle;
        if (edges.item3 == tmpAngle) {
          return Tuple3(true, edges.item3, edges.item3);
        }
        return Tuple3(true, null, edges.item2 - other.centerAngle);
      } else if (other.centerAngle >= edges.item1) {
        double tmpAngle = other.centerAngle - edges.item1;
        if (edges.item3 == tmpAngle) {
          return Tuple3(true, edges.item3, edges.item3);
        }
        return Tuple3(true, other.centerAngle - edges.item1, null);
      } else {
        // 不在范围内
        double toLeftOffsetAngle = edges.item1 - other.centerAngle;
        double toRightOffsetAngle = other.centerAngle - edges.item2;
        if (toLeftOffsetAngle < toRightOffsetAngle) {
          return Tuple3(false, toLeftOffsetAngle, null);
        } else if (toLeftOffsetAngle > toRightOffsetAngle) {
          return Tuple3(false, null, toRightOffsetAngle);
        } else {
          // 在对角线
          return Tuple3(false, toLeftOffsetAngle, toRightOffsetAngle);
        }
      }
    } else {
      if (other.centerAngle == edges.item1) {
        return const Tuple3(true, 0, null);
      }
      if (other.centerAngle == edges.item2) {
        return const Tuple3(true, null, 0);
      }
      if (other.centerAngle > edges.item1 && other.centerAngle < edges.item2) {
        // 说明ball在给定range的右侧
        double leftOffsetAngle = other.centerAngle - edges.item1;
        double rightOffsetAngle = edges.item2 - other.centerAngle;
        if (leftOffsetAngle < rightOffsetAngle) {
          return Tuple3(true, leftOffsetAngle, null);
        } else if (leftOffsetAngle > rightOffsetAngle) {
          return Tuple3(true, null, rightOffsetAngle);
        } else {
          return Tuple3(true, leftOffsetAngle, rightOffsetAngle);
        }
      } else {
        // 不在范围内
        if (other.centerAngle < edges.item1) {
          double toLeftOffsetAngle = edges.item1 - other.centerAngle;
          return Tuple3(false, toLeftOffsetAngle, null);
        } else if (other.centerAngle > edges.item2) {
          double toRightOffsetAngle = other.centerAngle - edges.item2;
          return Tuple3(false, null, toRightOffsetAngle);
        } else {
          return const Tuple3(false, null, null);
        }
      }
    }
  }

  // 计算两个角度的中间点角度
  static double calculateMidpointAngle(double angleA, double angleB) {
    // 计算两个角度的差值
    double diff = (angleB - angleA + 360) % 360;
    if (diff > 180) {
      // 如果差值大于 180 度，说明走的是长路径，交换两个角度
      double temp = angleA;
      angleA = angleB;
      angleB = temp;
      diff = (angleB - angleA + 360) % 360;
    }
    // 计算中间点角度
    double midpoint = (angleA + diff / 2) % 360;
    return midpoint;
  }

  void toRightAdjustAngle(double angle) {
    adjustAngle(angle);
  }

  void toLeftAdjustAngle(double angle) {
    adjustAngle(angle * -1);
  }

  // 调整角度的方法，同时增加调整次数
  // addAngle 为负数是向左，为正时相右
  void adjustAngle(double addAngle) {
    orderedStars = orderedStars.map((s) => s..adjustAngle(addAngle)).toList();
    _scalebleEdges = caculateScalebleEdges(orderedStars);
  }
}
