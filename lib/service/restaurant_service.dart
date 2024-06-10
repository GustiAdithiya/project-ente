import 'dart:convert';
import 'dart:developer';

import 'package:ente/config/config.dart';
import 'package:ente/model/restaurant_model.dart';
import 'package:http/http.dart';

class RestaurantService {
  final String apiUrl =
      "${Config().baseUrl}getTempatMakan"; // Replace with your actual API URL
  Future<List<Restaurant>> fetchRestaurants() async {
    final response = await get(Uri.parse(apiUrl));

    log(apiUrl);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => Restaurant.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load restaurants');
    }
  }
}
