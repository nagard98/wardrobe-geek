import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/models/explore_model.dart';
import 'package:esempio/models/outfit_model.dart';
import 'package:esempio/models/profile_model.dart';

abstract class OutfitsInterface {
  void filter(OutfitDBWorker outfitDBWorker, ProfileModel profile);

  void addOutfit(OutfitDBWorker outfitDBWorker, OutfitModel outfitModel, ProfileModel profile);

  void removeOutfit(OutfitDBWorker outfitDBWorker, int idOutfit, ProfileModel profile);

  void updateOutfit(OutfitDBWorker outfitDBWorker, OutfitModel outfitModel, ProfileModel profile, {bool withReload=true});

  void loadOutfits(OutfitDBWorker outfitDBWorker, ProfileModel profile);

  List<OutfitModel> getList(Section section);
}