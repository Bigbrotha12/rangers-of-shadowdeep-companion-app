# Rangers of Shadow Deep — Companion App Implementation Plan

## Overview

A Flutter Android companion app for the tabletop game *Rangers of Shadow Deep*. The app helps players create/manage rangers and companions, track game sessions in real-time, handle post-game bookkeeping, and look up rules. All data is stored locally with no authentication.

**Tech Stack:**
- Flutter 3.x (Dart)
- Riverpod (state management)
- Drift / SQLite (local database)
- go_router (declarative routing)
- Material Design 3 (light + dark themes)
- Min SDK: API 21 (Android 5.0)

---

## 1. Project Structure

```
lib/
├── main.dart
├── app.dart                          # MaterialApp.router, theme, providers
├── router.dart                       # GoRouter config with StatefulShellRoute
│
├── data/
│   ├── database/
│   │   ├── app_database.dart         # Drift database definition
│   │   ├── app_database.g.dart       # Generated
│   │   ├── tables/
│   │   │   ├── rangers.dart
│   │   │   ├── companions.dart
│   │   │   ├── ranger_companions.dart
│   │   │   ├── equipment.dart
│   │   │   ├── ranger_equipment.dart
│   │   │   ├── ranger_abilities.dart
│   │   │   ├── companion_progression.dart
│   │   │   ├── sessions.dart
│   │   │   ├── session_events.dart
│   │   │   └── injuries.dart
│   │   └── daos/
│   │       ├── ranger_dao.dart
│   │       ├── companion_dao.dart
│   │       ├── session_dao.dart
│   │       └── equipment_dao.dart
│   ├── models/                       # Domain models (freezed)
│   │   ├── ranger.dart
│   │   ├── companion.dart
│   │   ├── equipment.dart
│   │   ├── session.dart
│   │   ├── ability.dart
│   │   ├── spell.dart
│   │   ├── skill.dart
│   │   └── injury.dart
│   ├── services/
│   │   ├── backup_service.dart       # JSON export/import
│   │   ├── dice_service.dart         # d20 roller + manual roll input
│   │   ├── image_service.dart        # Placeholder image path resolution
│   │   └── rules_reference_service.dart
│   └── repositories/
│       ├── ranger_repository.dart
│       ├── companion_repository.dart
│       ├── session_repository.dart
│       └── equipment_repository.dart
│
├── domain/
│   ├── constants/
│   │   ├── base_stats.dart           # Ranger base stat-line
│   │   ├── heroic_abilities.dart     # All 16 abilities with descriptions
│   │   ├── spells.dart               # All 10 spells with descriptions
│   │   ├── skills.dart               # All 15 skills
│   │   ├── companion_types.dart      # 14 companion stat blocks
│   │   ├── basic_equipment.dart      # Basic equipment list
│   │   ├── magic_items.dart          # Magic items table
│   │   ├── herbs_potions.dart        # Herbs and potions
│   │   ├── permanent_injuries.dart   # Permanent injury table
│   │   ├── treasure_table.dart       # Treasure + sub-tables
│   │   ├── experience_table.dart     # XP costs and level bonuses
│   │   └── companion_progression.dart# PP thresholds and rewards
│   └── use_cases/
│       ├── create_ranger_use_case.dart
│       ├── recruit_companions_use_case.dart
│       ├── calculate_recruitment_points_use_case.dart
│       ├── apply_level_bonus_use_case.dart
│       ├── resolve_survival_roll_use_case.dart
│       ├── resolve_treasure_roll_use_case.dart
│       └── apply_permanent_injury_use_case.dart
│
├── ui/
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── color_schemes.dart
│   │   │   └── text_styles.dart
│   │   ├── widgets/
│   │   │   ├── stat_display.dart     # Stat with optional split stat
│   │   │   ├── dice_roller_button.dart
│   │   │   ├── manual_roll_input.dart # Manual dice result entry
│   │   │   ├── placeholder_image.dart # Fallback image widget
│   │   │   ├── confirm_dialog.dart
│   │   │   ├── empty_state.dart
│   │   │   └── search_bar.dart
│   │   └── navigation/
│   │       └── scaffold_with_nav_bar.dart
│   │
│   └── features/
│       └── ... (same as before)
│
├── assets/
│   └── images/
│       ├── rangers/                  # Ranger portraits (placeholder)
│       ├── companions/               # One per companion type
│       ├── items/                    # Item category icons
│       └── ui/                       # App icon, empty states
│
└── l10n/
    ├── app_en.arb
    └── l10n.yaml
```

