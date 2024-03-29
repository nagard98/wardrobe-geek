import 'dart:developer';
import 'dart:io';
import 'package:esempio/models/wishlist_model.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:colornames/colornames.dart';
import 'package:esempio/models/outfits_interface.dart';
import 'package:morpheus/morpheus.dart';
import 'package:esempio/screens/outfit.dart';
import 'package:like_button/like_button.dart';
import 'package:esempio/models/explore_model.dart';
import 'package:esempio/models/profile_model.dart';
import 'package:esempio/db/outfit_db_worker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as mbs;
import 'package:esempio/models/outfit_model.dart';
import 'package:form_field_validator/form_field_validator.dart' as validator;
import 'package:esempio/models/your_account_model.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:esempio/screens/profile.dart';

var uuid = const Uuid();

final passwordValidator = validator.MultiValidator([
  validator.RequiredValidator(errorText: 'La password è obbligatoria'),
  validator.MinLengthValidator(8,
      errorText: 'La password deve avere almeno 8 caratteri'),
  validator.PatternValidator(r'(?=.*?[#?!@$%^&*-])',
      errorText: 'La password deve avere almeno un carattere speciale')
]);

late Directory docsDir;

enum Filter {
  clothingType,
  brand,
  primColor,
  secColor,
  fav,
  favorite,
  season,
  like,
  dressCode
}

enum Order {
  desDate,
  ascDate,
  desPop,
  ascPop,
}

List<String> orderNames = ['Data Decrescente', 'Data Crescente', 'Popolarità Decrescente', 'Popolarità Crescente'];

Map<int, String> orderFilters = orderNames.asMap();

/*
class CardExtended extends StatelessWidget {
  const CardExtended({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: Hero(
          tag: "photo",
          child: Image.network(
            'https://picsum.photos/500?image=1',
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }
}*/

Widget buildCardShimmer() => Shimmer.fromColors(
    child: const Card(),
    baseColor: const Color(0xFFE3E1E1),
    highlightColor: const Color(0xFFEFEFEF));



