class TagOption {
  const TagOption({
    required this.slug,
    required this.name,
    this.isCustom = false,
  });

  final String slug;
  final String name;
  final bool isCustom;

  static List<TagOption> listFromJson(Map<String, dynamic> json) =>
      json.entries
          .map((e) => TagOption(slug: e.key, name: e.value as String))
          .toList();

  factory TagOption.custom(String text) => TagOption(
    slug: text.trim().toLowerCase().replaceAll(' ', '-'),
    name: text.trim(),
    isCustom: true,
  );
}
