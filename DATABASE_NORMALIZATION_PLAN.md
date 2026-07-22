# Database 1NF Normalization Plan

## Schema version: 17 (current)

---

## Phase 1: Status Effects (schema 14)

### Problem
`rangers.status_effects` and `ranger_companions.status_effects` store JSON arrays of effect keys like `["poisoned","exhausted"]` in TEXT columns. Cannot query, no FK integrity, concurrent-modification unsafe. Both share the same domain (same 8 status effect types apply to both rangers and companions).

### Target Schema
Single table with polymorphic FKs (same pattern as `injuries`):
```sql
CREATE TABLE status_effects (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ranger_id INTEGER REFERENCES rangers(id) ON DELETE CASCADE,
  companion_id INTEGER REFERENCES ranger_companions(id) ON DELETE CASCADE,
  status_effect_key TEXT NOT NULL,
  -- Unique enforcement via partial indexes in migration:
  -- CREATE UNIQUE INDEX idx_status_effects_ranger ON status_effects(ranger_id, status_effect_key) WHERE ranger_id IS NOT NULL;
  -- CREATE UNIQUE INDEX idx_status_effects_companion ON status_effects(companion_id, status_effect_key) WHERE companion_id IS NOT NULL;
);
```
App-level enforcement: at least one of `ranger_id` or `companion_id` must be non-null.

### Steps (migration 14)
1. Create `status_effects` table file
2. Migration: `INSERT INTO status_effects (ranger_id, status_effect_key) SELECT r.id, json_each.value FROM rangers r, json_each(r.status_effects)`
3. Migration: `INSERT INTO status_effects (companion_id, status_effect_key) SELECT rc.id, json_each.value FROM ranger_companions rc, json_each(rc.status_effects)`
4. Migration: `ALTER TABLE rangers DROP COLUMN status_effects`
5. Migration: `ALTER TABLE ranger_companions DROP COLUMN status_effects`

### Code changes
| File | What to change |
|------|---------------|
| `tables/rangers.dart` | Remove `statusEffects` column |
| `tables/ranger_companions.dart` | Remove `statusEffects` column |
| `ranger_detail_provider.dart` | Read from `status_effects` table filtered by `ranger_id` |
| `companion_provider.dart` | Read/write from `status_effects` table filtered by `companion_id` |
| `session_provider.dart` | Replace `jsonDecode`/`jsonEncode` with table queries; `applyStatusEffectToMember` inserts row; `removeStatusEffectFromMember` deletes row; `endSession` filters temporary via WHERE |
| `session_setup_view.dart` | Read from table |
| `party_member_card.dart` | Already uses `member.statusEffects` list (unchanged interface) |
| `status_effect_sheet.dart` | Works via session_provider (unchanged) |
| `ranger_injuries_tab.dart` | Read from table |
| `companion_injuries_tab.dart` | Read from table |
| `backup_service.dart` | Export/import the new table |
| `post_game_provider.dart` | No change (status effects are ephemeral per session) |

### Risk
- Same polymorphic pattern as `injuries` — consistent with existing schema design
- Two separate UNIQUE constraints avoid the SQL limitation of nullable-column uniqueness
- Session provider's `applyStatusEffectToMember` already prevents duplicates in-memory; DB uniqueness is a safety net
- Queries filter by `WHERE ranger_id = ?` or `WHERE companion_id = ?` — no extra complexity in practice

---

## Phase 2: Companion customSkills (schema 15)

### Problem
`ranger_companions.custom_skills` stores a JSON object like `{"strength":5,"fight":1}` in TEXT. Most heavily mutated JSON column — progression rewards, recruit bonuses all write to it.

### Target Schema
```sql
CREATE TABLE companion_skills (
  companion_id INTEGER NOT NULL REFERENCES ranger_companions(id) ON DELETE CASCADE,
  skill_key TEXT NOT NULL,
  value INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (companion_id, skill_key)
);
```

### Steps (migration 15)
1. Create `companion_skills` table file
2. Migration: `INSERT INTO companion_skills (companion_id, skill_key, value) SELECT rc.id, json_each.key, json_each.value FROM ranger_companions rc, json_each(rc.custom_skills)`
3. Migration: `ALTER TABLE ranger_companions DROP COLUMN custom_skills`
4. Regenerate drift code

