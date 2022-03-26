import 'dart:io';
import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/models/outfit_model.dart';
import 'package:esempio/models/your_account_model.dart';
import 'package:esempio/screens/outfit.dart';
import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'package:esempio/common/utils.dart';
import 'package:provider/provider.dart';
import 'package:esempio/models/explore_model.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:esempio/db/article_db_worker.dart';
import 'package:esempio/models/wardrobe_model.dart';
import 'package:esempio/models/article_model.dart';
import 'package:esempio/screens/explore_outfits.dart';
import 'package:animations/animations.dart';

class Explore extends StatelessWidget {
  Explore({Key? key, required this.controller}) : super(key: key);

  final int currentIndex = 0;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ExploreModel>.value(
      value: exploreModel,
      child: Container(
        color: const Color(0xFF425C5A),
        child: SafeArea(
          child: BackdropScaffold(
            frontLayerBackgroundColor: const Color(0xFF425C5A),
            stickyFrontLayer: true,
            maintainBackLayerState: true,
            appBar: ExploreAppBar(),
            frontLayer:
                Consumer<ExploreModel>(builder: (context, explore, child) {
              return PageTransitionSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (widget, anim1, anim2) {
                  return SharedAxisTransition(
                    transitionType: SharedAxisTransitionType.vertical,
                    fillColor: const Color(0xFF425C5A),
                    animation:  anim1,
                    secondaryAnimation: anim2,
                    child: widget,
                  );
                },
                child: IndexedStack(key: ValueKey<int>(explore.currentIndex),index: explore.currentIndex, children: [
                  ExploreFrontLayer(
                    controller: controller,
                    scrollController: explore.homeScrollController,
                  ),
                  FilteredOutfitsFrontLayer(
                      scrollController: explore.newPageScrollController,
                      subheaderTitle: "Filtrato")
                ]),
              );
            }),
            backLayer: const ExploreBackLayer(),
          ),
        ),
      ),
    );
  }
}

class ExploreAppBar extends BackdropAppBar {
  ExploreAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExploreModel>(builder: (context, explore, child) {
      return ScrollAppBar(
        foregroundColor: const Color(0xFFFDCDA2),
        controller: explore.currentIndex == 0 ? explore.homeScrollController : explore.newPageScrollController,
        leading: explore.currentIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  explore.showScreen(0, Section.home);
                })
            : null,
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

/*class ExploreBackLayer extends StatefulWidget {
  const ExploreBackLayer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ExploreBackLayerState();
  }
}*/

class ExploreBackLayer extends StatelessWidget {
  const ExploreBackLayer({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TabBar(padding: const EdgeInsets.only(bottom: 3), tabs: [
            Tab(
              child: Row(
                children: const [Icon(Icons.directions_transit), Text("Outfits")],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ),
            Tab(
              child: Row(
                children: const [Icon(Icons.directions_bike), Text("Utenti")],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ),
          ]),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: const TabBarView(
              children: [ExploreBackLayerOutfit(), ExploreBackLayerUser()],
            ),
          ),
        ],
      ),
    );
  }
}

class ExploreBackLayerUser extends StatefulWidget {
  const ExploreBackLayerUser({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ExploreBackLayerUserState();
  }
}

class ExploreBackLayerUserState extends State<ExploreBackLayerUser>
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

    wardrobeModel.filter(ArticleDBWorker.articleDBWorker, personalProfile.myProfile);

