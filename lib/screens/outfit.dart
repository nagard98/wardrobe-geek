import 'dart:io';
import 'package:esempio/db/outfit_db_worker.dart';
import 'package:esempio/models/myoutfits_model.dart';
import 'package:esempio/models/outfit_model.dart';
import 'package:esempio/models/wardrobe_model.dart';
import 'package:esempio/models/wishlist_model.dart';
import 'package:esempio/models/your_account_model.dart';
import 'package:esempio/screens/wardrobe.dart';
import 'package:esempio/screens/wardrobe_select.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer';
import 'package:esempio/common/utils.dart' as utils;
import 'package:path/path.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:esempio/models/article_model.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:esempio/models/explore_model.dart';
import 'package:morpheus/morpheus.dart';
import 'package:esempio/screens/article.dart';
import 'package:provider/provider.dart';

class Outfit extends StatelessWidget {
  final String heroTag;
  final OutfitModel outfit;
  final Section section;
  final bool isEditable;

  const Outfit(
      {Key? key,
      required this.outfit,
      required this.heroTag,
      required this.section,
      this.isEditable = false})
      : super(key: key);

  void _handleTap(BuildContext context, GlobalKey parentKey,
      ArticleModel article, bool isEditable) {
    Navigator.of(context).push(MorpheusPageRoute(
      transitionColor: const Color(0xFF425C5A),
      builder: (context) => Articolo(
        article: article,
        isEditable: isEditable,
      ),
      parentKey: parentKey,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MyOutfitsModel>.value(value: myOutfitsModel),
        ChangeNotifierProvider<WishlistModel>.value(value: wishlistModel)
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFF425C5A),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              foregroundColor: const Color(0xFFFDCDA2),
              title: const Text("Nome Outfit"),
              actions: [
                //TODO: implementa editing outfit
                isEditable
                    ? IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) {
                              return NuovoOutfit(
                                outfitToEdit: outfit,
                              );
                            }),
                          );
                        },
                        icon: const Icon(Icons.edit))
                    : const SizedBox()
              ],
              pinned: true,
              snap: false,
              floating: false,
              expandedHeight: 100,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Stack(
                  alignment: Alignment.topLeft,
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).appBarTheme.backgroundColor,
                      ),
                      height: 200,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(width: 0, color: Colors.white),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      height: 100,
                      margin: const EdgeInsets.only(top: 230),
                    ),
                    Row(
                      children: [
                        Flexible(
                          flex: 7,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                    width: 0, color: Colors.transparent)),
                            child: InkWell(
                              child: SizedBox(
                                height: 285,
                                child: Hero(
                                  tag: heroTag,
                                  child: Card(
                                    clipBehavior: Clip.hardEdge,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.zero,
                                            topRight: Radius.circular(20),
                                            bottomLeft: Radius.zero,
                                            bottomRight: Radius.circular(20))),
                                    margin: EdgeInsets.zero,
                                    child: Image.file(
                                      //TODO:Crea mosaico se manca
                                      File(outfit.imgPath.toString()),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () {
                                pushDynamicScreen(
                                  context,
                                  screen: MaterialPageRoute(builder: (_) {
                                    return utils.FullScreenImage(
                                        image: Image.file(File(outfit.imgPath.toString())),
                                        tag: heroTag);
                                  }),
                                  withNavBar: false,
                                );
                              },
                            ),
                          ),
                        ),
                        Flexible(
                            fit: FlexFit.tight,
                            flex: 8,
                            child: Column(
                              children: [
                                Text(
                                  "Stagione: ${seasons[outfit.season]}",
                                  style:
                                      const TextStyle(color: Color(0xFFFDCDA2)),
                                ),
                                Text(
                                    "Dress Code:  ${dressCodes[outfit.dressCode]}",
                                    style: const TextStyle(
                                        color: Color(0xFFFDCDA2))),
                                Text(
                                    "Designer: ${personalProfile.myProfile.name} ${personalProfile.myProfile.surname}",
                                    style: const TextStyle(
                                        color: Color(0xFFFDCDA2)))
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
                  (context, index) => Consumer2<MyOutfitsModel, WishlistModel>(
                          builder: (context, outfits, wishlist, child) {
                        return Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(width: 0, color: Colors.white)),
                            padding: EdgeInsets.fromLTRB(16, 4, 16, 32),
                            child: section == Section.myoutfits
                                ? (outfit.favorite ?? false
                                    ? ElevatedButton(
                                        //TODO: implementa aggiunta preferiti outfit
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  const Color(0xFFA4626D)),
                                        ),
                                        onPressed: () {
                                          outfit.favorite = false;
                                          outfits.currentOutfit = outfit;
                                          outfits.updateOutfit(
                                              OutfitDBWorker.outfitDBWorker,
                                              outfit,
                                              personalProfile.myProfile);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.favorite),
                                            Text("Rimuovi da Preferiti")
                                          ],
                                        ),
                                      )
                                    : ElevatedButton(
                                        //TODO: implementa aggiunta preferiti outfit
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  const Color(0xFFA4626D)),
                                        ),
                                        onPressed: () {
                                          outfit.favorite = true;
                                          outfits.currentOutfit = outfit;
                                          outfits.updateOutfit(
                                              OutfitDBWorker.outfitDBWorker,
                                              outfit,
                                              personalProfile.myProfile);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.favorite_border),
                                            Text("Aggiungi a Preferiti")
                                          ],
                                        ),
                                      ))
                                : outfit.isWishlisted ?? false
                                    ? ElevatedButton(
                                        //TODO: implementa aggiunta a wishlist outfit
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  const Color(0xFFA4626D)),
                                        ),
                                        onPressed: () {
                                          outfit.isWishlisted = false;
                                          wishlist.removeOutfit(
                                              OutfitDBWorker.outfitDBWorker,
                                              outfit.id!,
                                              personalProfile.myProfile);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.bookmark_remove),
                                            Text("Rimuovi da Wishlist")
                                          ],
                                        ),
                                      )
                                    : ElevatedButton(
                                        //TODO: implementa aggiunta a wishlist outfit
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  const Color(0xFFA4626D)),
                                        ),
                                        onPressed: () {
                                          outfit.isWishlisted = true;
                                          wishlist.addOutfit(
                                              OutfitDBWorker.outfitDBWorker,
                                              outfit,
                                              personalProfile.myProfile,
                                              withReload: true);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.bookmark_add),
                                            Text("Aggiungi a Wishlist")
                                          ],
                                        ),
                                      ));
                      }),
                  childCount: 1),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) => Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 0, color: Colors.white)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding:
                                  EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 6.0),
                              child: Text("Outfit Composto da:"),
                            ),
                            GridView.builder(
                              padding: const EdgeInsets.only(
                                  left: 16.0, right: 16.0),
                              primary: false,
                              itemCount: outfit.articles?.length,
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                childAspectRatio: 3.5,
                              ),
                              itemBuilder: (context, indexGrid) {
                                final _parentKey = GlobalKey();
                                return GestureDetector(
                                  key: _parentKey,
                                  onTap: () => _handleTap(context, _parentKey,
                                      outfit.articles![indexGrid], isEditable),
                                  child: Card(
                                    shape: const RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: Color(0xFF425C5A))),
                                    color: const Color(0xFF425C5A),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          fit: FlexFit.tight,
                                          flex: 1,
                                          child: Image.file(
                                            File(join(
                                                utils.docsDir.path,
                                                'articles',
                                                outfit.articles?[indexGrid]
                                                    .imgPath)),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Flexible(
                                          flex: 2,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        8.0, 2, 8, 2),
                                                child: Text(
                                                    clothing[outfit
                                                            .articles?[
                                                                indexGrid]
                                                            .clothingType]
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color:
                                                            Color(0xFFFDCDA2))),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        8.0, 2, 8, 2),
                                                child: Text(
                                                    brands[outfit
                                                            .articles?[
                                                                indexGrid]
                                                            .brand]
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color:
                                                            Color(0xFFFDCDA2))),
                                              ),
                                            ],
                                          ),
                                        ),
