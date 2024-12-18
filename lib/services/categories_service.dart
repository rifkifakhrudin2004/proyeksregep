import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:proyeksregep/models/categories_skincare.dart';

class CategoryService {
  static Future<List<SkincareCategory>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.0.102:8000/api/routine'));

      if (response.statusCode == 200) {
        final List<dynamic> categoryJson = json.decode(response.body);
        List<SkincareCategory> categories = categoryJson
            .map((json) => SkincareCategory.fromJson(json))
            .toList();

        // Insert a default 'Select Category' option
        categories.insert(
          0,
          SkincareCategory(
            id: 0, 
            categoryName: 'Select Category', 
            avatarUrl: ''
          )
        );

        return categories;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error fetching categories: ${e.toString()}');
    }
  }

  static Map<String, String> extractCategoryAvatars(List<SkincareCategory> categories) {
    return Map.fromIterable(
      categories,
      key: (cat) => cat.categoryName, 
      value: (cat) => cat.avatarUrl
    );
  }
}