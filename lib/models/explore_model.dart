import 'dart:developer';
import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/models/outfit_model.dart';
import 'package:esempio/models/outfits_interface.dart';
import 'package:esempio/models/profile_model.dart';
import 'package:provider/provider.dart';
import 'package:esempio/db/article_db_worker.dart';
import 'package:esempio/models/article_model.dart';
import 'package:flutter/material.dart';
import 'package:esempio/common/utils.dart';

enum Section {recOutf, popOutf, newHotOutf, popUsers, filteredOutf, filteredUsers }

class ExploreModel extends ChangeNotifier implements OutfitsInterface {
/*  List<OutfitModel>? reccomendedOutfits = [];
  List<OutfitModel>? popularOutfits = [];
  List<OutfitModel>? newHotOutfits = [];
  List<ProfileModel>? popularUsers = [];*/
  Map<Section,List> exploreMap = {};
  Map<Filter,List> filters = {};
  bool isLoading = false;
  bool isEditing = false;
  bool isFilteredOutfits = false;
  int currentIndex=0;

  ExploreModel(){
    exploreMap[Section.filteredOutf] = [];
    exploreMap[Section.filteredUsers] = [];
    exploreMap[Section.recOutf] = [];
    exploreMap[Section.popOutf] = [];
    exploreMap[Section.newHotOutf] = [];
    exploreMap[Section.popUsers] = [];
  }

  void showScreen(int index){
    isFilteredOutfits = false;
    currentIndex = index;
    notifyListeners();
  }

  void filterOutfits(OutfitDBWorker outfitDBWorker, ProfileModel profile, ) async {
    isFilteredOutfits = true;
    isLoading = true;
    await Future.delayed(Duration(milliseconds: 400), () {});
    exploreMap[Section.filteredOutf] = (await outfitDBWorker.getAll(-1, filters: filters))!;
    isLoading = false;
    notifyListeners();
  }

  @override
  bool addOutfit(OutfitModel outfitModel) {
    //TODO: implementa aggiunta articolo
    throw UnimplementedError();
  }

  void removeOutfit(OutfitDBWorker outfitDBWorker, int idOutfit, ProfileModel profile) async{
    await outfitDBWorker.delete(idOutfit);
    loadOutfits(outfitDBWorker, profile);
  }

  @override
  void updateOutfit(OutfitDBWorker outfitDBWorker, OutfitModel outfitModel, ProfileModel profile,
      {bool withReload = true}) async{
    await outfitDBWorker.update(outfitModel, profile.id!);
    if(withReload) loadData(outfitDBWorker, profile);
  }

  void loadData(OutfitDBWorker outfitDBWorker, ProfileModel profile) async {
    isLoading = true;
    await Future.delayed(const Duration(milliseconds: 500), () {});
    exploreMap[Section.recOutf] = (await outfitDBWorker.getAll(profile.id as int))!;
    exploreMap[Section.newHotOutf] = (await outfitDBWorker.getAll(profile.id as int))!;
    exploreMap[Section.popOutf] = (await outfitDBWorker.getAll(profile.id as int))!;
    exploreMap[Section.popUsers] = (await outfitDBWorker.getAll(profile.id as int))!;
    isLoading = false;
    log(isLoading.toString());
    notifyListeners();
  }

  @override
  void filter(OutfitDBWorker outfitDBWorker, ProfileModel profile) {
    filterOutfits(outfitDBWorker, profile);
  }

  @override
  void loadOutfits(OutfitDBWorker outfitDBWorker, ProfileModel profile) {
    // TODO: implement loadOutfits
  }

  @override
  List<OutfitModel> getListOutfits(Section section) {
    return exploreMap[section]!.cast<OutfitModel>();
  }

}

ExploreModel exploreModel = ExploreModel();
