import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../models/quiz_history.dart';

class QuizHistoryService {
  static const _kGlobalKey = 'quiz_history';

  static String _keyForEmail(String email) => 'quiz_history:email:$email';
  static String _keyForUsername(String username) => 'quiz_history:user:$username';

  /// Add a quiz history entry. If [q.email] is set we store it under a per-user key.
  static Future<void> add(QuizHistory q) async {
    final prefs = await SharedPreferences.getInstance();
    final key = (q.username != null && q.username!.isNotEmpty)
      ? _keyForUsername(q.username!)
      : (q.email != null && q.email!.isNotEmpty)
        ? _keyForEmail(q.email!)
        : _kGlobalKey;
    final raw = prefs.getStringList(key) ?? [];
    raw.add(jsonEncode(q.toJson()));
    await prefs.setStringList(key, raw);
    // Notify listeners that a new history entry was added.
    try {
      _controller.add(q);
    } catch (_) {}
  }

  /// Return all entries stored under the global key (legacy). Prefer [allFor]
  /// to get per-user entries.
  static Future<List<QuizHistory>> all() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kGlobalKey) ?? [];
    return raw.map((s) => QuizHistory.fromJson(jsonDecode(s))).toList();
  }

  /// Return quiz history for a specific [email]. If no entries found, returns empty list.
  static Future<List<QuizHistory>> allFor(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keyForEmail(email)) ?? [];
    return raw.map((s) => QuizHistory.fromJson(jsonDecode(s))).toList();
  }

  /// Return quiz history for a specific username. If no entries found, returns empty list.
  static Future<List<QuizHistory>> allForUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keyForUsername(username)) ?? [];
    return raw.map((s) => QuizHistory.fromJson(jsonDecode(s))).toList();
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kGlobalKey);
  }

  static Future<void> clearFor(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyForEmail(email));
  }

  static Future<void> clearForUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyForUsername(username));
  }

  // Broadcast stream for listeners who want live updates when history changes.
  static final StreamController<QuizHistory> _controller = StreamController<QuizHistory>.broadcast();

  /// Stream that emits the newly added [QuizHistory] when `add` is called.
  static Stream<QuizHistory> get onChanged => _controller.stream;
}
