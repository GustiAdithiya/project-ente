import 'dart:convert';
import 'dart:developer';

import 'package:ente/config/config.dart';
import 'package:ente/model/bookmark_model.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';

class BookmarkService {
  final String apiUrl = Config().baseUrl; // Replace with your API URL

  Future<List<Bookmark>> fetchBookmarks(String id) async {
    final response = await get(Uri.parse('${apiUrl}bookmark/show/$id'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body)['data'];
      List<Bookmark> bookmark = body
          .map(
            (dynamic item) => Bookmark.fromJson(item),
          )
          .toList();
      return bookmark;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<bool> storeBookmark(String userId, String warungmakanId) async {
    final url = Uri.parse('${apiUrl}bookmark');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'user_id': userId,
      'warungmakan_id': warungmakanId,
    });
    EasyLoading.show(status: "Loading...");
    final response = await post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // Berhasil mengirim data
      EasyLoading.dismiss();
      EasyLoading.showSuccess("Bookmark Berhasil");
      return true;
    } else {
      // Gagal mengirim data
      EasyLoading.dismiss();
      EasyLoading.showError("Bookmark Gagal");
      log('Failed to input data: ${response.body}');
      return false;
    }
  }

  Future<bool> deleteBookmark(String id) async {
    final url = Uri.parse('${apiUrl}bookmark/delete/$id');

    final response = await delete(url);

    if (response.statusCode == 200) {
      // Berhasil menghapus data
      EasyLoading.dismiss();
      EasyLoading.showSuccess("Bookmark Dihapus");
      return true;
    } else {
      // Gagal menghapus data
      EasyLoading.dismiss();
      EasyLoading.showError("Bookmark Gagal Dihapus");
      log('Failed to delete data: ${response.body}');
      return false;
    }
  }
}
