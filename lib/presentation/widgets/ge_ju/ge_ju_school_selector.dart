import 'package:flutter/material.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_school.dart';

/// 流派多选组件（FilterChip Wrap）
class GeJuSchoolSelector extends StatelessWidget {
  final List<GeJuSchool> allSchools;
  final List<String> selectedIds;
  final ValueChanged<List<String>>? onChanged;
  final bool enabled;

  const GeJuSchoolSelector({
    super.key,
    required this.allSchools,
    required this.selectedIds,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (allSchools.isEmpty) {
      return Text('暂无流派', style: TextStyle(color: Colors.grey.shade500));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: allSchools.map((school) {
        final isSelected = selectedIds.contains(school.id);
        return FilterChip(
          avatar: Icon(
            school.isBuiltIn ? Icons.lock_outline : Icons.person_outline,
            size: 16,
          ),
          label: Text(school.name),
          selected: isSelected,
          onSelected: enabled && onChanged != null
              ? (selected) {
                  final newIds = List<String>.from(selectedIds);
                  if (selected) {
                    newIds.add(school.id);
                  } else {
                    newIds.remove(school.id);
                  }
                  onChanged!(newIds);
                }
              : null,
        );
      }).toList(),
    );
  }
}
