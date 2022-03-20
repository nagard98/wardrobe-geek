import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/models/myoutfits_model.dart';
import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import '../common/utils.dart';
import 'package:esempio/models/profile_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:esempio/models/explore_model.dart';


class FilteredOutfitsFrontLayer extends StatefulWidget {
  const FilteredOutfitsFrontLayer({Key? key, required this.scrollController, required this.subheaderTitle}) : super(key: key);

  
  final ScrollController scrollController;
  final String subheaderTitle;

  @override
  State<StatefulWidget> createState() {
    return FilteredOutfitsFrontLayerState();
  }
}

class FilteredOutfitsFrontLayerState extends State<FilteredOutfitsFrontLayer>{

  @override
  void initState() {
    super.initState();
    //myOutfitsModel.loadOutfits(OutfitDBWorker.outfitDBWorker, profile);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Consumer<ExploreModel>(builder: (context, explore, child) {
        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 52,left: 6.0, right: 6.0),
              child: AnimationLimiter(
                child: GridView.builder(
                  //controller: widget.scrollController,
                  padding: EdgeInsets.only(bottom: 30),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 0.6,
                    crossAxisCount: 2,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    if (explore.isLoading) {
                      return buildCardShimmer();
                    } else {
                      return OutfitCard(index: index, outfitsInterface: explore, section: Section.recOutf,);
                    }
                  },
                  itemCount:
                  explore.isLoading ? 8 : explore.getListOutfits(Section.recOutf).length,
                ),
              ),
            ),
            BackdropSubHeader(
              title: Text(widget.subheaderTitle),
            ),
          ],
        );
      }),
    );
  }
}
