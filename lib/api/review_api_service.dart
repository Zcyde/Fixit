import 'dart:convert';
import 'package:http/http.dart' as http;
import 'review_model.dart';

class ReviewApiService {

  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  static Future<List<Review>> fetchReviews() async {
    try {

      final response = await http.get(
        Uri.parse('$baseUrl/comments?_limit=10'), 
      );


      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<Review> reviews = jsonData
            .map((json) => Review.fromJson(json))
            .toList();
        
        return reviews;
      } else {

        throw Exception('Failed to load reviews. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  static Future<List<Review>> fetchReviewsWithDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    return fetchReviews();
  }
}