/*                                    const Expanded(
                                          flex: 1,
                                          child: SizedBox(),
                                        ),
                                        const Expanded(
                                          flex: 2,
                                          child: SizedBox(),
                                        )*/
                                      ],
                                    ),
                                  ),
                                );
                              },
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
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            width: 2,
                            color: Colors.white,
                            style: BorderStyle.solid),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleListFormField extends FormField<List<ArticleModel>> {
  ArticleListFormField(
      {Key? key,
      required BuildContext context,
      FormFieldSetter<List<ArticleModel>>? onSaved,
      FormFieldValidator<List<ArticleModel>>? validator,
      List<ArticleModel> initialValue = const [],
      bool autovalidate = false})
      : super(
            key: key,
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            builder: (FormFieldState<List<ArticleModel>> state) {
              return Container(
                padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: const Color(0xFF425C5A),
                    ),
                    borderRadius: BorderRadius.circular(4.0)),
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                              child: TextField(
                            decoration: InputDecoration(
                                label: Text("Articoli"),
                                labelStyle: TextStyle(color: Color(0xFF425C5A)),
                                border: InputBorder.none),
                          )),
                          Flexible(
                            child: IconButton(
                              tooltip: "Add",
                              icon: const Icon(Icons.add_circle_outline),
                              color: const Color(0xFFA4626D),
                              onPressed: () async {
                                List selectedIds = await Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return WardrobeSelect(
                                    isSelectionMode: true,
                                  );
                                }));
                                log("ID selezionati");
                                log(selectedIds.toString());
                                ArticleModel? _article;
                                wardrobeModel.articles?.forEach((article) {
                                  for (var _id in selectedIds) {
                                    if (article.id == _id) {
                                      _article = article;
                                    }
                                  }
                                });
                                var currentArticles = [...?state.value];
                                if (_article != null) {
                                  currentArticles.add(_article!);
                                }
                                state.didChange(currentArticles);
                                log(currentArticles.toString());
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    if (state.value?.isNotEmpty ?? false)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.value?.length,
                            itemBuilder: (context, index) {
                              log(index.toString());
                              return SizedBox(
                                width: 120,
                                child: Card(
                                  shape: const RoundedRectangleBorder(),
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: IconButton(
                                          onPressed: () {
                                            var currentArticles = [
                                              ...?state.value
                                            ];
                                            currentArticles.removeAt(index);
                                            state.didChange(currentArticles);
                                          },
                                          icon: const Icon(Icons.close),
                                        ),
                                      ),
                                      Flexible(
                                          flex: 2,
                                          child: Image.file(
                                            File(state.value![index].imgPath!),
                                          )),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      )
                  ],
                ),
              );
            });
}

