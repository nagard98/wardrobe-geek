import 'package:esempio/models/article_model.dart';
import 'package:flutter/widgets.dart';

enum Season {estate, inverno, primavera, autunno, qualsiasi}
enum DressCode {casual, formalCasual, informale, streetwear, businessCasual, altro}

class OutfitModel {
  int? id;
  int? idUser;
  List<ArticleModel>? articles;
  Season? season;
  DressCode? dressCode;
  int? likes = 0;
  String? imgPath;
  DateTime? addedOn;
  bool? favorite = false;

  OutfitModel(
      {this.id,
      this.articles,
      this.season,
      this.dressCode,
      this.idUser,
      this.addedOn,
      this.favorite,
      this.likes,
      this.imgPath});
}