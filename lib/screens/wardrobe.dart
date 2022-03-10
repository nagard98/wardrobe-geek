import 'dart:developer';
import 'package:esempio/models/article_model.dart';
import 'package:esempio/models/profile_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import '../common/utils.dart';
import 'package:shimmer/shimmer.dart';
import 'article.dart';
import 'package:esempio/models/wardrobe_model.dart';
import 'package:esempio/db/db_worker.dart';
import 'dart:io';

class WardrobeAppBar extends BackdropAppBar {
  WardrobeAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropAppBar(
      automaticallyImplyLeading: false,
      actions: const [BackdropToggleButton()],
      title: Text('Wardrobe'),
    );
  }
}

class User {
  final String? name;
  final String? avatar;

  User({this.name, this.avatar});
}

class WardrobeBackLayer extends StatefulWidget {
  WardrobeBackLayer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WardrobeBackLayerState();
  }
}

class WardrobeBackLayerState extends State<WardrobeBackLayer> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        ListTile(
          title: Text("Elemento 1"),
        ),
        ListTile(
          title: Text("Elemento 2"),
        ),
        ListTile(
          title: Text("Elemento 3"),
        )
      ],
    ));
  }
}

class WardrobeFrontLayer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WardrobeFrontLayerState();
  }
}

class WardrobeFrontLayerState extends State<WardrobeFrontLayer> {
  WardrobeFrontLayerState() {
    wardrobeModel.loadArticles(ArticleDBWorker.articleDBWorker, profile);
  }

  Widget buildCardShimmer() => Shimmer.fromColors(
      child: Card(),
      baseColor: Color(0xFFC4C3C3),
      highlightColor: Color(0xFFEFEFEF));

  Widget buildCard(CardItem card) => card;

  List<CardItem> items = [];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: wardrobeModel,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Consumer<WardrobeModel>(builder: (context, wardrobe, child) {
          log(wardrobe.articles.toString());
          return Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: 52),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 1,
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    if (wardrobe.isLoading) {
                      return buildCardShimmer();
                    } else {
                      return InkWell(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Articolo(
                              article: wardrobe.articles!.elementAt(index));
                        })),
                        child: Card(
                          child: Hero(
                              tag:
                                  "articolo${wardrobe.articles!.elementAt(index).id}",
                              child: Image.file(
                                File(wardrobe.articles!
                                    .elementAt(index)
                                    .imgPath!),
                                fit: BoxFit.cover,
                              )),
                        ),
                      );
                    }
                  },
                  itemCount: wardrobe.isLoading ? 8 : wardrobe.articles?.length,
                ),
              ),
              Container(
                child: BackdropSubHeader(
                  title: Text("Titolo"),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () {
                      wardrobe.currentArticle = ArticleModel();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return NuovoArticolo();
                      }));
                    }),
              )
            ],
          );
        }),
      ),
    );
  }
}
