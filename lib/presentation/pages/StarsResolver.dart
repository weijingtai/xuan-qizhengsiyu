import 'dart:core';
import 'dart:math';

import 'package:tuple/tuple.dart';

import '../models/ui_star_model.dart';

class StarsResolver {
  static double calculateMinSafeAngle(double outerR, double innerR, double r) {
    // 参数校验
    if (outerR <= innerR) return 360.0; // 外圈必须大于内圈
    if (innerR < 0) return 360.0; // 内圈不能为负
    if (r <= 0) return 0.0; // 零或负半径无需安全角度

    final R = (outerR + innerR) / 2;
    final ratio = r / R;

    // 处理浮点精度误差
    const epsilon = 1e-10;
    return (ratio >= 1 - epsilon) ? 360.0 : 2 * asin(ratio) * 180 / pi;
  } // 判断一个角度是否在弧的范围内

  /// 根据两个星体解析星座模型
  @Deprecated('Use resolveUIStars() instead')
  static UIConstellationModel? doResolve2Stars(List<UIStarModel> stars) {
    if (stars[0].angle == stars[1].angle) {
      return doResolveSameAngleStars(stars);
    }
    List<UIStarModel> stars0 = sortStar(stars);
    UIStarModel head = stars0[0];
    UIStarModel tail = stars0[1];
    Tuple3<bool, double?, double?> inRangeTuple = head.inRangeAngle(tail);

    if (inRangeTuple.item1) {
      double diffAngle = inRangeTuple.item2 ?? inRangeTuple.item3!;
      // double minDiffAngle = UIStarModel.getMinDiffAngleOfTwoStar(head, tail);
      double shouldAdjustedAngle = diffAngle * .5;
      head.toLeftAdjustAngle(shouldAdjustedAngle);
      tail.toRightAdjustAngle(shouldAdjustedAngle);
      return UIConstellationModel(orderedStars: [head, tail]);
    }
    return null;
  }

  /// 从图中提取连通分量
  @Deprecated('Use resolveUIStars() instead')
  static List<Set<double>> extractConnectedComponents(
      Map<double, Set<double>> graph) {
    return GraphUtils.findConnectedComponents(graph);
  }

  /// 处理多个星座模型，检查并调整重叠情况
  @Deprecated('Use resolveUIStars() instead')
  static void handleTwoConstellationModel(
      List<UIConstellationModel> constellations) {
    for (var i = 0; i < constellations.length; i++) {
      for (var j = i + 1; j < constellations.length; j++) {
        if (j == i) continue;
        Tuple3<bool, double?, double?> ijCheckResult = checkAngleInRange(
            constellations[i].edges, constellations[j].centerAngle);
        if (ijCheckResult.item1) {
          if (ijCheckResult.item2 != null && ijCheckResult.item3 != null) {
            throw Exception("center overlap");
          } else {
            if (ijCheckResult.item2 != null) {
              _handleLeftOverlap(
                  constellations[i], constellations[j], ijCheckResult);
            }
            if (ijCheckResult.item3 != null) {
              _handleRightOverlap(
                  constellations[i], constellations[j], ijCheckResult);
            }
          }
        }
      }
    }
  }

  /// 处理星座与星体，调整并加入符合条件的星体
  @Deprecated('Use resolveUIStars() instead')
  static Tuple2<UIConstellationModel, List<UIStarModel>>
      doResolveConstellationWithStars(
          UIConstellationModel constellation, List<UIStarModel> stars) {
    UIConstellationModel currentConstellation = constellation;
    Map<double, UIStarModel> singleStarMap = _createStarMap(stars);
    List<double> circularSortedStarsAngle = sortCircularAnglesByGivenCenter(
        singleStarMap.keys.toList(), currentConstellation.centerAngle);

    int centerAngleIndex =
        circularSortedStarsAngle.indexOf(currentConstellation.centerAngle);
    List<double> leftAngles =
        circularSortedStarsAngle.sublist(0, centerAngleIndex).reversed.toList();
    List<double> rightAngles =
        circularSortedStarsAngle.sublist(centerAngleIndex + 1);
    List<UIStarModel> addedStars = [];

    _processAngles(
        leftAngles, currentConstellation, singleStarMap, addedStars, true);
    _processAngles(
        rightAngles, currentConstellation, singleStarMap, addedStars, false);

    return Tuple2(constellation, addedStars);
  }

  /// 从图中提取连通的星体集合
  @Deprecated('Use resolveUIStars() instead')
  static List<Set<UIStarModel>> findConnectedStars(
      Map<UIStarModel, Set<UIStarModel>> graph) {
    return GraphUtils.findConnectedComponents(graph);
  }

  /// 解析一组星体为星座模型（重写版本）
  ///
  /// 新算法流程：
  /// 1. 重置所有星体的调整状态（幂等性）
  /// 2. 按 originalAngle 排序
  /// 3. 检测重叠集群
  /// 4. 逐集群解析（均匀分配位置）
  /// 5. 迭代修复集群间重叠
  static List<UIStarModel> resolveUIStars(List<UIStarModel> stars) {
    if (stars.isEmpty) return stars;

    // Step 0: 重置所有星体的调整状态（幂等性）
    for (var s in stars) {
      s.resetAdjustment();
    }

    // Step 1: 按 originalAngle 排序
    List<UIStarModel> sorted = stars.toList()
      ..sort((a, b) => a.originalAngle.compareTo(b.originalAngle));

    if (sorted.length == 1) return sorted;

    // Step 2: 检测重叠集群
    List<List<UIStarModel>> clusters = _findOverlapClusters(sorted);

    // 如果没有任何集群（全部独立），直接返回
    if (clusters.isEmpty) return sorted;

    // Step 3: 逐集群解析
    for (var cluster in clusters) {
      _resolveCluster(cluster);
    }

    // Step 4: 全局后处理 — 修复所有相邻对重叠（含独立星体）
    for (int round = 0; round < 20; round++) {
      if (!_fixGlobalOverlaps(sorted)) break;
    }

    // Step 5: 返回结果
    return sorted;
  }

