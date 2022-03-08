import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:backdrop/backdrop.dart';
import 'screens/profile.dart';
import 'package:image_picker/image_picker.dart';
import 'screens/articolo.dart';

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

List<CardItem> allItems = [CardItem(),CardItem(),CardItem(),CardItem(),CardItem()];

class WidgetOptions{
  PreferredSizeWidget _appBar = AppBar();
  Widget _frontLayer = Container();
  Widget _backLayer = Container();
  BorderRadius _frontLayerBorderRadius = BorderRadius.circular(0);
  Widget _subheader = BackdropSubHeader(title: Text(""),);
  Widget _floatingActionButton = FloatingActionButton(onPressed: (){});

  WidgetOptions(appBar, frontLayer, backLayer, frontLayerBorderRadius, subheader, floatingActionButton){
    _appBar = appBar;
    _frontLayer = frontLayer;
    _backLayer = backLayer;
    _frontLayerBorderRadius = frontLayerBorderRadius;
    _subheader = subheader;
    _floatingActionButton = floatingActionButton;
  }

  PreferredSizeWidget getAppBar(){ return _appBar; }
  Widget getFrontLayer(){ return _frontLayer; }
  Widget getBackLayer(){ return _backLayer; }
  BorderRadius getFrontLayerBorderRadius(){ return _frontLayerBorderRadius; }
  Widget getSubheader(){ return _subheader; }
  Widget getFloatingActionButton(){ return _floatingActionButton; }
}



class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String screenTitle;
  final List<Widget> actionList ;

  MyAppBar({required this.screenTitle, this.actionList = const[] });

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: Text(screenTitle),
        elevation: 0,
        actions: actionList
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}



class MyFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final Icon? icon;

  Widget standard(BuildContext context){
    return NuovoArticolo();
  }

  MyFAB({
    required this.onPressed,
    required this.icon
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context){ return standard(context); } ));
        },
        child: icon,
    );
  }
}