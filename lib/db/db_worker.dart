import 'package:esempio/models/article_model.dart';
import 'package:esempio/models/wardrobe_model.dart';
import 'package:esempio/common/utils.dart' as utils;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ArticleDBWorker {
  ArticleDBWorker._();

  static final ArticleDBWorker articleDBWorker = ArticleDBWorker._();

  Database? _db;

  Future<Database?> _getDB() async {
    if (_db == null) {
      String path = join(utils.docsDir.path, "wardrobe_geek.db");
      _db = await openDatabase(path, version: 1,
          onCreate: (Database inDB, int inVersion) async {
        await inDB.execute('CREATE TABLE IF NOT EXISTS articles ('
            'idArticle INTEGER PRIMARY KEY,'
            'idUser INTEGER NOT NULL,'
            'articleName TEXT NOT NULL,'
            'primColor INTEGER NOT NULL,'
            'secColor INTEGER NULL,'
            'brand INTEGER NOT NULL,'
            'clothingType INTEGER NOT NULL,'
            'fav INTEGER NOT NULL)');
      });
    }
    return _db;
  }

  ArticleModel articleFromMap(Map<String,Object?> ?map) {
    ArticleModel article = ArticleModel(
        id: map!['idArticle'] as int,
        articleName: map['articleName'] as String,
        primaryColor: ArticleColor.values[map['primColor'] as int],
        secondaryColor: ArticleColor.values[map['secColor'] as int],
        brand: Brand.values[map['brand'] as int],
        clothingType: ClothingType.values[map['clothingType'] as int] ,
        favorite: map['fav'] as bool);
    return article;
  }

  Map<String,dynamic> articleToMap(ArticleModel article, int idUser){
    Map<String,dynamic> map = Map<String,dynamic>();
    map['idArticle'] = article.id;
    map['idUser'] = idUser;
    map['articleName'] = article.articleName;
    map['primColor'] = article.primaryColor.index;
    map['secColor'] = article.secondaryColor.index;
    map['brand'] = article.brand.index;
    map['clothingType'] = article.clothingType.index;
    map['fav'] = article.favorite as int;

    return map;
  }

  create(ArticleModel article, int idUser) async {
    Database? db = await _getDB();

    var val =
        await _db?.rawQuery('SELECT MAX(idArticle)+1 AS id from articles');
    int nextId = val?.first['id'] as int;
    if (nextId == null) {
      nextId = 1;
    }
    article.id = nextId;

    return await _db?.rawInsert(
        'INSERT INTO articles (idArticle, idUser, articleName, primColor, secColor, brand, clothingType, fav)'
        'VALUES (?,?,?,?,?,?,?,?)',
        [
          article.id,
          idUser,
          article.articleName,
          article.primaryColor,
          article.secondaryColor,
          article.brand,
          article.clothingType,
          article.favorite
        ]);
  }

  Future<ArticleModel> get(int idArticle) async {
    Database? db = await _getDB();
    var rec =
        await _db?.query("articles", where: "idArticle=?", whereArgs: [idArticle]);
    return articleFromMap(rec?.first);
  }

  Future<List<dynamic>?> getAll(int idUser) async {
    Database? db = await _getDB();
    var recs = await _db?.query('articles',where: 'idUser=?', whereArgs: [idUser]);
    var list = recs != null ? [] : recs?.map((m) => articleFromMap(m)).toList();
    return list;
  }

  update(ArticleModel article, int idUser) async {
    Database? db = await _getDB();
    return await _db?.update('articles', articleToMap(article, idUser), where: 'idArticle=?', whereArgs: [article.id]);
  }

  delete(int idArticle) async {
    Database? db = await _getDB();
    return await _db?.delete('articles', where: 'idArticle=?', whereArgs: [idArticle]);
  }
}
