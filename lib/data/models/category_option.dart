class CategoryOption {
  const CategoryOption({required this.slug, required this.name});

  final String slug;
  final String name;

  static List<CategoryOption> listFromJson(Map<String, dynamic> json) =>
      json.entries
          .map((e) => CategoryOption(slug: e.key, name: e.value as String))
          .toList();
}
