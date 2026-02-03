import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition.dart';
import 'package:qizhengsiyu/presentation/models/condition_type_registry.dart';
import 'package:uuid/uuid.dart';

/// 条件节点类型
enum ConditionNodeType {
  logic, // 逻辑节点 (AND/OR/NOT)
  leaf, // 叶子节点（具体条件）
}

/// 条件编辑器节点
///
/// 用于在 UI 中表示和编辑条件树结构。
/// 该类提供了在 [ConditionEditorNode] 和 [GeJuCondition] 之间的转换方法。
class ConditionEditorNode {
  final String id;
  ConditionNodeType nodeType;
  String conditionType; // 'and', 'or', 'not', 'starInGong', ...
  Map<String, dynamic> params;
  List<ConditionEditorNode> children;

  static const _uuid = Uuid();

  ConditionEditorNode({
    String? id,
    required this.nodeType,
    required this.conditionType,
    Map<String, dynamic>? params,
    List<ConditionEditorNode>? children,
  })  : id = id ?? _uuid.v4(),
        params = params ?? {},
        children = children ?? [];

  /// 创建一个新的逻辑节点
  factory ConditionEditorNode.logic(String type,
      {List<ConditionEditorNode>? children}) {
    assert(['and', 'or', 'not'].contains(type),
        'Logic type must be and, or, or not');
    return ConditionEditorNode(
      nodeType: ConditionNodeType.logic,
      conditionType: type,
      children: children ?? [],
    );
  }

  /// 创建一个新的叶子节点
  factory ConditionEditorNode.leaf(String type, Map<String, dynamic> params) {
    return ConditionEditorNode(
      nodeType: ConditionNodeType.leaf,
      conditionType: type,
      params: params,
    );
  }

  /// 是否为逻辑节点
  bool get isLogic => nodeType == ConditionNodeType.logic;

  /// 是否为叶子节点
  bool get isLeaf => nodeType == ConditionNodeType.leaf;

  /// 是否为 AND 节点
  bool get isAnd => conditionType == 'and';

  /// 是否为 OR 节点
  bool get isOr => conditionType == 'or';

  /// 是否为 NOT 节点
  bool get isNot => conditionType == 'not';

  /// 是否可以添加子节点（逻辑节点可以添加子节点）
  bool get canAddChild => isLogic;

  /// 获取条件类型的显示名称
  String get displayName {
    if (isLogic) {
      return ConditionTypeRegistry.logicTypeDisplayNames[conditionType] ??
          conditionType.toUpperCase();
    }
    final definition = ConditionTypeRegistry.getByType(conditionType);
    return definition?.displayName ?? conditionType;
  }

  /// 获取条件类型的分类
  String? get category {
    if (isLogic) return null;
    final definition = ConditionTypeRegistry.getByType(conditionType);
    return definition?.category;
  }

  /// 生成人类可读的描述
  String describe() {
    if (isLogic) {
      switch (conditionType) {
        case 'and':
          if (children.isEmpty) return '(空 AND)';
          return '(${children.map((c) => c.describe()).join(' 且 ')})';
        case 'or':
          if (children.isEmpty) return '(空 OR)';
          return '(${children.map((c) => c.describe()).join(' 或 ')})';
        case 'not':
          if (children.isEmpty) return '非(空)';
          return '非(${children.first.describe()})';
        default:
          return conditionType;
      }
    }

    // 叶子节点：尝试转换为 GeJuCondition 并调用其 describe 方法
    try {
      final condition = toCondition();
      return condition.describe();
    } catch (_) {
      // 无法转换时，显示简化描述
      return '$displayName: ${_formatParams()}';
    }
  }

  /// 格式化参数为简短描述
  String _formatParams() {
    if (params.isEmpty) return '(无参数)';
    final parts = <String>[];
    params.forEach((key, value) {
      if (value is List) {
        parts.add('${value.length}项');
      } else {
        parts.add('$value');
      }
    });
    return parts.join(', ');
  }

  /// 添加子节点
  void addChild(ConditionEditorNode child) {
    if (canAddChild) {
      children.add(child);
    }
  }

  /// 移除子节点
  void removeChild(String childId) {
    children.removeWhere((c) => c.id == childId);
  }

  /// 查找子节点（递归）
  ConditionEditorNode? findChild(String childId) {
    if (id == childId) return this;
    for (var child in children) {
      final found = child.findChild(childId);
      if (found != null) return found;
    }
    return null;
  }

  /// 替换子节点
  bool replaceChild(String childId, ConditionEditorNode newChild) {
    for (int i = 0; i < children.length; i++) {
      if (children[i].id == childId) {
        children[i] = newChild;
        return true;
      }
      if (children[i].replaceChild(childId, newChild)) {
        return true;
      }
    }
    return false;
  }

  /// 转换为 GeJuCondition 对象
  GeJuCondition toCondition() {
    if (isLogic) {
      switch (conditionType) {
        case 'and':
          return AndCondition(children.map((c) => c.toCondition()).toList());
        case 'or':
          return OrCondition(children.map((c) => c.toCondition()).toList());
        case 'not':
          if (children.isEmpty) {
            throw StateError('NOT condition must have exactly one child');
          }
          return NotCondition(children.first.toCondition());
        default:
          throw StateError('Unknown logic type: $conditionType');
      }
    }

    // 叶子节点：使用 JSON 工厂方法创建
    final json = {'type': conditionType, ...params};
    return GeJuCondition.fromJson(json);
  }

  /// 从 GeJuCondition 创建编辑器节点
  static ConditionEditorNode fromCondition(GeJuCondition condition) {
    if (condition is AndCondition) {
      return ConditionEditorNode(
        nodeType: ConditionNodeType.logic,
        conditionType: 'and',
        children: condition.conditions.map(fromCondition).toList(),
      );
    } else if (condition is OrCondition) {
      return ConditionEditorNode(
        nodeType: ConditionNodeType.logic,
        conditionType: 'or',
        children: condition.conditions.map(fromCondition).toList(),
      );
    } else if (condition is NotCondition) {
      return ConditionEditorNode(
        nodeType: ConditionNodeType.logic,
        conditionType: 'not',
        children: [fromCondition(condition.condition)],
      );
    } else {
      // 叶子节点：从 toJson 提取参数
      final json = condition.toJson();
      final type = json.remove('type') as String? ?? 'unknown';
      return ConditionEditorNode(
        nodeType: ConditionNodeType.leaf,
        conditionType: type,
        params: json,
      );
    }
  }

  /// 深拷贝节点
  ConditionEditorNode copy({bool generateNewId = true}) {
    return ConditionEditorNode(
      id: generateNewId ? null : id,
      nodeType: nodeType,
      conditionType: conditionType,
      params: Map.from(params),
      children: children.map((c) => c.copy(generateNewId: generateNewId)).toList(),
    );
  }

  /// 转换为 JSON（用于调试或持久化）
  Map<String, dynamic> toDebugJson() {
    return {
      'id': id,
      'nodeType': nodeType.name,
      'conditionType': conditionType,
      'params': params,
      if (children.isNotEmpty) 'children': children.map((c) => c.toDebugJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'ConditionEditorNode(type: $conditionType, children: ${children.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConditionEditorNode && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
