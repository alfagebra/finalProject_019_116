import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const _apiUrl =
      'https://open.er-api.com/v6/latest/'; // API gratis & stabil

  // Cache sederhana biar nggak sering request ulang
  static final Map<String, Map<String, double>> _cache = {};

  /// 🔹 Fungsi konversi antar mata uang
  static Future<double> convertCurrency(
    double amount,
    String from,
    String to,
  ) async {
    try {
      // kalau sama, gak perlu konversi
      if (from == to) return amount;

      // cek cache dulu
      if (_cache.containsKey(from) && _cache[from]!.containsKey(to)) {
        final rate = _cache[from]![to]!;
        return amount * rate;
      }

      // fetch data dari API kurs
      final response = await http.get(Uri.parse("$_apiUrl$from"));
      if (response.statusCode != 200) {
        throw Exception("Failed to fetch rates");
      }

      final data = jsonDecode(response.body);
      final rates = Map<String, dynamic>.from(data["rates"]);

      // simpan cache
      _cache[from] = rates.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );

      // ambil rate ke 'to'
      if (!_cache[from]!.containsKey(to)) {
        throw Exception("Currency $to not available");
      }

      final rate = _cache[from]![to]!;
      return amount * rate;
    } catch (e) {
      throw Exception("Conversion failed: $e");
    }
  }
}
