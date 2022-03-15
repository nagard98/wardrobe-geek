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
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as mbs;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class MyOutfits extends StatelessWidget {
  const MyOutfits({Key? key, required this.controller}) : super(key: key);

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyOutfitsModel>.value(
      value: myOutfitsModel,
      child: BackdropScaffold(
        frontLayerBackgroundColor: Colors.lightBlueAccent,
        stickyFrontLayer: true,
        appBar: MyOutfitsAppBar(),
        frontLayer: MyOutfitsFrontLayer(controller: controller),
        backLayer: MyOutfitsBackLayer(),
        floatingActionButton: MyOutfitsFAB(),
      ),
    );
  }
}

class MyOutfitsFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MyOutfitsModel>(builder: (context, myoutfits, child) {
      return FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            myoutfits.currentOutfit = OutfitModel();
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return NuovoOutfit();
            }));
          });
    });
  }
}

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
  const MyOutfitsFrontLayer({Key? key, required this.controller}) : super(key: key);

  final AnimationController controller;

  @override
  State<StatefulWidget> createState() {
    return MyOutfitsFrontLayerState();
  }
}

class MyOutfitsFrontLayerState extends State<MyOutfitsFrontLayer>{

  late Animation<double> _animationScale;
  late Animation<double> _animationOpacity;

  @override
  void initState() {
    super.initState();
    _animationScale = Tween(begin: 0.6, end: 1.0).animate(widget.controller);
    _animationOpacity = Tween(begin: 0.3, end: 1.0).animate(widget.controller);
    myOutfitsModel.loadOutfits(OutfitDBWorker.outfitDBWorker, profile);
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.forward();
    return FadeTransition(
      opacity: CurvedAnimation(curve: Curves.easeInOutCubic, parent: _animationOpacity),
      child: ScaleTransition(
        scale: CurvedAnimation(curve: Curves.easeInOutCubic, parent: _animationScale),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: Consumer<MyOutfitsModel>(builder: (context, myoutfits, child) {
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 52),
                  child: AnimationLimiter(
                    child: GridView.builder(
                      padding: EdgeInsets.only(bottom: 30),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 0.6,
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        if (myoutfits.isLoading) {
                          return buildCardShimmer();
                        } else {
                          return OutfitCard(index: index, myoutfits: myoutfits);
                        }
                      },
                      itemCount:
                          myoutfits.isLoading ? 8 : myoutfits.outfits?.length,
                    ),
                  ),
                ),
                BackdropSubHeader(
                  title: Text("Titolo"),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class OutfitCard extends StatelessWidget {
  OutfitCard({required this.index, required this.myoutfits});

  int index;
  MyOutfitsModel myoutfits;

  void _handleTap(BuildContext context, GlobalKey parentKey) {
    Navigator.of(context).push(MorpheusPageRoute(
      //TODO: Modifica Outfit
      builder: (context) => Outfit(
          outfit: myoutfits.outfits?.elementAt(index) as OutfitModel,
          heroIndex: index),
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
                tag: "outfit${myoutfits.outfits?.elementAt(index).id}",
                child: Image.file(
                  File(myoutfits.outfits?.elementAt(index).imgPath as String),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text("TESTO"),
                        )),
                    Expanded(
                      flex: 1,
                      child: LikeButton(
                        isLiked: myoutfits.outfits!.elementAt(index).favorite,
                        onTap: (isLiked) async {
                          myoutfits.outfits?.elementAt(index).favorite =
                              !isLiked;
                          myoutfits.updateOutfit(
                              OutfitDBWorker.outfitDBWorker,
                              myoutfits.outfits?.elementAt(index)
                                  as OutfitModel,
                              profile,
                              withReload: false);
                          return !isLiked;
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () {
                          mbs.showMaterialModalBottomSheet(
                              useRootNavigator: true,
                              context: context,
                              builder: (context) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      child: ListTile(
                                        leading: Icon(Icons.delete),
                                        title: Text("Elimina Outfit"),
                                      ),
                                      onTap: () async {
                                        bool toBeDeleted = await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                content: Text(
                                                    "Sei sicuro di voler eliminare questo articolo?"),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text('No'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(false);
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text('Sì'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(true);
                                                      Navigator.of(context)
                                                          .pop(true);
                                                    },
                                                  ),
                                                ],
                                              );
                                            });
                                        log("Cancellare outfit?: $toBeDeleted");
                                        if (toBeDeleted) {
                                          myoutfits.removeOutfit(
                                              OutfitDBWorker.outfitDBWorker,
                                              myoutfits.outfits
                                                  ?.elementAt(index)
                                                  .id as int,
                                              profile);
                                        }
                                      },
                                    ),
                                    InkWell(
                                      child: ListTile(
                                          leading: Icon(Icons.edit),
                                          title: Text("Modifica Outfit")),
                                      onTap: () {},
                                    ),
                                  ],
                                );
                              });
                        },
                      ),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
