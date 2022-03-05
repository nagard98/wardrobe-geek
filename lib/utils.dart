import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:backdrop/backdrop.dart';

class CardExtended extends StatelessWidget{
  const CardExtended({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Hero(
          tag: "photo",
          child: Image.network('https://picsum.photos/500?image=1', fit: BoxFit.fitWidth,),
        ),
      ),
    );
  }
}

class CardItem extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.purple,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          /*Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CardExtended()),
        );*/
          debugPrint('Card tapped.');
        },
        child: Column(
          children: [
            Expanded(
              child: Hero(
                tag: "photo",
                child: Image.network('https://picsum.photos/500?image=1', fit: BoxFit.fitHeight,),
              ),
              flex: 8,
            ),
            Expanded(
              child: Text("Nome prodotto"),
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }

}

List<CardItem> allItems = [CardItem()];

class WidgetOptions{
  PreferredSizeWidget _appBar = AppBar();
  Widget _frontLayer = Container();
  Widget _backLayer = Container();
  BorderRadius _frontLayerBorderRadius = BorderRadius.circular(0);
  Widget _subheader = BackdropSubHeader(title: Text(""),);

  WidgetOptions(appBar, frontLayer, backLayer, frontLayerBorderRadius, subheader){
    _appBar = appBar;
    _frontLayer = frontLayer;
    _backLayer = backLayer;
    _frontLayerBorderRadius = frontLayerBorderRadius;
    _subheader = subheader;
  }

  PreferredSizeWidget getAppBar(){ return _appBar; }
  Widget getFrontLayer(){ return _frontLayer; }
  Widget getBackLayer(){ return _backLayer; }
  BorderRadius getFrontLayerBorderRadius(){ return _frontLayerBorderRadius; }
  Widget getSubheader(){ return _subheader; }
}

