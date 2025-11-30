import 'package:shared_preferences/shared_preferences.dart';
import '../database/hive_database.dart';

class ProgressService {
  static const String _keyPrefix = 'progress_';
  static final _db = HiveDatabase(); // ambil email user dari Hive

  /// 🔹 Buat key unik berdasarkan email user
  static Future<String> _getUserKeyPrefix() async {
    final email = await _db.getCurrentUserEmail() ?? 'guest';
    return '$_keyPrefix$email-';
  }

  /// Simpan progress dari suatu topik
  static Future<void> saveProgress(
    String topikId,
    int index,
    bool completed,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = await _getUserKeyPrefix();
    await prefs.setBool('$prefix$topikId-$index', completed);
  }

  /// Ambil status progress dari topik tertentu
  static Future<bool> getProgress(String topikId, int index) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = await _getUserKeyPrefix();
    return prefs.getBool('$prefix$topikId-$index') ?? false;
  }

  /// Hapus semua progress dari satu topik
  static Future<void> clearProgress(String topikId) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = await _getUserKeyPrefix();
    final keys = prefs.getKeys().where((k) => k.startsWith('$prefix$topikId'));
    for (final k in keys) {
      await prefs.remove(k);
    }
  }

  /// 🔥 Ambil total progress keseluruhan
  static Future<double> getOverallProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = await _getUserKeyPrefix();
    final keys = prefs.getKeys().where((k) => k.startsWith(prefix)).toList();

    if (keys.isEmpty) return 0.0;

    int completedCount = 0;
    for (final key in keys) {
      final isDone = prefs.getBool(key) ?? false;
      if (isDone) completedCount++;
    }

    final progress = completedCount / keys.length;

    // 🔹 Sinkronkan dengan Hive (update progress total user)
    final email = await _db.getCurrentUserEmail();
    if (email != null) {
      await _db.saveUserProgress(email, progress);
    }

    return progress;
  }

  /// Ambil progress untuk 1 topik tertentu
  static Future<double> getTopicProgress(String topikId) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = await _getUserKeyPrefix();
    final keys = prefs
        .getKeys()
        .where((k) => k.startsWith('$prefix$topikId'))
        .toList();

    if (keys.isEmpty) return 0.0;

    int completedCount = 0;
    for (final key in keys) {
      final isDone = prefs.getBool(key) ?? false;
      if (isDone) completedCount++;
    }

    return completedCount / keys.length;
  }

  /// 🧹 Hapus semua progress user saat ini (dipanggil saat logout)
  static Future<void> clearAllUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = await _getUserKeyPrefix();
    final keys = prefs.getKeys().where((k) => k.startsWith(prefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
