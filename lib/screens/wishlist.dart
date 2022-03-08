import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:backdrop/backdrop.dart';
import '../utils.dart';
import 'package:shimmer/shimmer.dart';

WidgetOptions wishlistOptions = WidgetOptions(
    BackdropAppBar(title: Text("Wishlist"), automaticallyImplyLeading: false,),
    WishlistFrontLayer(),
    Container(),
    BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
    BackdropSubHeader( title: Text("Title") ),
    SizedBox.shrink()
);

class WishlistFrontLayer extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return WishlistFrontLayerState();
  }
}

class WishlistFrontLayerState extends State<WishlistFrontLayer> {
  Widget buildCardShimmer() => Shimmer.fromColors(child: Card(), baseColor: Color(0xFFC4C3C3), highlightColor: Color(0xFFEFEFEF));

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

    await Future.delayed(Duration(seconds: 2), () {});
    items = List.of(allItems);
    if(mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
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
          return Card();
        }
      },
      itemCount: isLoading ? 8 : items.length,
    );
  }
}