  /// 检测重叠集群：按排序顺序扫描，相邻距离 < minSafeDistance 则合并入同一集群
  static List<List<UIStarModel>> _findOverlapClusters(
      List<UIStarModel> sorted) {
    List<List<UIStarModel>> clusters = [];
    List<UIStarModel>? currentCluster;

    for (int i = 0; i < sorted.length; i++) {
      if (currentCluster == null) {
        currentCluster = [sorted[i]];
      } else {
        double dist = _circularDistance(
            currentCluster.last.originalAngle, sorted[i].originalAngle);
        double minDist = _minSafeDistance(currentCluster.last, sorted[i]);
        if (dist < minDist) {
          currentCluster.add(sorted[i]);
        } else {
          if (currentCluster.length > 1) {
            clusters.add(currentCluster);
          }
          currentCluster = [sorted[i]];
        }
      }
    }
    // 处理最后一个集群
    if (currentCluster != null && currentCluster.length > 1) {
      clusters.add(currentCluster);
    }

    // 关键：检查首尾集群是否跨 0° 重叠
    if (clusters.length >= 2) {
      _mergeFirstLastIfOverlapping(clusters, sorted);
    } else if (clusters.isEmpty && sorted.length > 1) {
      // 只有独立星体，但检查首尾是否跨 0° 重叠
      double dist = _circularDistance(
          sorted.last.originalAngle, sorted.first.originalAngle);
      double minDist = _minSafeDistance(sorted.last, sorted.first);
      if (dist < minDist) {
        // 首尾重叠，创建一个集群
        clusters.add([sorted.last, sorted.first]);
      }
    } else if (clusters.length == 1) {
      // 检查集群的边缘星体是否与未入群的首/尾星体跨 0° 重叠
      var cluster = clusters.first;
      // 检查与 sorted 中未入群的首尾
      if (cluster.first != sorted.first) {
        double dist = _circularDistance(
            sorted.last.originalAngle, cluster.first.originalAngle);
        double minDist = _minSafeDistance(sorted.last, cluster.first);
        if (dist < minDist) {
          cluster.insert(0, sorted.last);
        }
      }
      if (cluster.last != sorted.last) {
        double dist = _circularDistance(
            cluster.last.originalAngle, sorted.first.originalAngle);
        double minDist = _minSafeDistance(cluster.last, sorted.first);
        if (dist < minDist) {
          cluster.add(sorted.first);
        }
      }
    }

    return clusters;
  }

  /// 检查首尾集群是否需要合并（跨 0° 环绕）
  static void _mergeFirstLastIfOverlapping(
      List<List<UIStarModel>> clusters, List<UIStarModel> sorted) {
    var firstCluster = clusters.first;
    var lastCluster = clusters.last;

    // 检查 lastCluster 的最后一颗星与 firstCluster 的第一颗星是否跨 0° 重叠
    // 同时检查未入群的首/尾独立星体
    UIStarModel lastStar = lastCluster.last;
    UIStarModel firstStar = firstCluster.first;

    // 检查最后一个集群末端到第一个集群开头的距离
    double dist =
        _circularDistance(lastStar.originalAngle, firstStar.originalAngle);
    double minDist = _minSafeDistance(lastStar, firstStar);

    if (dist < minDist) {
      // 合并：将 firstCluster 追加到 lastCluster
      lastCluster.addAll(firstCluster);
      clusters.removeAt(0);
    } else {
      // 还需检查独立星体在首尾是否与集群重叠
      // 检查 sorted 中最后一颗（若不在 lastCluster 中）是否与 firstCluster 重叠
      if (!lastCluster.contains(sorted.last) &&
          !firstCluster.contains(sorted.last)) {
        double d = _circularDistance(
            sorted.last.originalAngle, firstStar.originalAngle);
        double md = _minSafeDistance(sorted.last, firstStar);
        if (d < md) {
          firstCluster.insert(0, sorted.last);
        }
      }
      if (!firstCluster.contains(sorted.first) &&
          !lastCluster.contains(sorted.first)) {
        double d = _circularDistance(
            lastStar.originalAngle, sorted.first.originalAngle);
        double md = _minSafeDistance(lastStar, sorted.first);
        if (d < md) {
          lastCluster.add(sorted.first);
        }
      }
    }
  }

