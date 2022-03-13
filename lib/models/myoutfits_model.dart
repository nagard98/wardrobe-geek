import 'dart:developer';
import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/models/article_model.dart';
import 'package:esempio/models/outfit_model.dart';
import 'package:esempio/models/profile_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class MyOutfitsModel extends ChangeNotifier{
  List<OutfitModel>? outfits = [];
  OutfitModel? currentOutfit;
  bool isLoading = false;
  bool isEditing = false;

  List<OutfitModel> filter() {
    //TODO: Implementa filtro per outfit
    throw UnimplementedError();
  }

  bool addOutfit(){
    //TODO: implementa aggiunta outfit
    throw UnimplementedError();
  }

  bool removeOutfit(){
    //TODO: implementa rimozione outfit
    throw UnimplementedError();
  }

  void loadOutfits(OutfitDBWorker outfitDBWorker, ProfileModel profile) async {
    isLoading = true;
    await Future.delayed(Duration(seconds: 1), () {});
    outfits = (await outfitDBWorker.getAll(profile.id as int))?.cast<OutfitModel>();
    isLoading = false;
    log(isLoading.toString());
    notifyListeners();
  }
  
}

MyOutfitsModel myOutfitsModel = MyOutfitsModel();