---

## 2. Database Schema (Drift)

### Tables

#### `rangers`
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | Auto-increment |
| name | TEXT | Ranger name |
| level | INTEGER DEFAULT 0 | Current ranger level |
| experience_points | INTEGER DEFAULT 0 | Total XP |
| base_recruitment_points | INTEGER DEFAULT 100 | BRP |
| move | INTEGER | Move stat |
| fight | INTEGER | Fight stat |
| shoot | INTEGER | Shoot stat |
| armour | INTEGER | Armour stat |
| will | INTEGER | Will stat |
| health | INTEGER | Health stat |
| current_health | INTEGER | Current HP during sessions |
| created_at | DATETIME | |
| updated_at | DATETIME | |
| notes | TEXT | Free-form notes |

#### `ranger_abilities` (abilities + spells purchased)
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| ranger_id | INTEGER FK | → rangers |
| ability_type | TEXT | 'heroic_ability' or 'spell' |
| ability_key | TEXT | Key from constants (e.g. 'dash', 'magic_bolt') |
| is_used_this_scenario | BOOLEAN | Reset per scenario |

#### `ranger_skills` (skill values)
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| ranger_id | INTEGER FK | → rangers |
| skill_key | TEXT | e.g. 'acrobatics', 'track' |
| value | INTEGER | Skill bonus |

#### `companion_types` (reference data, seeded)
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| type_key | TEXT UNIQUE | e.g. 'arcanist', 'barbarian' |
| name | TEXT | Display name |
| rp_cost | INTEGER | Recruitment point cost |
| move | INTEGER | |
| fight | INTEGER | |
| shoot | INTEGER | |
| armour | INTEGER | |
| will | INTEGER | |
| health | INTEGER | |
| notes | TEXT | Base notes/equipment |
| is_animal | BOOLEAN | Hound/Raptor |
| base_skills | TEXT | JSON map of initial skills |

#### `ranger_companions` (companions assigned to a ranger)
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| ranger_id | INTEGER FK | → rangers |
| companion_type_id | INTEGER FK | → companion_types |
| custom_name | TEXT | Player-given name |
| progression_points | INTEGER DEFAULT 0 | |
| is_alive | BOOLEAN DEFAULT TRUE | |
| permanent_injuries | TEXT | JSON list of injury keys |
| custom_skills | TEXT | JSON map of skill overrides |
| is_active | BOOLEAN DEFAULT TRUE | Currently in ranger's company |
| created_at | DATETIME | |

#### `equipment` (reference data, seeded)
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| item_key | TEXT UNIQUE | |
| name | TEXT | |
| category | TEXT | 'basic_weapon', 'basic_armour', 'basic_gear', 'magic_weapon', 'magic_armour', 'magic_item', 'herb_potion' |
| description | TEXT | Full description |
| effects | TEXT | JSON of mechanical effects |
| has_uses | BOOLEAN | |
| max_uses | INTEGER | Nullable |

#### `ranger_equipment`
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| ranger_id | INTEGER FK | → rangers |
| equipment_id | INTEGER FK | → equipment |
| current_uses | INTEGER | Remaining uses (null if unlimited) |
| equipped_by | TEXT | 'ranger' or companion_id |

#### `injuries` (permanent injuries tracking)
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| ranger_id | INTEGER FK | → rangers (nullable) |
| companion_id | INTEGER FK | → ranger_companions (nullable) |
| injury_key | TEXT | Key from permanent_injuries constant |
| times_received | INTEGER DEFAULT 1 | For cumulative injuries |
| received_at | DATETIME | |

