import 'bookmark_category.dart';
import 'bookmark_tag.dart';

class Bookmark {
  const Bookmark({
    required this.id,
    required this.url,
    required this.domain,
    required this.favorite,
    required this.tags,
    this.title,
    this.description,
    this.imageUrl,
    this.category,
  });

  final int id;
  final String url;
  final String domain;
  final bool favorite;
  final List<BookmarkTag> tags;
  final String? title;
  final String? description;
  final String? imageUrl;
  final BookmarkCategory? category;

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
    id: json['id'] as int,
    url: json['url'] as String,
    domain: json['domain'] as String,
    favorite: (json['favorite'] as int) == 1,
    title: json['title'] as String?,
    description: json['description'] as String?,
    imageUrl: json['image_url'] as String?,
    category: json['category'] != null
        ? BookmarkCategory.fromJson(
            json['category'] as Map<String, dynamic>,
          )
        : null,
    tags: (json['tags'] as List<dynamic>)
        .map((t) => BookmarkTag.fromJson(t as Map<String, dynamic>))
        .toList(),
  );
}