  /// 集群内解析：只推开实际重叠的星体，保留原本已足够的间距
  ///
  /// 算法：
  /// 1. 按相对于加权中心的角度排序
  /// 2. 左→右扫描：仅当相邻对实际重叠时才推开右侧星体
  /// 3. 重新居中：使整个集群以加权中心为基准对称分布
  static void _resolveCluster(List<UIStarModel> cluster) {
    if (cluster.length <= 1) return;

    // 计算集群的加权圆周中心
    double center = _weightedCircularMean(cluster);

    // 按相对于中心的有符号弧度排序
    cluster.sort((a, b) {
      double da = _signedDiff(a.originalAngle, center);
      double db = _signedDiff(b.originalAngle, center);
      return da.compareTo(db);
    });

    // 转换为以 center 为原点的线性坐标
    List<double> positions = cluster
        .map((s) => _signedDiff(s.originalAngle, center))
        .toList();

    // 左→右扫描：仅在实际重叠时推开
    for (int i = 1; i < positions.length; i++) {
      double dist = positions[i] - positions[i - 1];
      double minDist = _minSafeDistance(cluster[i - 1], cluster[i]);
      if (dist < minDist) {
        positions[i] = positions[i - 1] + minDist;
      }
    }

    // 重新居中：保持集群以加权中心为基准对称
    double midpoint = (positions.first + positions.last) / 2;
    for (int i = 0; i < positions.length; i++) {
      positions[i] -= midpoint;
    }

    // 应用调整
    for (int i = 0; i < cluster.length; i++) {
      double target = _normalize(center + positions[i]);
      double delta = _signedDiff(target, cluster[i].originalAngle);
      if (delta.abs() > 1e-9) {
        cluster[i].adjustAngle(delta);
      }
    }
  }

  /// 全局后处理：按 adjustedAngle 排序后遍历所有相邻对（含首尾跨 0°），
  /// 将重叠对对称推开 overlap/2。
  /// 返回 true 表示有修改，false 表示已稳定。
  static bool _fixGlobalOverlaps(List<UIStarModel> allStars) {
    if (allStars.length <= 1) return false;

    bool anyChange = false;
    // 按当前角度排序
    allStars.sort((a, b) => a.angle.compareTo(b.angle));

    for (int i = 0; i < allStars.length; i++) {
      int j = (i + 1) % allStars.length;
      if (i == j) continue; // 只有 1 颗星时跳过

      double dist = _circularDistance(allStars[i].angle, allStars[j].angle);
      double minDist = _minSafeDistance(allStars[i], allStars[j]);

      if (dist < minDist - 1e-9) {
        double shift = (minDist - dist) / 2;
        // i 在左（角度小），j 在右（角度大）；推 i 向左，j 向右
        // 对于首尾跨 0° 对（i=last, j=0），i 在大角度侧，j 在小角度侧
        // 此时 i 应向右推（增大），j 应向左推（减小）
        if (j == 0 && i == allStars.length - 1) {
          // 跨 0° 情况：i 在高角度端，j 在低角度端
          allStars[i].adjustAngle(shift);
          allStars[j].adjustAngle(-shift);
        } else {
          allStars[i].adjustAngle(-shift);
          allStars[j].adjustAngle(shift);
        }
        anyChange = true;
      }
    }
    return anyChange;
  }

  // ===== 圆周算术辅助方法 =====

  /// 角度归一化到 [0, 360)
  static double _normalize(double angle) {
    return ((angle % 360) + 360) % 360;
  }

  /// 有符号最短弧差 (a - b)，范围 (-180, 180]
  static double _signedDiff(double a, double b) {
    double d = _normalize(a) - _normalize(b);
    if (d > 180) d -= 360;
    if (d <= -180) d += 360;
    return d;
  }

  /// 两角度间的绝对最短弧距
  static double _circularDistance(double a, double b) {
    return _signedDiff(a, b).abs();
  }

  /// 两星中心之间的最小安全距离 = max(r1, r2)
  static double _minSafeDistance(UIStarModel a, UIStarModel b) {
    return max(a.rangeAngleEachSide, b.rangeAngleEachSide);
  }

  /// 基于优先级加权的圆周均值（向量均值法）
  static double _weightedCircularMean(List<UIStarModel> stars) {
    double sumSin = 0, sumCos = 0;
    for (var s in stars) {
      double rad = s.originalAngle * pi / 180;
      double w = s.priority.toDouble();
      sumSin += w * sin(rad);
      sumCos += w * cos(rad);
    }
    double meanRad = atan2(sumSin, sumCos);
    return _normalize(meanRad * 180 / pi);
  }

  /// 根据星座和星体解析星座模型
  @Deprecated('Use resolveUIStars() instead')
  static UIConstellationModel? doResolveByConstellation(
      UIConstellationModel stars, UIStarModel other) {
    Tuple3<bool, double?, double?> inRangeTuple = stars.inRangeAngle(other);
    if (!inRangeTuple.item1) return null;
    if (inRangeTuple.item2 != null && inRangeTuple.item3 != null) {
      other.adjustAngle(inRangeTuple.item3!);
    } else if (inRangeTuple.item2 != null) {
      other.adjustAngle(inRangeTuple.item2! * -1);
    } else if (inRangeTuple.item3 != null) {
      other.adjustAngle(inRangeTuple.item3!);
    }
    return stars..addStar(other);
  }

  /// 对星体进行圆周角度排序并保留相同角度的星体
  static List<UIStarModel> sortStarWithCircularAngleKeepSameAngleStars(
      List<UIStarModel> stars) {
    Map<double, List<UIStarModel>> starsMapper = _groupStarsByAngle(stars);
    List<double> circularSortedAngle =
        sortCircularAngles(starsMapper.keys.toList());
    return circularSortedAngle
        .map((a) => starsMapper[a]!)
        .expand((e) => e)
        .toList();
  }

