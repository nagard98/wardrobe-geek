import 'dart:io' as io;
import 'package:esempio/models/article_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/explore_home.dart';
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
  SystemUiOverlayStyle mySystemTheme= SystemUiOverlayStyle.light.copyWith(systemNavigationBarColor: Colors.white);
  SystemChrome.setSystemUIOverlayStyle(mySystemTheme);
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
          primaryColor: Color(0xFF425C5A),
          appBarTheme: AppBarTheme(backgroundColor: Color(0xFF425C5A)),
          fontFamily: 'Montserrat',
          //accentColor: Color(0xFFFF5963),

          textTheme: const TextTheme(
            headline1: TextStyle(
                fontSize: 48.0,
                fontWeight: FontWeight.bold,
                color: Colors.pink),
            headline6: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w600),
            bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          ).apply(
            bodyColor: Color(0xFF425C5A),
            displayColor: Color(0xFF425C5A),
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
  late int lastNavIndex;

  @override
  void initState(){
    lastNavIndex = 0;
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 350));
    screens = [Wardrobe(controller: controller,), MyOutfits(controller: controller,), Explore(controller: controller,), Profile(controller: controller,)];
    super.initState();
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home),
        title: ("Wardrobe"),
        activeColorPrimary: Color(0xFFFDCDA2),
        inactiveColorPrimary: Color(0xFF425C5A),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.architecture),
        title: ("MyOutfits"),
        activeColorPrimary: Color(0xFFFDCDA2),
        inactiveColorPrimary: Color(0xFF425C5A),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.explore),
        title: ("Explore"),
        activeColorPrimary: Color(0xFFFDCDA2),
        inactiveColorPrimary: Color(0xFF425C5A),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person),
        title: ("Profile"),
        activeColorPrimary: Color(0xFFFDCDA2),
        inactiveColorPrimary: Color(0xFF425C5A),
      ),
    ];
  }

  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      screens: screens,
      items: _navBarsItems(),
      onItemSelected: (index){
        log('Index Navigazione: ${index.toString()}');
        if(lastNavIndex != index){
          controller.reset();
          controller.forward();
        }
        lastNavIndex = index;
        log(clothing.toString());
        //TODO: implementa return to top
      },
      confineInSafeArea: true,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows: true,
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
      navBarStyle: NavBarStyle.style9,
    );
  }
}
