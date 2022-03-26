import 'dart:developer';
import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/models/article_model.dart';
import 'package:esempio/models/explore_model.dart';
import 'package:esempio/models/outfit_model.dart';
import 'package:esempio/models/outfits_interface.dart';
import 'package:esempio/models/profile_model.dart';
import 'package:esempio/models/your_account_model.dart';
import 'package:flutter/material.dart';
import 'package:esempio/common/utils.dart';

class MyOutfitsModel extends ChangeNotifier implements OutfitsInterface{
  List<OutfitModel>? outfits = [];
  OutfitModel? currentOutfit;
  bool isLoading = false;
  bool isEditing = false;
  Map<Filter,List> filters = {};

  @override
  void filter(OutfitDBWorker outfitDBWorker, ProfileModel profile) async {
    isLoading = true;
    await Future.delayed(const Duration(milliseconds: 400), () {});
    outfits = (await outfitDBWorker.getAll(profile.id as int, filters: filters)).cast<OutfitModel>();
    isLoading = false;
    notifyListeners();
  }

  @override
  void addOutfit(OutfitDBWorker outfitDBWorker, OutfitModel outfitModel, ProfileModel profile){
    //TODO: implementa aggiunta outfit
    throw UnimplementedError();
  }

  @override
  void removeOutfit(OutfitDBWorker outfitDBWorker, int idOutfit, ProfileModel profile) async{
    await outfitDBWorker.delete(idOutfit);
    loadOutfits(outfitDBWorker, profile);
  }

  getOutfit(OutfitDBWorker outfitDBWorker,int idOutfit) async{
    OutfitModel outfit = await outfitDBWorker.get(idOutfit, personalProfile.myProfile.id!);
    return outfit;
  }

  @override
  void updateOutfit(OutfitDBWorker outfitDBWorker, OutfitModel outfitModel, ProfileModel profile,
      {bool withReload = true}) async{
    await outfitDBWorker.update(outfitModel, profile.id!);
    if(withReload) loadOutfits(outfitDBWorker, profile);
  }

  @override
  void loadOutfits(OutfitDBWorker outfitDBWorker, ProfileModel profile) async {
    isLoading = true;
    await Future.delayed(const Duration(milliseconds: 500), () {});
    outfits = (await outfitDBWorker.getAll(profile.id as int)).cast<OutfitModel>();
    isLoading = false;
    log(isLoading.toString());
    notifyListeners();
  }

  @override
  List<OutfitModel> getListOutfits(Section section) {
    //TODO: gestisci meglio l'argomento passato section per myoutfits
    return outfits!;
  }
  
}

MyOutfitsModel myOutfitsModel = MyOutfitsModel();
