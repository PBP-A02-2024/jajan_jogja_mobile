import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/review.dart';

class ReviewsListWidget extends StatefulWidget {
  final String tempatKulinerId;
  final ValueKey<int> theKey;

  const ReviewsListWidget(
      {super.key, required this.tempatKulinerId, required this.theKey});

  @override
  State<ReviewsListWidget> createState() => _ReviewsListWidgetState();
}

class _ReviewsListWidgetState extends State<ReviewsListWidget> {
  late Future<List<Review>> _futureReviews;
  late Future<Map<String, dynamic>?> _futureCurrentUser;

  final String baseUrl = "https://farrel-reksa-jajanjogja.pbp.cs.ui.ac.id";

  @override
  void initState() {
    super.initState();
    _futureReviews = _fetchReviews(widget.tempatKulinerId);
    _futureCurrentUser = _getCurrentUserId();
  }

  Future<List<Review>> _fetchReviews(String id) async {
    final request = context.read<CookieRequest>();
    final url = "$baseUrl/review/get-reviews-flutter/$id/";
    try {
      final response = await request.get(url);

      if (response is List) {
        return response.map((e) => Review.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> _getCurrentUserId() async {
    final request = context.read<CookieRequest>();
    final response = await request.get('$baseUrl/get-current-user-id/');
    if (response is Map<String, dynamic>) {
      return response;
    }
    return null;
  }

  Future<void> _deleteReview(int reviewId) async {
    final request = context.read<CookieRequest>();
    final url = "$baseUrl/review/delete-review-flutter/$reviewId/";

    final response = await request.post(url, jsonEncode(<String, String>{}));

    if (response is Map && response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review deleted successfully.')),
      );
      setState(() {
        _futureReviews = _fetchReviews(widget.tempatKulinerId);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response is Map
                ? response['message'] ?? 'Failed to delete review.'
                : 'Failed to delete review.')),
      );
    }
  }

  Future<void> _updateReview(Review review) async {
    final request = context.read<CookieRequest>();
    final url = "$baseUrl/review/update-review-flutter/${review.id}/";

    final updatedData = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        int rating = review.rating;
        String comment = review.comment;

        return AlertDialog(
          title: const Text('Update Review'),
          content: StatefulBuilder(
            builder: (context, setStateSB) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return IconButton(
                        icon: Icon(
                          starIndex <= rating ? Icons.star : Icons.star_border,
                          color: Color(0xFFFFD401),
                        ),
                        onPressed: () {
                          setStateSB(() {
                            rating = starIndex;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: comment,
                    decoration: const InputDecoration(
                      labelText: 'Comment',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      comment = value;
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (rating >= 1 && rating <= 5 && comment.trim().isNotEmpty) {
                  Navigator.pop(
                      context, {"rating": rating, "comment": comment});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please provide valid inputs.')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (updatedData != null) {
      final response = await request.post(
          url,
          jsonEncode(<String, dynamic>{
            'rating': updatedData['rating'],
            'comment': updatedData['comment'],
          }));
      if (response is Map && response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review updated successfully.')),
        );
        setState(() {
          _futureReviews = _fetchReviews(widget.tempatKulinerId);
        });
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response is Map
                  ? response['message'] ?? 'Failed to update review.'
                  : 'Failed to update review.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: _futureReviews,
      builder: (context, snapshotReviews) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: _futureCurrentUser,
          builder: (context, snapshotUser) {
            if (snapshotReviews.connectionState == ConnectionState.waiting ||
                snapshotUser.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshotReviews.hasError) {
              return _errorContainer('Error loading reviews.');
            }

            if (snapshotUser.hasError) {
              return _errorContainer('Error loading user information.');
            }

            final reviews = snapshotReviews.data;
            if (reviews == null || reviews.isEmpty) {
              return _noDataContainer('No reviews yet.');
            }

            final currentUserId = snapshotUser.data?['user_id'];
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: reviews.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final review = reviews[index];
                final isCurrentUser = currentUserId == review.userId;

                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFFD6536D), width: 2),
                    borderRadius: BorderRadius.circular(24),
                    color: const Color(0xFFFFF9F9),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: [
                          Text(
                            "${review.userUsername} rated this place: ${review.rating}/5",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7C1D05),
                            ),
                          ),
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFFD401),
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        review.comment,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0F0401),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Posted on: ${(review.createdAt)}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7A7A7A),
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _updateReview(review),
                              icon: const Icon(Icons.edit,
                                  color: Color(0xFF0F0401)),
                              label: const Text(
                                'Edit',
                                style: TextStyle(color: Color(0xFF0F0401)),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirm Delete'),
                                    content: const Text(
                                        'Are you sure you want to delete this review?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  _deleteReview(review.id);
                                }
                              },
                              icon: const Icon(Icons.delete,
                                  color: Color(0xFFE43D12)),
                              label: const Text(
                                'Delete',
                                style: TextStyle(color: Color(0xFFE43D12)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _errorContainer(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD6536D), width: 2),
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFFFFEEEE),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Color(0xFFD6536D)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _noDataContainer(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD6536D), width: 2),
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFFFFF4F4),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Color(0xFF7A7A7A)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
