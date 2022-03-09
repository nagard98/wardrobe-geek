import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import '../utils.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

/*

class Profile extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return ProfileFrontLayer();
  }

}
*/


class ProfileAppBar extends BackdropAppBar{
  @override
  Widget build(BuildContext context) {
    return BackdropAppBar(
      actions: [
        IconButton(onPressed: (){}, icon: Icon(Icons.settings))
      ],
      automaticallyImplyLeading: false,
      title: Text('Profile',),
    );
  }

}

class ProfileBackLayer extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ProfileFrontLayer extends StatelessWidget{
  const ProfileFrontLayer({Key? key}) : super(key: key);

  static Future pickImage() async{
    log("Testing camera");
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(color: Theme.of(context).appBarTheme.backgroundColor),
                  height: 200,
                ),
                Container(
                  decoration: BoxDecoration(color: Colors.pink , borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                  height: 60,
                  margin: EdgeInsets.only(top: 160),
                ),
                Container(
                  margin: EdgeInsets.only(top: 40),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (_) {
                          return FullScreenImage(imageUrl: "https://picsum.photos/500?image=42", tag:"avatar");
                        })
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Hero(
                          tag: "avatar",
                          child: CircleAvatar(radius:80, backgroundImage: Image.network('https://picsum.photos/500?image=42', fit: BoxFit.fitHeight,).image,),
                        ),
                        SleekCircularSlider(
                          initialValue: 80,
                          innerWidget: (value) { return Container(); } ,
                          appearance: CircularSliderAppearance(
                            customWidths: CustomSliderWidths(
                              progressBarWidth: 10
                            ),
                            size: 170,
                          ),
                        )
                      ],
                    )
                  ),
                ),
              ],
            ),
            childCount: 1,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Container(
              decoration: BoxDecoration(
                color: Colors.pink,
                border: Border.all(width: 0, color: Colors.pink)
              ),
              child: Column(
                children: [
                  Divider(height:20 , color: Colors.pink,),
                  Text("Gianni Fantoni"),
                  Text("Italia, Milano"),

                  Divider(height:30 , color: Colors.pink,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          border: Border.all(color: Colors.yellow, width: 0),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))
                        ),
                        child: Text("Followers"),
                      ),
                      VerticalDivider(
                        width: 1,
                      ),
                      Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            border: Border.all(color: Colors.yellow, width: 0),
                            borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10))
                          ),
                          child: Text("Following"),
                      ),
                    ],
                  ),

                  Divider(height:30 , color: Colors.pink,),

                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("I Più Votati"),
                            TextButton(
                                onPressed: ()=>{},
                                child: Row(
                                  children: [
                                    Text("Vedi Tutti"),
                                    Icon(Icons.arrow_forward_ios)
                                  ],
                                ),
                            ),
                          ],
                        ),
                        Container(
                          height: 200,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              Card(
                                clipBehavior: Clip.hardEdge,
                                child: Image.network('https://picsum.photos/500?image=102', width:130, fit: BoxFit.fitHeight,),
                              ),
                              Card(
                                clipBehavior: Clip.hardEdge,
                                child: Image.network('https://picsum.photos/500?image=106', width:130, fit: BoxFit.fitHeight,),
                              ),
                              Card(
                                clipBehavior: Clip.hardEdge,
                                child: Image.network('https://picsum.photos/500?image=96', width:130, fit: BoxFit.fitHeight,),
                              ),
                              Card(
                                clipBehavior: Clip.hardEdge,
                                child: Image.network('https://picsum.photos/500?image=76', width:130, fit: BoxFit.fitHeight,),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  Divider(height:30 , color: Colors.pink,),

                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Utenti Seguiti"),
                            TextButton(
                              onPressed: ()=>{},
                              child: Row(
                                children: [
                                  Text("Vedi Tutti"),
                                  Icon(Icons.arrow_forward_ios)
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 130,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              Card(
                                shape: CircleBorder(),
                                clipBehavior: Clip.hardEdge,
                                child: Image.network('https://picsum.photos/500?image=196', width:130, fit: BoxFit.fitWidth,),
                              ),
                              Card(
                                shape: CircleBorder(),
                                clipBehavior: Clip.hardEdge,
                                child: Image.network('https://picsum.photos/500?image=106', width:130, fit: BoxFit.fitWidth,),
                              ),
                              Card(
                                shape: CircleBorder(),
                                clipBehavior: Clip.hardEdge,
                                child: Image.network('https://picsum.photos/500?image=126', width:130, fit: BoxFit.fitWidth,),
                              ),
                              Card(
                                shape: CircleBorder(),
                                clipBehavior: Clip.hardEdge,
                                child: Image.network('https://picsum.photos/500?image=146', width:130, fit: BoxFit.fitWidth,),
                              ),
                              Card(
                                shape: CircleBorder(),
                                clipBehavior: Clip.hardEdge,
                                child: Image.network('https://picsum.photos/500?image=116', width:130, fit: BoxFit.fitWidth,),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  Divider(height:30 , color: Colors.pink,),
                ],
              )
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