class HorizontalOutfitList extends StatelessWidget {
  const HorizontalOutfitList(
      {Key? key,
      this.title = 'Title',
      this.explore2,
      required this.section,
      this.itemHeight = 250,
      this.cardShape = const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)))})
      : super(key: key);

  void _handleTap(BuildContext context, GlobalKey parentKey) {
    /*Navigator.of(context).push(MorpheusPageRoute(
      builder: (context) => ExploreOutfits(),
      parentKey: parentKey,
    ));*/
/*    pushNewScreen(context,
        screen: FilteredOutfitsFrontLayer(subheaderTitle: "Titolo",),
        withNavBar: true,
        pageTransitionAnimation: PageTransitionAnimation.cupertino);*/
  }

  final bool isLoading = false;
  final double itemHeight;
  final ShapeBorder cardShape;
  final String title;
  final ExploreModel? explore2;
  final Section section;

  @override
  Widget build(BuildContext context) {
    final _parentKey = GlobalKey();
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              TextButton(
                style: ButtonStyle(
                    overlayColor:
                        MaterialStateProperty.all(const Color(0xFFFDCDA2)),
                    foregroundColor:
                        MaterialStateProperty.all(const Color(0xFFA4626D))),
                onPressed: () {
                  log("asd");
                  explore2?.showScreen(1, section);
                },
                child: Row(
                  children: const [
                    Text("Vedi Tutti"),
                    Icon(Icons.arrow_forward_ios)
                  ],
                ),
              ),
            ],
          ),
          Consumer<ExploreModel>(
            builder: (context, explore, child) {
              return SizedBox(
                height: itemHeight,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 1.5,
                    crossAxisCount: 1,
                    crossAxisSpacing: 8,
                    //TODO: valutare errore scroll extent is negative con silver grid
                    //mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    if (explore.isLoading) {
                      return buildCardShimmer();
                    } else {
                      return InkWell(
                        child: Hero(
                          tag: "explorehome$section$index",
                          child: Card(
                            shape: cardShape,
                            child: Image.file(
                              //TODO: implement dynamic loading
                              File(explore.exploreMap[section]?[index].imgPath
                                  as String),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Outfit(
                                outfit: explore.exploreMap[section]
                                    ?.elementAt(index) as OutfitModel,
                                heroTag: "explorehome$section$index",
                                section: section,
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                  itemCount: explore.isLoading
                      ? 4
                      : (explore.exploreMap[section]?.length as int > 4
                          ? 4
                          : explore.exploreMap[section]?.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class HorizontalUserList extends StatelessWidget {
  const HorizontalUserList(
      {Key? key,
        this.title = 'Title',
        this.explore2,
        required this.section,
        this.itemHeight = 200,
        this.cardShape = const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)))})
      : super(key: key);

  void _handleTap(BuildContext context, GlobalKey parentKey, ProfileModel profile) {
    PersonalAccount userProfile = PersonalAccount();
    userProfile.myProfile = profile;
    userProfile.isLoggedIn = true;
    Navigator.of(context).push(MorpheusPageRoute(
      builder: (context) => Profile(profile: userProfile ),
      parentKey: parentKey,
    ));
  }

  final bool isLoading = false;
  final double itemHeight;
  final ShapeBorder cardShape;
  final String title;
  final ExploreModel? explore2;
  final Section section;

  @override
  Widget build(BuildContext context) {
    final _parentKey = GlobalKey();
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              TextButton(
                style: ButtonStyle(
                    overlayColor:
                    MaterialStateProperty.all(const Color(0xFFFDCDA2)),
                    foregroundColor:
                    MaterialStateProperty.all(const Color(0xFFA4626D))),
                onPressed: () {
                  explore2?.showScreen(1, section);
                },
                child: Row(
                  children: const [
                    Text("Vedi Tutti"),
                    Icon(Icons.arrow_forward_ios)
                  ],
                ),
              ),
            ],
          ),
          Consumer<ExploreModel>(
            builder: (context, explore, child) {
              return SizedBox(
                height: itemHeight,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 1.5,
                    crossAxisCount: 1,
                    //mainAxisSpacing: 8,
                    //TODO: valutare errore scroll extent is negative con silver grid
                    //mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    if (explore.isLoading) {
                      return buildCardShimmer();
                    } else {
                      ProfileModel profile = explore.exploreMap[section]?[index] as ProfileModel;
                      return InkWell(
                        key: _parentKey,
                        child: Hero(
                          tag: "explorehome$section$index",
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 48,
                                backgroundColor: const Color(0xFF425C5A),
                                backgroundImage: profile.pathPicture!.isEmpty ? Image.file(
                                  //TODO: implement dynamic loading
                                  File(profile.pathPicture!),
                                  fit: BoxFit.cover,
                                ).image : Image.asset('assets/profile_placeholder.png',fit: BoxFit.fitWidth,).image,
                              ),
                              Text(profile.name)
                            ],
                          ),
                        ),
                        onTap: () {
                          _handleTap(context, _parentKey, profile);
                        },
                      );
                    }
                  },
                  itemCount: explore.isLoading
                      ? 4
                      : (explore.exploreMap[section]?.length as int > 4
                      ? 4
                      : explore.exploreMap[section]?.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


class FullScreenImage extends StatelessWidget {
  const FullScreenImage({
    Key? key,
    required this.image,
    required this.tag,
  }) : super(key: key);

  final Image image;
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
                child: image,
              )),
              Material(
                child: InkWell(
                  child: const Icon(
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

class MultiSelectColorField extends FormField<List<MultiSelectItem>> {
  MultiSelectColorField(
      {Key? key,
      FormFieldSetter<List<MultiSelectItem>>? onSaved,
      FormFieldValidator<List<MultiSelectItem>>? validator,
      Color textColor = const Color(0xFFFDCDA2),
      Color borderColor = const Color(0xFF425C5A),
      String text = "Seleziona",
      List<MultiSelectItem> initialValue = const [],
      bool autovalidate = false})
      : super(
            key: key,
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            builder: (FormFieldState<List<MultiSelectItem>> state) {
              return Column(
                children: [
                  InkWell(
                    child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(text,
                                style:
                                    const TextStyle(color: Color(0xFFFDCDA2))),
                            const Icon(Icons.add, color: Color(0xFFA4626D)),
                          ],
                        )),
                    onTap: () async {
                      var inputCol = await showColorPickerDialog(
                        state.context,
                        Colors.transparent,
                        title: Text('ColorPicker',
                            style: Theme.of(state.context).textTheme.headline6),
                        showColorCode: true,
                        colorCodeHasColor: true,
                        pickersEnabled: <ColorPickerType, bool>{
                          ColorPickerType.wheel: false,
                          ColorPickerType.accent: false
                        },
                        actionButtons: const ColorPickerActionButtons(
                          okButton: true,
                          closeButton: true,
                          dialogActionButtons: false,
                        ),
                      );
                      List<MultiSelectItem> copyValue = [...?state.value];
                      copyValue.add(MultiSelectItem(
                          inputCol.value, ColorNames.guess(inputCol)));
                      log('Dopo Aggiunta${copyValue.toString()}');
                      state.didChange(copyValue);
                    },
                  ),
                  MultiSelectChipDisplay(
                    scroll: true,
                    items: state.value,
                    textStyle: const TextStyle(color: Colors.black54),
                    icon: const Icon(Icons.close),
                    colorator: (value) {
                      return Color(value as int).withOpacity(0.5);
                    },
                    onTap: (value) {
                      List<MultiSelectItem> copyValue = [...?state.value];
                      copyValue
                          .removeWhere((element) => element.value == value);
                      log("Dopo rimozione:$copyValue");
                      state.didChange(copyValue);
                    },
                  ),
                ],
              );
            });
}

class ColorFormField extends FormField<Color> {
  ColorFormField(
      {Key? key,
      FormFieldSetter<Color>? onSaved,
      FormFieldValidator<Color>? validator,
      Color textColor = const Color(0xFFFDCDA2),
      Color borderColor = const Color(0xFF425C5A),
      String text = "Seleziona",
      Color initialValue = Colors.transparent,
      bool autovalidate = false})
      : super(
            key: key,
            onSaved: onSaved,
            restorationId: "ASD",
            validator: validator,
            initialValue: initialValue,
            builder: (FormFieldState<Color> state) {
              return Container(
                padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Text(
                        text,
                        softWrap: true,
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: state.value == Colors.transparent
                          ? ActionChip(
                              label: const Icon(Icons.add),
                              onPressed: () async {
                                var inputCol = await showColorPickerDialog(
                                  state.context,
                                  state.value as Color,
                                  title: Text('ColorPicker',
                                      style: Theme.of(state.context)
                                          .textTheme
                                          .headline6),
                                  showColorCode: true,
                                  colorCodeHasColor: true,
                                  pickersEnabled: <ColorPickerType, bool>{
                                    ColorPickerType.wheel: false,
                                    ColorPickerType.accent: false
                                  },
                                  actionButtons: const ColorPickerActionButtons(
                                    okButton: true,
                                    closeButton: true,
                                    dialogActionButtons: false,
                                  ),
                                );
                                state.didChange(inputCol);
                                log(inputCol.toString());
                              },
                            )
                          : RawChip(
                              onPressed: () {
                                state.didChange(Colors.transparent);
                              },
                              label: Text(ColorNames.guess(state.value!),
                                  overflow: TextOverflow.fade),
                              avatar: CircleAvatar(
                                backgroundColor: state.value!,
                              ),
                            ),
                    ),
                  ],
                ),
              );
            });
}

class SwitchFormField extends FormField<bool> {
  SwitchFormField(
      {Key? key,
      FormFieldSetter<bool>? onSaved,
      FormFieldValidator<bool>? validator,
      bool currentValue = false,
      Text title = const Text("Switch"),
      bool autovalidate = false})
      : super(
          key: key,
          onSaved: onSaved,
          restorationId: "AD",
          validator: validator,
          initialValue: currentValue,
          builder: (FormFieldState<bool> state) {
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  title,
                  Switch(
                    activeColor: const Color(0xFFA4626D),
                    value: state.value as bool,
                    onChanged: (value) {
                      state.didChange(value);
                      log(value.toString());
                    },
                  ),
                ],
              ),
            );
          },
        );
}

