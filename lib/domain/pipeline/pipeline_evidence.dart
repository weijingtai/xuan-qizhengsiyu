/// 排盘执行证据 —— 供壳侧 E2E 测试断言「executor 确实执行了」。
///
/// 只读数据对象：不参与生产逻辑判断、不影响渲染。
/// 字段语义与九模块契约保持一致：
///   - [callCount]   executor.execute 被调用的累计次数
///   - [requestId]   本次 ChartRequest 的标识（七政取 params.uuid）
///   - [resultUuid]  本次排盘结果的 uuid（与落库 Record 的 uuid 同源）
///   - [module]      模块 id（与 RecordMeta.module 一致：qizhengsiyu）
///   - [keyResult]   页面可观察的关键结果（七政取命宫所在宫位）
///   - [error]       本次执行的异常；成功为 null
final class PipelineEvidence {
  final int callCount;
  final String? requestId;
  final String? resultUuid;
  final String module;
  final Object? keyResult;
  final Object? error;

  const PipelineEvidence({
    required this.callCount,
    required this.requestId,
    required this.resultUuid,
    required this.module,
    required this.keyResult,
    required this.error,
  });

  @override
  String toString() =>
      'PipelineEvidence(module: $module, callCount: $callCount, '
      'requestId: $requestId, resultUuid: $resultUuid, '
      'keyResult: $keyResult, error: $error)';
}
