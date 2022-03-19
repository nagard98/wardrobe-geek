import 'dart:io';
import 'dart:math';
import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/models/outfit_model.dart';
import 'package:esempio/screens/my_outfits.dart';
import 'package:esempio/screens/outfit.dart';
import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'package:esempio/common/utils.dart';
import 'package:provider/provider.dart';
import 'package:esempio/models/explore_model.dart';
import 'package:esempio/models/profile_model.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:esempio/db/article_db_worker.dart';
import 'package:esempio/models/wardrobe_model.dart';
import 'package:esempio/models/article_model.dart';
import 'package:morpheus/morpheus.dart';
import 'package:esempio/screens/explore_outfits.dart';
import 'package:animations/animations.dart';
import 'package:bluejay/bluejay.dart' as Bluejay;
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';

class Explore extends StatelessWidget {
  Explore({Key? key, required this.controller}) : super(key: key);

  int currentIndex = 0;
  final AnimationController controller;
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ExploreModel>.value(
      value: exploreModel,
      child: Container(
        color: Color(0xFF425C5A),
        child: SafeArea(
          child: BackdropScaffold(
            frontLayerBackgroundColor: Color(0xFF425C5A),
            stickyFrontLayer: true,
            maintainBackLayerState: true,
            appBar: ExploreAppBar(scrollController),
            frontLayer:
                Consumer<ExploreModel>(builder: (context, explore, child) {
              return PageTransitionSwitcher(
                duration: Duration(milliseconds: 400),
                transitionBuilder: (widget, anim1, anim2) {
                  return SharedAxisTransition(
                    transitionType: SharedAxisTransitionType.vertical,
                    fillColor: Color(0xFF425C5A),
                    animation:  anim1,
                    secondaryAnimation: anim2,
                    child: widget,
                  );
                },
                child: IndexedStack(key: ValueKey<int>(explore.currentIndex),index: explore.currentIndex, children: [
                  ExploreFrontLayer(
                    controller: controller,
                    scrollController: scrollController,
                  ),
                  FilteredOutfitsFrontLayer(
                      scrollController: scrollController,
                      subheaderTitle: "Filtrato")
                ]),
              );
            }),
            backLayer: ExploreBackLayer(),
          ),
        ),
      ),
    );
  }
}

class ExploreAppBar extends BackdropAppBar {
  ExploreAppBar(this.scrollController, {Key? key}) : super(key: key);

  final scrollController;

  @override
  Widget build(BuildContext context) {
    return Consumer<ExploreModel>(builder: (context, explore, child) {
      return ScrollAppBar(
        foregroundColor: const Color(0xFFFDCDA2),
        controller: scrollController,
        leading: explore.currentIndex > 0
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  explore.showScreen(0);
                })
            : SizedBox(),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: const [
          BackdropToggleButton(
            color: Color(0xFFFDCDA2),
          )
        ],
        title: const Text('Explore'),
      );
    });
  }
}

class ExploreBackLayer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ExploreBackLayerState();
  }
}

class ExploreBackLayerState extends State<ExploreBackLayer> {
  final GlobalKey<FormState> _outfitFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _userFormKey = GlobalKey<FormState>();

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
  List _selectedSeasons = [];
  List _selectedDressCodes = [];

  _save(BuildContext context) async {
    _outfitFormKey.currentState!.save();
    //TODO: Add validation to input

    wardrobeModel.filter(ArticleDBWorker.articleDBWorker, profile);

    Backdrop.of(context).concealBackLayer();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Filtrato con successo")));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TabBar(padding: EdgeInsets.only(bottom: 3), tabs: [
            Tab(
              child: Row(
                children: [Icon(Icons.directions_transit), Text("Outfits")],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ),
            Tab(
              child: Row(
                children: [Icon(Icons.directions_bike), Text("Utenti")],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ),
          ]),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 400),
            child: TabBarView(
              children: [ExploreFilterListOutfit(), ExploreFilterListUser()],
            ),
          ),
        ],
      ),
    );
  }
}

class ExploreFilterListUser extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ExploreFilterListUserState();
  }
}

