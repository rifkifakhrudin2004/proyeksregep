import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:proyeksregep/models/article.dart';

class ArticleDialog {
  final BuildContext context;

  ArticleDialog(this.context);

  void show(Article article) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: InteractiveViewer(
            child: Center(
              child: CachedNetworkImage(
                imageUrl: article.imageUrl,
                fit: BoxFit.contain,
                height: MediaQuery.of(context).size.height * 0.8,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
        );
      },
    );
  }
}