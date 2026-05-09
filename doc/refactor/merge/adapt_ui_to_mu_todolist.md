# UI层适配MVVM架构 - 原子化任务清单

**目标**: 将 `refactor/74-ui` 分支的UI层代码以最小修改量适配到 `refactor/74-mu` 的MVVM架构

**策略**: 扩展 `QiZhengSiYuViewModel` 使其向后兼容 `BeautyPageViewModel` 的所有接口

**日期**: 2025-10-20

---

## 阶段1: 环境准备与分支管理 ✅

### 1.1 Git分支操作✅
- [x] 确认当前在 `refactor/74-ui` 分支
- [x] 备份当前工作区状态 (git stash 或 commit)
- [x] 创建新的集成分支 `refactor/74-integrated`
- [x] 验证新分支创建成功 (git branch 查看)

### 1.2 备份关键文件 ✅
- [x] 备份 `qizhengsiyu/lib/pages/beauty_page_viewmodel.dart` 到 `.bak`
- [x] 备份 `qizhengsiyu/lib/pages/beauty_view_page.dart` 到 `.bak`
- [x] 备份 `qizhengsiyu/pubspec.yaml` 到 `.bak`
- [x] 创建备份清单文件记录所有备份路径

---

## 阶段2: 深度分析两个分支的接口差异 ✅

### 2.1 分析 UI 分支的 BeautyPageViewModel ✅
- [x] 列出所有 `ValueNotifier` 属性及其类型
- [x] 列出所有 public getter 方法
- [x] 列出所有 public 方法 (init, calculate, 等)
- [x] 列出所有 private 方法的功能 (需要移植的)
- [x] 记录 ChangeNotifier 的使用位置
- [x] 记录依赖的 Manager/Service 类

### 2.2 分析 MVVM 分支的 QiZhengSiYuViewModel ✅
- [x] 列出现有的 public 属性
- [x] 列出现有的 public 方法
- [x] 列出构造函数参数 (依赖注入)
- [x] 记录 UseCase 的调用方式
- [x] 记录 Repository 的使用方式

### 2.3 生成接口对比表 ✅
- [x] 创建 `interface_comparison.md` 文档
- [x] 列出 UI 分支有但 MVVM 分支没有的接口
- [x] 列出两个分支都有但签名不同的接口
- [x] 标记哪些接口需要添加
- [x] 标记哪些接口需要适配

### 2.4 分析 UI 层的实际调用 ✅
- [x] 扫描 `beauty_view_page.dart` 中所有 `context.read<BeautyPageViewModel>()` 调用
- [x] 记录所有 `ValueListenableBuilder` 使用的 notifier
- [x] 记录所有直接访问的 getter
- [x] 记录所有方法调用及其参数
- [x] 生成 `ui_dependencies.md` 文档 (集成到interface_comparison.md)

---

## 阶段3: 合并 MVVM 架构层代码 ✅

### 3.1 合并 domain 层 ✅
- [x] 从 `refactor/74-mu` 检出 `qizhengsiyu/lib/domain/` 整个目录
- [x] 验证 domain 层文件完整性 (检查关键子目录存在)
- [x] 检查是否有编译错误 (暂时忽略缺少依赖的错误)
- [x] 记录 domain 层引入的新依赖包

### 3.2 合并 data 层 ✅
- [x] 从 `refactor/74-mu` 检出 `qizhengsiyu/lib/data/` 整个目录
- [x] 验证 data 层文件完整性
- [x] 检查 DAO 和 Repository 实现是否完整
- [x] 记录 data 层引入的新依赖包

### 3.3 合并依赖注入配置 ✅
- [x] 从 `refactor/74-mu` 检出 `qizhengsiyu/lib/di.dart`
- [x] 阅读 `di.dart` 了解依赖注入结构
- [x] 记录需要注册的 Provider 列表

