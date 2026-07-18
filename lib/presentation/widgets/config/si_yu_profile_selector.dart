import 'package:flutter/material.dart';
import 'package:qizhengsiyu/domain/entities/models/si_yu_profile.dart';

/// 四余档案选择器 — 纯展示,档案列表由父组件经 UseCase 供数。
class SiYuProfileSelector extends StatelessWidget {
  final String selectedId;
  final List<SiYuProfile> profiles;
  final ValueChanged<String> onChanged;

  const SiYuProfileSelector({
    super.key,
    required this.selectedId,
    required this.profiles,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
        initialValue: selectedId,
        decoration: const InputDecoration(labelText: '流派档案'),
        items: profiles
            .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      );
}
