// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RangersTable extends Rangers with TableInfo<$RangersTable, Ranger> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RangersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _experiencePointsMeta = const VerificationMeta(
    'experiencePoints',
  );
  @override
  late final GeneratedColumn<int> experiencePoints = GeneratedColumn<int>(
    'experience_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _baseRecruitmentPointsMeta =
      const VerificationMeta('baseRecruitmentPoints');
  @override
  late final GeneratedColumn<int> baseRecruitmentPoints = GeneratedColumn<int>(
    'base_recruitment_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _moveMeta = const VerificationMeta('move');
  @override
  late final GeneratedColumn<int> move = GeneratedColumn<int>(
    'move',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fightMeta = const VerificationMeta('fight');
  @override
  late final GeneratedColumn<int> fight = GeneratedColumn<int>(
    'fight',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shootMeta = const VerificationMeta('shoot');
  @override
  late final GeneratedColumn<int> shoot = GeneratedColumn<int>(
    'shoot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _armourMeta = const VerificationMeta('armour');
  @override
  late final GeneratedColumn<int> armour = GeneratedColumn<int>(
    'armour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _willMeta = const VerificationMeta('will');
  @override
  late final GeneratedColumn<int> will = GeneratedColumn<int>(
    'will',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _healthMeta = const VerificationMeta('health');
  @override
  late final GeneratedColumn<int> health = GeneratedColumn<int>(
    'health',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentHealthMeta = const VerificationMeta(
    'currentHealth',
  );
  @override
  late final GeneratedColumn<int> currentHealth = GeneratedColumn<int>(
    'current_health',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    level,
    experiencePoints,
    baseRecruitmentPoints,
    move,
    fight,
    shoot,
    armour,
    will,
    health,
    currentHealth,
    createdAt,
    updatedAt,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rangers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ranger> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('experience_points')) {
      context.handle(
        _experiencePointsMeta,
        experiencePoints.isAcceptableOrUnknown(
          data['experience_points']!,
          _experiencePointsMeta,
        ),
      );
    }
    if (data.containsKey('base_recruitment_points')) {
      context.handle(
        _baseRecruitmentPointsMeta,
        baseRecruitmentPoints.isAcceptableOrUnknown(
          data['base_recruitment_points']!,
          _baseRecruitmentPointsMeta,
        ),
      );
    }
    if (data.containsKey('move')) {
      context.handle(
        _moveMeta,
        move.isAcceptableOrUnknown(data['move']!, _moveMeta),
      );
    } else if (isInserting) {
      context.missing(_moveMeta);
    }
    if (data.containsKey('fight')) {
      context.handle(
        _fightMeta,
        fight.isAcceptableOrUnknown(data['fight']!, _fightMeta),
      );
    } else if (isInserting) {
      context.missing(_fightMeta);
    }
    if (data.containsKey('shoot')) {
      context.handle(
        _shootMeta,
        shoot.isAcceptableOrUnknown(data['shoot']!, _shootMeta),
      );
    } else if (isInserting) {
      context.missing(_shootMeta);
    }
    if (data.containsKey('armour')) {
      context.handle(
        _armourMeta,
        armour.isAcceptableOrUnknown(data['armour']!, _armourMeta),
      );
    } else if (isInserting) {
      context.missing(_armourMeta);
    }
    if (data.containsKey('will')) {
      context.handle(
        _willMeta,
        will.isAcceptableOrUnknown(data['will']!, _willMeta),
      );
    } else if (isInserting) {
      context.missing(_willMeta);
    }
    if (data.containsKey('health')) {
      context.handle(
        _healthMeta,
        health.isAcceptableOrUnknown(data['health']!, _healthMeta),
      );
    } else if (isInserting) {
      context.missing(_healthMeta);
    }
    if (data.containsKey('current_health')) {
      context.handle(
        _currentHealthMeta,
        currentHealth.isAcceptableOrUnknown(
          data['current_health']!,
          _currentHealthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentHealthMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ranger map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ranger(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      experiencePoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}experience_points'],
      )!,
      baseRecruitmentPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_recruitment_points'],
      )!,
      move: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}move'],
      )!,
      fight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fight'],
      )!,
      shoot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shoot'],
      )!,
      armour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}armour'],
      )!,
      will: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}will'],
      )!,
      health: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}health'],
      )!,
      currentHealth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_health'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $RangersTable createAlias(String alias) {
    return $RangersTable(attachedDatabase, alias);
  }
}

