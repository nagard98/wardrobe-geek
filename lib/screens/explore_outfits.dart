import 'dart:developer';
import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/db/profile_db_worker.dart';
import 'package:esempio/models/outfit_model.dart';
import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import '../common/utils.dart';
import 'package:esempio/models/your_account_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:esempio/models/explore_model.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';


class ExploreOutfitFrontLayer extends StatefulWidget {
  const ExploreOutfitFrontLayer(
      {Key? key, required this.controller, required this.scrollController})
      : super(key: key);

  final AnimationController controller;
  final ScrollController scrollController;

  @override
  State<StatefulWidget> createState() {
    return ExploreOutfitFrontLayerState();
  }
}

class ExploreOutfitFrontLayerState extends State<ExploreOutfitFrontLayer> {
  late Animation<double> _animationScale;
  late Animation<double> _animationOpacity;

  @override
  void initState() {
    super.initState();
    _animationScale = Tween(begin: 0.6, end: 1.0).animate(widget.controller);
    _animationOpacity = Tween(begin: 0.3, end: 1.0).animate(widget.controller);
    exploreModel.loadData(
        OutfitDBWorker.outfitDBWorker, ProfileDBWorker.profileDBWorker, personalProfile.myProfile);
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
                            HorizontalOutfitList(
                              explore2: explore,
                              section: Section.recOutf,
                              cardShape: const RoundedRectangleBorder(),
                              title: "Consigliati per Te",
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            HorizontalOutfitList(
                              explore2: explore,
                              section: Section.newHotOutf,
                              cardShape: const RoundedRectangleBorder(),
                              title: "Nuovi di Tendenza",
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            HorizontalOutfitList(
                              section: Section.popOutf,
                              explore2: explore,
                              cardShape: const RoundedRectangleBorder(),
                              title: "I Più Popolari",
                            ),
                            const SizedBox(
                              height: 30,
                            ),
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

  List<DropdownMenuItem<int>> _dropdownFromMap(Map<int, String> map) {
    List<DropdownMenuItem<int>> items = [];
    map.forEach((key, value) {
      items.add(DropdownMenuItem(value: key, child: Text(value.toString())));
    });
    return items;
  }

  List _selectedSeasons = [];
  List _selectedDressCodes = [];

  _save(BuildContext context) async {
    _outfitFormKey.currentState!.save();
    //TODO: Add validation to input

    exploreModel.filterOutfits(
        OutfitDBWorker.outfitDBWorker, personalProfile.myProfile);

    Backdrop.of(context).concealBackLayer();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Outfit filtrati con successo")));
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
                const Divider(color: Color(0xFF486563), thickness: 3, height: 20,),
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0,right: 8.0),
                      child: Text("Ordina per", style: TextStyle(color: Color(0xFFFDCDA2)),),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.white60,
                        ),
                        child: DropdownButtonFormField<int>(
                          items: _dropdownFromMap(orderFilters),
                          value: 0,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFA4626D),),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(16.0, 2.0,12.0,2.0),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none
                            )
                          ),
                          style: const TextStyle(color: Colors.black),
                          onChanged: (item) {},
                          onSaved: (item) {
                            exploreModel.filterOrder = Order.values[item!];
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(
                  color: Color(0xFF486563),
                  thickness: 2,
                  height: 20,
                ),
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
                  height: 20,
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
                            foregroundColor: MaterialStateProperty.all(
                                const Color(0xFFFDCDA2)),
                            backgroundColor: MaterialStateProperty.all(
                                const Color(0xFF76454E))),
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


class FilteredOutfitsFrontLayer extends StatefulWidget {
  const FilteredOutfitsFrontLayer({Key? key, required this.scrollController, required this.subheaderTitle}) : super(key: key);

  final ScrollController scrollController;
  final String subheaderTitle;

  @override
  State<StatefulWidget> createState() {
    return FilteredOutfitsFrontLayerState();
  }
}

class FilteredOutfitsFrontLayerState extends State<FilteredOutfitsFrontLayer>{

  @override
  void initState() {
    super.initState();
    //myOutfitsModel.loadOutfits(OutfitDBWorker.outfitDBWorker, profile);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Consumer<ExploreModel>(builder: (context, explore, child) {
        if(explore.currentSection != Section.home){
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 52, left: 6.0, right: 6.0),
                child: AnimationLimiter(
                  child: GridView.builder(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.only(bottom: kToolbarHeight+10),
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
                        log(explore.getList(explore.currentSection).elementAt(index).addedOn.toString());
                        return OutfitCard(
                          index: index,
                          outfitsInterface: explore,
                          section: explore.currentSection,
                          heroTag: "outfitnewpage${explore.currentSection}${index}",
                        );
                      }
                    },
                    itemCount: explore.isLoading
                        ? 8
                        : explore.getList(explore.currentSection).length,
                  ),
                ),
              ),
              BackdropSubHeader(
                title: Text(explore.currentSection.name),
              ),
            ],
          );
        }else{
          return const SizedBox();
        }
      }),
    );
  }
}