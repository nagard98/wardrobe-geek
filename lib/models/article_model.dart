enum Brand { armani, valentino, gucci, northFace, hollister }

enum ClothingType { tshirt, jeans, pantaloni, maglione, felpa, camicia }

enum ArticleColor { red, green, blue, yellow, pink ,white, black }

class ArticleModel {
  int? id;
  String articleName;
  ArticleColor primaryColor;
  ArticleColor secondaryColor;
  Brand brand;
  ClothingType clothingType;
  bool favorite;

  ArticleModel(
      {this.id,
      required this.articleName,
      required this.favorite,
      required this.primaryColor,
      required this.brand,
      required this.clothingType,
      required this.secondaryColor});
}
