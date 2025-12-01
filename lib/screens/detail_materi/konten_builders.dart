import 'package:flutter/material.dart';
import '../../models/docs_model.dart';
import 'konten_sections.dart';
import 'next_button.dart';

class KontenBody extends StatelessWidget {
  final Topik topik;
  final int subIndex;
  final Map<String, dynamic> kontenItem;

  const KontenBody({
    super.key,
    required this.topik,
    required this.subIndex,
    required this.kontenItem,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    kontenItem.forEach((key, value) {
      if (value == null) return;

      switch (key) {
        case 'sub_judul':
          children.add(_buildTitle(value));
          break;
        case 'aturan_id':
          // Show aturan_id as a section header (column header), not as the
          // larger sub-title. This keeps it visually inside the content box.
          children.add(_buildHeader(value.toString()));
          break;
        case 'sub_jenis':
          children.add(_buildSubJenis(value));
          break;
        case 'definisi':
          children.add(_buildContent("Definisi", value));
          break;
        case 'unsur':
          children.add(_buildContent("Unsur", value));
          break;
        case 'rumus':
          children.add(_buildContent("Rumus", value, monospace: true));
          break;
        case 'langkah':
          children.add(_buildContent("Langkah-langkah", value, bullet: '•'));
          break;
        case 'aturan':
          children.add(_buildContent("Aturan", value, bullet: '⚖️'));
          break;
        case 'penjelasan':
          children.add(_buildContent("Penjelasan", value));
          break;
        case 'contoh':
          children.add(_buildContent("Contoh", value, bullet: '•'));
          break;
        case 'catatan':
          children.add(_buildContent("Catatan", value, bullet: '📝'));
          break;
        case 'tips':
          children.add(_buildContent("Tips", value, bullet: '💡'));
          break;
        case 'daftar':
          children.add(_buildContent("Daftar", value, bullet: '•'));
        case 'daftar_kata':
          children.add(_buildDaftarKata(value));
          break;
        case 'kesimpulan':
          children.add(_buildContent("Kesimpulan", value, bullet: '✅'));
          break;
        default:
          children.add(_buildContent(key, value));
      }
    });

    children.add(const SizedBox(height: 30));
    children.add(NextButton(topik: topik, subIndex: subIndex));
    children.add(const SizedBox(height: 20));

    return ListView(padding: const EdgeInsets.all(16), children: children);
  }

  Widget _buildDaftarKata(dynamic daftar) {
    if (daftar == null) return const SizedBox();

    // If daftar is a list of maps with {baku, tidak_baku}
    if (daftar is List && daftar.isNotEmpty && daftar.first is Map && (daftar.first.containsKey('baku') || daftar.first.containsKey('tidak_baku'))) {
      final rows = <TableRow>[];
      rows.add(TableRow(children: [
        Padding(padding: const EdgeInsets.all(8), child: Text('Baku', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        Padding(padding: const EdgeInsets.all(8), child: Text('Tidak baku', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ]));
      for (var item in daftar) {
        if (item is Map) {
          rows.add(TableRow(children: [
            Padding(padding: const EdgeInsets.all(6), child: Text(item['baku']?.toString() ?? '', style: const TextStyle(color: Colors.white70))),
            Padding(padding: const EdgeInsets.all(6), child: Text(item['tidak_baku']?.toString() ?? '', style: const TextStyle(color: Colors.white70))),
          ]));
        }
      }

      return BaseContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader('Daftar Kata'),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
                children: rows,
              ),
            ),
          ],
        ),
      );
    }

    // If daftar is a map with lists {baku: [...], tidak_baku: [...]}
    if (daftar is Map && (daftar.containsKey('baku') || daftar.containsKey('tidak_baku'))) {
      final bakuList = (daftar['baku'] is List) ? List.from(daftar['baku']) : <dynamic>[];
      final tidakList = (daftar['tidak_baku'] is List) ? List.from(daftar['tidak_baku']) : <dynamic>[];
      final maxRows = bakuList.length > tidakList.length ? bakuList.length : tidakList.length;

      final rows = <TableRow>[];
      rows.add(TableRow(children: [
        Padding(padding: const EdgeInsets.all(8), child: Text('Baku', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        Padding(padding: const EdgeInsets.all(8), child: Text('Tidak baku', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ]));

      for (var i = 0; i < maxRows; i++) {
        rows.add(TableRow(children: [
          Padding(padding: const EdgeInsets.all(6), child: Text(i < bakuList.length ? bakuList[i].toString() : '', style: const TextStyle(color: Colors.white70))),
          Padding(padding: const EdgeInsets.all(6), child: Text(i < tidakList.length ? tidakList[i].toString() : '', style: const TextStyle(color: Colors.white70))),
        ]));
      }

      return BaseContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader('Daftar Kata'),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)}, children: rows),
            ),
          ],
        ),
      );
    }

    // Fallback: show as a list or string
    if (daftar is List) {
      return BaseContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader('Daftar Kata'),
            const SizedBox(height: 8),
            ...daftar.map<Widget>((d) => _buildBulletLine(d.toString(), '•', false)),
          ],
        ),
      );
    }

    if (daftar is String) {
      return BaseContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader('Daftar Kata'),
            const SizedBox(height: 8),
            Text(daftar, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildSubJenis(dynamic value) {
    if (value is! List) return const SizedBox();

    return BaseContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Sub Jenis'),
          const SizedBox(height: 8),
          ...value.map<Widget>((item) {
            if (item == null) return const SizedBox();
            if (item is Map) {
              final nama = item['nama']?.toString();
              final daftar = item['daftar'];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (nama != null)
                      Text(
                        nama,
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    if (daftar is List) ...[
                      const SizedBox(height: 8),
                      ...daftar.map<Widget>((d) => _buildBulletLine(d.toString(), '•', false)),
                    ] else if (daftar is String) ...[
                      const SizedBox(height: 8),
                      _buildBulletLine(daftar, '•', false),
                    ],
                  ],
                ),
              );
            }

            return _buildBulletLine(item.toString(), '•', false);
          }).toList(),
        ],
      ),
    );
  }

  // 🔹 Judul submateri
  Widget _buildTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.orangeAccent,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
    );
  }

  // 🔹 Konten utama builder (bisa string atau list)
  Widget _buildContent(
    String title,
    dynamic value, {
    String bullet = '•',
    bool monospace = false,
  }) {
    if (value is List) {
      // If the list contains maps (e.g. [{istilah:..., deskripsi:...}])
      // render each map as a small titled section. Otherwise render
      // as bullet lines.
      return BaseContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(title),
            const SizedBox(height: 8),
            ...value.map<Widget>((item) {
              if (item == null) return const SizedBox();

              // If item is a map with 'istilah'/'deskripsi' or common keys,
              // render a compact section: bold small title + description.
              if (item is Map) {
                // Special handling for rumus-like maps that contain a
                // 'formula' key: render formula bold + monospace and
                // show contoh/pengecualian as bullets beneath it.
                if (item.containsKey('formula')) {
                  final formula = item['formula']?.toString();
                  final contoh = item['contoh'];
                  final pengecualian = item['pengecualian'];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (formula != null) ...[
                          Text(
                            formula,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (contoh is List) ...[
                          ...contoh.map<Widget>((c) => _buildBulletLine(c.toString(), '•', false)),
                        ] else if (contoh is String) ...[
                          _buildBulletLine(contoh, '•', false),
                        ],
                        if (pengecualian is List) ...[
                          const SizedBox(height: 6),
                          ...pengecualian.map<Widget>((p) => _buildBulletLine(p.toString(), '⚠️', false)),
                        ] else if (pengecualian is String) ...[
                          const SizedBox(height: 6),
                          _buildBulletLine(pengecualian, '⚠️', false),
                        ],
                      ],
                    ),
                  );
                }

                final maybeTitle =
                    item['istilah'] ?? item['judul'] ?? item['nama'];
                final maybeDesc =
                    item['deskripsi'] ?? item['keterangan'] ?? item['definisi'];

                if (maybeTitle != null || maybeDesc != null) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (maybeTitle != null)
                          Text(
                            maybeTitle.toString(),
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        if (maybeDesc != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            maybeDesc.toString(),
                            style: const TextStyle(
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                // Generic map fallback: show key: value lines
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: item.entries.map<Widget>((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$bullet ",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "${e.key}: ${e.value}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }

              // Strings or other primitives — render as bullet lines
              return _buildBulletLine(item.toString(), bullet, monospace);
            }),
          ],
        ),
      );
    } else if (value is String) {
      return BaseContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(title),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: Colors.white70,
                height: 1.5,
                fontFamily: monospace ? 'monospace' : null,
                fontSize: monospace ? 15 : 14,
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  // 🔹 Header kecil per bagian
  Widget _buildHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  // 🔹 Baris dengan bullet
  Widget _buildBulletLine(String text, String bullet, bool monospace) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$bullet ",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white70,
                fontSize: monospace ? 15 : 14,
                height: 1.5,
                fontFamily: monospace ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}