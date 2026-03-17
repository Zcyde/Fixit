import 'dart:convert';
import 'package:http/http.dart' as http;
import 'review_model.dart';

class ReviewApiService {
  static const String baseUrl = 'https://dummyjson.com';

  static Future<List<Review>> fetchReviews({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/comments?limit=$limit'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> commentsList = jsonData['comments'] as List<dynamic>;
        return commentsList
            .map((item) => Review.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load reviews. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  static Future<List<Review>> fetchReviewsWithDelay({int limit = 10}) async {
    await Future.delayed(const Duration(seconds: 2));
    return fetchReviews(limit: limit);
  }
}
