import '../managers/zhou_tian_model_manager.dart';

class InitializeQiZhengOfficialDataUseCase {
  final ZhouTianModelManager zhouTianModelManager;

  InitializeQiZhengOfficialDataUseCase({
    required this.zhouTianModelManager,
  });

  Future<void> execute() async {
    await zhouTianModelManager.load();
  }
}
