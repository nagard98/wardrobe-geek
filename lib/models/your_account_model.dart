import 'dart:convert';
import 'package:esempio/db/article_db_worker.dart';
import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/db/profile_db_worker.dart';
import 'package:esempio/models/myoutfits_model.dart';
import 'package:esempio/models/wardrobe_model.dart';
import 'package:flutter/material.dart';
import 'package:esempio/models/profile_model.dart';
import 'package:crypto/crypto.dart';

class PersonalAccount extends ChangeNotifier {
  PersonalAccount():
    myProfile = ProfileModel(
      id: 1,
      email: "profile@local.com",
      password: sha256.convert(utf8.encode("local")).toString(),
      level: 0,
      surname: "local",
      name: 'profile',
    );

  ProfileModel myProfile;
  bool isLoggedIn = false;
  bool isRegistered = false;

  login(ProfileDBWorker profileDBWorker) async{
    isLoggedIn = false;
    ProfileModel? foundProfile = await profileDBWorker.get(myProfile.email, password: myProfile.password);
    if(foundProfile==null){
      isLoggedIn == false;
      return isLoggedIn;
    }else{
      isLoggedIn = true;
      myProfile = foundProfile;
      wardrobeModel.loadArticles(ArticleDBWorker.articleDBWorker, myProfile);
      myOutfitsModel.loadOutfits(OutfitDBWorker.outfitDBWorker, myProfile);
      notifyListeners();
      return isLoggedIn;
    }
  }

  logout(){
    isLoggedIn = false;
    myProfile = ProfileModel(
      id: 1,
      email: "test",
      password: sha256.convert(utf8.encode("test")).toString(),
      level: 0,
      surname: "test",
      name: 'test',
    );
    wardrobeModel.loadArticles(ArticleDBWorker.articleDBWorker, myProfile);
    myOutfitsModel.loadOutfits(OutfitDBWorker.outfitDBWorker, myProfile);
    notifyListeners();
  }

  register(ProfileDBWorker profileDBWorker) async{
    isRegistered = false;
    ProfileModel? existingProfile = await profileDBWorker.get(myProfile.email);
    if(existingProfile==null){
      await profileDBWorker.create(myProfile);
      return isRegistered = true;
    }else{
      return isRegistered = false;
    }
  }
}

PersonalAccount personalProfile = PersonalAccount();
