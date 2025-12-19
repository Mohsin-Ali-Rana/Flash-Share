import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class TrustManager {
  static const String _boxName = 'trusted_devices';

  static Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  bool isTrusted(String token) {
    final box = Hive.box(_boxName);
    return box.containsKey(token);
  }

  String addTrustedDevice(String userAgent) {
    final box = Hive.box(_boxName);
    final token = const Uuid().v4(); 
    box.put(token, {
      'userAgent': userAgent,
      'addedAt': DateTime.now().toIso8601String(),
    });
    return token;
  }

  Future<void> clearAll() async {
    final box = Hive.box(_boxName);
    await box.clear();
  }
}