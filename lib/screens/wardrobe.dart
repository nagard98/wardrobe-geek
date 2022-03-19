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
import 'package:scroll_app_bar/scroll_app_bar.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class Wardrobe extends StatelessWidget {
  Wardrobe({Key? key, required this.controller}) : super(key: key);

  final AnimationController controller;
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WardrobeModel>.value(
      value: wardrobeModel,
      child: Container(
        color: Color(0xFF425C5A),
        child: SafeArea(
          child: BackdropScaffold(
            maintainBackLayerState: true,
            frontLayerBackgroundColor: Color(0xFF486563),
            stickyFrontLayer: true,
            appBar: WardrobeAppBar(scrollController),
            frontLayer: WardrobeFrontLayer(
                controller: controller, scrollController: scrollController),
            backLayer: const WardrobeBackLayer(),
            floatingActionButton: WardrobeFAB(),
          ),
        ),
      ),
    );
  }
}

class WardrobeFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<WardrobeModel>(builder: (context, wardrobe, child) {
      return FloatingActionButton(
          backgroundColor: Color(0xFFA4626D),
          foregroundColor: Color(0xFFFDCDA2),
          child: const Icon(Icons.add),
          onPressed: () {
            wardrobe.currentArticle = ArticleModel();
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              //TODO: Correggi crash sporadico aggiunta immagine(scomparso?)
              return NuovoArticolo();
            }));
          });
    });
  }
}

class WardrobeAppBar extends BackdropAppBar {
  WardrobeAppBar(this.scrollController, {Key? key}) : super(key: key);

  final scrollController;

  @override
  Widget build(BuildContext context) {
    return ScrollAppBar(
      foregroundColor: const Color(0xFFFDCDA2),
      controller: scrollController,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: const [
        BackdropToggleButton(
          color: Color(0xFFFDCDA2),
        )
      ],
      title: const Text('Wardrobe'),
    );
  }
}

class WardrobeBackLayer extends StatefulWidget {
  const WardrobeBackLayer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WardrobeBackLayerState();
  }
}

class WardrobeBackLayerState extends State<WardrobeBackLayer> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<MultiSelectItem> _multiSelectFromMap(Map<int, String> map) {
    List<MultiSelectItem> items = [];
    map.forEach((key, value) {
      items.add(
        MultiSelectItem(key, value),
      );
    });
    return items;
  }

  List _selectedBrands = [];
  List _selectedClothingType = [];

  _save(BuildContext context) async {
    _formKey.currentState!.save();
    //TODO: Add validation to input

    wardrobeModel.filter(ArticleDBWorker.articleDBWorker, profile);

    Backdrop.of(context).concealBackLayer();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Filtrato con successo")));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: <Widget>[
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Divider(color: Color(0xFF486563), thickness: 3),
                //TODO: implementa ordinamento risultati
                SwitchFormField(
                  title: const Text(
                    "Mostra solo preferiti",
                    style: TextStyle(color: Color(0xFFFDCDA2)),
                  ),
                  onSaved: (state) {
                    wardrobeModel.filters[Filter.fav] =
                        (state ?? false) ? [1] : [];
                  },
                ),
                const Divider(
                  color: Color(0xFF486563),
                  thickness: 2,
                  height: 5,
                ),
                MultiSelectDialogField(
                  buttonText: const Text(
                    "Brand",
                    style: TextStyle(color: Color(0xFFFDCDA2)),
                  ),
                  buttonIcon: const Icon(
                    Icons.add,
                    color: Color(0xFFA4626D),
                  ),
                  //selectedColor: Color(0xFF425C5A),
                  decoration: BoxDecoration(),
                  title: Text("Brand"),
                  searchable: true,
                  items: _multiSelectFromMap(brands),
                  listType: MultiSelectListType.LIST,
                  chipDisplay: MultiSelectChipDisplay(
                    scroll: true,
                    icon: Icon(Icons.close),
                    onTap: (value) {
                      setState(() {
                        _selectedBrands.remove(value);
                      });
                    },
                  ),
                  onConfirm: (values) {
                    _selectedBrands = values;
                  },
                  onSaved: (values) {
                    wardrobeModel.filters[Filter.brand] = values ?? [];
                  },
                ),
                const Divider(
                  color: Color(0xFF486563),
                  thickness: 2,
                  height: 5,
                ),
                MultiSelectDialogField(
                  buttonText: const Text(
                    "Tipo Capo",
                    style: TextStyle(color: Color(0xFFFDCDA2)),
                  ),
                  buttonIcon: const Icon(
                    Icons.add,
                    color: Color(0xFFA4626D),
                  ),
                  decoration: BoxDecoration(),
                  //selectedColor: Color(0xFF425C5A),
                  checkColor: Colors.white70,
                  title: Text("Tipo Capo"),
                  items: _multiSelectFromMap(clothing),
                  listType: MultiSelectListType.CHIP,
                  chipDisplay: MultiSelectChipDisplay(
                    scroll: true,
                    icon: Icon(Icons.close),
                    onTap: (value) {
                      setState(() {
                        _selectedClothingType.remove(value);
                      });
                    },
                  ),
                  onConfirm: (values) {
                    _selectedClothingType = values;
                  },
                  onSaved: (values) {
                    wardrobeModel.filters[Filter.clothingType] = values ?? [];
                  },
                ),
                const Divider(
                  color: Color(0xFF486563),
                  thickness: 2,
                  height: 5,
                ),
                MultiSelectColorField(
                  text: "Colore Primario",
                  onSaved: (value){
                    var list = value?.map((e) => e.value).toList();
                    wardrobeModel.filters[Filter.primColor] = list!;
                  },
                ),
                const Divider(
                  color: Color(0xFF486563),
                  thickness: 2,
                  height: 5,
                ),
                MultiSelectColorField(
                  text: "Colore Secondario",
                  onSaved: (value){
                    var list = value?.map((e) => e.value).toList();
                    wardrobeModel.filters[Filter.secColor] = list!;
                  },
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all(Color(0xFFFDCDA2)),
                            backgroundColor:
                                MaterialStateProperty.all(Color(0xFF76454E))),
                        child: Text("Filtra Articoli"),
                        onPressed: () {
                          _save(context);
                        },
                      ),
                    )
                  ],
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class WardrobeFrontLayer extends StatefulWidget {
  WardrobeFrontLayer(
      {Key? key, required this.controller, required this.scrollController})
      : super(key: key);

  final AnimationController controller;
  final ScrollController scrollController;

  @override
  State<StatefulWidget> createState() {
    return WardrobeFrontLayerState();
  }
}

