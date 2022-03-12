import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import '../common/utils.dart';
import 'package:shimmer/shimmer.dart';
import 'outfit.dart';
import 'package:like_button/like_button.dart';
import 'package:morpheus/morpheus.dart';

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
  @override
  State<StatefulWidget> createState() {
    return MyOutfitsFrontLayerState();
  }
}

class MyOutfitsFrontLayerState extends State<MyOutfitsFrontLayer> {
  Widget buildCardShimmer() => Shimmer.fromColors(
      child: Card(),
      baseColor: Color(0xFFC4C3C3),
      highlightColor: Color(0xFFEFEFEF));

  Widget buildCard(CardItem card) => card;
  List<CardItem> items = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async {
    setState(() => isLoading = true);
    await Future.delayed(Duration(seconds: 1), () {});
    items = List.of(allItems);
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
            margin: EdgeInsets.only(top: 52),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 0.6,
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                if (isLoading) {
                  return buildCardShimmer();
                } else {
                  return OutfitCard(index: index);
                }
              },
              itemCount: isLoading ? 8 : items.length,
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

class OutfitCard extends StatelessWidget {
  const OutfitCard({Key? key, required this.index}) : super(key: key);

  final int index;

  void _handleTap(BuildContext context, GlobalKey parentKey) {
    Navigator.of(context).push(MorpheusPageRoute(
      builder: (context) => Outfit(heroIndex: index),
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
                tag: "outfit$index",
                child: Container(
                  child: Image.network(
                    'https://picsum.photos/500?image=35',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text("TESTO"),
                        )),
                    Expanded(
                      flex: 1,
                      child: LikeButton(),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
