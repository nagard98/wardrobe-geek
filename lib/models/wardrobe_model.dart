import 'dart:developer';
import 'package:esempio/models/profile_model.dart';
import 'package:esempio/db/article_db_worker.dart';
import 'package:esempio/models/article_model.dart';
import 'package:flutter/material.dart';
import 'package:esempio/common/utils.dart';

class WardrobeModel extends ChangeNotifier {
  List<ArticleModel>? articles = [];
  ArticleModel? currentArticle;
  bool isLoading = false;
  bool isEditing = false;
  Map<Filter,List> filters = {};

  void filter(ArticleDBWorker articleDBWorker, ProfileModel profile) async{
    isLoading = true;
    await Future.delayed(const Duration(milliseconds: 400), () {});
    articles = (await articleDBWorker.getAll(profile.id as int, filters: filters))?.cast<ArticleModel>();
    isLoading = false;
    notifyListeners();
  }

  bool addArticle(ArticleModel article) {
    //TODO: implementa aggiunta articolo
    throw UnimplementedError();
  }

  void updateArticle(ArticleDBWorker articleDBWorker, ArticleModel articleModel, ProfileModel profile,
      {bool withReload = true}) async{
    await articleDBWorker.update(articleModel, profile.id!);
    if(withReload) loadArticles(articleDBWorker, profile);
  }

  void removeArticle(ArticleDBWorker articleDBWorker, int idArticle ,ProfileModel profile) async{
    await articleDBWorker.delete(idArticle);
    loadArticles(articleDBWorker, profile);
  }

  void loadArticles(ArticleDBWorker articleDBWorker, ProfileModel profile) async {
    isLoading = true;
    await Future.delayed(const Duration(milliseconds: 500), () {});
    articles = (await articleDBWorker.getAll(profile.id as int))?.cast<ArticleModel>();
    isLoading = false;
    notifyListeners();
  }
}

WardrobeModel wardrobeModel = WardrobeModel();
