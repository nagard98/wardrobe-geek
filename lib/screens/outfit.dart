import 'dart:io';

import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/models/myoutfits_model.dart';
import 'package:esempio/models/outfit_model.dart';
import 'package:esempio/models/outfit_model.dart';
import 'package:esempio/models/wardrobe_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:backdrop/backdrop.dart';
import '../common/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer';
import 'package:esempio/common/utils.dart' as utils;
import 'package:path/path.dart';
import 'package:esempio/models/profile_model.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_colorpicker/src/material_picker.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:esempio/models/article_model.dart';

class Outfit extends StatelessWidget {
  final int heroIndex;

  const Outfit({Key? key, this.heroIndex = 0}) : super(key: key);

  static Future pickImage() async {
    log("Testing camera");
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nome Outfit"),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Stack(
                alignment: Alignment.topLeft,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).appBarTheme.backgroundColor),
                    height: 300,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 0, color: Colors.white),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    height: 130,
                    margin: EdgeInsets.only(top: 270),
                  ),
                  Row(
                    children: [
                      Flexible(
                        flex: 7,
                        child: Container(
                          margin: EdgeInsets.only(top: 40, left: 0),
                          child: InkWell(
                            child: Hero(
                              tag: "outfit$heroIndex",
                              child: Container(
                                height: 285,
                                child: Card(
                                  clipBehavior: Clip.hardEdge,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.zero,
                                          topRight: Radius.circular(20),
                                          bottomLeft: Radius.zero,
                                          bottomRight: Radius.circular(20))),
                                  margin: EdgeInsets.zero,
                                  child: Image.network(
                                    'https://picsum.photos/500/750?image=35',
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) {
                                return FullScreenImage(
                                    imageUrl:
                                        "https://picsum.photos/500/750?image=35",
                                    tag: "outfit$heroIndex");
                              }));
                            },
                          ),
                        ),
                      ),
                      Flexible(
                          fit: FlexFit.tight,
                          flex: 8,
                          child: Column(
                            children: [
                              Text("TITOLO"),
                              Text("Brand"),
                              Text("Colore"),
                              Text("Stagione"),
                              Text("Designer")
                            ],
                          ))
                    ],
                  )
                ],
              ),
              childCount: 1,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                (context, index) => Container(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(width: 0, color: Colors.white)),
                      child: Column(
                        children: [
                          Material(
                            color: Colors.blue,
                            child: ListTile(
                              tileColor: Colors.blue,
                              leading: Icon(Icons.ten_k),
                            ),
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
      ),
    );
  }
}

class ArticleListFormField extends FormField<List<ArticleModel>> {
  ArticleListFormField(
      {required BuildContext context,
      FormFieldSetter<List<ArticleModel>>? onSaved,
      FormFieldValidator<List<ArticleModel>>? validator,
      List<ArticleModel> initialValue = const [],
      bool autovalidate = false})
      : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            builder: (FormFieldState<List<ArticleModel>> state) {
              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue)),
                      child: Text("Seleziona Articoli"),
                      onPressed: () async {
                        List<String> selectedIds = await Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return SelezioneArticoli();
                        }));
                        List<ArticleModel> _articles = [];
                        wardrobeModel.articles?.forEach((article) {
                          for(var stringId in selectedIds){
                            int _id = int.parse(stringId);
                            if(article.id == _id){
                              _articles.add(article);
                            }
                          }
                        });
                        state.didChange(_articles);
                        log(_articles.toString());
                      },
                    ),
                  )
                ],
              );
            });
}

