import 'package:esempio/models/article_model.dart';
import 'package:esempio/models/outfit_model.dart';

class MyOutfitsModel {
  List<OutfitModel> outfits;

  MyOutfitsModel({required this.outfits});

  List<ArticleModel> filter() {
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
  
}
