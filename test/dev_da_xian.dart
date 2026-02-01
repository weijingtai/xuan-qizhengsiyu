import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/utils/da_xian_calculate_helper.dart';
import 'package:common/models/year_month.dart'; // 导入 math 库以使用 abs 函数

void main() {
  group("洞微大限 ui 年转换列表 google", () {
    test('测试 [3.25, 3] 的转换', () {
      List<double> example1 = [3.25, 3];
      List<List<double>> result1 =
          DaXianCalculateHelper.transformNumbers(example1);
      List<List<double>> expected1 = [
        [1.0, 1.0, 1.0, 0.25],
        [0.75, 1.0, 1.0, 0.25]
      ];
      expect(result1, equals(expected1));
    });

    test('测试 [3.25, 3, 4.75] 的转换', () {
      List<double> example2 = [3.25, 3, 4.75];
      List<List<double>> result2 =
          DaXianCalculateHelper.transformNumbers(example2);
      List<List<double>> expected2 = [
        [1.0, 1.0, 1.0, 0.25],
        [0.75, 1.0, 1.0, 0.25],
        [0.75, 1.0, 1.0, 1.0, 1.0]
      ];
      expect(result2, equals(expected2));
    });

    test('测试 [3.75, 3, 4.5] 的转换', () {
      List<double> example3 = [3.75, 3, 4.5];
      List<List<double>> result3 =
          DaXianCalculateHelper.transformNumbers(example3);
      List<List<double>> expected3 = [
        [1.0, 1.0, 1.0, 0.75],
        [0.25, 1.0, 1.0, 0.75],
        [0.25, 1.0, 1.0, 1.0, 1.0, 0.25]
      ];
      expect(result3, equals(expected3));
    });

    test('测试 [4.0, 5.5, 3.75] 的转换', () {
      List<double> example4 = [4.0, 5.5, 3.75];
      List<List<double>> result4 =
          DaXianCalculateHelper.transformNumbers(example4);
      // 这里没有注释说明期望结果，所以只是运行测试确保不会出错
      expect(result4, isA<List<List<double>>>());
      expect(result4.length, equals(3));

      List<List<double>> expected4 = [
        [1.0, 1.0, 1.0, 1.0],
        [1.0, 1.0, 1.0, 1.0, 1.0, 0.5],
        [0.5, 1.0, 1.0, 1.0, 0.25]
      ];
      expect(result4, equals(expected4));
    });

    test('测试 [3.5] 的转换', () {
      List<double> example5 = [3.5];
      List<List<double>> result5 =
          DaXianCalculateHelper.transformNumbers(example5);
      // 这里没有注释说明期望结果，所以只是运行测试确保不会出错
      expect(result5, isA<List<List<double>>>());
      expect(result5.length, equals(1));
    });

    test('测试 [3.0] 的转换', () {
      List<double> example6 = [3.0];
      List<List<double>> result6 =
          DaXianCalculateHelper.transformNumbers(example6);
      // 这里没有注释说明期望结果，所以只是运行测试确保不会出错
      expect(result6, isA<List<List<double>>>());
      expect(result6.length, equals(1));
    });

    test('测试 [4.5, 4.75, 4.25] 的转换 -example7', () {
      List<double> example7 = [4.5, 4.75, 4.25];
      List<List<double>> result7 =
          DaXianCalculateHelper.transformNumbers(example7);
      List<List<double>> expected7 = [
        [1.0, 1.0, 1.0, 1.0, 0.5],
        [0.5, 1.0, 1.0, 1.0, 1.0, 0.25],
        [0.75, 1.0, 1.0, 1.0, 0.5]
      ];
      expect(result7, equals(expected7));
    });
  });

  group("洞微大限 年转换列表 deepseek", () {
    // 测试示例1: [3.25, 3]
    test('测试示例1: [3.25, 3]', () {
      final result = DaXianCalculateHelper.convertNumbers([3.25, 3]);
      final expected = [
        [1.0, 1.0, 1.0, 0.25],
        [0.75, 1.0, 1.0, 0.25]
      ];
      expect(result, equals(expected), reason: result.toString());
    });

    // 测试示例2: [3.25, 3, 4.75]
    test('测试示例2: [3.25, 3, 4.75]', () {
      final result = DaXianCalculateHelper.convertNumbers([3.25, 3, 4.75]);
      final expected = [
        [1.0, 1.0, 1.0, 0.25],
        [0.75, 1.0, 1.0, 0.25],
        [0.75, 1.0, 1.0, 1.0, 1.0]
      ];
      expect(result, equals(expected));
    });

    // 测试示例3: [3.75, 3, 4.5]
    test('测试示例3: [3.75, 3, 4.5]', () {
      final result = DaXianCalculateHelper.convertNumbers([3.75, 3, 4.5]);
      final expected = [
        [1.0, 1.0, 1.0, 0.75],
        [0.25, 1.0, 1.0, 0.75],
        [0.25, 1.0, 1.0, 1.0, 1.0, 0.25]
      ];
      expect(result, equals(expected));
    });

    // 测试12个数字的数组
    test('测试12个数字的数组', () {
      List<double> input = [
        5.50,
        4.25,
        6.00,
        7.50,
        3.00,
        8.75,
        10.00,
        5.25,
        6.75,
        9.00,
        4.50,
        11.75
      ];
      final result = DaXianCalculateHelper.convertNumbers(input);
      // 验证结果是List<List<double>>类型
      expect(result, isA<List<List<double>>>());
      // 验证结果长度为12
      expect(result.length, equals(12));
      // 验证每个子列表都不为空
      for (var subList in result) {
        expect(subList, isNotEmpty);
      }
    });
  });

  group("交叉测试 - 验证两个函数的一致性", () {
    // 使用google group中的测试用例测试deepseek函数
    test('deepseek函数测试 [3.25, 3] (来自google测试用例)', () {
      List<double> example1 = [3.25, 3];
      List<List<double>> result =
          DaXianCalculateHelper.convertNumbers(example1);
      List<List<double>> expected = [
        [1.0, 1.0, 1.0, 0.25],
        [0.75, 1.0, 1.0, 0.25]
      ];
      expect(result, equals(expected));
    });

    test('deepseek函数测试 [3.25, 3, 4.75] (来自google测试用例)', () {
      List<double> example2 = [3.25, 3, 4.75];
      List<List<double>> result =
          DaXianCalculateHelper.convertNumbers(example2);
      List<List<double>> expected = [
        [1.0, 1.0, 1.0, 0.25],
        [0.75, 1.0, 1.0, 0.25],
        [0.75, 1.0, 1.0, 1.0, 1.0]
      ];
      expect(result, equals(expected));
    });

    test('deepseek函数测试 [3.75, 3, 4.5] (来自google测试用例)', () {
      List<double> example3 = [3.75, 3, 4.5];
      List<List<double>> result =
          DaXianCalculateHelper.convertNumbers(example3);
      List<List<double>> expected = [
        [1.0, 1.0, 1.0, 0.75],
        [0.25, 1.0, 1.0, 0.75],
        [0.25, 1.0, 1.0, 1.0, 1.0, 0.25]
      ];
      expect(result, equals(expected));
    });

    test('deepseek函数测试 [4.0, 5.5, 3.75] (来自google测试用例)', () {
      List<double> example4 = [4.0, 5.5, 3.75];
      List<List<double>> result =
          DaXianCalculateHelper.convertNumbers(example4);
      expect(result, isA<List<List<double>>>());
      expect(result.length, equals(3));
    });

    // 使用deepseek group中的测试用例测试google函数
    test('google函数测试 [3.25, 3] (来自deepseek测试用例)', () {
      final result = DaXianCalculateHelper.transformNumbers([3.25, 3]);
      final expected = [
        [1.0, 1.0, 1.0, 0.25],
        [0.75, 1.0, 1.0, 0.25]
      ];
      expect(result, equals(expected));
    });

    test('google函数测试 [3.25, 3, 4.75] (来自deepseek测试用例)', () {
      final result = DaXianCalculateHelper.transformNumbers([3.25, 3, 4.75]);
      final expected = [
        [1.0, 1.0, 1.0, 0.25],
        [0.75, 1.0, 1.0, 0.25],
        [0.75, 1.0, 1.0, 1.0, 1.0]
      ];
      expect(result, equals(expected));
    });

    test('google函数测试 [3.75, 3, 4.5] (来自deepseek测试用例)', () {
      final result = DaXianCalculateHelper.transformNumbers([3.75, 3, 4.5]);
      final expected = [
        [1.0, 1.0, 1.0, 0.75],
        [0.25, 1.0, 1.0, 0.75],
        [0.25, 1.0, 1.0, 1.0, 1.0, 0.25]
      ];
      expect(result, equals(expected));
    });

    // 直接比较两个函数的输出结果
    test('直接比较两个函数的输出 - 测试用例1', () {
      List<double> input = [3.25, 3];
      List<List<double>> googleResult =
          DaXianCalculateHelper.transformNumbers(input);
      List<List<double>> deepseekResult =
          DaXianCalculateHelper.convertNumbers(input);
      expect(googleResult, equals(deepseekResult),
          reason: 'Google: $googleResult, Deepseek: $deepseekResult');
    });

    test('直接比较两个函数的输出 - 测试用例2', () {
      List<double> input = [3.25, 3, 4.75];
      List<List<double>> googleResult =
          DaXianCalculateHelper.transformNumbers(input);
      List<List<double>> deepseekResult =
          DaXianCalculateHelper.convertNumbers(input);
      expect(googleResult, equals(deepseekResult),
          reason: 'Google: $googleResult, Deepseek: $deepseekResult');
    });

    test('直接比较两个函数的输出 - 测试用例3', () {
      List<double> input = [3.75, 3, 4.5];
      List<List<double>> googleResult =
          DaXianCalculateHelper.transformNumbers(input);
      List<List<double>> deepseekResult =
          DaXianCalculateHelper.convertNumbers(input);
      expect(googleResult, equals(deepseekResult),
          reason: 'Google: $googleResult, Deepseek: $deepseekResult');
    });

    test('直接比较两个函数的输出 - 测试用例4', () {
      List<double> input = [4.0, 5.5, 3.75];
      List<List<double>> googleResult =
          DaXianCalculateHelper.transformNumbers(input);
      List<List<double>> deepseekResult =
          DaXianCalculateHelper.convertNumbers(input);
      expect(googleResult, equals(deepseekResult),
          reason: 'Google: $googleResult, Deepseek: $deepseekResult');
    });

    test('直接比较两个函数的输出 - 12个数字数组', () {
      List<double> input = [
        5.50,
        4.25,
        6.00,
        7.50,
        3.00,
        8.75,
        10.00,
        5.25,
        6.75,
        9.00,
        4.50,
        11.75
      ];
      List<List<double>> googleResult =
          DaXianCalculateHelper.transformNumbers(input);
      List<List<double>> deepseekResult =
          DaXianCalculateHelper.convertNumbers(input);
      expect(googleResult, equals(deepseekResult),
          reason: 'Google和Deepseek函数在12个数字数组上的输出不一致');
    });
  });

  group("洞微大限 YearMonth 年列表转换 google", () {
    // 示例 1: [3.25, 3] => [YM(3,3), YM(3,0)] (0.25年 = 3个月)
    test('测试示例1: [YM(3,3), YM(3,0)] - [3.25, 3.0]', () {
      List<YearMonth> example1 = [YearMonth(3, 3), YearMonth(3, 0)];
      List<List<YearMonth>> result1 =
          DaXianCalculateHelper.transformYearMonths(example1);

      // 验证输入转换为double的正确性
      List<double> inputAsDouble =
          example1.map((ym) => ym.toDoubleYear()).toList();
      expect(inputAsDouble, equals([3.25, 3.0]));

      // 验证结果类型和结构
      expect(result1, isA<List<List<YearMonth>>>());
      expect(result1.length, equals(2));

      // 期望输出类似: [[1/0, 1/0, 1/0, 0/3], [0/9, 1/0, 1/0, 0/3]]
      expect(result1[0].length, equals(4)); // 第一个列表应该有4个元素
      expect(result1[1].length, equals(4)); // 第二个列表应该有4个元素

      List<List<YearMonth>> expected1 = [
        [YearMonth(1, 0), YearMonth(1, 0), YearMonth(1, 0), YearMonth(0, 3)],
        [YearMonth(0, 9), YearMonth(1, 0), YearMonth(1, 0), YearMonth(0, 3)],
      ];
      expect(result1, equals(expected1));
    });

    // 示例 2: [3.25, 3, 4.75] => [YM(3,3), YM(3,0), YM(4,9)]
    test('测试示例2: [YM(3,3), YM(3,0), YM(4,9)] - [3.25, 3.0, 4.75]', () {
      List<YearMonth> example2 = [
        YearMonth(3, 3),
        YearMonth(3, 0),
        YearMonth(4, 9)
      ];
      List<List<YearMonth>> result2 =
          DaXianCalculateHelper.transformYearMonths(example2);

      // 验证输入转换为double的正确性
      List<double> inputAsDouble =
          example2.map((ym) => ym.toDoubleYear()).toList();
      expect(inputAsDouble, equals([3.25, 3.0, 4.75]));

      // 验证结果类型和结构
      expect(result2, isA<List<List<YearMonth>>>());
      expect(result2.length, equals(3));

      // 期望输出类似: [[1/0, 1/0, 1/0, 0/3], [0/9, 1/0, 1/0, 0/3], [0/9, 1/0, 1/0, 1/0, 1/0]]
      expect(result2[0].length, equals(4)); // 第一个列表应该有4个元素
      expect(result2[1].length, equals(4)); // 第二个列表应该有4个元素
      expect(result2[2].length, equals(5)); // 第三个列表应该有5个元素
    });

    // 示例 3: [3.75, 3, 4.5] => [YM(3,9), YM(3,0), YM(4,6)]
    test('测试示例3: [YM(3,9), YM(3,0), YM(4,6)] - [3.75, 3.0, 4.5]', () {
      List<YearMonth> example3 = [
        YearMonth(3, 9),
        YearMonth(3, 0),
        YearMonth(4, 6)
      ];
      List<List<YearMonth>> result3 =
          DaXianCalculateHelper.transformYearMonths(example3);

      // 验证输入转换为double的正确性
      List<double> inputAsDouble =
          example3.map((ym) => ym.toDoubleYear()).toList();
      expect(inputAsDouble, equals([3.75, 3.0, 4.5]));

      // 验证结果类型和结构
      expect(result3, isA<List<List<YearMonth>>>());
      expect(result3.length, equals(3));

      // 期望输出类似: [[1/0, 1/0, 1/0, 0/9], [0/3, 1/0, 1/0, 0/9], [0/3, 1/0, 1/0, 1/0, 1/0, 0/6]]
      expect(result3[0].length, equals(4)); // 第一个列表应该有4个元素
      expect(result3[1].length, equals(4)); // 第二个列表应该有4个元素
      expect(result3[2].length, equals(6)); // 第三个列表应该有6个元素
    });

    // 其他测试用例4: [YM(4,0), YM(5,6), YM(3,9)]
    test('测试示例4: [YM(4,0), YM(5,6), YM(3,9)] - [4.0, 5.5, 3.75]', () {
      List<YearMonth> example4 = [
        YearMonth(4, 0),
        YearMonth(5, 6),
        YearMonth(3, 9)
      ];
      List<List<YearMonth>> result4 =
          DaXianCalculateHelper.transformYearMonths(example4);

      // 验证输入转换为double的正确性
      List<double> inputAsDouble =
          example4.map((ym) => ym.toDoubleYear()).toList();
      expect(inputAsDouble, equals([4.0, 5.5, 3.75]));

      // 验证结果类型和结构
      expect(result4, isA<List<List<YearMonth>>>());
      expect(result4.length, equals(3));

      // 验证每个子列表都不为空
      for (var subList in result4) {
        expect(subList, isNotEmpty);
      }
    });

    // 其他测试用例5: [YM(3,6)] - 单个元素
    test('测试示例5: [YM(3,6)] - [3.5] 单个元素', () {
      List<YearMonth> example5 = [YearMonth(3, 6)];
      List<List<YearMonth>> result5 =
          DaXianCalculateHelper.transformYearMonths(example5);

      // 验证输入转换为double的正确性
      List<double> inputAsDouble =
          example5.map((ym) => ym.toDoubleYear()).toList();
      expect(inputAsDouble, equals([3.5]));

      // 验证结果类型和结构
      expect(result5, isA<List<List<YearMonth>>>());
      expect(result5.length, equals(1));
      expect(result5[0], isNotEmpty);
    });

    // 其他测试用例6: [YM(5,0)] - 整数年份
    test('测试示例6: [YM(5,0)] - [5.0] 整数年份', () {
      List<YearMonth> example6 = [YearMonth(5, 0)];
      List<List<YearMonth>> result6 =
          DaXianCalculateHelper.transformYearMonths(example6);

      // 验证输入转换为double的正确性
      List<double> inputAsDouble =
          example6.map((ym) => ym.toDoubleYear()).toList();
      expect(inputAsDouble, equals([5.0]));

      // 验证结果类型和结构
      expect(result6, isA<List<List<YearMonth>>>());
      expect(result6.length, equals(1));
      expect(result6[0], isNotEmpty);
      expect(result6[0].length, equals(5)); // 5年应该转换为5个1年的元素
    });
  });

  group("洞微大限 ui circle ring paint - DeepSeek", () {
    // 示例 1: 基本使用
    test('测试示例1: 基本使用 - first: 0.25, last: 0.5, kMiddle: 1, total: 21', () {
      var (success, firstAlloc, middleAlloc, lastAlloc) =
          DaXianCalculateHelper.proportionalAllocationWithEnds(
        first: 0.25,
        last: 0.5,
        kMiddle: 1,
        total: 21,
      );

      expect(success, isTrue);
      expect(firstAlloc, closeTo(3.0, 0.0001)); // 3.0000
      expect(middleAlloc.length, equals(1));
      expect(middleAlloc[0], closeTo(12.0, 0.0001)); // 12.0000
      expect(lastAlloc, closeTo(6.0, 0.0001)); // 6.0000

      // 验证总和
      double totalSum = firstAlloc +
          middleAlloc.fold(0.0, (sum, val) => sum + val) +
          lastAlloc;
      expect(totalSum, closeTo(21.0, 0.0001));
    });

    // 示例 2: 首尾为1
    test('测试示例2: 首尾为1 - first: 1.0, last: 1.0, kMiddle: 1, total: 12', () {
      var (success, firstAlloc, middleAlloc, lastAlloc) =
          DaXianCalculateHelper.proportionalAllocationWithEnds(
        first: 1.0,
        last: 1.0,
        kMiddle: 1,
        total: 12,
      );

      expect(success, isTrue);
      expect(firstAlloc, closeTo(4.0, 0.0001)); // 4.0000
      expect(middleAlloc.length, equals(1));
      expect(middleAlloc[0], closeTo(4.0, 0.0001)); // 4.0000
      expect(lastAlloc, closeTo(4.0, 0.0001)); // 4.0000

      // 验证总和
      double totalSum = firstAlloc +
          middleAlloc.fold(0.0, (sum, val) => sum + val) +
          lastAlloc;
      expect(totalSum, closeTo(12.0, 0.0001));
    });

    // 示例 3: 混合值
    test('测试示例3: 混合值 - first: 0.75, last: 1.0, kMiddle: 28, total: 30', () {
      var (success, firstAlloc, middleAlloc, lastAlloc) =
          DaXianCalculateHelper.proportionalAllocationWithEnds(
        first: 0.75,
        last: 1.0,
        kMiddle: 28,
        total: 30,
      );

      expect(success, isTrue);
      expect(firstAlloc, closeTo(0.7563, 0.001)); // ≈0.7563
      expect(middleAlloc.length, equals(28));
      expect(middleAlloc[0], closeTo(1.0084, 0.001)); // ≈1.0084
      expect(lastAlloc, closeTo(1.0084, 0.001)); // ≈1.0084

      // 验证总和
      double totalSum = firstAlloc +
          middleAlloc.fold(0.0, (sum, val) => sum + val) +
          lastAlloc;
      expect(totalSum, closeTo(30.0, 0.001));

      // 验证所有中间项都相等
      for (int i = 1; i < middleAlloc.length; i++) {
        expect(middleAlloc[i], closeTo(middleAlloc[0], 0.0001));
      }
    });

    // 示例 4: 无效输入
    test('测试示例4: 无效输入处理 - first: 0.3 (无效值)', () {
      var (success, firstAlloc, middleAlloc, lastAlloc) =
          DaXianCalculateHelper.proportionalAllocationWithEnds(
        first: 0.3, // 无效值
        last: 0.5,
        kMiddle: 1,
        total: 10,
      );

      expect(success, isFalse);
      // 当success为false时，其他返回值的具体内容可能不重要，但我们仍然可以验证它们的类型
      expect(firstAlloc, isA<double>());
      expect(middleAlloc, isA<List<double>>());
      expect(lastAlloc, isA<double>());
    });

    // 额外测试：边界情况
    test('测试边界情况: 最小有效输入', () {
      var (success, firstAlloc, middleAlloc, lastAlloc) =
          DaXianCalculateHelper.proportionalAllocationWithEnds(
        first: 0.25,
        last: 0.25,
        kMiddle: 1,
        total: 3,
      );

      expect(success, isTrue);
      // 验证总和等于输入的total
      double totalSum = firstAlloc +
          middleAlloc.fold(0.0, (sum, val) => sum + val) +
          lastAlloc;
      expect(totalSum, closeTo(3.0, 0.0001));
    });

    // 额外测试：大量中间项
    test('测试大量中间项: kMiddle = 100', () {
      var (success, firstAlloc, middleAlloc, lastAlloc) =
          DaXianCalculateHelper.proportionalAllocationWithEnds(
        first: 0.5,
        last: 0.75,
        kMiddle: 100,
        total: 1000,
      );

      expect(success, isTrue);
      expect(middleAlloc.length, equals(100));

      // 验证总和
      double totalSum = firstAlloc +
          middleAlloc.fold(0.0, (sum, val) => sum + val) +
          lastAlloc;
      expect(totalSum, closeTo(1000.0, 0.001));

      // 验证所有中间项都相等
      for (int i = 1; i < middleAlloc.length; i++) {
        expect(middleAlloc[i], closeTo(middleAlloc[0], 0.0001));
      }
    });
  });
}