  /// 根据星体列表解析星座模型
  @Deprecated('Use resolveUIStars() instead')
  static UIConstellationModel doResolveConstellation(List<UIStarModel> stars) {
    if (stars.length == 2) {
      UIConstellationModel? result = doResolve2Stars(stars);
      if (result != null) {
        return result;
      }
      throw Exception(
          "${stars.first.star}(${stars.first.angle}) 和 ${stars.last.star}(${stars.last.angle}) 不应该聚群");
    } else {
      Map<double, List<UIStarModel>> starsMapper = _groupStarsByAngle(stars);
      if (starsMapper.length == 1) {
        return doResolveSameAngleStars(stars);
      }
      return sortMultipleInRangeStars(starsMapper);
    }
  }

  /// 处理多个相同角度的星体，构建星座模型
  @Deprecated('Use resolveUIStars() instead')
  static UIConstellationModel sortMultipleInRangeStars(
      Map<double, List<UIStarModel>> starsMapper) {
    List<double> circularAngleSorted =
        sortCircularAngles(starsMapper.keys.toList());
    if (circularAngleSorted.length % 2 == 1) {
      return _processOddCircularAngles(circularAngleSorted, starsMapper);
    } else {
      return _processEvenCircularAngles(circularAngleSorted, starsMapper);
    }
  }

  /// 计算两个角度在圆周角中的最小角度差
  static double calculateMinAngleDifference(double angle1, double angle2) {
    double directDiff = (angle1 - angle2).abs();
    double reverseDiff = 360 - directDiff;
    return directDiff < reverseDiff ? directDiff : reverseDiff;
  }

  /// 调整星座左侧星体的角度并加入星座
  static UIConstellationModel adjustStarAngleOnLeft(
      UIConstellationModel constellation, UIStarModel starOnLeft) {
    return _adjustStarAngle(constellation, starOnLeft, true);
  }

  /// 调整星座右侧星体的角度并加入星座
  static UIConstellationModel adjustStarAngleOnRight(
      UIConstellationModel constellation, UIStarModel starOnRight) {
    return _adjustStarAngle(constellation, starOnRight, false);
  }

  /// 根据边缘调整星座左侧星体的角度并加入星座
  static UIConstellationModel? adjustStarAngleOnLeftByEdge(
      Edge constellation, UIStarModel starOnLeft) {
    Tuple3<bool, double?, double?> tmpInRangeResult =
        constellation.inRangeAngle(starOnLeft);
    if (!tmpInRangeResult.item1) {
      throw Exception(
          "${starOnLeft.star.starName}(${starOnLeft.angle}) 不在 centerConstellation${constellation.edges} 的角度范围内");
    }
    if (tmpInRangeResult.item3 != null && tmpInRangeResult.item2 == null) {
      throw Exception(
          "${starOnLeft.star.starName}(${starOnLeft.angle}) 不在 距离centerConstellation${constellation.edges} rightEdge更近的角度范围内");
    }
    starOnLeft.toLeftAdjustAngle(tmpInRangeResult.item2!);
    return constellation.addStar(starOnLeft);
  }

  /// 根据星体优先级排序并构建星座模型
  @Deprecated('Use resolveUIStars() instead')
  static UIConstellationModel sortInRangeStarsNoneSameAngleWithPriority(
      List<UIStarModel> stars) {
    List<UIStarModel> sortedStars = stars
      ..sort((a, b) => b.priority.compareTo(a.priority));
    if (sortedStars.first.priority == 4) {
      return sortStarWithCircularAngleByCenterStar(
          sortedStars, sortedStars.first);
    }
    if (sortedStars.first.priority == 3) {
      return sortStarWithCircularAngleByCenterStar(
          sortedStars, sortedStars.first);
    }
    if (sortedStars.first.priority == 2) {
      List<UIStarModel> priority2Stars =
          sortedStars.where((s) => s.priority == 2).toList();
      if (priority2Stars.length > 1) {
        if (priority2Stars.length % 2 == 1) {
          List<UIStarModel> tmpSortedStars =
              sortStarWithCircularAngle(priority2Stars);
          int centerIndex = tmpSortedStars.length ~/ 2;
          UIStarModel centerStar = tmpSortedStars[centerIndex];
          return sortStarWithCircularAngleByCenterStar(sortedStars, centerStar);
        } else {
          List<UIStarModel> tmpSortedStars =
              sortStarWithCircularAngle(priority2Stars);
          double centerAngle = UIConstellationModel.calculateMidpointAngle(
              tmpSortedStars.first.angle, tmpSortedStars.last.angle);
          return sortStarWithCircularAngleByCenterAngle(
              sortedStars, centerAngle);
        }
      } else {
        return sortStarWithCircularAngleByCenterStar(
            sortedStars, sortedStars.first);
      }
    }
    return UIConstellationModel(orderedStars: sortStarWithCircularAngle(stars));
  }

  /// 根据目标角度将角度列表分为两部分
  static Tuple2<List<double>, List<double>> splitAngles(
      List<double> angles, double targetAngle) {
    List<double> part1 = [];
    List<double> part2 = [];
    for (double angle in angles) {
      bool isClockwise = (angle - targetAngle + 360) % 360 < 180;
      if (isClockwise) {
        part2.add(angle);
      } else {
        part1.add(angle);
      }
    }
    return Tuple2(part1, part2);
  }