### 3.4 合并 presentation 层 (选择性) ✅
- [x] 从 `refactor/74-mu` 检出 `qizhengsiyu/lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart`
- [x] 从 `refactor/74-mu` 检出 `qizhengsiyu/lib/presentation/models/ui_star_model.dart`
- [x] 对比 UI 分支和 MVVM 分支的 `ui_star_model.dart` 差异
- [x] 如果有差异, 记录需要手动合并的字段 (发现重复,已删除MVVM版本)

### 3.5 处理 pubspec.yaml ⏸️
- [ ] 从 `refactor/74-mu` 获取新增的依赖包列表
- [ ] 手动将新依赖添加到当前 `pubspec.yaml`
- [ ] 保留 UI 分支的 UI 相关依赖 (lottie, responsive_framework 等)
- [ ] 运行 `flutter pub get`
- [ ] 验证依赖安装成功

### 3.6 处理模型路径迁移 ✅
- [x] 记录 UI 分支 `lib/models/` 下的所有文件
- [x] 对比 MVVM 分支 `lib/domain/entities/models/` 的相同文件
- [x] 确认 MVVM 分支是否包含所有必要的模型
- [x] 如果有缺失, 从 UI 分支复制过去 (已确认完整)

---

## 阶段4: 扩展 QiZhengSiYuViewModel (核心任务) ✅

### 4.1 添加 ValueNotifier 属性 ✅
- [x] 添加 `uiBasePanelNotifier: ValueNotifier<BasePanelModel?>`
- [x] 添加 `uiDaXianPanelNotifier: ValueNotifier<DaXianPanelModel?>`
- [x] 添加 `uiBasicLifeStarsNotifier: ValueNotifier<List<UIStarModel>?>`
- [x] 添加 `uiFateLifeStarsNotifier: ValueNotifier<List<UIStarModel>?>`
- [x] 添加 `baseObserverPositionNotifier: ValueNotifier<ObserverPosition?>`
- [x] 在构造函数中初始化所有 ValueNotifier
- [x] 在 dispose 方法中释放所有 ValueNotifier

### 4.2 添加普通 Getter 属性 ✅
- [x] 添加 `_uiBasicLifeStars: List<UIStarModel>` 及其 getter
- [x] 添加 `_uiFateLifeStars: List<UIStarModel>` 及其 getter
- [x] 添加 `_daXianMapper: Map<EnumStars, FiveStarWalkingInfo>?` 及其 getter
- [x] 添加 `_lifeObserver: ObserverPosition?` 及其 getter
- [x] 验证所有 getter 的返回类型正确

### 4.3 添加 Manager 的 Getter (如果还没有) ✅
- [x] 确认 `shenShaManager` getter 存在
- [x] 确认 `huaYaoManager` getter 存在
- [x] 确认 `zhouTianModelManager` getter 存在
- [x] 如果缺失, 从构造函数参数暴露为 getter (已通过构造函数注入)

### 4.4 实现 init() 方法 ✅
- [x] 创建 `Future<void> init()` 方法
- [x] 在 init 中调用 `zhouTianModelManager.load()`
- [x] 在 init 中加载其他必要的数据源 (如果有)
- [x] 添加错误处理 (try-catch)
- [x] 添加日志记录初始化状态

### 4.5 实现兼容版 calculate() 方法 ✅
- [x] 创建 `Future<void> calculate(ObserverPosition observerPosition)` 方法
- [x] 保存 `observerPosition` 到 `_lifeObserver`
- [x] 更新 `baseObserverPositionNotifier.value`
- [x] 从 `observerPosition` 构建默认的 `BasePanelConfig`
- [x] 调用内部的 MVVM 计算方法
- [x] 添加错误处理和日志

### 4.6 实现 _buildDefaultConfig() 辅助方法 ✅
- [x] 创建 `BasePanelConfig _buildDefaultConfig(ObserverPosition)` 方法
- [x] 设置 `panelSystemType` 为合理默认值
- [x] 设置 `celestialCoordinateSystem` 为合理默认值
- [x] 设置 `settleLifeBodyMode` 为合理默认值
- [x] 从 `observerPosition` 提取必要参数
- [x] 验证生成的 config 的合法性

