import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import '../common/utils.dart';
import 'package:provider/provider.dart';
import 'package:esempio/models/wishlist_model.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';
import 'package:esempio/models/explore_model.dart';
import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/models/your_account_model.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:esempio/models/outfit_model.dart';

class Wishlist extends StatelessWidget{
  Wishlist({Key? key, required this.controller}) : super(key: key);

  final AnimationController controller;
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WishlistModel>.value(
      value: wishlistModel,
      child: Container(
        color: const Color(0xFF425C5A),
        child: SafeArea(
          child: BackdropScaffold(
            frontLayerBackgroundColor: const Color(0xFF425C5A),
            stickyFrontLayer: true,
            appBar: WishlistAppBar(scrollController),
            frontLayer: WishlistFrontLayer(controller: controller, scrollController: scrollController),
            backLayer: const WishlistBackLayer(),
          ),
        ),
      ),
    );
  }

}

class WishlistAppBar extends BackdropAppBar{
  WishlistAppBar(this.scrollController, {Key? key}) : super(key: key);

  final ScrollController scrollController;

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
      title: const Text('Wishlist'),
    );
  }
}

class WishlistBackLayer extends StatefulWidget{
  const WishlistBackLayer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WishlistBackLayerState();
  }

}

class WishlistBackLayerState extends State<WishlistBackLayer>{
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

  List _selectedSeasons = [];
  List _selectedDressCodes = [];

  _save(BuildContext context) async {
    _formKey.currentState!.save();
    //TODO: Add validation to input

    wishlistModel.filter(
        OutfitDBWorker.outfitDBWorker, personalProfile.myProfile);

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
                /*SwitchFormField(
                  title: const Text(
                    "Mostra solo preferiti",
                    style: TextStyle(color: Color(0xFFFDCDA2)),
                  ),
                  onSaved: (state) {
                    wishlistModel.filters[Filter.favorite] =
                    (state ?? false) ? [1] : [];
                  },
                ),
                const Divider(
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
                    wishlistModel.filters[Filter.season] = values ?? [];
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
                    wishlistModel.filters[Filter.dressCode] = values ?? [];
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
                        child: const Text("Filtra Outfit Wishlist"),
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
        ),
      ],
    );
  }
}

class WishlistFrontLayer extends StatefulWidget{
  const WishlistFrontLayer({Key? key, required this.controller, required this.scrollController}) : super(key: key);

  final AnimationController controller;
  final ScrollController scrollController;

  @override
  State<StatefulWidget> createState() {
    return WishlistFrontLayerState();
  }
}

class WishlistFrontLayerState extends State<WishlistFrontLayer> {
  late Animation<double> _animationScale;
  late Animation<double> _animationOpacity;

  @override
  void initState() {
    super.initState();
    _animationScale = Tween(begin: 0.6, end: 1.0).animate(widget.controller);
    _animationOpacity = Tween(begin: 0.3, end: 1.0).animate(widget.controller);
    wishlistModel.loadOutfits(OutfitDBWorker.outfitDBWorker, personalProfile.myProfile);
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
          child: Consumer<WishlistModel>(builder: (context, wishlist, child) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 52,left: 6.0, right: 6.0),
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
                        if (wishlist.isLoading) {
                          return buildCardShimmer();
                        } else {
                          return OutfitCard(index: index, outfitsInterface: wishlist, section: Section.wishlist, heroTag: "wishlist$index",);
                        }
                      },
                      itemCount:
                      wishlist.isLoading ? 8 : wishlist.wishlistOutfits.length,
                    ),
                ),
                const BackdropSubHeader(
                  title: Text("La mia Wishlist"),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}