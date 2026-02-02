import 'package:common/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/conditions/position_conditions.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/conditions/relationship_conditions.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/conditions/structure_conditions.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_rule.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju_model.dart';
import 'package:qizhengsiyu/domain/managers/ge_ju/ge_ju_text_constants.dart';
import 'package:uuid/uuid.dart';

/// T-037: 格局文本解析器
class GeJuTextParser {
  static const _uuid = Uuid();

  /// 解析整段文本
  static List<GeJuRule> parseText(String content) {
    print("Beginning parsing of ${content.length} characters...");
    final rules = <GeJuRule>[];

    // 1. 预处理：按行分割，识别规则块
    // 规则通常以 "序号.名称：" 开始
    // 例如 "1.日边红杏："

    final lines = content.split('\n');
    String? currentId;
    String? currentName;
    StringBuffer currentDescBuffer = StringBuffer();

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // 匹配 "1.日边红杏：" 或 "1.日边红杏"
      final match = RegExp(r'^(\d+)[.．](.+?)[：:]?$').firstMatch(line);

      if (match != null) {
        // 保存前一个规则
        if (currentName != null) {
          rules.add(_buildRule(currentName, currentDescBuffer.toString()));
        }

        // 开始新规则
        currentId = match.group(1); // 暂时不用 external ID，内部生成 UUID
        currentName = match.group(2)?.trim();
        if (currentName != null && currentName.endsWith("：")) {
          currentName = currentName.substring(0, currentName.length - 1);
        }
        currentDescBuffer = StringBuffer();
      } else {
        // 累积描述文本
        if (currentName != null) {
          currentDescBuffer.writeln(line);
        }
      }
    }

    // 添加最后一个
    if (currentName != null) {
      rules.add(_buildRule(currentName, currentDescBuffer.toString()));
    }

    return rules;
  }

  static GeJuRule _buildRule(String name, String rawText) {
    // 提取出处
    // 格式： 《出处》：描述...
    String? source;
    String description = rawText;

    final sourceMatch =
        RegExp(r'《(.+?)》[：:]?(.*)', dotAll: true).firstMatch(rawText);
    if (sourceMatch != null) {
      source = sourceMatch.group(1);
      description = sourceMatch.group(2)?.trim() ?? rawText;
    }

    final conditions = _extractConditions(name, description);

    return GeJuRule(
      id: _uuid.v4(),
      name: name,
      className: "总汇", // 默认为总汇，后续可根据 Section Title 区分
      books: source ?? "未知",
      source: source ?? "",
      description: description,
      jiXiong: _guessJiXiong(description), // 简单推断
      geJuType: GeJuType.pin, // 默认，需后续分析
      scope: GeJuScope.natal,
      conditions: conditions.isNotEmpty
          ? (conditions.length == 1
              ? conditions.first
              : AndCondition(conditions))
          : null,
      coordinateSystem: null,
    );
  }

  static List<GeJuCondition> _extractConditions(String name, String text) {
    final conditions = <GeJuCondition>[];

    // T-036: 这里应用正则模式匹配条件
    // 策略：优先匹配括号内的解释，因为通常括号内是对规则的具体定义
    // "[紅杏者木星也，木為官、恩、命、令等用者，與太陽同行。]"

    String textToScan = text;
    final bracketMatch = RegExp(r'\[(.*?)\]').firstMatch(text);
    if (bracketMatch != null) {
      textToScan = bracketMatch.group(1)!;
    }

    // 1. 同宫/同行 (Same Gong)
    // "木日同行", "与太阳同行", "木水同躔"
    // 简单正则：(星)与(星)同行/同宫
    final sameGongMatches = RegExp(
            r'([日月金木水火土\u4e00-\u9fa5]{1,2})[与与]([日月金木水火土\u4e00-\u9fa5]{1,2})[同合](?:行|宫|躔|辉)')
        .allMatches(textToScan);
    for (var m in sameGongMatches) {
      final s1 = GeJuTextConstants.getStar(m.group(1)!);
      final s2 = GeJuTextConstants.getStar(m.group(2)!);
      if (s1 != null && s2 != null) {
        conditions.add(SameGongCondition([s1, s2]));
      }
    }

    // "木水会命" -> SameGong(Wood, Water, LifeGong?) or StarInDestinyGong

    // 2. 星在宫 (Star In Gong)
    // "木在巳申", "金在亥"
    final starInGongMatches = RegExp(
            r'([日月金木水火土\u4e00-\u9fa5]{1,2})[在入居]([子丑寅卯辰巳午未申酉戌亥\u4e00-\u9fa5]{1,5})[宫地]?')
        .allMatches(textToScan);
    for (var m in starInGongMatches) {
      final starName = m.group(1)!;
      final gongStr = m.group(2)!;
      final star = GeJuTextConstants.getStar(starName);
      if (star != null) {
        // 尝试解析宫位列表，如 "巳申" -> [Si, Shen]
        final gongs = <String>[];
        for (int i = 0; i < gongStr.length; i++) {
          // 单字尝试
          final char = gongStr[i];
          if (GeJuTextConstants.getGong(char) != null) {
            gongs.add(char);
          }
        }
        // 如果单字没匹配上，尝试双字（如"宝瓶"）
        if (gongs.isEmpty) {
          final g = GeJuTextConstants.getGong(gongStr);
          if (g != null) gongs.add(gongStr);
        }

        if (gongs.isNotEmpty) {
          conditions.add(StarInGongCondition(star, gongs));
        }
      }
    }

    // 3. 命立X宫 (Life Gong At)
    // "命立子宫", "安命子宫"
    final lifeGongMatches =
        RegExp(r'[命身][立安居在]([子丑寅卯辰巳午未申酉戌亥\u4e00-\u9fa5]+?)[宫度地]')
            .allMatches(textToScan);
    for (var m in lifeGongMatches) {
      final gongStr = m.group(1)!;
      final g = GeJuTextConstants.getGong(gongStr); // 简单处理单宫
      if (g != null) {
        conditions.add(LifeGongAtCondition([gongStr]));
      } else {
        // 尝试拆分 "寅卯"
        final gongs = <String>[];
        for (int i = 0; i < gongStr.length; i++) {
          final char = gongStr[i];
          if (GeJuTextConstants.getGong(char) != null) gongs.add(char);
        }
        if (gongs.isNotEmpty) conditions.add(LifeGongAtCondition(gongs));
      }
    }

    // 4. 季节 (Season)
    // "冬月生", "春夏"
    if (textToScan.contains("春夏")) {
      // 简单示例
    }

    return conditions;
  }

  static JiXiongEnum _guessJiXiong(String text) {
    if (text.contains("贫") ||
        text.contains("夭") ||
        text.contains("贱") ||
        text.contains("死") ||
        text.contains("凶") ||
        text.contains("忌")) {
      return JiXiongEnum.XIONG; // 需要定义或引用
    }
    return JiXiongEnum.JI; // 默认吉
  }
}
