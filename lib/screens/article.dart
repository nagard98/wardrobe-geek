import 'package:esempio/models/article_model.dart';
import 'package:esempio/models/wardrobe_model.dart';
import 'package:esempio/models/your_account_model.dart';
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
import 'package:provider/provider.dart';

class NuovoArticolo extends StatefulWidget {
  NuovoArticolo({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NuovoArticoloState();
  }
}

class NuovoArticoloState extends State<NuovoArticolo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static XFile? imageFile;

  @override
  initState() {
    super.initState();
  }

  static Future chooseImage(ImageSource source) async {
    imageFile = await ImagePicker().pickImage(source: source);
    log(imageFile?.path ?? "");
    wardrobeModel.currentArticle!.imgPath = imageFile?.path;
  }

  static void _saveImage() {
    log("IN IMAGE");
    String newPath = join(
        docsDir.path, 'articles', '${uuid.v1()}.jpg');
    imageFile?.saveTo(newPath);
    wardrobeModel.currentArticle?.imgPath = newPath;
    log(newPath);
  }

  _save(BuildContext context) async {
    _formKey.currentState!.save();
    //TODO: Add validation to input
    _saveImage();

    if (wardrobeModel.currentArticle?.id == null) {
      log("current article while saving:${wardrobeModel.currentArticle?.imgPath}");
      await ArticleDBWorker.articleDBWorker.create(
          wardrobeModel.currentArticle as ArticleModel,
          personalProfile.myProfile.id as int);
    } else {
      await ArticleDBWorker.articleDBWorker.update(
          wardrobeModel.currentArticle as ArticleModel,
          personalProfile.myProfile.id as int);
    }

    wardrobeModel.loadArticles(
        ArticleDBWorker.articleDBWorker, personalProfile.myProfile);

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
      backgroundColor: const Color(0xFF425C5A),
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                const SliverAppBar(
                  foregroundColor: Color(0xFFFDCDA2),
                  title: Text("Nuovo Articolo"),
                  pinned: true,
                  snap: false,
                  floating: false,
                  expandedHeight: 100,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Stack(
                      alignment: Alignment.topCenter,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).appBarTheme.backgroundColor,),
                          height: 250,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 0, color: Colors.white),
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20))),
                          height: 80,
                          margin: const EdgeInsets.only(top: 170),
                        ),
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFDEDEDE),
                              ),
                              BoxShadow(
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
                                        const Color(0xFF76454E)),
                                    overlayColor: MaterialStateProperty.all(
                                        const Color(0xFFFDCDA2))),
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
                              const Text("oppure"),
                              OutlinedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                    foregroundColor: MaterialStateProperty.all(
                                        const Color(0xFF76454E)),
                                    overlayColor: MaterialStateProperty.all(
                                        const Color(0xFFFDCDA2))),
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
                      ],
                    ),
                    childCount: 1,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (context, index) => Container(
                            padding:
                                const EdgeInsets.only(left: 35, top: 40, right: 35),
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
                                  cursorColor: const Color(0xFFA4626D),
                                  decoration: const InputDecoration(
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
                                const SizedBox(height: 20),
                                DropdownSearch<DropdownMenuItem<int>>(
                                  dropdownSearchDecoration: const InputDecoration(
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
                                  popupTitle: const Text('Seleziona Brand'),
                                  items: _dropDownFromMap(brands),
                                  itemAsString: (item) =>
                                      (item?.child as Text).data as String,
                                  onSaved: (item) {
                                    wardrobeModel.currentArticle!.brand =
                                        item?.value;
                                  },
                                  onChanged: print,
                                ),
                                const SizedBox(height: 20),
                                DropdownSearch<DropdownMenuItem<int>>(
                                  dropdownSearchDecoration: const InputDecoration(
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
                                  popupTitle: const Text('Seleziona Tipo Capo'),
                                  items: _dropDownFromMap(clothing),
                                  itemAsString: (item) =>
                                      (item?.child as Text).data as String,
                                  onSaved: (item) {
                                    wardrobeModel.currentArticle!.clothingType =
                                        item?.value;
                                  },
                                  onChanged: print,
                                ),
                                const SizedBox(height: 20),
                                ColorFormField(
                                  text: "Colore Primario",
                                  textColor: const Color(0xFF425C5A),
                                  onSaved: (color) {
                                    log(color.toString());
                                    wardrobeModel.currentArticle!.primaryColor =
                                        color;
                                  },
                                ),
                                const SizedBox(height: 20),
                                ColorFormField(
                                  text: "Colore Secondario",
                                  textColor: const Color(0xFF425C5A),
                                  onSaved: (color) {
                                    log(color.toString());
                                    wardrobeModel.currentArticle!.secondaryColor =
                                        color;
                                  },
                                ),
                                const SizedBox(height: 80),
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
            Positioned(
              bottom: 0,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(
                          const Color(0xFFF39053))),
                  child: const Text("Salva Articolo"),
                  onPressed: () {
                    _save(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditArticolo extends StatefulWidget {
  String? articleName;
  int? brand;
  int? clothingType;
  Color? primColor;
  Color? secColor;
  String? imgPath;

  EditArticolo(ArticleModel article, {Key? key}) : super(key: key) {
    wardrobeModel.currentArticle = article;
    articleName = article.articleName;
    brand = article.brand;
    clothingType = article.clothingType;
    primColor = article.primaryColor;
    secColor = article.secondaryColor;
    imgPath = article.imgPath;
  }

  @override
  State<StatefulWidget> createState() {
    return EditArticoloState();
  }
}

class EditArticoloState extends State<EditArticolo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  XFile? imageFile;

  @override
  initState() {
    super.initState();
    log(widget.imgPath!);
    imageFile = XFile(widget.imgPath!);
  }

  Future chooseImage(ImageSource source) async {
    XFile? file = await ImagePicker().pickImage(source: source);
    setState(() {
      imageFile = file;
    });
    log(imageFile?.path ?? "");
    wardrobeModel.currentArticle!.imgPath = imageFile?.path;
  }

  void _saveImage() {
    log("IN IMAGE");
    String newPath = join(
        docsDir.path, 'articles', '${uuid.v1()}.jpg');
    imageFile?.saveTo(newPath);
    wardrobeModel.currentArticle!.imgPath = newPath;
    log(newPath);
  }

  _save(BuildContext context) async {
    _formKey.currentState!.save();
    //TODO: Add validation to input

    _saveImage();
    await ArticleDBWorker.articleDBWorker.update(
        wardrobeModel.currentArticle as ArticleModel,
        personalProfile.myProfile.id as int);

    wardrobeModel.loadArticles(
        ArticleDBWorker.articleDBWorker, personalProfile.myProfile);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Modificato articolo correttamente")));
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
      backgroundColor: const Color(0xFF425C5A),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              foregroundColor: Color(0xFFFDCDA2),
              title: Text("Modifica Articolo"),
              pinned: true,
              snap: false,
              floating: false,
              expandedHeight: 100,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).appBarTheme.backgroundColor),
                      height: 250,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(width: 0, color: Colors.white),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      height: 80,
                      margin: const EdgeInsets.only(top: 170),
                    ),
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: Image.file(File(imageFile?.path as String))
                                .image),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFDEDEDE),
                          ),
                          BoxShadow(
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
                                    const Color(0xFF76454E)),
                                overlayColor: MaterialStateProperty.all(
                                    const Color(0xFFFDCDA2))),
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
                          const Text("oppure"),
                          OutlinedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.white),
                                foregroundColor: MaterialStateProperty.all(
                                    const Color(0xFF76454E)),
                                overlayColor: MaterialStateProperty.all(
                                    const Color(0xFFFDCDA2))),
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
                  ],
                ),
                childCount: 1,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) => Container(
                        padding:
                            const EdgeInsets.only(left: 35, top: 40, right: 35),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 0, color: Colors.white)),
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: widget.articleName,
                              textCapitalization: TextCapitalization.sentences,
                              onSaved: (input) {
                                wardrobeModel.currentArticle!.articleName =
                                    input;
                              },
                              cursorColor: const Color(0xFFA4626D),
                              decoration: const InputDecoration(
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
                            const SizedBox(height: 20),
                            DropdownSearch<DropdownMenuItem<int>>(
                              dropdownSearchDecoration: const InputDecoration(
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
                              selectedItem: DropdownMenuItem<int>(
                                value: widget.brand,
                                child: Text(brands[widget.brand].toString()),
                              ),
                              mode: Mode.DIALOG,
                              popupTitle: const Text('Seleziona Brand'),
                              items: _dropDownFromMap(brands),
                              itemAsString: (item) =>
                                  (item?.child as Text).data as String,
                              onSaved: (item) {
                                wardrobeModel.currentArticle!.brand =
                                    item?.value;
                              },
                              onChanged: print,
                            ),
                            const SizedBox(height: 20),
                            DropdownSearch<DropdownMenuItem<int>>(
                              dropdownSearchDecoration: const InputDecoration(
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
                              selectedItem: DropdownMenuItem<int>(
                                value: widget.clothingType,
                                child: Text(
                                    clothing[widget.clothingType].toString()),
                              ),
                              popupTitle: const Text('Seleziona Tipo Capo'),
                              items: _dropDownFromMap(clothing),
                              itemAsString: (item) =>
                                  (item?.child as Text).data as String,
                              onSaved: (item) {
                                wardrobeModel.currentArticle!.clothingType =
                                    item?.value;
                              },
                              onChanged: print,
                            ),
                            const SizedBox(height: 20),
                            ColorFormField(
                              initialValue: widget.primColor!,
                              text: "Colore Primario",
                              textColor: const Color(0xFF425C5A),
                              onSaved: (color) {
                                log(color.toString());
                                wardrobeModel.currentArticle!.primaryColor =
                                    color;
                              },
                            ),
                            const SizedBox(height: 20),
                            ColorFormField(
                              initialValue: widget.secColor!,
                              text: "Colore Secondario",
                              textColor: const Color(0xFF425C5A),
                              onSaved: (color) {
                                log(color.toString());
                                wardrobeModel.currentArticle!.secondaryColor =
                                    color;
                              },
                            ),
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                const Color(0xFFF39053))),
                                    child: const Text("Salva Articolo"),
                                    onPressed: () {
                                      _save(context);
                                    },
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
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
  Articolo({required this.article, this.isEditable = true, Key? key})
      : super(key: key) {
    imageFile = File(article.imgPath!);
  }

  final ArticleModel article;
  late final File imageFile;
  final bool isEditable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: const Color(0xFFFDCDA2),
        title: Text('${article.articleName}'),
        actions: isEditable
            ? [
                IconButton(
                    onPressed: () {
                      pushNewScreen(context, screen: EditArticolo(article),pageTransitionAnimation: PageTransitionAnimation.slideUp);
                    },
                    icon: const Icon(Icons.edit))
              ]
            : [],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).appBarTheme.backgroundColor),
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
                        margin: const EdgeInsets.only(top: 190),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 40),
                        child: InkWell(
                          onTap: () {
                            pushDynamicScreen(
                              context,
                              screen: MaterialPageRoute(builder: (_) {
                                return FullScreenImage(
                                    image: Image.file(imageFile),
                                    tag: "articolo${article.id}");
                              }),
                              withNavBar: false,
                            );
                          },
                          child: Hero(
                            tag: "articolo${article.id}",
                            child: SizedBox(
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
                              border:
                                  Border.all(width: 0, color: Colors.white)),
                          child: Column(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                    border:
                                        Border(bottom: BorderSide(width: 0.4))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Tipo Capo",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    RawChip(
                                        label: Text(
                                            '${clothing[article.clothingType]}'))
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                    border:
                                        Border(bottom: BorderSide(width: 0.4))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Brand",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    RawChip(
                                        label: Text('${brands[article.brand]}'))
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                    border:
                                        Border(bottom: BorderSide(width: 0.4))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Flexible(
                                      flex: 2,
                                      child: Text(
                                        "Colore Primario",
                                        softWrap: true,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 3,
                                      child: RawChip(
                                        label: Text(
                                            ColorNames.guess(
                                                article.primaryColor!),
                                            overflow: TextOverflow.fade),
                                        avatar: CircleAvatar(
                                          backgroundColor: article.primaryColor,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              article.secondaryColor != Colors.transparent
                                  ? Container(
                                      decoration: const BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(width: 0.4))),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Flexible(
                                            flex: 2,
                                            child: Text(
                                              "Colore Secondario",
                                              softWrap: true,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 3,
                                            child: RawChip(
                                              label: Text(
                                                  ColorNames.guess(
                                                      article.secondaryColor!),
                                                  overflow: TextOverflow.fade),
                                              avatar: CircleAvatar(
                                                backgroundColor:
                                                    article.secondaryColor,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : const SizedBox(),
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
          Consumer<WardrobeModel>(
            builder: (context, wardrobe, child){
              return Positioned(
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 32.0,
                    child: article.favorite ?? false ? ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all(const Color(0xFFA4626D)),
                      ),
                      onPressed: () {
                        article.favorite=false;
                        wardrobe.updateArticle(ArticleDBWorker.articleDBWorker, article, personalProfile.myProfile);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.favorite),
                          Text("Rimuovi da Preferiti"),
                        ],
                      ),
                    ) : ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all(const Color(0xFFA4626D)),
                      ),
                      onPressed: () {
                        article.favorite=true;
                        wardrobe.updateArticle(ArticleDBWorker.articleDBWorker, article, personalProfile.myProfile);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.favorite_border),
                          Text("Aggiungi a Preferiti"),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
