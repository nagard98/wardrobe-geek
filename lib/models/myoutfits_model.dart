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

  void removeOutfit(OutfitDBWorker outfitDBWorker, int idOutfit, ProfileModel profile) async{
    await outfitDBWorker.delete(idOutfit);
    loadOutfits(outfitDBWorker, profile);
  }

  void updateOutfit(OutfitDBWorker outfitDBWorker, OutfitModel outfitModel, ProfileModel profile,
      {bool withReload = true}) async{
    await outfitDBWorker.update(outfitModel, profile.id!);
    if(withReload) loadOutfits(outfitDBWorker, profile);
  }

  void loadOutfits(OutfitDBWorker outfitDBWorker, ProfileModel profile) async {
    isLoading = true;
    await Future.delayed(const Duration(milliseconds: 500), () {});
    outfits = (await outfitDBWorker.getAll(profile.id as int))?.cast<OutfitModel>();
    isLoading = false;
    log(isLoading.toString());
    notifyListeners();
  }
  
}

MyOutfitsModel myOutfitsModel = MyOutfitsModel();
