import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../data/models/bookmark.dart';

class BookmarksController extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();

  List<Bookmark> _bookmarks = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;

  List<Bookmark> get bookmarks => List.unmodifiable(_bookmarks);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _currentPage < _lastPage;

  Future<void> fetchBookmarks({int page = 1, String sort = 'newest'}) async {
    if (_isLoading) return;
    _isLoading = true;
    if (page == 1) _error = null;
    notifyListeners();

    try {
      final baseUrl = await _storage.read(key: 'baseUrl');
      final token = await _storage.read(key: 'authToken');
      if (baseUrl == null || token == null) {
        _error = 'Not authenticated.';
        return;
      }

      final uri = Uri.parse('$baseUrl/api/v1/app/bookmarks?page=$page&sort=$sort');
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final items = (body['data'] as List<dynamic>)
            .map((j) => Bookmark.fromJson(j as Map<String, dynamic>))
            .toList();
        if (page == 1) {
          _bookmarks = items;
        } else {
          _bookmarks = [..._bookmarks, ...items];
        }
        _currentPage = body['current_page'] as int;
        _lastPage = body['last_page'] as int;
      } else {
        _error =
            'Failed to load bookmarks (HTTP ${response.statusCode}).';
      }
    } catch (e) {
      log('BookmarksController: $e');
      _error = 'Could not connect to server.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh({String sort = 'newest'}) =>
      fetchBookmarks(sort: sort);

  Future<void> loadMore({String sort = 'newest'}) async {
    if (!hasMore || _isLoading) return;
    await fetchBookmarks(page: _currentPage + 1, sort: sort);
  }
}
