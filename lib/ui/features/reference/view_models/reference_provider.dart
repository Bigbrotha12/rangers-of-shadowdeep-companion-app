import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/data/services/rules_reference_service.dart';

final rulesReferenceServiceProvider = Provider<RulesReferenceService>((ref) {
  return RulesReferenceService();
});

final allReferenceEntriesProvider = Provider<List<ReferenceEntry>>((ref) {
  return ref.watch(rulesReferenceServiceProvider).allEntries;
});

final referenceCategoryEntriesProvider =
    Provider.family<List<ReferenceEntry>, String>((ref, category) {
  return ref.watch(rulesReferenceServiceProvider).getEntriesByCategory(category);
});

final referenceCategoryCountProvider =
    Provider.family<int, String>((ref, category) {
  return ref.watch(rulesReferenceServiceProvider).categoryCount(category);
});

final referenceEntryProvider =
    Provider.family<ReferenceEntry?, ({String category, String id})>(
  (ref, params) {
    return ref
        .watch(rulesReferenceServiceProvider)
        .getEntryById(params.category, params.id);
  },
);

final referenceSearchResultsProvider =
    Provider.family<List<ReferenceEntry>, String>((ref, query) {
  if (query.isEmpty) return [];
  return ref.watch(rulesReferenceServiceProvider).search(query);
});

final referenceCategoriesProvider = Provider<List<ReferenceCategory>>((ref) {
  return referenceCategories;
});

final quickReferenceEntriesProvider =
    Provider<List<QuickReferenceEntry>>((ref) {
  return quickReferenceEntries;
});

final referenceFavoriteIdsProvider =
    StateNotifierProvider<ReferenceFavoritesNotifier, Set<String>>((ref) {
  return ReferenceFavoritesNotifier();
});

class ReferenceFavoritesNotifier extends StateNotifier<Set<String>> {
  ReferenceFavoritesNotifier() : super({});

  void toggle(String entryId) {
    if (state.contains(entryId)) {
      final updated = Set<String>.from(state);
      updated.remove(entryId);
      state = updated;
    } else {
      final updated = Set<String>.from(state);
      updated.add(entryId);
      state = updated;
    }
  }

  bool isFavorite(String entryId) => state.contains(entryId);
}

final favoriteEntriesProvider = Provider<List<ReferenceEntry>>((ref) {
  final favoriteIds = ref.watch(referenceFavoriteIdsProvider);
  if (favoriteIds.isEmpty) return [];
  final allEntries = ref.watch(allReferenceEntriesProvider);
  return allEntries.where((e) => favoriteIds.contains(e.id)).toList();
});
