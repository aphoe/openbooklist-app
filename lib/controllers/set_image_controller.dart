import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SetImageController {
  static const _storage = FlutterSecureStorage();

  Future<String?> call({
    required int bookmarkId,
    required String imageSource,
    String? imageUrl,
  }) async {
    try {
      final baseUrl = await _storage.read(key: 'baseUrl');
      final token = await _storage.read(key: 'authToken');
      if (baseUrl == null || token == null) return 'Not authenticated.';

      final uri = Uri.parse(
        '$baseUrl/api/v1/app/bookmarks/$bookmarkId/set-image',
      );

      final body = <String, String>{
        'image_source': imageSource,
        if (imageSource == 'url' && imageUrl != null) 'image_url': imageUrl,
      };

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) return null;
      return 'Request failed (HTTP ${response.statusCode}).';
    } catch (e) {
      log('SetImageController: $e');
      return 'Could not connect to server.';
    }
  }
}
