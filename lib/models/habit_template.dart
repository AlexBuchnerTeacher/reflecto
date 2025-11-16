class HabitTemplate {
  final String id;
  final String title;
  final String category;
  final String color;
  final String frequency; // daily | weekly_days | weekly_target | irregular
  final List<int>? weekdays; // 1=Mo .. 7=So
  final int? weeklyTarget; // für weekly_target
  final String? reminderTime; // HH:mm optional

  const HabitTemplate({
    required this.id,
    required this.title,
    required this.category,
    required this.color,
    required this.frequency,
    this.weekdays,
    this.weeklyTarget,
    this.reminderTime,
  });

  factory HabitTemplate.fromMap(String id, Map<String, dynamic> map) {
    return HabitTemplate(
      id: id,
      title: map['title'] as String? ?? '',
      category: map['category'] as String? ?? 'Sonstiges',
      color: map['color'] as String? ?? '#5B50FF',
      frequency: map['frequency'] as String? ?? 'daily',
      weekdays: (map['weekdays'] as List<dynamic>?)
          ?.map((e) => int.tryParse(e.toString()) ?? -1)
          .where((e) => e >= 1 && e <= 7)
          .toList(),
      weeklyTarget: (map['weeklyTarget'] is int)
          ? map['weeklyTarget'] as int
          : int.tryParse(map['weeklyTarget']?.toString() ?? ''),
      reminderTime: map['reminderTime'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'color': color,
      'frequency': frequency,
      if (weekdays != null) 'weekdays': weekdays,
      if (weeklyTarget != null) 'weeklyTarget': weeklyTarget,
      if (reminderTime != null) 'reminderTime': reminderTime,
    };
  }
}
