import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/ranger_creation_provider.dart';

class RangerCreationStep1Name extends ConsumerStatefulWidget {
  const RangerCreationStep1Name({super.key});

  @override
  ConsumerState<RangerCreationStep1Name> createState() =>
      _RangerCreationStep1NameState();
}

class _RangerCreationStep1NameState
    extends ConsumerState<RangerCreationStep1Name> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final state = ref.read(rangerCreationProvider);
    _nameController.text = state.name;
    _notesController.text = state.notes;
    _nameFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.person_add,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Name Your Ranger',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Give your ranger a name that reflects their personality and background.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            decoration: const InputDecoration(
              labelText: 'Ranger Name *',
              hintText: 'e.g., Aragorn, Shadow Walker, etc.',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (value) {
              ref.read(rangerCreationProvider.notifier).updateName(value);
            },
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Concept / Notes (optional)',
              hintText: 'e.g., A stealthy scout who prefers ranged combat...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (value) {
              ref.read(rangerCreationProvider.notifier).updateNotes(value);
            },
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You will have 10 Build Points to spend on stats, abilities, skills, and recruitment points in the next step.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
