import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import '../common/utils.dart';


class WishlistAppBar extends BackdropAppBar{
  WishlistAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropAppBar(
      automaticallyImplyLeading: false,
      actions: const [
        BackdropToggleButton()
      ],
      title: const Text('Wishlist'),
    );
  }
}

class WishlistBackLayer extends StatelessWidget{
  const WishlistBackLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
        )
    );
  }
}

class WishlistFrontLayer extends StatefulWidget{
  const WishlistFrontLayer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WishlistFrontLayerState();
  }
}

class WishlistFrontLayerState extends State<WishlistFrontLayer> {
/*  Widget buildCard(CardItem card) => card;*/
  List items = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 52),
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
                  return const Card();
                }
              },
              itemCount: isLoading ? 8 : items.length,
            ),
          ),
          const SizedBox(
            child: BackdropSubHeader(
              title: Text("Titolo"),
            ),
          ),
        ],
      ),
    );
  }
}