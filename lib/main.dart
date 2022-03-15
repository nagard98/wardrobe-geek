import 'dart:io' as io;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'screens/explore.dart';
import 'screens/profile.dart';
import 'screens/my_outfits.dart';
import 'screens/wardrobe.dart';
import 'screens/wishlist.dart';
import 'common/utils.dart' as utils;
import 'dart:developer';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

//TO-DO: Cambiare versione minima sdk

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  io.Directory docsDir = await getApplicationDocumentsDirectory();
  utils.docsDir = docsDir;
  await io.Directory(join(docsDir.path, 'articles')).create();
  await io.Directory(join(docsDir.path, 'outfits')).create();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BaseModel>(
            create: (BuildContext context) => BaseModel()),
        ChangeNotifierProvider<BackdropModel>(
            create: (BuildContext context) => BackdropModel())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.lightBlueAccent,
          appBarTheme: AppBarTheme(backgroundColor: Colors.lightBlueAccent),

          fontFamily: 'Montserrat',

          textTheme: const TextTheme(
            headline1: TextStyle(
                fontSize: 48.0,
                fontWeight: FontWeight.bold,
                color: Colors.pink),
            headline6: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w700),
            bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          ),
        ),
        home: BaseRoute(),
      ),
    );
  }
}

class BaseModel extends ChangeNotifier {
  int selIndex = 0;

  void increaseIndex() {
    selIndex++;
    notifyListeners();
  }

  void setIndex(int selIndex) {
    this.selIndex = selIndex;
    notifyListeners();
  }
}

class BackdropModel extends ChangeNotifier {
  void toggleBackLayer() {
    notifyListeners();
  }
}

class BaseRoute extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return BaseRouteState();
  }

}

class BaseRouteState extends State<BaseRoute> with TickerProviderStateMixin{

  late AnimationController controller;
  late List<Widget> screens;

  @override
  void initState(){
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 350));
    screens = [Wardrobe(controller: controller,), MyOutfits(controller: controller,), Explore(controller: controller,), Profile(controller: controller,)];
    super.initState();
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home),
        title: ("Wardrobe"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.architecture),
        title: ("MyOutfits"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.explore),
        title: ("Explore"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person),
        title: ("Profile"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }

  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      screens: screens,
      items: _navBarsItems(),
      onItemSelected: (index){
        log(index.toString());
        controller.reset();
        controller.forward();
      },
      confineInSafeArea: true,
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: false,
      stateManagement: false,
      hideNavigationBarWhenKeyboardShows: false,
      decoration: NavBarDecoration( colorBehindNavBar: Colors.white, ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: const ItemAnimationProperties(
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation(
        animateTabTransition: false,
      ),
      navBarStyle: NavBarStyle.style3,
    );
  }
}
