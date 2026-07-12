import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/ranger_repository_provider.dart';

final rangersListProvider = FutureProvider<List<Ranger>>((ref) async {
  final repo = ref.watch(rangerRepositoryProvider);
  return repo.getRangers();
});
