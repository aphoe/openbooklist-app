class BookmarkCategory {
  const BookmarkCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  final int id;
  final String name;
  final String slug;

  factory BookmarkCategory.fromJson(Map<String, dynamic> json) =>
      BookmarkCategory(
        id: json['id'] as int,
        name: json['name'] as String,
        slug: json['slug'] as String,
      );
}
