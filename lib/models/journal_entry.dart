import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

/// Repräsentiert einen Journaleintrag für einen Tag.
class JournalEntry {
  final String id; // yyyy-MM-dd
  final Planning planning;
  final Morning morning;
  final Evening evening;
  final Ratings ratings;
  final DateTime? updatedAt;

  const JournalEntry({
    required this.id,
    this.planning = const Planning(),
    this.morning = const Morning(),
    this.evening = const Evening(),
    this.ratings = const Ratings(),
    this.updatedAt,
  });

  /// Leerer Default-Eintrag
  static JournalEntry empty(String id) => JournalEntry(id: id);

  /// Serialisierung in Firestore-Map
  Map<String, dynamic> toMap() {
    return {
      'planning': planning.toMap(),
      'morning': morning.toMap(),
      'evening': evening.toMap(),
      'ratings': ratings.toMap(),
      'updatedAt': updatedAt,
      // Back-compat: top-level ratings für bestehenden Code
      'ratingFocus': ratings.focus,
      'ratingEnergy': ratings.energy,
      'ratingHappiness': ratings.happiness,
    };
  }

  /// Deserialisierung aus Firestore-Map
  factory JournalEntry.fromMap(String id, Map<String, dynamic> map) {
    DateTime? updated;
    final raw = map['updatedAt'];
    if (raw is Timestamp) {
      updated = raw.toDate();
    } else if (raw is DateTime) {
      updated = raw;
    } else if (raw != null) {
      updated = DateTime.tryParse(raw.toString());
    }

    final planning = Planning.fromMap(map['planning'] as Map<String, dynamic>?);
    final morning = Morning.fromMap(map['morning'] as Map<String, dynamic>?);
    final evening = Evening.fromMap(map['evening'] as Map<String, dynamic>?);
    final ratings = Ratings.fromMap(map['ratings'] as Map<String, dynamic>?, fallback: map);

    return JournalEntry(
      id: id,
      planning: planning,
      morning: morning,
      evening: evening,
      ratings: ratings,
      updatedAt: updated,
    );
  }

  /// Convenience-Getter für bestehenden Code
  int? get ratingFocus => ratings.focus;
  int? get ratingEnergy => ratings.energy;
  int? get ratingHappiness => ratings.happiness;

  JournalEntry copyWith({
    Planning? planning,
    Morning? morning,
    Evening? evening,
    Ratings? ratings,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id,
      planning: planning ?? this.planning,
      morning: morning ?? this.morning,
      evening: evening ?? this.evening,
      ratings: ratings ?? this.ratings,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Planung für den kommenden Tag.
class Planning {
  final List<String> goals;
  final List<String> todos;
  final String reflection;
  final String notes;

  const Planning({
    this.goals = const <String>[],
    this.todos = const <String>[],
    this.reflection = '',
    this.notes = '',
  });

  factory Planning.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const Planning();
    final goals = (map['goals'] is List) ? List<String>.from(map['goals']) : <String>[];
    final todos = (map['todos'] is List) ? List<String>.from(map['todos']) : <String>[];
    return Planning(
      goals: goals,
      todos: todos,
      reflection: (map['reflection'] ?? '') as String,
      notes: (map['notes'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'goals': goals,
        'todos': todos,
        'reflection': reflection,
        'notes': notes,
      };

  Planning copyWith({
    List<String>? goals,
    List<String>? todos,
    String? reflection,
    String? notes,
  }) {
    return Planning(
      goals: goals ?? this.goals,
      todos: todos ?? this.todos,
      reflection: reflection ?? this.reflection,
      notes: notes ?? this.notes,
    );
  }
}

/// Morgenreflexion.
class Morning {
  final String mood;
  final String goodThing;
  final String focus;

  const Morning({
    this.mood = '',
    this.goodThing = '',
    this.focus = '',
  });

  factory Morning.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const Morning();
    return Morning(
      mood: (map['mood'] ?? map['feeling'] ?? '') as String,
      goodThing: (map['goodThing'] ?? map['good'] ?? '') as String,
      focus: (map['focus'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'mood': mood,
        'goodThing': goodThing,
        'focus': focus,
      };

  Morning copyWith({String? mood, String? goodThing, String? focus}) => Morning(
        mood: mood ?? this.mood,
        goodThing: goodThing ?? this.goodThing,
        focus: focus ?? this.focus,
      );
}

/// Abendreflexion.
class Evening {
  final String good;
  final String learned;
  final String improve;
  final String gratitude;
  final List<bool> todosCompletion;

  const Evening({
    this.good = '',
    this.learned = '',
    this.improve = '',
    this.gratitude = '',
    this.todosCompletion = const [false, false, false],
  });

  factory Evening.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const Evening();
    List<bool> toBoolList(dynamic v) {
      if (v is List) {
        return v.map((e) => e == true).toList();
      }
      return const [false, false, false];
    }
    return Evening(
      good: (map['good'] ?? '') as String,
      learned: (map['learned'] ?? '') as String,
      improve: (map['improve'] ?? map['better'] ?? '') as String,
      gratitude: (map['gratitude'] ?? map['grateful'] ?? '') as String,
      todosCompletion: toBoolList(map['todosCompletion']),
    );
  }

  Map<String, dynamic> toMap() => {
        'good': good,
        'learned': learned,
        'improve': improve,
        'gratitude': gratitude,
        'todosCompletion': todosCompletion,
      };

  Evening copyWith({String? good, String? learned, String? improve, String? gratitude}) => Evening(
        good: good ?? this.good,
        learned: learned ?? this.learned,
        improve: improve ?? this.improve,
        gratitude: gratitude ?? this.gratitude,
      );
}

/// Tagesbewertungen.
class Ratings {
  final int? mood;
  final int? focus;
  final int? energy;
  final int? happiness;

  const Ratings({this.mood, this.focus, this.energy, this.happiness});

  factory Ratings.fromMap(Map<String, dynamic>? map, {Map<String, dynamic>? fallback}) {
    if (map != null) {
      return Ratings(
        mood: (map['mood'] as num?)?.toInt(),
        focus: (map['focus'] as num?)?.toInt(),
        energy: (map['energy'] as num?)?.toInt(),
        happiness: (map['happiness'] as num?)?.toInt(),
      );
    }
    if (fallback != null) {
      return Ratings(
        mood: (fallback['mood'] as num?)?.toInt(),
        focus: (fallback['ratingFocus'] as num?)?.toInt(),
        energy: (fallback['ratingEnergy'] as num?)?.toInt(),
        happiness: (fallback['ratingHappiness'] as num?)?.toInt(),
      );
    }
    return const Ratings();
  }

  Map<String, dynamic> toMap() => {
        'mood': mood,
        'focus': focus,
        'energy': energy,
        'happiness': happiness,
      };

  Ratings copyWith({int? mood, int? focus, int? energy, int? happiness}) => Ratings(
        mood: mood ?? this.mood,
        focus: focus ?? this.focus,
        energy: energy ?? this.energy,
        happiness: happiness ?? this.happiness,
      );
}
