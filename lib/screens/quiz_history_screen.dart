import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_app_bar.dart';
import '../services/quiz_history_service.dart';
import '../models/quiz_history.dart';
import '../database/hive_database.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({Key? key}) : super(key: key);

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  List<QuizHistory> _list = [];
  bool _loading = true;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _load();
    _sub = QuizHistoryService.onChanged.listen((_) {
      if (!mounted) return;
      _load();
    });
  }

  Future<void> _load() async {
    try {
      final hive = HiveDatabase();
      final email = await hive.getCurrentUserEmail();
      String? username;
      if (email != null && email.isNotEmpty) {
        username = await hive.getUsername(email);
      }
      final all = (username != null && username.isNotEmpty)
          ? await QuizHistoryService.allForUser(username)
          : (email != null && email.isNotEmpty)
              ? await QuizHistoryService.allFor(email)
              : await QuizHistoryService.all();
      setState(() {
        _list = all.reversed.toList();
        _loading = false;
      });
    } catch (e) {
      // fallback to global list
      final all = await QuizHistoryService.all();
      setState(() {
        _list = all.reversed.toList();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Riwayat Kuis',
        backgroundColor: Color(0xFF012D5A),
      ),
      backgroundColor: const Color(0xFF001F3F),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent),
            )
          : _list.isEmpty
          ? const Center(
              child: Text(
                'Belum ada riwayat kuis.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.separated(
              itemCount: _list.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white12),
              itemBuilder: (context, index) {
                final q = _list[index];
                final time = DateFormat(
                  'd MMM yyyy, HH:mm',
                  'id_ID',
                ).format(q.time);
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    time,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${q.correct} / ${q.total} benar',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Text(
                    '${((q.correct / q.total) * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
