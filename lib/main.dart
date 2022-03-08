import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:backdrop/backdrop.dart';
import 'screens/explore.dart';
import 'screens/profile.dart';
import 'screens/my_outfits.dart';
import 'screens/wardrobe.dart';
import 'screens/wishlist.dart';
import 'utils.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras = [];

//TO-DO: Cambiare versione minima sdk

Future<void> main() async{
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error in fetching the cameras: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.light,
        primaryColor: Colors.orange,
        backgroundColor: Colors.orange,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange
        ),

        fontFamily: 'Montserrat',

        textTheme: const TextTheme(

          headline1: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold, color: Colors.pink),
          headline6: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w700),
          bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      home: BaseRoute(),
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
  Widget _floatingActionButton = _widgetOptions.elementAt(0).getFloatingActionButton();

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
      _floatingActionButton = _widgetOptions.elementAt(index).getFloatingActionButton();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropScaffold(
      backLayerBackgroundColor: Theme.of(context).backgroundColor,
      frontLayerBackgroundColor: Colors.pink,
      frontLayerBorderRadius: _frontLayerBorderRadius,
      subHeader: _subheader,
      appBar: _appBar,
      frontLayer: _frontLayer,
      backLayer: _backLayer,
      floatingActionButton: _floatingActionButton,
      bottomNavigationBar: Builder(
        builder: (BuildContext context){
          return BottomNavigationBar(
            backgroundColor: Colors.orange,
            selectedItemColor: Colors.blue,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              Backdrop.of(context).concealBackLayer();
              _onItemTapped(index);
            },
            currentIndex: _selectedIndex,
            items: <BottomNavigationBarItem>[
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
        },
      )
    );
  }
}