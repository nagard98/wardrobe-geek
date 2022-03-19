import 'package:esempio/models/article_model.dart';
import 'package:esempio/models/wardrobe_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:esempio/db/article_db_worker.dart';
import 'package:esempio/models/profile_model.dart';
import 'package:esempio/common/utils.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:colornames/colornames.dart';

class NuovoArticolo extends StatefulWidget {
  const NuovoArticolo({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NuovoArticoloState();
  }
}

class NuovoArticoloState extends State<NuovoArticolo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static XFile? imageFile;

  static Future chooseImage(ImageSource source) async {
    imageFile = await ImagePicker().pickImage(source: source);
    log(imageFile?.path ?? "");
    wardrobeModel.currentArticle!.imgPath = imageFile?.path;
  }

  static void _saveImage() {
    log("IN IMAGE");
    String newPath = join(
        docsDir.path, 'articles', '${wardrobeModel.currentArticle?.id}.jpg');
    imageFile?.saveTo(newPath);
    log(newPath);
  }

  _save(BuildContext context) async {
    _formKey.currentState!.save();
    //TODO: Add validation to input

    if (wardrobeModel.currentArticle?.id == null) {
      await ArticleDBWorker.articleDBWorker.create(
          wardrobeModel.currentArticle as ArticleModel, profile.id as int);
    } else {
      await ArticleDBWorker.articleDBWorker.update(
          wardrobeModel.currentArticle as ArticleModel, profile.id as int);
    }

    _saveImage();

    wardrobeModel.loadArticles(ArticleDBWorker.articleDBWorker, profile);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aggiunto articolo correttamente")));
  }

  List<DropdownMenuItem<int>> _dropDownFromMap(Map<int, String> map) {
    List<DropdownMenuItem<int>> items = [];
    map.forEach((key, value) {
      items.add(
        DropdownMenuItem<int>(
          child: Text(value),
          value: key,
        ),
      );
    });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: const Color(0xFFFDCDA2),
        title: const Text("Nuovo Articolo"),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).appBarTheme.backgroundColor),
                      height: 220,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(width: 0, color: Colors.white),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      height: 130,
                      margin: EdgeInsets.only(top: 190),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 40),
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            const BoxShadow(
                              color: Color(0xFFDEDEDE),
                            ),
                            const BoxShadow(
                              color: Color(0xFFF1F1F1),
                              spreadRadius: -4.0,
                              blurRadius: 8.0,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                  foregroundColor: MaterialStateProperty.all(
                                      Color(0xFF76454E)),
                                  overlayColor: MaterialStateProperty.all(
                                      Color(0xFFFDCDA2))),
                              onPressed: () {
                                chooseImage(ImageSource.camera);
                              },
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.photo_camera),
                                    Text("Fai Foto")
                                  ]),
                            ),
                            Text("oppure"),
                            OutlinedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                  foregroundColor: MaterialStateProperty.all(
                                      Color(0xFF76454E)),
                                  overlayColor: MaterialStateProperty.all(
                                      Color(0xFFFDCDA2))),
                              onPressed: () {
                                chooseImage(ImageSource.gallery);
                              },
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.collections),
                                    Text("Scegli da Galleria")
                                  ]),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                childCount: 1,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) => Container(
                        padding: EdgeInsets.only(left: 35, top: 20, right: 35),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 0, color: Colors.white)),
                        child: Column(
                          children: [
                            TextFormField(
                              textCapitalization: TextCapitalization.sentences,
                              onSaved: (input) {
                                wardrobeModel.currentArticle!.articleName =
                                    input;
                              },
                              cursorColor: Color(0xFFA4626D),
                              decoration: InputDecoration(
                                //hintText: 'Titolo Articolo',
                                labelText: 'Titolo Articolo',
                                labelStyle: TextStyle(color: Color(0xFF425C5A)),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFF425C5A)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(0xFFFDCDA2), width: 2.0)),
                              ),
                            ),
                            SizedBox(height: 20),
                            DropdownSearch<DropdownMenuItem<int>>(
                              dropdownSearchDecoration: InputDecoration(
                                  labelText: "Brand",
                                  labelStyle:
                                      TextStyle(color: Color(0xFF425C5A)),
                                  isDense: true,
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(0xFFFDCDA2),
                                          width: 2.0)),
                                  contentPadding:
                                      EdgeInsets.fromLTRB(10, 6, 10, 6),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(0xFF425C5A)))),
                              showSearchBox: true,
                              mode: Mode.DIALOG,
                              popupTitle: Text('Seleziona Brand'),
                              items: _dropDownFromMap(brands),
                              itemAsString: (item) =>
                                  (item?.child as Text).data as String,
                              onSaved: (item) {
                                wardrobeModel.currentArticle!.brand =
                                    item?.value;
                              },
                              onChanged: print,
                            ),
                            SizedBox(height: 20),
                            DropdownSearch<DropdownMenuItem<int>>(
                              dropdownSearchDecoration: InputDecoration(
                                  labelText: "Tipo Capo",
                                  labelStyle:
                                      TextStyle(color: Color(0xFF425C5A)),
                                  isDense: true,
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(0xFFFDCDA2),
                                          width: 2.0)),
                                  contentPadding:
                                      EdgeInsets.fromLTRB(10, 6, 10, 6),
                                  enabledBorder: OutlineInputBorder(
                                      gapPadding: 2.0,
                                      borderSide: BorderSide(
                                          color: Color(0xFF425C5A)))),
                              showSearchBox: true,
                              mode: Mode.DIALOG,
                              popupTitle: Text('Seleziona Tipo Capo'),
                              items: _dropDownFromMap(clothing),
                              itemAsString: (item) =>
                                  (item?.child as Text).data as String,
                              onSaved: (item) {
                                wardrobeModel.currentArticle!.clothingType =
                                    item?.value;
                              },
                              onChanged: print,
                            ),
