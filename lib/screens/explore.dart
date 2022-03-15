import 'dart:io';
import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/models/outfit_model.dart';
import 'package:esempio/screens/outfit.dart';
import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import '../common/utils.dart';
import 'package:provider/provider.dart';
import 'package:esempio/models/explore_model.dart';
import 'package:esempio/models/profile_model.dart';

class Explore extends StatelessWidget {
  const Explore({Key? key, required this.controller}) : super(key: key);

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ExploreModel>.value(
      value: exploreModel,
      child: BackdropScaffold(
        stickyFrontLayer: true,
        appBar: ExploreAppBar(),
        frontLayer: ExploreFrontLayer(controller: controller),
        backLayer: ExploreBackLayer(),
      ),
    );
  }
}

class ExploreAppBar extends BackdropAppBar {
  @override
  Widget build(BuildContext context) {
    return BackdropAppBar(
      automaticallyImplyLeading: false,
      actions: const [BackdropToggleButton()],
      title: Text('Explore'),
    );
  }
}

class ExploreBackLayer extends StatelessWidget {
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

class ExploreFrontLayer extends StatefulWidget {
  const ExploreFrontLayer({Key? key, required this.controller})
      : super(key: key);

  final AnimationController controller;

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
    widget.controller.dispose();
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
                      children: [
                        Column(
                          children: [
                            HorizontalMoreList(
                              explore: explore,
                              title: "Consigliati per Te",
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            HorizontalMoreList(
                              explore: explore,
                              title: "Nuovi di Tendenza",
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            HorizontalMoreList(
                              explore: explore,
                              title: "I Più Popolari",
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            HorizontalMoreList(
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
                    title: Text("Titolo"),
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

class HorizontalMoreList extends StatelessWidget {
  HorizontalMoreList(
      {Key? key,
      this.title = 'Title',
      this.explore,
      this.itemHeight = 250,
      this.cardShape = const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)))})
      : super(key: key);

  final bool isLoading = false;
  double itemHeight;
  ShapeBorder cardShape;
  String title;
  ExploreModel? explore;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            TextButton(
              onPressed: () => {},
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
                      File(explore?.reccomendedOutfits?[index].imgPath
                          as String),
                      fit: BoxFit.cover,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Outfit(
                            outfit: explore?.reccomendedOutfits
                                ?.elementAt(index) as OutfitModel)));
                  },
                );
              }
            },
            itemCount: explore!.isLoading
                ? 4
                : (explore?.reccomendedOutfits?.length as int > 4
                    ? 4
                    : explore?.reccomendedOutfits?.length),
          ),
        ),
      ],
    );
  }
}
