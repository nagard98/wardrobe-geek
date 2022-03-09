import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import '../common/utils.dart';
import 'package:shimmer/shimmer.dart';
import 'outfit.dart';

class MyOutfitsAppBar extends BackdropAppBar {
  @override
  Widget build(BuildContext context) {
    return BackdropAppBar(
      automaticallyImplyLeading: false,
      actions: const [
        BackdropToggleButton()
      ],
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
                childAspectRatio: 0.7,
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                if (isLoading) {
                  return buildCardShimmer();
                } else {
                  return InkWell(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Outfit(heroIndex: index);
                    })),
                    child: Hero(
                      tag: "outfit$index",
                      child: Container(
                        child: Card(
                          child: Image.network(
                            'https://picsum.photos/500?image=35',
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
              itemCount: isLoading ? 8 : items.length,
            ),
          ),
          Container(
            child: const BackdropSubHeader(
              title: Text("Titolo"),
            ),
          ),
        ],
      ),
    );
  }
}