#### `sessions` (game session records)
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| ranger_id | INTEGER FK | → rangers |
| scenario_name | TEXT | |
| mission_name | TEXT | |
| date_played | DATETIME | |
| turns_played | INTEGER | |
| outcome | TEXT | 'victory', 'defeat', 'partial' |
| notes | TEXT | |
| experience_earned | INTEGER | XP earned this session |
| is_completed | BOOLEAN | |

#### `session_events` (event log during play)
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| session_id | INTEGER FK | → sessions |
| turn_number | INTEGER | |
| phase | TEXT | 'ranger', 'creature', 'companion', 'event' |
| event_type | TEXT | 'damage', 'heal', 'ability_used', 'spell_cast', 'skill_roll', 'death', 'note' |
| description | TEXT | |
| figure_name | TEXT | Who it happened to |
| created_at | DATETIME | |

---

## 3. Domain Constants

All game data from the rulebook will be encoded as Dart constants (not database records, since they never change):

- `heroic_abilities.dart` — 16 abilities, each with: key, name, description, when_it_can_be_used
- `spells.dart` — 10 spells, each with: key, name, description, target, will_roll_tn (if any)
- `skills.dart` — 15 skills, each with: key, name, description
- `companion_types.dart` — 14 companions, each with: full stat line, base skills, notes
- `basic_equipment.dart` — ~12 basic items with rules text
- `magic_items.dart` — 20 magic items with uses and effects
- `herbs_potions.dart` — 20 herbs/potions with effects
- `permanent_injuries.dart` — 8 injuries with stat penalties and cumulative rules
- `treasure_table.dart` — Main table + sub-tables (herbs, weapons/armor, magic items)
- `experience_table.dart` — Level costs + level bonus table
- `companion_progression.dart` — PP thresholds and rewards

---

## 4. Feature Breakdown

### 4.1 Ranger Creation Wizard

A multi-step wizard for creating a new ranger:

**Step 1 — Name & Concept**
- Text field for ranger name
- Optional: concept/theme notes

**Step 2 — Build Points Allocation (10 BP)**
- Display remaining BP
- Stat increases (up to 3 BP, +1 to any stat except Armour, once per stat)
- Heroic Abilities (1 BP each, up to 5 BP)
- Spells (1 BP each, up to 5 BP)
- Skills (1 BP = +1 to 8 skills, up to 5 BP)
- Recruitment Points (+10 RP per BP, up to 3 BP)

Live BP counter that validates spending.

**Step 3 — Starting Equipment**
- Select up to 5 items from Basic Equipment List
- Equipment slots display (6 max)

**Step 4 — Review & Save**
- Full stat summary
- Confirm creation

### 4.2 Ranger Management

- **Rangers List (Home Screen)** — The first screen users see. Cards showing name, level, XP, and party size. Prominent "Create New Ranger" button. Tapping a ranger sets it as the active ranger for session and management views.
- **Ranger Detail** — Tabbed view:
  - Stats tab: Full stat line with split stats support
  - Abilities tab: Purchased heroic abilities + spells
  - Skills tab: All 15 skills with current values
  - Equipment tab: Carried items with slot count
  - Companions tab: Current company
  - Campaign tab: Permanent injuries, notes
- **Edit Ranger** — Modify stats, add/remove abilities, adjust skills
- **Manual Overrides** — The app auto-calculates stats from equipment, abilities, injuries, and level bonuses, but always allows the user to manually override any value. This includes:
  - Direct stat adjustments (e.g. manually correcting a stat after a mistake)
  - Adding/removing equipment items outside the normal flow
  - Adjusting XP, level, or RP totals manually
  - Adding/removing heroic abilities or spells manually
  - Each manual override shows an "override" indicator and can be reverted
- **Delete Ranger** — Confirmation dialog

### 4.3 Companion Management

- **Companion Types Reference** — Browse all 14 companion types with stats and RP cost
- **Recruit Companions** — For a selected ranger:
  - Show available RP (base + level bonuses + magic item bonuses + leadership skill)
  - Recruit/remove companions from the company
  - Assign +3 skill bonus on first recruitment
  - Enforce maximum companion limits per player count
