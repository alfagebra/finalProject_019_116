import 'package:flutter/material.dart';
import '../utils/palette.dart';

class InformasiScreen extends StatelessWidget {
  const InformasiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const authorPhotoAsset = 'assets/images/Logo.png';
    const authorName = 'Eva Luthfia Ramadhani';
    const authorNIM = '124230116';
    const authorContact = 'evaluthfia23101187@gmail.com';
    const courseTitle = 'Pemograman Aplikasi Mobile';
    const kesanPesanBegut = 'Mata kuliah ini memberikan wawasan dan tantangan yang membantu pengembangan aplikasi mobile. Terima kasih kepada dosen dan teman-teman atas bimbingannya.';

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text('Informasi Pembuat', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Palette.primaryDark,
      ),
      backgroundColor: Palette.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
              child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Palette.primaryDark, borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Palette.accent.withOpacity(0.18),
                    backgroundImage: const AssetImage(authorPhotoAsset),
                  ),
                ),
                const SizedBox(height: 12),
                Center(child: Text(authorName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                const SizedBox(height: 6),
                Center(child: Text('NIM: $authorNIM', style: const TextStyle(color: Colors.white))),
                const SizedBox(height: 6),
                Center(child: Text(authorContact, style: const TextStyle(color: Colors.white))),
                const SizedBox(height: 12),
                const Divider(color: Colors.white12),
                const SizedBox(height: 12),
                Text('Kesan & Pesan Mata Kuliah', style: TextStyle(color: Palette.accent, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Mata Kuliah: $courseTitle', style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 6),
                Text(kesanPesanBegut, style: const TextStyle(color: Colors.white)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
