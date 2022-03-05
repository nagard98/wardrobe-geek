import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:backdrop/backdrop.dart';
import 'utils.dart';

WidgetOptions profileOptions = WidgetOptions(
    AppBar(title: Text("Profile"), elevation: 0, foregroundColor: Colors.primaries.first,),
    ProfileFrontLayer(),
    Container(),
    BorderRadius.zero,
    Container()
);

class ProfileFrontLayer extends StatelessWidget{
  const ProfileFrontLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: false,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  color: Colors.primaries.first,
                  height: 130,
                ),
                CircleAvatar(radius:100, backgroundImage: Image.network('https://picsum.photos/500?image=42', fit: BoxFit.fitHeight,).image,),
              ],
            ),
            childCount: 1,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => ListTile(tileColor: Colors.yellow,),
            childCount: 5
          ),
        )
      ],
    );
  }
}