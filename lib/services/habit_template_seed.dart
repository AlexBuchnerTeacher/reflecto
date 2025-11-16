import '../models/habit_template.dart';

String _slug(String input) {
  final lower = input.toLowerCase();
  final basic = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  final collapsed = basic.replaceAll(RegExp(r'-+'), '-');
  return collapsed.replaceAll(RegExp(r'^-|-$'), '');
}

List<HabitTemplate> buildCuratedHabitTemplates() {
  HabitTemplate make({
    required String category,
    required String color,
    required String title,
    required String frequency,
    List<int>? weekdays,
    int? weeklyTarget,
  }) {
    final id = '${_slug(category)}_${_slug(title)}';
    return HabitTemplate(
      id: id,
      title: title,
      category: category,
      color: color,
      frequency: frequency,
      weekdays: weekdays,
      weeklyTarget: weeklyTarget,
      reminderTime: null,
    );
  }

  final data = <HabitTemplate>[
    // 🔥 GESUNDHEIT – #34C759
    make(
      category: '🔥 GESUNDHEIT',
      color: '#34C759',
      title: '2 Liter Wasser',
      frequency: 'daily',
    ),
    make(
      category: '🔥 GESUNDHEIT',
      color: '#34C759',
      title: '7 Stunden Schlaf',
      frequency: 'daily',
    ),
    make(
      category: '🔥 GESUNDHEIT',
      color: '#34C759',
      title: '10 Minuten Mobility',
      frequency: 'daily',
    ),
    make(
      category: '🔥 GESUNDHEIT',
      color: '#34C759',
      title: 'Meal-Prep / Woche planen',
      frequency: 'weekly_target',
      weeklyTarget: 1,
    ),
    make(
      category: '🔥 GESUNDHEIT',
      color: '#34C759',
      title: 'Arzt-/Gesundheitscheck',
      frequency: 'irregular',
    ),

    // 🚴 SPORT – #FF3B30
    make(
      category: '🚴 SPORT',
      color: '#FF3B30',
      title: '8.000 Schritte',
      frequency: 'daily',
    ),
    make(
      category: '🚴 SPORT',
      color: '#FF3B30',
      title: '5-Minuten Core/Stabilität',
      frequency: 'daily',
    ),
    make(
      category: '🚴 SPORT',
      color: '#FF3B30',
      title: 'Radfahren 3×/Woche (30–60 Min locker/moderat)',
      frequency: 'weekly_target',
      weeklyTarget: 3,
    ),
    make(
      category: '🚴 SPORT',
      color: '#FF3B30',
      title: 'HIIT-Radeinheit 1×/Woche (20–30 Min Intervalle)',
      frequency: 'weekly_target',
      weeklyTarget: 1,
    ),
    make(
      category: '🚴 SPORT',
      color: '#FF3B30',
      title: 'Leistungscheck / Fortschrittsmessung',
      frequency: 'irregular',
    ),

    // 📘 LERNEN – #0A84FF
    make(
      category: '📘 LERNEN',
      color: '#0A84FF',
      title: '10 Minuten Lernen',
      frequency: 'daily',
    ),
    make(
      category: '📘 LERNEN',
      color: '#0A84FF',
      title: 'Sprachen lernen',
      frequency: 'daily',
    ),
    make(
      category: '📘 LERNEN',
      color: '#0A84FF',
      title: 'Reflexionsnotiz',
      frequency: 'daily',
    ),
    make(
      category: '📘 LERNEN',
      color: '#0A84FF',
      title: '30–45 Min Deep Dive',
      frequency: 'weekly_target',
      weeklyTarget: 1,
    ),
    make(
      category: '📘 LERNEN',
      color: '#0A84FF',
      title: 'Weiterbildung / Kurs / Workshop',
      frequency: 'irregular',
    ),

    // ⚡ KREATIVITÄT – #FFCC00
    make(
      category: '⚡ KREATIVITÄT',
      color: '#FFCC00',
      title: 'Eine Idee notieren',
      frequency: 'daily',
    ),
    make(
      category: '⚡ KREATIVITÄT',
      color: '#FFCC00',
      title: 'Kreativmoment (Foto/Skizze)',
      frequency: 'daily',
    ),
    make(
      category: '⚡ KREATIVITÄT',
      color: '#FFCC00',
      title: '5-Minuten-Brainstorm',
      frequency: 'daily',
    ),
    make(
      category: '⚡ KREATIVITÄT',
      color: '#FFCC00',
      title: 'Kreativprojekt weiterführen',
      frequency: 'weekly_target',
      weeklyTarget: 1,
    ),
    make(
      category: '⚡ KREATIVITÄT',
      color: '#FFCC00',
      title: 'Kreativ-Ausflug / Inspirationsinput',
      frequency: 'irregular',
    ),

    // 📈 PRODUKTIVITÄT – #5856D6
    make(
      category: '📈 PRODUKTIVITÄT',
      color: '#5856D6',
      title: 'Top-3 Tagesziele definieren',
      frequency: 'daily',
    ),
    make(
      category: '📈 PRODUKTIVITÄT',
      color: '#5856D6',
      title: 'Eine Aufgabe komplett abschließen',
      frequency: 'daily',
    ),
    make(
      category: '📈 PRODUKTIVITÄT',
      color: '#5856D6',
      title: '10 Minuten Inbox-Zero',
      frequency: 'daily',
    ),
    make(
      category: '📈 PRODUKTIVITÄT',
      color: '#5856D6',
      title: 'Wochenplanung',
      frequency: 'weekly_target',
      weeklyTarget: 1,
    ),
    make(
      category: '📈 PRODUKTIVITÄT',
      color: '#5856D6',
      title: 'System-/Tool-Update',
      frequency: 'irregular',
    ),

    // 🤝 SOZIALES – #FF9500
    make(
      category: '🤝 SOZIALES',
      color: '#FF9500',
      title: 'Eine Nachricht/Check-in',
      frequency: 'daily',
    ),
    make(
      category: '🤝 SOZIALES',
      color: '#FF9500',
      title: 'Wertschätzung aussprechen',
      frequency: 'daily',
    ),
    make(
      category: '🤝 SOZIALES',
      color: '#FF9500',
      title: 'Familienmoment setzen',
      frequency: 'daily',
    ),
    make(
      category: '🤝 SOZIALES',
      color: '#FF9500',
      title: 'Gemeinsame Aktivität',
      frequency: 'weekly_target',
      weeklyTarget: 1,
    ),
    make(
      category: '🤝 SOZIALES',
      color: '#FF9500',
      title: 'Treffen organisieren',
      frequency: 'irregular',
    ),

    // 🧘 ACHTSAMKEIT – #AF52DE
    make(
      category: '🧘 ACHTSAMKEIT',
      color: '#AF52DE',
      title: '3 Minuten Atemfokus',
      frequency: 'daily',
    ),
    make(
      category: '🧘 ACHTSAMKEIT',
      color: '#AF52DE',
      title: '10 Minuten Walk ohne Handy',
      frequency: 'daily',
    ),
    make(
      category: '🧘 ACHTSAMKEIT',
      color: '#AF52DE',
      title: 'Kurz-Reflexion am Abend',
      frequency: 'daily',
    ),
    make(
      category: '🧘 ACHTSAMKEIT',
      color: '#AF52DE',
      title: 'Digital-Reset (1 Stunde)',
      frequency: 'weekly_target',
      weeklyTarget: 1,
    ),
    make(
      category: '🧘 ACHTSAMKEIT',
      color: '#AF52DE',
      title: 'Achtsamkeitstag',
      frequency: 'irregular',
    ),

    // 🔧 SONSTIGES – #8E8E93
    make(
      category: '🔧 SONSTIGES',
      color: '#8E8E93',
      title: '5-Minuten-Ordnung',
      frequency: 'daily',
    ),
    make(
      category: '🔧 SONSTIGES',
      color: '#8E8E93',
      title: 'Sabbatical-/Projekt-Impuls',
      frequency: 'daily',
    ),
    make(
      category: '🔧 SONSTIGES',
      color: '#8E8E93',
      title: 'Mini-Administration (1 Schritt)',
      frequency: 'daily',
    ),
    make(
      category: '🔧 SONSTIGES',
      color: '#8E8E93',
      title: 'Finanzüberblick',
      frequency: 'weekly_target',
      weeklyTarget: 1,
    ),
    make(
      category: '🔧 SONSTIGES',
      color: '#8E8E93',
      title: 'Langzeitprojekte pushen',
      frequency: 'irregular',
    ),
  ];

  return data;
}
