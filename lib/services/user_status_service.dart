import 'package:flutter/foundation.dart';
import '../database/hive_database.dart';

class UserStatusService {
  static final HiveDatabase _db = HiveDatabase();

  /// Notifier for the current username (helps update UI immediately)
  static final ValueNotifier<String?> usernameNotifier = ValueNotifier(null);

  /// ✅ Cek apakah user saat ini premium
  static Future<bool> isPremium() async {
    final email = await _db.getCurrentUserEmail();
    if (email == null) return false;
    return await _db.isPremium(email);
  }

  /// ✅ Ambil username user saat ini
  static Future<String?> getUsername() async {
    final email = await _db.getCurrentUserEmail();
    if (email == null) return null;
    final u = await _db.getUsername(email);
    // update notifier
    usernameNotifier.value = u;
    return u;
  }

  /// Refresh username from DB and update notifier
  static Future<void> refreshUsername() async {
    final u = await getUsername();
    usernameNotifier.value = u;
  }

  /// ✅ Set status premium untuk user
  static Future<void> setPremium(bool value) async {
    final email = await _db.getCurrentUserEmail();
    debugPrint(
      '🔁 UserStatusService.setPremium called -> $value (email=$email)',
    );
    if (email == null) {
      debugPrint('⚠️ setPremium: no current email found');
      return;
    }
    await _db.setPremium(email, value);
    debugPrint('✅ UserStatusService.setPremium completed for $email -> $value');
  }

  /// ✅ Logout user — tanpa menghapus seluruh data Hive
  static Future<void> logout() async {
    final box = await _db.getUserBox();
    // hapus hanya current_email dan flag login
    await box.delete('current_email');
    await box.put('isLoggedIn', false);
  }
}
