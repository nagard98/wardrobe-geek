import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:backdrop/backdrop.dart';
import 'screens/profile.dart';
import 'package:image_picker/image_picker.dart';
import 'screens/articolo.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'dart:developer';

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


class MyAppBar extends StatelessWidget implements PreferredSizeWidget{
  final AnimationController animationController;
  final String screenTitle;
  final List<Widget> actionList ;
  const MyAppBar({required this.screenTitle, required this.actionList, required this.animationController});


/*  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }*/

  void repeatOnce() async {
    await animationController.forward();
    await animationController.reverse();
  }

/*
  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
*/

  @override
  Widget build(BuildContext context) {
    return Consumer<BaseModel>(
      builder: (context,base,child) {
        log("Inside App Bar");
        return AppBar(
            title: Text('asd${base.selIndex}'),
            elevation: 0,
            actions: [IconButton(onPressed: () {

            }, icon: Icon(Icons.settings))]
        );
      }
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