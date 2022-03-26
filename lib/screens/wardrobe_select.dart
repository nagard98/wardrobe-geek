import 'dart:developer';
import 'package:esempio/models/article_model.dart';
import 'package:esempio/models/profile_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import '../common/utils.dart';
import 'article.dart';
import 'package:esempio/models/wardrobe_model.dart';
import 'package:esempio/db/article_db_worker.dart';
import 'dart:io';
import 'package:morpheus/morpheus.dart';
import 'package:like_button/like_button.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as mbs;
import 'package:scroll_app_bar/scroll_app_bar.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:esempio/models/your_account_model.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:esempio/screens/wardrobe.dart';

class WardrobeSelect extends StatelessWidget {
  WardrobeSelect({Key? key, this.isSelectionMode=false}) : super(key: key);

  final scrollController = ScrollController();
  final bool isSelectionMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF425C5A),
      child: SafeArea(
        child: BackdropScaffold(
          maintainBackLayerState: true,
          frontLayerBackgroundColor: const Color(0xFF486563),
          stickyFrontLayer: true,
          appBar: WardrobeAppBarSelect(scrollController),
          frontLayer: WardrobeFrontLayerSelect( scrollController: scrollController, isSelectionMode: isSelectionMode),
          backLayer: const WardrobeBackLayer(),
        ),
      ),
    );
  }
}

class WardrobeAppBarSelect extends BackdropAppBar {
  WardrobeAppBarSelect(this.scrollController, {Key? key}) : super(key: key);

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ScrollAppBar(
      foregroundColor: const Color(0xFFFDCDA2),
      controller: scrollController,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: const [
        BackdropToggleButton(
          color: Color(0xFFFDCDA2),
        ),
      ],
      title: const Text('Seleziona articolo'),
    );
  }
}

class WardrobeFrontLayerSelect extends StatefulWidget {
  const WardrobeFrontLayerSelect(
      {Key? key,
        required this.scrollController,
        this.isSelectionMode = false})
      : super(key: key);

  final ScrollController scrollController;
  final bool isSelectionMode;

  @override
  State<StatefulWidget> createState() {
    return WardrobeFrontLayerSelectState();
  }
}

class WardrobeFrontLayerSelectState extends State<WardrobeFrontLayerSelect> {
  int optionSelected = 0;

  void checkOption(int articleId) {
    setState(() {
      optionSelected = articleId;
    });
  }

  @override
  void initState() {
    super.initState();
    wardrobeModel.loadArticles(
        ArticleDBWorker.articleDBWorker, personalProfile.myProfile);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFBFBFB),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Consumer<WardrobeModel>(builder: (context, wardrobe, child) {
        log(wardrobe.articles.toString());
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 52,
                left: 6,
                right: 6,
              ),
              child: GridView.builder(
                controller: widget.scrollController,
                padding: EdgeInsets.only(bottom: kToolbarHeight + 10),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 1.5,
                  crossAxisCount: 2,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemBuilder: (context, index) {
                  if (wardrobe.isLoading) {
                    return buildCardShimmer();
                  } else {
                    return ArticleSelectCard(
                      index: index,
                      wardrobe: wardrobe,
                      onTap: () =>
                          checkOption(wardrobe.articles?[index].id as int),
                      isSelected: optionSelected ==
                          (wardrobe.articles?[index].id as int),
                    );
                  }
                },
                itemCount:
                wardrobe.isLoading ? 8 : wardrobe.articles?.length,
              ),
            ),
            BackdropSubHeader(
              title:const Text("I Miei Articoli"),
              trailing: IconButton(onPressed: (){Navigator.of(context).pop([optionSelected]);}, icon: const Icon(Icons.check)),
            ),
          ],
        );
      }),
    );
  }
}

class ArticleSelectCard extends StatelessWidget {
  const ArticleSelectCard(
      {Key? key,
        required this.wardrobe,
        required this.index,
        required this.onTap,
        required this.isSelected})
      : super(key: key);

  final WardrobeModel wardrobe;
  final int index;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.red : Colors.transparent,
              width: isSelected ? 5 : 0,
            ),
          ),
        ),
        child: Card(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Hero(
            tag: "articolo${wardrobe.articles![index].id}",
            child: Image.file(
              File(wardrobe.articles!.elementAt(index).imgPath!),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
