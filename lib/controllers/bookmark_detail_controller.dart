import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../data/models/bookmark_detail.dart';

class BookmarkDetailController extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();

  BookmarkDetail? _detail;
  bool _isLoading = false;
  String? _error;

  BookmarkDetail? get detail => _detail;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetch(int bookmarkId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final baseUrl = await _storage.read(key: 'baseUrl');
      final token = await _storage.read(key: 'authToken');
      if (baseUrl == null || token == null) {
        _error = 'Not authenticated.';
        return;
      }

      final uri = Uri.parse('$baseUrl/api/v1/app/bookmarks/$bookmarkId');
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        _detail = BookmarkDetail.fromJson(body);
      } else {
        _error = 'Failed to load bookmark (HTTP ${response.statusCode}).';
      }
    } catch (e) {
      log('BookmarkDetailController: $e');
      _error = 'Could not connect to server.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