### 4.7 重命名或重构原有的 calculate 方法 ✅
- [x] 将 MVVM 分支的 `calculate(BasePanelConfig, ObserverPosition)` 重命名为 `calculateWithConfig`
- [x] 更新方法内部的逻辑保持不变
- [x] 确保新方法返回计算结果

### 4.8 在 calculateWithConfig 中更新 ValueNotifier ✅
- [x] 在计算完成后更新 `uiBasePanelNotifier.value = _basicLifePanel`
- [x] 更新 `uiBasicLifeStarsNotifier.value = _uiBasicLifeStars`
- [x] 更新 `baseObserverPositionNotifier.value = observer`
- [x] 确保在更新 notifier 前检查值是否为 null
- [x] 调用 `notifyListeners()` 通知 UI

---

## 阶段5: 移植 UI 星体计算逻辑 ✅

### 5.1 从 UI 分支提取星体计算方法 ✅
- [x] 打开 UI 分支的 `beauty_page_viewmodel.dart`
- [x] 找到 `_calculateUIStars` 或类似的私有方法
- [x] 复制整个方法体
- [x] 记录该方法依赖的其他私有方法和常量

### 5.2 移植星体计算方法到 MVVM ViewModel ✅
- [x] 将 `_calculateUIStars` 方法粘贴到 `QiZhengSiYuViewModel`
- [x] 移植方法依赖的所有常量 (如 `_uiSafetyAnglePadding`)
- [x] 移植方法依赖的所有辅助方法
- [x] 更新方法内部的数据访问路径 (适配新的数据结构)
- [x] 处理 `BasePanelModel` 到 `UIStarModel` 的转换逻辑

### 5.3 实现星体位置防重叠逻辑 ✅
- [x] 找到 UI 分支中防止星体重叠的算法
- [x] 理解算法的输入输出
- [x] 移植算法到新 ViewModel
- [x] 测试算法在边界情况下的表现

### 5.4 实现星体速度和状态计算 ✅
- [x] 移植星体顺逆行状态计算逻辑
- [x] 移植星体速度显示逻辑
- [x] 移植星体特殊状态标记逻辑 (如入庙、失陷等)

### 5.5 验证 UIStarModel 生成 ✅
- [x] 添加日志输出 `_uiBasicLifeStars` 的数量
- [x] 验证每个 `UIStarModel` 的关键字段非空
- [x] 验证星体角度范围正确 (0-360)

---

## 阶段6: 处理大限盘 (DaXianPanel) 计算

### 6.1 分析 UI 分支的大限盘逻辑
- [ ] 找到 UI 分支中大限盘计算的入口
- [ ] 记录大限盘计算依赖的数据
- [ ] 记录大限盘的计算流程
- [ ] 记录大限盘结果的数据结构

### 6.2 确认 MVVM 分支是否有大限盘支持
- [ ] 检查 `domain/` 层是否有大限盘相关 UseCase
- [ ] 检查是否有 `DaXianPanelModel` 定义
- [ ] 检查是否有大限盘计算的 Service

### 6.3 移植或集成大限盘计算
- [ ] 如果 MVVM 分支有, 集成到 `calculateWithConfig` 中
- [ ] 如果 MVVM 分支没有, 从 UI 分支移植计算逻辑
- [ ] 更新 `uiDaXianPanelNotifier.value` 在计算完成后

### 6.4 实现大限盘 UI 数据生成
- [ ] 移植大限盘星体 UI 数据生成逻辑 (如果有)
- [ ] 更新 `uiFateLifeStarsNotifier.value`
- [ ] 验证大限盘数据结构完整

---

## 阶段7: 处理数据模型转换

### 7.1 处理 DivinationInfoModel 兼容性
- [ ] 检查 UI 层是否使用 `DivinationInfoModel`
- [ ] 如果使用, 创建 `setLifeObserver(DivinationInfoModel)` 方法
- [ ] 在方法中将 `DivinationInfoModel` 转换为 `ObserverPosition`
- [ ] 更新 `_lifeObserver` 并触发计算