  /// 处理相同角度的星体，调整角度并构建星座模型
  static UIConstellationModel doResolveSameAngleStars(List<UIStarModel> stars) {
    List<UIStarModel> result = [];
    if (stars.length % 2 == 1) {
      UIStarModel? centerStar;
      List<UIStarModel> leftStars = [];
      List<UIStarModel> rightStars = [];
      stars.sort((s1, s2) => s2.priority.compareTo(s1.priority));
      for (var i = 0; i < stars.length; i++) {
        if (i == 0) {
          centerStar = stars[i];
        } else if (i % 2 == 0) {
          leftStars.add(stars[i]
            ..adjustAngle(
                stars[i].rangeAngleEachSide * (leftStars.length + 1) * -1));
        } else {
          rightStars.add(stars[i]
            ..adjustAngle(
                stars[i].rangeAngleEachSide * (rightStars.length + 1)));
        }
      }
      result.addAll(leftStars.reversed);
      result.add(centerStar!);
      result.addAll(rightStars);
    } else {
      List<UIStarModel> leftStars = [];
      List<UIStarModel> rightStars = [];
      for (var i = 0; i < stars.length; i++) {
        if (i % 2 == 0) {
          if (leftStars.isEmpty) {
            leftStars.add(
                stars[i]..adjustAngle(stars[i].rangeAngleEachSide / 2 * -1));
          } else {
            leftStars.add(stars[i]
              ..adjustAngle(
                  stars[i].rangeAngleEachSide * leftStars.length * -1 -
                      stars[i].rangeAngleEachSide / 2));
          }
        } else {
          if (leftStars.isEmpty) {
            rightStars
                .add(stars[i]..adjustAngle(stars[i].rangeAngleEachSide / 2));
          } else {
            rightStars.add(stars[i]
              ..adjustAngle(stars[i].rangeAngleEachSide * rightStars.length +
                  stars[i].rangeAngleEachSide / 2));
          }
        }
      }
      result.addAll(leftStars.reversed);
      result.addAll(rightStars);
    }
    return UIConstellationModel(orderedStars: result);
  }

  /// 对星体进行排序
  static List<UIStarModel> sortStar(List<UIStarModel> stars) {
    Map<double, List<UIStarModel>> mapper = _groupStarsByAngle(stars);
    List<double> sortedAngleResult =
        sortCircularAngles(stars.map((e) => e.angle).toList());
    List<UIStarModel> sortedResult = [];
    for (var angle in sortedAngleResult) {
      sortedResult.addAll(mapper[angle]!);
    }
    return sortedResult;
  }

  /// 检查角度是否在给定边缘范围内
  static Tuple3<bool, double?, double?> checkAngleInRange(
      Tuple3<double, double, double> edges, double otherAngle) {
    if (edges.item1 > edges.item2) {
      if (otherAngle <= edges.item2) {
        double tmpAngle = edges.item2 - otherAngle;
        if (edges.item3 == tmpAngle) {
          return Tuple3(true, edges.item3, edges.item3);
        }
        return Tuple3(true, null, edges.item2 - otherAngle);
      } else if (otherAngle >= edges.item1) {
        double tmpAngle = otherAngle - edges.item1;
        if (edges.item3 == tmpAngle) {
          return Tuple3(true, edges.item3, edges.item3);
        }
        return Tuple3(true, otherAngle - edges.item1, null);
      } else {
        double toLeftOffsetAngle = edges.item1 - otherAngle;
        double toRightOffsetAngle = otherAngle - edges.item2;
        if (toLeftOffsetAngle < toRightOffsetAngle) {
          return Tuple3(false, toLeftOffsetAngle, null);
        } else if (toLeftOffsetAngle > toRightOffsetAngle) {
          return Tuple3(false, null, toRightOffsetAngle);
        } else {
          return Tuple3(false, toLeftOffsetAngle, toRightOffsetAngle);
        }
      }
    } else {
      if (otherAngle == edges.item1) {
        return const Tuple3(true, 0, null);
      }
      if (otherAngle == edges.item2) {
        return const Tuple3(true, null, 0);
      }
      if (otherAngle > edges.item1 && otherAngle < edges.item2) {
        double leftOffsetAngle = otherAngle - edges.item1;
        double rightOffsetAngle = edges.item2 - otherAngle;
        if (leftOffsetAngle < rightOffsetAngle) {
          return Tuple3(true, leftOffsetAngle, null);
        } else if (leftOffsetAngle > rightOffsetAngle) {
          return Tuple3(true, null, rightOffsetAngle);
        } else {
          return Tuple3(true, leftOffsetAngle, rightOffsetAngle);
        }
      } else {
        if (otherAngle < edges.item1) {
          double toLeftOffsetAngle = edges.item1 - otherAngle;
          return Tuple3(false, toLeftOffsetAngle, null);
        } else if (otherAngle > edges.item2) {
          double toRightOffsetAngle = otherAngle - edges.item2;
          return Tuple3(false, null, toRightOffsetAngle);
        } else {
          return const Tuple3(false, null, null);
        }
      }
    }
  }

  /// 根据中心角度对星体进行圆周角度排序并构建星座模型
  static UIConstellationModel sortStarWithCircularAngleByCenterAngle(
      List<UIStarModel> stars, double centerAngle) {
    Map<double, UIStarModel> mapper = _createStarMap(stars);
    List<double> angles = mapper.keys.toList();
    angles.remove(centerAngle);
    List<double> sortedAngle =
        sortCircularAnglesByGivenCenter(angles, centerAngle);
    sortedAngle.remove(centerAngle);
    List<UIStarModel> sortedStars = sortedAngle.map((a) => mapper[a]!).toList();
    return UIConstellationModel(orderedStars: sortedStars);
  }

