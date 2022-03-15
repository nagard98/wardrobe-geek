import 'dart:developer';
import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/models/outfit_model.dart';
import 'package:esempio/models/profile_model.dart';
import 'package:provider/provider.dart';
import 'package:esempio/db/article_db_worker.dart';
import 'package:esempio/models/article_model.dart';
import 'package:flutter/material.dart';

class ExploreModel extends ChangeNotifier {
  List<OutfitModel>? reccomendedOutfits = [];
  List<OutfitModel>? popularOutfits = [];
  List<OutfitModel>? newHotOutfits = [];
  List<ProfileModel>? popularUsers = [];
  bool isLoading = false;
  bool isEditing = false;

  List<OutfitModel> filter() {
    //TODO: implementa filtro
    throw UnimplementedError();
  }

  bool addArticle(OutfitModel outfitModel) {
    //TODO: implementa aggiunta articolo
    throw UnimplementedError();
  }

  void updateOutfit(OutfitDBWorker outfitDBWorker, OutfitModel outfitModel, ProfileModel profile,
      {bool withReload = true}) async{
    await outfitDBWorker.update(outfitModel, profile.id!);
    if(withReload) loadData(outfitDBWorker, profile);
  }

  void loadData(OutfitDBWorker outfitDBWorker, ProfileModel profile) async {
    isLoading = true;
    await Future.delayed(const Duration(milliseconds: 500), () {});
    reccomendedOutfits = (await outfitDBWorker.getAll(profile.id as int))?.cast<OutfitModel>();
    isLoading = false;
    log(isLoading.toString());
    notifyListeners();
  }
}

ExploreModel exploreModel = ExploreModel();
