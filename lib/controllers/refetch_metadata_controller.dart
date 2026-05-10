import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class RefetchMetadataController {
  static const _storage = FlutterSecureStorage();

  Future<String?> call(int bookmarkId) async {
    try {
      final baseUrl = await _storage.read(key: 'baseUrl');
      final token = await _storage.read(key: 'authToken');
      if (baseUrl == null || token == null) return 'Not authenticated.';

      final uri = Uri.parse(
        '$baseUrl/api/v1/app/bookmarks/$bookmarkId/refetch-metadata',
      );
      final response = await http.post(uri, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) return null;
      return 'Request failed (HTTP ${response.statusCode}).';
    } catch (e) {
      log('RefetchMetadataController: $e');
      return 'Could not connect to server.';
    }
  }
}
