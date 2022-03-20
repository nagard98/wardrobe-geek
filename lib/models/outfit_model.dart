import 'package:esempio/models/article_model.dart';

/*enum Season {estate, inverno, primavera, autunno, qualsiasi}
enum DressCode {casual, formalCasual, informale, streetwear, businessCasual, altro}*/

List<String> seasonNames = ['Estate', 'Inverno', 'Primavera', 'Autunno'];
Map<int,String>  seasons = seasonNames.asMap();

List<String> dressCodeNames = ['Casual', 'Formal Casual', 'Informale', 'Streetwear', 'Business Casual', 'Altro'];
Map<int,String> dressCodes = dressCodeNames.asMap();

class OutfitModel {
  int? id;
  int? idUser;
  List<ArticleModel>? articles;
  int? season;
  int? dressCode;
  int? likes = 0;
  String? imgPath;
  DateTime? addedOn;
  bool? favorite = false;

  OutfitModel(
      {this.id,
      this.articles,
      this.season,
      this.dressCode,
      this.idUser,
      this.addedOn,
      this.favorite,
      this.likes,
      this.imgPath});
}