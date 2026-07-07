import 'package:flutter/material.dart';
import 'package:qizhengsiyu/enums/enum_school.dart';
import 'package:qizhengsiyu/domain/engines/school/school_profile.dart';

/// 典籍下拉 + 「已自定义」徽标 + 「存为自定义流派」按钮。
/// 配置页流派选择器下方的一段附加 UI。
class SchoolProfileBar extends StatelessWidget {
  final EnumSchoolType? selectedSchool;
  final List<SchoolProfile> books;
  final bool isCustomized;
  final String? selectedProfileId;
  final ValueChanged<String> onBookSelected;
  final VoidCallback onSaveProfile;

  const SchoolProfileBar({
    super.key,
    required this.selectedSchool,
    required this.books,
    required this.isCustomized,
    this.selectedProfileId,
    required this.onBookSelected,
    required this.onSaveProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (books.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: Text(
              '典籍',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
          DropdownButtonFormField<String>(
            value: selectedProfileId,
            decoration: const InputDecoration(
              labelText: '选择典籍',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: books
                .map((p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.classicBook),
                    ))
                .toList(),
            onChanged: (id) {
              if (id != null) onBookSelected(id);
            },
          ),
          const SizedBox(height: 8),
        ],
        if (isCustomized)
          const Chip(
            label: Text('已自定义'),
            backgroundColor: Colors.orangeAccent,
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('存为自定义流派'),
          onPressed: onSaveProfile,
        ),
      ],
    );
  }
}
