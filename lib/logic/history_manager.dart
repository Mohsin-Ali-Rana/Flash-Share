import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final historyProvider = StateNotifierProvider<HistoryNotifier, List<Map<String, dynamic>>>((ref) {
  return HistoryNotifier();
});

class HistoryNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  HistoryNotifier() : super([]) {
    _loadHistory();
  }

  static const String _boxName = 'transfer_history';

  Future<void> _loadHistory() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    final box = Hive.box(_boxName);
    // Convert generic Hive objects to typed Map
    state = box.values.map((e) => Map<String, dynamic>.from(e)).toList().reversed.toList();
  }

  Future<void> addEntry({
    required String fileName,
    required String type, // 'sent' or 'received'
    required int size,
  }) async {
    final box = Hive.box(_boxName);
    
    final entry = {
      'fileName': fileName,
      'type': type,
      'size': size,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await box.add(entry);
    _loadHistory();
  }

  Future<void> clearHistory() async {
    final box = Hive.box(_boxName);
    await box.clear();
    state = [];
  }
}