/*                            DropdownButtonFormField<int>(
                              hint: Text("Brand"),
                              isExpanded: true,
                              value: 0,
                              onSaved: (input) {
                                wardrobeModel.currentArticle!.brand = input;
                              },
                              onChanged: (newValue) {},
                              items: _dropDownFromMap(brands),
                            ),
                            SizedBox(height: 20),
                            DropdownButtonFormField<int>(
                                hint: Text("Tipo"),
                                isExpanded: true,
                                value: 0,
                                onSaved: (input) {
                                  wardrobeModel.currentArticle!.clothingType =
                                      input;
                                },
                                onChanged: (newValue) {},
                                items: _dropDownFromMap(clothing)),
                            SizedBox(height: 20),*/
                            SizedBox(height: 20),
                            ColorFormField(
                              text: "Colore Primario",
                              textColor: Color(0xFF425C5A),
                              onSaved: (color) {
                                log(color.toString());
                                wardrobeModel.currentArticle!.primaryColor =
                                    color;
                              },
                            ),
                            SizedBox(height: 20),
                            ColorFormField(
                              text: "Colore Secondario",
                              textColor: Color(0xFF425C5A),
                              onSaved: (color) {
                                log(color.toString());
                                wardrobeModel.currentArticle!.secondaryColor =
                                    color;
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
                                                Color(0xFFF39053))),
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

class Articolo extends StatelessWidget {
  ArticleModel article;
  late File imageFile;

  Articolo({required this.article, Key? key}) : super(key: key) {
    imageFile = File(article.imgPath!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: const Color(0xFFFDCDA2),
        title: Text('${article.articleName}'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.edit))],
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).appBarTheme.backgroundColor),
                    height: 220,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 0, color: Colors.white),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    height: 130,
                    margin: EdgeInsets.only(top: 190),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 40),
                    child: InkWell(
                      onTap: () {
                        pushDynamicScreen(
                          context,
                          screen: MaterialPageRoute(builder: (_) {
                            return FullScreenImage(
                                image: imageFile, tag: "articolo${article.id}");
                          }),
                          withNavBar: false,
                        );
                      },
                      child: Hero(
                        tag: "articolo${article.id}",
                        child: Container(
                          width: 250,
                          height: 250,
                          child: Card(
                            clipBehavior: Clip.hardEdge,
                            child: Image.file(
                              imageFile,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              childCount: 1,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                (context, index) => Container(
                      padding: const EdgeInsets.only(left: 35, right: 35),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(width: 0, color: Colors.white)),
                      child: Column(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(width: 0.4))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Tipo Capo",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                RawChip(label: Text('${clothing[article.clothingType]}'))
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Container(
                            decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(width: 0.4))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Brand",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                RawChip(label: Text('${brands[article.brand]}'))
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Container(
                            decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(width: 0.4))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: const Text(
                                    "Colore Primario",
                                    softWrap: true,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: RawChip(
                                      label: Text(
                                          '${ColorNames.guess(article.primaryColor!)}', overflow: TextOverflow.fade),
                                      avatar: CircleAvatar(
                                        backgroundColor: article.primaryColor,
                                      ),
                                    ),
                                  ),
                                )
                              ],
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
