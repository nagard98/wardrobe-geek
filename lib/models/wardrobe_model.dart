import 'dart:developer';
import 'package:provider/provider.dart';
import 'package:esempio/db/db_worker.dart';
import 'package:esempio/models/article_model.dart';
import 'package:flutter/material.dart';

class WardrobeModel extends ChangeNotifier {
  List<ArticleModel>? articles = [
    ArticleModel(
        articleName: "test",
        favorite: true,
        primaryColor: ArticleColor.blue,
        brand: Brand.armani,
        clothingType: ClothingType.camicia,
        secondaryColor: ArticleColor.pink)
  ];
  bool isLoading = false;

  List<ArticleModel> filter() {
    //TODO: implementa filtro
    throw UnimplementedError();
  }

  bool addArticle(ArticleModel article) {
    //TODO: implementa aggiunta articolo
    throw UnimplementedError();
  }

  bool removeArticle() {
    //TODO: implementa rimozione articoo
    throw UnimplementedError();
  }

  void loadArticles(ArticleDBWorker articleDBWorker) async {
    isLoading = true;
    //articles = (await articleDBWorker.getAll(1))?.cast<ArticleModel>();
    await Future.delayed(Duration(seconds: 6), () {});
    isLoading = false;
    log(isLoading.toString());
    notifyListeners();
  }
}

WardrobeModel wardrobeModel = WardrobeModel();