- **Companion Detail** — Stats, skills, injuries, progression, equipment
- **Companion Progression** — Auto-tracked PP:
  - Display current PP and next threshold
  - Auto-apply rewards when thresholds are reached
  - Reward selection when multiple options exist (e.g. +1 Fight or +1 Shoot)

### 4.4 Game Session Tracker

**Session Setup:**
- Select ranger and active companions
- Set player count (affects RP calculation, already done during recruitment)
- Enter scenario/mission name
- Pre-populate starting HP for all figures

**Active Session View:**
- **Turn Tracker** — Current turn number, phase indicator (Ranger → Creature → Companion → Event)
- **Party Panel** — For each hero:
  - Current/max HP with +/- buttons
  - Status indicators (poisoned, diseased, hungry/thirsty)
  - Active abilities/spells with used/unused toggles
  - Quick d20 roller with skill modifiers
- **Creature Panel** — Simple HP tracking for enemy creatures (user-entered names)
- **Event Log** — Timestamped log of in-game events (damage, heals, ability uses, notes)
- **Dice Roller** — Floating action button or bottom sheet:
  - d20 roll with optional modifier input (+skill, +spell bonus, etc.)
  - **Manual roll input** — User can type in a dice result directly (for physical dice users) with an optional modifier, so both digital and physical dice players are accommodated
  - Roll history for current session (showing which were app-rolled vs manually entered)
  - Auto-log results to event log

**Session Pause/Resume:**
- Sessions can be paused and resumed later
- All state is persisted

**Session End:**
- Mark session as complete
- Navigate to post-game bookkeeping

### 4.5 Post-Game Bookkeeping

A guided workflow after each session, in order:

**Step 1 — Injury & Death Check**
- List all heroes reduced to 0 HP during the session
- For each: roll on Survival Table (or let user roll d20)
- Handle outcomes:
  - **Dead**: Remove ranger (game over) or companion (items lost)
  - **Permanent Injury**: Select injury from table, apply stat penalty, record
  - **Badly Wounded**: Apply -5 Health for next scenario
  - **Close Call**: Remove non-standard equipment
  - **Full Recovery**: No action needed

**Step 2 — Experience & Level Up**
- Display XP earned (from scenario rewards + treasure gold)
- Show current XP total and level
- Calculate if level-up is possible
- If leveling up:
  - Show new level bonus type (Skills / Stats / RP / New Ability)
  - Provide appropriate selection UI
  - Apply changes to ranger

**Step 3 — Treasure Rolls**
- Count secured treasure tokens
- For each: roll on Treasure Table (or let user roll d20)
- Handle sub-tables:
  - Gold & Jewels → +10 XP or +1 PP to a companion
  - Herbs/Potions → Roll on sub-table, add to equipment
  - Weapons/Armour → Roll on sub-table, add to equipment with uses
  - Magic Items → Roll on sub-table, add to equipment with uses

**Step 4 — Reorganize Companions**
- Show updated RP total
- Recruit/remove companions
- Companions kept retain their PP; released companions go to reserve

### 4.6 Rules Reference

A searchable, categorized reference section:

- **Categories**: Spells, Heroic Abilities, Skills, Companions, Basic Equipment, Magic Items, Herbs & Potions, Permanent Injuries, Treasure Tables
- **Search**: Full-text search across all reference entries
- **Favorites**: Pin frequently referenced entries
- **Cross-linking**: Clicking "Heal" spell in a ranger's ability list navigates to its reference entry
- **Quick Reference Cards**: Summarized cards for:
  - Combat modifiers
  - Shooting modifiers
  - Swimming modifiers
  - Movement rules (climbing, jumping, falling)
  - Evil creature AI flowchart

### 4.7 Data Backup & Import

- **Export**: Serialize all rangers, companions, equipment, sessions, and event logs to a single JSON file
- **Import**: Read JSON file, validate schema, merge or replace data
- **File location**: Android Downloads directory or user-selected location
- **UI**: Settings screen with Export/Import buttons + file picker

### 4.8 Placeholder Images

The app will include placeholder portrait images to enhance the visual experience. These will be replaced with final artwork later.

