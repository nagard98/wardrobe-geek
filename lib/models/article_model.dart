import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

/*enum Brand { armani, valentino, gucci, northFace, hollister, generico }

enum ClothingType { tshirt, jeans, pantaloni, maglione, felpa, camicia, altro, sneakers, stivali, zeppe, giaccaVento }*/
List<String> clothingNames = ['T-Shirt', 'Jeans', 'Pantaloni', 'Maglione', 'Felpa', 'Camicia', 'Altro', 'Sneakers', 'Stivali', 'Zeppe', 'Giacca A Vento'];
Map<int,String>  clothing = clothingNames.asMap();

List<String> brandNames = ['Armani', 'Valentino', 'Gucci', 'The North Face', 'Hollister', 'Generico'];
Map<int,String> brands = brandNames.asMap();

final Map<ColorSwatch<Object>, String> customSwatches =
    <ColorSwatch<Object>, String>{
  const MaterialColor(0xFFfae738, <int, Color>{
    50: Color(0xFFfffee9),
    100: Color(0xFFfff9c6),
    200: Color(0xFFfff59f),
    300: Color(0xFFfff178),
    400: Color(0xFFfdec59),
    500: Color(0xFFfae738),
    600: Color(0xFFf3dd3d),
    700: Color(0xFFdfc735),
    800: Color(0xFFcbb02f),
    900: Color(0xFFab8923),
  }): 'Alpine',
  ColorTools.createPrimarySwatch(const Color(0xFFBC350F)): 'Rust',
  ColorTools.createAccentSwatch(const Color(0xFFB062DB)): 'Lavender',
};

class ArticleModel {
  int? id;
  int? idUser;
  String? imgPath;
  String? articleName;
  Color? primaryColor;
  Color? secondaryColor;
  int? brand;
  int? clothingType;
  bool? favorite;

  ArticleModel(
      {this.id,
      this.imgPath,
      this.idUser,
      this.articleName,
      this.favorite = false,
      this.primaryColor,
      this.brand,
      this.clothingType,
      this.secondaryColor});
}
