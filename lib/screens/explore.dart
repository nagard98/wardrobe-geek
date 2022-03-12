import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:backdrop/backdrop.dart';
import '../common/utils.dart' as utils;
import 'package:shimmer/shimmer.dart';
import 'package:path/path.dart';

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
  @override
  State<StatefulWidget> createState() {
    return ExploreFrontLayerState();
  }
}

class ExploreFrontLayerState extends State<ExploreFrontLayer> {
  Widget buildCardShimmer() => Shimmer.fromColors(
      child: Card(),
      baseColor: Color(0xFFC4C3C3),
      highlightColor: Color(0xFFEFEFEF));

  Widget buildCard(utils.CardItem card) => card;
  List<utils.CardItem> items = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async {
    setState(() => isLoading = true);

    await Future.delayed(Duration(seconds: 1), () {});
    items = List.of(utils.allItems);
    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 52),
            child: ListView(
              children: [
                Column(
                  children: [
                    HorizontalMoreList(
                      title: "Consigliati per Te",
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    HorizontalMoreList(
                      title: "Nuovi di Tendenza",
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    HorizontalMoreList(
                      title: "I Più Popolari",
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    HorizontalMoreList(
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
      ),
    );
  }
}

class HorizontalMoreList extends StatelessWidget {
  HorizontalMoreList(
      {Key? key,
      this.title = 'Title',
      this.itemHeight = 250,
      this.cardShape = const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)))})
      : super(key: key);

  Widget buildCardShimmer() => Shimmer.fromColors(
      child: Card(),
      baseColor: Color(0xFFC4C3C3),
      highlightColor: Color(0xFFEFEFEF));

  final bool isLoading = false;
  double itemHeight;
  ShapeBorder cardShape;
  String title;

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
              if (isLoading) {
                return buildCardShimmer();
              } else {
                return Card(
                  shape: cardShape,
                  clipBehavior: Clip.hardEdge,
                  child: Image.file(
                    File(join(utils.docsDir.path, '2.jpg')),
                    fit: BoxFit.cover,
                  ),
                );
              }
            },
            itemCount: 5,
          ),
        ),
      ],
    );
  }
}
