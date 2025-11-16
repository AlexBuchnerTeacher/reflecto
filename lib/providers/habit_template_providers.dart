import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit_template.dart';
import '../services/habit_template_service.dart';

final habitTemplateServiceProvider = Provider<HabitTemplateService>((ref) {
  return HabitTemplateService();
});

final habitTemplatesProvider = StreamProvider.autoDispose<List<HabitTemplate>>((
  ref,
) {
  final service = ref.watch(habitTemplateServiceProvider);
  return service.watchTemplates();
});
