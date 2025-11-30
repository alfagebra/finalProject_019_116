import 'package:intl/intl.dart';

/// Small currency formatting utilities used across the app.
class CurrencyUtils {
  /// Format an amount for display given a currency code.
  ///
  /// - For IDR/RP default to 0 decimal digits and use `Rp ` symbol.
  /// - For other currencies use `NumberFormat.simpleCurrency` with 2 decimals by default.
  /// - If [approximate] is true, the output is prefixed with '≈ '.
  static String format(
    double value,
    String currency, {
    bool approximate = false,
    int? decimalDigits,
  }) {
    try {
      final cur = currency.toUpperCase();
      String out;
      if (cur == 'IDR' || cur == 'RP') {
        final digits = decimalDigits ?? 0;
        final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: digits);
        out = fmt.format(value);
      } else {
        final digits = decimalDigits ?? 2;
        final fmt = NumberFormat.simpleCurrency(name: cur, decimalDigits: digits);
        out = fmt.format(value);
      }
      return approximate ? '≈ $out' : out;
    } catch (e) {
      final out = '$currency ${value.toStringAsFixed(decimalDigits ?? 2)}';
      return approximate ? '≈ $out' : out;
    }
  }

  /// Small helper to format a compact price for lists (no decimals for IDR).
  static String short(double value, String currency) => format(value, currency);
}
