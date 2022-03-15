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
import 'package:esempio/db/article_db_worker.dart';
import 'dart:io';
import 'package:morpheus/morpheus.dart';
import 'package:like_button/like_button.dart';
import 'package:backdrop/backdrop.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as mbs;

class Wardrobe extends StatelessWidget{
  const Wardrobe({Key? key, required this.controller}) : super(key: key);

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WardrobeModel>.value(
      value: wardrobeModel,
      child: BackdropScaffold(
        frontLayerBackgroundColor: Colors.lightBlueAccent,
        stickyFrontLayer: true,
        appBar: WardrobeAppBar(),
        frontLayer: WardrobeFrontLayer(controller: controller,),
        backLayer: WardrobeBackLayer(),
        floatingActionButton: WardrobeFAB(),
      ),
    );
  }
}

class WardrobeFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<WardrobeModel>(builder: (context, wardrobe, child){
      return FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            wardrobe.currentArticle = ArticleModel();
            Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                  //TODO: Correggi crash sporadico aggiunta immagine(scomparso?)
                  return NuovoArticolo();
                }));
          });
    });
  }

}

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

class WardrobeBackLayer extends StatefulWidget {
  WardrobeBackLayer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WardrobeBackLayerState();
  }
}

class ActorFilterEntry {
  const ActorFilterEntry(this.name, this.initials);

  final String name;
  final String initials;
}

class WardrobeBackLayerState extends State<WardrobeBackLayer> {
  final List<ActorFilterEntry> _cast = <ActorFilterEntry>[
    const ActorFilterEntry('Aaron Burr', 'AB'),
    const ActorFilterEntry('Alexander Hamilton', 'AH'),
    const ActorFilterEntry('Eliza Hamilton', 'EH'),
    const ActorFilterEntry('James Madison', 'JM'),
  ];
  final List<String> _filters = <String>[];

  Iterable<Widget> get actorWidgets {
    return _cast.map((ActorFilterEntry actor) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: FilterChip(
          avatar: CircleAvatar(child: Text(actor.initials)),
          label: Text(actor.name),
          selected: _filters.contains(actor.name),
          onSelected: (bool value) {
            setState(() {
              if (value) {
                _filters.add(actor.name);
              } else {
                _filters.removeWhere((String name) {
                  return name == actor.name;
                });
              }
            });
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: [
        Container(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: actorWidgets.toList(),
          ),
        ),
        Container(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: actorWidgets.toList(),
          ),
        ),
        Container(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: actorWidgets.toList(),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            /*Expanded(
              child: FloatingActionButton.extended(
                  label: Text("Apply"), onPressed: () {}),
            ),
            FloatingActionButton.extended(label: Text("Reset"), onPressed: () {})*/
          ],
        )
      ],
    );
  }
}

class WardrobeFrontLayer extends StatefulWidget {
  WardrobeFrontLayer({Key? key, required this.controller}) : super(key: key);

  final AnimationController controller;

  @override
  State<StatefulWidget> createState() {
    return WardrobeFrontLayerState();
  }
}

class WardrobeFrontLayerState extends State<WardrobeFrontLayer>{

  late Animation<double> _animationScale;
  late Animation<double> _animationOpacity;

  @override
  void initState(){
    super.initState();
    _animationScale = Tween(begin: 0.6, end: 1.0).animate(widget.controller);
    _animationOpacity = Tween(begin: 0.3, end: 1.0).animate(widget.controller);
    wardrobeModel.loadArticles(ArticleDBWorker.articleDBWorker, profile);
  }

  @override
  void dispose(){
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.forward();
    return FadeTransition(
      opacity: CurvedAnimation(parent: _animationOpacity, curve: Curves.easeInOutCubic),
      child: ScaleTransition(
        scale: CurvedAnimation(parent: _animationScale, curve: Curves.easeInOutCubic),
        child: ChangeNotifierProvider.value(
          value: wardrobeModel,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Consumer<WardrobeModel>(builder: (context, wardrobe, child) {
              log(wardrobe.articles.toString());
              return Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 52),
                    child: GridView.builder(
                      padding: EdgeInsets.only(bottom: 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 1.3,
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        if (wardrobe.isLoading) {
                          return buildCardShimmer();
                        } else {
                          return ArticleCard(
                            index: index,
                            wardrobe: wardrobe,
                          );
                        }
                      },
                      itemCount: wardrobe.isLoading ? 8 : wardrobe.articles?.length,
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
      ),
    );
  }
}

class ArticleCard extends StatelessWidget {
  ArticleCard({required this.wardrobe, required this.index});

  WardrobeModel wardrobe;
  int index;

  void _handleTap(BuildContext context, GlobalKey parentKey) {
    Navigator.of(context).push(MorpheusPageRoute(
      builder: (context) =>
          Articolo(article: wardrobe.articles!.elementAt(index)),
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
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Hero(
                tag: "articolo${wardrobe.articles![index].id}",
                child: Image.file(
                  File(wardrobe.articles!.elementAt(index).imgPath!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  LikeButton(
                    isLiked: wardrobe.articles!.elementAt(index).favorite,
                    onTap: (isLiked) async{
                      wardrobe.articles?.elementAt(index).favorite = !isLiked;
                      wardrobe.updateArticle(ArticleDBWorker.articleDBWorker, wardrobe.articles?.elementAt(index) as ArticleModel, profile, withReload: false);
                      return !isLiked;
                    },
                  ),
                  IconButton(
                      onPressed: () {
                        mbs.showMaterialModalBottomSheet(
                          useRootNavigator: true,
                          context: context,
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () async{
                                    var toBeDeleted = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: Text(
                                              "Sei sicuro di voler eliminare questo articolo?"),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('No'),
                                              onPressed: () {
                                                Navigator.of(context).pop(false);
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Sì'),
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                                Navigator.of(context).pop(true);
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    log("Cancellare articolo?: $toBeDeleted");
                                    if(toBeDeleted){
                                      wardrobe.removeArticle(ArticleDBWorker.articleDBWorker ,wardrobe.articles?.elementAt(index).id as int, profile );
                                    }
                                  },
                                  child: const ListTile(
                                    title: Text("Elimina Articolo"),
                                    leading: Icon(Icons.delete),
                                  ),
                                ),
                                InkWell(
                                  onTap: (){},
                                  child: const ListTile(
                                    title: Text("Mostra Possibili Abbinamenti"),
                                    leading: Icon(Icons.add),
                                  ),
                                ),
                                InkWell(
                                  onTap: (){},
                                  child: const ListTile(
                                    title: Text("Modifica"),
                                    leading: Icon(Icons.edit),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.more_vert))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
