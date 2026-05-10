class BookmarkTag {
  const BookmarkTag({
    required this.id,
    required this.name,
    required this.slug,
  });

  final int id;
  final String name;
  final String slug;

  factory BookmarkTag.fromJson(Map<String, dynamic> json) => BookmarkTag(
    id: json['id'] as int,
    name: json['name'] as String,
    slug: json['slug'] as String,
  );
}
