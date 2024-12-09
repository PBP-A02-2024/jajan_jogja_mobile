import 'package:flutter/material.dart';
import 'package:jajan_jogja_mobile/iyan/models/resto.dart';
import 'package:jajan_jogja_mobile/marco/screens/restaurant.dart'; // Import model TempatKuliner

class CardTempat extends StatelessWidget {
  final TempatKuliner tempatKuliner;

  const CardTempat(this.tempatKuliner, {super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil data dari model TempatKuliner
    final idTempatKuliner = tempatKuliner.pk;
    final nama = tempatKuliner.fields.nama;
    final alamat = tempatKuliner.fields.alamat;
    final rating = double.parse(tempatKuliner.fields.rating);
    final fotoLink = tempatKuliner.fields.fotoLink;

    return GestureDetector(
      onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RestaurantPage(idTempatKuliner: idTempatKuliner)),
          );
        },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto resto
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Color(0xFFC88709), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    fotoLink,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 100,
                  ),
                ),
              ),
              SizedBox(height: 8),
              // Nama tempat
              Text(
                nama,
                style: TextStyle(
                  color: Color(0xFF7C1D04),
                  fontSize: 13,
                  fontFamily: 'Jockey One',
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 4),
              // Alamat
              Text(
                alamat,
                style: TextStyle(
                  color: Color(0xFF7C1D04),
                  fontSize: 9.94,
                  fontFamily: 'Jockey One',
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 8),
              // Rating
              Row(
                children: [
                  Text(
                    '$rating/5',
                    style: TextStyle(
                      color: Color(0xFF7C1D04),
                      fontSize: 10,
                      fontFamily: 'Jockey One',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(
                    Icons.star,
                    color: Color(0xFFEFB11D),
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}