### 7.2 处理 PanelConfig 模型差异
- [ ] 对比 UI 分支和 MVVM 分支的 `PanelConfig` 定义
- [ ] 记录字段差异
- [ ] 如果有新增字段, 在 `_buildDefaultConfig` 中设置默认值
- [ ] 如果有删除字段, 移除依赖

### 7.3 处理 ObserverPosition 模型差异
- [ ] 对比两个分支的 `ObserverPosition` 定义
- [ ] 确认字段兼容性
- [ ] 如果不兼容, 创建转换方法

---

## 阶段8: 最小化修改 UI 层代码

### 8.1 更新 beauty_view_page.dart 的导入
- [ ] 注释掉 `import 'beauty_page_viewmodel.dart';`
- [ ] 添加 `import '../presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';`
- [ ] 添加所需的 model 导入 (从 `domain/entities/models/` 路径)
- [ ] 验证所有导入路径正确

### 8.2 替换 ViewModel 类型引用
- [ ] 全局搜索 `BeautyPageViewModel` 替换为 `QiZhengSiYuViewModel`
- [ ] 确认所有 `context.read<BeautyPageViewModel>()` 已替换
- [ ] 确认所有类型声明已替换
- [ ] 保持其他代码完全不变

### 8.3 验证 UI 调用兼容性
- [ ] 确认所有 `vm.uiBasePanelNotifier` 调用仍然有效
- [ ] 确认所有 `vm.calculate()` 调用仍然有效
- [ ] 确认所有 `vm.init()` 调用仍然有效
- [ ] 确认所有 getter 访问仍然有效

### 8.4 处理其他 UI 文件 (如果有)
- [ ] 搜索项目中所有导入 `beauty_page_viewmodel.dart` 的文件
- [ ] 对每个文件重复 8.1-8.3 的步骤
- [ ] 记录所有修改的文件列表

---

## 阶段9: 更新依赖注入和初始化

### 9.1 分析 MVVM 分支的 di.dart
- [ ] 阅读 `di.dart` 了解依赖注入架构
- [ ] 记录需要注册的所有 Provider
- [ ] 记录依赖的注入顺序

### 9.2 更新 main.dart 的 Provider 注册
- [ ] 打开主 app 的 `main.dart`
- [ ] 找到 Provider 注册区域
- [ ] 注释掉或删除旧的 `BeautyPageViewModel` Provider
- [ ] 添加 `QiZhengSiYuViewModel` Provider
- [ ] 确保依赖的 Manager 已经注册 (ShenShaManager, HuaYaoManager, ZhouTianModelManager)

### 9.3 注册必要的 Repository 和 DataSource
- [ ] 添加 `HuaYaoLocalDataSource` Provider (如果需要)
- [ ] 添加 `ShenShaLocalDataSource` Provider (如果需要)
- [ ] 添加 `HuaYaoRepositoryImpl` Provider
- [ ] 添加 `ShenShaRepositoryImpl` Provider
- [ ] 验证注册顺序正确 (底层先注册)

### 9.4 更新 qizhengsiyu 模块的 main.dart (如果有)
- [ ] 检查 `qizhengsiyu/lib/main.dart` 是否存在
- [ ] 如果存在, 更新其中的 Provider 注册
- [ ] 确保与主 app 的注册保持一致

---

## 阶段10: 处理模型导入路径迁移

### 10.1 生成模型迁移映射表
- [ ] 列出 UI 分支所有 `lib/models/` 的文件
- [ ] 列出对应的 MVVM 分支 `lib/domain/entities/models/` 文件
- [ ] 生成映射表 (旧路径 -> 新路径)
- [ ] 保存为 `model_path_migration.md`

### 10.2 更新 UI 层的 model 导入
- [ ] 在 `beauty_view_page.dart` 中查找所有 model 导入
- [ ] 按照映射表更新每个导入路径
- [ ] 将 `import 'package:qizhengsiyu/models/xxx.dart'` 改为 `import 'package:qizhengsiyu/domain/entities/models/xxx.dart'`
- [ ] 验证所有导入无错误