### Code changes
| File | What to change |
|------|---------------|
| `tables/ranger_companions.dart` | Remove `customSkills` column |
| `companion_repository.dart` | Add `getCompanionSkills`, `upsertCompanionSkill`, `setCompanionSkills` (full-replace for save) |
| `companion_provider.dart` | `CompanionData.customSkills` stays as `Map<String,int>` but loaded from/persisted via companion_skills table; `updateCustomSkill` upserts a single row; `_persist` does batch upsert |
| `assign_skill_bonus_view.dart` | Unchanged (calls `updateCustomSkill`) |
| `companion_progression_reward_dialog.dart` | Unchanged (calls `updateCustomSkill`) |
| `companion_progression_view.dart` | Unchanged (calls `updateCustomSkill`) |
| `companion_skills_tab.dart` | Unchanged (reads `CompanionData.customSkills`) |
| `companion_abilities_tab.dart` | Unchanged (reads `CompanionData.customSkills`) |
| `ranger_companions_tab.dart` | Replace `JsonDecoder().convert()` with repository query for raw rows |
| `party_member_card.dart` | Replace `JsonDecoder().convert()` with join query or repository |
| `recruitment_provider.dart` | No explicit init needed (no rows = empty map) |
| `post_game_provider.dart` | Pass-through unchanged (FK cascade handles cleanup) |
| `backup_service.dart` | Export/import the new table, companion ID remapping |

### Fix inconsistency
`CompanionData.effectiveMove` does NOT use `customSkills['move']` but `party_member_card.dart:140` DOES. After normalization, make `effectiveMove` also include customSkills for consistency, OR explicitly document that move is not skill-bonusable.

### Risk
- **ON DELETE CASCADE** ensures companion deletion cleans up skills
- Batch upsert on `_persist` is new but straightforward (delete-all + insert-all in a transaction)
- Progression rewards add +2/+1/+4; recruit bonus adds +3 — all go through `updateCustomSkill`

---

## Phase 3: companion_types baseSkills (schema 16)

### Problem
`companion_types.base_skills` stores JSON like `{"strength":5}` in TEXT. Static seed data, never modified at runtime, but prevents queries like "which types have tracking?".

### Target Schema
```sql
CREATE TABLE companion_type_skills (
  companion_type_id INTEGER NOT NULL REFERENCES companion_types(id),
  skill_key TEXT NOT NULL,
  value INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (companion_type_id, skill_key)
);
```

### Steps (migration 16)
1. Create `companion_type_skills` table
2. Migration: `INSERT INTO companion_type_skills (companion_type_id, skill_key, value) SELECT ct.id, json_each.key, CAST(json_each.value AS INTEGER) FROM companion_types ct, json_each(ct.base_skills)`
3. Migration: `ALTER TABLE companion_types DROP COLUMN base_skills`
4. Update seed data (`_seedCompanionTypes` in `app_database.dart`): insert into `companion_type_skills` instead of writing JSON
5. Update `CompanionTypeDefinition` domain model: keep `baseSkills` as `Map<String,int>` but mark as nullable (loaded via join, or keep populated via eager load)

### Code changes
| File | What to change |
|------|---------------|
| `tables/companion_types.dart` | Remove `baseSkills` column |
| `app_database.dart` | Update `_seedCompanionTypes()` to insert into both tables; add `_seedCompanionTypeSkills()` or inline inserts |
| `companion_types.dart` (domain) | `CompanionTypeDefinition.baseSkills` field stays, but populated differently |
| `companion_types_browser.dart` | Load skills via join or separate query |
| `rules_reference_service.dart` | Read from table instead of JSON string |
| `reference_detail_view.dart` | Unchanged (receives formatted string) |
| `companion_skills_tab.dart` | Unchanged (reads from domain model) |
| `companion_progression_view.dart` | Unchanged |
| `companion_progression_reward_dialog.dart` | Unchanged |
| `assign_skill_bonus_view.dart` | Unchanged |
| `party_member_card.dart` | Join or lazy-load skills |
| `backup_service.dart` | Export/import new table |

### Risk
- Low risk — static data, no runtime writes
- The `CompanionTypeDefinition` constant list (in `lib/domain/constants/companion_types.dart`) already has `baseSkills` as `Map<String,int>` — this is a separate in-memory constant list from the DB seed data. The in-memory list is the primary data source for the UI, and the DB is a secondary read source. Post-migration, both sources should agree.
- Actually, looking deeper: `CompanionTypeDefinition` in `companion_types.dart` is the **primary** data source (UI reads from this, not from DB). The DB `companion_types` table is a secondary persistence. So `baseSkills` extraction is valuable for DB consistency but the in-memory constant remains the primary data source.

---

## Phase 4: claimedProgressionRewards (schema 17)

### Problem
`ranger_companions.claimed_progression_rewards` stores JSON array `["5","10","15"]` in TEXT. Cannot query which companions claimed a given threshold.

