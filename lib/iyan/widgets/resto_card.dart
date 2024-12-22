import 'package:flutter/material.dart';
import 'package:jajan_jogja_mobile/iyan/models/resto.dart';
import 'package:jajan_jogja_mobile/iyan/screens/edit_tempat_kuliner.dart';
import 'package:jajan_jogja_mobile/marco/screens/restaurant.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class CardTempat extends StatelessWidget {
  final TempatKuliner tempatKuliner;
  final bool isAdmin;
  final CookieRequest request;
  final VoidCallback onDelete;

  const CardTempat(
    this.tempatKuliner, {
    super.key,
    required this.isAdmin,
    required this.request,
    required this.onDelete,
  });

  Future<void> deleteTempatKuliner(CookieRequest request, String uuid) async {
    final response = await request.post(
      'https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id/adm/delete-resto-flutter/$uuid/',
      {},
    );

    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Gagal menghapus tempat kuliner');
    }
  }

  @override
  Widget build(BuildContext context) {
    final idTempatKuliner = tempatKuliner.pk; // UUID (String)
    final nama = tempatKuliner.fields.nama;
    final alamat = tempatKuliner.fields.alamat;
    final rating = double.parse(tempatKuliner.fields.rating);
    final fotoLink = tempatKuliner.fields.fotoLink;

    return GestureDetector(
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RestaurantPage(idTempatKuliner: idTempatKuliner),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFC88709), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border:
                        Border.all(color: const Color(0xFFC88709), width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      fotoLink,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  nama,
                  style: const TextStyle(
                    color: Color(0xFF7C1D04),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alamat,
                  style: const TextStyle(
                    color: Color(0xFF7C1D04),
                    fontSize: 9.94,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('$rating/5'),
                    const Icon(Icons.star, color: Color(0xFFEFB11D)),
                  ],
                ),
                const SizedBox(height: 8),
                if (isAdmin)
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditTempatKuliner(id: idTempatKuliner),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC88709),
                        ),
                        child: const Text(
                          'Edit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Konfirmasi"),
                              content: const Text(
                                  "Apakah Anda yakin ingin menghapus tempat ini?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Batal"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Hapus"),
                                ),
                              ],
                            ),
                          );

                          if (shouldDelete == true) {
                            try {
                              await deleteTempatKuliner(
                                  request, idTempatKuliner);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Berhasil dihapus")),
                              );
                              onDelete();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Gagal menghapus tempat kuliner: $e")),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE43D12),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
