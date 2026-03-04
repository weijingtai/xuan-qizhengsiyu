/// 吉凶基础类型枚举
enum Jixiong {
  /// 吉
  ji,
  
  /// 平
  ping,
  
  /// 凶
  xiong;
}

/// 吉凶强度层级枚举
enum Level {
  /// 小
  xiao,
  
  /// 中
  zhong,
  
  /// 大
  da;
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

/// 吉凶中文显示
String jixiongToChinese(Jixiong jixiong) {
  switch (jixiong) {
    case Jixiong.ji:
      return '吉';
    case Jixiong.ping:
      return '平';
    case Jixiong.xiong:
      return '凶';
  }
}

/// 层级中文显示
String levelToChinese(Level level) {
  switch (level) {
    case Level.xiao:
      return '小';
    case Level.zhong:
      return '中';
    case Level.da:
      return '大';
  }
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
