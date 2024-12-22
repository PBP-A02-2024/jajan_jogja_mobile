import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class ReviewEntryFormPage extends StatefulWidget {
  final String tempatKulinerId;
  final String tempatKulinerNama;

  const ReviewEntryFormPage({
    super.key,
    required this.tempatKulinerId,
    required this.tempatKulinerNama,
  });

  @override
  State<ReviewEntryFormPage> createState() => _ReviewEntryFormPageState();
}

class _ReviewEntryFormPageState extends State<ReviewEntryFormPage> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 1;

  // Update this to your actual backend URL
  final String baseUrl = "https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id";

  // Variable to hold the Future for submission
  Future<void>? _submitFuture;

  Future<void> _submitReview() async {
    if (_rating < 1 || _rating > 5 || _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a valid rating and comment.'),
        ),
      );
      return;
    }

    final request = context.read<CookieRequest>();
    final url = "$baseUrl/review/create-review-flutter/";
    final payload = json.encode(<String, dynamic>{
      "tempat_kuliner_id": widget.tempatKulinerId,
      "rating": _rating,
      "comment": _commentController.text.trim(),
    });

    try {
      final response = await request.post(url, payload);

      if (response is Map && response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review added successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response is Map
                  ? response['message'] ?? 'Failed to add review.'
                  : 'Failed to add review.',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding review: $e')),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return IconButton(
          icon: Icon(
            starIndex <= _rating ? Icons.star : Icons.star_border,
            color: const Color(0xFFFFD401),
            size: 32,
          ),
          onPressed: () {
            setState(() {
              _rating = starIndex;
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBE9E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEBE9E1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F0401)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Add Review for ${widget.tempatKulinerNama}",
          style: const TextStyle(color: Color(0xFF0F0401)),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<void>(
        future: _submitFuture,
        builder: (context, snapshot) {
          // While the future is running, show a loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // After the future completes, show the form
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD6536D), width: 2),
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFFFFF9F9),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Rating',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD6536D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStarRating(),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Comment',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD6536D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Write your review here...',
                      border: OutlineInputBorder(),
                      fillColor: Color(0xFFFFFFFF),
                      filled: true,
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          // Assign the future to trigger FutureBuilder
                          _submitFuture = _submitReview();
                        });
                      },
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: const Text('Submit Review'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE43D12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
