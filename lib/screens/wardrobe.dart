import 'dart:developer';
import 'package:esempio/models/article_model.dart';
import 'package:esempio/models/profile_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import '../common/utils.dart';
import 'package:shimmer/shimmer.dart';
import 'article.dart';
import 'package:esempio/models/wardrobe_model.dart';
import 'package:esempio/db/db_worker.dart';
import 'dart:io';
import 'package:morpheus/morpheus.dart';
import 'package:like_button/like_button.dart';

class WardrobeAppBar extends BackdropAppBar {
  WardrobeAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropAppBar(
      automaticallyImplyLeading: false,
      actions: const [BackdropToggleButton()],
      title: Text('Wardrobe'),
    );
  }
}

class User {
  final String? name;
  final String? avatar;

  User({this.name, this.avatar});
}

class WardrobeBackLayer extends StatefulWidget {
  WardrobeBackLayer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WardrobeBackLayerState();
  }
}

class ActorFilterEntry {
  const ActorFilterEntry(this.name, this.initials);

  final String name;
  final String initials;
}

class WardrobeBackLayerState extends State<WardrobeBackLayer> {
  final List<ActorFilterEntry> _cast = <ActorFilterEntry>[
    const ActorFilterEntry('Aaron Burr', 'AB'),
    const ActorFilterEntry('Alexander Hamilton', 'AH'),
    const ActorFilterEntry('Eliza Hamilton', 'EH'),
    const ActorFilterEntry('James Madison', 'JM'),
  ];
  final List<String> _filters = <String>[];

  Iterable<Widget> get actorWidgets {
    return _cast.map((ActorFilterEntry actor) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: FilterChip(
          avatar: CircleAvatar(child: Text(actor.initials)),
          label: Text(actor.name),
          selected: _filters.contains(actor.name),
          onSelected: (bool value) {
            setState(() {
              if (value) {
                _filters.add(actor.name);
              } else {
                _filters.removeWhere((String name) {
                  return name == actor.name;
                });
              }
            });
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: [
        Container(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: actorWidgets.toList(),
          ),
        ),
        Container(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: actorWidgets.toList(),
          ),
        ),
        Container(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: actorWidgets.toList(),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            /*Expanded(
              child: FloatingActionButton.extended(
                  label: Text("Apply"), onPressed: () {}),
            ),
            FloatingActionButton.extended(label: Text("Reset"), onPressed: () {})*/
          ],
        )
      ],
    );
  }
}

class WardrobeFrontLayer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WardrobeFrontLayerState();
  }
}

class WardrobeFrontLayerState extends State<WardrobeFrontLayer> {
  WardrobeFrontLayerState() {
    wardrobeModel.loadArticles(ArticleDBWorker.articleDBWorker, profile);
  }

  Widget buildCardShimmer() => Shimmer.fromColors(
      child: Card(),
      baseColor: Color(0xFFC4C3C3),
      highlightColor: Color(0xFFEFEFEF));

  Widget buildCard(CardItem card) => card;

  List<CardItem> items = [];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: wardrobeModel,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Consumer<WardrobeModel>(builder: (context, wardrobe, child) {
          log(wardrobe.articles.toString());
          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 52),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 1.3,
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    if (wardrobe.isLoading) {
                      return buildCardShimmer();
                    } else {
                      return ArticleCard(
                        index: index,
                        wardrobe: wardrobe,
                      );
                    }
                  },
                  itemCount: wardrobe.isLoading ? 8 : wardrobe.articles?.length,
                ),
              ),
              Container(
                color: Colors.white,
                child: BackdropSubHeader(
                  title: Text("Titolo"),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () {
                      wardrobe.currentArticle = ArticleModel();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return NuovoArticolo();
                      }));
                    }),
              )
            ],
          );
        }),
      ),
    );
  }
}

class ArticleCard extends StatelessWidget {
  ArticleCard({required this.wardrobe, required this.index});

  WardrobeModel wardrobe;
  int index;

  void _handleTap(BuildContext context, GlobalKey parentKey) {
    Navigator.of(context).push(MorpheusPageRoute(
      builder: (context) => Articolo(article: wardrobe.articles!.elementAt(index)),
      parentKey: parentKey,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final _parentKey = GlobalKey();
    return InkWell(
      key: _parentKey,
      onTap: () => _handleTap(context, _parentKey),
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Hero(
                tag: "articolo${wardrobe.articles!.elementAt(index).id}",
                child: Image.file(
                  File(wardrobe.articles!.elementAt(index).imgPath!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  LikeButton(),
                  IconButton(onPressed: (){}, icon: Icon(Icons.more_vert))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
