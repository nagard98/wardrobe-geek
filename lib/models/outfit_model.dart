import 'package:esempio/models/article_model.dart';
import 'package:flutter/widgets.dart';

class OutfitModel {
  int? id;
  List<ArticleModel> articles;
  String season;
  String situation;
  String designer;
  int nLikes;
  List<Image> outfitImages;
  DateTime addedOn;
  bool favorite;

  OutfitModel(
      {this.id,
      required this.articles,
      required this.season,
      required this.situation,
      required this.designer,
      required this.addedOn,
      required this.favorite,
      required this.nLikes,
      required this.outfitImages});
}