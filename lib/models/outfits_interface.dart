import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/models/explore_model.dart';
import 'package:esempio/models/outfit_model.dart';
import 'package:esempio/models/profile_model.dart';

abstract class OutfitsInterface {
  void filter(OutfitDBWorker outfitDBWorker, ProfileModel profile);

  bool addOutfit(OutfitModel outfitModel);

  void removeOutfit(OutfitDBWorker outfitDBWorker, int idOutfit, ProfileModel profile);

  void updateOutfit(OutfitDBWorker outfitDBWorker, OutfitModel outfitModel, ProfileModel profile, {bool withReload});

  void loadOutfits(OutfitDBWorker outfitDBWorker, ProfileModel profile);

  List<OutfitModel> getListOutfits(Section section);
}