import 'dart:io';
import 'dart:developer';
import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/models/article_model.dart';
import 'package:esempio/models/myoutfits_model.dart';
import 'package:esempio/models/outfit_model.dart';
import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import '../common/utils.dart';
import 'package:shimmer/shimmer.dart';
import 'outfit.dart';
import 'package:like_button/like_button.dart';
import 'package:morpheus/morpheus.dart';
import 'package:esempio/models/profile_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class MyOutfitsAppBar extends BackdropAppBar {
  @override
  Widget build(BuildContext context) {
    return BackdropAppBar(
      automaticallyImplyLeading: false,
      actions: const [BackdropToggleButton()],
      title: Text('MyOutfits'),
    );
  }
}

class MyOutfitsBackLayer extends StatelessWidget {
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

class MyOutfitsFrontLayer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyOutfitsFrontLayerState();
  }
}

class MyOutfitsFrontLayerState extends State<MyOutfitsFrontLayer> {
  Widget buildCardShimmer() => Shimmer.fromColors(
      child: Card(),
      baseColor: Color(0xFFC4C3C3),
      highlightColor: Color(0xFFEFEFEF));

  List<CardItem> items = [];
  bool isLoading = false;

  @override
  void initState() {
    myOutfitsModel.loadOutfits(OutfitDBWorker.outfitDBWorker, profile);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyOutfitsModel>.value(
      value: myOutfitsModel,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Consumer<MyOutfitsModel>(builder: (context, myoutfits, child) {
          return Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: 52),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 0.6,
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    if (myoutfits.isLoading) {
                      return buildCardShimmer();
                    } else {
                      return OutfitCard(index: index, outfit: myoutfits.outfits![index]);
                    }
                  },
                  itemCount:
                      myoutfits.isLoading ? 8 : myoutfits.outfits?.length,
                ),
              ),
              BackdropSubHeader(
                title: Text("Titolo"),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () {
                      myoutfits.currentOutfit = OutfitModel();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return NuovoOutfit();
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

class OutfitCard extends StatelessWidget {
  OutfitCard({required this.index, required this.outfit});

  int index;
  OutfitModel outfit;

  void _handleTap(BuildContext context, GlobalKey parentKey) {
    Navigator.of(context).push(MorpheusPageRoute(
      //TODO: Modifica Outfit
      builder: (context) => Outfit(heroIndex: index),
      parentKey: parentKey,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final _parentKey = GlobalKey();
    return InkWell(
      key: _parentKey,
      onTap: () => _handleTap(context, _parentKey),
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Hero(
                tag: "articolo${outfit.id}",
                child: Image.file(
                  File(outfit.imgPath!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text("TESTO"),
                        )),
                    Expanded(
                      flex: 1,
                      child: LikeButton(),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
