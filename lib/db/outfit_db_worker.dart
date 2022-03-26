import 'dart:developer';
import 'package:esempio/models/article_model.dart';
import 'package:esempio/models/outfit_model.dart';
import 'package:esempio/common/utils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:esempio/db/article_db_worker.dart';

class OutfitDBWorker {
  OutfitDBWorker._();

  static final OutfitDBWorker outfitDBWorker = OutfitDBWorker._();

  Database? _db;

  Future<Database?> _getDB() async {
    if (_db == null) {
      String path = join(docsDir.path, "wardrobe_geek6.db");
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
            'numWished INTEGER NOT NULL,'
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
            'fav INTEGER NOT NULL);');

        await inDB.execute('CREATE TABLE IF NOT EXISTS profiles ('
            'id INTEGER PRIMARY KEY,'
            'email TEXT NOT NULL UNIQUE,'
            'password TEXT NOT NULL,'
            'name TEXT NOT NULL,'
            'surname TEXT NOT NULL,'
            'city TEXT NULL,'
            'nation TEXT NULL,'
            'level INTEGER NOT NULL,'
            'pathPicture TEXT NULL);');

        await inDB.execute('CREATE TABLE IF NOT EXISTS outfit_wishlist ('
            'idUser INTEGER NOT NULL,'
            'idOutfit INTEGER NOT NULL,'
            'PRIMARY KEY(idUser, idOutfit) );');

        await inDB.execute('CREATE TABLE IF NOT EXISTS profile_follows ('
            'idFollower INTEGER NOT NULL,'
            'idFollowed INTEGER NOT NULL,'
            'PRIMARY KEY(idFollower, idFollowed) );');

        await inDB.execute('CREATE TABLE IF NOT EXISTS like_outfit ('
            'idUser INTEGER NOT NULL,'
            'idOutfit INTEGER NOT NULL,'
            'PRIMARY KEY(idUser, idOutfit) );');
      });
    }
    return _db;
  }

  void updateDatabase() async {
    Database? db = await _getDB();
    await _db?.execute('CREATE TABLE IF NOT EXISTS like_outfit ('
        'idUser INTEGER NOT NULL,'
        'idOutfit INTEGER NOT NULL,'
        'PRIMARY KEY(idUser, idOutfit) );');

    log("Database Updated");
  }

  ArticleModel articleFromMap(Map<String, dynamic>? map) {
    ArticleModel article = ArticleModel(
        id: map!['idArticle'] as int,
        idUser: map['idUser'] as int,
        articleName: map['articleName'] ?? '',
        imgPath: map['artImg'] ?? "",
        primaryColor: Color(map['primColor'] as int),
        secondaryColor: Color(map['secColor'] as int),
        brand: map['brand'] as int,
        clothingType: map['clothingType'] as int,
        favorite: map['fav'] == 0 ? false : true);
    return article;
  }

  OutfitModel outfitFromMap(String key, List value,{int idOwner=-1}) {
    List<ArticleModel> articles =
        value == null ? [] : value.map((a) => articleFromMap(a)).toList();

    log(articles.toString());
    Map<String, dynamic> map = value.first;

    OutfitModel outfit = OutfitModel(
        id: map['idOutfit'] as int,
        idUser: map['idUser'],
        articles: articles,
        imgPath: map['otfImg'] ?? "",
        season: map['season'] as int,
        dressCode: map['dressCode'] as int,
        likes: map['likes'],
        addedOn: DateTime.fromMillisecondsSinceEpoch(
            ((map['addedOn']).toInt() * 1000).toInt()),
        isWishlisted: map['wishlistedBy']==null ? false : (idOwner==map['wishlistedBy']),
        favorite: map['favorite'] == 0 ? false : true);

    log(outfit.toString());
    return outfit;
  }

  Map<String, dynamic> outfitToMap(OutfitModel outfit, int idUser) {
    Map<String, dynamic> map = <String, dynamic>{};
    map['idOutfit'] = outfit.id;
    map['idUser'] = idUser;
    map['imgPath'] = outfit.imgPath;
    map['dressCode'] = outfit.dressCode;
    map['addedOn'] = (outfit.addedOn?.millisecondsSinceEpoch)! / 1000;
    map['favorite'] =  outfit.favorite == true ? 1 : 0;
    map['likes'] = outfit.likes ?? 0;
    map['season'] = outfit.season;

    return map;
  }

  String _buildOrder(Order order){
    String orderString = "";
    switch (order){
      case Order.ascDate:
        orderString="ORDER BY addedOn DESC";
        break;
      case Order.desDate:
        orderString="ORDER BY addedOn ASC";
        break;
      case Order.desPop:
        orderString="ORDER BY likes DESC";
        break;
      case Order.ascPop:
        orderString="ORDER BY likes ASC";
        break;
    }
    return orderString;
  }

  String _buildCondition(Filter filter, List filterArgs, BooleanOp operator) {
    List conditions = [];
    for (var element in filterArgs) {
      switch (filter) {
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
          break;
        case Filter.season:
          conditions.add("season='$element'");
          break;
        case Filter.like:
          conditions.add("like='$element'");
          break;
        case Filter.dressCode:
          conditions.add("dressCode='$element'");
          break;
        case Filter.favorite:
          conditions.add("favorite='$element'");
          break;
      }
    }
    log(conditions.toString());
    String op = operator == BooleanOp.and ? " AND " : " OR ";
    return conditions.isEmpty ? "" : '(${conditions.join(op)})';
  }


  create(OutfitModel outfit, int idUser, {bool isWishlist = false, bool isLikes=false}) async {
    Database? db = await _getDB();

    if(isLikes){
      return await _db?.rawInsert(
        'INSERT INTO like_outfit (idOutfit, idUser)'
            'VALUES (?,?)',
        [outfit.id, idUser],
      );
    }else if (isWishlist) {
      return await _db?.rawInsert(
        'INSERT INTO outfit_wishlist (idOutfit, idUser)'
        'VALUES (?,?)',
        [outfit.id, idUser],
      );
    } else {
      var val =
          await _db?.rawQuery('SELECT MAX(idOutfit)+1 AS id from outfits');
      int nextId = val?.first['id'] == null ? 1 : val!.first['id'] as int;
      outfit.id = nextId;

      outfit.articles?.forEach((article) async {
        await _db?.rawInsert(
            'INSERT or REPLACE INTO outfit_articles (idOutfit, idArticle)'
            'VALUES (?,?)',
            [outfit.id, article.id]);
      });

      await _db?.rawInsert(
          'INSERT INTO outfits (idOutfit, idUser, imgPath, dressCode, addedOn, favorite, likes, season, numWished)'
          'VALUES (?,?,?,?,?,?,?,?,?)',
          [
            outfit.id,
            idUser,
            outfit.imgPath,
            outfit.dressCode,
            DateTime.now().millisecondsSinceEpoch / 1000,
            outfit.favorite ?? false,
            outfit.likes ?? 0,
            outfit.season,
            0,
          ]);

      return outfit.id;
    }
  }


  Future<OutfitModel> get(int idOutfit, int idOwner) async {
    Database? db = await _getDB();
    /*var rec =
        await _db?.query("outfits", where: "idOutfit=?", whereArgs: [idOutfit]);*/
    //TODO: implementa metodo get in db correttamente
    var rec = await _db?.rawQuery(
        'SELECT * FROM (SELECT outfits.idOutfit,outfits.idUser,articles.idArticle,outfits.imgPath as otfImg,season,likes,addedOn,favorite,dressCode,articles.imgPath as artImg,primColor,secColor,brand,clothingType,fav '
            'FROM outfits,outfit_articles,articles '
            'WHERE outfits.idOutfit="$idOutfit" AND outfits.idOutfit=outfit_articles.idOutfit AND articles.idArticle=outfit_articles.idArticle) as r '
            'LEFT JOIN (SELECT idOutfit as wishOutfit, idUser as wishlistedBy FROM outfit_wishlist) as w ON r.idOutfit=w.wishOutfit');

    Map<String, dynamic> map = {};
    rec?.forEach((element) {
      log(element.toString());
      map.putIfAbsent(element['idOutfit'].toString(), () => []);
      (map[element['idOutfit'].toString()] as List).add(element);
    });
    List<OutfitModel> list = [];
    map.forEach((key, value) => list.add(outfitFromMap(key, value, idOwner: idOwner)));
    log(list.toString());

    return list.first; //outfitFromMap(rec?.first);
  }


  Future<List<OutfitModel>> getAll(int idUserSearch,
      {bool inWishlist = false, Order order=Order.ascDate, Map<Filter, List> filters = const {}, int idOwner = -1}) async {
    Database? db = await _getDB();
    List<Map<String, Object?>>? recs;
    String userIdCondition = idUserSearch == -1 ? "" : "outfits.idUser='$idUserSearch'";

    if (inWishlist && idOwner>-1) {
      Map<Filter, String> stringedFilters = filters.map((key, value) =>
          MapEntry(key, _buildCondition(key, value, BooleanOp.or)));
      log(stringedFilters.toString());
      List cleanedFilters = stringedFilters.values.toList();

      log("Before: $cleanedFilters");
      cleanedFilters.removeWhere((element) => element == "");
      cleanedFilters.add(userIdCondition);
      log("After: $cleanedFilters");

      //Prende solo gli outfit che fanno parte della wishlist
      recs = await _db?.rawQuery(
          'SELECT * FROM (SELECT outfits.idOutfit,outfits.idUser,articles.idArticle,outfits.imgPath as otfImg,season,likes,addedOn,favorite,dressCode,articles.imgPath as artImg,primColor,secColor,brand,clothingType,fav '
          'FROM outfit_wishlist,outfits,outfit_articles,articles '
          'WHERE ${cleanedFilters.join(" AND ")} ${userIdCondition.isEmpty ? "" : "AND"} outfits.idOutfit=outfit_articles.idOutfit AND articles.idArticle=outfit_articles.idArticle AND outfit_wishlist.idOutfit=outfits.idOutfit) as r '
              'LEFT JOIN (SELECT idOutfit as wishOutfit, idUser as wishlistedBy FROM outfit_wishlist) as w ON r.idOutfit=w.wishOutfit ${_buildOrder(order)}');
    } else if (filters.isEmpty) {
      recs = await _db?.rawQuery(
          'SELECT * FROM (SELECT outfits.idOutfit,outfits.idUser,articles.idArticle,outfits.imgPath as otfImg,season,likes,addedOn,favorite,dressCode,articles.imgPath as artImg,primColor,secColor,brand,clothingType,fav '
          'FROM outfits,outfit_articles,articles '
          'WHERE $userIdCondition ${userIdCondition.isEmpty ? "" : "AND"} outfits.idOutfit=outfit_articles.idOutfit AND articles.idArticle=outfit_articles.idArticle) as r '
              'LEFT JOIN (SELECT idOutfit as wishOutfit, idUser as wishlistedBy FROM outfit_wishlist) as w ON r.idOutfit=w.wishOutfit ${_buildOrder(order)}');
    } else {
      Map<Filter, String> stringedFilters = filters.map((key, value) =>
          MapEntry(key, _buildCondition(key, value, BooleanOp.or)));
      log(stringedFilters.toString());
      List cleanedFilters = stringedFilters.values.toList();

      log("Before: $cleanedFilters");
      cleanedFilters.removeWhere((element) => element == "");
      cleanedFilters.add(userIdCondition);
      log("After: $cleanedFilters");

      recs = await _db?.rawQuery(
          'SELECT * FROM (SELECT outfits.idOutfit,outfits.idUser,articles.idArticle,outfits.imgPath as otfImg,season,likes,addedOn,favorite,dressCode,articles.imgPath as artImg,primColor,secColor,brand,clothingType,fav '
          'FROM outfits,outfit_articles,articles '
          'WHERE ${cleanedFilters.join(" AND ")} ${userIdCondition.isEmpty ? "" : "AND"} outfits.idOutfit=outfit_articles.idOutfit AND articles.idArticle=outfit_articles.idArticle) as r '
              'LEFT JOIN (SELECT idOutfit as wishOutfit, idUser as wishlistedBy FROM outfit_wishlist) as w ON r.idOutfit=w.wishOutfit ${_buildOrder(order)}');
    }

    Map<String, dynamic> map = {};
    recs?.forEach((element) {
      log(element.toString());
      map.putIfAbsent(element['idOutfit'].toString(), () => []);
      (map[element['idOutfit'].toString()] as List).add(element);
      log('Data Aggiunta: ${element['addedOn'].toString()}');
    });
    List<OutfitModel> list = [];
    map.forEach((key, value) => list.add(outfitFromMap(key, value, idOwner: idOwner)));
    log(list.toString());
    return list;
  }

  update(OutfitModel outfit, int idUser, {int isWishNum=0}) async {
    Database? db = await _getDB();

    if(isWishNum>0){
      return await _db?.rawUpdate("UPDATE outfits SET numWished=numWished+1 WHERE idOutfit='${outfit.id}'");
    }else if(isWishNum<0){
      return await _db?.rawUpdate("UPDATE outfits SET numWished=numWished-1 WHERE idOutfit='${outfit.id}'");
    }else{
      //aggiorna outfit
      await _db?.update('outfits', outfitToMap(outfit, idUser),
          where: 'idOutfit=?', whereArgs: [outfit.id]);

      //rimuove vecchi articoli
      await _db?.delete('outfit_articles', where: 'idOutfit=?', whereArgs: [outfit.id]);

      //aggiunge nuovi articoli
      outfit.articles?.forEach((article) async {
        await _db?.rawInsert(
            'INSERT or REPLACE INTO outfit_articles (idOutfit, idArticle)'
                'VALUES (?,?)',
            [outfit.id, article.id]);
      });
    }

  }

  delete(int idOutfit, {bool isLikes=false, bool isWishlist=false, int idUser=-1}) async {
    Database? db = await _getDB();

    if(isWishlist){
      return await _db
          ?.delete('outfit_wishlist', where: 'idOutfit=? AND idUser=?', whereArgs: [idOutfit, idUser]);
    }else if(isLikes){
      return await _db
          ?.delete('like_outfit', where: 'idOutfit=? AND idUser=?', whereArgs: [idOutfit, idUser]);
    }else{
      return await _db
          ?.delete('outfits', where: 'idOutfit=?', whereArgs: [idOutfit]);
    }

  }
}
