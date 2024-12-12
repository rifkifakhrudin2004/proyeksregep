import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyeksregep/models/article.dart';

class ArticleService {
final String baseUrl = 'http://192.168.0.102:8000/api/articles';

  Future<List<Article>> fetchArticles() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        List<Article> articles = body.map((dynamic item) => Article.fromJson(item)).toList();
        return articles;
      } else {
        throw Exception('Failed to load articles');
      }
    } catch (e) {
      print('Error fetching articles: $e');
      return [];
    }
  }
}