import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

/// Model untuk merepresentasikan satu pertanyaan kuis.
class Kuis {
  final String idPertanyaan;
  final String pertanyaan;
  final List<String> pilihan;
  final int jawabanBenarIndex;
  final String pembahasan;

  Kuis({
    required this.idPertanyaan,
    required this.pertanyaan,
    required this.pilihan,
    required this.jawabanBenarIndex,
    required this.pembahasan,
  });

  /// Factory constructor untuk membuat instance Kuis dari JSON Map.
  factory Kuis.fromJson(Map<String, dynamic> json) {
    return Kuis(
      idPertanyaan: json['id_pertanyaan'] ?? '',
      pertanyaan: json['pertanyaan'] ?? 'Pertanyaan tidak ditemukan',
      pilihan: List<String>.from(json['pilihan'] ?? []),
      jawabanBenarIndex: json['jawaban_benar_index'] ?? 0,
      pembahasan: json['pembahasan'] ?? 'Tidak ada pembahasan.',
    );
  }
}

/// Model untuk merepresentasikan satu topik materi, termasuk konten dan kuisnya.
class Topik {
  final String topikId;
  final String judulTopik;

  /// Diubah ke 'dynamic' untuk mengakomodasi 'konten' yang bisa berupa
  /// List (untuk materi biasa) ATAU Map (untuk Topik "Kamus").
  final dynamic konten;

  final List<Kuis> kuis;

  Topik({
    required this.topikId,
    required this.judulTopik,
    required this.konten,
    required this.kuis,
  });

  /// Factory constructor untuk membuat instance Topik dari JSON Map.
  factory Topik.fromJson(Map<String, dynamic> json) {
    // Mem-parse list kuis
    var kuisListFromJson = json['kuis'] as List? ?? [];
    List<Kuis> kuisList = kuisListFromJson
        .map((k) => Kuis.fromJson(k))
        .toList();

    return Topik(
      topikId: json['topik_id'] ?? '',
      judulTopik: json['judul_topik'] ?? 'Tanpa Judul',

      // Mengambil 'konten' apa adanya, tanpa casting ke tipe tertentu.
      // Ini akan menjadi List atau Map tergantung data JSON-nya.
      konten: json['konten'],

      kuis: kuisList,
    );
  }
}

/// Model utama yang membungkus keseluruhan materi PBM.
class PBMMateri {
  final String judulMateri;
  final List<Topik> rangkumanTopik;

  PBMMateri({required this.judulMateri, required this.rangkumanTopik});

  /// Factory constructor untuk membuat instance PBMMateri dari JSON Map.
  factory PBMMateri.fromJson(Map<String, dynamic> json) {
    var list = json['rangkuman_topik'] as List? ?? [];
    List<Topik> topikList = list.map((t) => Topik.fromJson(t)).toList();

    return PBMMateri(
      judulMateri: json['judul_materi'] ?? 'Materi',
      rangkumanTopik: topikList,
    );
  }
}

/// Fungsi helper untuk me-load dan mem-parse materi dari file JSON di assets.
Future<PBMMateri> loadMateri() async {
  // Ganti 'assets/pbm_materi.json' jika path file Anda berbeda
  final String response = await rootBundle.loadString('assets/pbm_materi.json');
  final data = await json.decode(response);
  return PBMMateri.fromJson(data);
}
