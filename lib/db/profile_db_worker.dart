import 'dart:developer';
import 'package:esempio/models/article_model.dart';
import 'package:esempio/models/outfit_model.dart';
import 'package:esempio/common/utils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:esempio/db/article_db_worker.dart';
import 'package:esempio/models/profile_model.dart';

class ProfileDBWorker {
  ProfileDBWorker._();

  static final ProfileDBWorker profileDBWorker = ProfileDBWorker._();

  Database? _db;

  Future<Database?> _getDB() async {
    if (_db == null) {
      String path = join(docsDir.path, "wardrobe_geek3.db");
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

  ArticleModel articleFromMap(Map<String,dynamic> ?map) {
    ArticleModel article = ArticleModel(
        id: map!['idArticle'] as int,
        idUser: map['idUser'] as int,
        articleName: map['articleName'] ?? '',
        imgPath: map['artImg'] ?? "",
        primaryColor: Color(map['primColor'] as int),
        secondaryColor: Color(map['secColor'] as int),
        brand: map['brand'] as int,
        clothingType: map['clothingType'] as int ,
        favorite: map['fav'] == 0 ? false : true);
    return article;
  }

  Map<String,dynamic> profileToMap(ProfileModel profile){
    Map<String,dynamic> map = <String,dynamic>{};
    map['id'] = profile.id;
    map['email'] = profile.email;
    map['password'] = profile.password;
    map['name'] = profile.name;
    map['surname'] = profile.surname;
    map['city'] = profile.city;
    map['nation'] = profile.nation;
    map['level'] = profile.level;
    map['pathPicture'] = profile.pathPicture;

    return map;
  }

  ProfileModel profileFromMap(Map<String,dynamic> ?map) {
    ProfileModel profile = ProfileModel(
        id: map!['id'] as int,
        email: map['email'],
        password: map['password'],
        name: map['name'],
        surname: map['surname'],
        city: map['city'] ?? "",
        nation: map['nation'] ?? "",
        numFollower: map['numFollower'],
        numFollowing: map['numFollowing'],
        pathPicture: map['pathPicture'] ?? "default" ,
        level: map['level']);
    return profile;
  }

  Map<String, dynamic> outfitToMap(OutfitModel outfit, int idUser) {
    Map<String, dynamic> map = <String, dynamic>{};
    map['idOutfit'] = outfit.id;
    map['idUser'] = idUser;
    map['imgPath'] = outfit.imgPath;
    map['dressCode'] = outfit.dressCode;
    map['addedOn'] = (outfit.addedOn?.millisecondsSinceEpoch)!/1000;
    map['favorite'] = outfit.favorite == true ? 1 : 0;
    map['likes'] = outfit.likes;
    map['season'] = outfit.season;

    return map;
  }


  String _buildCondition(Filter filter, List filterArgs, BooleanOp operator){
    List conditions = [];
    for (var element in filterArgs) {
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
    String op = operator==BooleanOp.and ? " AND " : " OR ";
    return conditions.isEmpty ? "" : '(${conditions.join(op)})';
  }

  create(ProfileModel profile) async {
    Database? db = await _getDB();

    var val = await _db?.rawQuery('SELECT MAX(id)+1 AS id from profiles');
    int nextId = val?.first['id'] == null ? 1 : val!.first['id'] as int;
    profile.id = nextId;
    profile.pathPicture = join(docsDir.path,'profiles', '${profile.id}.jpg');


    return await _db?.rawInsert(
        'INSERT INTO profiles (id, email, password, name, surname, city, nation, level, pathPicture)'
            'VALUES (?,?,?,?,?,?,?,?,?)',
        [
          profile.id,
          profile.email,
          profile.password,
          profile.name,
          profile.surname,
          profile.city,
          profile.nation,
          profile.level,
          profile.pathPicture
        ]);
  }

  Future<ProfileModel?> get(String email, {String? password}) async {
    Database? db = await _getDB();
    if(password!=null){
      var rec = await _db?.query("profiles",
          where: "email=? AND password=?", whereArgs: [email, password]);
      if(rec!.isEmpty)return null;
      ProfileModel profile = profileFromMap(rec.first);
      return profile;
    }else{
      var rec = await _db?.query("profiles",
          where: "email=?", whereArgs: [email]);
      if(rec!.isEmpty)return null;
      ProfileModel profile = profileFromMap(rec.first);
      return profile;
    }
  }
/*
  Future<List<dynamic>?> getAll(int idUser, {Map<Filter,List> filters=const {} }) async {
    Database? db = await _getDB();
    List<Map<String, Object?>>? recs;
    String userIdCondition = idUser == -1 ? "" : "outfits.idUser='$idUser'" ;

    if (filters.isEmpty) {
      recs = await _db?.rawQuery('SELECT outfits.idOutfit,outfits.idUser,articles.idArticle,outfits.imgPath as otfImg,season,likes,addedOn,favorite,dressCode,articles.imgPath as artImg,primColor,secColor,brand,clothingType,fav '
          'FROM outfits,outfit_articles,articles '
          'WHERE $userIdCondition ${userIdCondition.isEmpty ? "" : "AND"} outfits.idOutfit=outfit_articles.idOutfit AND articles.idArticle=outfit_articles.idArticle');
    }else{
      Map<Filter,String> stringedFilters = filters.map((key, value) => MapEntry(key,_buildCondition(key, value, BooleanOp.or)) );
      log(stringedFilters.toString());
      List cleanedFilters = stringedFilters.values.toList();

      log("Before: $cleanedFilters");
      cleanedFilters.removeWhere((element) => element=="");
      cleanedFilters.add(userIdCondition);
      log("After: $cleanedFilters");

      recs = await _db?.rawQuery('SELECT outfits.idOutfit,outfits.idUser,articles.idArticle,outfits.imgPath as otfImg,season,likes,addedOn,favorite,dressCode,articles.imgPath as artImg,primColor,secColor,brand,clothingType,fav '
          'FROM outfits,outfit_articles,articles '
          'WHERE ${cleanedFilters.join(" AND ")} ${userIdCondition.isEmpty ? "" : "AND"} outfits.idOutfit=outfit_articles.idOutfit AND articles.idArticle=outfit_articles.idArticle');
    }

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
  }*/

  update(ProfileModel profile) async {
    Database? db = await _getDB();
    return await _db?.update('profiles', profileToMap(profile),
        where: 'id=?', whereArgs: [profile.id]);
  }

  delete(int idProfile) async {
    Database? db = await _getDB();
    return await _db
        ?.delete('profiles', where: 'id=?', whereArgs: [idProfile]);
  }
}
