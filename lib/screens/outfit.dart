import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:backdrop/backdrop.dart';
import '../utils.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_colorpicker/src/material_picker.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';



class Outfit extends StatelessWidget{
  final int heroIndex;

  const Outfit({Key? key, this.heroIndex=0}) : super(key: key);

  static Future pickImage() async{
    log("Testing camera");
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nome Outfit"),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => Stack(
                    alignment: Alignment.topLeft,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Theme.of(context).appBarTheme.backgroundColor),
                        height: 300,
                      ),
                      Container(
                        decoration: BoxDecoration(color: Colors.pink, border: Border.all(width: 0, color: Colors.pink), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                        height: 130,
                        margin: EdgeInsets.only(top: 270),
                      ),
                      Row(
                        children: [
                          Flexible(
                            flex: 7,
                            child: Container(
                              margin: EdgeInsets.only(top: 40, left: 0),
                              child: InkWell(
                                child: Hero(
                                  tag: "outfit$heroIndex",
                                  child: Container(
                                    height: 285,
                                    child: Card(
                                      clipBehavior: Clip.hardEdge,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(topLeft: Radius.zero, topRight: Radius.circular(20), bottomLeft: Radius.zero, bottomRight: Radius.circular(20))
                                      ),
                                      margin: EdgeInsets.zero,
                                      child: Image.network('https://picsum.photos/500/750?image=35',
                                        fit: BoxFit.fitHeight,),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                        return FullScreenImage(imageUrl: "https://picsum.photos/500/750?image=35", tag:"outfit$heroIndex");
                                      })
                                  );
                                },
                              ),
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 8,
                            child: Column(
                              children: [
                                Text("TITOLO"),
                                Text("Brand"),
                                Text("Colore"),
                                Text("Stagione"),
                                Text("Designer")
                              ],
                            )
                          )
                        ],
                      )
                    ],
                  ),
              childCount: 1,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                    (context, index) => Container(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  decoration: BoxDecoration(
                      color: Colors.pink,
                      border: Border.all(width: 0, color: Colors.pink)
                  ),
                  child: Column(
                    children: [
                      Material(
                        color: Colors.blue,
                        child: ListTile(
                          tileColor: Colors.blue,
                          leading: Icon(Icons.ten_k),
                        ),
                      ),
                    ],
                  ),
                ),
                childCount: 1
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Expanded(child: Container(decoration: BoxDecoration(color: Colors.pink, border: Border.all(width: 0, color: Colors.pink, style: BorderStyle.none))))
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class FullScreenImage extends StatelessWidget{
  const FullScreenImage({
    Key? key,
    required this.imageUrl,
    required this.tag,
  }) : super(key: key);

  final String imageUrl;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.blueGrey,
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                  child: Hero(
                    tag: tag,
                    child: Image.network(imageUrl),
                  )
              ),
              Material(
                child: InkWell(
                  child: Icon(Icons.close, size: 48,),
                  onTap: ()=>{Navigator.pop(context)},
                ),
                color: Colors.transparent,
              ),
            ],
          ),
        )
    );
  }

}