### 10.3 更新 widget 层的 model 导入
- [ ] 在 `qizhengsiyu/lib/widgets/` 下搜索所有 model 导入
- [ ] 逐个文件更新导入路径
- [ ] 验证编译无错误

### 10.4 更新 painter 层的 model 导入
- [ ] 在 `qizhengsiyu/lib/painter/` 下搜索所有 model 导入
- [ ] 逐个文件更新导入路径
- [ ] 验证编译无错误

---

## 阶段11: 处理 Manager 和 Service 的路径迁移

### 11.1 更新 Manager 导入路径
- [ ] 查找 UI 层中所有 `import '.../managers/xxx.dart'`
- [ ] 更新为 `import '.../domain/managers/xxx.dart'`
- [ ] 验证 Manager 类在新位置存在

### 11.2 更新 Service 导入路径
- [ ] 查找 UI 层中所有 `import '.../services/xxx.dart'`
- [ ] 更新为 `import '.../domain/services/xxx.dart'`
- [ ] 验证 Service 类在新位置存在

### 11.3 处理可能的类名冲突
- [ ] 如果有类名冲突, 使用 `as` 别名
- [ ] 记录所有使用别名的地方

---

## 阶段12: 编译和修复错误

### 12.1 首次编译尝试
- [ ] 运行 `flutter pub get` 确保依赖最新
- [ ] 运行 `flutter analyze` 查看静态分析错误
- [ ] 记录所有错误和警告到 `compile_errors.md`
- [ ] 按优先级对错误分类 (致命 / 重要 / 次要)

### 12.2 修复导入错误
- [ ] 修复所有 "undefined class" 错误
- [ ] 修复所有 "file not found" 错误
- [ ] 确保所有导入路径正确

### 12.3 修复类型错误
- [ ] 修复所有类型不匹配错误
- [ ] 修复所有 null safety 错误
- [ ] 修复所有泛型参数错误

### 12.4 修复方法签名错误
- [ ] 修复所有 "method not found" 错误
- [ ] 修复所有参数不匹配错误
- [ ] 添加缺失的方法实现

### 12.5 修复常量和枚举错误
- [ ] 修复所有枚举值访问错误
- [ ] 修复所有常量访问错误

### 12.6 再次编译验证
- [ ] 运行 `flutter analyze` 确认无错误
- [ ] 运行 `flutter build apk --debug` 尝试构建
- [ ] 如果有错误, 返回 12.2 继续修复

---

## 阶段13: 代码生成和数据库迁移

### 13.1 运行代码生成
- [ ] 运行 `flutter packages pub run build_runner clean`
- [ ] 运行 `flutter packages pub run build_runner build --delete-conflicting-outputs`
- [ ] 检查生成的 `.g.dart` 文件是否正确
- [ ] 检查生成的 `.drift.dart` 文件是否正确

### 13.2 处理数据库迁移
- [ ] 对比 UI 分支和 MVVM 分支的数据库表结构
- [ ] 确认 MVVM 分支的数据库包含所有必要的表
- [ ] 如果有新表, 验证 DAO 已实现
- [ ] 如果有表结构变更, 编写迁移脚本

### 13.3 验证 Drift 配置
- [ ] 检查 `app_database.dart` 的表注册
- [ ] 检查所有 DAO 的导出
- [ ] 确认数据库版本号正确

---

## 阶段14: 单元测试和验证

### 14.1 测试 ViewModel 初始化
- [ ] 创建简单的测试文件 `qi_zheng_si_yu_viewmodel_test.dart`
- [ ] 测试 `init()` 方法能成功执行
- [ ] 测试所有 ValueNotifier 正确初始化
- [ ] 测试依赖注入正确

### 14.2 测试兼容接口
- [ ] 测试 `calculate(ObserverPosition)` 方法调用成功
- [ ] 测试调用后 `uiBasePanelNotifier.value` 非空
- [ ] 测试调用后 `uiBasicLifeStars` 非空
- [ ] 测试 ValueNotifier 正确触发通知

