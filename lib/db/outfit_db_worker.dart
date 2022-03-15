import 'dart:developer';

import 'package:esempio/models/article_model.dart';
import 'package:esempio/models/outfit_model.dart';
import 'package:esempio/models/wardrobe_model.dart';
import 'package:esempio/common/utils.dart' as utils;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:esempio/db/article_db_worker.dart';
import 'package:collection/collection.dart' as Coll;


class Combo{
  var Outfit;
  List articles = [];
}

class OutfitDBWorker {
  OutfitDBWorker._();

  static final OutfitDBWorker outfitDBWorker = OutfitDBWorker._();

  Database? _db;

  Future<Database?> _getDB() async {
    if (_db == null) {
      String path = join(utils.docsDir.path, "wardrobe_geek3.db");
      _db = await openDatabase(path, version: 1,
          onCreate: (Database inDB, int inVersion) async {
            //TODO: Aggiungere foreign key
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

            //TODO:Aggiungere foreign key
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
          });
    }
    return _db;
  }

  ArticleModel articleFromMap(Map<String,dynamic> ?map) {
    ArticleModel article = ArticleModel(
        id: map!['idArticle'] as int,
        idUser: map['idUser'] as int,
        articleName: map['articleName'] ?? '',
        imgPath: map['artImg'] ?? "",
        primaryColor: Color(map['primColor'] as int),
        secondaryColor: Color(map['secColor'] as int),
        brand: Brand.values[map['brand'] as int],
        clothingType: ClothingType.values[map['clothingType'] as int] ,
        favorite: map['fav'] == 0 ? false : true);
    return article;
  }

  OutfitModel outfitFromMap(String key, List value) {
    List<ArticleModel> articles = value == null
        ? []
        : value.map((a) => articleFromMap(a)).toList();

    log(articles.toString());
    Map<String,dynamic> map = value.first;

    OutfitModel outfit = OutfitModel(
        id: map['idOutfit'] as int,
        idUser: map['idUser'],
        articles: articles,
        imgPath: map['otfImg'] ?? "",
        season: Season.values[map['season']],
        dressCode: DressCode.values[map['dressCode']],
        likes: map['likes'],
        addedOn: DateTime.fromMillisecondsSinceEpoch(
            ((map['addedOn']).toInt() * 1000).toInt()),
        favorite: map['favorite'] == 0 ? false : true);

    log(outfit.toString());
    return outfit;
  }

  Map<String, dynamic> outfitToMap(OutfitModel outfit, int idUser) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['idOutfit'] = outfit.id;
    map['idUser'] = idUser;
    map['imgPath'] = outfit.imgPath;
    map['dressCode'] = outfit.dressCode?.index;
    map['addedOn'] = (outfit.addedOn?.millisecondsSinceEpoch)!/1000;
    map['favorite'] = outfit.favorite == true ? 1 : 0;
    map['likes'] = outfit.likes;
    map['season'] = outfit.season?.index;

    return map;
  }

  create(OutfitModel outfit, int idUser) async {
    Database? db = await _getDB();

    var val = await _db?.rawQuery('SELECT MAX(idOutfit)+1 AS id from outfits');
    int nextId = val?.first['id'] == null ? 1 : val!.first['id'] as int;
    outfit.id = nextId;
    outfit.imgPath = join(utils.docsDir.path,'outfits', '${outfit.id}.jpg');

    outfit.articles?.forEach((article) async {
      await _db?.rawInsert(
          'INSERT or REPLACE INTO outfit_articles (idOutfit, idArticle)'
              'VALUES (?,?)',
          [outfit.id, article.id]);
    });

    return await _db?.rawInsert(
        'INSERT INTO outfits (idOutfit, idUser, imgPath, dressCode, addedOn, favorite, likes, season)'
            'VALUES (?,?,?,?,?,?,?,?)',
        [
          outfit.id,
          idUser,
          outfit.imgPath,
          outfit.dressCode?.index,
          DateTime
              .now()
              .millisecondsSinceEpoch / 1000,
          outfit.favorite,
          outfit.likes,
          outfit.season?.index,
        ]);
  }

  Future<OutfitModel> get(int idOutfit) async {
    Database? db = await _getDB();
    var rec =
    await _db?.query("outfits", where: "idOutfit=?", whereArgs: [idOutfit]);
    //TODO: implementa metodo get in db correttamente
    return OutfitModel();//outfitFromMap(rec?.first);
  }

  Future<List<dynamic>?> getAll(int idUser) async {
    Database? db = await _getDB();
    var recs = await _db?.rawQuery('SELECT outfits.idOutfit,outfits.idUser,articles.idArticle,outfits.imgPath as otfImg,season,likes,addedOn,favorite,dressCode,articles.imgPath as artImg,primColor,secColor,brand,clothingType,fav '
        'FROM outfits,outfit_articles,articles '
        'WHERE outfits.idUser=${idUser} AND outfits.idOutfit=outfit_articles.idOutfit AND articles.idArticle=outfit_articles.idArticle');

    Map<String,dynamic> map = {};
    recs?.forEach((element) {
      log(element.toString());
      map.putIfAbsent(element['idOutfit'].toString(), () => []);
      (map[element['idOutfit'].toString()] as List).add(element);
    });
    List<OutfitModel> list = [];
    map.forEach( (key, value) => list.add(outfitFromMap(key, value)) );
    log(list.toString());
    return list;
  }

  Future test(int id) async{
    return await _db?.rawQuery('SELECT *'
        'FROM outfits '
        'WHERE outfits.idUser=${id}');
  }

  Future test2(var recs) async{
    return await _db?.rawQuery('SELECT *'
        'FROM outfit_articles,articles '
        'WHERE articles.idArticle=outfit_articles.idArticle');
  }

  update(OutfitModel outfit, int idUser) async {
    Database? db = await _getDB();
    return await _db?.update('outfits', outfitToMap(outfit, idUser),
        where: 'idOutfit=?', whereArgs: [outfit.id]);
  }

  delete(int idOutfit) async {
    Database? db = await _getDB();
    return await _db
        ?.delete('outfits', where: 'idOutfit=?', whereArgs: [idOutfit]);
  }
}