    Backdrop.of(context).concealBackLayer();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Utenti Filtrati con successo")));
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
                  decoration: const BoxDecoration(),
                  title: const Text("Brand"),
                  searchable: true,
                  items: _multiSelectFromMap(brands),
                  listType: MultiSelectListType.LIST,
                  chipDisplay: MultiSelectChipDisplay(
                    scroll: true,
                    icon: const Icon(Icons.close),
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
                  decoration: const BoxDecoration(),
                  //selectedColor: Color(0xFF425C5A),
                  checkColor: Colors.white70,
                  title: const Text("Tipo Capo"),
                  items: _multiSelectFromMap(clothing),
                  listType: MultiSelectListType.CHIP,
                  chipDisplay: MultiSelectChipDisplay(
                    scroll: true,
                    icon: const Icon(Icons.close),
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all(const Color(0xFFFDCDA2)),
                            backgroundColor:
                                MaterialStateProperty.all(const Color(0xFF76454E))),
                        child: const Text("Filtra Articoli"),
                        onPressed: () {
                          _save(context);
                        },
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 30),
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

class ExploreBackLayerOutfit extends StatefulWidget {
  const ExploreBackLayerOutfit({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ExploreBackLayerOutfitState();
  }
}

class ExploreBackLayerOutfitState extends State<ExploreBackLayerOutfit>
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

  List<DropdownMenuItem<int>> _dropdownFromMap(Map<int,String> map){
    List<DropdownMenuItem<int>> items=[];
    map.forEach((key, value) {
      items.add(DropdownMenuItem(value: key,child: Text(value.toString())));
    });
    return items;
  }

  List _selectedSeasons = [];
  List _selectedDressCodes = [];

  _save(BuildContext context) async {
    _outfitFormKey.currentState!.save();
    //TODO: Add validation to input

    exploreModel.filterOutfits(OutfitDBWorker.outfitDBWorker, personalProfile.myProfile);

    Backdrop.of(context).concealBackLayer();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Outfit filtrati con successo")));
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
              DropdownButtonFormField<int>(items: _dropdownFromMap(orderFilters), onChanged: (item){}, onSaved: (item){
                exploreModel.filterOrder = Order.values[item!];
              },),
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
                  decoration: const BoxDecoration(),
                  title: const Text("Stagione"),
                  searchable: true,
                  items: _multiSelectFromMap(seasons),
                  listType: MultiSelectListType.CHIP,
                  chipDisplay: MultiSelectChipDisplay(
                    scroll: true,
                    icon: const Icon(Icons.close),
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
                  decoration: const BoxDecoration(),
                  //selectedColor: Color(0xFF425C5A),
                  checkColor: Colors.white70,
                  title: const Text("Dress Code"),
                  items: _multiSelectFromMap(dressCodes),
                  listType: MultiSelectListType.CHIP,
                  chipDisplay: MultiSelectChipDisplay(
                    scroll: true,
                    icon: const Icon(Icons.close),
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all(const Color(0xFFFDCDA2)),
                            backgroundColor:
                                MaterialStateProperty.all(const Color(0xFF76454E))),
                        child: const Text("Filtra Articoli"),
                        onPressed: () {
                          exploreModel.showScreen(1, Section.filteredOutf);
                          _save(context);
                        },
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 30),
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
    exploreModel.loadData(OutfitDBWorker.outfitDBWorker, personalProfile.myProfile);
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
                                explore2: explore,
                                section: Section.recOutf,
                                cardShape: const RoundedRectangleBorder(),
                                title: "Consigliati per Te",
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              HorizontalMoreList(
                                explore2: explore,
                                section: Section.newHotOutf,
                                cardShape: const RoundedRectangleBorder(),
                                title: "Nuovi di Tendenza",
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              HorizontalMoreList(
                                section: Section.popOutf,
                                explore2: explore,
                                cardShape: const RoundedRectangleBorder(),
                                title: "I Più Popolari",
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              HorizontalMoreList(
                                section: Section.popUsers,
                                explore2: explore,
                                title: "I Migliori Designer",
                                cardShape: const CircleBorder(),
                                itemHeight: 150,
                              ),
                              const SizedBox(height: kToolbarHeight,)
                            ],
                          ),
                        ],
                      ),
                    ),
                    const BackdropSubHeader(
                      title: Text("Esplora la Community"),
                    ),
                  ],
                );
            },
          ),
        ),
      ),
    );
  }
}