class Ranger extends DataClass implements Insertable<Ranger> {
  final int id;
  final String name;
  final int level;
  final int experiencePoints;
  final int baseRecruitmentPoints;
  final int move;
  final int fight;
  final int shoot;
  final int armour;
  final int will;
  final int health;
  final int currentHealth;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String notes;
  const Ranger({
    required this.id,
    required this.name,
    required this.level,
    required this.experiencePoints,
    required this.baseRecruitmentPoints,
    required this.move,
    required this.fight,
    required this.shoot,
    required this.armour,
    required this.will,
    required this.health,
    required this.currentHealth,
    required this.createdAt,
    required this.updatedAt,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['level'] = Variable<int>(level);
    map['experience_points'] = Variable<int>(experiencePoints);
    map['base_recruitment_points'] = Variable<int>(baseRecruitmentPoints);
    map['move'] = Variable<int>(move);
    map['fight'] = Variable<int>(fight);
    map['shoot'] = Variable<int>(shoot);
    map['armour'] = Variable<int>(armour);
    map['will'] = Variable<int>(will);
    map['health'] = Variable<int>(health);
    map['current_health'] = Variable<int>(currentHealth);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  RangersCompanion toCompanion(bool nullToAbsent) {
    return RangersCompanion(
      id: Value(id),
      name: Value(name),
      level: Value(level),
      experiencePoints: Value(experiencePoints),
      baseRecruitmentPoints: Value(baseRecruitmentPoints),
      move: Value(move),
      fight: Value(fight),
      shoot: Value(shoot),
      armour: Value(armour),
      will: Value(will),
      health: Value(health),
      currentHealth: Value(currentHealth),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      notes: Value(notes),
    );
  }

  factory Ranger.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ranger(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      level: serializer.fromJson<int>(json['level']),
      experiencePoints: serializer.fromJson<int>(json['experiencePoints']),
      baseRecruitmentPoints: serializer.fromJson<int>(
        json['baseRecruitmentPoints'],
      ),
      move: serializer.fromJson<int>(json['move']),
      fight: serializer.fromJson<int>(json['fight']),
      shoot: serializer.fromJson<int>(json['shoot']),
      armour: serializer.fromJson<int>(json['armour']),
      will: serializer.fromJson<int>(json['will']),
      health: serializer.fromJson<int>(json['health']),
      currentHealth: serializer.fromJson<int>(json['currentHealth']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'level': serializer.toJson<int>(level),
      'experiencePoints': serializer.toJson<int>(experiencePoints),
      'baseRecruitmentPoints': serializer.toJson<int>(baseRecruitmentPoints),
      'move': serializer.toJson<int>(move),
      'fight': serializer.toJson<int>(fight),
      'shoot': serializer.toJson<int>(shoot),
      'armour': serializer.toJson<int>(armour),
      'will': serializer.toJson<int>(will),
      'health': serializer.toJson<int>(health),
      'currentHealth': serializer.toJson<int>(currentHealth),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'notes': serializer.toJson<String>(notes),
    };
  }

  Ranger copyWith({
    int? id,
    String? name,
    int? level,
    int? experiencePoints,
    int? baseRecruitmentPoints,
    int? move,
    int? fight,
    int? shoot,
    int? armour,
    int? will,
    int? health,
    int? currentHealth,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) => Ranger(
    id: id ?? this.id,
    name: name ?? this.name,
    level: level ?? this.level,
    experiencePoints: experiencePoints ?? this.experiencePoints,
    baseRecruitmentPoints: baseRecruitmentPoints ?? this.baseRecruitmentPoints,
    move: move ?? this.move,
    fight: fight ?? this.fight,
    shoot: shoot ?? this.shoot,
    armour: armour ?? this.armour,
    will: will ?? this.will,
    health: health ?? this.health,
    currentHealth: currentHealth ?? this.currentHealth,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    notes: notes ?? this.notes,
  );
  Ranger copyWithCompanion(RangersCompanion data) {
    return Ranger(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      level: data.level.present ? data.level.value : this.level,
      experiencePoints: data.experiencePoints.present
          ? data.experiencePoints.value
          : this.experiencePoints,
      baseRecruitmentPoints: data.baseRecruitmentPoints.present
          ? data.baseRecruitmentPoints.value
          : this.baseRecruitmentPoints,
      move: data.move.present ? data.move.value : this.move,
      fight: data.fight.present ? data.fight.value : this.fight,
      shoot: data.shoot.present ? data.shoot.value : this.shoot,
      armour: data.armour.present ? data.armour.value : this.armour,
      will: data.will.present ? data.will.value : this.will,
      health: data.health.present ? data.health.value : this.health,
      currentHealth: data.currentHealth.present
          ? data.currentHealth.value
          : this.currentHealth,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ranger(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('level: $level, ')
          ..write('experiencePoints: $experiencePoints, ')
          ..write('baseRecruitmentPoints: $baseRecruitmentPoints, ')
          ..write('move: $move, ')
          ..write('fight: $fight, ')
          ..write('shoot: $shoot, ')
          ..write('armour: $armour, ')
          ..write('will: $will, ')
          ..write('health: $health, ')
          ..write('currentHealth: $currentHealth, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    level,
    experiencePoints,
    baseRecruitmentPoints,
    move,
    fight,
    shoot,
    armour,
    will,
    health,
    currentHealth,
    createdAt,
    updatedAt,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ranger &&
          other.id == this.id &&
          other.name == this.name &&
          other.level == this.level &&
          other.experiencePoints == this.experiencePoints &&
          other.baseRecruitmentPoints == this.baseRecruitmentPoints &&
          other.move == this.move &&
          other.fight == this.fight &&
          other.shoot == this.shoot &&
          other.armour == this.armour &&
          other.will == this.will &&
          other.health == this.health &&
          other.currentHealth == this.currentHealth &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.notes == this.notes);
}

class RangersCompanion extends UpdateCompanion<Ranger> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> level;
  final Value<int> experiencePoints;
  final Value<int> baseRecruitmentPoints;
  final Value<int> move;
  final Value<int> fight;
  final Value<int> shoot;
  final Value<int> armour;
  final Value<int> will;
  final Value<int> health;
  final Value<int> currentHealth;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> notes;
  const RangersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.level = const Value.absent(),
    this.experiencePoints = const Value.absent(),
    this.baseRecruitmentPoints = const Value.absent(),
    this.move = const Value.absent(),
    this.fight = const Value.absent(),
    this.shoot = const Value.absent(),
    this.armour = const Value.absent(),
    this.will = const Value.absent(),
    this.health = const Value.absent(),
    this.currentHealth = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.notes = const Value.absent(),
  });
  RangersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.level = const Value.absent(),
    this.experiencePoints = const Value.absent(),
    this.baseRecruitmentPoints = const Value.absent(),
    required int move,
    required int fight,
    required int shoot,
    required int armour,
    required int will,
    required int health,
    required int currentHealth,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.notes = const Value.absent(),
  }) : name = Value(name),
       move = Value(move),
       fight = Value(fight),
       shoot = Value(shoot),
       armour = Value(armour),
       will = Value(will),
       health = Value(health),
       currentHealth = Value(currentHealth),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Ranger> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? level,
    Expression<int>? experiencePoints,
    Expression<int>? baseRecruitmentPoints,
    Expression<int>? move,
    Expression<int>? fight,
    Expression<int>? shoot,
    Expression<int>? armour,
    Expression<int>? will,
    Expression<int>? health,
    Expression<int>? currentHealth,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (level != null) 'level': level,
      if (experiencePoints != null) 'experience_points': experiencePoints,
      if (baseRecruitmentPoints != null)
        'base_recruitment_points': baseRecruitmentPoints,
      if (move != null) 'move': move,
      if (fight != null) 'fight': fight,
      if (shoot != null) 'shoot': shoot,
      if (armour != null) 'armour': armour,
      if (will != null) 'will': will,
      if (health != null) 'health': health,
      if (currentHealth != null) 'current_health': currentHealth,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (notes != null) 'notes': notes,
    });
  }

  RangersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? level,
    Value<int>? experiencePoints,
    Value<int>? baseRecruitmentPoints,
    Value<int>? move,
    Value<int>? fight,
    Value<int>? shoot,
    Value<int>? armour,
    Value<int>? will,
    Value<int>? health,
    Value<int>? currentHealth,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? notes,
  }) {
    return RangersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      baseRecruitmentPoints:
          baseRecruitmentPoints ?? this.baseRecruitmentPoints,
      move: move ?? this.move,
      fight: fight ?? this.fight,
      shoot: shoot ?? this.shoot,
      armour: armour ?? this.armour,
      will: will ?? this.will,
      health: health ?? this.health,
      currentHealth: currentHealth ?? this.currentHealth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (experiencePoints.present) {
      map['experience_points'] = Variable<int>(experiencePoints.value);
    }
    if (baseRecruitmentPoints.present) {
      map['base_recruitment_points'] = Variable<int>(
        baseRecruitmentPoints.value,
      );
    }
    if (move.present) {
      map['move'] = Variable<int>(move.value);
    }
    if (fight.present) {
      map['fight'] = Variable<int>(fight.value);
    }
    if (shoot.present) {
      map['shoot'] = Variable<int>(shoot.value);
    }
    if (armour.present) {
      map['armour'] = Variable<int>(armour.value);
    }
    if (will.present) {
      map['will'] = Variable<int>(will.value);
    }
    if (health.present) {
      map['health'] = Variable<int>(health.value);
    }
    if (currentHealth.present) {
      map['current_health'] = Variable<int>(currentHealth.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RangersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('level: $level, ')
          ..write('experiencePoints: $experiencePoints, ')
          ..write('baseRecruitmentPoints: $baseRecruitmentPoints, ')
          ..write('move: $move, ')
          ..write('fight: $fight, ')
          ..write('shoot: $shoot, ')
          ..write('armour: $armour, ')
          ..write('will: $will, ')
          ..write('health: $health, ')
          ..write('currentHealth: $currentHealth, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $RangerAbilitiesTable extends RangerAbilities
    with TableInfo<$RangerAbilitiesTable, RangerAbility> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RangerAbilitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rangerIdMeta = const VerificationMeta(
    'rangerId',
  );
  @override
  late final GeneratedColumn<int> rangerId = GeneratedColumn<int>(
    'ranger_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rangers (id)',
    ),
  );
  static const VerificationMeta _abilityTypeMeta = const VerificationMeta(
    'abilityType',
  );
  @override
  late final GeneratedColumn<String> abilityType = GeneratedColumn<String>(
    'ability_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _abilityKeyMeta = const VerificationMeta(
    'abilityKey',
  );
  @override
  late final GeneratedColumn<String> abilityKey = GeneratedColumn<String>(
    'ability_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isUsedThisScenarioMeta =
      const VerificationMeta('isUsedThisScenario');
  @override
  late final GeneratedColumn<bool> isUsedThisScenario = GeneratedColumn<bool>(
    'is_used_this_scenario',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_used_this_scenario" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rangerId,
    abilityType,
    abilityKey,
    isUsedThisScenario,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ranger_abilities';
  @override
  VerificationContext validateIntegrity(
    Insertable<RangerAbility> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ranger_id')) {
      context.handle(
        _rangerIdMeta,
        rangerId.isAcceptableOrUnknown(data['ranger_id']!, _rangerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rangerIdMeta);
    }
    if (data.containsKey('ability_type')) {
      context.handle(
        _abilityTypeMeta,
        abilityType.isAcceptableOrUnknown(
          data['ability_type']!,
          _abilityTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_abilityTypeMeta);
    }
    if (data.containsKey('ability_key')) {
      context.handle(
        _abilityKeyMeta,
        abilityKey.isAcceptableOrUnknown(data['ability_key']!, _abilityKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_abilityKeyMeta);
    }
    if (data.containsKey('is_used_this_scenario')) {
      context.handle(
        _isUsedThisScenarioMeta,
        isUsedThisScenario.isAcceptableOrUnknown(
          data['is_used_this_scenario']!,
          _isUsedThisScenarioMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {rangerId, abilityKey},
  ];
  @override
  RangerAbility map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RangerAbility(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rangerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ranger_id'],
      )!,
      abilityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ability_type'],
      )!,
      abilityKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ability_key'],
      )!,
      isUsedThisScenario: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_used_this_scenario'],
      )!,
    );
  }

  @override
  $RangerAbilitiesTable createAlias(String alias) {
    return $RangerAbilitiesTable(attachedDatabase, alias);
  }
}

class RangerAbility extends DataClass implements Insertable<RangerAbility> {
  final int id;
  final int rangerId;
  final String abilityType;
  final String abilityKey;
  final bool isUsedThisScenario;
  const RangerAbility({
    required this.id,
    required this.rangerId,
    required this.abilityType,
    required this.abilityKey,
    required this.isUsedThisScenario,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ranger_id'] = Variable<int>(rangerId);
    map['ability_type'] = Variable<String>(abilityType);
    map['ability_key'] = Variable<String>(abilityKey);
    map['is_used_this_scenario'] = Variable<bool>(isUsedThisScenario);
    return map;
  }

  RangerAbilitiesCompanion toCompanion(bool nullToAbsent) {
    return RangerAbilitiesCompanion(
      id: Value(id),
      rangerId: Value(rangerId),
      abilityType: Value(abilityType),
      abilityKey: Value(abilityKey),
      isUsedThisScenario: Value(isUsedThisScenario),
    );
  }

  factory RangerAbility.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RangerAbility(
      id: serializer.fromJson<int>(json['id']),
      rangerId: serializer.fromJson<int>(json['rangerId']),
      abilityType: serializer.fromJson<String>(json['abilityType']),
      abilityKey: serializer.fromJson<String>(json['abilityKey']),
      isUsedThisScenario: serializer.fromJson<bool>(json['isUsedThisScenario']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rangerId': serializer.toJson<int>(rangerId),
      'abilityType': serializer.toJson<String>(abilityType),
      'abilityKey': serializer.toJson<String>(abilityKey),
      'isUsedThisScenario': serializer.toJson<bool>(isUsedThisScenario),
    };
  }

  RangerAbility copyWith({
    int? id,
    int? rangerId,
    String? abilityType,
    String? abilityKey,
    bool? isUsedThisScenario,
  }) => RangerAbility(
    id: id ?? this.id,
    rangerId: rangerId ?? this.rangerId,
    abilityType: abilityType ?? this.abilityType,
    abilityKey: abilityKey ?? this.abilityKey,
    isUsedThisScenario: isUsedThisScenario ?? this.isUsedThisScenario,
  );
  RangerAbility copyWithCompanion(RangerAbilitiesCompanion data) {
    return RangerAbility(
      id: data.id.present ? data.id.value : this.id,
      rangerId: data.rangerId.present ? data.rangerId.value : this.rangerId,
      abilityType: data.abilityType.present
          ? data.abilityType.value
          : this.abilityType,
      abilityKey: data.abilityKey.present
          ? data.abilityKey.value
          : this.abilityKey,
      isUsedThisScenario: data.isUsedThisScenario.present
          ? data.isUsedThisScenario.value
          : this.isUsedThisScenario,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RangerAbility(')
          ..write('id: $id, ')
          ..write('rangerId: $rangerId, ')
          ..write('abilityType: $abilityType, ')
          ..write('abilityKey: $abilityKey, ')
          ..write('isUsedThisScenario: $isUsedThisScenario')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, rangerId, abilityType, abilityKey, isUsedThisScenario);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RangerAbility &&
          other.id == this.id &&
          other.rangerId == this.rangerId &&
          other.abilityType == this.abilityType &&
          other.abilityKey == this.abilityKey &&
          other.isUsedThisScenario == this.isUsedThisScenario);
}

class RangerAbilitiesCompanion extends UpdateCompanion<RangerAbility> {
  final Value<int> id;
  final Value<int> rangerId;
  final Value<String> abilityType;
  final Value<String> abilityKey;
  final Value<bool> isUsedThisScenario;
  const RangerAbilitiesCompanion({
    this.id = const Value.absent(),
    this.rangerId = const Value.absent(),
    this.abilityType = const Value.absent(),
    this.abilityKey = const Value.absent(),
    this.isUsedThisScenario = const Value.absent(),
  });
  RangerAbilitiesCompanion.insert({
    this.id = const Value.absent(),
    required int rangerId,
    required String abilityType,
    required String abilityKey,
    this.isUsedThisScenario = const Value.absent(),
  }) : rangerId = Value(rangerId),
       abilityType = Value(abilityType),
       abilityKey = Value(abilityKey);
  static Insertable<RangerAbility> custom({
    Expression<int>? id,
    Expression<int>? rangerId,
    Expression<String>? abilityType,
    Expression<String>? abilityKey,
    Expression<bool>? isUsedThisScenario,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rangerId != null) 'ranger_id': rangerId,
      if (abilityType != null) 'ability_type': abilityType,
      if (abilityKey != null) 'ability_key': abilityKey,
      if (isUsedThisScenario != null)
        'is_used_this_scenario': isUsedThisScenario,
    });
  }

  RangerAbilitiesCompanion copyWith({
    Value<int>? id,
    Value<int>? rangerId,
    Value<String>? abilityType,
    Value<String>? abilityKey,
    Value<bool>? isUsedThisScenario,
  }) {
    return RangerAbilitiesCompanion(
      id: id ?? this.id,
      rangerId: rangerId ?? this.rangerId,
      abilityType: abilityType ?? this.abilityType,
      abilityKey: abilityKey ?? this.abilityKey,
      isUsedThisScenario: isUsedThisScenario ?? this.isUsedThisScenario,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rangerId.present) {
      map['ranger_id'] = Variable<int>(rangerId.value);
    }
    if (abilityType.present) {
      map['ability_type'] = Variable<String>(abilityType.value);
    }
    if (abilityKey.present) {
      map['ability_key'] = Variable<String>(abilityKey.value);
    }
    if (isUsedThisScenario.present) {
      map['is_used_this_scenario'] = Variable<bool>(isUsedThisScenario.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RangerAbilitiesCompanion(')
          ..write('id: $id, ')
          ..write('rangerId: $rangerId, ')
          ..write('abilityType: $abilityType, ')
          ..write('abilityKey: $abilityKey, ')
          ..write('isUsedThisScenario: $isUsedThisScenario')
          ..write(')'))
        .toString();
  }
}

class $RangerSkillsTable extends RangerSkills
    with TableInfo<$RangerSkillsTable, RangerSkill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RangerSkillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rangerIdMeta = const VerificationMeta(
    'rangerId',
  );
  @override
  late final GeneratedColumn<int> rangerId = GeneratedColumn<int>(
    'ranger_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rangers (id)',
    ),
  );
  static const VerificationMeta _skillKeyMeta = const VerificationMeta(
    'skillKey',
  );
  @override
  late final GeneratedColumn<String> skillKey = GeneratedColumn<String>(
    'skill_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, rangerId, skillKey, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ranger_skills';
  @override
  VerificationContext validateIntegrity(
    Insertable<RangerSkill> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ranger_id')) {
      context.handle(
        _rangerIdMeta,
        rangerId.isAcceptableOrUnknown(data['ranger_id']!, _rangerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rangerIdMeta);
    }
    if (data.containsKey('skill_key')) {
      context.handle(
        _skillKeyMeta,
        skillKey.isAcceptableOrUnknown(data['skill_key']!, _skillKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_skillKeyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {rangerId, skillKey},
  ];
  @override
  RangerSkill map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RangerSkill(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rangerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ranger_id'],
      )!,
      skillKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skill_key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $RangerSkillsTable createAlias(String alias) {
    return $RangerSkillsTable(attachedDatabase, alias);
  }
}

class RangerSkill extends DataClass implements Insertable<RangerSkill> {
  final int id;
  final int rangerId;
  final String skillKey;
  final int value;
  const RangerSkill({
    required this.id,
    required this.rangerId,
    required this.skillKey,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ranger_id'] = Variable<int>(rangerId);
    map['skill_key'] = Variable<String>(skillKey);
    map['value'] = Variable<int>(value);
    return map;
  }

  RangerSkillsCompanion toCompanion(bool nullToAbsent) {
    return RangerSkillsCompanion(
      id: Value(id),
      rangerId: Value(rangerId),
      skillKey: Value(skillKey),
      value: Value(value),
    );
  }

  factory RangerSkill.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RangerSkill(
      id: serializer.fromJson<int>(json['id']),
      rangerId: serializer.fromJson<int>(json['rangerId']),
      skillKey: serializer.fromJson<String>(json['skillKey']),
      value: serializer.fromJson<int>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rangerId': serializer.toJson<int>(rangerId),
      'skillKey': serializer.toJson<String>(skillKey),
      'value': serializer.toJson<int>(value),
    };
  }

  RangerSkill copyWith({
    int? id,
    int? rangerId,
    String? skillKey,
    int? value,
  }) => RangerSkill(
    id: id ?? this.id,
    rangerId: rangerId ?? this.rangerId,
    skillKey: skillKey ?? this.skillKey,
    value: value ?? this.value,
  );
  RangerSkill copyWithCompanion(RangerSkillsCompanion data) {
    return RangerSkill(
      id: data.id.present ? data.id.value : this.id,
      rangerId: data.rangerId.present ? data.rangerId.value : this.rangerId,
      skillKey: data.skillKey.present ? data.skillKey.value : this.skillKey,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RangerSkill(')
          ..write('id: $id, ')
          ..write('rangerId: $rangerId, ')
          ..write('skillKey: $skillKey, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, rangerId, skillKey, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RangerSkill &&
          other.id == this.id &&
          other.rangerId == this.rangerId &&
          other.skillKey == this.skillKey &&
          other.value == this.value);
}

class RangerSkillsCompanion extends UpdateCompanion<RangerSkill> {
  final Value<int> id;
  final Value<int> rangerId;
  final Value<String> skillKey;
  final Value<int> value;
  const RangerSkillsCompanion({
    this.id = const Value.absent(),
    this.rangerId = const Value.absent(),
    this.skillKey = const Value.absent(),
    this.value = const Value.absent(),
  });
  RangerSkillsCompanion.insert({
    this.id = const Value.absent(),
    required int rangerId,
    required String skillKey,
    required int value,
  }) : rangerId = Value(rangerId),
       skillKey = Value(skillKey),
       value = Value(value);
  static Insertable<RangerSkill> custom({
    Expression<int>? id,
    Expression<int>? rangerId,
    Expression<String>? skillKey,
    Expression<int>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rangerId != null) 'ranger_id': rangerId,
      if (skillKey != null) 'skill_key': skillKey,
      if (value != null) 'value': value,
    });
  }

  RangerSkillsCompanion copyWith({
    Value<int>? id,
    Value<int>? rangerId,
    Value<String>? skillKey,
    Value<int>? value,
  }) {
    return RangerSkillsCompanion(
      id: id ?? this.id,
      rangerId: rangerId ?? this.rangerId,
      skillKey: skillKey ?? this.skillKey,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rangerId.present) {
      map['ranger_id'] = Variable<int>(rangerId.value);
    }
    if (skillKey.present) {
      map['skill_key'] = Variable<String>(skillKey.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RangerSkillsCompanion(')
          ..write('id: $id, ')
          ..write('rangerId: $rangerId, ')
          ..write('skillKey: $skillKey, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $CompanionTypesTable extends CompanionTypes
    with TableInfo<$CompanionTypesTable, CompanionType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompanionTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _typeKeyMeta = const VerificationMeta(
    'typeKey',
  );
  @override
  late final GeneratedColumn<String> typeKey = GeneratedColumn<String>(
    'type_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rpCostMeta = const VerificationMeta('rpCost');
  @override
  late final GeneratedColumn<int> rpCost = GeneratedColumn<int>(
    'rp_cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moveMeta = const VerificationMeta('move');
  @override
  late final GeneratedColumn<int> move = GeneratedColumn<int>(
    'move',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fightMeta = const VerificationMeta('fight');
  @override
  late final GeneratedColumn<int> fight = GeneratedColumn<int>(
    'fight',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shootMeta = const VerificationMeta('shoot');
  @override
  late final GeneratedColumn<int> shoot = GeneratedColumn<int>(
    'shoot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _armourMeta = const VerificationMeta('armour');
  @override
  late final GeneratedColumn<int> armour = GeneratedColumn<int>(
    'armour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _willMeta = const VerificationMeta('will');
  @override
  late final GeneratedColumn<int> will = GeneratedColumn<int>(
    'will',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _healthMeta = const VerificationMeta('health');
  @override
  late final GeneratedColumn<int> health = GeneratedColumn<int>(
    'health',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isAnimalMeta = const VerificationMeta(
    'isAnimal',
  );
  @override
  late final GeneratedColumn<bool> isAnimal = GeneratedColumn<bool>(
    'is_animal',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_animal" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _baseSkillsMeta = const VerificationMeta(
    'baseSkills',
  );
  @override
  late final GeneratedColumn<String> baseSkills = GeneratedColumn<String>(
    'base_skills',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    typeKey,
    name,
    rpCost,
    move,
    fight,
    shoot,
    armour,
    will,
    health,
    notes,
    isAnimal,
    baseSkills,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'companion_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompanionType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type_key')) {
      context.handle(
        _typeKeyMeta,
        typeKey.isAcceptableOrUnknown(data['type_key']!, _typeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_typeKeyMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('rp_cost')) {
      context.handle(
        _rpCostMeta,
        rpCost.isAcceptableOrUnknown(data['rp_cost']!, _rpCostMeta),
      );
    } else if (isInserting) {
      context.missing(_rpCostMeta);
    }
    if (data.containsKey('move')) {
      context.handle(
        _moveMeta,
        move.isAcceptableOrUnknown(data['move']!, _moveMeta),
      );
    } else if (isInserting) {
      context.missing(_moveMeta);
    }
    if (data.containsKey('fight')) {
      context.handle(
        _fightMeta,
        fight.isAcceptableOrUnknown(data['fight']!, _fightMeta),
      );
    } else if (isInserting) {
      context.missing(_fightMeta);
    }
    if (data.containsKey('shoot')) {
      context.handle(
        _shootMeta,
        shoot.isAcceptableOrUnknown(data['shoot']!, _shootMeta),
      );
    } else if (isInserting) {
      context.missing(_shootMeta);
    }
    if (data.containsKey('armour')) {
      context.handle(
        _armourMeta,
        armour.isAcceptableOrUnknown(data['armour']!, _armourMeta),
      );
    } else if (isInserting) {
      context.missing(_armourMeta);
    }
    if (data.containsKey('will')) {
      context.handle(
        _willMeta,
        will.isAcceptableOrUnknown(data['will']!, _willMeta),
      );
    } else if (isInserting) {
      context.missing(_willMeta);
    }
    if (data.containsKey('health')) {
      context.handle(
        _healthMeta,
        health.isAcceptableOrUnknown(data['health']!, _healthMeta),
      );
    } else if (isInserting) {
      context.missing(_healthMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_animal')) {
      context.handle(
        _isAnimalMeta,
        isAnimal.isAcceptableOrUnknown(data['is_animal']!, _isAnimalMeta),
      );
    }
    if (data.containsKey('base_skills')) {
      context.handle(
        _baseSkillsMeta,
        baseSkills.isAcceptableOrUnknown(data['base_skills']!, _baseSkillsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompanionType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompanionType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      typeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_key'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      rpCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rp_cost'],
      )!,
      move: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}move'],
      )!,
      fight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fight'],
      )!,
      shoot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shoot'],
      )!,
      armour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}armour'],
      )!,
      will: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}will'],
      )!,
      health: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}health'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      isAnimal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_animal'],
      )!,
      baseSkills: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_skills'],
      )!,
    );
  }

  @override
  $CompanionTypesTable createAlias(String alias) {
    return $CompanionTypesTable(attachedDatabase, alias);
  }
}

class CompanionType extends DataClass implements Insertable<CompanionType> {
  final int id;
  final String typeKey;
  final String name;
  final int rpCost;
  final int move;
  final int fight;
  final int shoot;
  final int armour;
  final int will;
  final int health;
  final String notes;
  final bool isAnimal;
  final String baseSkills;
  const CompanionType({
    required this.id,
    required this.typeKey,
    required this.name,
    required this.rpCost,
    required this.move,
    required this.fight,
    required this.shoot,
    required this.armour,
    required this.will,
    required this.health,
    required this.notes,
    required this.isAnimal,
    required this.baseSkills,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type_key'] = Variable<String>(typeKey);
    map['name'] = Variable<String>(name);
    map['rp_cost'] = Variable<int>(rpCost);
    map['move'] = Variable<int>(move);
    map['fight'] = Variable<int>(fight);
    map['shoot'] = Variable<int>(shoot);
    map['armour'] = Variable<int>(armour);
    map['will'] = Variable<int>(will);
    map['health'] = Variable<int>(health);
    map['notes'] = Variable<String>(notes);
    map['is_animal'] = Variable<bool>(isAnimal);
    map['base_skills'] = Variable<String>(baseSkills);
    return map;
  }

  CompanionTypesCompanion toCompanion(bool nullToAbsent) {
    return CompanionTypesCompanion(
      id: Value(id),
      typeKey: Value(typeKey),
      name: Value(name),
      rpCost: Value(rpCost),
      move: Value(move),
      fight: Value(fight),
      shoot: Value(shoot),
      armour: Value(armour),
      will: Value(will),
      health: Value(health),
      notes: Value(notes),
      isAnimal: Value(isAnimal),
      baseSkills: Value(baseSkills),
    );
  }

  factory CompanionType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompanionType(
      id: serializer.fromJson<int>(json['id']),
      typeKey: serializer.fromJson<String>(json['typeKey']),
      name: serializer.fromJson<String>(json['name']),
      rpCost: serializer.fromJson<int>(json['rpCost']),
      move: serializer.fromJson<int>(json['move']),
      fight: serializer.fromJson<int>(json['fight']),
      shoot: serializer.fromJson<int>(json['shoot']),
      armour: serializer.fromJson<int>(json['armour']),
      will: serializer.fromJson<int>(json['will']),
      health: serializer.fromJson<int>(json['health']),
      notes: serializer.fromJson<String>(json['notes']),
      isAnimal: serializer.fromJson<bool>(json['isAnimal']),
      baseSkills: serializer.fromJson<String>(json['baseSkills']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'typeKey': serializer.toJson<String>(typeKey),
      'name': serializer.toJson<String>(name),
      'rpCost': serializer.toJson<int>(rpCost),
      'move': serializer.toJson<int>(move),
      'fight': serializer.toJson<int>(fight),
      'shoot': serializer.toJson<int>(shoot),
      'armour': serializer.toJson<int>(armour),
      'will': serializer.toJson<int>(will),
      'health': serializer.toJson<int>(health),
      'notes': serializer.toJson<String>(notes),
      'isAnimal': serializer.toJson<bool>(isAnimal),
      'baseSkills': serializer.toJson<String>(baseSkills),
    };
  }

  CompanionType copyWith({
    int? id,
    String? typeKey,
    String? name,
    int? rpCost,
    int? move,
    int? fight,
    int? shoot,
    int? armour,
    int? will,
    int? health,
    String? notes,
    bool? isAnimal,
    String? baseSkills,
  }) => CompanionType(
    id: id ?? this.id,
    typeKey: typeKey ?? this.typeKey,
    name: name ?? this.name,
    rpCost: rpCost ?? this.rpCost,
    move: move ?? this.move,
    fight: fight ?? this.fight,
    shoot: shoot ?? this.shoot,
    armour: armour ?? this.armour,
    will: will ?? this.will,
    health: health ?? this.health,
    notes: notes ?? this.notes,
    isAnimal: isAnimal ?? this.isAnimal,
    baseSkills: baseSkills ?? this.baseSkills,
  );
  CompanionType copyWithCompanion(CompanionTypesCompanion data) {
    return CompanionType(
      id: data.id.present ? data.id.value : this.id,
      typeKey: data.typeKey.present ? data.typeKey.value : this.typeKey,
      name: data.name.present ? data.name.value : this.name,
      rpCost: data.rpCost.present ? data.rpCost.value : this.rpCost,
      move: data.move.present ? data.move.value : this.move,
      fight: data.fight.present ? data.fight.value : this.fight,
      shoot: data.shoot.present ? data.shoot.value : this.shoot,
      armour: data.armour.present ? data.armour.value : this.armour,
      will: data.will.present ? data.will.value : this.will,
      health: data.health.present ? data.health.value : this.health,
      notes: data.notes.present ? data.notes.value : this.notes,
      isAnimal: data.isAnimal.present ? data.isAnimal.value : this.isAnimal,
      baseSkills: data.baseSkills.present
          ? data.baseSkills.value
          : this.baseSkills,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompanionType(')
          ..write('id: $id, ')
          ..write('typeKey: $typeKey, ')
          ..write('name: $name, ')
          ..write('rpCost: $rpCost, ')
          ..write('move: $move, ')
          ..write('fight: $fight, ')
          ..write('shoot: $shoot, ')
          ..write('armour: $armour, ')
          ..write('will: $will, ')
          ..write('health: $health, ')
          ..write('notes: $notes, ')
          ..write('isAnimal: $isAnimal, ')
          ..write('baseSkills: $baseSkills')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    typeKey,
    name,
    rpCost,
    move,
    fight,
    shoot,
    armour,
    will,
    health,
    notes,
    isAnimal,
    baseSkills,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompanionType &&
          other.id == this.id &&
          other.typeKey == this.typeKey &&
          other.name == this.name &&
          other.rpCost == this.rpCost &&
          other.move == this.move &&
          other.fight == this.fight &&
          other.shoot == this.shoot &&
          other.armour == this.armour &&
          other.will == this.will &&
          other.health == this.health &&
          other.notes == this.notes &&
          other.isAnimal == this.isAnimal &&
          other.baseSkills == this.baseSkills);
}

class CompanionTypesCompanion extends UpdateCompanion<CompanionType> {
  final Value<int> id;
  final Value<String> typeKey;
  final Value<String> name;
  final Value<int> rpCost;
  final Value<int> move;
  final Value<int> fight;
  final Value<int> shoot;
  final Value<int> armour;
  final Value<int> will;
  final Value<int> health;
  final Value<String> notes;
  final Value<bool> isAnimal;
  final Value<String> baseSkills;
  const CompanionTypesCompanion({
    this.id = const Value.absent(),
    this.typeKey = const Value.absent(),
    this.name = const Value.absent(),
    this.rpCost = const Value.absent(),
    this.move = const Value.absent(),
    this.fight = const Value.absent(),
    this.shoot = const Value.absent(),
    this.armour = const Value.absent(),
    this.will = const Value.absent(),
    this.health = const Value.absent(),
    this.notes = const Value.absent(),
    this.isAnimal = const Value.absent(),
    this.baseSkills = const Value.absent(),
  });
  CompanionTypesCompanion.insert({
    this.id = const Value.absent(),
    required String typeKey,
    required String name,
    required int rpCost,
    required int move,
    required int fight,
    required int shoot,
    required int armour,
    required int will,
    required int health,
    this.notes = const Value.absent(),
    this.isAnimal = const Value.absent(),
    this.baseSkills = const Value.absent(),
  }) : typeKey = Value(typeKey),
       name = Value(name),
       rpCost = Value(rpCost),
       move = Value(move),
       fight = Value(fight),
       shoot = Value(shoot),
       armour = Value(armour),
       will = Value(will),
       health = Value(health);
  static Insertable<CompanionType> custom({
    Expression<int>? id,
    Expression<String>? typeKey,
    Expression<String>? name,
    Expression<int>? rpCost,
    Expression<int>? move,
    Expression<int>? fight,
    Expression<int>? shoot,
    Expression<int>? armour,
    Expression<int>? will,
    Expression<int>? health,
    Expression<String>? notes,
    Expression<bool>? isAnimal,
    Expression<String>? baseSkills,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (typeKey != null) 'type_key': typeKey,
      if (name != null) 'name': name,
      if (rpCost != null) 'rp_cost': rpCost,
      if (move != null) 'move': move,
      if (fight != null) 'fight': fight,
      if (shoot != null) 'shoot': shoot,
      if (armour != null) 'armour': armour,
      if (will != null) 'will': will,
      if (health != null) 'health': health,
      if (notes != null) 'notes': notes,
      if (isAnimal != null) 'is_animal': isAnimal,
      if (baseSkills != null) 'base_skills': baseSkills,
    });
  }

  CompanionTypesCompanion copyWith({
    Value<int>? id,
    Value<String>? typeKey,
    Value<String>? name,
    Value<int>? rpCost,
    Value<int>? move,
    Value<int>? fight,
    Value<int>? shoot,
    Value<int>? armour,
    Value<int>? will,
    Value<int>? health,
    Value<String>? notes,
    Value<bool>? isAnimal,
    Value<String>? baseSkills,
  }) {
    return CompanionTypesCompanion(
      id: id ?? this.id,
      typeKey: typeKey ?? this.typeKey,
      name: name ?? this.name,
      rpCost: rpCost ?? this.rpCost,
      move: move ?? this.move,
      fight: fight ?? this.fight,
      shoot: shoot ?? this.shoot,
      armour: armour ?? this.armour,
      will: will ?? this.will,
      health: health ?? this.health,
      notes: notes ?? this.notes,
      isAnimal: isAnimal ?? this.isAnimal,
      baseSkills: baseSkills ?? this.baseSkills,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (typeKey.present) {
      map['type_key'] = Variable<String>(typeKey.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rpCost.present) {
      map['rp_cost'] = Variable<int>(rpCost.value);
    }
    if (move.present) {
      map['move'] = Variable<int>(move.value);
    }
    if (fight.present) {
      map['fight'] = Variable<int>(fight.value);
    }
    if (shoot.present) {
      map['shoot'] = Variable<int>(shoot.value);
    }
    if (armour.present) {
      map['armour'] = Variable<int>(armour.value);
    }
    if (will.present) {
      map['will'] = Variable<int>(will.value);
    }
    if (health.present) {
      map['health'] = Variable<int>(health.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isAnimal.present) {
      map['is_animal'] = Variable<bool>(isAnimal.value);
    }
    if (baseSkills.present) {
      map['base_skills'] = Variable<String>(baseSkills.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompanionTypesCompanion(')
          ..write('id: $id, ')
          ..write('typeKey: $typeKey, ')
          ..write('name: $name, ')
          ..write('rpCost: $rpCost, ')
          ..write('move: $move, ')
          ..write('fight: $fight, ')
          ..write('shoot: $shoot, ')
          ..write('armour: $armour, ')
          ..write('will: $will, ')
          ..write('health: $health, ')
          ..write('notes: $notes, ')
          ..write('isAnimal: $isAnimal, ')
          ..write('baseSkills: $baseSkills')
          ..write(')'))
        .toString();
  }
}

class $RangerCompanionsTable extends RangerCompanions
    with TableInfo<$RangerCompanionsTable, RangerCompanion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RangerCompanionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rangerIdMeta = const VerificationMeta(
    'rangerId',
  );
  @override
  late final GeneratedColumn<int> rangerId = GeneratedColumn<int>(
    'ranger_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rangers (id)',
    ),
  );
  static const VerificationMeta _companionTypeIdMeta = const VerificationMeta(
    'companionTypeId',
  );
  @override
  late final GeneratedColumn<int> companionTypeId = GeneratedColumn<int>(
    'companion_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companion_types (id)',
    ),
  );
  static const VerificationMeta _customNameMeta = const VerificationMeta(
    'customName',
  );
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
    'custom_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _progressionPointsMeta = const VerificationMeta(
    'progressionPoints',
  );
  @override
  late final GeneratedColumn<int> progressionPoints = GeneratedColumn<int>(
    'progression_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isAliveMeta = const VerificationMeta(
    'isAlive',
  );
  @override
  late final GeneratedColumn<bool> isAlive = GeneratedColumn<bool>(
    'is_alive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_alive" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _permanentInjuriesMeta = const VerificationMeta(
    'permanentInjuries',
  );
  @override
  late final GeneratedColumn<String> permanentInjuries =
      GeneratedColumn<String>(
        'permanent_injuries',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _customSkillsMeta = const VerificationMeta(
    'customSkills',
  );
  @override
  late final GeneratedColumn<String> customSkills = GeneratedColumn<String>(
    'custom_skills',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _claimedProgressionRewardsMeta =
      const VerificationMeta('claimedProgressionRewards');
  @override
  late final GeneratedColumn<String> claimedProgressionRewards =
      GeneratedColumn<String>(
        'claimed_progression_rewards',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _hasUsedRecruitmentBonusMeta =
      const VerificationMeta('hasUsedRecruitmentBonus');
  @override
  late final GeneratedColumn<bool> hasUsedRecruitmentBonus =
      GeneratedColumn<bool>(
        'has_used_recruitment_bonus',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_used_recruitment_bonus" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _bonusHealthMeta = const VerificationMeta(
    'bonusHealth',
  );
  @override
  late final GeneratedColumn<int> bonusHealth = GeneratedColumn<int>(
    'bonus_health',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rangerId,
    companionTypeId,
    customName,
    progressionPoints,
    isAlive,
    permanentInjuries,
    customSkills,
    isActive,
    createdAt,
    claimedProgressionRewards,
    hasUsedRecruitmentBonus,
    bonusHealth,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ranger_companions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RangerCompanion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ranger_id')) {
      context.handle(
        _rangerIdMeta,
        rangerId.isAcceptableOrUnknown(data['ranger_id']!, _rangerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rangerIdMeta);
    }
    if (data.containsKey('companion_type_id')) {
      context.handle(
        _companionTypeIdMeta,
        companionTypeId.isAcceptableOrUnknown(
          data['companion_type_id']!,
          _companionTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_companionTypeIdMeta);
    }
    if (data.containsKey('custom_name')) {
      context.handle(
        _customNameMeta,
        customName.isAcceptableOrUnknown(data['custom_name']!, _customNameMeta),
      );
    } else if (isInserting) {
      context.missing(_customNameMeta);
    }
    if (data.containsKey('progression_points')) {
      context.handle(
        _progressionPointsMeta,
        progressionPoints.isAcceptableOrUnknown(
          data['progression_points']!,
          _progressionPointsMeta,
        ),
      );
    }
    if (data.containsKey('is_alive')) {
      context.handle(
        _isAliveMeta,
        isAlive.isAcceptableOrUnknown(data['is_alive']!, _isAliveMeta),
      );
    }
    if (data.containsKey('permanent_injuries')) {
      context.handle(
        _permanentInjuriesMeta,
        permanentInjuries.isAcceptableOrUnknown(
          data['permanent_injuries']!,
          _permanentInjuriesMeta,
        ),
      );
    }
    if (data.containsKey('custom_skills')) {
      context.handle(
        _customSkillsMeta,
        customSkills.isAcceptableOrUnknown(
          data['custom_skills']!,
          _customSkillsMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('claimed_progression_rewards')) {
      context.handle(
        _claimedProgressionRewardsMeta,
        claimedProgressionRewards.isAcceptableOrUnknown(
          data['claimed_progression_rewards']!,
          _claimedProgressionRewardsMeta,
        ),
      );
    }
    if (data.containsKey('has_used_recruitment_bonus')) {
      context.handle(
        _hasUsedRecruitmentBonusMeta,
        hasUsedRecruitmentBonus.isAcceptableOrUnknown(
          data['has_used_recruitment_bonus']!,
          _hasUsedRecruitmentBonusMeta,
        ),
      );
    }
    if (data.containsKey('bonus_health')) {
      context.handle(
        _bonusHealthMeta,
        bonusHealth.isAcceptableOrUnknown(
          data['bonus_health']!,
          _bonusHealthMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RangerCompanion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RangerCompanion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rangerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ranger_id'],
      )!,
      companionTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}companion_type_id'],
      )!,
      customName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_name'],
      )!,
      progressionPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progression_points'],
      )!,
      isAlive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_alive'],
      )!,
      permanentInjuries: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permanent_injuries'],
      )!,
      customSkills: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_skills'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      claimedProgressionRewards: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}claimed_progression_rewards'],
      )!,
      hasUsedRecruitmentBonus: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_used_recruitment_bonus'],
      )!,
      bonusHealth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bonus_health'],
      )!,
    );
  }

  @override
  $RangerCompanionsTable createAlias(String alias) {
    return $RangerCompanionsTable(attachedDatabase, alias);
  }
}

class RangerCompanion extends DataClass implements Insertable<RangerCompanion> {
  final int id;
  final int rangerId;
  final int companionTypeId;
  final String customName;
  final int progressionPoints;
  final bool isAlive;
  final String permanentInjuries;
  final String customSkills;
  final bool isActive;
  final DateTime createdAt;
  final String claimedProgressionRewards;
  final bool hasUsedRecruitmentBonus;
  final int bonusHealth;
  const RangerCompanion({
    required this.id,
    required this.rangerId,
    required this.companionTypeId,
    required this.customName,
    required this.progressionPoints,
    required this.isAlive,
    required this.permanentInjuries,
    required this.customSkills,
    required this.isActive,
    required this.createdAt,
    required this.claimedProgressionRewards,
    required this.hasUsedRecruitmentBonus,
    required this.bonusHealth,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ranger_id'] = Variable<int>(rangerId);
    map['companion_type_id'] = Variable<int>(companionTypeId);
    map['custom_name'] = Variable<String>(customName);
    map['progression_points'] = Variable<int>(progressionPoints);
    map['is_alive'] = Variable<bool>(isAlive);
    map['permanent_injuries'] = Variable<String>(permanentInjuries);
    map['custom_skills'] = Variable<String>(customSkills);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['claimed_progression_rewards'] = Variable<String>(
      claimedProgressionRewards,
    );
    map['has_used_recruitment_bonus'] = Variable<bool>(hasUsedRecruitmentBonus);
    map['bonus_health'] = Variable<int>(bonusHealth);
    return map;
  }

  RangerCompanionsCompanion toCompanion(bool nullToAbsent) {
    return RangerCompanionsCompanion(
      id: Value(id),
      rangerId: Value(rangerId),
      companionTypeId: Value(companionTypeId),
      customName: Value(customName),
      progressionPoints: Value(progressionPoints),
      isAlive: Value(isAlive),
      permanentInjuries: Value(permanentInjuries),
      customSkills: Value(customSkills),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      claimedProgressionRewards: Value(claimedProgressionRewards),
      hasUsedRecruitmentBonus: Value(hasUsedRecruitmentBonus),
      bonusHealth: Value(bonusHealth),
    );
  }

  factory RangerCompanion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RangerCompanion(
      id: serializer.fromJson<int>(json['id']),
      rangerId: serializer.fromJson<int>(json['rangerId']),
      companionTypeId: serializer.fromJson<int>(json['companionTypeId']),
      customName: serializer.fromJson<String>(json['customName']),
      progressionPoints: serializer.fromJson<int>(json['progressionPoints']),
      isAlive: serializer.fromJson<bool>(json['isAlive']),
      permanentInjuries: serializer.fromJson<String>(json['permanentInjuries']),
      customSkills: serializer.fromJson<String>(json['customSkills']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      claimedProgressionRewards: serializer.fromJson<String>(
        json['claimedProgressionRewards'],
      ),
      hasUsedRecruitmentBonus: serializer.fromJson<bool>(
        json['hasUsedRecruitmentBonus'],
      ),
      bonusHealth: serializer.fromJson<int>(json['bonusHealth']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rangerId': serializer.toJson<int>(rangerId),
      'companionTypeId': serializer.toJson<int>(companionTypeId),
      'customName': serializer.toJson<String>(customName),
      'progressionPoints': serializer.toJson<int>(progressionPoints),
      'isAlive': serializer.toJson<bool>(isAlive),
      'permanentInjuries': serializer.toJson<String>(permanentInjuries),
      'customSkills': serializer.toJson<String>(customSkills),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'claimedProgressionRewards': serializer.toJson<String>(
        claimedProgressionRewards,
      ),
      'hasUsedRecruitmentBonus': serializer.toJson<bool>(
        hasUsedRecruitmentBonus,
      ),
      'bonusHealth': serializer.toJson<int>(bonusHealth),
    };
  }

  RangerCompanion copyWith({
    int? id,
    int? rangerId,
    int? companionTypeId,
    String? customName,
    int? progressionPoints,
    bool? isAlive,
    String? permanentInjuries,
    String? customSkills,
    bool? isActive,
    DateTime? createdAt,
    String? claimedProgressionRewards,
    bool? hasUsedRecruitmentBonus,
    int? bonusHealth,
  }) => RangerCompanion(
    id: id ?? this.id,
    rangerId: rangerId ?? this.rangerId,
    companionTypeId: companionTypeId ?? this.companionTypeId,
    customName: customName ?? this.customName,
    progressionPoints: progressionPoints ?? this.progressionPoints,
    isAlive: isAlive ?? this.isAlive,
    permanentInjuries: permanentInjuries ?? this.permanentInjuries,
    customSkills: customSkills ?? this.customSkills,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    claimedProgressionRewards:
        claimedProgressionRewards ?? this.claimedProgressionRewards,
    hasUsedRecruitmentBonus:
        hasUsedRecruitmentBonus ?? this.hasUsedRecruitmentBonus,
    bonusHealth: bonusHealth ?? this.bonusHealth,
  );
  RangerCompanion copyWithCompanion(RangerCompanionsCompanion data) {
    return RangerCompanion(
      id: data.id.present ? data.id.value : this.id,
      rangerId: data.rangerId.present ? data.rangerId.value : this.rangerId,
      companionTypeId: data.companionTypeId.present
          ? data.companionTypeId.value
          : this.companionTypeId,
      customName: data.customName.present
          ? data.customName.value
          : this.customName,
      progressionPoints: data.progressionPoints.present
          ? data.progressionPoints.value
          : this.progressionPoints,
      isAlive: data.isAlive.present ? data.isAlive.value : this.isAlive,
      permanentInjuries: data.permanentInjuries.present
          ? data.permanentInjuries.value
          : this.permanentInjuries,
      customSkills: data.customSkills.present
          ? data.customSkills.value
          : this.customSkills,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      claimedProgressionRewards: data.claimedProgressionRewards.present
          ? data.claimedProgressionRewards.value
          : this.claimedProgressionRewards,
      hasUsedRecruitmentBonus: data.hasUsedRecruitmentBonus.present
          ? data.hasUsedRecruitmentBonus.value
          : this.hasUsedRecruitmentBonus,
      bonusHealth: data.bonusHealth.present
          ? data.bonusHealth.value
          : this.bonusHealth,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RangerCompanion(')
          ..write('id: $id, ')
          ..write('rangerId: $rangerId, ')
          ..write('companionTypeId: $companionTypeId, ')
          ..write('customName: $customName, ')
          ..write('progressionPoints: $progressionPoints, ')
          ..write('isAlive: $isAlive, ')
          ..write('permanentInjuries: $permanentInjuries, ')
          ..write('customSkills: $customSkills, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('claimedProgressionRewards: $claimedProgressionRewards, ')
          ..write('hasUsedRecruitmentBonus: $hasUsedRecruitmentBonus, ')
          ..write('bonusHealth: $bonusHealth')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rangerId,
    companionTypeId,
    customName,
    progressionPoints,
    isAlive,
    permanentInjuries,
    customSkills,
    isActive,
    createdAt,
    claimedProgressionRewards,
    hasUsedRecruitmentBonus,
    bonusHealth,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RangerCompanion &&
          other.id == this.id &&
          other.rangerId == this.rangerId &&
          other.companionTypeId == this.companionTypeId &&
          other.customName == this.customName &&
          other.progressionPoints == this.progressionPoints &&
          other.isAlive == this.isAlive &&
          other.permanentInjuries == this.permanentInjuries &&
          other.customSkills == this.customSkills &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.claimedProgressionRewards == this.claimedProgressionRewards &&
          other.hasUsedRecruitmentBonus == this.hasUsedRecruitmentBonus &&
          other.bonusHealth == this.bonusHealth);
}

class RangerCompanionsCompanion extends UpdateCompanion<RangerCompanion> {
  final Value<int> id;
  final Value<int> rangerId;
  final Value<int> companionTypeId;
  final Value<String> customName;
  final Value<int> progressionPoints;
  final Value<bool> isAlive;
  final Value<String> permanentInjuries;
  final Value<String> customSkills;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<String> claimedProgressionRewards;
  final Value<bool> hasUsedRecruitmentBonus;
  final Value<int> bonusHealth;
  const RangerCompanionsCompanion({
    this.id = const Value.absent(),
    this.rangerId = const Value.absent(),
    this.companionTypeId = const Value.absent(),
    this.customName = const Value.absent(),
    this.progressionPoints = const Value.absent(),
    this.isAlive = const Value.absent(),
    this.permanentInjuries = const Value.absent(),
    this.customSkills = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.claimedProgressionRewards = const Value.absent(),
    this.hasUsedRecruitmentBonus = const Value.absent(),
    this.bonusHealth = const Value.absent(),
  });
  RangerCompanionsCompanion.insert({
    this.id = const Value.absent(),
    required int rangerId,
    required int companionTypeId,
    required String customName,
    this.progressionPoints = const Value.absent(),
    this.isAlive = const Value.absent(),
    this.permanentInjuries = const Value.absent(),
    this.customSkills = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    this.claimedProgressionRewards = const Value.absent(),
    this.hasUsedRecruitmentBonus = const Value.absent(),
    this.bonusHealth = const Value.absent(),
  }) : rangerId = Value(rangerId),
       companionTypeId = Value(companionTypeId),
       customName = Value(customName),
       createdAt = Value(createdAt);
  static Insertable<RangerCompanion> custom({
    Expression<int>? id,
    Expression<int>? rangerId,
    Expression<int>? companionTypeId,
    Expression<String>? customName,
    Expression<int>? progressionPoints,
    Expression<bool>? isAlive,
    Expression<String>? permanentInjuries,
    Expression<String>? customSkills,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<String>? claimedProgressionRewards,
    Expression<bool>? hasUsedRecruitmentBonus,
    Expression<int>? bonusHealth,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rangerId != null) 'ranger_id': rangerId,
      if (companionTypeId != null) 'companion_type_id': companionTypeId,
      if (customName != null) 'custom_name': customName,
      if (progressionPoints != null) 'progression_points': progressionPoints,
      if (isAlive != null) 'is_alive': isAlive,
      if (permanentInjuries != null) 'permanent_injuries': permanentInjuries,
      if (customSkills != null) 'custom_skills': customSkills,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (claimedProgressionRewards != null)
        'claimed_progression_rewards': claimedProgressionRewards,
      if (hasUsedRecruitmentBonus != null)
        'has_used_recruitment_bonus': hasUsedRecruitmentBonus,
      if (bonusHealth != null) 'bonus_health': bonusHealth,
    });
  }

  RangerCompanionsCompanion copyWith({
    Value<int>? id,
    Value<int>? rangerId,
    Value<int>? companionTypeId,
    Value<String>? customName,
    Value<int>? progressionPoints,
    Value<bool>? isAlive,
    Value<String>? permanentInjuries,
    Value<String>? customSkills,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<String>? claimedProgressionRewards,
    Value<bool>? hasUsedRecruitmentBonus,
    Value<int>? bonusHealth,
  }) {
    return RangerCompanionsCompanion(
      id: id ?? this.id,
      rangerId: rangerId ?? this.rangerId,
      companionTypeId: companionTypeId ?? this.companionTypeId,
      customName: customName ?? this.customName,
      progressionPoints: progressionPoints ?? this.progressionPoints,
      isAlive: isAlive ?? this.isAlive,
      permanentInjuries: permanentInjuries ?? this.permanentInjuries,
      customSkills: customSkills ?? this.customSkills,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      claimedProgressionRewards:
          claimedProgressionRewards ?? this.claimedProgressionRewards,
      hasUsedRecruitmentBonus:
          hasUsedRecruitmentBonus ?? this.hasUsedRecruitmentBonus,
      bonusHealth: bonusHealth ?? this.bonusHealth,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rangerId.present) {
      map['ranger_id'] = Variable<int>(rangerId.value);
    }
    if (companionTypeId.present) {
      map['companion_type_id'] = Variable<int>(companionTypeId.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (progressionPoints.present) {
      map['progression_points'] = Variable<int>(progressionPoints.value);
    }
    if (isAlive.present) {
      map['is_alive'] = Variable<bool>(isAlive.value);
    }
    if (permanentInjuries.present) {
      map['permanent_injuries'] = Variable<String>(permanentInjuries.value);
    }
    if (customSkills.present) {
      map['custom_skills'] = Variable<String>(customSkills.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (claimedProgressionRewards.present) {
      map['claimed_progression_rewards'] = Variable<String>(
        claimedProgressionRewards.value,
      );
    }
    if (hasUsedRecruitmentBonus.present) {
      map['has_used_recruitment_bonus'] = Variable<bool>(
        hasUsedRecruitmentBonus.value,
      );
    }
    if (bonusHealth.present) {
      map['bonus_health'] = Variable<int>(bonusHealth.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RangerCompanionsCompanion(')
          ..write('id: $id, ')
          ..write('rangerId: $rangerId, ')
          ..write('companionTypeId: $companionTypeId, ')
          ..write('customName: $customName, ')
          ..write('progressionPoints: $progressionPoints, ')
          ..write('isAlive: $isAlive, ')
          ..write('permanentInjuries: $permanentInjuries, ')
          ..write('customSkills: $customSkills, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('claimedProgressionRewards: $claimedProgressionRewards, ')
          ..write('hasUsedRecruitmentBonus: $hasUsedRecruitmentBonus, ')
          ..write('bonusHealth: $bonusHealth')
          ..write(')'))
        .toString();
  }
}

class $EquipmentTable extends Equipment
    with TableInfo<$EquipmentTable, EquipmentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EquipmentTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _itemKeyMeta = const VerificationMeta(
    'itemKey',
  );
  @override
  late final GeneratedColumn<String> itemKey = GeneratedColumn<String>(
    'item_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _effectsMeta = const VerificationMeta(
    'effects',
  );
  @override
  late final GeneratedColumn<String> effects = GeneratedColumn<String>(
    'effects',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _hasUsesMeta = const VerificationMeta(
    'hasUses',
  );
  @override
  late final GeneratedColumn<bool> hasUses = GeneratedColumn<bool>(
    'has_uses',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_uses" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _maxUsesMeta = const VerificationMeta(
    'maxUses',
  );
  @override
  late final GeneratedColumn<int> maxUses = GeneratedColumn<int>(
    'max_uses',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemKey,
    name,
    category,
    description,
    effects,
    hasUses,
    maxUses,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'equipment';
  @override
  VerificationContext validateIntegrity(
    Insertable<EquipmentData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('item_key')) {
      context.handle(
        _itemKeyMeta,
        itemKey.isAcceptableOrUnknown(data['item_key']!, _itemKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_itemKeyMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('effects')) {
      context.handle(
        _effectsMeta,
        effects.isAcceptableOrUnknown(data['effects']!, _effectsMeta),
      );
    }
    if (data.containsKey('has_uses')) {
      context.handle(
        _hasUsesMeta,
        hasUses.isAcceptableOrUnknown(data['has_uses']!, _hasUsesMeta),
      );
    }
    if (data.containsKey('max_uses')) {
      context.handle(
        _maxUsesMeta,
        maxUses.isAcceptableOrUnknown(data['max_uses']!, _maxUsesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EquipmentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EquipmentData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      itemKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_key'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      effects: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effects'],
      )!,
      hasUses: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_uses'],
      )!,
      maxUses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_uses'],
      ),
    );
  }

  @override
  $EquipmentTable createAlias(String alias) {
    return $EquipmentTable(attachedDatabase, alias);
  }
}

class EquipmentData extends DataClass implements Insertable<EquipmentData> {
  final int id;
  final String itemKey;
  final String name;
  final String category;
  final String description;
  final String effects;
  final bool hasUses;
  final int? maxUses;
  const EquipmentData({
    required this.id,
    required this.itemKey,
    required this.name,
    required this.category,
    required this.description,
    required this.effects,
    required this.hasUses,
    this.maxUses,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['item_key'] = Variable<String>(itemKey);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['description'] = Variable<String>(description);
    map['effects'] = Variable<String>(effects);
    map['has_uses'] = Variable<bool>(hasUses);
    if (!nullToAbsent || maxUses != null) {
      map['max_uses'] = Variable<int>(maxUses);
    }
    return map;
  }

  EquipmentCompanion toCompanion(bool nullToAbsent) {
    return EquipmentCompanion(
      id: Value(id),
      itemKey: Value(itemKey),
      name: Value(name),
      category: Value(category),
      description: Value(description),
      effects: Value(effects),
      hasUses: Value(hasUses),
      maxUses: maxUses == null && nullToAbsent
          ? const Value.absent()
          : Value(maxUses),
    );
  }

  factory EquipmentData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EquipmentData(
      id: serializer.fromJson<int>(json['id']),
      itemKey: serializer.fromJson<String>(json['itemKey']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      description: serializer.fromJson<String>(json['description']),
      effects: serializer.fromJson<String>(json['effects']),
      hasUses: serializer.fromJson<bool>(json['hasUses']),
      maxUses: serializer.fromJson<int?>(json['maxUses']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'itemKey': serializer.toJson<String>(itemKey),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'description': serializer.toJson<String>(description),
      'effects': serializer.toJson<String>(effects),
      'hasUses': serializer.toJson<bool>(hasUses),
      'maxUses': serializer.toJson<int?>(maxUses),
    };
  }

  EquipmentData copyWith({
    int? id,
    String? itemKey,
    String? name,
    String? category,
    String? description,
    String? effects,
    bool? hasUses,
    Value<int?> maxUses = const Value.absent(),
  }) => EquipmentData(
    id: id ?? this.id,
    itemKey: itemKey ?? this.itemKey,
    name: name ?? this.name,
    category: category ?? this.category,
    description: description ?? this.description,
    effects: effects ?? this.effects,
    hasUses: hasUses ?? this.hasUses,
    maxUses: maxUses.present ? maxUses.value : this.maxUses,
  );
  EquipmentData copyWithCompanion(EquipmentCompanion data) {
    return EquipmentData(
      id: data.id.present ? data.id.value : this.id,
      itemKey: data.itemKey.present ? data.itemKey.value : this.itemKey,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      description: data.description.present
          ? data.description.value
          : this.description,
      effects: data.effects.present ? data.effects.value : this.effects,
      hasUses: data.hasUses.present ? data.hasUses.value : this.hasUses,
      maxUses: data.maxUses.present ? data.maxUses.value : this.maxUses,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EquipmentData(')
          ..write('id: $id, ')
          ..write('itemKey: $itemKey, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('effects: $effects, ')
          ..write('hasUses: $hasUses, ')
          ..write('maxUses: $maxUses')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemKey,
    name,
    category,
    description,
    effects,
    hasUses,
    maxUses,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EquipmentData &&
          other.id == this.id &&
          other.itemKey == this.itemKey &&
          other.name == this.name &&
          other.category == this.category &&
          other.description == this.description &&
          other.effects == this.effects &&
          other.hasUses == this.hasUses &&
          other.maxUses == this.maxUses);
}

class EquipmentCompanion extends UpdateCompanion<EquipmentData> {
  final Value<int> id;
  final Value<String> itemKey;
  final Value<String> name;
  final Value<String> category;
  final Value<String> description;
  final Value<String> effects;
  final Value<bool> hasUses;
  final Value<int?> maxUses;
  const EquipmentCompanion({
    this.id = const Value.absent(),
    this.itemKey = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.effects = const Value.absent(),
    this.hasUses = const Value.absent(),
    this.maxUses = const Value.absent(),
  });
  EquipmentCompanion.insert({
    this.id = const Value.absent(),
    required String itemKey,
    required String name,
    required String category,
    this.description = const Value.absent(),
    this.effects = const Value.absent(),
    this.hasUses = const Value.absent(),
    this.maxUses = const Value.absent(),
  }) : itemKey = Value(itemKey),
       name = Value(name),
       category = Value(category);
  static Insertable<EquipmentData> custom({
    Expression<int>? id,
    Expression<String>? itemKey,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? description,
    Expression<String>? effects,
    Expression<bool>? hasUses,
    Expression<int>? maxUses,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemKey != null) 'item_key': itemKey,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (effects != null) 'effects': effects,
      if (hasUses != null) 'has_uses': hasUses,
      if (maxUses != null) 'max_uses': maxUses,
    });
  }

  EquipmentCompanion copyWith({
    Value<int>? id,
    Value<String>? itemKey,
    Value<String>? name,
    Value<String>? category,
    Value<String>? description,
    Value<String>? effects,
    Value<bool>? hasUses,
    Value<int?>? maxUses,
  }) {
    return EquipmentCompanion(
      id: id ?? this.id,
      itemKey: itemKey ?? this.itemKey,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      effects: effects ?? this.effects,
      hasUses: hasUses ?? this.hasUses,
      maxUses: maxUses ?? this.maxUses,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (itemKey.present) {
      map['item_key'] = Variable<String>(itemKey.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (effects.present) {
      map['effects'] = Variable<String>(effects.value);
    }
    if (hasUses.present) {
      map['has_uses'] = Variable<bool>(hasUses.value);
    }
    if (maxUses.present) {
      map['max_uses'] = Variable<int>(maxUses.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EquipmentCompanion(')
          ..write('id: $id, ')
          ..write('itemKey: $itemKey, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('effects: $effects, ')
          ..write('hasUses: $hasUses, ')
          ..write('maxUses: $maxUses')
          ..write(')'))
        .toString();
  }
}

class $RangerEquipmentTable extends RangerEquipment
    with TableInfo<$RangerEquipmentTable, RangerEquipmentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RangerEquipmentTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rangerIdMeta = const VerificationMeta(
    'rangerId',
  );
  @override
  late final GeneratedColumn<int> rangerId = GeneratedColumn<int>(
    'ranger_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rangers (id)',
    ),
  );
  static const VerificationMeta _equipmentIdMeta = const VerificationMeta(
    'equipmentId',
  );
  @override
  late final GeneratedColumn<int> equipmentId = GeneratedColumn<int>(
    'equipment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES equipment (id)',
    ),
  );
  static const VerificationMeta _currentUsesMeta = const VerificationMeta(
    'currentUses',
  );
  @override
  late final GeneratedColumn<int> currentUses = GeneratedColumn<int>(
    'current_uses',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _equippedByMeta = const VerificationMeta(
    'equippedBy',
  );
  @override
  late final GeneratedColumn<String> equippedBy = GeneratedColumn<String>(
    'equipped_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ranger'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rangerId,
    equipmentId,
    currentUses,
    equippedBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ranger_equipment';
  @override
  VerificationContext validateIntegrity(
    Insertable<RangerEquipmentData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ranger_id')) {
      context.handle(
        _rangerIdMeta,
        rangerId.isAcceptableOrUnknown(data['ranger_id']!, _rangerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rangerIdMeta);
    }
    if (data.containsKey('equipment_id')) {
      context.handle(
        _equipmentIdMeta,
        equipmentId.isAcceptableOrUnknown(
          data['equipment_id']!,
          _equipmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_equipmentIdMeta);
    }
    if (data.containsKey('current_uses')) {
      context.handle(
        _currentUsesMeta,
        currentUses.isAcceptableOrUnknown(
          data['current_uses']!,
          _currentUsesMeta,
        ),
      );
    }
    if (data.containsKey('equipped_by')) {
      context.handle(
        _equippedByMeta,
        equippedBy.isAcceptableOrUnknown(data['equipped_by']!, _equippedByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RangerEquipmentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RangerEquipmentData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rangerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ranger_id'],
      )!,
      equipmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}equipment_id'],
      )!,
      currentUses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_uses'],
      ),
      equippedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipped_by'],
      )!,
    );
  }

  @override
  $RangerEquipmentTable createAlias(String alias) {
    return $RangerEquipmentTable(attachedDatabase, alias);
  }
}

class RangerEquipmentData extends DataClass
    implements Insertable<RangerEquipmentData> {
  final int id;
  final int rangerId;
  final int equipmentId;
  final int? currentUses;
  final String equippedBy;
  const RangerEquipmentData({
    required this.id,
    required this.rangerId,
    required this.equipmentId,
    this.currentUses,
    required this.equippedBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ranger_id'] = Variable<int>(rangerId);
    map['equipment_id'] = Variable<int>(equipmentId);
    if (!nullToAbsent || currentUses != null) {
      map['current_uses'] = Variable<int>(currentUses);
    }
    map['equipped_by'] = Variable<String>(equippedBy);
    return map;
  }

  RangerEquipmentCompanion toCompanion(bool nullToAbsent) {
    return RangerEquipmentCompanion(
      id: Value(id),
      rangerId: Value(rangerId),
      equipmentId: Value(equipmentId),
      currentUses: currentUses == null && nullToAbsent
          ? const Value.absent()
          : Value(currentUses),
      equippedBy: Value(equippedBy),
    );
  }

  factory RangerEquipmentData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RangerEquipmentData(
      id: serializer.fromJson<int>(json['id']),
      rangerId: serializer.fromJson<int>(json['rangerId']),
      equipmentId: serializer.fromJson<int>(json['equipmentId']),
      currentUses: serializer.fromJson<int?>(json['currentUses']),
      equippedBy: serializer.fromJson<String>(json['equippedBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rangerId': serializer.toJson<int>(rangerId),
      'equipmentId': serializer.toJson<int>(equipmentId),
      'currentUses': serializer.toJson<int?>(currentUses),
      'equippedBy': serializer.toJson<String>(equippedBy),
    };
  }

  RangerEquipmentData copyWith({
    int? id,
    int? rangerId,
    int? equipmentId,
    Value<int?> currentUses = const Value.absent(),
    String? equippedBy,
  }) => RangerEquipmentData(
    id: id ?? this.id,
    rangerId: rangerId ?? this.rangerId,
    equipmentId: equipmentId ?? this.equipmentId,
    currentUses: currentUses.present ? currentUses.value : this.currentUses,
    equippedBy: equippedBy ?? this.equippedBy,
  );
  RangerEquipmentData copyWithCompanion(RangerEquipmentCompanion data) {
    return RangerEquipmentData(
      id: data.id.present ? data.id.value : this.id,
      rangerId: data.rangerId.present ? data.rangerId.value : this.rangerId,
      equipmentId: data.equipmentId.present
          ? data.equipmentId.value
          : this.equipmentId,
      currentUses: data.currentUses.present
          ? data.currentUses.value
          : this.currentUses,
      equippedBy: data.equippedBy.present
          ? data.equippedBy.value
          : this.equippedBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RangerEquipmentData(')
          ..write('id: $id, ')
          ..write('rangerId: $rangerId, ')
          ..write('equipmentId: $equipmentId, ')
          ..write('currentUses: $currentUses, ')
          ..write('equippedBy: $equippedBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, rangerId, equipmentId, currentUses, equippedBy);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RangerEquipmentData &&
          other.id == this.id &&
          other.rangerId == this.rangerId &&
          other.equipmentId == this.equipmentId &&
          other.currentUses == this.currentUses &&
          other.equippedBy == this.equippedBy);
}

class RangerEquipmentCompanion extends UpdateCompanion<RangerEquipmentData> {
  final Value<int> id;
  final Value<int> rangerId;
  final Value<int> equipmentId;
  final Value<int?> currentUses;
  final Value<String> equippedBy;
  const RangerEquipmentCompanion({
    this.id = const Value.absent(),
    this.rangerId = const Value.absent(),
    this.equipmentId = const Value.absent(),
    this.currentUses = const Value.absent(),
    this.equippedBy = const Value.absent(),
  });
  RangerEquipmentCompanion.insert({
    this.id = const Value.absent(),
    required int rangerId,
    required int equipmentId,
    this.currentUses = const Value.absent(),
    this.equippedBy = const Value.absent(),
  }) : rangerId = Value(rangerId),
       equipmentId = Value(equipmentId);
  static Insertable<RangerEquipmentData> custom({
    Expression<int>? id,
    Expression<int>? rangerId,
    Expression<int>? equipmentId,
    Expression<int>? currentUses,
    Expression<String>? equippedBy,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rangerId != null) 'ranger_id': rangerId,
      if (equipmentId != null) 'equipment_id': equipmentId,
      if (currentUses != null) 'current_uses': currentUses,
      if (equippedBy != null) 'equipped_by': equippedBy,
    });
  }

  RangerEquipmentCompanion copyWith({
    Value<int>? id,
    Value<int>? rangerId,
    Value<int>? equipmentId,
    Value<int?>? currentUses,
    Value<String>? equippedBy,
  }) {
    return RangerEquipmentCompanion(
      id: id ?? this.id,
      rangerId: rangerId ?? this.rangerId,
      equipmentId: equipmentId ?? this.equipmentId,
      currentUses: currentUses ?? this.currentUses,
      equippedBy: equippedBy ?? this.equippedBy,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rangerId.present) {
      map['ranger_id'] = Variable<int>(rangerId.value);
    }
    if (equipmentId.present) {
      map['equipment_id'] = Variable<int>(equipmentId.value);
    }
    if (currentUses.present) {
      map['current_uses'] = Variable<int>(currentUses.value);
    }
    if (equippedBy.present) {
      map['equipped_by'] = Variable<String>(equippedBy.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RangerEquipmentCompanion(')
          ..write('id: $id, ')
          ..write('rangerId: $rangerId, ')
          ..write('equipmentId: $equipmentId, ')
          ..write('currentUses: $currentUses, ')
          ..write('equippedBy: $equippedBy')
          ..write(')'))
        .toString();
  }
}

class $InjuriesTable extends Injuries with TableInfo<$InjuriesTable, Injury> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InjuriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rangerIdMeta = const VerificationMeta(
    'rangerId',
  );
  @override
  late final GeneratedColumn<int> rangerId = GeneratedColumn<int>(
    'ranger_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rangers (id)',
    ),
  );
  static const VerificationMeta _companionIdMeta = const VerificationMeta(
    'companionId',
  );
  @override
  late final GeneratedColumn<int> companionId = GeneratedColumn<int>(
    'companion_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ranger_companions (id)',
    ),
  );
  static const VerificationMeta _injuryKeyMeta = const VerificationMeta(
    'injuryKey',
  );
  @override
  late final GeneratedColumn<String> injuryKey = GeneratedColumn<String>(
    'injury_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timesReceivedMeta = const VerificationMeta(
    'timesReceived',
  );
  @override
  late final GeneratedColumn<int> timesReceived = GeneratedColumn<int>(
    'times_received',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rangerId,
    companionId,
    injuryKey,
    timesReceived,
    receivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'injuries';
  @override
  VerificationContext validateIntegrity(
    Insertable<Injury> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ranger_id')) {
      context.handle(
        _rangerIdMeta,
        rangerId.isAcceptableOrUnknown(data['ranger_id']!, _rangerIdMeta),
      );
    }
    if (data.containsKey('companion_id')) {
      context.handle(
        _companionIdMeta,
        companionId.isAcceptableOrUnknown(
          data['companion_id']!,
          _companionIdMeta,
        ),
      );
    }
    if (data.containsKey('injury_key')) {
      context.handle(
        _injuryKeyMeta,
        injuryKey.isAcceptableOrUnknown(data['injury_key']!, _injuryKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_injuryKeyMeta);
    }
    if (data.containsKey('times_received')) {
      context.handle(
        _timesReceivedMeta,
        timesReceived.isAcceptableOrUnknown(
          data['times_received']!,
          _timesReceivedMeta,
        ),
      );
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Injury map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Injury(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rangerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ranger_id'],
      ),
      companionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}companion_id'],
      ),
      injuryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}injury_key'],
      )!,
      timesReceived: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}times_received'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
    );
  }

  @override
  $InjuriesTable createAlias(String alias) {
    return $InjuriesTable(attachedDatabase, alias);
  }
}

class Injury extends DataClass implements Insertable<Injury> {
  final int id;
  final int? rangerId;
  final int? companionId;
  final String injuryKey;
  final int timesReceived;
  final DateTime receivedAt;
  const Injury({
    required this.id,
    this.rangerId,
    this.companionId,
    required this.injuryKey,
    required this.timesReceived,
    required this.receivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || rangerId != null) {
      map['ranger_id'] = Variable<int>(rangerId);
    }
    if (!nullToAbsent || companionId != null) {
      map['companion_id'] = Variable<int>(companionId);
    }
    map['injury_key'] = Variable<String>(injuryKey);
    map['times_received'] = Variable<int>(timesReceived);
    map['received_at'] = Variable<DateTime>(receivedAt);
    return map;
  }

  InjuriesCompanion toCompanion(bool nullToAbsent) {
    return InjuriesCompanion(
      id: Value(id),
      rangerId: rangerId == null && nullToAbsent
          ? const Value.absent()
          : Value(rangerId),
      companionId: companionId == null && nullToAbsent
          ? const Value.absent()
          : Value(companionId),
      injuryKey: Value(injuryKey),
      timesReceived: Value(timesReceived),
      receivedAt: Value(receivedAt),
    );
  }

  factory Injury.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Injury(
      id: serializer.fromJson<int>(json['id']),
      rangerId: serializer.fromJson<int?>(json['rangerId']),
      companionId: serializer.fromJson<int?>(json['companionId']),
      injuryKey: serializer.fromJson<String>(json['injuryKey']),
      timesReceived: serializer.fromJson<int>(json['timesReceived']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rangerId': serializer.toJson<int?>(rangerId),
      'companionId': serializer.toJson<int?>(companionId),
      'injuryKey': serializer.toJson<String>(injuryKey),
      'timesReceived': serializer.toJson<int>(timesReceived),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
    };
  }

  Injury copyWith({
    int? id,
    Value<int?> rangerId = const Value.absent(),
    Value<int?> companionId = const Value.absent(),
    String? injuryKey,
    int? timesReceived,
    DateTime? receivedAt,
  }) => Injury(
    id: id ?? this.id,
    rangerId: rangerId.present ? rangerId.value : this.rangerId,
    companionId: companionId.present ? companionId.value : this.companionId,
    injuryKey: injuryKey ?? this.injuryKey,
    timesReceived: timesReceived ?? this.timesReceived,
    receivedAt: receivedAt ?? this.receivedAt,
  );
  Injury copyWithCompanion(InjuriesCompanion data) {
    return Injury(
      id: data.id.present ? data.id.value : this.id,
      rangerId: data.rangerId.present ? data.rangerId.value : this.rangerId,
      companionId: data.companionId.present
          ? data.companionId.value
          : this.companionId,
      injuryKey: data.injuryKey.present ? data.injuryKey.value : this.injuryKey,
      timesReceived: data.timesReceived.present
          ? data.timesReceived.value
          : this.timesReceived,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Injury(')
          ..write('id: $id, ')
          ..write('rangerId: $rangerId, ')
          ..write('companionId: $companionId, ')
          ..write('injuryKey: $injuryKey, ')
          ..write('timesReceived: $timesReceived, ')
          ..write('receivedAt: $receivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rangerId,
    companionId,
    injuryKey,
    timesReceived,
    receivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Injury &&
          other.id == this.id &&
          other.rangerId == this.rangerId &&
          other.companionId == this.companionId &&
          other.injuryKey == this.injuryKey &&
          other.timesReceived == this.timesReceived &&
          other.receivedAt == this.receivedAt);
}

class InjuriesCompanion extends UpdateCompanion<Injury> {
  final Value<int> id;
  final Value<int?> rangerId;
  final Value<int?> companionId;
  final Value<String> injuryKey;
  final Value<int> timesReceived;
  final Value<DateTime> receivedAt;
  const InjuriesCompanion({
    this.id = const Value.absent(),
    this.rangerId = const Value.absent(),
    this.companionId = const Value.absent(),
    this.injuryKey = const Value.absent(),
    this.timesReceived = const Value.absent(),
    this.receivedAt = const Value.absent(),
  });
  InjuriesCompanion.insert({
    this.id = const Value.absent(),
    this.rangerId = const Value.absent(),
    this.companionId = const Value.absent(),
    required String injuryKey,
    this.timesReceived = const Value.absent(),
    required DateTime receivedAt,
  }) : injuryKey = Value(injuryKey),
       receivedAt = Value(receivedAt);
  static Insertable<Injury> custom({
    Expression<int>? id,
    Expression<int>? rangerId,
    Expression<int>? companionId,
    Expression<String>? injuryKey,
    Expression<int>? timesReceived,
    Expression<DateTime>? receivedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rangerId != null) 'ranger_id': rangerId,
      if (companionId != null) 'companion_id': companionId,
      if (injuryKey != null) 'injury_key': injuryKey,
      if (timesReceived != null) 'times_received': timesReceived,
      if (receivedAt != null) 'received_at': receivedAt,
    });
  }

  InjuriesCompanion copyWith({
    Value<int>? id,
    Value<int?>? rangerId,
    Value<int?>? companionId,
    Value<String>? injuryKey,
    Value<int>? timesReceived,
    Value<DateTime>? receivedAt,
  }) {
    return InjuriesCompanion(
      id: id ?? this.id,
      rangerId: rangerId ?? this.rangerId,
      companionId: companionId ?? this.companionId,
      injuryKey: injuryKey ?? this.injuryKey,
      timesReceived: timesReceived ?? this.timesReceived,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rangerId.present) {
      map['ranger_id'] = Variable<int>(rangerId.value);
    }
    if (companionId.present) {
      map['companion_id'] = Variable<int>(companionId.value);
    }
    if (injuryKey.present) {
      map['injury_key'] = Variable<String>(injuryKey.value);
    }
    if (timesReceived.present) {
      map['times_received'] = Variable<int>(timesReceived.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InjuriesCompanion(')
          ..write('id: $id, ')
          ..write('rangerId: $rangerId, ')
          ..write('companionId: $companionId, ')
          ..write('injuryKey: $injuryKey, ')
          ..write('timesReceived: $timesReceived, ')
          ..write('receivedAt: $receivedAt')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rangerIdMeta = const VerificationMeta(
    'rangerId',
  );
  @override
  late final GeneratedColumn<int> rangerId = GeneratedColumn<int>(
    'ranger_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rangers (id)',
    ),
  );
  static const VerificationMeta _scenarioNameMeta = const VerificationMeta(
    'scenarioName',
  );
  @override
  late final GeneratedColumn<String> scenarioName = GeneratedColumn<String>(
    'scenario_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _missionNameMeta = const VerificationMeta(
    'missionName',
  );
  @override
  late final GeneratedColumn<String> missionName = GeneratedColumn<String>(
    'mission_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _datePlayedMeta = const VerificationMeta(
    'datePlayed',
  );
  @override
  late final GeneratedColumn<DateTime> datePlayed = GeneratedColumn<DateTime>(
    'date_played',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _turnsPlayedMeta = const VerificationMeta(
    'turnsPlayed',
  );
  @override
  late final GeneratedColumn<int> turnsPlayed = GeneratedColumn<int>(
    'turns_played',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _experienceEarnedMeta = const VerificationMeta(
    'experienceEarned',
  );
  @override
  late final GeneratedColumn<int> experienceEarned = GeneratedColumn<int>(
    'experience_earned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rangerId,
    scenarioName,
    missionName,
    datePlayed,
    turnsPlayed,
    outcome,
    notes,
    experienceEarned,
    isCompleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ranger_id')) {
      context.handle(
        _rangerIdMeta,
        rangerId.isAcceptableOrUnknown(data['ranger_id']!, _rangerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rangerIdMeta);
    }
    if (data.containsKey('scenario_name')) {
      context.handle(
        _scenarioNameMeta,
        scenarioName.isAcceptableOrUnknown(
          data['scenario_name']!,
          _scenarioNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scenarioNameMeta);
    }
    if (data.containsKey('mission_name')) {
      context.handle(
        _missionNameMeta,
        missionName.isAcceptableOrUnknown(
          data['mission_name']!,
          _missionNameMeta,
        ),
      );
    }
    if (data.containsKey('date_played')) {
      context.handle(
        _datePlayedMeta,
        datePlayed.isAcceptableOrUnknown(data['date_played']!, _datePlayedMeta),
      );
    } else if (isInserting) {
      context.missing(_datePlayedMeta);
    }
    if (data.containsKey('turns_played')) {
      context.handle(
        _turnsPlayedMeta,
        turnsPlayed.isAcceptableOrUnknown(
          data['turns_played']!,
          _turnsPlayedMeta,
        ),
      );
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('experience_earned')) {
      context.handle(
        _experienceEarnedMeta,
        experienceEarned.isAcceptableOrUnknown(
          data['experience_earned']!,
          _experienceEarnedMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rangerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ranger_id'],
      )!,
      scenarioName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scenario_name'],
      )!,
      missionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mission_name'],
      )!,
      datePlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_played'],
      )!,
      turnsPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}turns_played'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      experienceEarned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}experience_earned'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final int rangerId;
  final String scenarioName;
  final String missionName;
  final DateTime datePlayed;
  final int turnsPlayed;
  final String outcome;
  final String notes;
  final int experienceEarned;
  final bool isCompleted;
  const Session({
    required this.id,
    required this.rangerId,
    required this.scenarioName,
    required this.missionName,
    required this.datePlayed,
    required this.turnsPlayed,
    required this.outcome,
    required this.notes,
    required this.experienceEarned,
    required this.isCompleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ranger_id'] = Variable<int>(rangerId);
    map['scenario_name'] = Variable<String>(scenarioName);
    map['mission_name'] = Variable<String>(missionName);
    map['date_played'] = Variable<DateTime>(datePlayed);
    map['turns_played'] = Variable<int>(turnsPlayed);
    map['outcome'] = Variable<String>(outcome);
    map['notes'] = Variable<String>(notes);
    map['experience_earned'] = Variable<int>(experienceEarned);
    map['is_completed'] = Variable<bool>(isCompleted);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      rangerId: Value(rangerId),
      scenarioName: Value(scenarioName),
      missionName: Value(missionName),
      datePlayed: Value(datePlayed),
      turnsPlayed: Value(turnsPlayed),
      outcome: Value(outcome),
      notes: Value(notes),
      experienceEarned: Value(experienceEarned),
      isCompleted: Value(isCompleted),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      rangerId: serializer.fromJson<int>(json['rangerId']),
      scenarioName: serializer.fromJson<String>(json['scenarioName']),
      missionName: serializer.fromJson<String>(json['missionName']),
      datePlayed: serializer.fromJson<DateTime>(json['datePlayed']),
      turnsPlayed: serializer.fromJson<int>(json['turnsPlayed']),
      outcome: serializer.fromJson<String>(json['outcome']),
      notes: serializer.fromJson<String>(json['notes']),
      experienceEarned: serializer.fromJson<int>(json['experienceEarned']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rangerId': serializer.toJson<int>(rangerId),
      'scenarioName': serializer.toJson<String>(scenarioName),
      'missionName': serializer.toJson<String>(missionName),
      'datePlayed': serializer.toJson<DateTime>(datePlayed),
      'turnsPlayed': serializer.toJson<int>(turnsPlayed),
      'outcome': serializer.toJson<String>(outcome),
      'notes': serializer.toJson<String>(notes),
      'experienceEarned': serializer.toJson<int>(experienceEarned),
      'isCompleted': serializer.toJson<bool>(isCompleted),
    };
  }

  Session copyWith({
    int? id,
    int? rangerId,
    String? scenarioName,
    String? missionName,
    DateTime? datePlayed,
    int? turnsPlayed,
    String? outcome,
    String? notes,
    int? experienceEarned,
    bool? isCompleted,
  }) => Session(
    id: id ?? this.id,
    rangerId: rangerId ?? this.rangerId,
    scenarioName: scenarioName ?? this.scenarioName,
    missionName: missionName ?? this.missionName,
    datePlayed: datePlayed ?? this.datePlayed,
    turnsPlayed: turnsPlayed ?? this.turnsPlayed,
    outcome: outcome ?? this.outcome,
    notes: notes ?? this.notes,
    experienceEarned: experienceEarned ?? this.experienceEarned,
    isCompleted: isCompleted ?? this.isCompleted,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      rangerId: data.rangerId.present ? data.rangerId.value : this.rangerId,
      scenarioName: data.scenarioName.present
          ? data.scenarioName.value
          : this.scenarioName,
      missionName: data.missionName.present
          ? data.missionName.value
          : this.missionName,
      datePlayed: data.datePlayed.present
          ? data.datePlayed.value
          : this.datePlayed,
      turnsPlayed: data.turnsPlayed.present
          ? data.turnsPlayed.value
          : this.turnsPlayed,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      notes: data.notes.present ? data.notes.value : this.notes,
      experienceEarned: data.experienceEarned.present
          ? data.experienceEarned.value
          : this.experienceEarned,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('rangerId: $rangerId, ')
          ..write('scenarioName: $scenarioName, ')
          ..write('missionName: $missionName, ')
          ..write('datePlayed: $datePlayed, ')
          ..write('turnsPlayed: $turnsPlayed, ')
          ..write('outcome: $outcome, ')
          ..write('notes: $notes, ')
          ..write('experienceEarned: $experienceEarned, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rangerId,
    scenarioName,
    missionName,
    datePlayed,
    turnsPlayed,
    outcome,
    notes,
    experienceEarned,
    isCompleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.rangerId == this.rangerId &&
          other.scenarioName == this.scenarioName &&
          other.missionName == this.missionName &&
          other.datePlayed == this.datePlayed &&
          other.turnsPlayed == this.turnsPlayed &&
          other.outcome == this.outcome &&
          other.notes == this.notes &&
          other.experienceEarned == this.experienceEarned &&
          other.isCompleted == this.isCompleted);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<int> rangerId;
  final Value<String> scenarioName;
  final Value<String> missionName;
  final Value<DateTime> datePlayed;
  final Value<int> turnsPlayed;
  final Value<String> outcome;
  final Value<String> notes;
  final Value<int> experienceEarned;
  final Value<bool> isCompleted;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.rangerId = const Value.absent(),
    this.scenarioName = const Value.absent(),
    this.missionName = const Value.absent(),
    this.datePlayed = const Value.absent(),
    this.turnsPlayed = const Value.absent(),
    this.outcome = const Value.absent(),
    this.notes = const Value.absent(),
    this.experienceEarned = const Value.absent(),
    this.isCompleted = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required int rangerId,
    required String scenarioName,
    this.missionName = const Value.absent(),
    required DateTime datePlayed,
    this.turnsPlayed = const Value.absent(),
    this.outcome = const Value.absent(),
    this.notes = const Value.absent(),
    this.experienceEarned = const Value.absent(),
    this.isCompleted = const Value.absent(),
  }) : rangerId = Value(rangerId),
       scenarioName = Value(scenarioName),
       datePlayed = Value(datePlayed);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<int>? rangerId,
    Expression<String>? scenarioName,
    Expression<String>? missionName,
    Expression<DateTime>? datePlayed,
    Expression<int>? turnsPlayed,
    Expression<String>? outcome,
    Expression<String>? notes,
    Expression<int>? experienceEarned,
    Expression<bool>? isCompleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rangerId != null) 'ranger_id': rangerId,
      if (scenarioName != null) 'scenario_name': scenarioName,
      if (missionName != null) 'mission_name': missionName,
      if (datePlayed != null) 'date_played': datePlayed,
      if (turnsPlayed != null) 'turns_played': turnsPlayed,
      if (outcome != null) 'outcome': outcome,
      if (notes != null) 'notes': notes,
      if (experienceEarned != null) 'experience_earned': experienceEarned,
      if (isCompleted != null) 'is_completed': isCompleted,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? rangerId,
    Value<String>? scenarioName,
    Value<String>? missionName,
    Value<DateTime>? datePlayed,
    Value<int>? turnsPlayed,
    Value<String>? outcome,
    Value<String>? notes,
    Value<int>? experienceEarned,
    Value<bool>? isCompleted,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      rangerId: rangerId ?? this.rangerId,
      scenarioName: scenarioName ?? this.scenarioName,
      missionName: missionName ?? this.missionName,
      datePlayed: datePlayed ?? this.datePlayed,
      turnsPlayed: turnsPlayed ?? this.turnsPlayed,
      outcome: outcome ?? this.outcome,
      notes: notes ?? this.notes,
      experienceEarned: experienceEarned ?? this.experienceEarned,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rangerId.present) {
      map['ranger_id'] = Variable<int>(rangerId.value);
    }
    if (scenarioName.present) {
      map['scenario_name'] = Variable<String>(scenarioName.value);
    }
    if (missionName.present) {
      map['mission_name'] = Variable<String>(missionName.value);
    }
    if (datePlayed.present) {
      map['date_played'] = Variable<DateTime>(datePlayed.value);
    }
    if (turnsPlayed.present) {
      map['turns_played'] = Variable<int>(turnsPlayed.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (experienceEarned.present) {
      map['experience_earned'] = Variable<int>(experienceEarned.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('rangerId: $rangerId, ')
          ..write('scenarioName: $scenarioName, ')
          ..write('missionName: $missionName, ')
          ..write('datePlayed: $datePlayed, ')
          ..write('turnsPlayed: $turnsPlayed, ')
          ..write('outcome: $outcome, ')
          ..write('notes: $notes, ')
          ..write('experienceEarned: $experienceEarned, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }
}

class $SessionEventsTable extends SessionEvents
    with TableInfo<$SessionEventsTable, SessionEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _turnNumberMeta = const VerificationMeta(
    'turnNumber',
  );
  @override
  late final GeneratedColumn<int> turnNumber = GeneratedColumn<int>(
    'turn_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<String> phase = GeneratedColumn<String>(
    'phase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _figureNameMeta = const VerificationMeta(
    'figureName',
  );
  @override
  late final GeneratedColumn<String> figureName = GeneratedColumn<String>(
    'figure_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    turnNumber,
    phase,
    eventType,
    description,
    figureName,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('turn_number')) {
      context.handle(
        _turnNumberMeta,
        turnNumber.isAcceptableOrUnknown(data['turn_number']!, _turnNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_turnNumberMeta);
    }
    if (data.containsKey('phase')) {
      context.handle(
        _phaseMeta,
        phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta),
      );
    } else if (isInserting) {
      context.missing(_phaseMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('figure_name')) {
      context.handle(
        _figureNameMeta,
        figureName.isAcceptableOrUnknown(data['figure_name']!, _figureNameMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      turnNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}turn_number'],
      )!,
      phase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phase'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      figureName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}figure_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SessionEventsTable createAlias(String alias) {
    return $SessionEventsTable(attachedDatabase, alias);
  }
}

class SessionEvent extends DataClass implements Insertable<SessionEvent> {
  final int id;
  final int sessionId;
  final int turnNumber;
  final String phase;
  final String eventType;
  final String description;
  final String figureName;
  final DateTime createdAt;
  const SessionEvent({
    required this.id,
    required this.sessionId,
    required this.turnNumber,
    required this.phase,
    required this.eventType,
    required this.description,
    required this.figureName,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['turn_number'] = Variable<int>(turnNumber);
    map['phase'] = Variable<String>(phase);
    map['event_type'] = Variable<String>(eventType);
    map['description'] = Variable<String>(description);
    map['figure_name'] = Variable<String>(figureName);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SessionEventsCompanion toCompanion(bool nullToAbsent) {
    return SessionEventsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      turnNumber: Value(turnNumber),
      phase: Value(phase),
      eventType: Value(eventType),
      description: Value(description),
      figureName: Value(figureName),
      createdAt: Value(createdAt),
    );
  }

  factory SessionEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionEvent(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      turnNumber: serializer.fromJson<int>(json['turnNumber']),
      phase: serializer.fromJson<String>(json['phase']),
      eventType: serializer.fromJson<String>(json['eventType']),
      description: serializer.fromJson<String>(json['description']),
      figureName: serializer.fromJson<String>(json['figureName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'turnNumber': serializer.toJson<int>(turnNumber),
      'phase': serializer.toJson<String>(phase),
      'eventType': serializer.toJson<String>(eventType),
      'description': serializer.toJson<String>(description),
      'figureName': serializer.toJson<String>(figureName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SessionEvent copyWith({
    int? id,
    int? sessionId,
    int? turnNumber,
    String? phase,
    String? eventType,
    String? description,
    String? figureName,
    DateTime? createdAt,
  }) => SessionEvent(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    turnNumber: turnNumber ?? this.turnNumber,
    phase: phase ?? this.phase,
    eventType: eventType ?? this.eventType,
    description: description ?? this.description,
    figureName: figureName ?? this.figureName,
    createdAt: createdAt ?? this.createdAt,
  );
  SessionEvent copyWithCompanion(SessionEventsCompanion data) {
    return SessionEvent(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      turnNumber: data.turnNumber.present
          ? data.turnNumber.value
          : this.turnNumber,
      phase: data.phase.present ? data.phase.value : this.phase,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      description: data.description.present
          ? data.description.value
          : this.description,
      figureName: data.figureName.present
          ? data.figureName.value
          : this.figureName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionEvent(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('turnNumber: $turnNumber, ')
          ..write('phase: $phase, ')
          ..write('eventType: $eventType, ')
          ..write('description: $description, ')
          ..write('figureName: $figureName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    turnNumber,
    phase,
    eventType,
    description,
    figureName,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionEvent &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.turnNumber == this.turnNumber &&
          other.phase == this.phase &&
          other.eventType == this.eventType &&
          other.description == this.description &&
          other.figureName == this.figureName &&
          other.createdAt == this.createdAt);
}

class SessionEventsCompanion extends UpdateCompanion<SessionEvent> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> turnNumber;
  final Value<String> phase;
  final Value<String> eventType;
  final Value<String> description;
  final Value<String> figureName;
  final Value<DateTime> createdAt;
  const SessionEventsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.turnNumber = const Value.absent(),
    this.phase = const Value.absent(),
    this.eventType = const Value.absent(),
    this.description = const Value.absent(),
    this.figureName = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SessionEventsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int turnNumber,
    required String phase,
    required String eventType,
    this.description = const Value.absent(),
    this.figureName = const Value.absent(),
    required DateTime createdAt,
  }) : sessionId = Value(sessionId),
       turnNumber = Value(turnNumber),
       phase = Value(phase),
       eventType = Value(eventType),
       createdAt = Value(createdAt);
  static Insertable<SessionEvent> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? turnNumber,
    Expression<String>? phase,
    Expression<String>? eventType,
    Expression<String>? description,
    Expression<String>? figureName,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (turnNumber != null) 'turn_number': turnNumber,
      if (phase != null) 'phase': phase,
      if (eventType != null) 'event_type': eventType,
      if (description != null) 'description': description,
      if (figureName != null) 'figure_name': figureName,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SessionEventsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? turnNumber,
    Value<String>? phase,
    Value<String>? eventType,
    Value<String>? description,
    Value<String>? figureName,
    Value<DateTime>? createdAt,
  }) {
    return SessionEventsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      turnNumber: turnNumber ?? this.turnNumber,
      phase: phase ?? this.phase,
      eventType: eventType ?? this.eventType,
      description: description ?? this.description,
      figureName: figureName ?? this.figureName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (turnNumber.present) {
      map['turn_number'] = Variable<int>(turnNumber.value);
    }
    if (phase.present) {
      map['phase'] = Variable<String>(phase.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (figureName.present) {
      map['figure_name'] = Variable<String>(figureName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionEventsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('turnNumber: $turnNumber, ')
          ..write('phase: $phase, ')
          ..write('eventType: $eventType, ')
          ..write('description: $description, ')
          ..write('figureName: $figureName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RangersTable rangers = $RangersTable(this);
  late final $RangerAbilitiesTable rangerAbilities = $RangerAbilitiesTable(
    this,
  );
  late final $RangerSkillsTable rangerSkills = $RangerSkillsTable(this);
  late final $CompanionTypesTable companionTypes = $CompanionTypesTable(this);
  late final $RangerCompanionsTable rangerCompanions = $RangerCompanionsTable(
    this,
  );
  late final $EquipmentTable equipment = $EquipmentTable(this);
  late final $RangerEquipmentTable rangerEquipment = $RangerEquipmentTable(
    this,
  );
  late final $InjuriesTable injuries = $InjuriesTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $SessionEventsTable sessionEvents = $SessionEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    rangers,
    rangerAbilities,
    rangerSkills,
    companionTypes,
    rangerCompanions,
    equipment,
    rangerEquipment,
    injuries,
    sessions,
    sessionEvents,
  ];
}

typedef $$RangersTableCreateCompanionBuilder =
    RangersCompanion Function({
      Value<int> id,
      required String name,
      Value<int> level,
      Value<int> experiencePoints,
      Value<int> baseRecruitmentPoints,
      required int move,
      required int fight,
      required int shoot,
      required int armour,
      required int will,
      required int health,
      required int currentHealth,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> notes,
    });
typedef $$RangersTableUpdateCompanionBuilder =
    RangersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> level,
      Value<int> experiencePoints,
      Value<int> baseRecruitmentPoints,
      Value<int> move,
      Value<int> fight,
      Value<int> shoot,
      Value<int> armour,
      Value<int> will,
      Value<int> health,
      Value<int> currentHealth,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> notes,
    });

final class $$RangersTableReferences
    extends BaseReferences<_$AppDatabase, $RangersTable, Ranger> {
  $$RangersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RangerAbilitiesTable, List<RangerAbility>>
  _rangerAbilitiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.rangerAbilities,
    aliasName: $_aliasNameGenerator(db.rangers.id, db.rangerAbilities.rangerId),
  );

  $$RangerAbilitiesTableProcessedTableManager get rangerAbilitiesRefs {
    final manager = $$RangerAbilitiesTableTableManager(
      $_db,
      $_db.rangerAbilities,
    ).filter((f) => f.rangerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _rangerAbilitiesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RangerSkillsTable, List<RangerSkill>>
  _rangerSkillsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.rangerSkills,
    aliasName: $_aliasNameGenerator(db.rangers.id, db.rangerSkills.rangerId),
  );

  $$RangerSkillsTableProcessedTableManager get rangerSkillsRefs {
    final manager = $$RangerSkillsTableTableManager(
      $_db,
      $_db.rangerSkills,
    ).filter((f) => f.rangerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_rangerSkillsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RangerCompanionsTable, List<RangerCompanion>>
  _rangerCompanionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.rangerCompanions,
    aliasName: $_aliasNameGenerator(
      db.rangers.id,
      db.rangerCompanions.rangerId,
    ),
  );

  $$RangerCompanionsTableProcessedTableManager get rangerCompanionsRefs {
    final manager = $$RangerCompanionsTableTableManager(
      $_db,
      $_db.rangerCompanions,
    ).filter((f) => f.rangerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _rangerCompanionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RangerEquipmentTable, List<RangerEquipmentData>>
  _rangerEquipmentRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.rangerEquipment,
    aliasName: $_aliasNameGenerator(db.rangers.id, db.rangerEquipment.rangerId),
  );

  $$RangerEquipmentTableProcessedTableManager get rangerEquipmentRefs {
    final manager = $$RangerEquipmentTableTableManager(
      $_db,
      $_db.rangerEquipment,
    ).filter((f) => f.rangerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _rangerEquipmentRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InjuriesTable, List<Injury>> _injuriesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.injuries,
    aliasName: $_aliasNameGenerator(db.rangers.id, db.injuries.rangerId),
  );

  $$InjuriesTableProcessedTableManager get injuriesRefs {
    final manager = $$InjuriesTableTableManager(
      $_db,
      $_db.injuries,
    ).filter((f) => f.rangerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_injuriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: $_aliasNameGenerator(db.rangers.id, db.sessions.rangerId),
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.rangerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RangersTableFilterComposer
    extends Composer<_$AppDatabase, $RangersTable> {
  $$RangersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get experiencePoints => $composableBuilder(
    column: $table.experiencePoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseRecruitmentPoints => $composableBuilder(
    column: $table.baseRecruitmentPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get move => $composableBuilder(
    column: $table.move,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fight => $composableBuilder(
    column: $table.fight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shoot => $composableBuilder(
    column: $table.shoot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get armour => $composableBuilder(
    column: $table.armour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get will => $composableBuilder(
    column: $table.will,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get health => $composableBuilder(
    column: $table.health,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentHealth => $composableBuilder(
    column: $table.currentHealth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> rangerAbilitiesRefs(
    Expression<bool> Function($$RangerAbilitiesTableFilterComposer f) f,
  ) {
    final $$RangerAbilitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rangerAbilities,
      getReferencedColumn: (t) => t.rangerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangerAbilitiesTableFilterComposer(
            $db: $db,
            $table: $db.rangerAbilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> rangerSkillsRefs(
    Expression<bool> Function($$RangerSkillsTableFilterComposer f) f,
  ) {
    final $$RangerSkillsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rangerSkills,
      getReferencedColumn: (t) => t.rangerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangerSkillsTableFilterComposer(
            $db: $db,
            $table: $db.rangerSkills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> rangerCompanionsRefs(
    Expression<bool> Function($$RangerCompanionsTableFilterComposer f) f,
  ) {
    final $$RangerCompanionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rangerCompanions,
      getReferencedColumn: (t) => t.rangerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangerCompanionsTableFilterComposer(
            $db: $db,
            $table: $db.rangerCompanions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> rangerEquipmentRefs(
    Expression<bool> Function($$RangerEquipmentTableFilterComposer f) f,
  ) {
    final $$RangerEquipmentTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rangerEquipment,
      getReferencedColumn: (t) => t.rangerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangerEquipmentTableFilterComposer(
            $db: $db,
            $table: $db.rangerEquipment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> injuriesRefs(
    Expression<bool> Function($$InjuriesTableFilterComposer f) f,
  ) {
    final $$InjuriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.injuries,
      getReferencedColumn: (t) => t.rangerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InjuriesTableFilterComposer(
            $db: $db,
            $table: $db.injuries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.rangerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RangersTableOrderingComposer
    extends Composer<_$AppDatabase, $RangersTable> {
  $$RangersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get experiencePoints => $composableBuilder(
    column: $table.experiencePoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseRecruitmentPoints => $composableBuilder(
    column: $table.baseRecruitmentPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get move => $composableBuilder(
    column: $table.move,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fight => $composableBuilder(
    column: $table.fight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shoot => $composableBuilder(
    column: $table.shoot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get armour => $composableBuilder(
    column: $table.armour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get will => $composableBuilder(
    column: $table.will,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get health => $composableBuilder(
    column: $table.health,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentHealth => $composableBuilder(
    column: $table.currentHealth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RangersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RangersTable> {
  $$RangersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get experiencePoints => $composableBuilder(
    column: $table.experiencePoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baseRecruitmentPoints => $composableBuilder(
    column: $table.baseRecruitmentPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get move =>
      $composableBuilder(column: $table.move, builder: (column) => column);

  GeneratedColumn<int> get fight =>
      $composableBuilder(column: $table.fight, builder: (column) => column);

  GeneratedColumn<int> get shoot =>
      $composableBuilder(column: $table.shoot, builder: (column) => column);

  GeneratedColumn<int> get armour =>
      $composableBuilder(column: $table.armour, builder: (column) => column);

  GeneratedColumn<int> get will =>
      $composableBuilder(column: $table.will, builder: (column) => column);

  GeneratedColumn<int> get health =>
      $composableBuilder(column: $table.health, builder: (column) => column);

  GeneratedColumn<int> get currentHealth => $composableBuilder(
    column: $table.currentHealth,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> rangerAbilitiesRefs<T extends Object>(
    Expression<T> Function($$RangerAbilitiesTableAnnotationComposer a) f,
  ) {
    final $$RangerAbilitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rangerAbilities,
      getReferencedColumn: (t) => t.rangerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangerAbilitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.rangerAbilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> rangerSkillsRefs<T extends Object>(
    Expression<T> Function($$RangerSkillsTableAnnotationComposer a) f,
  ) {
    final $$RangerSkillsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rangerSkills,
      getReferencedColumn: (t) => t.rangerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangerSkillsTableAnnotationComposer(
            $db: $db,
            $table: $db.rangerSkills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> rangerCompanionsRefs<T extends Object>(
    Expression<T> Function($$RangerCompanionsTableAnnotationComposer a) f,
  ) {
    final $$RangerCompanionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rangerCompanions,
      getReferencedColumn: (t) => t.rangerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangerCompanionsTableAnnotationComposer(
            $db: $db,
            $table: $db.rangerCompanions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> rangerEquipmentRefs<T extends Object>(
    Expression<T> Function($$RangerEquipmentTableAnnotationComposer a) f,
  ) {
    final $$RangerEquipmentTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rangerEquipment,
      getReferencedColumn: (t) => t.rangerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangerEquipmentTableAnnotationComposer(
            $db: $db,
            $table: $db.rangerEquipment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> injuriesRefs<T extends Object>(
    Expression<T> Function($$InjuriesTableAnnotationComposer a) f,
  ) {
    final $$InjuriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.injuries,
      getReferencedColumn: (t) => t.rangerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InjuriesTableAnnotationComposer(
            $db: $db,
            $table: $db.injuries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.rangerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RangersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RangersTable,
          Ranger,
          $$RangersTableFilterComposer,
          $$RangersTableOrderingComposer,
          $$RangersTableAnnotationComposer,
          $$RangersTableCreateCompanionBuilder,
          $$RangersTableUpdateCompanionBuilder,
          (Ranger, $$RangersTableReferences),
          Ranger,
          PrefetchHooks Function({
            bool rangerAbilitiesRefs,
            bool rangerSkillsRefs,
            bool rangerCompanionsRefs,
            bool rangerEquipmentRefs,
            bool injuriesRefs,
            bool sessionsRefs,
          })
        > {
  $$RangersTableTableManager(_$AppDatabase db, $RangersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RangersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RangersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RangersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> experiencePoints = const Value.absent(),
                Value<int> baseRecruitmentPoints = const Value.absent(),
                Value<int> move = const Value.absent(),
                Value<int> fight = const Value.absent(),
                Value<int> shoot = const Value.absent(),
                Value<int> armour = const Value.absent(),
                Value<int> will = const Value.absent(),
                Value<int> health = const Value.absent(),
                Value<int> currentHealth = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => RangersCompanion(
                id: id,
                name: name,
                level: level,
                experiencePoints: experiencePoints,
                baseRecruitmentPoints: baseRecruitmentPoints,
                move: move,
                fight: fight,
                shoot: shoot,
                armour: armour,
                will: will,
                health: health,
                currentHealth: currentHealth,
                createdAt: createdAt,
                updatedAt: updatedAt,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> level = const Value.absent(),
                Value<int> experiencePoints = const Value.absent(),
                Value<int> baseRecruitmentPoints = const Value.absent(),
                required int move,
                required int fight,
                required int shoot,
                required int armour,
                required int will,
                required int health,
                required int currentHealth,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> notes = const Value.absent(),
              }) => RangersCompanion.insert(
                id: id,
                name: name,
                level: level,
                experiencePoints: experiencePoints,
                baseRecruitmentPoints: baseRecruitmentPoints,
                move: move,
                fight: fight,
                shoot: shoot,
                armour: armour,
                will: will,
                health: health,
                currentHealth: currentHealth,
                createdAt: createdAt,
                updatedAt: updatedAt,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RangersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                rangerAbilitiesRefs = false,
                rangerSkillsRefs = false,
                rangerCompanionsRefs = false,
                rangerEquipmentRefs = false,
                injuriesRefs = false,
                sessionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (rangerAbilitiesRefs) db.rangerAbilities,
                    if (rangerSkillsRefs) db.rangerSkills,
                    if (rangerCompanionsRefs) db.rangerCompanions,
                    if (rangerEquipmentRefs) db.rangerEquipment,
                    if (injuriesRefs) db.injuries,
                    if (sessionsRefs) db.sessions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (rangerAbilitiesRefs)
                        await $_getPrefetchedData<
                          Ranger,
                          $RangersTable,
                          RangerAbility
                        >(
                          currentTable: table,
                          referencedTable: $$RangersTableReferences
                              ._rangerAbilitiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RangersTableReferences(
                                db,
                                table,
                                p0,
                              ).rangerAbilitiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.rangerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (rangerSkillsRefs)
                        await $_getPrefetchedData<
                          Ranger,
                          $RangersTable,
                          RangerSkill
                        >(
                          currentTable: table,
                          referencedTable: $$RangersTableReferences
                              ._rangerSkillsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RangersTableReferences(
                                db,
                                table,
                                p0,
                              ).rangerSkillsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.rangerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (rangerCompanionsRefs)
                        await $_getPrefetchedData<
                          Ranger,
                          $RangersTable,
                          RangerCompanion
                        >(
                          currentTable: table,
                          referencedTable: $$RangersTableReferences
                              ._rangerCompanionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RangersTableReferences(
                                db,
                                table,
                                p0,
                              ).rangerCompanionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.rangerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (rangerEquipmentRefs)
                        await $_getPrefetchedData<
                          Ranger,
                          $RangersTable,
                          RangerEquipmentData
                        >(
                          currentTable: table,
                          referencedTable: $$RangersTableReferences
                              ._rangerEquipmentRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RangersTableReferences(
                                db,
                                table,
                                p0,
                              ).rangerEquipmentRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.rangerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (injuriesRefs)
                        await $_getPrefetchedData<
                          Ranger,
                          $RangersTable,
                          Injury
                        >(
                          currentTable: table,
                          referencedTable: $$RangersTableReferences
                              ._injuriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RangersTableReferences(
                                db,
                                table,
                                p0,
                              ).injuriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.rangerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sessionsRefs)
                        await $_getPrefetchedData<
                          Ranger,
                          $RangersTable,
                          Session
                        >(
                          currentTable: table,
                          referencedTable: $$RangersTableReferences
                              ._sessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RangersTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.rangerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RangersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RangersTable,
      Ranger,
      $$RangersTableFilterComposer,
      $$RangersTableOrderingComposer,
      $$RangersTableAnnotationComposer,
      $$RangersTableCreateCompanionBuilder,
      $$RangersTableUpdateCompanionBuilder,
      (Ranger, $$RangersTableReferences),
      Ranger,
      PrefetchHooks Function({
        bool rangerAbilitiesRefs,
        bool rangerSkillsRefs,
        bool rangerCompanionsRefs,
        bool rangerEquipmentRefs,
        bool injuriesRefs,
        bool sessionsRefs,
      })
    >;
typedef $$RangerAbilitiesTableCreateCompanionBuilder =
    RangerAbilitiesCompanion Function({
      Value<int> id,
      required int rangerId,
      required String abilityType,
      required String abilityKey,
      Value<bool> isUsedThisScenario,
    });
typedef $$RangerAbilitiesTableUpdateCompanionBuilder =
    RangerAbilitiesCompanion Function({
      Value<int> id,
      Value<int> rangerId,
      Value<String> abilityType,
      Value<String> abilityKey,
      Value<bool> isUsedThisScenario,
    });

final class $$RangerAbilitiesTableReferences
    extends
        BaseReferences<_$AppDatabase, $RangerAbilitiesTable, RangerAbility> {
  $$RangerAbilitiesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RangersTable _rangerIdTable(_$AppDatabase db) =>
      db.rangers.createAlias(
        $_aliasNameGenerator(db.rangerAbilities.rangerId, db.rangers.id),
      );

  $$RangersTableProcessedTableManager get rangerId {
    final $_column = $_itemColumn<int>('ranger_id')!;

    final manager = $$RangersTableTableManager(
      $_db,
      $_db.rangers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rangerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RangerAbilitiesTableFilterComposer
    extends Composer<_$AppDatabase, $RangerAbilitiesTable> {
  $$RangerAbilitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get abilityType => $composableBuilder(
    column: $table.abilityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get abilityKey => $composableBuilder(
    column: $table.abilityKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUsedThisScenario => $composableBuilder(
    column: $table.isUsedThisScenario,
    builder: (column) => ColumnFilters(column),
  );

  $$RangersTableFilterComposer get rangerId {
    final $$RangersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rangerId,
      referencedTable: $db.rangers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangersTableFilterComposer(
            $db: $db,
            $table: $db.rangers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RangerAbilitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $RangerAbilitiesTable> {
  $$RangerAbilitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get abilityType => $composableBuilder(
    column: $table.abilityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get abilityKey => $composableBuilder(
    column: $table.abilityKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUsedThisScenario => $composableBuilder(
    column: $table.isUsedThisScenario,
    builder: (column) => ColumnOrderings(column),
  );

  $$RangersTableOrderingComposer get rangerId {
    final $$RangersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rangerId,
      referencedTable: $db.rangers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangersTableOrderingComposer(
            $db: $db,
            $table: $db.rangers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RangerAbilitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RangerAbilitiesTable> {
  $$RangerAbilitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get abilityType => $composableBuilder(
    column: $table.abilityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get abilityKey => $composableBuilder(
    column: $table.abilityKey,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isUsedThisScenario => $composableBuilder(
    column: $table.isUsedThisScenario,
    builder: (column) => column,
  );

  $$RangersTableAnnotationComposer get rangerId {
    final $$RangersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rangerId,
      referencedTable: $db.rangers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangersTableAnnotationComposer(
            $db: $db,
            $table: $db.rangers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RangerAbilitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RangerAbilitiesTable,
          RangerAbility,
          $$RangerAbilitiesTableFilterComposer,
          $$RangerAbilitiesTableOrderingComposer,
          $$RangerAbilitiesTableAnnotationComposer,
          $$RangerAbilitiesTableCreateCompanionBuilder,
          $$RangerAbilitiesTableUpdateCompanionBuilder,
          (RangerAbility, $$RangerAbilitiesTableReferences),
          RangerAbility,
          PrefetchHooks Function({bool rangerId})
        > {
  $$RangerAbilitiesTableTableManager(
    _$AppDatabase db,
    $RangerAbilitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RangerAbilitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RangerAbilitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RangerAbilitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> rangerId = const Value.absent(),
                Value<String> abilityType = const Value.absent(),
                Value<String> abilityKey = const Value.absent(),
                Value<bool> isUsedThisScenario = const Value.absent(),
              }) => RangerAbilitiesCompanion(
                id: id,
                rangerId: rangerId,
                abilityType: abilityType,
                abilityKey: abilityKey,
                isUsedThisScenario: isUsedThisScenario,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int rangerId,
                required String abilityType,
                required String abilityKey,
                Value<bool> isUsedThisScenario = const Value.absent(),
              }) => RangerAbilitiesCompanion.insert(
                id: id,
                rangerId: rangerId,
                abilityType: abilityType,
                abilityKey: abilityKey,
                isUsedThisScenario: isUsedThisScenario,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RangerAbilitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rangerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (rangerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.rangerId,
                                referencedTable:
                                    $$RangerAbilitiesTableReferences
                                        ._rangerIdTable(db),
                                referencedColumn:
                                    $$RangerAbilitiesTableReferences
                                        ._rangerIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RangerAbilitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RangerAbilitiesTable,
      RangerAbility,
      $$RangerAbilitiesTableFilterComposer,
      $$RangerAbilitiesTableOrderingComposer,
      $$RangerAbilitiesTableAnnotationComposer,
      $$RangerAbilitiesTableCreateCompanionBuilder,
      $$RangerAbilitiesTableUpdateCompanionBuilder,
      (RangerAbility, $$RangerAbilitiesTableReferences),
      RangerAbility,
      PrefetchHooks Function({bool rangerId})
    >;
typedef $$RangerSkillsTableCreateCompanionBuilder =
    RangerSkillsCompanion Function({
      Value<int> id,
      required int rangerId,
      required String skillKey,
      required int value,
    });
typedef $$RangerSkillsTableUpdateCompanionBuilder =
    RangerSkillsCompanion Function({
      Value<int> id,
      Value<int> rangerId,
      Value<String> skillKey,
      Value<int> value,
    });

final class $$RangerSkillsTableReferences
    extends BaseReferences<_$AppDatabase, $RangerSkillsTable, RangerSkill> {
  $$RangerSkillsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RangersTable _rangerIdTable(_$AppDatabase db) =>
      db.rangers.createAlias(
        $_aliasNameGenerator(db.rangerSkills.rangerId, db.rangers.id),
      );

  $$RangersTableProcessedTableManager get rangerId {
    final $_column = $_itemColumn<int>('ranger_id')!;

    final manager = $$RangersTableTableManager(
      $_db,
      $_db.rangers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rangerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RangerSkillsTableFilterComposer
    extends Composer<_$AppDatabase, $RangerSkillsTable> {
  $$RangerSkillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skillKey => $composableBuilder(
    column: $table.skillKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  $$RangersTableFilterComposer get rangerId {
    final $$RangersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rangerId,
      referencedTable: $db.rangers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangersTableFilterComposer(
            $db: $db,
            $table: $db.rangers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RangerSkillsTableOrderingComposer
    extends Composer<_$AppDatabase, $RangerSkillsTable> {
  $$RangerSkillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skillKey => $composableBuilder(
    column: $table.skillKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  $$RangersTableOrderingComposer get rangerId {
    final $$RangersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rangerId,
      referencedTable: $db.rangers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangersTableOrderingComposer(
            $db: $db,
            $table: $db.rangers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RangerSkillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RangerSkillsTable> {
  $$RangerSkillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get skillKey =>
      $composableBuilder(column: $table.skillKey, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  $$RangersTableAnnotationComposer get rangerId {
    final $$RangersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rangerId,
      referencedTable: $db.rangers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangersTableAnnotationComposer(
            $db: $db,
            $table: $db.rangers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RangerSkillsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RangerSkillsTable,
          RangerSkill,
          $$RangerSkillsTableFilterComposer,
          $$RangerSkillsTableOrderingComposer,
          $$RangerSkillsTableAnnotationComposer,
          $$RangerSkillsTableCreateCompanionBuilder,
          $$RangerSkillsTableUpdateCompanionBuilder,
          (RangerSkill, $$RangerSkillsTableReferences),
          RangerSkill,
          PrefetchHooks Function({bool rangerId})
        > {
  $$RangerSkillsTableTableManager(_$AppDatabase db, $RangerSkillsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RangerSkillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RangerSkillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RangerSkillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> rangerId = const Value.absent(),
                Value<String> skillKey = const Value.absent(),
                Value<int> value = const Value.absent(),
              }) => RangerSkillsCompanion(
                id: id,
                rangerId: rangerId,
                skillKey: skillKey,
                value: value,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int rangerId,
                required String skillKey,
                required int value,
              }) => RangerSkillsCompanion.insert(
                id: id,
                rangerId: rangerId,
                skillKey: skillKey,
                value: value,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RangerSkillsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rangerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (rangerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.rangerId,
                                referencedTable: $$RangerSkillsTableReferences
                                    ._rangerIdTable(db),
                                referencedColumn: $$RangerSkillsTableReferences
                                    ._rangerIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RangerSkillsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RangerSkillsTable,
      RangerSkill,
      $$RangerSkillsTableFilterComposer,
      $$RangerSkillsTableOrderingComposer,
      $$RangerSkillsTableAnnotationComposer,
      $$RangerSkillsTableCreateCompanionBuilder,
      $$RangerSkillsTableUpdateCompanionBuilder,
      (RangerSkill, $$RangerSkillsTableReferences),
      RangerSkill,
      PrefetchHooks Function({bool rangerId})
    >;
typedef $$CompanionTypesTableCreateCompanionBuilder =
    CompanionTypesCompanion Function({
      Value<int> id,
      required String typeKey,
      required String name,
      required int rpCost,
      required int move,
      required int fight,
      required int shoot,
      required int armour,
      required int will,
      required int health,
      Value<String> notes,
      Value<bool> isAnimal,
      Value<String> baseSkills,
    });
typedef $$CompanionTypesTableUpdateCompanionBuilder =
    CompanionTypesCompanion Function({
      Value<int> id,
      Value<String> typeKey,
      Value<String> name,
      Value<int> rpCost,
      Value<int> move,
      Value<int> fight,
      Value<int> shoot,
      Value<int> armour,
      Value<int> will,
      Value<int> health,
      Value<String> notes,
      Value<bool> isAnimal,
      Value<String> baseSkills,
    });

final class $$CompanionTypesTableReferences
    extends BaseReferences<_$AppDatabase, $CompanionTypesTable, CompanionType> {
  $$CompanionTypesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$RangerCompanionsTable, List<RangerCompanion>>
  _rangerCompanionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.rangerCompanions,
    aliasName: $_aliasNameGenerator(
      db.companionTypes.id,
      db.rangerCompanions.companionTypeId,
    ),
  );

  $$RangerCompanionsTableProcessedTableManager get rangerCompanionsRefs {
    final manager = $$RangerCompanionsTableTableManager(
      $_db,
      $_db.rangerCompanions,
    ).filter((f) => f.companionTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _rangerCompanionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CompanionTypesTableFilterComposer
    extends Composer<_$AppDatabase, $CompanionTypesTable> {
  $$CompanionTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeKey => $composableBuilder(
    column: $table.typeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rpCost => $composableBuilder(
    column: $table.rpCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get move => $composableBuilder(
    column: $table.move,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fight => $composableBuilder(
    column: $table.fight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shoot => $composableBuilder(
    column: $table.shoot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get armour => $composableBuilder(
    column: $table.armour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get will => $composableBuilder(
    column: $table.will,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get health => $composableBuilder(
    column: $table.health,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAnimal => $composableBuilder(
    column: $table.isAnimal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseSkills => $composableBuilder(
    column: $table.baseSkills,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> rangerCompanionsRefs(
    Expression<bool> Function($$RangerCompanionsTableFilterComposer f) f,
  ) {
    final $$RangerCompanionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rangerCompanions,
      getReferencedColumn: (t) => t.companionTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangerCompanionsTableFilterComposer(
            $db: $db,
            $table: $db.rangerCompanions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompanionTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $CompanionTypesTable> {
  $$CompanionTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeKey => $composableBuilder(
    column: $table.typeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rpCost => $composableBuilder(
    column: $table.rpCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get move => $composableBuilder(
    column: $table.move,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fight => $composableBuilder(
    column: $table.fight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shoot => $composableBuilder(
    column: $table.shoot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get armour => $composableBuilder(
    column: $table.armour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get will => $composableBuilder(
    column: $table.will,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get health => $composableBuilder(
    column: $table.health,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAnimal => $composableBuilder(
    column: $table.isAnimal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseSkills => $composableBuilder(
    column: $table.baseSkills,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompanionTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompanionTypesTable> {
  $$CompanionTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get typeKey =>
      $composableBuilder(column: $table.typeKey, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get rpCost =>
      $composableBuilder(column: $table.rpCost, builder: (column) => column);

  GeneratedColumn<int> get move =>
      $composableBuilder(column: $table.move, builder: (column) => column);

  GeneratedColumn<int> get fight =>
      $composableBuilder(column: $table.fight, builder: (column) => column);

  GeneratedColumn<int> get shoot =>
      $composableBuilder(column: $table.shoot, builder: (column) => column);

  GeneratedColumn<int> get armour =>
      $composableBuilder(column: $table.armour, builder: (column) => column);

  GeneratedColumn<int> get will =>
      $composableBuilder(column: $table.will, builder: (column) => column);

  GeneratedColumn<int> get health =>
      $composableBuilder(column: $table.health, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isAnimal =>
      $composableBuilder(column: $table.isAnimal, builder: (column) => column);

  GeneratedColumn<String> get baseSkills => $composableBuilder(
    column: $table.baseSkills,
    builder: (column) => column,
  );

  Expression<T> rangerCompanionsRefs<T extends Object>(
    Expression<T> Function($$RangerCompanionsTableAnnotationComposer a) f,
  ) {
    final $$RangerCompanionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rangerCompanions,
      getReferencedColumn: (t) => t.companionTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangerCompanionsTableAnnotationComposer(
            $db: $db,
            $table: $db.rangerCompanions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompanionTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompanionTypesTable,
          CompanionType,
          $$CompanionTypesTableFilterComposer,
          $$CompanionTypesTableOrderingComposer,
          $$CompanionTypesTableAnnotationComposer,
          $$CompanionTypesTableCreateCompanionBuilder,
          $$CompanionTypesTableUpdateCompanionBuilder,
          (CompanionType, $$CompanionTypesTableReferences),
          CompanionType,
          PrefetchHooks Function({bool rangerCompanionsRefs})
        > {
  $$CompanionTypesTableTableManager(
    _$AppDatabase db,
    $CompanionTypesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompanionTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompanionTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompanionTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> typeKey = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rpCost = const Value.absent(),
                Value<int> move = const Value.absent(),
                Value<int> fight = const Value.absent(),
                Value<int> shoot = const Value.absent(),
                Value<int> armour = const Value.absent(),
                Value<int> will = const Value.absent(),
                Value<int> health = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> isAnimal = const Value.absent(),
                Value<String> baseSkills = const Value.absent(),
              }) => CompanionTypesCompanion(
                id: id,
                typeKey: typeKey,
                name: name,
                rpCost: rpCost,
                move: move,
                fight: fight,
                shoot: shoot,
                armour: armour,
                will: will,
                health: health,
                notes: notes,
                isAnimal: isAnimal,
                baseSkills: baseSkills,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String typeKey,
                required String name,
                required int rpCost,
                required int move,
                required int fight,
                required int shoot,
                required int armour,
                required int will,
                required int health,
                Value<String> notes = const Value.absent(),
                Value<bool> isAnimal = const Value.absent(),
                Value<String> baseSkills = const Value.absent(),
              }) => CompanionTypesCompanion.insert(
                id: id,
                typeKey: typeKey,
                name: name,
                rpCost: rpCost,
                move: move,
                fight: fight,
                shoot: shoot,
                armour: armour,
                will: will,
                health: health,
                notes: notes,
                isAnimal: isAnimal,
                baseSkills: baseSkills,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CompanionTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rangerCompanionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (rangerCompanionsRefs) db.rangerCompanions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (rangerCompanionsRefs)
                    await $_getPrefetchedData<
                      CompanionType,
                      $CompanionTypesTable,
                      RangerCompanion
                    >(
                      currentTable: table,
                      referencedTable: $$CompanionTypesTableReferences
                          ._rangerCompanionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CompanionTypesTableReferences(
                            db,
                            table,
                            p0,
                          ).rangerCompanionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.companionTypeId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CompanionTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompanionTypesTable,
      CompanionType,
      $$CompanionTypesTableFilterComposer,
      $$CompanionTypesTableOrderingComposer,
      $$CompanionTypesTableAnnotationComposer,
      $$CompanionTypesTableCreateCompanionBuilder,
      $$CompanionTypesTableUpdateCompanionBuilder,
      (CompanionType, $$CompanionTypesTableReferences),
      CompanionType,
      PrefetchHooks Function({bool rangerCompanionsRefs})
    >;
typedef $$RangerCompanionsTableCreateCompanionBuilder =
    RangerCompanionsCompanion Function({
      Value<int> id,
      required int rangerId,
      required int companionTypeId,
      required String customName,
      Value<int> progressionPoints,
      Value<bool> isAlive,
      Value<String> permanentInjuries,
      Value<String> customSkills,
      Value<bool> isActive,
      required DateTime createdAt,
      Value<String> claimedProgressionRewards,
      Value<bool> hasUsedRecruitmentBonus,
      Value<int> bonusHealth,
    });
typedef $$RangerCompanionsTableUpdateCompanionBuilder =
    RangerCompanionsCompanion Function({
      Value<int> id,
      Value<int> rangerId,
      Value<int> companionTypeId,
      Value<String> customName,
      Value<int> progressionPoints,
      Value<bool> isAlive,
      Value<String> permanentInjuries,
      Value<String> customSkills,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<String> claimedProgressionRewards,
      Value<bool> hasUsedRecruitmentBonus,
      Value<int> bonusHealth,
    });

final class $$RangerCompanionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $RangerCompanionsTable, RangerCompanion> {
  $$RangerCompanionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RangersTable _rangerIdTable(_$AppDatabase db) =>
      db.rangers.createAlias(
        $_aliasNameGenerator(db.rangerCompanions.rangerId, db.rangers.id),
      );

  $$RangersTableProcessedTableManager get rangerId {
    final $_column = $_itemColumn<int>('ranger_id')!;

    final manager = $$RangersTableTableManager(
      $_db,
      $_db.rangers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rangerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CompanionTypesTable _companionTypeIdTable(_$AppDatabase db) =>
      db.companionTypes.createAlias(
        $_aliasNameGenerator(
          db.rangerCompanions.companionTypeId,
          db.companionTypes.id,
        ),
      );

  $$CompanionTypesTableProcessedTableManager get companionTypeId {
    final $_column = $_itemColumn<int>('companion_type_id')!;

    final manager = $$CompanionTypesTableTableManager(
      $_db,
      $_db.companionTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companionTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$InjuriesTable, List<Injury>> _injuriesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.injuries,
    aliasName: $_aliasNameGenerator(
      db.rangerCompanions.id,
      db.injuries.companionId,
    ),
  );

  $$InjuriesTableProcessedTableManager get injuriesRefs {
    final manager = $$InjuriesTableTableManager(
      $_db,
      $_db.injuries,
    ).filter((f) => f.companionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_injuriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RangerCompanionsTableFilterComposer
    extends Composer<_$AppDatabase, $RangerCompanionsTable> {
  $$RangerCompanionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progressionPoints => $composableBuilder(
    column: $table.progressionPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAlive => $composableBuilder(
    column: $table.isAlive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get permanentInjuries => $composableBuilder(
    column: $table.permanentInjuries,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customSkills => $composableBuilder(
    column: $table.customSkills,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get claimedProgressionRewards => $composableBuilder(
    column: $table.claimedProgressionRewards,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasUsedRecruitmentBonus => $composableBuilder(
    column: $table.hasUsedRecruitmentBonus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bonusHealth => $composableBuilder(
    column: $table.bonusHealth,
    builder: (column) => ColumnFilters(column),
  );

  $$RangersTableFilterComposer get rangerId {
    final $$RangersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rangerId,
      referencedTable: $db.rangers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangersTableFilterComposer(
            $db: $db,
            $table: $db.rangers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompanionTypesTableFilterComposer get companionTypeId {
    final $$CompanionTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companionTypeId,
      referencedTable: $db.companionTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompanionTypesTableFilterComposer(
            $db: $db,
            $table: $db.companionTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> injuriesRefs(
    Expression<bool> Function($$InjuriesTableFilterComposer f) f,
  ) {
    final $$InjuriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.injuries,
      getReferencedColumn: (t) => t.companionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InjuriesTableFilterComposer(
            $db: $db,
            $table: $db.injuries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RangerCompanionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RangerCompanionsTable> {
  $$RangerCompanionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progressionPoints => $composableBuilder(
    column: $table.progressionPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAlive => $composableBuilder(
    column: $table.isAlive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get permanentInjuries => $composableBuilder(
    column: $table.permanentInjuries,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customSkills => $composableBuilder(
    column: $table.customSkills,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get claimedProgressionRewards => $composableBuilder(
    column: $table.claimedProgressionRewards,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasUsedRecruitmentBonus => $composableBuilder(
    column: $table.hasUsedRecruitmentBonus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bonusHealth => $composableBuilder(
    column: $table.bonusHealth,
    builder: (column) => ColumnOrderings(column),
  );

  $$RangersTableOrderingComposer get rangerId {
    final $$RangersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rangerId,
      referencedTable: $db.rangers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangersTableOrderingComposer(
            $db: $db,
            $table: $db.rangers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompanionTypesTableOrderingComposer get companionTypeId {
    final $$CompanionTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companionTypeId,
      referencedTable: $db.companionTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompanionTypesTableOrderingComposer(
            $db: $db,
            $table: $db.companionTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RangerCompanionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RangerCompanionsTable> {
  $$RangerCompanionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get progressionPoints => $composableBuilder(
    column: $table.progressionPoints,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAlive =>
      $composableBuilder(column: $table.isAlive, builder: (column) => column);

  GeneratedColumn<String> get permanentInjuries => $composableBuilder(
    column: $table.permanentInjuries,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customSkills => $composableBuilder(
    column: $table.customSkills,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get claimedProgressionRewards => $composableBuilder(
    column: $table.claimedProgressionRewards,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasUsedRecruitmentBonus => $composableBuilder(
    column: $table.hasUsedRecruitmentBonus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bonusHealth => $composableBuilder(
    column: $table.bonusHealth,
    builder: (column) => column,
  );

  $$RangersTableAnnotationComposer get rangerId {
    final $$RangersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rangerId,
      referencedTable: $db.rangers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangersTableAnnotationComposer(
            $db: $db,
            $table: $db.rangers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompanionTypesTableAnnotationComposer get companionTypeId {
    final $$CompanionTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companionTypeId,
      referencedTable: $db.companionTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompanionTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.companionTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> injuriesRefs<T extends Object>(
    Expression<T> Function($$InjuriesTableAnnotationComposer a) f,
  ) {
    final $$InjuriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.injuries,
      getReferencedColumn: (t) => t.companionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InjuriesTableAnnotationComposer(
            $db: $db,
            $table: $db.injuries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RangerCompanionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RangerCompanionsTable,
          RangerCompanion,
          $$RangerCompanionsTableFilterComposer,
          $$RangerCompanionsTableOrderingComposer,
          $$RangerCompanionsTableAnnotationComposer,
          $$RangerCompanionsTableCreateCompanionBuilder,
          $$RangerCompanionsTableUpdateCompanionBuilder,
          (RangerCompanion, $$RangerCompanionsTableReferences),
          RangerCompanion,
          PrefetchHooks Function({
            bool rangerId,
            bool companionTypeId,
            bool injuriesRefs,
          })
        > {
  $$RangerCompanionsTableTableManager(
    _$AppDatabase db,
    $RangerCompanionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RangerCompanionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RangerCompanionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RangerCompanionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> rangerId = const Value.absent(),
                Value<int> companionTypeId = const Value.absent(),
                Value<String> customName = const Value.absent(),
                Value<int> progressionPoints = const Value.absent(),
                Value<bool> isAlive = const Value.absent(),
                Value<String> permanentInjuries = const Value.absent(),
                Value<String> customSkills = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> claimedProgressionRewards = const Value.absent(),
                Value<bool> hasUsedRecruitmentBonus = const Value.absent(),
                Value<int> bonusHealth = const Value.absent(),
              }) => RangerCompanionsCompanion(
                id: id,
                rangerId: rangerId,
                companionTypeId: companionTypeId,
                customName: customName,
                progressionPoints: progressionPoints,
                isAlive: isAlive,
                permanentInjuries: permanentInjuries,
                customSkills: customSkills,
                isActive: isActive,
                createdAt: createdAt,
                claimedProgressionRewards: claimedProgressionRewards,
                hasUsedRecruitmentBonus: hasUsedRecruitmentBonus,
                bonusHealth: bonusHealth,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int rangerId,
                required int companionTypeId,
                required String customName,
                Value<int> progressionPoints = const Value.absent(),
                Value<bool> isAlive = const Value.absent(),
                Value<String> permanentInjuries = const Value.absent(),
                Value<String> customSkills = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                Value<String> claimedProgressionRewards = const Value.absent(),
                Value<bool> hasUsedRecruitmentBonus = const Value.absent(),
                Value<int> bonusHealth = const Value.absent(),
              }) => RangerCompanionsCompanion.insert(
                id: id,
                rangerId: rangerId,
                companionTypeId: companionTypeId,
                customName: customName,
                progressionPoints: progressionPoints,
                isAlive: isAlive,
                permanentInjuries: permanentInjuries,
                customSkills: customSkills,
                isActive: isActive,
                createdAt: createdAt,
                claimedProgressionRewards: claimedProgressionRewards,
                hasUsedRecruitmentBonus: hasUsedRecruitmentBonus,
                bonusHealth: bonusHealth,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RangerCompanionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                rangerId = false,
                companionTypeId = false,
                injuriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (injuriesRefs) db.injuries],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (rangerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.rangerId,
                                    referencedTable:
                                        $$RangerCompanionsTableReferences
                                            ._rangerIdTable(db),
                                    referencedColumn:
                                        $$RangerCompanionsTableReferences
                                            ._rangerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (companionTypeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companionTypeId,
                                    referencedTable:
                                        $$RangerCompanionsTableReferences
                                            ._companionTypeIdTable(db),
                                    referencedColumn:
                                        $$RangerCompanionsTableReferences
                                            ._companionTypeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (injuriesRefs)
                        await $_getPrefetchedData<
                          RangerCompanion,
                          $RangerCompanionsTable,
                          Injury
                        >(
                          currentTable: table,
                          referencedTable: $$RangerCompanionsTableReferences
                              ._injuriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RangerCompanionsTableReferences(
                                db,
                                table,
                                p0,
                              ).injuriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RangerCompanionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RangerCompanionsTable,
      RangerCompanion,
      $$RangerCompanionsTableFilterComposer,
      $$RangerCompanionsTableOrderingComposer,
      $$RangerCompanionsTableAnnotationComposer,
      $$RangerCompanionsTableCreateCompanionBuilder,
      $$RangerCompanionsTableUpdateCompanionBuilder,
      (RangerCompanion, $$RangerCompanionsTableReferences),
      RangerCompanion,
      PrefetchHooks Function({
        bool rangerId,
        bool companionTypeId,
        bool injuriesRefs,
      })
    >;
typedef $$EquipmentTableCreateCompanionBuilder =
    EquipmentCompanion Function({
      Value<int> id,
      required String itemKey,
      required String name,
      required String category,
      Value<String> description,
      Value<String> effects,
      Value<bool> hasUses,
      Value<int?> maxUses,
    });
typedef $$EquipmentTableUpdateCompanionBuilder =
    EquipmentCompanion Function({
      Value<int> id,
      Value<String> itemKey,
      Value<String> name,
      Value<String> category,
      Value<String> description,
      Value<String> effects,
      Value<bool> hasUses,
      Value<int?> maxUses,
    });

final class $$EquipmentTableReferences
    extends BaseReferences<_$AppDatabase, $EquipmentTable, EquipmentData> {
  $$EquipmentTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RangerEquipmentTable, List<RangerEquipmentData>>
  _rangerEquipmentRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.rangerEquipment,
    aliasName: $_aliasNameGenerator(
      db.equipment.id,
      db.rangerEquipment.equipmentId,
    ),
  );

  $$RangerEquipmentTableProcessedTableManager get rangerEquipmentRefs {
    final manager = $$RangerEquipmentTableTableManager(
      $_db,
      $_db.rangerEquipment,
    ).filter((f) => f.equipmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _rangerEquipmentRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EquipmentTableFilterComposer
    extends Composer<_$AppDatabase, $EquipmentTable> {
  $$EquipmentTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemKey => $composableBuilder(
    column: $table.itemKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effects => $composableBuilder(
    column: $table.effects,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasUses => $composableBuilder(
    column: $table.hasUses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxUses => $composableBuilder(
    column: $table.maxUses,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> rangerEquipmentRefs(
    Expression<bool> Function($$RangerEquipmentTableFilterComposer f) f,
  ) {
    final $$RangerEquipmentTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rangerEquipment,
      getReferencedColumn: (t) => t.equipmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangerEquipmentTableFilterComposer(
            $db: $db,
            $table: $db.rangerEquipment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EquipmentTableOrderingComposer
    extends Composer<_$AppDatabase, $EquipmentTable> {
  $$EquipmentTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemKey => $composableBuilder(
    column: $table.itemKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effects => $composableBuilder(
    column: $table.effects,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasUses => $composableBuilder(
    column: $table.hasUses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxUses => $composableBuilder(
    column: $table.maxUses,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EquipmentTableAnnotationComposer
    extends Composer<_$AppDatabase, $EquipmentTable> {
  $$EquipmentTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemKey =>
      $composableBuilder(column: $table.itemKey, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get effects =>
      $composableBuilder(column: $table.effects, builder: (column) => column);

  GeneratedColumn<bool> get hasUses =>
      $composableBuilder(column: $table.hasUses, builder: (column) => column);

  GeneratedColumn<int> get maxUses =>
      $composableBuilder(column: $table.maxUses, builder: (column) => column);

  Expression<T> rangerEquipmentRefs<T extends Object>(
    Expression<T> Function($$RangerEquipmentTableAnnotationComposer a) f,
  ) {
    final $$RangerEquipmentTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rangerEquipment,
      getReferencedColumn: (t) => t.equipmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangerEquipmentTableAnnotationComposer(
            $db: $db,
            $table: $db.rangerEquipment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EquipmentTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EquipmentTable,
          EquipmentData,
          $$EquipmentTableFilterComposer,
          $$EquipmentTableOrderingComposer,
          $$EquipmentTableAnnotationComposer,
          $$EquipmentTableCreateCompanionBuilder,
          $$EquipmentTableUpdateCompanionBuilder,
          (EquipmentData, $$EquipmentTableReferences),
          EquipmentData,
          PrefetchHooks Function({bool rangerEquipmentRefs})
        > {
  $$EquipmentTableTableManager(_$AppDatabase db, $EquipmentTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EquipmentTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EquipmentTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EquipmentTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> itemKey = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> effects = const Value.absent(),
                Value<bool> hasUses = const Value.absent(),
                Value<int?> maxUses = const Value.absent(),
              }) => EquipmentCompanion(
                id: id,
                itemKey: itemKey,
                name: name,
                category: category,
                description: description,
                effects: effects,
                hasUses: hasUses,
                maxUses: maxUses,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String itemKey,
                required String name,
                required String category,
                Value<String> description = const Value.absent(),
                Value<String> effects = const Value.absent(),
                Value<bool> hasUses = const Value.absent(),
                Value<int?> maxUses = const Value.absent(),
              }) => EquipmentCompanion.insert(
                id: id,
                itemKey: itemKey,
                name: name,
                category: category,
                description: description,
                effects: effects,
                hasUses: hasUses,
                maxUses: maxUses,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EquipmentTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rangerEquipmentRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (rangerEquipmentRefs) db.rangerEquipment,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (rangerEquipmentRefs)
                    await $_getPrefetchedData<
                      EquipmentData,
                      $EquipmentTable,
                      RangerEquipmentData
                    >(
                      currentTable: table,
                      referencedTable: $$EquipmentTableReferences
                          ._rangerEquipmentRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$EquipmentTableReferences(
                            db,
                            table,
                            p0,
                          ).rangerEquipmentRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.equipmentId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$EquipmentTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EquipmentTable,
      EquipmentData,
      $$EquipmentTableFilterComposer,
      $$EquipmentTableOrderingComposer,
      $$EquipmentTableAnnotationComposer,
      $$EquipmentTableCreateCompanionBuilder,
      $$EquipmentTableUpdateCompanionBuilder,
      (EquipmentData, $$EquipmentTableReferences),
      EquipmentData,
      PrefetchHooks Function({bool rangerEquipmentRefs})
    >;
typedef $$RangerEquipmentTableCreateCompanionBuilder =
    RangerEquipmentCompanion Function({
      Value<int> id,
      required int rangerId,
      required int equipmentId,
      Value<int?> currentUses,
      Value<String> equippedBy,
    });
typedef $$RangerEquipmentTableUpdateCompanionBuilder =
    RangerEquipmentCompanion Function({
      Value<int> id,
      Value<int> rangerId,
      Value<int> equipmentId,
      Value<int?> currentUses,
      Value<String> equippedBy,
    });

final class $$RangerEquipmentTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RangerEquipmentTable,
          RangerEquipmentData
        > {
  $$RangerEquipmentTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RangersTable _rangerIdTable(_$AppDatabase db) =>
      db.rangers.createAlias(
        $_aliasNameGenerator(db.rangerEquipment.rangerId, db.rangers.id),
      );

  $$RangersTableProcessedTableManager get rangerId {
    final $_column = $_itemColumn<int>('ranger_id')!;

    final manager = $$RangersTableTableManager(
      $_db,
      $_db.rangers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rangerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EquipmentTable _equipmentIdTable(_$AppDatabase db) =>
      db.equipment.createAlias(
        $_aliasNameGenerator(db.rangerEquipment.equipmentId, db.equipment.id),
      );

  $$EquipmentTableProcessedTableManager get equipmentId {
    final $_column = $_itemColumn<int>('equipment_id')!;

    final manager = $$EquipmentTableTableManager(
      $_db,
      $_db.equipment,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_equipmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RangerEquipmentTableFilterComposer
    extends Composer<_$AppDatabase, $RangerEquipmentTable> {
  $$RangerEquipmentTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentUses => $composableBuilder(
    column: $table.currentUses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equippedBy => $composableBuilder(
    column: $table.equippedBy,
    builder: (column) => ColumnFilters(column),
  );

  $$RangersTableFilterComposer get rangerId {
    final $$RangersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rangerId,
      referencedTable: $db.rangers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangersTableFilterComposer(
            $db: $db,
            $table: $db.rangers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentTableFilterComposer get equipmentId {
    final $$EquipmentTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentTableFilterComposer(
            $db: $db,
            $table: $db.equipment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RangerEquipmentTableOrderingComposer
    extends Composer<_$AppDatabase, $RangerEquipmentTable> {
  $$RangerEquipmentTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentUses => $composableBuilder(
    column: $table.currentUses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equippedBy => $composableBuilder(
    column: $table.equippedBy,
    builder: (column) => ColumnOrderings(column),
  );

  $$RangersTableOrderingComposer get rangerId {
    final $$RangersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rangerId,
      referencedTable: $db.rangers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangersTableOrderingComposer(
            $db: $db,
            $table: $db.rangers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentTableOrderingComposer get equipmentId {
    final $$EquipmentTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentTableOrderingComposer(
            $db: $db,
            $table: $db.equipment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RangerEquipmentTableAnnotationComposer
    extends Composer<_$AppDatabase, $RangerEquipmentTable> {
  $$RangerEquipmentTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get currentUses => $composableBuilder(
    column: $table.currentUses,
    builder: (column) => column,
  );

  GeneratedColumn<String> get equippedBy => $composableBuilder(
    column: $table.equippedBy,
    builder: (column) => column,
  );

  $$RangersTableAnnotationComposer get rangerId {
    final $$RangersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rangerId,
      referencedTable: $db.rangers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangersTableAnnotationComposer(
            $db: $db,
            $table: $db.rangers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentTableAnnotationComposer get equipmentId {
    final $$EquipmentTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentTableAnnotationComposer(
            $db: $db,
            $table: $db.equipment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RangerEquipmentTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RangerEquipmentTable,
          RangerEquipmentData,
          $$RangerEquipmentTableFilterComposer,
          $$RangerEquipmentTableOrderingComposer,
          $$RangerEquipmentTableAnnotationComposer,
          $$RangerEquipmentTableCreateCompanionBuilder,
          $$RangerEquipmentTableUpdateCompanionBuilder,
          (RangerEquipmentData, $$RangerEquipmentTableReferences),
          RangerEquipmentData,
          PrefetchHooks Function({bool rangerId, bool equipmentId})
        > {
  $$RangerEquipmentTableTableManager(
    _$AppDatabase db,
    $RangerEquipmentTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RangerEquipmentTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RangerEquipmentTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RangerEquipmentTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> rangerId = const Value.absent(),
                Value<int> equipmentId = const Value.absent(),
                Value<int?> currentUses = const Value.absent(),
                Value<String> equippedBy = const Value.absent(),
              }) => RangerEquipmentCompanion(
                id: id,
                rangerId: rangerId,
                equipmentId: equipmentId,
                currentUses: currentUses,
                equippedBy: equippedBy,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int rangerId,
                required int equipmentId,
                Value<int?> currentUses = const Value.absent(),
                Value<String> equippedBy = const Value.absent(),
              }) => RangerEquipmentCompanion.insert(
                id: id,
                rangerId: rangerId,
                equipmentId: equipmentId,
                currentUses: currentUses,
                equippedBy: equippedBy,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RangerEquipmentTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rangerId = false, equipmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (rangerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.rangerId,
                                referencedTable:
                                    $$RangerEquipmentTableReferences
                                        ._rangerIdTable(db),
                                referencedColumn:
                                    $$RangerEquipmentTableReferences
                                        ._rangerIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (equipmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.equipmentId,
                                referencedTable:
                                    $$RangerEquipmentTableReferences
                                        ._equipmentIdTable(db),
                                referencedColumn:
                                    $$RangerEquipmentTableReferences
                                        ._equipmentIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RangerEquipmentTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RangerEquipmentTable,
      RangerEquipmentData,
      $$RangerEquipmentTableFilterComposer,
      $$RangerEquipmentTableOrderingComposer,
      $$RangerEquipmentTableAnnotationComposer,
      $$RangerEquipmentTableCreateCompanionBuilder,
      $$RangerEquipmentTableUpdateCompanionBuilder,
      (RangerEquipmentData, $$RangerEquipmentTableReferences),
      RangerEquipmentData,
      PrefetchHooks Function({bool rangerId, bool equipmentId})
    >;
typedef $$InjuriesTableCreateCompanionBuilder =
    InjuriesCompanion Function({
      Value<int> id,
      Value<int?> rangerId,
      Value<int?> companionId,
      required String injuryKey,
      Value<int> timesReceived,
      required DateTime receivedAt,
    });
typedef $$InjuriesTableUpdateCompanionBuilder =
    InjuriesCompanion Function({
      Value<int> id,
      Value<int?> rangerId,
      Value<int?> companionId,
      Value<String> injuryKey,
      Value<int> timesReceived,
      Value<DateTime> receivedAt,
    });

final class $$InjuriesTableReferences
    extends BaseReferences<_$AppDatabase, $InjuriesTable, Injury> {
  $$InjuriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RangersTable _rangerIdTable(_$AppDatabase db) => db.rangers
      .createAlias($_aliasNameGenerator(db.injuries.rangerId, db.rangers.id));

  $$RangersTableProcessedTableManager? get rangerId {
    final $_column = $_itemColumn<int>('ranger_id');
    if ($_column == null) return null;
    final manager = $$RangersTableTableManager(
      $_db,
      $_db.rangers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rangerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RangerCompanionsTable _companionIdTable(_$AppDatabase db) =>
      db.rangerCompanions.createAlias(
        $_aliasNameGenerator(db.injuries.companionId, db.rangerCompanions.id),
      );

  $$RangerCompanionsTableProcessedTableManager? get companionId {
    final $_column = $_itemColumn<int>('companion_id');
    if ($_column == null) return null;
    final manager = $$RangerCompanionsTableTableManager(
      $_db,
      $_db.rangerCompanions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InjuriesTableFilterComposer
    extends Composer<_$AppDatabase, $InjuriesTable> {
  $$InjuriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get injuryKey => $composableBuilder(
    column: $table.injuryKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timesReceived => $composableBuilder(
    column: $table.timesReceived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RangersTableFilterComposer get rangerId {
    final $$RangersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rangerId,
      referencedTable: $db.rangers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangersTableFilterComposer(
            $db: $db,
            $table: $db.rangers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RangerCompanionsTableFilterComposer get companionId {
    final $$RangerCompanionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companionId,
      referencedTable: $db.rangerCompanions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangerCompanionsTableFilterComposer(
            $db: $db,
            $table: $db.rangerCompanions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InjuriesTableOrderingComposer
    extends Composer<_$AppDatabase, $InjuriesTable> {
  $$InjuriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get injuryKey => $composableBuilder(
    column: $table.injuryKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timesReceived => $composableBuilder(
    column: $table.timesReceived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RangersTableOrderingComposer get rangerId {
    final $$RangersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rangerId,
      referencedTable: $db.rangers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangersTableOrderingComposer(
            $db: $db,
            $table: $db.rangers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RangerCompanionsTableOrderingComposer get companionId {
    final $$RangerCompanionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companionId,
      referencedTable: $db.rangerCompanions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangerCompanionsTableOrderingComposer(
            $db: $db,
            $table: $db.rangerCompanions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InjuriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InjuriesTable> {
  $$InjuriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get injuryKey =>
      $composableBuilder(column: $table.injuryKey, builder: (column) => column);

  GeneratedColumn<int> get timesReceived => $composableBuilder(
    column: $table.timesReceived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  $$RangersTableAnnotationComposer get rangerId {
    final $$RangersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rangerId,
      referencedTable: $db.rangers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangersTableAnnotationComposer(
            $db: $db,
            $table: $db.rangers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RangerCompanionsTableAnnotationComposer get companionId {
    final $$RangerCompanionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companionId,
      referencedTable: $db.rangerCompanions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangerCompanionsTableAnnotationComposer(
            $db: $db,
            $table: $db.rangerCompanions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InjuriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InjuriesTable,
          Injury,
          $$InjuriesTableFilterComposer,
          $$InjuriesTableOrderingComposer,
          $$InjuriesTableAnnotationComposer,
          $$InjuriesTableCreateCompanionBuilder,
          $$InjuriesTableUpdateCompanionBuilder,
          (Injury, $$InjuriesTableReferences),
          Injury,
          PrefetchHooks Function({bool rangerId, bool companionId})
        > {
  $$InjuriesTableTableManager(_$AppDatabase db, $InjuriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InjuriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InjuriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InjuriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> rangerId = const Value.absent(),
                Value<int?> companionId = const Value.absent(),
                Value<String> injuryKey = const Value.absent(),
                Value<int> timesReceived = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
              }) => InjuriesCompanion(
                id: id,
                rangerId: rangerId,
                companionId: companionId,
                injuryKey: injuryKey,
                timesReceived: timesReceived,
                receivedAt: receivedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> rangerId = const Value.absent(),
                Value<int?> companionId = const Value.absent(),
                required String injuryKey,
                Value<int> timesReceived = const Value.absent(),
                required DateTime receivedAt,
              }) => InjuriesCompanion.insert(
                id: id,
                rangerId: rangerId,
                companionId: companionId,
                injuryKey: injuryKey,
                timesReceived: timesReceived,
                receivedAt: receivedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InjuriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rangerId = false, companionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (rangerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.rangerId,
                                referencedTable: $$InjuriesTableReferences
                                    ._rangerIdTable(db),
                                referencedColumn: $$InjuriesTableReferences
                                    ._rangerIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (companionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.companionId,
                                referencedTable: $$InjuriesTableReferences
                                    ._companionIdTable(db),
                                referencedColumn: $$InjuriesTableReferences
                                    ._companionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InjuriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InjuriesTable,
      Injury,
      $$InjuriesTableFilterComposer,
      $$InjuriesTableOrderingComposer,
      $$InjuriesTableAnnotationComposer,
      $$InjuriesTableCreateCompanionBuilder,
      $$InjuriesTableUpdateCompanionBuilder,
      (Injury, $$InjuriesTableReferences),
      Injury,
      PrefetchHooks Function({bool rangerId, bool companionId})
    >;
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      required int rangerId,
      required String scenarioName,
      Value<String> missionName,
      required DateTime datePlayed,
      Value<int> turnsPlayed,
      Value<String> outcome,
      Value<String> notes,
      Value<int> experienceEarned,
      Value<bool> isCompleted,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<int> rangerId,
      Value<String> scenarioName,
      Value<String> missionName,
      Value<DateTime> datePlayed,
      Value<int> turnsPlayed,
      Value<String> outcome,
      Value<String> notes,
      Value<int> experienceEarned,
      Value<bool> isCompleted,
    });

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RangersTable _rangerIdTable(_$AppDatabase db) => db.rangers
      .createAlias($_aliasNameGenerator(db.sessions.rangerId, db.rangers.id));

  $$RangersTableProcessedTableManager get rangerId {
    final $_column = $_itemColumn<int>('ranger_id')!;

    final manager = $$RangersTableTableManager(
      $_db,
      $_db.rangers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rangerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SessionEventsTable, List<SessionEvent>>
  _sessionEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionEvents,
    aliasName: $_aliasNameGenerator(db.sessions.id, db.sessionEvents.sessionId),
  );

  $$SessionEventsTableProcessedTableManager get sessionEventsRefs {
    final manager = $$SessionEventsTableTableManager(
      $_db,
      $_db.sessionEvents,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scenarioName => $composableBuilder(
    column: $table.scenarioName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get missionName => $composableBuilder(
    column: $table.missionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get datePlayed => $composableBuilder(
    column: $table.datePlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get turnsPlayed => $composableBuilder(
    column: $table.turnsPlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get experienceEarned => $composableBuilder(
    column: $table.experienceEarned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  $$RangersTableFilterComposer get rangerId {
    final $$RangersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rangerId,
      referencedTable: $db.rangers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangersTableFilterComposer(
            $db: $db,
            $table: $db.rangers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> sessionEventsRefs(
    Expression<bool> Function($$SessionEventsTableFilterComposer f) f,
  ) {
    final $$SessionEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionEvents,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionEventsTableFilterComposer(
            $db: $db,
            $table: $db.sessionEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scenarioName => $composableBuilder(
    column: $table.scenarioName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get missionName => $composableBuilder(
    column: $table.missionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get datePlayed => $composableBuilder(
    column: $table.datePlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get turnsPlayed => $composableBuilder(
    column: $table.turnsPlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get experienceEarned => $composableBuilder(
    column: $table.experienceEarned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$RangersTableOrderingComposer get rangerId {
    final $$RangersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rangerId,
      referencedTable: $db.rangers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangersTableOrderingComposer(
            $db: $db,
            $table: $db.rangers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scenarioName => $composableBuilder(
    column: $table.scenarioName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get missionName => $composableBuilder(
    column: $table.missionName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get datePlayed => $composableBuilder(
    column: $table.datePlayed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get turnsPlayed => $composableBuilder(
    column: $table.turnsPlayed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get experienceEarned => $composableBuilder(
    column: $table.experienceEarned,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  $$RangersTableAnnotationComposer get rangerId {
    final $$RangersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rangerId,
      referencedTable: $db.rangers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RangersTableAnnotationComposer(
            $db: $db,
            $table: $db.rangers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> sessionEventsRefs<T extends Object>(
    Expression<T> Function($$SessionEventsTableAnnotationComposer a) f,
  ) {
    final $$SessionEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionEvents,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({bool rangerId, bool sessionEventsRefs})
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> rangerId = const Value.absent(),
                Value<String> scenarioName = const Value.absent(),
                Value<String> missionName = const Value.absent(),
                Value<DateTime> datePlayed = const Value.absent(),
                Value<int> turnsPlayed = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> experienceEarned = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                rangerId: rangerId,
                scenarioName: scenarioName,
                missionName: missionName,
                datePlayed: datePlayed,
                turnsPlayed: turnsPlayed,
                outcome: outcome,
                notes: notes,
                experienceEarned: experienceEarned,
                isCompleted: isCompleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int rangerId,
                required String scenarioName,
                Value<String> missionName = const Value.absent(),
                required DateTime datePlayed,
                Value<int> turnsPlayed = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> experienceEarned = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                rangerId: rangerId,
                scenarioName: scenarioName,
                missionName: missionName,
                datePlayed: datePlayed,
                turnsPlayed: turnsPlayed,
                outcome: outcome,
                notes: notes,
                experienceEarned: experienceEarned,
                isCompleted: isCompleted,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({rangerId = false, sessionEventsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sessionEventsRefs) db.sessionEvents,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (rangerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.rangerId,
                                    referencedTable: $$SessionsTableReferences
                                        ._rangerIdTable(db),
                                    referencedColumn: $$SessionsTableReferences
                                        ._rangerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sessionEventsRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          SessionEvent
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._sessionEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({bool rangerId, bool sessionEventsRefs})
    >;
typedef $$SessionEventsTableCreateCompanionBuilder =
    SessionEventsCompanion Function({
      Value<int> id,
      required int sessionId,
      required int turnNumber,
      required String phase,
      required String eventType,
      Value<String> description,
      Value<String> figureName,
      required DateTime createdAt,
    });
typedef $$SessionEventsTableUpdateCompanionBuilder =
    SessionEventsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int> turnNumber,
      Value<String> phase,
      Value<String> eventType,
      Value<String> description,
      Value<String> figureName,
      Value<DateTime> createdAt,
    });

final class $$SessionEventsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionEventsTable, SessionEvent> {
  $$SessionEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias(
        $_aliasNameGenerator(db.sessionEvents.sessionId, db.sessions.id),
      );

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionEventsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionEventsTable> {
  $$SessionEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get turnNumber => $composableBuilder(
    column: $table.turnNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get figureName => $composableBuilder(
    column: $table.figureName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionEventsTable> {
  $$SessionEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get turnNumber => $composableBuilder(
    column: $table.turnNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get figureName => $composableBuilder(
    column: $table.figureName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionEventsTable> {
  $$SessionEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get turnNumber => $composableBuilder(
    column: $table.turnNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get figureName => $composableBuilder(
    column: $table.figureName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionEventsTable,
          SessionEvent,
          $$SessionEventsTableFilterComposer,
          $$SessionEventsTableOrderingComposer,
          $$SessionEventsTableAnnotationComposer,
          $$SessionEventsTableCreateCompanionBuilder,
          $$SessionEventsTableUpdateCompanionBuilder,
          (SessionEvent, $$SessionEventsTableReferences),
          SessionEvent,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SessionEventsTableTableManager(_$AppDatabase db, $SessionEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> turnNumber = const Value.absent(),
                Value<String> phase = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> figureName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SessionEventsCompanion(
                id: id,
                sessionId: sessionId,
                turnNumber: turnNumber,
                phase: phase,
                eventType: eventType,
                description: description,
                figureName: figureName,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int turnNumber,
                required String phase,
                required String eventType,
                Value<String> description = const Value.absent(),
                Value<String> figureName = const Value.absent(),
                required DateTime createdAt,
              }) => SessionEventsCompanion.insert(
                id: id,
                sessionId: sessionId,
                turnNumber: turnNumber,
                phase: phase,
                eventType: eventType,
                description: description,
                figureName: figureName,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$SessionEventsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$SessionEventsTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessionEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionEventsTable,
      SessionEvent,
      $$SessionEventsTableFilterComposer,
      $$SessionEventsTableOrderingComposer,
      $$SessionEventsTableAnnotationComposer,
      $$SessionEventsTableCreateCompanionBuilder,
      $$SessionEventsTableUpdateCompanionBuilder,
      (SessionEvent, $$SessionEventsTableReferences),
      SessionEvent,
      PrefetchHooks Function({bool sessionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RangersTableTableManager get rangers =>
      $$RangersTableTableManager(_db, _db.rangers);
  $$RangerAbilitiesTableTableManager get rangerAbilities =>
      $$RangerAbilitiesTableTableManager(_db, _db.rangerAbilities);
  $$RangerSkillsTableTableManager get rangerSkills =>
      $$RangerSkillsTableTableManager(_db, _db.rangerSkills);
  $$CompanionTypesTableTableManager get companionTypes =>
      $$CompanionTypesTableTableManager(_db, _db.companionTypes);
  $$RangerCompanionsTableTableManager get rangerCompanions =>
      $$RangerCompanionsTableTableManager(_db, _db.rangerCompanions);
  $$EquipmentTableTableManager get equipment =>
      $$EquipmentTableTableManager(_db, _db.equipment);
  $$RangerEquipmentTableTableManager get rangerEquipment =>
      $$RangerEquipmentTableTableManager(_db, _db.rangerEquipment);
  $$InjuriesTableTableManager get injuries =>
      $$InjuriesTableTableManager(_db, _db.injuries);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$SessionEventsTableTableManager get sessionEvents =>
      $$SessionEventsTableTableManager(_db, _db.sessionEvents);
}
