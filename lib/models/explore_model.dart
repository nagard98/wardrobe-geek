import 'dart:developer';
import 'package:esempio/db/profile_db_worker.dart';
import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/models/outfit_model.dart';
import 'package:esempio/models/outfits_interface.dart';
import 'package:esempio/models/profile_model.dart';
import 'package:esempio/models/your_account_model.dart';
import 'package:provider/provider.dart';
import 'package:esempio/db/article_db_worker.dart';
import 'package:esempio/models/article_model.dart';
import 'package:flutter/material.dart';
import 'package:esempio/common/utils.dart';

enum Section {recOutf, popOutf, newHotOutf, recUsers, popUsers, newHotUsers, filteredOutf, filteredUsers, home, myoutfits, wishlist }

class ExploreModel extends ChangeNotifier implements OutfitsInterface {
  Map<Section,List> exploreMap = {};
  Map<Filter,List> filters = {};
  Order filterOrder = Order.ascDate;
  bool isLoading = false;
  bool isEditing = false;
  Section currentSection = Section.home;
  int currentOutfitStackIndex=0;
  int currentUserStackIndex=0;
  ScrollController homeScrollController = ScrollController();
  ScrollController newPageScrollController = ScrollController();

  ExploreModel(){
    Section.values.forEach((section) {
      exploreMap[section] = [];
    });
  }

  void showScreen(int index, Section targetSection){
    currentSection = targetSection;
    currentUserStackIndex = 0;
    currentOutfitStackIndex = 0;
    if([Section.filteredOutf, Section.recOutf, Section.popOutf, Section.newHotOutf].any((element) => element==targetSection)){
      currentOutfitStackIndex = index;
    }else{
      currentUserStackIndex = index;
    }
    notifyListeners();
  }

  void filterOutfits(OutfitDBWorker outfitDBWorker, ProfileModel profile, ) async {
    isLoading = true;
    await Future.delayed(const Duration(milliseconds: 400), () {});
    exploreMap[Section.filteredOutf] = (await outfitDBWorker.getAll(-1, filters: filters, order: filterOrder ,idOwner: personalProfile.myProfile.id!));
    isLoading = false;
    notifyListeners();
  }

  @override
  void addOutfit(OutfitDBWorker outfitDBWorker, OutfitModel outfitModel, ProfileModel profile) {
    //TODO: implementa aggiunta articolo
    throw UnimplementedError();
  }

  @override
  void removeOutfit(OutfitDBWorker outfitDBWorker, int idOutfit, ProfileModel profile) async{
    await outfitDBWorker.delete(idOutfit);
    loadOutfits(outfitDBWorker, profile);
  }

  @override
  void updateOutfit(OutfitDBWorker outfitDBWorker, OutfitModel outfitModel, ProfileModel profile,
      {bool withReload = true}) async{
    await outfitDBWorker.update(outfitModel, profile.id!);
    if(withReload) loadData(outfitDBWorker, ProfileDBWorker.profileDBWorker , profile);
  }

  void loadData(OutfitDBWorker outfitDBWorker, ProfileDBWorker profileDBWorker, ProfileModel profile, {bool withReload = true}) async {
    isLoading = true;
    await Future.delayed(const Duration(milliseconds: 500), () {});
    exploreMap[Section.recOutf] = (await outfitDBWorker.getAll(-1, idOwner: personalProfile.myProfile.id!));
    exploreMap[Section.newHotOutf] = (await outfitDBWorker.getAll(-1,order: Order.desDate , idOwner: personalProfile.myProfile.id!));
    exploreMap[Section.popOutf] = (await outfitDBWorker.getAll(-1, idOwner: personalProfile.myProfile.id!));
    exploreMap[Section.popUsers] = (await profileDBWorker.getAll());
    isLoading = false;
    log(isLoading.toString());
    if(withReload) notifyListeners();
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
  List<OutfitModel> getList(Section section) {
    return exploreMap[section]!.cast<OutfitModel>();
  }

}

ExploreModel exploreModel = ExploreModel();