### 14.3 测试数据转换
- [ ] 测试 `_buildDefaultConfig` 生成的配置合法
- [ ] 测试 `ObserverPosition` 数据正确传递
- [ ] 测试星体数据转换为 `UIStarModel` 正确

### 14.4 测试边界情况
- [ ] 测试 `calculate` 在 `init` 之前调用的处理
- [ ] 测试无效输入的错误处理
- [ ] 测试空数据的处理

---

## 阶段15: 集成测试和 UI 验证

### 15.1 启动应用
- [ ] 连接测试设备或启动模拟器
- [ ] 运行 `flutter run` 启动应用
- [ ] 观察启动过程中的日志输出
- [ ] 记录任何运行时错误

### 15.2 测试 UI 初始化
- [ ] 导航到七政四余模块
- [ ] 验证页面能正常加载
- [ ] 验证没有渲染错误
- [ ] 验证没有崩溃

### 15.3 测试星盘计算
- [ ] 触发星盘计算 (通过 UI 操作)
- [ ] 验证星盘正确绘制
- [ ] 验证星体位置正确显示
- [ ] 验证没有星体重叠
- [ ] 验证星体信息完整

### 15.4 测试 ValueNotifier 响应
- [ ] 修改输入参数 (如时间、地点)
- [ ] 验证 UI 自动刷新
- [ ] 验证 `ValueListenableBuilder` 正确响应
- [ ] 验证数据更新及时

### 15.5 测试大限盘功能
- [ ] 触发大限盘计算
- [ ] 验证大限盘数据正确显示
- [ ] 验证大限盘 UI 正确渲染

### 15.6 测试交互功能
- [ ] 测试星体点击事件
- [ ] 测试宫位交互
- [ ] 测试配置修改
- [ ] 测试页面切换

---

## 阶段16: 性能测试和优化

### 16.1 性能基准测试
- [ ] 记录星盘计算耗时
- [ ] 记录 UI 渲染帧率
- [ ] 对比 UI 分支的性能基准
- [ ] 识别性能瓶颈

### 16.2 优化 ValueNotifier 使用
- [ ] 检查是否有不必要的 notifyListeners 调用
- [ ] 确保 ValueNotifier 只在值变化时更新
- [ ] 优化 ValueListenableBuilder 的范围

### 16.3 优化星体计算
- [ ] 检查星体计算是否有重复计算
- [ ] 添加必要的缓存
- [ ] 优化循环和算法

---

## 阶段17: 代码清理和文档

### 17.1 清理备份文件
- [ ] 删除所有 `.bak` 备份文件 (确认不需要后)
- [ ] 删除无用的注释代码
- [ ] 删除调试用的 print 语句

### 17.2 添加代码注释
- [ ] 为新增的兼容接口添加注释说明
- [ ] 标记哪些是兼容层代码
- [ ] 标记未来可以重构的地方
- [ ] 添加 TODO 注释标记待完成的功能

### 17.3 更新文档
- [ ] 更新 `adapt_ui_to_mu_todolist.md` 标记完成状态
- [ ] 创建 `integration_report.md` 记录集成结果
- [ ] 记录遇到的问题和解决方案
- [ ] 记录性能对比数据
- [ ] 记录未来的优化方向

### 17.4 代码格式化
- [ ] 运行 `dart format .` 格式化所有代码
- [ ] 检查格式化后的代码无语法错误
- [ ] 提交格式化后的代码

---

## 阶段18: Git 提交和分支管理

### 18.1 审查修改
- [ ] 运行 `git status` 查看所有修改文件
- [ ] 运行 `git diff` 审查关键文件的变更
- [ ] 确认没有意外修改
- [ ] 确认没有遗漏文件

### 18.2 分阶段提交
- [ ] 提交阶段3: 合并 MVVM 架构层
  - commit 信息: "chore: merge MVVM architecture layers (domain/data)"
- [ ] 提交阶段4-6: ViewModel 扩展
  - commit 信息: "feat: extend QiZhengSiYuViewModel with UI compatibility layer"
- [ ] 提交阶段8: UI 层最小化修改
  - commit 信息: "refactor: adapt UI layer to use QiZhengSiYuViewModel"