  /// 根据中心星体对星体进行圆周角度排序并构建星座模型
  static UIConstellationModel sortStarWithCircularAngleByCenterStar(
      List<UIStarModel> stars, UIStarModel centerStar) {
    Map<double, UIStarModel> mapper = _createStarMap(stars);
    List<double> angles = mapper.keys.toList();
    angles.remove(centerStar.angle);
    List<double> sortedAngle =
        sortCircularAnglesByGivenCenter(angles, centerStar.angle);
    List<UIStarModel> sortedStars = sortedAngle.map((a) => mapper[a]!).toList();
    return UIConstellationModel(orderedStars: sortedStars);
  }

  /// 对星体进行圆周角度排序
  static List<UIStarModel> sortStarWithCircularAngle(List<UIStarModel> stars) {
    Map<double, UIStarModel> mapper = _createStarMap(stars);
    List<double> angles = mapper.keys.toList();
    List<double> sortedAngle = sortCircularAngles(angles);
    List<UIStarModel> sortedStars = sortedAngle.map((a) => mapper[a]!).toList();
    return sortedStars;
  }

  /// 对角度进行圆周排序
  static List<double> sortCircularAngles(List<double> angles) {
    return _sortCircularAnglesInternal(angles, angles[angles.length ~/ 2]);
  }

  /// 计算两个角度的中间点角度
  static double calculateMidpointAngle(double angleA, double angleB) {
    double diff = (angleB - angleA + 360) % 360;
    if (diff > 180) {
      double temp = angleA;
      angleA = angleB;
      angleB = temp;
      diff = (angleB - angleA + 360) % 360;
    }
    return (angleA + diff / 2) % 360;
  }

  /// 根据给定中心角度对角度进行圆周排序
  static List<double> sortCircularAnglesByGivenCenter(
      List<double> angles, double centerAngle) {
    return _sortCircularAnglesInternal(angles, centerAngle);
  }

  // 辅助方法：创建星体映射
  static Map<double, UIStarModel> _createStarMap(List<UIStarModel> stars) {
    Map<double, UIStarModel> map = {};
    for (var s in stars) {
      map[s.angle] = s;
    }
    return map;
  }

  // 辅助方法：按角度分组星体
  static Map<double, List<UIStarModel>> _groupStarsByAngle(
      List<UIStarModel> stars) {
    Map<double, List<UIStarModel>> mapper = {};
    for (var s in stars) {
      if (mapper.containsKey(s.angle)) {
        mapper[s.angle]!.add(s);
      } else {
        mapper[s.angle] = [s];
      }
    }
    return mapper;
  }

  // 辅助方法：处理星座左重叠情况

  static void _handleLeftOverlap(
      UIConstellationModel constellationI,
      UIConstellationModel constellationJ,
      Tuple3<bool, double?, double?> ijCheckResult) {
    UIStarModel jRightStar = constellationJ.orderedStars.last;
    UIStarModel jLeftStar = constellationJ.orderedStars.first;
    ijCheckResult = checkAngleInRange(constellationI.edges, jRightStar.angle);
    if (ijCheckResult.item1) {
      if (ijCheckResult.item2 != null) {
        constellationJ.toLeftAdjustAngle(ijCheckResult.item2!);
      } else if (ijCheckResult.item3 != null) {
        throw Exception(
            "constellations[j]的最右侧星体并不是距离 constellations[i] 最左edge的星体，而是最左");
      } else {
        throw Exception("center overlap j的最右侧星体并不是距离 i 最左edge最近的星体");
      }
    } else {
      ijCheckResult = checkAngleInRange(constellationI.edges, jLeftStar.angle);
      if (ijCheckResult.item1) {
        if (ijCheckResult.item3 != null) {
          constellationJ.toRightAdjustAngle(ijCheckResult.item3!);
        } else if (ijCheckResult.item2 != null) {
          throw Exception(
              "constellations[j]的最左侧星体并不是距离 constellations[i] 最右edge的星体，而是最左");
        } else {
          throw Exception("center overlap j的最右侧星体并不是距离 i 最左edge最近的星体");
        }
      }
    }
  }

  // 辅助方法：处理星座右重叠情况
  static void _handleRightOverlap(
      UIConstellationModel constellationI,
      UIConstellationModel constellationJ,
      Tuple3<bool, double?, double?> ijCheckResult) {
    UIStarModel jLeftStar = constellationJ.orderedStars.first;
    ijCheckResult = checkAngleInRange(constellationI.edges, jLeftStar.angle);
    if (ijCheckResult.item1) {
      if (ijCheckResult.item3 != null) {
        constellationJ.toRightAdjustAngle(ijCheckResult.item3!);
      } else if (ijCheckResult.item2 != null) {
        throw Exception(
            "constellations[j]的最左侧星体并不是距离 constellations[i] 最右edge的星体，而是最左");
      } else {
        throw Exception("center overlap j的最右侧星体并不是距离 i 最左edge最近的星体");
      }
    }
  }

