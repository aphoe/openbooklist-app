import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../data/models/category_option.dart';
import '../data/models/tag_option.dart';

class AddBookmarkController extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();

  List<CategoryOption> _categories = [];
  List<TagOption> _tags = [];
  bool _isLoadingMeta = false;
  String? _metaError;

  bool _isSubmitting = false;
  String? _submitError;

  List<CategoryOption> get categories => List.unmodifiable(_categories);
  List<TagOption> get tags => List.unmodifiable(_tags);
  bool get isLoadingMeta => _isLoadingMeta;
  String? get metaError => _metaError;

  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;

  Future<void> fetchMeta() async {
    _isLoadingMeta = true;
    _metaError = null;
    notifyListeners();

    try {
      final baseUrl = await _storage.read(key: 'baseUrl');
      final token = await _storage.read(key: 'authToken');
      if (baseUrl == null || token == null) {
        _metaError = 'Not authenticated.';
        return;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final results = await Future.wait([
        http.get(
          Uri.parse('$baseUrl/api/v1/app/bookmarks/categories'),
          headers: headers,
        ),
        http.get(
          Uri.parse('$baseUrl/api/v1/app/bookmarks/tags'),
          headers: headers,
        ),
      ]);

      final catResponse = results[0];
      final tagResponse = results[1];

      if (catResponse.statusCode == 200) {
        _categories = CategoryOption.listFromJson(
          jsonDecode(catResponse.body) as Map<String, dynamic>,
        );
      }
      if (tagResponse.statusCode == 200) {
        _tags = TagOption.listFromJson(
          jsonDecode(tagResponse.body) as Map<String, dynamic>,
        );
      }
      if (catResponse.statusCode != 200 || tagResponse.statusCode != 200) {
        _metaError =
            'Could not load form options. You can still add a bookmark.';
      }
    } catch (e) {
      log('AddBookmarkController.fetchMeta: $e');
      _metaError = 'Could not connect to server.';
    } finally {
      _isLoadingMeta = false;
      notifyListeners();
    }
  }

  /// Returns true on success, false on failure.
  Future<bool> submit({
    required String url,
    required String? categorySlug,
    required List<String> tagSlugs,
  }) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      final baseUrl = await _storage.read(key: 'baseUrl');
      final token = await _storage.read(key: 'authToken');
      if (baseUrl == null || token == null) {
        _submitError = 'Not authenticated.';
        return false;
      }

      final body = <String, dynamic>{'url': url};
      if (categorySlug != null) body['category'] = categorySlug;
      if (tagSlugs.isNotEmpty) body['tags'] = tagSlugs;

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/app/bookmarks'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      _submitError =
          'Failed to save bookmark (HTTP ${response.statusCode}).';
      return false;
    } catch (e) {
      log('AddBookmarkController.submit: $e');
      _submitError = 'Could not connect to server.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
