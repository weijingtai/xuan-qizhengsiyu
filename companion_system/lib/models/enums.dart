/// 吉凶枚举（7级，与主项目 JiXiongEnum 对齐）
enum JiXiong {
  daJi('大吉'),
  ji('吉'),
  xiaoJi('小吉'),
  ping('平'),
  xiaoXiong('小凶'),
  xiong('凶'),
  daXiong('大凶');

  const JiXiong(this.label);
  final String label;

  static JiXiong fromLabel(String label) {
    return JiXiong.values.firstWhere(
      (e) => e.label == label,
      orElse: () => JiXiong.ping,
    );
  }
}

/// 格局类型枚举
enum GeJuType {
  /// 贫
  gui,
  
  /// 富
  fu,
  
  /// 贫
  pin,
  
  /// 贱
  jian,
  
  /// 夭
  yao,
  
  /// 寿
  shou,
  
  /// 贤
  xian,
  
  /// 愚
  yu,
}

/// 适用范围枚举
enum Scope {
  /// 仅命盘
  natal,
  
  /// 仅行限
  xingxian,
  
  /// 通用
  both,
}

/// 操作类型枚举
enum OperationType {
  /// 创建
  create,
  
  /// 更新
  update,
  
  /// 验证
  verify,
  
  /// 停用/删除
  deactivate,
}

/// 坐标系要求枚举
enum CoordinateSystem {
  /// 黄道制
  ecliptic,
  
  /// 赤道制
  equatorial,
}

/// 格局类型中文显示
String geJuTypeToChinese(GeJuType geJuType) {
  switch (geJuType) {
    case GeJuType.gui:
      return '贵';
    case GeJuType.fu:
      return '富';
    case GeJuType.pin:
      return '贫';
    case GeJuType.jian:
      return '贱';
    case GeJuType.yao:
      return '夭';
    case GeJuType.shou:
      return '寿';
    case GeJuType.xian:
      return '贵';
    case GeJuType.yu:
      return '愚';
  }
}

/// 适用范围中文显示
String scopeToChinese(Scope scope) {
  switch (scope) {
    case Scope.natal:
      return '仅命盘';
    case Scope.xingxian:
      return '仅行限';
    case Scope.both:
      return '通用';
  }
}
