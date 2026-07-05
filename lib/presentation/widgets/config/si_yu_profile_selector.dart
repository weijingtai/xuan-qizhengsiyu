import 'package:flutter/material.dart';
import 'package:qizhengsiyu/domain/engines/siyu/profile/built_in_profiles.dart';

class SiYuProfileSelector extends StatelessWidget {
  final String selectedId;
  final ValueChanged<String> onChanged;
  const SiYuProfileSelector({super.key, required this.selectedId, required this.onChanged});
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
        initialValue: selectedId,
        decoration: const InputDecoration(labelText: '流派档案'),
        items: BuiltInSiYuProfiles.all
            .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
            .toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      );
}
