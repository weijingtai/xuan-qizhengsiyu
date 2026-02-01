abstract class FateManager {
  FateManager? _nextManager;

  FateManager setNext(FateManager manager) {
    _nextManager = manager;
    return manager;
  }

  void calculate(DateTime date);

  void passToNext(DateTime date) {
    if (_nextManager != null) {
      _nextManager!.calculate(date);
    }
  }
}
