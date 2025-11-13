import 'package:flutter_riverpod/flutter_riverpod.dart';

final pendingWritesProvider = StateProvider<int>((ref) => 0);

final appPendingProvider = Provider<bool>((ref) {
  final cnt = ref.watch(pendingWritesProvider);
  return cnt > 0;
});
