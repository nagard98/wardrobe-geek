import 'dart:developer';

import 'package:esempio/db/profile_db_worker.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:backdrop/backdrop.dart';
import 'package:esempio/models/your_account_model.dart';
import 'package:esempio/db/article_db_worker.dart';
import 'package:esempio/models/wardrobe_model.dart';
import 'package:esempio/common/utils.dart';
import 'package:esempio/models/article_model.dart';
import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/models/explore_model.dart';
import 'package:provider/provider.dart';

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

  List<DropdownMenuItem<int>> _dropdownFromMap(Map<int, String> map) {
    List<DropdownMenuItem<int>> items = [];
    map.forEach((key, value) {
      items.add(DropdownMenuItem(value: key, child: Text(value.toString())));
    });
    return items;
  }

  List _selectedBrands = [];
  List _selectedClothingType = [];

  _save(BuildContext context) async {
    _userFormKey.currentState!.save();
    //TODO: Add validation to input

    wardrobeModel.filter(
        ArticleDBWorker.articleDBWorker, personalProfile.myProfile);

    Backdrop.of(context).concealBackLayer();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Utenti Filtrati con successo")));
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

class ExploreUsersFrontLayer extends StatefulWidget {
  const ExploreUsersFrontLayer(
      {Key? key, required this.controller, required this.scrollController})
      : super(key: key);

  final AnimationController controller;
  final ScrollController scrollController;

  @override
  State<StatefulWidget> createState() {
    return ExploreUsersFrontLayerState();
  }
}

class ExploreUsersFrontLayerState extends State<ExploreUsersFrontLayer> {
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
                            HorizontalUserList(
                              section: Section.recUsers,
                              explore2: explore,
                              title: "Raccomandati per Te",
                              cardShape: const CircleBorder(),
                              itemHeight: 140,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            HorizontalUserList(
                              section: Section.popUsers,
                              explore2: explore,
                              title: "I Migliori Designer",
                              cardShape: const CircleBorder(),
                              itemHeight: 140,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            HorizontalUserList(
                              section: Section.newHotUsers,
                              explore2: explore,
                              title: "Designer di Tendenza",
                              cardShape: const CircleBorder(),
                              itemHeight: 140,
                            ),
                            const SizedBox(
                              height: kToolbarHeight,
                            )
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

class FilteredUsersFrontLayer extends StatefulWidget {
  const FilteredUsersFrontLayer(
      {Key? key, required this.scrollController, required this.subheaderTitle})
      : super(key: key);

  final ScrollController scrollController;
  final String subheaderTitle;

  @override
  State<StatefulWidget> createState() {
    return FilteredUsersFrontLayerState();
  }
}

class FilteredUsersFrontLayerState extends State<FilteredUsersFrontLayer> {
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
        if (explore.currentSection != Section.home) {
          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 52, left: 6.0, right: 6.0),
                child: GridView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.only(bottom: kToolbarHeight + 10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 0.6,
                    crossAxisCount: 2,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    if (explore.isLoading) {
                      return buildCardShimmer();
                    } else {
                      //TODO: implementa card utenti
                      return SizedBox();
                      /*log(explore
                          .getListOutfits(explore.currentSection)
                          .elementAt(index)
                          .addedOn
                          .toString());
                      return OutfitCard(
                        index: index,
                        outfitsInterface: explore,
                        section: explore.currentSection,
                        heroTag:
                            "outfitnewpage${explore.currentSection}${index}",
                      );*/
                    }
                  },
                  itemCount: explore.isLoading
                      ? 8
                      : explore.getList(explore.currentSection).length,
                ),
              ),
              BackdropSubHeader(
                title: Text(explore.currentSection.name),
              ),
            ],
          );
        } else {
          return const SizedBox();
        }
      }),
    );
  }
}
