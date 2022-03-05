import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:backdrop/backdrop.dart';
import 'utils.dart';
import 'package:shimmer/shimmer.dart';

WidgetOptions exploreOptions = WidgetOptions(
  BackdropAppBar(title: Text("Explore"), automaticallyImplyLeading: false,),
  ExploreFrontLayer(),
  Container(),
  BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
  BackdropSubHeader( title: Text("Title") )
);

class ExploreFrontLayer extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ExploreFrontLayerState();
  }
}

class ExploreFrontLayerState extends State<ExploreFrontLayer>{
  Widget buildCardShimmer() => Shimmer.fromColors(child: Card(), baseColor: Colors.blueAccent, highlightColor: Colors.cyanAccent);
  Widget buildCard(CardItem card) => card;
  List<CardItem> items = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async{
    setState( () => isLoading = true );
    
    await Future.delayed(Duration(seconds: 2), (){} );
    items = List.of(allItems);
    setState( () => isLoading = false );
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
      itemBuilder: (context, index){
          if(isLoading){
            return buildCardShimmer();
          }else{
            return Card();
          }
      },
      itemCount: isLoading ? 8 : items.length ,
    );

    /*[
        Image.network('https://picsum.photos/250?image=1', fit: BoxFit.fitHeight,),
        Image.network('https://picsum.photos/250?image=2', fit: BoxFit.fitHeight,),
        Image.network('https://picsum.photos/250?image=3', fit: BoxFit.fitHeight,),
        Image.network('https://picsum.photos/250?image=4', fit: BoxFit.fitHeight,),
        Image.network('https://picsum.photos/250?image=1', fit: BoxFit.fitHeight,),
        Image.network('https://picsum.photos/250?image=2', fit: BoxFit.fitHeight,),
        Image.network('https://picsum.photos/250?image=3', fit: BoxFit.fitHeight,),
        Image.network('https://picsum.photos/250?image=4', fit: BoxFit.fitHeight,),
        Image.network('https://picsum.photos/250?image=1', fit: BoxFit.fitHeight,),
        Image.network('https://picsum.photos/250?image=2', fit: BoxFit.fitHeight,),
        Image.network('https://picsum.photos/250?image=3', fit: BoxFit.fitHeight,),
        Image.network('https://picsum.photos/250?image=4', fit: BoxFit.fitHeight,),
      ],*/
  }
}