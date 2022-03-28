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

  Future<List<ProfileModel>> getAll() async{
    Database? db = await _getDB();

    List<Map<String, Object?>>? recs;
    recs = await _db?.query('profiles');

    List<ProfileModel> list = recs == null ? [] : recs.map((m) => profileFromMap(m)).toList();
    return list;
  }

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
