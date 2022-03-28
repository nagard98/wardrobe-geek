import 'dart:convert';
import 'package:esempio/db/article_db_worker.dart';
import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/db/profile_db_worker.dart';
import 'package:esempio/models/myoutfits_model.dart';
import 'package:esempio/models/wardrobe_model.dart';
import 'package:flutter/material.dart';
import 'package:esempio/models/profile_model.dart';
import 'package:crypto/crypto.dart';
import 'package:esempio/common/utils.dart';
import 'package:esempio/models/outfit_model.dart';

class PersonalAccount extends ChangeNotifier {
  PersonalAccount():
    myProfile = ProfileModel(
      id: 0,
      email: "profile@local.com",
      password: sha256.convert(utf8.encode("local")).toString(),
      level: 0,
      surname: "local",
      name: 'profile',
    );

  ProfileModel myProfile;
  bool isLoggedIn = false;
  bool isRegistered = false;
  List<OutfitModel> outfits=[];
  List<ProfileModel> followed = [];

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
      outfits = await OutfitDBWorker.outfitDBWorker.getAll(myProfile.id!, order: Order.desPop);
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

  loadData() async{
    outfits = await OutfitDBWorker.outfitDBWorker.getAll(myProfile.id!, order: Order.desPop);
    //TODO: implementa recupero utenti seguiti
    followed = await ProfileDBWorker.profileDBWorker.getAll();
    notifyListeners();
  }

}

PersonalAccount personalProfile = PersonalAccount();
