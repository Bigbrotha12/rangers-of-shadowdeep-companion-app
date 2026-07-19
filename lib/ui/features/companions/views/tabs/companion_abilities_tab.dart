import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rangers_mobile/domain/constants/companion_types.dart';
import 'package:rangers_mobile/domain/constants/heroic_abilities.dart';
import 'package:rangers_mobile/domain/constants/spells.dart';
import 'package:rangers_mobile/domain/constants/skills.dart';
import 'package:rangers_mobile/ui/features/companions/view_models/companion_provider.dart';

class CompanionAbilitiesTab extends ConsumerWidget {
  const CompanionAbilitiesTab({
    required this.companion,
    required this.type,
    required this.rangerId,
    super.key,
  });

  final CompanionData companion;
  final CompanionTypeDefinition type;
  final int rangerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isConjuror = type.key == 'conjuror';
    final maxSpells = isConjuror ? 3 : null;

    final hasHeroic = companion.heroicAbilityKeys.isNotEmpty;
    final hasSpells = isConjuror;
    final hasSkillBonuses = companion.customSkills.isNotEmpty;

    if (!hasHeroic && !hasSpells && !hasSkillBonuses) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No abilities',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Earn abilities through progression rewards.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasHeroic) ...[
            Text(
              'Heroic Abilities',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...companion.heroicAbilityKeys.map((key) {
              final data = heroicAbilities.firstWhere(
                (a) => a.key == key,
                orElse: () => heroicAbilities.first,
              );
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  leading: Icon(Icons.star, color: theme.colorScheme.primary),
                  title: Text(data.name),
                  subtitle: Text(
                    data.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () => context.push(
                    '/reference/heroic_abilities/$key',
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          if (isConjuror) ...[
            Text(
              'Spells',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (companion.spellKeys.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'No spells selected.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ...companion.spellKeys.map((key) {
                final data = spells.firstWhere(
                  (s) => s.key == key,
                  orElse: () => spells.first,
                );
                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    leading: Icon(Icons.auto_awesome, color: theme.colorScheme.tertiary),
                    title: Text(data.name),
                    subtitle: Text(
                      data.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.open_in_new, size: 18),
                          onPressed: () => context.push(
                            '/reference/spells/$key',
                          ),
                          tooltip: 'View details',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.remove_circle_outline,
                            size: 20,
                            color: theme.colorScheme.error,
                          ),
                          onPressed: () {
                            ref.read(companionProvider(companion.id).notifier)
                                .removeSpellKey(key);
                          },
                          tooltip: 'Remove spell',
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 8),
            if (companion.spellKeys.length < maxSpells!)
              OutlinedButton.icon(
                onPressed: () => _showSpellPicker(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  'Select Spell (${companion.spellKeys.length}/$maxSpells)',
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Conjuror can select up to $maxSpells spell${maxSpells == 1 ? '' : 's'}.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (hasSkillBonuses) ...[
            Text(
              'Skill Bonuses',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: companion.customSkills.entries.map((entry) {
                final skill = skills.firstWhere(
                  (s) => s.key == entry.key,
                  orElse: () => skills.first,
                );
                return ActionChip(
                  avatar: const Icon(Icons.school, size: 14),
                  label: Text(
                    '${skill.name} +${entry.value}',
                    style: theme.textTheme.labelSmall,
                  ),
                  onPressed: () => context.push(
                    '/reference/skills/${entry.key}',
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _showSpellPicker(BuildContext context, WidgetRef ref) {
    final existing = [...companion.spellKeys];
    final selected = Set<String>.from(existing);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Select Spells (max 3)'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: spells.length,
              itemBuilder: (ctx, i) {
                final spell = spells[i];
                final isSelected = selected.contains(spell.key);
                final atMax = selected.length >= 3 && !isSelected;

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: atMax
                      ? null
                      : (checked) {
                          setState(() {
                            if (checked == true) {
                              selected.add(spell.key);
                            } else {
                              selected.remove(spell.key);
                            }
                          });
                        },
                  title: Text(spell.name),
                  subtitle: Text(
                    spell.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                ref.read(companionProvider(companion.id).notifier)
                    .setSpellKeys(selected.toList());
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
