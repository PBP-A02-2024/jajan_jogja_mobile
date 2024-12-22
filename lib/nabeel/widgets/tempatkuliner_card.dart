import 'package:flutter/material.dart';
import 'package:jajan_jogja_mobile/iyan/models/resto.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jajan_jogja_mobile/marco/screens/restaurant.dart';

class TempatKulinerCard extends StatelessWidget {
  final TempatKuliner tempatKuliner;
  final String url = '';

  const TempatKulinerCard({
    super.key,
    required this.tempatKuliner,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    RestaurantPage(idTempatKuliner: tempatKuliner.pk)));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFC98809), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(500),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: tempatKuliner.fields.fotoLink,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey,
                        child: Center(
                          child: Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(500),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(tempatKuliner.fields.rating.toString()),
                        const SizedBox(width: 4),
                        Icon(Icons.star, color: Color(0xFFEFB11D), size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 8),
            Text(
              tempatKuliner.fields.nama,
              style: TextStyle(
                color: Color(0xFF7C1D05),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            // const SizedBox(height: 4),
            Text(
              tempatKuliner.fields.alamat,
              style: TextStyle(
                color: Color(0xFF7A7A7A),
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