**Asset Structure:**
```
assets/
├── images/
│   ├── rangers/           # Ranger portraits (placeholder)
│   │   └── default_ranger.png
│   ├── companions/        # Companion type portraits (one per type)
│   │   ├── arcanist.png
│   │   ├── archer.png
│   │   ├── barbarian.png
│   │   ├── conjuror.png
│   │   ├── guardsman.png
│   │   ├── hound.png
│   │   ├── warhound.png
│   │   ├── bloodhound.png
│   │   ├── knight.png
│   │   ├── man_at_arms.png
│   │   ├── raptor.png
│   │   ├── recruit.png
│   │   ├── rogue.png
│   │   ├── savage.png
│   │   ├── swordsman.png
│   │   ├── templar.png
│   │   └── tracker.png
│   ├── items/             # Item category icons
│   │   ├── weapon.png
│   │   ├── armour.png
│   │   ├── magic_item.png
│   │   ├── herb_potion.png
│   │   └── gear.png
│   └── ui/                # UI elements
│       ├── app_icon.png
│       └── empty_state.png
```

**Usage:**
- Ranger cards and detail views show a portrait (default_ranger.png unless user assigns one)
- Companion detail and recruitment views show the companion type portrait
- Equipment items show category icons
- Reference entries for items show relevant icons
- Images are stored in `assets/` and referenced via `pubspec.yaml`
- A `PlaceholderImage` widget handles fallback gracefully when an image is missing

### 4.9 Settings

- Theme toggle (light/dark)
- Default player count preference
- Clear all data (with confirmation)
- About/version info
- Export/Import buttons

---

## 5. Navigation Architecture

Using `StatefulShellRoute.indexedStack` with `go_router`:

```
/ (ScaffoldWithNavBar)
├── /rangers (tab 0)
│   ├── /rangers (list)
│   ├── /rangers/create (wizard)
│   ├── /rangers/:id (detail)
│   ├── /rangers/:id/edit
│   ├── /rangers/:id/equipment
│   └── /rangers/:id/companions
│       └── /rangers/:id/companions/recruit
│
├── /session (tab 1)
│   ├── /session (list/history)
│   ├── /session/setup/:rangerId
│   ├── /session/active/:sessionId
│   └── /session/summary/:sessionId
│
├── /reference (tab 2)
│   ├── /reference (home/categories)
│   ├── /reference/search
│   ├── /reference/spells/:key
│   ├── /reference/abilities/:key
│   ├── /reference/companions/:key
│   └── /reference/items/:key
│
└── /settings (tab 3)
```

---

## 6. Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  # State Management
  flutter_riverpod: ^2.x
  riverpod_annotation: ^2.x
  
  # Database
  drift: ^2.x
  sqlite3_flutter_libs: ^0.5.x
  path_provider: ^2.x
  path: ^1.x
  
  # Routing
  go_router: ^14.x
  
  # Serialization
  freezed_annotation: ^2.x
  json_annotation: ^4.x
  
  # UI
  google_fonts: ^6.x
  flutter_slidable: ^3.x   # Swipe-to-delete on lists
  
  # Utilities
  uuid: ^4.x
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.x
  build_runner: ^2.x
  drift_dev: ^2.x
  freezed: ^2.x
  json_serializable: ^6.x
  riverpod_generator: ^2.x
