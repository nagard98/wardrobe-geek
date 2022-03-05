import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:backdrop/backdrop.dart';
import 'explore.dart';
import 'profile.dart';
import 'myOutfits.dart';
import 'wardrobe.dart';
import 'wishlist.dart';
import 'utils.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (BuildContext context){
          return BaseRoute();
        },
      ),
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.light,
        primaryColor: Colors.green,

        fontFamily: 'Georgia',

        textTheme: const TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
    );
  }
}

class BaseRoute extends StatefulWidget {
  const BaseRoute({Key? key}) : super(key: key);

  @override
  State<BaseRoute> createState() => _BaseRouteState();
}

class _BaseRouteState extends State<BaseRoute> {
  int _selectedIndex = 0;
  PreferredSizeWidget _appBar = _widgetOptions.elementAt(0).getAppBar();
  Widget _frontLayer = _widgetOptions.elementAt(0).getFrontLayer();
  Widget _backLayer = _widgetOptions.elementAt(0).getBackLayer();
  BorderRadius _frontLayerBorderRadius = _widgetOptions.elementAt(0).getFrontLayerBorderRadius();
  Widget _subheader = _widgetOptions.elementAt(0).getSubheader();

  static List<WidgetOptions> _widgetOptions = <WidgetOptions>[
    wardrobeOptions,
    myOutfitsOptions,
    exploreOptions,
    wishlistOptions,
    profileOptions,
  ];

  void _onItemTapped(int index) {
    setState(() {
      //Backdrop.of(context).concealBackLayer();
      _selectedIndex = index;
      _frontLayer = _widgetOptions.elementAt(index).getFrontLayer();
      _appBar = _widgetOptions.elementAt(index).getAppBar();
      _subheader = _widgetOptions.elementAt(index).getSubheader();
      _backLayer = _widgetOptions.elementAt(index).getBackLayer();
      _frontLayerBorderRadius = _widgetOptions.elementAt(index).getFrontLayerBorderRadius();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropScaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      frontLayerBackgroundColor: Theme.of(context).colorScheme.primary,
      frontLayerBorderRadius: _frontLayerBorderRadius,
      subHeader: _subheader,
      appBar: _appBar,
      frontLayer: _frontLayer,
      backLayer: _backLayer,
      bottomNavigationBar: Builder(builder: (BuildContext context){
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: Colors.black,
          selectedItemColor: Colors.blueAccent,
          onTap: (index) {
            Backdrop.of(context).concealBackLayer();
            _onItemTapped(index);
          },
          currentIndex: _selectedIndex,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.architecture),
              label: "Outfits",
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
      })
    );
  }
}