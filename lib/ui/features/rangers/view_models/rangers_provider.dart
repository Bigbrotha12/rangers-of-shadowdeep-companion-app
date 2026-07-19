import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository_provider.dart';

final rangersListProvider = FutureProvider<List<Ranger>>((ref) async {
  final repo = ref.watch(rangerRepositoryProvider);
  return repo.getRangers();
});
