import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:backdrop/backdrop.dart';
import '../utils.dart';
import 'package:shimmer/shimmer.dart';
import 'outfit.dart';

WidgetOptions myOutfitsOptions = WidgetOptions(
    BackdropAppBar(
      title: Text("MyOutfits",),
      automaticallyImplyLeading: false,
      actions: <Widget>[
        BackdropToggleButton(
          icon: AnimatedIcons.list_view,
        )
      ],
    ),
    MyOutfitsFrontLayer(),
    Container(),
    BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
    BackdropSubHeader( title: Text("Title") ),
    FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: (){},
    ),
);

class MyOutfitsFrontLayer extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return MyOutfitsFrontLayerState();
  }
}

class MyOutfitsFrontLayerState extends State<MyOutfitsFrontLayer> {
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
          return InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context){ return Outfit(heroIndex: index); } )),
            child: Hero(
              tag: "outfit$index",
              child: Container(
                child: Card( child: Image.network('https://picsum.photos/500?image=35', fit: BoxFit.fitHeight,),),
              ),
            ),
          );
        }
      },
      itemCount: isLoading ? 8 : items.length,
    );
  }
}