### Target Schema
```sql
CREATE TABLE companion_progression_claims (
  companion_id INTEGER NOT NULL REFERENCES ranger_companions(id) ON DELETE CASCADE,
  threshold INTEGER NOT NULL,
  claimed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (companion_id, threshold)
);
```

### Steps (migration 17)
1. Create table file
2. Migration: `INSERT INTO companion_progression_claims (companion_id, threshold, claimed_at) SELECT rc.id, CAST(json_each.value AS INTEGER), datetime('now') FROM ranger_companions rc, json_each(rc.claimed_progression_rewards)`
3. Migration: `ALTER TABLE ranger_companions DROP COLUMN claimed_progression_rewards`

### Code changes
| File | What to change |
|------|---------------|
| `tables/ranger_companions.dart` | Remove `claimedProgressionRewards` column |
| `companion_repository.dart` | Add `getClaimedThresholds`, `markThresholdClaimed`, `getCompanionIdsByThreshold` |
| `companion_provider.dart` | Store `Set<int>` or `List<int>` in `CompanionData`, load from new table; `markProgressionRewardClaimed` inserts a row; `_persist` becomes a no-op for this field |
| `companion_progression_view.dart` | Read from model (unchanged interface) |
| `companion_stats_tab.dart` | Read from model (unchanged) |
| `post_game_provider.dart` | Read from table instead of `_parseClaimedRewards`; use repository method |
| `backup_service.dart` | Export/import new table with companion ID remapping |

### Risk
- The progression rewards domain constant defines 9 fixed thresholds: [5, 10, 15, 20, 25, 30, 35, 40, 50]
- Previously thresholds were stored as strings (e.g. `"5"` not `5`); migration should cast to INTEGER
- `_parseClaimedRewards` in `post_game_provider` handles both int and string elements — defensive, but after migration all values will be integers

---

## Phase 5: equipment effects (schema 18)

### Problem
`equipment.effects` stores arbitrary JSON objects with ~40 possible keys. Largest refactor due to schema-less nature, but only 9 keys are programmatically consumed. The remaining ~30 keys are metadata for the rules reference viewer.

### Target Schema (two tables)
```sql
CREATE TABLE equipment_effect_modifiers (
  equipment_id INTEGER NOT NULL REFERENCES equipment(id),
  stat_key TEXT NOT NULL,
  modifier INTEGER NOT NULL,
  PRIMARY KEY (equipment_id, stat_key)
);
-- stat_key IN ('armour', 'fight', 'shoot', 'will', 'move', 'damage')

CREATE TABLE equipment_effect_metadata (
  equipment_id INTEGER NOT NULL REFERENCES equipment(id),
  metadata_key TEXT NOT NULL,
  metadata_value TEXT NOT NULL,
  PRIMARY KEY (equipment_id, metadata_key)
);
```
All known keys:
- **Stat modifiers** (go to `equipment_effect_modifiers`): `armour_bonus`, `fight_bonus`, `fight_penalty`, `shoot_bonus`, `will_bonus`, `will_penalty`, `move_bonus`, `move_penalty`, `damage_modifier`
- **Metadata** (go to `equipment_effect_metadata`): `range`, `reload`, `requires`, `shots_per_game`, `opponent_damage_modifier`, `magic`, `light`, `brightness`, `blocking`, `elemental_strike`, `herb_slots`, `stealth_bonus`, `rp_bonus`, `teleport_distance`, `cure_disease`, `extra_action`, `temp_health`, `heal`, `cure_poison`, `throw_damage`, `radius`, `re_cast_spell`, `ignore_terrain`, `duration`, `no_fall_damage`, `re_use_ability`, `full_heal`, `cure_temp_stat`, `cure_permanent_injury`, `undead_magic`, `damage_multiplier`, `fight_reroll`, `reroll`, etc.

### Alternative simpler approach
Keep `effects` column as-is but migrate known modifier keys to `equipment_effect_modifiers`. The remaining JSON stays in `effects` for the reference viewer. This avoids migrating 58 items' metadata strings into 58×~3 = ~174 metadata rows that are only used for human browsing.

**Recommended**: Extract only the 9 stat-modifier keys, leave the rest in `effects`.

### Steps (migration 18)
1. Create `equipment_effect_modifiers` table
2. Migration: For each of the 9 stat-mapping keys, generate INSERT per equipment that has that key:
   ```sql
   INSERT INTO equipment_effect_modifiers (equipment_id, stat_key, modifier)
   SELECT e.id, 'armour', CAST(json_extract(e.effects, '$.armour_bonus') AS INTEGER)
   FROM equipment e WHERE json_extract(e.effects, '$.armour_bonus') IS NOT NULL;
   -- Repeat for all 9 mappings
   ```
3. Do NOT drop `effects` column (kept for reference/metadata)

