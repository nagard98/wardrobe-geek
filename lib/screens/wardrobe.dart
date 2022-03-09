import 'dart:developer';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import '../common/utils.dart';
import 'package:shimmer/shimmer.dart';
import 'articolo.dart';
import 'package:esempio/models/wardrobe_model.dart';
import 'package:esempio/db/db_worker.dart';

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

class WardrobeBackLayer extends StatelessWidget {
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
    wardrobeModel.loadArticles(ArticleDBWorker.articleDBWorker);
  }

  Widget buildCardShimmer() => Shimmer.fromColors(
      child: Card(),
      baseColor: Color(0xFFC4C3C3),
      highlightColor: Color(0xFFEFEFEF));

  Widget buildCard(CardItem card) => card;

  List<CardItem> items = [];
  bool isLoading = false;

/*
  @override
  void initState() {
    super.initState();
    loadData();
  }
*/

/*  Future loadData() async {
    setState(() => isLoading = true);
    await Future.delayed(Duration(seconds: 1), () {});
    items = List.of(allItems);
    if (mounted) setState(() => isLoading = false);
  }*/

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: wardrobeModel,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Stack(
          children: [
            Consumer<WardrobeModel>(
              builder: (context, wardrobe, child){
                return Container(
                  margin: EdgeInsets.only(top: 52),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 0.7,
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
                                    articleModel:
                                    wardrobe.articles?.elementAt(index));
                              })),
                          child: Card(),
                        );
                      }
                    },
                    itemCount: wardrobe.isLoading ? 8 : wardrobe.articles?.length,
                  ),
                );
              }
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return NuovoArticolo();
                    }));
                  }),
            )
          ],
        ),
      ),
    );
  }
}
