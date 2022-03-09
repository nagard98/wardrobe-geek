import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:backdrop/backdrop.dart';
import '../common/utils.dart';
import 'package:shimmer/shimmer.dart';


class ExploreAppBar extends BackdropAppBar{
  @override
  Widget build(BuildContext context) {
    return BackdropAppBar(
      automaticallyImplyLeading: false,
      actions: const [
        BackdropToggleButton()
      ],
      title: Text('Explore'),
    );
  }

}

class ExploreBackLayer extends StatelessWidget{
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
        )
    );
  }

}

class ExploreFrontLayer extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ExploreFrontLayerState();
  }
}

class ExploreFrontLayerState extends State<ExploreFrontLayer>{
  Widget buildCardShimmer() => Shimmer.fromColors(child: Card(), baseColor: Color(0xFFC4C3C3), highlightColor: Color(0xFFEFEFEF));
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
    
    await Future.delayed(Duration(seconds: 1), (){} );
    items = List.of(allItems);
    if(mounted) setState( () => isLoading = false );
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
              itemBuilder: (context, index){
                  if(isLoading){
                    return buildCardShimmer();
                  }else{
                    return Card();
                  }
              },
              itemCount: isLoading ? 8 : items.length ,
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