class ExploreFilterListUserState extends State<ExploreFilterListUser>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<FormState> _userFormKey = GlobalKey<FormState>();

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
    _userFormKey.currentState!.save();
    //TODO: Add validation to input

    wardrobeModel.filter(ArticleDBWorker.articleDBWorker, profile);

    Backdrop.of(context).concealBackLayer();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Filtrato con successo")));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Form(
          key: _userFormKey,
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
                ),
                const Divider(
                  color: Color(0xFF486563),
                  thickness: 2,
                  height: 5,
                ),
                MultiSelectColorField(
                  text: "Colore Secondario",
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
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ExploreFilterListOutfit extends StatefulWidget {
  const ExploreFilterListOutfit({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ExploreFilterListOutfitState();
  }
}

class ExploreFilterListOutfitState extends State<ExploreFilterListOutfit>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<FormState> _outfitFormKey = GlobalKey<FormState>();

  List<MultiSelectItem> _multiSelectFromMap(Map<int, String> map) {
    List<MultiSelectItem> items = [];
    map.forEach((key, value) {
      items.add(
        MultiSelectItem(key, value),
      );
    });
    return items;
  }

  List _selectedSeasons = [];
  List _selectedDressCodes = [];

  _save(BuildContext context) async {
    _outfitFormKey.currentState!.save();
    //TODO: Add validation to input

    exploreModel.filterOutfits(OutfitDBWorker.outfitDBWorker, profile);

    Backdrop.of(context).concealBackLayer();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Filtrato con successo")));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Form(
          key: _outfitFormKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Divider(color: Color(0xFF486563), thickness: 3),
                //TODO: implementa ordinamento risultati
/*                          SwitchFormField(
                            title: const Text(
                              "Mostra solo preferiti",
                              style: TextStyle(color: Color(0xFFFDCDA2)),
                            ),
                            onSaved: (state) {
                              myOutfitsModel.filters[Filter.favorite] =
                              (state ?? false) ? [1] : [];
                            },
                          ),*/
/*                          const Divider(
                            color: Color(0xFF486563),
                            thickness: 2,
                            height: 5,
                          ),*/
                MultiSelectDialogField(
                  buttonText: const Text(
                    "Stagione",
                    style: TextStyle(color: Color(0xFFFDCDA2)),
                  ),
                  buttonIcon: const Icon(
                    Icons.add,
                    color: Color(0xFFA4626D),
                  ),
                  //selectedColor: Color(0xFF425C5A),
                  decoration: BoxDecoration(),
                  title: Text("Stagione"),
                  searchable: true,
                  items: _multiSelectFromMap(seasons),
                  listType: MultiSelectListType.CHIP,
                  chipDisplay: MultiSelectChipDisplay(
                    scroll: true,
                    icon: Icon(Icons.close),
                    onTap: (value) {
                      setState(() {
                        _selectedSeasons.remove(value);
                      });
                    },
                  ),
                  onConfirm: (values) {
                    _selectedSeasons = values;
                  },
                  onSaved: (values) {
                    exploreModel.filters[Filter.season] = values ?? [];
                  },
                ),
                const Divider(
                  color: Color(0xFF486563),
                  thickness: 2,
                  height: 5,
                ),
                MultiSelectDialogField(
                  buttonText: const Text(
                    "Dress Code",
                    style: TextStyle(color: Color(0xFFFDCDA2)),
                  ),
                  buttonIcon: const Icon(
                    Icons.add,
                    color: Color(0xFFA4626D),
                  ),
                  decoration: BoxDecoration(),
                  //selectedColor: Color(0xFF425C5A),
                  checkColor: Colors.white70,
                  title: Text("Dress Code"),
                  items: _multiSelectFromMap(dressCodes),
                  listType: MultiSelectListType.CHIP,
                  chipDisplay: MultiSelectChipDisplay(
                    scroll: true,
                    icon: Icon(Icons.close),
                    onTap: (value) {
                      setState(() {
                        _selectedDressCodes.remove(value);
                      });
                    },
                  ),
                  onConfirm: (values) {
                    _selectedDressCodes = values;
                  },
                  onSaved: (values) {
                    exploreModel.filters[Filter.dressCode] = values ?? [];
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

  @override
  bool get wantKeepAlive => true;
}

class ExploreFrontLayer extends StatefulWidget {
  const ExploreFrontLayer(
      {Key? key, required this.controller, required this.scrollController})
      : super(key: key);

  final AnimationController controller;
  final ScrollController scrollController;

  @override
  State<StatefulWidget> createState() {
    return ExploreFrontLayerState();
  }
}

class ExploreFrontLayerState extends State<ExploreFrontLayer> {
  late Animation<double> _animationScale;
  late Animation<double> _animationOpacity;

  @override
  void initState() {
    super.initState();
    _animationScale = Tween(begin: 0.6, end: 1.0).animate(widget.controller);
    _animationOpacity = Tween(begin: 0.3, end: 1.0).animate(widget.controller);
    exploreModel.loadData(OutfitDBWorker.outfitDBWorker, profile);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
          curve: Curves.easeInOutCubic, parent: _animationOpacity),
      child: ScaleTransition(
        scale: CurvedAnimation(
            curve: Curves.easeInOutCubic, parent: _animationScale),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: Consumer<ExploreModel>(
            builder: (context, explore, child) {
              if (explore.isFilteredOutfits) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16)),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.only(top: 52, left: 6.0, right: 6.0),
                        child: GridView.builder(
                          controller: widget.scrollController,
                          padding: EdgeInsets.only(bottom: 30),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 0.6,
                            crossAxisCount: 2,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemBuilder: (context, index) {
                            if (explore.isLoading) {
                              return buildCardShimmer();
                            } else {
                              return OutfitCard(
                                  index: index,
                                  outfitsInterface: explore,
                                  section: Section.filteredOutf);
                            }
                          },
                          itemCount: explore.isLoading
                              ? 8
                              : explore
                                  .exploreMap[Section.filteredOutf]?.length,
                        ),
                      ),
                      BackdropSubHeader(
                        title: Text("I Miei Outfit"),
                      ),
                    ],
                  ),
                );
              } else {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 52),
                      child: ListView(
                        controller: widget.scrollController,
                        children: [
                          Column(
                            children: [
                              HorizontalMoreList(
                                explore: explore,
                                section: Section.recOutf,
                                title: "Consigliati per Te",
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              HorizontalMoreList(
                                explore: explore,
                                section: Section.newHotOutf,
                                title: "Nuovi di Tendenza",
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              HorizontalMoreList(
                                section: Section.popOutf,
                                explore: explore,
                                title: "I Più Popolari",
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              HorizontalMoreList(
                                section: Section.popUsers,
                                explore: explore,
                                title: "I Migliori Designer",
                                cardShape: CircleBorder(),
                                itemHeight: 150,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    BackdropSubHeader(
                      title: Text("Esplora la Community"),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class HorizontalMoreList extends StatelessWidget {
  HorizontalMoreList(
      {Key? key,
      this.title = 'Title',
      this.explore,
      required this.section,
      this.itemHeight = 250,
      this.cardShape = const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)))})
      : super(key: key);

  void _handleTap(BuildContext context, GlobalKey parentKey) {
    /*Navigator.of(context).push(MorpheusPageRoute(
      builder: (context) => ExploreOutfits(),
      parentKey: parentKey,
    ));*/
/*    pushNewScreen(context,
        screen: FilteredOutfitsFrontLayer(subheaderTitle: "Titolo",),
        withNavBar: true,
        pageTransitionAnimation: PageTransitionAnimation.cupertino);*/
  }

  final bool isLoading = false;
  double itemHeight;
  ShapeBorder cardShape;
  String title;
  ExploreModel? explore;
  Section section;

  @override
  Widget build(BuildContext context) {
    final _parentKey = GlobalKey();
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              TextButton(
                style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Color(0xFFFDCDA2)),
                    foregroundColor:
                        MaterialStateProperty.all(Color(0xFFA4626D))),
                onPressed: () {
                  explore?.showScreen(1);
                },
                child: Row(
                  children: [Text("Vedi Tutti"), Icon(Icons.arrow_forward_ios)],
                ),
              ),
            ],
          ),
          SizedBox(
            height: itemHeight,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 1.5,
                crossAxisCount: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                if (explore!.isLoading) {
                  return buildCardShimmer();
                } else {
                  return InkWell(
                    child: Card(
                      shape: cardShape,
                      clipBehavior: Clip.hardEdge,
                      child: Image.file(
                        //TODO: implement dynamic loading
                        File(explore?.exploreMap[section]?[index].imgPath
                            as String),
                        fit: BoxFit.cover,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Outfit(
                              outfit: explore?.exploreMap[section]
                                  ?.elementAt(index) as OutfitModel)));
                    },
                  );
                }
              },
              itemCount: explore!.isLoading
                  ? 4
                  : (explore?.exploreMap[section]?.length as int > 4
                      ? 4
                      : explore?.exploreMap[section]?.length),
            ),
          ),
        ],
      ),
    );
  }
}
