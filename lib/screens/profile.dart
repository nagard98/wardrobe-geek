import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:esempio/screens/settings.dart';
import 'package:esempio/screens/explore.dart';

class ProfileAppBar extends BackdropAppBar {
  ProfileAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropAppBar(
      actions: [
        IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Settings()));
            },
            icon: Icon(Icons.settings))
      ],
      automaticallyImplyLeading: false,
      title: Text(
        'Profile',
      ),
    );
  }
}

class ProfileBackLayer extends StatelessWidget {
  const ProfileBackLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ProfileFrontLayer extends StatelessWidget {
  const ProfileFrontLayer({Key? key}) : super(key: key);

  static Future pickImage() async {
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
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  height: 60,
                  margin: EdgeInsets.only(top: 164),
                ),
                const ProfilePicture(),
              ],
            ),
            childCount: 1,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
              (context, index) => Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(style: BorderStyle.none, width: 0)),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Text("Gianni Fantoni"),
                        Text("Italia, Milano"),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  border: Border.all(
                                      color: Colors.yellow, width: 0),
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10))),
                              child: Text("Followers"),
                            ),
                            const VerticalDivider(
                              width: 1,
                            ),
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  border: Border.all(
                                      color: Colors.yellow, width: 0),
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10))),
                              child: Text("Following"),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        HorizontalMoreList(
                          itemHeight: 200,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        HorizontalMoreList(
                          itemHeight: 150,
                          cardShape: CircleBorder(),
                        ),
                        const Divider(
                          height: 30,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
              childCount: 1),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            children: [
              Expanded(
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              width: 0,
                              color: Colors.white,
                              style: BorderStyle.none))))
            ],
          ),
        ),
      ],
    );
  }
}

class FullScreenImage extends StatelessWidget {
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
              )),
              Material(
                child: InkWell(
                  child: Icon(
                    Icons.close,
                    size: 48,
                  ),
                  onTap: () => {Navigator.pop(context)},
                ),
                color: Colors.transparent,
              ),
            ],
          ),
        ));
  }
}

class ProfilePicture extends StatelessWidget{
  const ProfilePicture({Key? key, this.topMargin = 40}) : super(key: key);

  final double topMargin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return const FullScreenImage(
                  imageUrl: "https://picsum.photos/500?image=42",
                  tag: "avatar");
            }));
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Hero(
                tag: "avatar",
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: Image.network(
                    'https://picsum.photos/500?image=42',
                    fit: BoxFit.fitHeight,
                  ).image,
                ),
              ),
              SleekCircularSlider(
                initialValue: 80,
                innerWidget: (value) {
                  return Container();
                },
                appearance: CircularSliderAppearance(
                  customWidths:
                  CustomSliderWidths(progressBarWidth: 10),
                  size: 170,
                ),
              )
            ],
          )),
    );
  }

}