  // 辅助方法：处理角度列表
  static void _processAngles(
      List<double> angles,
      UIConstellationModel constellation,
      Map<double, UIStarModel> starMap,
      List<UIStarModel> addedStars,
      bool isLeft) {
    if (angles.isNotEmpty) {
      for (var j = 0; j < angles.length; j++) {
        double currentAngle = angles[j];
        Tuple3<bool, double?, double?> checkResult =
            checkAngleInRange(constellation.edges, currentAngle);
        if (!checkResult.item1) {
          break;
        }
        if (checkResult.item2 != null && checkResult.item3 != null) {
          throw Exception("singleStar 与 constellation center overlap");
        }
        if ((isLeft && checkResult.item2 != null) ||
            (!isLeft && checkResult.item3 != null)) {
          UIStarModel inRangeStar = starMap[currentAngle]!;
          if (isLeft) {
            inRangeStar.toLeftAdjustAngle(checkResult.item2!);
          } else {
            inRangeStar.toRightAdjustAngle(checkResult.item3!);
          }
          constellation.addStar(inRangeStar);
          addedStars.add(inRangeStar);
        }
      }
    }
  }

  // 辅助方法：分类星体
  static void _classifyStars(
      List<UIStarModel> stars,
      Map<UIStarModel, Set<UIStarModel>> needHandled,
      Set<UIStarModel> singleStar) {
    // final sun = stars.firstWhere((t) => t.star == EnumStars.Sun);
    // final mercury = stars.firstWhere((t) => t.star == EnumStars.Mercury);
    // print(sun.inRangeAngle(mercury));
    for (var s in stars) {
      Set<UIStarModel> result = s.setupInRangeAngle(stars);
      if (result.isNotEmpty) {
        needHandled[s] = result;
      } else {
        singleStar.add(s);
      }
    }
    // print("-------");
    // needHandled.forEach((k, v) => print("$k: ${v.length}"));
    // print("-------");
    // stars.forEach((e) => print(e));
    // print("-------");
  }

  // 辅助方法：处理奇数个圆周角度情况
  static UIConstellationModel _processOddCircularAngles(
      List<double> circularAngleSorted,
      Map<double, List<UIStarModel>> starsMapper) {
    double centerAngle = circularAngleSorted[circularAngleSorted.length ~/ 2];
    UIConstellationModel centerConstellation;
    if (starsMapper[centerAngle]!.length > 1) {
      centerConstellation = doResolveSameAngleStars(starsMapper[centerAngle]!);
    } else {
      centerConstellation =
          UIConstellationModel(orderedStars: starsMapper[centerAngle]!);
    }

    int centerIndex = circularAngleSorted.indexOf(centerAngle);
    List<double> leftCircularAngleSorted =
        circularAngleSorted.sublist(0, centerIndex).reversed.toList();
    List<double> rightCircularAngleSorted =
        circularAngleSorted.sublist(centerIndex + 1);

    _processSideAngles(
        leftCircularAngleSorted, centerConstellation, starsMapper, true);
    _processSideAngles(
        rightCircularAngleSorted, centerConstellation, starsMapper, false);

    return centerConstellation;
  }

  // 辅助方法：处理偶数个圆周角度情况
  static UIConstellationModel _processEvenCircularAngles(
      List<double> circularAngleSorted,
      Map<double, List<UIStarModel>> starsMapper) {
    int middleIndex = circularAngleSorted.length ~/ 2;
    List<double> leftCircularAngleSorted =
        circularAngleSorted.sublist(0, middleIndex - 1).reversed.toList();
    List<double> rightCircularAngleSorted =
        circularAngleSorted.sublist(middleIndex + 1);
    double middleLeftAngle = circularAngleSorted[middleIndex - 1];
    double middleRightAngle = circularAngleSorted[middleIndex];

    int leftStarCount = starsMapper[middleLeftAngle]!.length;
    int rightStarCount = starsMapper[middleRightAngle]!.length;

    UIConstellationModel centerConstellation;
    if (leftStarCount == rightStarCount) {
      if (leftStarCount > 1) {
        List<UIStarModel> leftSameAngleStars = starsMapper[middleLeftAngle]!
          ..sort((a, b) => b.priority.compareTo(a.priority));
        List<UIStarModel> rightSameAngleStars = starsMapper[middleRightAngle]!
          ..sort((a, b) => b.priority.compareTo(a.priority));
        UIStarModel leftFirstStar = leftSameAngleStars.first;
        UIStarModel rightFirstStar = rightSameAngleStars.first;
        double currentLeftRightDiff = calculateMinAngleDifference(
            leftFirstStar.angle, rightFirstStar.angle);
        double leftRightStarMinDiffAngle =
            UIStarModel.getMinDiffAngleOfTwoStar(leftFirstStar, rightFirstStar);
        double shouldAdjustAngleEachStar =
            (leftRightStarMinDiffAngle - currentLeftRightDiff) * .5;
        leftFirstStar.toLeftAdjustAngle(shouldAdjustAngleEachStar);
        rightFirstStar.toRightAdjustAngle(shouldAdjustAngleEachStar);
        centerConstellation =
            UIConstellationModel(orderedStars: [leftFirstStar, rightFirstStar]);

        for (var i = 1; i < leftSameAngleStars.length; i++) {
          UIStarModel sLeft = leftSameAngleStars[i];
          centerConstellation =
              adjustStarAngleOnLeft(centerConstellation, sLeft);
          UIStarModel sRight = rightSameAngleStars[i];
          centerConstellation =
              adjustStarAngleOnRight(centerConstellation, sRight);
        }
      } else {
        UIStarModel leftStar = starsMapper[middleLeftAngle]!.first;
        UIStarModel rightStar = starsMapper[middleRightAngle]!.first;
        double currentLeftRightDiff =
            calculateMinAngleDifference(leftStar.angle, rightStar.angle);
        double leftRightStarMinDiffAngle =
            UIStarModel.getMinDiffAngleOfTwoStar(leftStar, rightStar);
        double shouldAdjustAngleEachStar =
            (leftRightStarMinDiffAngle - currentLeftRightDiff) * .5;
        leftStar.toLeftAdjustAngle(shouldAdjustAngleEachStar);
        rightStar.toRightAdjustAngle(shouldAdjustAngleEachStar);
        centerConstellation =
            UIConstellationModel(orderedStars: [leftStar, rightStar]);
      }
    } else if (leftStarCount > rightStarCount) {
      centerConstellation =
          doResolveSameAngleStars(starsMapper[middleLeftAngle]!);
      for (var s in starsMapper[middleRightAngle]!) {
        centerConstellation = adjustStarAngleOnRight(centerConstellation, s);
      }
    } else {
      centerConstellation =
          doResolveSameAngleStars(starsMapper[middleRightAngle]!);
      for (var s in starsMapper[middleLeftAngle]!) {
        centerConstellation = adjustStarAngleOnLeft(centerConstellation, s);
      }
    }

    _processSideAngles(
        leftCircularAngleSorted, centerConstellation, starsMapper, true);
    _processSideAngles(
        rightCircularAngleSorted, centerConstellation, starsMapper, false);

    return centerConstellation;
  }

