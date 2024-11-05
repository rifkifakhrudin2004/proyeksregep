import 'package:flutter/material.dart';
import 'package:proyeksregep/models/article.dart';

class ArticleWidget extends StatelessWidget {
  final Article article;

  ArticleWidget({required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Menampilkan gambar dari assets
          Image.asset(article.imageUrl), // Menggunakan Image.asset
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(article.content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
