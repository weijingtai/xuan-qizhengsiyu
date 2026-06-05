/// Stub for missing data source
import '../models/layout_template.dart';

class LayoutTemplateLocalDataSource {
  Future<List<LayoutTemplate>> getAll(String collectionId) async => [];
  Future<LayoutTemplate?> getById(String collectionId, String templateId) async => null;
  Future<void> save(LayoutTemplate template) async {}
  Future<void> delete(String collectionId, String templateId) async {}
}