```

---

## 7. Implementation Phases

### Phase 1 — Foundation (Weeks 1–2)
- [ ] Scaffold Flutter project (`flutter create`)
- [ ] Set up dependencies (Riverpod, Drift, go_router, freezed)
- [ ] Implement Drift database with all tables
- [ ] Seed reference data (companion types, equipment, abilities, spells, skills)
- [ ] Create domain models with freezed
- [ ] Set up routing shell with bottom navigation
- [ ] Implement light/dark theme
- [ ] Add placeholder image assets (ranger, companion, item portraits)
- [ ] Create `PlaceholderImage` widget for fallback rendering

### Phase 2 — Ranger Management (Weeks 3–4)
- [ ] Ranger creation wizard (all 4 steps)
- [ ] Rangers list view
- [ ] Ranger detail view (tabbed)
- [ ] Ranger editing
- [ ] Equipment management (assign/remove items)
- [ ] Ranger deletion

### Phase 3 — Companion Management (Weeks 5–6)
- [ ] Companion types reference browser
- [ ] Recruit companions view (RP calculator, limits enforcement)
- [ ] Companion detail view
- [ ] Assign +3 skill bonus on first recruitment
- [ ] Companion progression tracking (auto-PP, threshold notifications)

### Phase 4 — Game Session (Weeks 7–9)
- [ ] Session setup view
- [ ] Active session view (turn tracker, phase indicator)
- [ ] Party panel (HP tracking, status effects, ability toggles)
- [ ] Creature HP tracker
- [ ] Dice roller (d20 + modifier)
- [ ] Event logging
- [ ] Session pause/resume
- [ ] Session list/history

### Phase 5 — Post-Game Bookkeeping (Weeks 10–11)
- [ ] Injury & death check workflow
- [ ] Survival table roller with outcome handling
- [ ] Permanent injury application (split stats)
- [ ] Experience & level-up system
- [ ] Level bonus application (4 types)
- [ ] Treasure rolling (main table + sub-tables)
- [ ] Reorganize companions

### Phase 6 — Reference & Polish (Weeks 12–13)
- [ ] Searchable rules reference (all categories)
- [ ] Quick reference cards
- [ ] Cross-linking between features and reference
- [ ] Data backup/export (JSON)
- [ ] Data import
- [ ] Settings screen
- [ ] Edge cases and error handling

### Phase 7 — Testing & Release (Week 14)
- [ ] Unit tests for use cases and repositories
- [ ] Widget tests for key views
- [ ] Integration tests for critical flows
- [ ] Performance testing
- [ ] Build APK for release

---

## 8. Key Design Decisions & Notes

### Split Stats
Stats can have two values (e.g. `+3/+2` for a Crushed Arm injury). The domain model should store both `baseStat` and `effectiveStat`. The UI displays the split notation. All rolls use the effective stat.

### Ability/Spell Usage Tracking
Heroic abilities and spells are once-per-scenario. The `ranger_abilities` table tracks `is_used_this_scenario`, reset at session start.

### Companion Progression Automation
When PP reaches a threshold (5, 10, 15, 20, 25, 30, 35, 40, 50), the app should:
1. Notify the user
2. Present the reward choice (if applicable)
3. Apply the reward to the companion
4. Mark the threshold as claimed

### Permanent Injury Cumulative Rules
Some injuries can be received twice (Lost Toes, Smashed Leg, Crushed Arm, Lost Fingers, Never Quite as Strong, Psychological Scars). The app must track `times_received` and enforce the maximum.

### Treasure Rolling
Each treasure result cascades into sub-tables. The app should automate this chain:
1. Roll d20 on Treasure Table → get category
2. Roll d20 on category sub-table → get specific item
3. If item has uses, track remaining uses

### Evil Creature AI Flowchart
The reference section should include an interactive version of the creature action flowchart (Steps 1–3) for quick lookup during the creature phase.

### Data Integrity
When a ranger is deleted, all associated companions, equipment, sessions, and injuries should be cascaded deleted. When a companion is removed from a ranger's company, their PP and injuries should be preserved in the database (for potential future re-recruitment from reserve).

### Dice Roller: Digital + Physical
The dice roller supports two modes:
1. **App-rolled** — Tap to roll d20, optionally pre-set a modifier. Result is displayed and logged.
2. **Manual input** — User types in the die result they rolled physically, optionally adds a modifier. The entry is marked as "manual" in the event log for transparency.

Both modes produce the same output (final modified result) and are logged identically. The distinction is visual only (icon/badge in the event log).

### Placeholder Images
All images are local assets stored in `assets/images/`. The `PlaceholderImage` widget:
- Accepts an asset path and a fallback category icon
- Displays the asset if it exists, otherwise renders a themed icon placeholder
- Used consistently across ranger cards, companion detail views, equipment lists, and reference entries
- Designed to be easily swapped out when final artwork is provided