  // 辅助方法：处理一侧的角度
  static void _processSideAngles(
      List<double> angles,
      UIConstellationModel constellation,
      Map<double, List<UIStarModel>> starsMapper,
      bool isLeft) {
    if (angles.isNotEmpty) {
      for (var angle in angles) {
        List<UIStarModel> sameAngleStars = starsMapper[angle]!;
        if (sameAngleStars.length > 1) {
          sameAngleStars.sort((a, b) => b.priority.compareTo(a.priority));
          for (var s in sameAngleStars) {
            if (isLeft) {
              constellation = adjustStarAngleOnLeft(constellation, s);
            } else {
              constellation = adjustStarAngleOnRight(constellation, s);
            }
          }
        } else {
          UIStarModel star = sameAngleStars.first;
          if (isLeft) {
            constellation = adjustStarAngleOnLeft(constellation, star);
          } else {
            constellation = adjustStarAngleOnRight(constellation, star);
          }
        }
      }
    }
  }

  // 辅助方法：内部圆周角度排序
  static List<double> _sortCircularAnglesInternal(
      List<double> angles, double anchor) {
    var lists = angles.toSet().toList()..sort();
    lists.remove(anchor);
    var zeroToAnchor = anchor;
    Map<double, double> anchorLeftMapper = {};
    Map<double, double> anchorRightMapper = {};

    for (int i = 0; i < lists.length; i++) {
      final current = lists[i];
      if (anchor < current) {
        var toAnchorLeft = 360 - current + zeroToAnchor;
        var toAnchorRight = current - zeroToAnchor;
        if (toAnchorLeft > toAnchorRight) {
          anchorLeftMapper[toAnchorRight] = current;
        } else {
          anchorRightMapper[toAnchorLeft] = current;
        }
      } else {
        var toAnchorLeft = anchor - current;
        var toAnchorRight = 360 - (anchor - current);
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
    List<double> leftNumbers =
        sortedRightKeys.reversed.map((e) => anchorRightMapper[e]!).toList();
    return [...leftNumbers, anchor, ...rightNumber];
  }

  // 辅助方法：调整星体角度
  static UIConstellationModel _adjustStarAngle(
      UIConstellationModel constellation, UIStarModel star, bool isLeft) {
    Tuple3<bool, double?, double?> tmpInRangeResult =
        constellation.inRangeAngle(star);
    if (!tmpInRangeResult.item1) {
      throw Exception(
          "${star.star.starName}(${star.angle}) 不在 centerConstellation${constellation.edges} 的角度范围内");
    }
    if ((isLeft &&
            tmpInRangeResult.item3 != null &&
            tmpInRangeResult.item2 == null) ||
        (!isLeft &&
            tmpInRangeResult.item2 != null &&
            tmpInRangeResult.item3 == null)) {
      throw Exception(isLeft
          ? "${star.star.starName}(${star.angle}) 不在 距离centerConstellation${constellation.edges} rightEdge更近的角度范围内"
          : "${star.star.starName}(${star.angle}) 在，但距离centerConstellation${constellation.edges} leftEdge更近的角度范围内");
    }
    if (isLeft) {
      star.toLeftAdjustAngle(tmpInRangeResult.item2!);
    } else {
      star.toRightAdjustAngle(tmpInRangeResult.item3!);
    }
    constellation.addStar(star);
    return constellation;
  }
}

class GraphUtils {
  static List<Set<T>> findConnectedComponents<T>(Map<T, Set<T>> graph) {
    Set<T> visited = {};
    List<Set<T>> connectedComponents = [];

    void dfs(T node, List<T> component) {
      visited.add(node);
      component.add(node);
      for (T neighbor in graph[node]!) {
        if (!visited.contains(neighbor)) {
          dfs(neighbor, component);
        }
      }
    }

    for (T node in graph.keys) {
      if (!visited.contains(node)) {
        List<T> component = [];
        dfs(node, component);
        component.sort();
        connectedComponents.add(component.toSet());
      }
    }

    return connectedComponents;
  }
}

/// @param outerR 外圈半径
/// @param innerR 内圈半径
/// @param r 小球半径