class NuovoOutfit extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static XFile? imageFile;

  NuovoOutfit({Key? key}) : super(key: key);

  static Future chooseImage(ImageSource source) async {
    imageFile = await ImagePicker().pickImage(source: source);
    log(imageFile?.path ?? "");
    myOutfitsModel.currentOutfit!.imgPath = imageFile?.path;
  }

  static void _saveImage() {
    log("IN IMAGE");
    String newPath =
        join(utils.docsDir.path, '${myOutfitsModel.currentOutfit?.id}.jpg');
    imageFile?.saveTo(newPath);
    log(newPath);
  }

  _save(BuildContext context) async {
    _formKey.currentState!.save();
    //TODO: Add validation to input
    myOutfitsModel.currentOutfit?.favorite = false;
    myOutfitsModel.currentOutfit?.likes = 0;

    if (myOutfitsModel.currentOutfit?.id == null) {
      await OutfitDBWorker.outfitDBWorker.create(
          myOutfitsModel.currentOutfit as OutfitModel, profile.id as int);
    } else {
      await OutfitDBWorker.outfitDBWorker.update(
          myOutfitsModel.currentOutfit as OutfitModel, profile.id as int);
    }

    _saveImage();

    myOutfitsModel.loadOutfits(OutfitDBWorker.outfitDBWorker, profile);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
        //TODO: controllare successo operazione
        const SnackBar(content: Text("Aggiunto outfit correttamente")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nuovo Outfit"),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Stack(
                  alignment: Alignment.topLeft,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).appBarTheme.backgroundColor),
                      height: 300,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(width: 0, color: Colors.white),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      height: 130,
                      margin: EdgeInsets.only(top: 270),
                    ),
                    Row(
                      children: [
                        Flexible(
                          flex: 7,
                          child: Container(
                            margin: EdgeInsets.only(top: 40, left: 0),
                            child: InkWell(
                              child: Container(
                                height: 285,
                                child: Card(
                                  clipBehavior: Clip.hardEdge,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.zero,
                                          topRight: Radius.circular(20),
                                          bottomLeft: Radius.zero,
                                          bottomRight: Radius.circular(20))),
                                  margin: EdgeInsets.zero,
                                  child: Image.network(
                                    'https://picsum.photos/500/750?image=35',
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                            fit: FlexFit.tight,
                            flex: 8,
                            child: Column(
                              children: [
                                Text("TITOLO"),
                                Text("Brand"),
                                Text("Colore"),
                                Text("Stagione"),
                                Text("Designer")
                              ],
                            ))
                      ],
                    )
                  ],
                ),
                childCount: 1,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) => Container(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 0, color: Colors.white)),
                        child: Column(
                          children: [
                            Container(
                              width: 250,
                              height: 250,
                              child: Card(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () {
                                        chooseImage(ImageSource.camera);
                                      },
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.photo_camera),
                                            Text("Fai Foto")
                                          ]),
                                    ),
                                    Text("oppure"),
                                    OutlinedButton(
                                      onPressed: () {
                                        chooseImage(ImageSource.gallery);
                                      },
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.collections),
                                            Text("Scegli da Galleria")
                                          ]),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            DropdownButtonFormField(
                              hint: Text("Stagione"),
                              isExpanded: true,
                              value: Season.estate.index.toString(),
                              onSaved: (input) {
                                myOutfitsModel.currentOutfit!.season =
                                    Season.values[int.parse(input as String)];
                              },
                              onChanged: (String? newValue) {},
                              items: [
                                DropdownMenuItem(
                                    child: Text("Estate"),
                                    value: Season.estate.index.toString()),
                                DropdownMenuItem(
                                    child: Text("Inverno"),
                                    value: Season.inverno.index.toString()),
                                DropdownMenuItem(
                                    child: Text("Autunno"),
                                    value: Season.autunno.index.toString()),
                                DropdownMenuItem(
                                    child: Text("Primavera"),
                                    value: Season.primavera.index.toString()),
                              ],
                            ),
                            SizedBox(height: 20),
                            DropdownButtonFormField(
                              hint: Text("Dress Code"),
                              isExpanded: true,
                              value: DressCode.casual.index.toString(),
                              onSaved: (input) {
                                myOutfitsModel.currentOutfit!.dressCode =
                                    DressCode
                                        .values[int.parse(input as String)];
                              },
                              onChanged: (String? newValue) {},
                              items: [
                                DropdownMenuItem(
                                    child: Text("Casual"),
                                    value: DressCode.casual.index.toString()),
                                DropdownMenuItem(
                                    child: Text("Business Casual"),
                                    value: DressCode.businessCasual.index
                                        .toString()),
                                DropdownMenuItem(
                                    child: Text("Formal Casual"),
                                    value: DressCode.formalCasual.index
                                        .toString()),
                                DropdownMenuItem(
                                    child: Text("Informale"),
                                    value:
                                        DressCode.informale.index.toString()),
                                DropdownMenuItem(
                                    child: Text("StreetWear"),
                                    value:
                                        DressCode.streetwear.index.toString()),
                                DropdownMenuItem(
                                    child: Text("Altro"),
                                    value: DressCode.altro.index.toString()),
                              ],
                            ),
                            SizedBox(height: 30),
                            ArticleListFormField(
                              context: context,
                              onSaved: (articles){
                                log(articles.toString());
                                myOutfitsModel.currentOutfit?.articles = articles;
                              },
                            ),
                            SizedBox(height: 30),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.green)),
                                    child: Text("Salva Articolo"),
                                    onPressed: () {
                                      _save(context);
                                    },
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 20),
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
        ),
      ),
    );
  }
}

class SelezioneArticoli extends StatelessWidget {
  Widget getChild(String imagePath, String title) {
    return SizedBox(
      width: 75,
      height: 50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
              child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
          )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title),
          )
        ],
      ),
    );
  }

  List<MultiSelectCard<String>>? items = [];
  List<String> selectedIds = [];

  @override
  Widget build(BuildContext context) {
    wardrobeModel.articles?.forEach((article) {
      items?.add(MultiSelectCard(
        value: article.id.toString(),
        child: getChild(article.imgPath as String, article.id.toString()),
      ));
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Seleziona Articoli'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop(selectedIds);
              },
              icon: Icon(Icons.check))
        ],
      ),
      body: MultiSelectContainer(
        itemsPadding: const EdgeInsets.all(5),
        itemsDecoration: MultiSelectDecorations(
          decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1)),
          selectedDecoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.green, Colors.lightGreen]),
          ),
        ),
        items: items!,
        onChange: (List<String> selectedItems, String selectedItem) {
          selectedIds = selectedItems;
          log(selectedItems.toString());
        },
      ),
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
