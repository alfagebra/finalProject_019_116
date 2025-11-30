import 'package:flutter/material.dart';
import '../utils/palette.dart';

class NextButton extends StatelessWidget {
  final bool isLastSub;
  final VoidCallback onNext;

  const NextButton({
    super.key,
    required this.isLastSub,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Palette.accent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        icon: Icon(isLastSub ? Icons.school : Icons.arrow_forward,
            color: Colors.white),
        label: Text(
          isLastSub
                ? "Lanjut ke Ujian Bab Ini"
              : "Lanjut ke Materi Selanjutnya",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onPressed: onNext,
      ),
    );
  }
}
