import 'dart:developer';
import 'package:esempio/models/article_model.dart';
import 'package:esempio/models/profile_model.dart';
import 'package:esempio/models/wardrobe_model.dart';
import 'package:esempio/common/utils.dart' as utils;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:esempio/common/utils.dart';

enum BooleanOp {and, or}

class ArticleDBWorker {
  ArticleDBWorker._();

  static final ArticleDBWorker articleDBWorker = ArticleDBWorker._();

  Database? _db;

  Future<Database?> _getDB() async {
    if (_db == null) {
      String path = join(utils.docsDir.path, "wardrobe_geek3.db");
      _db = await openDatabase(path, version: 1,
          onCreate: (Database inDB, int inVersion) async {
        await inDB.execute('CREATE TABLE IF NOT EXISTS articles ('
            'idArticle INTEGER PRIMARY KEY,'
            'idUser INTEGER NOT NULL,'
            'imgPath TEXT NOT NULL,'
            'articleName TEXT NOT NULL,'
            'primColor INTEGER NOT NULL,'
            'secColor INTEGER NULL,'
            'brand INTEGER NOT NULL,'
            'clothingType INTEGER NOT NULL,'
            'fav INTEGER NOT NULL)');

        await inDB.execute('CREATE TABLE IF NOT EXISTS outfits ('
            'idOutfit INTEGER PRIMARY KEY,'
            'idUser INTEGER NOT NULL,'
            'season INTEGER NOT NULL,'
            'likes INTEGER NOT NULL,'
            'imgPath TEXT NOT NULL,'
            'addedOn INTEGER NOT NULL,'
            'favorite INTEGER NOT NULL,'
            'dressCode INTEGER NOT NULL);');

        await inDB.execute('CREATE TABLE IF NOT EXISTS outfit_articles ('
            'idOutfit INTEGER NOT NULL,'
            'idArticle INTEGER NOT NULL,'
            'PRIMARY KEY(idOutfit, idArticle) );');
      });
    }
    return _db;
  }

  ArticleModel articleFromMap(Map<String,dynamic> ?map) {
    ArticleModel article = ArticleModel(
        id: map!['idArticle'] as int,
        articleName: map['articleName'] as String,
        imgPath: map['imgPath'] ?? "",
        primaryColor: Color(map['primColor'] as int),
        secondaryColor: Color(map['secColor'] as int),
        brand: map['brand'] as int,
        clothingType: map['clothingType'] as int ,
        favorite: map['fav'] == 0 ? false : true);
    return article;
  }

  Map<String,dynamic> articleToMap(ArticleModel article, int idUser){
    Map<String,dynamic> map = Map<String,dynamic>();
    map['idArticle'] = article.id;
    map['idUser'] = idUser;
    map['imgPath'] = article.imgPath;
    map['articleName'] = article.articleName;
    map['primColor'] = article.primaryColor!.value;
    map['secColor'] = article.secondaryColor?.value;
    map['brand'] = article.brand;
    map['clothingType'] = article.clothingType;
    map['fav'] = article.favorite! ? 1 : 0;

    return map;
  }

  create(ArticleModel article, int idUser) async {
    Database? db = await _getDB();

    var val =
        await _db?.rawQuery('SELECT MAX(idArticle)+1 AS id from articles');
    int nextId = val?.first['id'] == null ? 1 : val!.first['id'] as int;
    article.id = nextId;
    article.imgPath = join(utils.docsDir.path,'articles','${article.id}.jpg');

    return await _db?.rawInsert(
        'INSERT INTO articles (idArticle, idUser, imgPath, articleName, primColor, secColor, brand, clothingType, fav)'
        'VALUES (?,?,?,?,?,?,?,?,?)',
        [
          article.id,
          idUser,
          article.imgPath,
          article.articleName,
          article.primaryColor?.value,
          article.secondaryColor?.value,
          article.brand,
          article.clothingType,
          article.favorite
        ]);
  }

  Future<ArticleModel> get(int idArticle) async {
    Database? db = await _getDB();
    var rec =
        await _db?.query("articles", where: "idArticle=?", whereArgs: [idArticle]);
    return articleFromMap(rec?.first);
  }

  String _buildCondition(Filter filter, List filterArgs, BooleanOp operator){
    List conditions = [];
    filterArgs.forEach((element) {
      switch (filter){
        case Filter.clothingType:
          conditions.add("clothingType='$element'");
          break;
        case Filter.brand:
          conditions.add("brand='$element'");
          break;
        case Filter.primColor:
          conditions.add("primColor='$element'");
          break;
        case Filter.secColor:
          conditions.add("secColor='$element'");
          break;
        case Filter.fav:
          conditions.add("fav='$element'");
      }
    });
    log(conditions.toString());
    String op = operator==BooleanOp.and ? " AND " : " OR ";
    return conditions.isEmpty ? "" : '(${conditions.join(op)})';

  }

  Future<List<dynamic>?> getAll(int idUser, {Map<Filter,List> filters=const {} } ) async {
    Database? db = await _getDB();
    List<Map<String, Object?>>? recs;
    if(filters.isEmpty){
      recs = await _db?.query('articles',where: 'idUser=?', whereArgs: [idUser]);
    }else{
      Map<Filter,String> stringedFilters = filters.map((key, value) => MapEntry(key,_buildCondition(key, value, BooleanOp.or)) );
      log(stringedFilters.toString());
      List cleanedFilters = stringedFilters.values.toList();

      log("Before: $cleanedFilters");
      cleanedFilters.removeWhere((element) => element=="");
      cleanedFilters.add("idUser='${idUser}'");
      log("After: $cleanedFilters");

      recs = await _db?.rawQuery('SELECT * FROM articles '
          'WHERE ${cleanedFilters.join(" AND ")}');

    }
    var list = recs == null ? [] : recs.map((m) => articleFromMap(m)).toList();
    return list;
  }

  update(ArticleModel article, int idUser) async {
    Database? db = await _getDB();
    return await _db?.update('articles', articleToMap(article, idUser), where: 'idArticle=?', whereArgs: [article.id]);
  }

  delete(int idArticle) async {
    Database? db = await _getDB();
    return await _db?.delete('articles', where: 'idArticle=?', whereArgs: [idArticle]);
  }
}
