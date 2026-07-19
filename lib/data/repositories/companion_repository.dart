import 'package:rangers_mobile/data/database/app_database.dart';

class CompanionRepository {
  CompanionRepository(this._db);

  final AppDatabase _db;

  // Companion CRUD
  Future<int> insertCompanion(RangerCompanionsCompanion companion) async {
    return await _db.into(_db.rangerCompanions).insert(companion);
  }

  Future<RangerCompanion?> getCompanionById(int id) async {
    final query = _db.select(_db.rangerCompanions)
      ..where((c) => c.id.equals(id));
    return await query.getSingleOrNull();
  }

  Future<List<RangerCompanion>> getCompanionsByRanger(int rangerId, {bool? isActive}) async {
    final query = _db.select(_db.rangerCompanions)
      ..where((c) => c.rangerId.equals(rangerId));
    if (isActive != null) {
      query.where((c) => c.isActive.equals(isActive));
    }
    return await query.get();
  }

  Future<bool> updateCompanion(RangerCompanionsCompanion companion) async {
    final rows = await (_db.update(_db.rangerCompanions)..where((c) => c.id.equals(companion.id.value))).write(companion);
    return rows > 0;
  }

  Future<int> deleteCompanion(int id) async {
    // Delete related injuries first
    await (_db.delete(_db.injuries)..where((i) => i.companionId.equals(id))).go();
    // Delete the companion
    return await (_db.delete(_db.rangerCompanions)..where((c) => c.id.equals(id))).go();
  }

  // Companion Type lookup
  Future<CompanionType?> getCompanionTypeById(int typeId) async {
    final query = _db.select(_db.companionTypes)
      ..where((t) => t.id.equals(typeId));
    return await query.getSingleOrNull();
  }

  Future<List<CompanionType>> getAllCompanionTypes() async {
    return await _db.select(_db.companionTypes).get();
  }
}
