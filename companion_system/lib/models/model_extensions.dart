/// 数据模型扩展，添加转换方法

import 'package:drift/drift.dart';
import 'package:companion_system/database/drift_database.dart';
import 'package:companion_system/models/enums.dart';

/// Pattern扩展
extension PatternExtension on Pattern {
  GeJuPatternsCompanion toData() {
    return GeJuPatternsCompanion(
      id: Value(id),
      name: Value(name),
      englishName: Value(englishName),
      pinyin: Value(pinyin),
      aliases: Value(aliases),
      categoryId: Value(categoryId),
      keywords: Value(keywords),
      tags: Value(tags),
      description: Value(description),
      originNotes: Value(originNotes),
      referenceCount: Value(referenceCount),
      ruleCount: Value(ruleCount),
      createdAt: Value(createdAt),
    );
  }
}

/// School扩展
extension SchoolExtension on School {
  GeJuSchoolsCompanion toData() {
    return GeJuSchoolsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      era: Value(era),
      founder: Value(founder),
      description: Value(description),
      isActive: Value(isActive),
      ruleCount: Value(ruleCount),
      createdAt: Value(createdAt),
    );
  }
}

/// Rule扩展
extension RuleExtension on Rule {
  GeJuRulesCompanion toData() {
    return GeJuRulesCompanion(
      id: Value(id),
      patternId: Value(patternId),
      schoolId: Value(schoolId),
      jixiong: Value(jixiong),
      level: Value(level),
      geJuType: Value(geJuType),
      scope: Value(scope),
      coordinateSystem: Value(coordinateSystem),
      conditions: Value(conditions),
      assertion: Value(assertion),
      brief: Value(brief),
      chapter: Value(chapter),
      originalText: Value(originalText),
      explanation: Value(explanation),
      notes: Value(notes),
      version: Value(version),
      versionRemark: Value(versionRemark),
      isActive: Value(isActive),
      isVerified: Value(isVerified),
      priority: Value(priority),
      viewCount: Value(viewCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  /// 获取吉凶枚举
  Jixiong get jixiongEnum {
    switch (jixiong) {
      case '吉':
        return Jixiong.ji;
      case '平':
        return Jixiong.ping;
      case '凶':
        return Jixiong.xiong;
      default:
        return Jixiong.ping;
    }
  }

  /// 获取层级枚举
  Level get levelEnum {
    switch (level) {
      case '小':
        return Level.xiao;
      case '中':
        return Level.zhong;
      case '大':
        return Level.da;
      default:
        return Level.zhong;
    }
  }

  /// 获取格局类型枚举
  GeJuType get geJuTypeEnum {
    switch (geJuType) {
      case '贫':
        return GeJuType.pin;
      case '贱':
        return GeJuType.jian;
      case '富':
        return GeJuType.fu;
      case '贵':
        return GeJuType.gui;
      case '夭':
        return GeJuType.yao;
      case '寿':
        return GeJuType.shou;
      case '贤':
        return GeJuType.xian;
      case '愚':
        return GeJuType.yu;
      case '平':
        return GeJuType.pin;
      default:
        return GeJuType.pin;
    }
  }

  /// 获取适用范围枚举
  Scope get scopeEnum {
    switch (scope) {
      case 'natal':
        return Scope.natal;
      case 'xingxian':
        return Scope.xingxian;
      case 'both':
        return Scope.both;
      default:
        return Scope.natal;
    }
  }
}

/// RuleVersion扩展
extension RuleVersionExtension on RuleVersion {
  GeJuVersionsCompanion toData() {
    return GeJuVersionsCompanion(
      id: Value(id),
      ruleId: Value(ruleId),
      version: Value(version),
      versionRemark: Value(versionRemark),
      operationType: Value(operationType),
      changedFields: Value(changedFields),
      snapshot: Value(snapshot),
      diffFromPrevious: Value(diffFromPrevious),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  /// 获取操作类型枚举
  OperationType get operationTypeEnum {
    switch (operationType) {
      case 'create':
        return OperationType.create;
      case 'update':
        return OperationType.update;
      case 'verify':
        return OperationType.verify;
      case 'deactivate':
        return OperationType.deactivate;
      case 'rollback':
        return OperationType.update;
      default:
        return OperationType.update;
    }
  }
}

/// Category扩展
extension CategoryExtension on Category {
  GeJuCategoriesCompanion toData() {
    return GeJuCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      order: Value(order),
      parentId: Value(parentId),
      isActive: Value(isActive),
      patternCount: Value(patternCount),
      createdAt: Value(createdAt),
    );
  }
}
