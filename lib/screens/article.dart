import 'package:esempio/models/article_model.dart';
import 'package:esempio/models/wardrobe_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:esempio/db/db_worker.dart';
import 'package:esempio/models/profile_model.dart';
import 'package:esempio/common/utils.dart' as utils;
import 'package:path/path.dart';
import 'dart:io';

class ColorFormField extends FormField<Color>{
  ColorFormField({
    required BuildContext context,
    FormFieldSetter<Color>? onSaved,
    FormFieldValidator<Color>? validator,
    Color initialValue = Colors.red,
    bool autovalidate = false
  }) : super(
      onSaved: onSaved,
      validator: validator,
      initialValue: initialValue,

      builder: (FormFieldState<Color> state) {
        return TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: state.value.toString()
          ),
          onTap: () async {
            var inputCol = await showColorPickerDialog(
              context,
              state.value as Color,
              title: Text('ColorPicker',
                  style: Theme.of(context).textTheme.headline6),
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
          });
      }
  );

}

class NuovoArticolo extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static XFile? imageFile;

  NuovoArticolo({Key? key}) : super(key: key);

  static Future chooseImage(ImageSource source) async {
    imageFile = await ImagePicker().pickImage(source: source);
    log(imageFile?.path ?? "");
    wardrobeModel.currentArticle!.imgPath = imageFile?.path;
  }
  
  static void _saveImage() {
    log("IN IMAGE");
    String newPath = join(utils.docsDir.path,'${wardrobeModel.currentArticle?.id}.jpg');
    imageFile?.saveTo(newPath);
    log(newPath);
  }

  _save(BuildContext context) async{
    _formKey.currentState!.save();
    
    if(wardrobeModel.currentArticle?.id == null){
      await ArticleDBWorker.articleDBWorker.create(wardrobeModel.currentArticle as ArticleModel, profile.id as int );
    }else{
      await ArticleDBWorker.articleDBWorker.update(wardrobeModel.currentArticle as ArticleModel, profile.id as int);
    }

    _saveImage();

    wardrobeModel.loadArticles(ArticleDBWorker.articleDBWorker, profile);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Aggiunto articolo correttamente"))
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                          color: Colors.pink,
                          border: Border.all(width: 0, color: Colors.pink),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      height: 130,
                      margin: EdgeInsets.only(top: 190),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 40),
                      child: InkWell(
                        /*onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                                return FullScreenImage(imageUrl: "https://picsum.photos/500?image=25", tag:"articolo");
                              })
                          );
                        },*/
                        child: Hero(
                          tag: "articolo",
                          child: Container(
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
                            color: Colors.pink,
                            border: Border.all(width: 0, color: Colors.pink)),
                        child: Column(
                          children: [
                            TextFormField(
                              textCapitalization: TextCapitalization.sentences,
                              onSaved: (input) {
                                wardrobeModel.currentArticle!.articleName =
                                    input;
                              },
                              decoration: InputDecoration(
                                  labelText: 'Titolo Articolo',
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        width: 2, color: Colors.blue),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        width: 2, color: Colors.red),
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                            SizedBox(height: 20),
                            DropdownButtonFormField(
                              hint: Text("Brand"),
                              isExpanded: true,
                              value: Brand.armani.index.toString(),
                              onSaved: (input) {
                                wardrobeModel.currentArticle!.brand =
                                    Brand.values[int.parse(input as String)];
                              },
                              onChanged: (String? newValue) {},
                              items: [
                                DropdownMenuItem(
                                    child: Text("Armani"),
                                    value: Brand.armani.index.toString()),
                                DropdownMenuItem(
                                    child: Text("Gucci"),
                                    value: Brand.gucci.index.toString()),
                                DropdownMenuItem(
                                    child: Text("Valentino"),
                                    value: Brand.valentino.index.toString()),
                                DropdownMenuItem(
                                    child: Text("Generico"),
                                    value: Brand.generico.index.toString()),
                              ],
                            ),
                            SizedBox(height: 20),
                            DropdownButtonFormField(
                              hint: Text("Tipo"),
                              isExpanded: true,
                              value: ClothingType.tshirt.index.toString(),
                              onSaved: (input) {
                                wardrobeModel.currentArticle!.clothingType =
                                    ClothingType.values[int.parse(input as String)];
                              },
                              onChanged: (String? newValue) {},
                              items: [
                                DropdownMenuItem(
                                    child: Text("T-Shirt"),
                                    value:
                                        ClothingType.tshirt.index.toString()),
                                DropdownMenuItem(
                                    child: Text("Felpa"),
                                    value: ClothingType.felpa.index.toString()),
                                DropdownMenuItem(
                                    child: Text("Maglione"),
                                    value:
                                        ClothingType.maglione.index.toString()),
                                DropdownMenuItem(
                                    child: Text("Altro"),
                                    value: ClothingType.altro.index.toString()),
                              ],
                            ),
                            SizedBox(height: 20),
                            ColorFormField(
                              context: context,
                              onSaved: (color){
                                log(color.toString());
                                wardrobeModel.currentArticle!.primaryColor = color;
                              },
                            ),
                            SizedBox(height: 20),
                            ColorFormField(
                              context: context,
                              onSaved: (color){
                                log(color.toString());
                                wardrobeModel.currentArticle!.secondaryColor = color;
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
                              color: Colors.pink,
                              border: Border.all(
                                  width: 0,
                                  color: Colors.pink,
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

  Articolo({required this.article, Key? key}) : super(key: key){
    imageFile = File(article.imgPath!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('${article.articleName}'),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.edit))
        ],
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
                        color: Colors.pink,
                        border: Border.all(width: 0, color: Colors.pink),
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
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return FullScreenImage(
                              image: imageFile,
                              tag: "articolo${article.id }");
                        }));
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
                          color: Colors.pink,
                          border: Border.all(width: 0, color: Colors.pink)),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 30),
                            decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(width: 0.4))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Tipo Capo",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('${article.clothingType}')
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 30),
                            decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(width: 0.4))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:  [
                                const Text(
                                  "Brand",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('${article.brand}')
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 30),
                            decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(width: 0.4))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Colore Primario",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('${article.primaryColor}')
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
                            color: Colors.pink,
                            border: Border.all(
                                width: 0,
                                color: Colors.pink,
                                style: BorderStyle.none))))
              ],
            ),
          ),
        ],
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
