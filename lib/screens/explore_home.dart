import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/models/outfit_model.dart';
import 'package:esempio/models/your_account_model.dart';
import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'package:esempio/common/utils.dart';
import 'package:provider/provider.dart';
import 'package:esempio/models/explore_model.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';
import 'package:esempio/screens/explore_users.dart';
import 'package:esempio/screens/explore_outfits.dart';
import 'package:animations/animations.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

class Explore extends StatelessWidget {
  Explore({Key? key, required this.controller}) : super(key: key);

  final int currentIndex = 0;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ExploreModel>.value(
      value: exploreModel,
      child: Container(
        color: const Color(0xFF425C5A),
        child: SafeArea(
          child: DefaultTabController(
            length: 2,
            child: BackdropScaffold(
              frontLayerBackgroundColor: const Color(0xFF425C5A),
              backgroundColor: const Color(0xFF425C5A),
              stickyFrontLayer: true,
              maintainBackLayerState: true,
              appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight + 50),
                  child: ExploreAppBar()),
              frontLayer:
                  Consumer<ExploreModel>(builder: (context, explore, child) {
                return TabBarView(
                  children: [
                    PageTransitionSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (widget, anim1, anim2) {
                        return SharedAxisTransition(
                          transitionType: SharedAxisTransitionType.vertical,
                          fillColor: const Color(0xFF425C5A),
                          animation: anim1,
                          secondaryAnimation: anim2,
                          child: widget,
                        );
                      },
                      child: IndexedStack(
                          key: ValueKey<int>(explore.currentOutfitStackIndex),
                          index: explore.currentOutfitStackIndex,
                          children: [
                            ExploreOutfitFrontLayer(
                              controller: controller,
                              scrollController: explore.homeScrollController,
                            ),
                            FilteredOutfitsFrontLayer(
                                scrollController:
                                    explore.newPageScrollController,
                                subheaderTitle: "Outfit Filtrati")
                          ]),
                    ),
                    PageTransitionSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (widget, anim1, anim2) {
                        return SharedAxisTransition(
                          transitionType: SharedAxisTransitionType.vertical,
                          fillColor: const Color(0xFF425C5A),
                          animation: anim1,
                          secondaryAnimation: anim2,
                          child: widget,
                        );
                      },
                      child: IndexedStack(
                          key: ValueKey<int>(explore.currentUserStackIndex),
                          index: explore.currentUserStackIndex,
                          children: [
                            ExploreUsersFrontLayer(
                              controller: controller,
                              scrollController: explore.homeScrollController,
                            ),
                            FilteredUsersFrontLayer(
                                scrollController:
                                    explore.newPageScrollController,
                                subheaderTitle: "Utenti Filtrati")
                          ]),
                    ),
                  ],
                );
              }),
              backLayer: const ExploreBackLayer(),
            ),
          ),
        ),
      ),
    );
  }
}

class ExploreAppBar extends BackdropAppBar {
  ExploreAppBar({Key? key}) : super(key: key);

  ScrollController _getScrollController(ExploreModel exploreModel){
    if([Section.filteredOutf, Section.recOutf, Section.popOutf, Section.newHotOutf].any((section) => section==exploreModel.currentSection)){
      return exploreModel.currentOutfitStackIndex == 0
          ? exploreModel.homeScrollController
          : exploreModel.newPageScrollController;
    }else{
      return exploreModel.currentUserStackIndex == 0
          ? exploreModel.homeScrollController
          : exploreModel.newPageScrollController;
    }
  }

  IconButton? _getLeadingIcon(ExploreModel exploreModel){
    if([Section.filteredOutf, Section.recOutf, Section.popOutf, Section.newHotOutf].any((section) => section==exploreModel.currentSection)){
      return exploreModel.currentOutfitStackIndex > 0
          ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            exploreModel.showScreen(0, Section.home);
          })
          : null;
    }else{
      return exploreModel.currentUserStackIndex > 0
          ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            exploreModel.showScreen(0, Section.home);
          })
          : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExploreModel>(builder: (context, explore, child) {
      return ScrollAppBar(
        foregroundColor: const Color(0xFFFDCDA2),
        controller: _getScrollController(explore),
        leading: _getLeadingIcon(exploreModel),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: const [
          BackdropToggleButton(
            color: Color(0xFFFDCDA2),
          )
        ],
        title: const Text('Explore'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            decoration: BoxDecoration(
                color: const Color(0xFF425C5A),
                border: Border.all(color: const Color(0xFF425C5A), width: 3)),
            height: 50,
            child: TabBar(
                labelColor:  const Color(0xFFFDCDA2),
                indicator: RectangularIndicator(
                  color: Colors.white60,
                  horizontalPadding: 6,
                  verticalPadding: 3,
                  paintingStyle: PaintingStyle.stroke,
                  bottomLeftRadius: 25,
                  bottomRightRadius: 25,
                  topLeftRadius: 25,
                  topRightRadius: 25,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      children: const [
                        Text("Outfits")
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: const [
                        Text("Utenti")
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  ),
                ]),
          ),
        ),
      );
    });
  }
}


class ExploreBackLayer extends StatelessWidget {
  const ExploreBackLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400),
          child: const TabBarView(
            children: [
              ExploreBackLayerOutfit(),
              ExploreBackLayerUser()
            ],
          ),
        ),
      ],
    );
  }
}

