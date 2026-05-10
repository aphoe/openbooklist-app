class BookmarkDetail {
  const BookmarkDetail({
    required this.id,
    required this.domain,
    required this.tags,
    this.title,
    this.description,
    this.imageUrl,
    this.category,
    this.dateAdded,
  });

  final int id;
  final String domain;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? category;
  final List<String> tags;
  final String? dateAdded;

  factory BookmarkDetail.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category'];
    String? categoryName;
    if (rawCategory is Map && rawCategory.isNotEmpty) {
      categoryName = rawCategory.values.first as String?;
    }

    final rawTags = json['tags'];
    final tagList = <String>[];
    if (rawTags is Map) {
      tagList.addAll(rawTags.values.map((v) => v.toString()));
    }

    return BookmarkDetail(
      id: json['id'] as int,
      domain: json['domain'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      category: categoryName,
      tags: tagList,
      dateAdded: json['date_added'] as String?,
    );
  }
}
