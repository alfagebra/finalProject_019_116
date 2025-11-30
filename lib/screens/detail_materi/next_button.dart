import 'package:flutter/material.dart';
import '../../models/docs_model.dart';
import '../ujian_screen.dart';
import '../detail_materi_screen.dart';
import '../../services/docs_service.dart';
import '../../services/progress_service.dart';

class NextButton extends StatelessWidget {
  final Topik topik;
  final int subIndex;

  const NextButton({super.key, required this.topik, required this.subIndex});

  @override
  Widget build(BuildContext context) {
    final bool isLastSub = subIndex == topik.konten.length - 1;

    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orangeAccent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        icon: Icon(
          isLastSub ? Icons.school : Icons.arrow_forward,
          color: Colors.white,
        ),
        label: Text(
          isLastSub
              ? "Lanjut ke Ujian Bab Ini"
              : "Lanjut ke Materi Selanjutnya",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onPressed: () async {
          if (isLastSub) {
            // Push the exam and wait for result so we can react (open next topik)
            final result = await Navigator.push<Map<String, dynamic>>(
              context,
              MaterialPageRoute(builder: (_) => UjianScreen(topik: topik)),
            );

            if (result != null && result['completed'] == true) {
              // try to load materi list and open next topik's first sub
              try {
                final materi = await DocsService.loadPBMMateri();
                final idx = materi.rangkumanTopik.indexWhere((t) => t.topikId == topik.topikId);
                final nextIdx = idx + 1;
                if (nextIdx >= 0 && nextIdx < materi.rangkumanTopik.length) {
                  final nextTopik = materi.rangkumanTopik[nextIdx];
                  Map<String, dynamic> firstContent = {};
                  if (nextTopik.konten is List && (nextTopik.konten as List).isNotEmpty) {
                    firstContent = (nextTopik.konten as List)[0] as Map<String, dynamic>;
                  } else if (nextTopik.konten is Map) {
                    firstContent = Map<String, dynamic>.from(nextTopik.konten as Map);
                  }

                  // Navigate to the next topik's first submateri
                  await Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailMateriScreen(
                        topik: nextTopik,
                        subIndex: 0,
                        kontenItem: firstContent,
                      ),
                    ),
                  );

                  // mark progress
                  try {
                    await ProgressService.saveProgress(nextTopik.topikId, 0, true);
                  } catch (_) {}
                } else {
                  // if no next topik, just pop back to previous
                }
              } catch (e) {
                debugPrint('⚠️ NextButton: gagal membuka materi berikutnya: $e');
              }
            }
          } else {
            final nextSubIndex = subIndex + 1;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => DetailMateriScreen(
                  topik: topik,
                  subIndex: nextSubIndex,
                  kontenItem: topik.konten[nextSubIndex],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