- [ ] 提交阶段9: 依赖注入更新
  - commit 信息: "refactor: update dependency injection for MVVM architecture"
- [ ] 提交阶段17: 代码清理
  - commit 信息: "chore: code cleanup and documentation"

### 18.3 创建 Pull Request (可选)
- [ ] 推送 `refactor/74-integrated` 分支到远程
- [ ] 创建 PR: `refactor/74-integrated` -> `master`
- [ ] 填写 PR 描述, 引用相关 issue
- [ ] 请求代码审查

---

## 阶段19: 回归测试和验收

### 19.1 完整功能测试
- [ ] 测试所有七政四余功能模块
- [ ] 测试所有输入场景 (不同时间、地点)
- [ ] 测试所有配置选项
- [ ] 测试所有系统切换 (如果支持)

### 19.2 跨平台测试
- [ ] 在 Android 设备上测试
- [ ] 在 iOS 设备上测试 (如果可用)
- [ ] 在 Web 浏览器上测试 (如果支持)
- [ ] 记录平台特定问题

### 19.3 边界和异常测试
- [ ] 测试极端日期 (如公元前、未来日期)
- [ ] 测试极端地理位置 (南北极、赤道)
- [ ] 测试网络异常情况
- [ ] 测试数据库异常情况

### 19.4 用户验收测试
- [ ] 邀请实际用户测试
- [ ] 收集用户反馈
- [ ] 记录用户发现的 bug
- [ ] 优先修复关键 bug

---

## 阶段20: 后续优化计划

### 20.1 识别技术债务
- [ ] 列出所有标记为 TODO 的代码
- [ ] 列出所有兼容层代码 (未来可以移除的)
- [ ] 列出所有性能优化点
- [ ] 创建技术债务清单

### 20.2 制定重构路线图
- [ ] 计划逐步移除兼容层
- [ ] 计划完全迁移到 MVVM 架构
- [ ] 计划性能优化迭代
- [ ] 设定时间节点

### 20.3 文档和知识分享
- [ ] 编写架构迁移指南
- [ ] 分享集成经验和教训
- [ ] 培训团队成员使用新架构
- [ ] 更新项目文档

---

## 验收标准

- [ ] **编译成功**: `flutter analyze` 无错误
- [ ] **功能完整**: 所有 UI 功能正常工作
- [ ] **性能达标**: 性能不低于 UI 分支
- [ ] **代码质量**: 符合项目编码规范
- [ ] **测试覆盖**: 关键路径有单元测试
- [ ] **文档完整**: 所有变更有文档记录
- [ ] **无回归**: 没有引入新的 bug

---

## 风险和应对

### 风险1: ViewModel 接口不完全兼容
- **应对**: 在阶段2详细对比, 确保完全覆盖
- **备用方案**: 如果差异太大, 考虑创建适配器类

### 风险2: UI 星体计算逻辑复杂难以移植
- **应对**: 先保留 UI 分支的原始逻辑, 作为独立模块
- **备用方案**: 逐步重写而非一次性移植

### 风险3: 数据库结构不兼容
- **应对**: 在阶段13检查表结构, 编写迁移脚本
- **备用方案**: 保留两个数据库版本, 运行时自动迁移

### 风险4: 性能下降
- **应对**: 在阶段16进行性能测试和优化
- **备用方案**: 回滚到 UI 分支, 重新评估方案

### 风险5: 第三方依赖冲突
- **应对**: 在阶段3.5仔细检查依赖版本
- **备用方案**: 使用 `dependency_overrides` 临时解决

---

## 参考资料

- [UI 重构报告](../ui/beauty_page_report.md)
- [MVVM 架构文档](../../docs/code_arch.md)
- [接口对比文档](./interface_comparison.md) (待生成)
- [模型迁移映射表](./model_path_migration.md) (待生成)
- [集成报告](./integration_report.md) (待生成)

---

**最后更新**: 2025-10-20
**负责人**: Claude Code
**预计完成时间**: 根据执行进度动态调整
