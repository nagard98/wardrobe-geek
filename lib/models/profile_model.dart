import 'package:esempio/db/outfit_db_worker.dart';
import 'package:flutter/widgets.dart';
import 'package:esempio/models/outfit_model.dart';
import 'package:esempio/common/utils.dart';

class ProfileModel{
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