class OutfitCard extends StatelessWidget {
  const OutfitCard(
      {Key? key,
      required this.index,
      required this.outfitsInterface,
      required this.section,
      required this.heroTag,
      this.isEditable = false})
      : super(key: key);

  final int index;
  final Section section;
  final OutfitsInterface outfitsInterface;
  final String heroTag;
  final bool isEditable;

  void _handleTap(BuildContext context, GlobalKey parentKey) {
    Navigator.of(context).push(MorpheusPageRoute(
      //TODO: Modifica Outfit
      builder: (context) => Outfit(
        outfit: outfitsInterface.getList(section).elementAt(index),
        heroTag: heroTag,
        section: section,
        isEditable: isEditable,
      ),
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
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Hero(
                tag: heroTag,
                /*{outfitsInterface.getListOutfits(section).elementAt(index).id*/
                child: Image.file(
                  File(outfitsInterface
                      .getList(section)
                      .elementAt(index)
                      .imgPath as String),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /*const Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text("TESTO"),
                        )),*/
                    section == Section.myoutfits
                        ? Flexible(
                            flex: 1,
                            child: LikeButton(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              isLiked: outfitsInterface
                                  .getList(section)
                                  .elementAt(index)
                                  .favorite,
                              onTap: (isLiked) async {
                                outfitsInterface
                                    .getList(section)
                                    .elementAt(index)
                                    .favorite = !isLiked;
                                outfitsInterface.updateOutfit(
                                    OutfitDBWorker.outfitDBWorker,
                                    outfitsInterface
                                        .getList(section)
                                        .elementAt(index),
                                    personalProfile.myProfile,
                                    withReload: false);
                                return !isLiked;
                              },
                            ),
                          )
                        : Flexible(
                            flex: 1,
                            child: LikeButton(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              isLiked: outfitsInterface
                                  .getList(section)
                                  .elementAt(index)
                                  .isWishlisted,
                              likeBuilder: (bool isLiked) {
                                return Icon(
                                  Icons.bookmark,
                                  color: isLiked
                                      ? Colors.deepOrangeAccent
                                      : Colors.grey,
                                );
                              },
                              onTap: (isLiked) async {
                                bool toBeDeleted;
                                if (isLiked == true) {
                                  toBeDeleted = await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: const Text(
                                              "Sei sicuro di voler rimuovere questo outfit dal tuo wishlist?"),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('No'),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(false);
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Sì'),
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                  log("Rimuovere outfit da wishlist?: $toBeDeleted");
                                  if (toBeDeleted) {
                                    if (section == Section.wishlist) {
                                      wishlistModel.removeOutfit(
                                          OutfitDBWorker.outfitDBWorker,
                                          outfitsInterface
                                              .getList(section)
                                              .elementAt(index)
                                              .id!,
                                          personalProfile.myProfile,
                                          withReload: true);
                                    } else {
                                      wishlistModel.removeOutfit(
                                          OutfitDBWorker.outfitDBWorker,
                                          outfitsInterface
                                              .getList(section)
                                              .elementAt(index)
                                              .id!,
                                          personalProfile.myProfile,
                                          withReload: false);
                                    }
                                    return !isLiked;
                                  } else {
                                    return isLiked;
                                  }
                                } else {
                                  if (section == Section.wishlist) {
                                    wishlistModel.addOutfit(
                                        OutfitDBWorker.outfitDBWorker,
                                        outfitsInterface
                                            .getList(section)
                                            .elementAt(index),
                                        personalProfile.myProfile,
                                        withReload: true);
                                  } else {
                                    wishlistModel.addOutfit(
                                        OutfitDBWorker.outfitDBWorker,
                                        outfitsInterface
                                            .getList(section)
                                            .elementAt(index),
                                        personalProfile.myProfile);
                                  }

                                  return !isLiked;
                                }
                              },
                            ),
                          ),
                    Flexible(
                      flex: 1,
                      child: IconButton(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Color(0xFF425C5A),
                        ),
                        onPressed: () {
                          mbs.showMaterialModalBottomSheet(
                              useRootNavigator: true,
                              context: context,
                              builder: (context) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    section == Section.myoutfits
                                        ? InkWell(
                                            child: const ListTile(
                                              leading: Icon(Icons.delete),
                                              title: Text("Elimina Outfit"),
                                            ),
                                            onTap: () async {
                                              bool toBeDeleted =
                                                  await showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          content: const Text(
                                                              "Sei sicuro di voler eliminare questo articolo?"),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              child: const Text(
                                                                  'No'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(false);
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: const Text(
                                                                  'Sì'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(true);
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(true);
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      });
                                              log("Cancellare outfit?: $toBeDeleted");
                                              if (toBeDeleted) {
                                                outfitsInterface.removeOutfit(
                                                    OutfitDBWorker
                                                        .outfitDBWorker,
                                                    outfitsInterface
                                                        .getList(section)
                                                        .elementAt(index)
                                                        .id as int,
                                                    personalProfile.myProfile);
                                              }
                                            },
                                          )
                                        : const SizedBox(),
                                    section == Section.myoutfits
                                        ? InkWell(
                                            child: const ListTile(
                                                leading: Icon(Icons.edit),
                                                //TODO: implementa modifica outfit bottom sheet
                                                title: Text("Modifica Outfit")),
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return NuovoOutfit(
                                                  outfitToEdit: outfitsInterface
                                                      .getList(
                                                          Section.myoutfits)
                                                      .elementAt(index),
                                                );
                                              }));
                                            },
                                          )
                                        : const SizedBox(),
                                    section != Section.myoutfits &&
                                            section != Section.wishlist
                                        ? InkWell(
                                            child: const ListTile(
                                                leading:
                                                    Icon(Icons.bookmark_add),
                                                //TODO: implementa aggiunta a wishlist bottom sheet
                                                title: Text(
                                                    "Aggiungi a Wishlist")),
                                            onTap: () {},
                                          )
                                        : const SizedBox(),
                                    section == Section.wishlist
                                        ? InkWell(
                                            child: const ListTile(
                                                leading:
                                                    Icon(Icons.bookmark_remove),
                                                //TODO: implementa aggiunta a wishlist bottom sheet
                                                title: Text(
                                                    "Rimuovi da Wishlist")),
                                            onTap: () async {
                                              bool toBeDeleted =
                                                  await showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          content: const Text(
                                                              "Sei sicuro di voler rimuovere questo outfit dal tuo wishlist?"),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              child: const Text(
                                                                  'No'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(false);
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: const Text(
                                                                  'Sì'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(true);
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(true);
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      });
                                              log("Rimuovere outfit da wishlist?: $toBeDeleted");
                                              if (toBeDeleted) {
                                                if (section ==
                                                    Section.wishlist) {
                                                  wishlistModel.removeOutfit(
                                                      OutfitDBWorker
                                                          .outfitDBWorker,
                                                      outfitsInterface
                                                          .getList(
                                                              section)
                                                          .elementAt(index)
                                                          .id!,
                                                      personalProfile.myProfile,
                                                      withReload: true);
                                                } else {
                                                  wishlistModel.removeOutfit(
                                                      OutfitDBWorker
                                                          .outfitDBWorker,
                                                      outfitsInterface
                                                          .getList(
                                                              section)
                                                          .elementAt(index)
                                                          .id!,
                                                      personalProfile.myProfile,
                                                      withReload: false);
                                                }
                                              }
                                            },
                                          )
                                        : const SizedBox(),
                                  ],
                                );
                              });
                        },
                      ),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
