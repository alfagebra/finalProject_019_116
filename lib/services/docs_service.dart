import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/docs_model.dart';
import 'package:flutter/foundation.dart';

class DocsService {
  static PBMMateri? _cachedMateri;

  /// Load PBM materi from bundled JSON. Uses an in-memory cache to avoid
  /// re-parsing the asset repeatedly which can cause UI jank when called
  /// multiple times during navigation or state changes.
  static Future<PBMMateri> loadPBMMateri({bool forceReload = false}) async {
    if (!forceReload && _cachedMateri != null) {
      debugPrint(
        '♻️ Returning cached PBMMateri (${_cachedMateri!.rangkumanTopik.length} topics)',
      );
      return _cachedMateri!;
    }
    try {
      // Pastikan file ada dan bisa dimuat
      final jsonString = await rootBundle.loadString(
        'assets/data/pbm_materi.json',
      );

      // Decode JSON
      final dynamic parsed = jsonDecode(jsonString);
      final Map<String, dynamic> jsonData = Map<String, dynamic>.from(parsed);

      // 🔍 Log detail untuk debugging
      debugPrint("✅ JSON berhasil dimuat: ${jsonData['judul_materi']}");
      if (jsonData['rangkuman_topik'] is List) {
        final topikList = jsonData['rangkuman_topik'] as List;
        debugPrint("📚 Jumlah topik: ${topikList.length}");
        if (topikList.isNotEmpty) {
          debugPrint(
            "🧩 Contoh topik pertama: ${topikList.first['judul_topik']}",
          );
        }
      } else {
        debugPrint("⚠️ 'rangkuman_topik' bukan List di JSON!");
      }

      // Konversi ke model Dart
      final materi = PBMMateri.fromJson(jsonData);
      debugPrint("✅ Model PBMMateri berhasil dibuat: ${materi.judulMateri}");
      _cachedMateri = materi;
      return materi;
    } catch (e, stack) {
      debugPrint("❌ Gagal memuat JSON: $e");
      debugPrint(stack.toString());
      throw Exception("Gagal memuat JSON: $e");
    }
  }

  /// Clear in-memory cache (useful for debugging or if you replace the
  /// bundled asset at runtime in development).
  static void clearCache() {
    _cachedMateri = null;
  }
}
