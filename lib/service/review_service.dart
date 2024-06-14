import 'dart:convert';
import 'dart:developer';
import 'package:ente/config/config.dart';
import 'package:ente/model/review_model.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';

class ReviewService {
  final String baseUrl = Config().baseUrl; // Ganti dengan URL API yang sesuai

  Future<Review?> fetchReview(String userId, String warungmakanId) async {
    try {
      final response = await get(Uri.parse('${baseUrl}rating/show/$userId'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body)['data'];

        var filteredReviews =
            data.where((review) => review['warungmakan_id'] == warungmakanId);

        if (filteredReviews.isNotEmpty) {
          return Review.fromJson(filteredReviews.first);
        } else {
          return null;
        }
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      log('Error fetching review: $e');
      throw Exception('Error fetching review');
    }
  }

  Future<bool> storeReview(String userId, String name, String review,
      int rating, String warungmakanId) async {
    final response = await post(
      Uri.parse('${baseUrl}rating'),
      body: {
        'user_id': userId,
        'name': name,
        'review': review,
        'rating': rating.toString(),
        'status': "0",
        'warungmakan_id': warungmakanId,
      },
    );

    log(response.body);
    if (response.statusCode == 200) {
      EasyLoading.dismiss();
      EasyLoading.showSuccess("Review Berhasil");
      return true;
    } else {
      EasyLoading.dismiss();
      EasyLoading.showError("Review Gagal");
      log('Failed to input data: ${response.body}');
      return false;
    }
  }
}
