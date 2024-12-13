class SkincareCategory {
  final int id;
  final String categoryName;
  final String avatarUrl;

  SkincareCategory({
    required this.id,
    required this.categoryName,
    required this.avatarUrl,
  });

  factory SkincareCategory.fromJson(Map<String, dynamic> json) {
    return SkincareCategory(
      id: json['id'],
      categoryName: json['category_name'],
      avatarUrl: json['avatar_url'],
    );
  }
}