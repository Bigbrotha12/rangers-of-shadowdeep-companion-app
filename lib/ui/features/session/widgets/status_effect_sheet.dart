import 'package:flutter/material.dart';
import 'package:rangers_mobile/domain/constants/status_effects.dart';

class StatusEffectSheet extends StatefulWidget {
  final List<String> activeEffects;

  const StatusEffectSheet({required this.activeEffects, super.key});

  @override
  State<StatusEffectSheet> createState() => _StatusEffectSheetState();
}

class _StatusEffectSheetState extends State<StatusEffectSheet> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.activeEffects);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manage Status Effects',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...statusEffects.map((effect) => CheckboxListTile(
              title: Text(effect.name),
              subtitle: Text(effect.description, style: theme.textTheme.bodySmall),
              value: _selected.contains(effect.key),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selected.add(effect.key);
                  } else {
                    _selected.remove(effect.key);
                  }
                });
              },
              secondary: Icon(
                effect.category == StatusEffectCategory.positive
                    ? Icons.arrow_upward : Icons.arrow_downward,
                color: effect.category == StatusEffectCategory.positive
                    ? Colors.green : theme.colorScheme.error,
              ),
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, _selected),
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
