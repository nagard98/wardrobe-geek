import 'package:esempio/db/outfit_db_worker.dart';
import 'package:flutter/widgets.dart';

class ProfileModel {
  //String username;
  String email;
  String password;
  int? id;
  String name;
  String surname;
  String? city;
  String? nation;
  int? numFollower;
  int? numFollowing;
  int level;
  String? pathPicture;

  ProfileModel(
      {//required this.username,
      required this.email,
      required this.password,
      this.id,
      required this.name,
      required this.surname,
      this.city,
      this.nation,
      this.numFollower,
      this.numFollowing,
      required this.level,
      this.pathPicture}){
   OutfitDBWorker.outfitDBWorker.updateDatabase();
  }
}

//ProfileModel profile = ProfileModel(id: 1);
