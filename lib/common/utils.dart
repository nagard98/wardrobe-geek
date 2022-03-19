import 'dart:developer';
import 'dart:io';
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

late Directory docsDir;

enum Filter { clothingType, brand, primColor, secColor, fav , favorite, season, like, dressCode}

class CardExtended extends StatelessWidget {
  const CardExtended({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
}

Widget buildCardShimmer() => Shimmer.fromColors(
    child: const Card(),
    baseColor: const Color(0xFFE3E1E1),
    highlightColor: const Color(0xFFEFEFEF));

class CardItem extends StatelessWidget {
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
                child: Image.network(
                  'https://picsum.photos/500?image=1',
                  fit: BoxFit.fitHeight,
                ),
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

class MultiSelectColorField extends FormField<List<MultiSelectItem>>{
  MultiSelectColorField(
      {Key? key,
        FormFieldSetter<List<MultiSelectItem>>? onSaved,
        FormFieldValidator<List<MultiSelectItem>>? validator,
        Color textColor = const Color(0xFFFDCDA2),
        Color borderColor = const Color(0xFF425C5A),
        String text = "Seleziona",
        List<MultiSelectItem> initialValue = const [] ,
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
                      Text(text, style: TextStyle(color: Color(0xFFFDCDA2))),
                      const Icon(Icons.add, color: Color(0xFFA4626D)),
                    ],
                  )
              ),
              onTap: () async{
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
                copyValue.add(MultiSelectItem(inputCol.value, ColorNames.guess(inputCol)));
                log('Dopo Aggiunta${copyValue.toString()}');
                state.didChange(copyValue);
              },
            ),
            MultiSelectChipDisplay(
              scroll: true,
              items: state.value,
              textStyle: TextStyle(color: Colors.black54),
              icon: Icon(Icons.close),
              colorator: (value){
                return Color(value as int).withOpacity(0.5);
              },
              onTap: (value) {
                List<MultiSelectItem> copyValue = [...?state.value];
                copyValue.removeWhere((element)=> element.value == value);
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
              return DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: TextField(
                        readOnly: true,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: textColor),
                          hintText: text,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 2,
                        child: ActionChip(
                          label: Icon(Icons.add),
                          onPressed: () async {
                            var inputCol = await showColorPickerDialog(
                              state.context,
                              state.value as Color,
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
                            state.didChange(inputCol);
                            log(inputCol.toString());
                          },
                        )),
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
                    activeColor: Color(0xFFA4626D),
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
  OutfitCard({Key? key, required this.index, required this.outfitsInterface, required this.section}) : super(key: key);

  int index;
  Section section;
  OutfitsInterface outfitsInterface;

  void _handleTap(BuildContext context, GlobalKey parentKey) {
    Navigator.of(context).push(MorpheusPageRoute(
      //TODO: Modifica Outfit
      builder: (context) => Outfit(
          outfit: outfitsInterface.getListOutfits(section).elementAt(index),
          heroIndex: index),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Hero(
                tag: "outfit${outfitsInterface.getListOutfits(section).elementAt(index).id}",
                child: Image.file(
                  File(outfitsInterface.getListOutfits(section).elementAt(index).imgPath as String),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
                flex: 1,
                child: Row(
                  children: [
                    const Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text("TESTO"),
                        )),
                    Expanded(
                      flex: 1,
                      child: LikeButton(
                        isLiked: outfitsInterface.getListOutfits(section).elementAt(index).favorite,
                        onTap: (isLiked) async {
                          outfitsInterface.getListOutfits(section).elementAt(index).favorite =
                          !isLiked;
                          outfitsInterface.updateOutfit(
                              OutfitDBWorker.outfitDBWorker,
                              outfitsInterface.getListOutfits(section).elementAt(index),
                              profile,
                              withReload: false);
                          return !isLiked;
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: const Icon(Icons.more_vert, color: Color(0xFF425C5A),),
                        onPressed: () {
                          mbs.showMaterialModalBottomSheet(
                              useRootNavigator: true,
                              context: context,
                              builder: (context) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      child:  ListTile(
                                        leading: Icon(Icons.delete),
                                        title: Text("Elimina Outfit"),
                                      ),
                                      onTap: () async {
                                        bool toBeDeleted = await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                content: Text(
                                                    "Sei sicuro di voler eliminare questo articolo?"),
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
                                                      Navigator.of(context)
                                                          .pop(true);
                                                      Navigator.of(context)
                                                          .pop(true);
                                                    },
                                                  ),
                                                ],
                                              );
                                            });
                                        log("Cancellare outfit?: $toBeDeleted");
                                        if (toBeDeleted) {
                                          outfitsInterface.removeOutfit(
                                              OutfitDBWorker.outfitDBWorker,
                                              outfitsInterface.getListOutfits(section).elementAt(index)
                                                  .id as int,
                                              profile);
                                        }
                                      },
                                    ),
                                    InkWell(
                                      child: ListTile(
                                          leading: Icon(Icons.edit),
                                          title: Text("Modifica Outfit")),
                                      onTap: () {},
                                    ),
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