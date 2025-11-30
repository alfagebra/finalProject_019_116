import 'package:flutter/material.dart';

class BaseContainer extends StatelessWidget {
  final Widget child;
  const BaseContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF012D5A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF012D5A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "Belum ada materi di bagian ini.",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}
