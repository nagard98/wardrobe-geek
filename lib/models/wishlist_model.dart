import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/db/profile_db_worker.dart';
import 'package:esempio/models/article_model.dart';
import 'package:esempio/models/explore_model.dart';
import 'package:esempio/models/myoutfits_model.dart';
import 'package:esempio/models/outfit_model.dart';
import 'package:esempio/models/profile_model.dart';
import 'package:esempio/models/your_account_model.dart';
import 'package:flutter/material.dart';
import 'package:esempio/models/outfits_interface.dart';
import 'package:esempio/common/utils.dart';

class WishlistModel extends ChangeNotifier implements OutfitsInterface{
  bool isLoading=false;
  List<OutfitModel> wishlistOutfits = [];
  Map<Filter,List> filters = {};

/*  addLike(OutfitDBWorker outfitDBWorker, OutfitModel outfitModel, ProfileModel profile) async{
    outfitDBWorker.create(outfitModel, profile.id!, isLikes: true);
    exploreModel.loadData(outfitDBWorker, profile);
  }

  removeLike(OutfitDBWorker outfitDBWorker, OutfitModel outfitModel, ProfileModel profile) async{
    outfitDBWorker.delete(outfitModel.id! ,isLikes: true, idUser: profile.id!);
    exploreModel.loadData(outfitDBWorker, profile);
  }*/

  @override
  void addOutfit(OutfitDBWorker outfitDBWorker, OutfitModel outfitModel, ProfileModel profile,{bool withReload = false}) async{
    await outfitDBWorker.create(outfitModel, profile.id!, isWishlist: true);
    //await outfitDBWorker.update(outfitModel, personalProfile.myProfile.id!, isWishNum: 1);
    loadOutfits(outfitDBWorker, profile);
    exploreModel.loadData(outfitDBWorker, ProfileDBWorker.profileDBWorker, profile,withReload: withReload);
  }

  @override
  void removeOutfit(OutfitDBWorker outfitDBWorker, int idOutfit, ProfileModel profile,{bool withReload = false}) async{
    await outfitDBWorker.delete(idOutfit, isWishlist: true, idUser: profile.id!);
    //await outfitDBWorker.update(outfitModel, personalProfile.myProfile.id!, isWishNum: -1);
    loadOutfits(outfitDBWorker, profile);
    exploreModel.loadData(outfitDBWorker, ProfileDBWorker.profileDBWorker, profile, withReload: withReload);
  }

  @override
  void filter(OutfitDBWorker outfitDBWorker, ProfileModel profile) async {
    isLoading = true;
    await Future.delayed(const Duration(milliseconds: 400), () {});
    wishlistOutfits = await outfitDBWorker.getAll(profile.id as int, filters: filters, idOwner: personalProfile.myProfile.id!, inWishlist: true);
    isLoading = false;
    notifyListeners();
  }

  @override
  List<OutfitModel> getList(Section section) {
    return wishlistOutfits;
  }

  @override
  void loadOutfits(OutfitDBWorker outfitDBWorker, ProfileModel profile) async {
    isLoading = true;
    wishlistOutfits = await outfitDBWorker.getAll(profile.id!, inWishlist: true, idOwner: personalProfile.myProfile.id!);
    await Future.delayed(const Duration(milliseconds: 500), () {});
    isLoading = false;
    notifyListeners();
  }



  @override
  void updateOutfit(OutfitDBWorker outfitDBWorker, OutfitModel outfitModel, ProfileModel profile, {bool withReload=true}) {
    // TODO: implement updateOutfit
  }

}

WishlistModel wishlistModel = WishlistModel();