class NuovoOutfit extends StatefulWidget {
  NuovoOutfit({Key? key, OutfitModel? outfitToEdit}) : super(key: key) {
    myOutfitsModel.currentOutfit = outfitToEdit ?? OutfitModel();
  }

  @override
  State<StatefulWidget> createState() {
    return NuovoOutfitState();
  }
}

class NuovoOutfitState extends State<NuovoOutfit> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  XFile? imageFile;
  late List selectedOutfitIds;

  @override
  initState() {
    super.initState();
    selectedOutfitIds = [];
    imageFile = myOutfitsModel.currentOutfit?.id == null
        ? null
        : XFile(myOutfitsModel.currentOutfit?.imgPath as String);
  }

  Future chooseImage(ImageSource source) async {
    XFile? file = await ImagePicker().pickImage(source: source);
    setState(() {
      imageFile = file;
    });
    log(imageFile?.path ?? "");
    myOutfitsModel.currentOutfit!.imgPath = imageFile?.path;
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

  void _saveImage() {
    log("IN IMAGE");
    String newPath =
        join(utils.docsDir.path, 'outfits', '${utils.uuid.v1()}.jpg');
    imageFile?.saveTo(newPath);
    myOutfitsModel.currentOutfit?.imgPath = newPath;
    log(newPath);
  }

  _save(BuildContext context) async {
    _formKey.currentState!.save();
    //TODO: Add validation to input
    /*myOutfitsModel.currentOutfit?.favorite = false;
    myOutfitsModel.currentOutfit?.likes = 0;*/

    _saveImage();

    if (myOutfitsModel.currentOutfit?.id == null) {
      await OutfitDBWorker.outfitDBWorker.create(
          myOutfitsModel.currentOutfit as OutfitModel,
          personalProfile.myProfile.id as int);
    } else {
      await OutfitDBWorker.outfitDBWorker.update(
          myOutfitsModel.currentOutfit as OutfitModel,
          personalProfile.myProfile.id as int);
    }

    myOutfitsModel.loadOutfits(
        OutfitDBWorker.outfitDBWorker, personalProfile.myProfile);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
        //TODO: controllare successo operazione
        const SnackBar(content: Text("Aggiunto outfit correttamente")));
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
                  title: Text("Nuovo Outfit"),
                  pinned: true,
                  snap: false,
                  floating: false,
                  expandedHeight: 100,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).appBarTheme.backgroundColor),
                          height: 280,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 0, color: Colors.white),
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20))),
                          height: 100,
                          margin: const EdgeInsets.only(top: 180),
                        ),
                        Container(
                          width: 220,
                          height: 280,
                          child: Container(
                            decoration: BoxDecoration(
                              image: imageFile == null
                                  ? null
                                  : DecorationImage(
                                      image: Image.file(
                                              File(imageFile?.path as String))
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
                        ),
                      ],
                    ),
                    childCount: 1,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (context, index) => Container(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(width: 0, color: Colors.white)),
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                DropdownSearchField(
                                  labelText: 'Stagione',
                                  popUpTitle: 'Seleziona Stagione',
                                  items: seasons,
                                  selectedItem:
                                      myOutfitsModel.currentOutfit!.id == null
                                          ? null
                                          : DropdownMenuItem<int>(
                                              value: myOutfitsModel
                                                  .currentOutfit?.season,
                                              child: Text(seasons[myOutfitsModel
                                                      .currentOutfit?.season]
                                                  .toString()),
                                            ),
                                  onSaved: (item) {
                                    log(item.toString());
                                    myOutfitsModel.currentOutfit!.season =
                                        item?.value;
                                  },
                                ),
                                const SizedBox(height: 20),
                                DropdownSearchField(
                                  labelText: 'Dress Code',
                                  popUpTitle: 'Seleziona Dress Code',
                                  selectedItem:
                                      myOutfitsModel.currentOutfit!.id == null
                                          ? null
                                          : DropdownMenuItem<int>(
                                              value: myOutfitsModel
                                                  .currentOutfit?.dressCode,
                                              child: Text(dressCodes[
                                                      myOutfitsModel
                                                          .currentOutfit
                                                          ?.dressCode]
                                                  .toString()),
                                            ),
                                  items: dressCodes,
                                  onSaved: (item) {
                                    myOutfitsModel.currentOutfit!.dressCode =
                                        item?.value;
                                  },
                                ),
                                const SizedBox(height: 20),
                                ArticleListFormField(
                                  context: context,
                                  initialValue:
                                      myOutfitsModel.currentOutfit?.articles ??
                                          [],
                                  onSaved: (articles) {
                                    log(articles.toString());
                                    myOutfitsModel.currentOutfit?.articles =
                                        articles;
                                  },
                                ),
                                const SizedBox(height: 60,)
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
                          Colors.green)),
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

