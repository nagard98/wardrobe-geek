import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'screens/explore.dart';
import 'screens/profile.dart';
import 'screens/my_outfits.dart';
import 'screens/wardrobe.dart';
import 'screens/wishlist.dart';
import 'common/utils.dart' as utils;
import 'dart:developer';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:auto_animated/auto_animated.dart';

//TO-DO: Cambiare versione minima sdk

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  io.Directory docsDir = await getApplicationDocumentsDirectory();
  utils.docsDir = docsDir;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BaseModel>(create: (BuildContext context) => BaseModel()),
        ChangeNotifierProvider<BackdropModel>(create: (BuildContext context) => BackdropModel())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Define the default brightness and colors.
          brightness: Brightness.light,
          primaryColor: Colors.pinkAccent,
          appBarTheme: AppBarTheme(backgroundColor: Colors.pinkAccent),

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
  int selIndex = 1;

  void increaseIndex() {
    this.selIndex++;
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


class BaseRoute extends StatefulWidget {
  const BaseRoute({Key? key}) : super(key: key);

  @override
  State<BaseRoute> createState() => _BaseRouteState();
}

class _BaseRouteState extends State<BaseRoute>{
  late AnimationController animationController;
  final frontLayers = [
    WardrobeFrontLayer(),
    MyOutfitsFrontLayer(),
    ExploreFrontLayer(),
    WishlistFrontLayer(),
    ProfileFrontLayer()
  ];
  final backLayers = [
    WardrobeBackLayer(),
    MyOutfitsBackLayer(),
    ExploreBackLayer(),
    WishlistBackLayer(),
    ProfileBackLayer()
  ];
  final appBars = <BackdropAppBar>[
    WardrobeAppBar(),
    MyOutfitsAppBar(),
    ExploreAppBar(),
    WishlistAppBar(),
    ProfileAppBar()
  ];

  final subHeaders = [
    Container(child: BackdropSubHeader(title: Text("Title"))),
    Container(child: BackdropSubHeader(title: Text("Tit"))),
    Container(child: BackdropSubHeader(title: Text("Ttle"))),
    Container(child: BackdropSubHeader(title: Text("Tite"))),
    Container(child: BackdropSubHeader(title: Text("Titl"))),
  ];

  final titles = ['Wardrobe', 'MyOutfits', 'Esplora', 'WishList', 'Profilo'];

  @override
  Widget build(BuildContext context) {
    return BackdropScaffold(
      frontLayerBackgroundColor: Colors.pink,
      stickyFrontLayer: true,
      appBar: PreferredSize(
        child: Consumer<BaseModel>(
            builder: (context, baseModel, child) {
              log("Inside App Bar");
              return appBars[baseModel.selIndex];
            }
        ),
        preferredSize: Size.fromHeight(kToolbarHeight),
      ),
      frontLayer: Consumer<BaseModel>(
          builder: (context, baseModel, child) {
            log("Inside front");
            return PageTransitionSwitcher(
                child: frontLayers[baseModel.selIndex],
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,) {
                  return FadeThroughTransition(
                    fillColor: Colors.pinkAccent,
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    child: child,
                  );
                }
            );
          }
      ),
      backLayer: Consumer<BaseModel>(
          builder: (context, baseModel, child) {
            log("Inside back");
            return backLayers[baseModel.selIndex];
          }
      ),
      bottomNavigationBar: Builder(builder: (BuildContext context) {
        return Consumer<BaseModel>(
          builder: (context, baseModel, child){
            log("Inside Bottom Nav");
            return BottomNavigationBar(
              backgroundColor: Colors.pinkAccent,
              selectedItemColor: Colors.blue,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                Provider.of<BaseModel>(context,listen: false).setIndex(index);
              },
              currentIndex: Provider.of<BaseModel>(context,listen: false).selIndex,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Wardrobe",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.architecture),
                  label: "MyOutfits",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore),
                  label: "Explore",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: "Wishlist",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Profile",
                ),
              ],
            );
          }
        );
      }),
    );
  }
}
