import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

late Directory docsDir;

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

Widget buildCardShimmer() => Shimmer.fromColors(
    child: const Card(),
    baseColor: const Color(0xFFE3E1E1),
    highlightColor: const Color(0xFFEFEFEF));

class CardItem extends StatelessWidget{
  const CardItem({Key? key}) : super(key: key);

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

class FullScreenImage extends StatelessWidget {
  FullScreenImage({
    Key? key,
    required this.image,
    required this.tag,
  }) : super(key: key);

  final File image;
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
                    child: Image.file(image),
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