class WardrobeFrontLayerState extends State<WardrobeFrontLayer> {
  late Animation<double> _animationScale;
  late Animation<double> _animationOpacity;

  @override
  void initState() {
    super.initState();
    _animationScale = Tween(begin: 0.6, end: 1.0).animate(widget.controller);
    _animationOpacity = Tween(begin: 0.3, end: 1.0).animate(widget.controller);
    wardrobeModel.loadArticles(ArticleDBWorker.articleDBWorker, profile);
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
      opacity: CurvedAnimation(
          parent: _animationOpacity, curve: Curves.easeInOutCubic),
      child: ScaleTransition(
        scale: CurvedAnimation(
            parent: _animationScale, curve: Curves.easeInOutCubic),
        child: ChangeNotifierProvider.value(
          value: wardrobeModel,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFBFBFB),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Consumer<WardrobeModel>(builder: (context, wardrobe, child) {
              log(wardrobe.articles.toString());
              return Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 52, left: 6, right: 6),
                    child: GridView.builder(
                      controller: widget.scrollController,
                      padding: EdgeInsets.only(bottom: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 1.5,
                        crossAxisCount: 2,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
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
                      itemCount:
                          wardrobe.isLoading ? 8 : wardrobe.articles?.length,
                    ),
                  ),
                  BackdropSubHeader(
                    title: Text("I Miei Articoli"),
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
  ArticleCard({Key? key, required this.wardrobe, required this.index}) : super(key: key);

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
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        //elevation: 0,
        //shape: RoundedRectangleBorder(side: BorderSide(color: Colors.indigo, width: 2), borderRadius: BorderRadius.circular(4)),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LikeButton(
                    likeBuilder: (bool isLiked) {
                      return Icon(
                        Icons.favorite,
                        color: isLiked ? Color(0xFFDC4F4F) : Colors.grey,
                      );
                    },
                    isLiked: wardrobe.articles!.elementAt(index).favorite,
                    onTap: (isLiked) async {
                      wardrobe.articles?.elementAt(index).favorite = !isLiked;
                      wardrobe.updateArticle(
                          ArticleDBWorker.articleDBWorker,
                          wardrobe.articles?.elementAt(index) as ArticleModel,
                          profile,
                          withReload: false);
                      return !isLiked;
                    },
                  ),
                  IconButton(
                      color: Color(0xFF425C5A),
                      onPressed: () {
                        mbs.showMaterialModalBottomSheet(
                          useRootNavigator: true,
                          context: context,
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () async {
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
                                                Navigator.of(context)
                                                    .pop(false);
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
                                    if (toBeDeleted) {
                                      wardrobe.removeArticle(
                                          ArticleDBWorker.articleDBWorker,
                                          wardrobe.articles?.elementAt(index).id
                                              as int,
                                          profile);
                                    }
                                  },
                                  child: const ListTile(
                                    title: Text("Elimina Articolo"),
                                    leading: Icon(Icons.delete),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: const ListTile(
                                    title: Text("Mostra Possibili Abbinamenti"),
                                    leading: Icon(Icons.add),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {},
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
