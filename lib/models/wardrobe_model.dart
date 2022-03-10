import 'dart:developer';
import 'package:esempio/models/profile_model.dart';
import 'package:provider/provider.dart';
import 'package:esempio/db/db_worker.dart';
import 'package:esempio/models/article_model.dart';
import 'package:flutter/material.dart';

class WardrobeModel extends ChangeNotifier {
  List<ArticleModel>? articles = [];
  ArticleModel? currentArticle;
  bool isLoading = false;
  bool isEditing = false;

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

  void loadArticles(ArticleDBWorker articleDBWorker, ProfileModel profile) async {
    isLoading = true;
    articles = (await articleDBWorker.getAll(profile.id as int))?.cast<ArticleModel>();
    await Future.delayed(Duration(seconds: 1), () {});
    isLoading = false;
    log(isLoading.toString());
    notifyListeners();
  }
}

WardrobeModel wardrobeModel = WardrobeModel();
