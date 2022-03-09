import 'package:esempio/models/article_model.dart';
import 'package:esempio/models/myoutfits_model.dart';
import 'package:esempio/models/outfit_model.dart';

class WishlistModel extends MyOutfitsModel{
  WishlistModel(List<OutfitModel> listoutfits) : super(outfits: listoutfits);

}