### Code changes
| File | What to change |
|------|---------------|
| `stat_calculation_service.dart` | Replace `jsonDecode` + effectMappings dict with JOIN to `equipment_effect_modifiers` |
| `equipment_utils.dart` | **Delete this file** (it's a duplicate of stat_calculation_service) |
| `stat_calculation_service.dart` | Consolidate all callers to use the single canonical function |
| `companion_stats_tab.dart` | Update import if needed |
| `party_member_card.dart` | Update import if needed |
| `ranger_detail_view.dart` | Use stat_calculation_service version |
| `ranger_companions_tab.dart` | Use stat_calculation_service version |
| `ranger_stats_tab.dart` | Unchanged (receives `Map<String,int>`) |
| `rules_reference_service.dart` | Read from `effects` column (unchanged) or from metadata table |
| `backup_service.dart` | Export/import `equipment_effect_modifiers` |

### Risk
- Medium complexity due to number of callers that currently use `equipment_utils.dart`
- Eliminating the duplicate `computeEquipmentModifiers` in `equipment_utils.dart` is a cleanup win
- The `effects` column stays — no migration to drop it, no need to migrate 30+ metadata keys
- `json_extract` in the migration extracts individual keys without needing to JSON-decode in Dart

---

## Phase 6: Cleanup opportunities (non-JSON)

### 6a. Injuries: polymorphic FK → separate tables
```sql
CREATE TABLE ranger_injuries (
  ranger_id INTEGER NOT NULL REFERENCES rangers(id),
  injury_key TEXT NOT NULL,
  times_received INTEGER NOT NULL DEFAULT 1,
  received_at DATETIME NOT NULL,
  PRIMARY KEY (ranger_id, injury_key)
);

CREATE TABLE companion_injuries (
  companion_id INTEGER NOT NULL REFERENCES ranger_companions(id) ON DELETE CASCADE,
  injury_key TEXT NOT NULL,
  times_received INTEGER NOT NULL DEFAULT 1,
  received_at DATETIME NOT NULL,
  PRIMARY KEY (companion_id, injury_key)
);
```
- Simpler queries, true FK enforcement
- Migration must split existing `injuries` rows between the two new tables
- **Alternative**: Add `owner_type` TEXT discriminator + rename to polymorphic pattern (less invasive)

### 6b. Enum CHECK constraints
Add checks to prevent data corruption:
```sql
ALTER TABLE ranger_equipment ADD CONSTRAINT CHECK (equipped_by IN ('ranger', 'companion', 'pool'));
```
SQLite `ALTER TABLE ADD CONSTRAINT` is not supported. Must recreate tables or enforce in app layer. Given the app-layer enforcement already exists and the schema is drift-managed, this is low priority.

### 6c. Remove `companionTypeKeyFromId()` hardcoded switch
Replace with a repository query against `companion_types` table. Affects `companion_types.dart` domain constant. The function is used in `session_provider.dart` (line 292), plus any place that needs key-by-ID lookup.

---

## Migration sequence summary

| Phase | Schema | Tables added | Columns dropped |
|-------|--------|-------------|----------------|
| 1 | 14 | `ranger_status_effects`, `companion_status_effects` | `rangers.status_effects`, `ranger_companions.status_effects` |
| 2 | 15 | `companion_skills` | `ranger_companions.custom_skills` |
| 3 | 16 | `companion_type_skills` | `companion_types.base_skills` |
| 4 | 17 | `companion_progression_claims` | `ranger_companions.claimed_progression_rewards` |
| 5 | 18 | `equipment_effect_modifiers` | (none — `equipment.effects` kept) |
| 6a | 19 | `ranger_injuries`, `companion_injuries` | `injuries` |
| 6c | 20 | (none) | Remove `companionTypeKeyFromId()` from code |

### Phasing rationale
Phases 1-5 each tackle one JSON column in order of mutability (most-changed first). Each phase is a complete, testable unit. Phase 1-4 follow the exact same pattern as the heroicAbilityKeys/spellKeys fix (migration 13). Phase 5 is unique due to the schema-less nature and the duplicate-code elimination opportunity. Phase 6 is optional cleanup.

### Effort estimate (relative)
- Phase 1: medium (~6 files, session_provider is complex)
- Phase 2: medium (~8 files, companion_provider mutation path)
- Phase 3: small (~4 files, static data)
- Phase 4: small (~4 files, straightforward CRUD)
- Phase 5: medium (~8 files + de-duplication cleanup)
- Phase 6a: medium (~6 files, split injuries)
- Phase 6c: trivial (~2 files)

**Total**: Each phase is independently shippable. Recommend starting with Phase 1.
