import 'package:hive_flutter/hive_flutter.dart';
import '../models/payment_history.dart';

class HistoryService {
  static const String boxName = 'paymentHistoryBox';

  /// Simpan riwayat transaksi baru berdasarkan email
  static Future<void> addHistory(String email, PaymentHistory history) async {
    final box = await Hive.openBox(boxName);

    // Ambil list transaksi untuk user ini
    final allHistories = box.get(email, defaultValue: <Map<String, dynamic>>[]);

    // Tambahkan transaksi baru
    allHistories.add(history.toJson());

    // Simpan balik ke Hive
    await box.put(email, allHistories);
  }

  /// Ambil semua riwayat transaksi user berdasarkan email
  static Future<List<PaymentHistory>> getHistory(String email) async {
    final box = await Hive.openBox(boxName);
    final List<dynamic> data = box.get(email, defaultValue: []);
    return data
        .map((e) => PaymentHistory.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Hapus semua riwayat transaksi user ini
  static Future<void> clearHistory(String email) async {
    final box = await Hive.openBox(boxName);
    await box.delete(email);
  }

  /// Hapus semua data di box (opsional, kalau mau reset total)
  static Future<void> clearAll() async {
    final box = await Hive.openBox(boxName);
    await box.clear();
  }
}