class SelezioneArticoli extends StatelessWidget {
  SelezioneArticoli({Key? key}) : super(key: key);

  Widget getChild(String imagePath, String title) {
    return SizedBox(
        width: 150,
        height: 150,
        child: Card(
          shape: const RoundedRectangleBorder(),
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
          ),
        ));
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
        title: const Text('Seleziona Articoli'),
        foregroundColor: const Color(0xFFFDCDA2),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop(selectedIds);
              },
              icon: const Icon(Icons.check))
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

class DropdownSearchField extends StatefulWidget {
  DropdownSearchField(
      {Key? key,
      required this.labelText,
      required this.popUpTitle,
      required this.items,
      required this.onSaved,
      this.selectedItem})
      : super(key: key);

  DropdownMenuItem<int>? selectedItem;
  String labelText;
  String popUpTitle;
  Map<int, String> items;
  Function(DropdownMenuItem<int>?) onSaved;

  @override
  State<StatefulWidget> createState() {
    return DropdownSearchFieldState();
  }
}

class DropdownSearchFieldState extends State<DropdownSearchField> {
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

  DropdownMenuItem<int>? _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedItem == null) {
      return DropdownSearch<DropdownMenuItem<int>>(
          dropdownSearchDecoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: const TextStyle(color: Color(0xFF425C5A)),
              isDense: true,
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFDCDA2), width: 2.0)),
              contentPadding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF425C5A)))),
          showSearchBox: true,
          mode: Mode.DIALOG,
          popupTitle: Text(widget.popUpTitle),
          items: _dropDownFromMap(widget.items),
          itemAsString: (item) => (item?.child as Text).data as String,
          onSaved: widget.onSaved,
          onChanged: (item) {
            _selectedItem = item;
          });
    } else {
      return DropdownSearch<DropdownMenuItem<int>>(
        dropdownSearchDecoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: const TextStyle(color: Color(0xFF425C5A)),
            isDense: true,
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFDCDA2), width: 2.0)),
            contentPadding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF425C5A)))),
        showSearchBox: true,
        selectedItem: _selectedItem,
        mode: Mode.DIALOG,
        popupTitle: Text(widget.popUpTitle),
        items: _dropDownFromMap(widget.items),
        itemAsString: (item) => (item?.child as Text).data as String,
        onSaved: widget.onSaved,
        onChanged: (item) {
          _selectedItem = item;
        },
      );
    }
  }
}
