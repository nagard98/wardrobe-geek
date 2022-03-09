import 'package:esempio/models/article_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:backdrop/backdrop.dart';
import '../common/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_colorpicker/src/material_picker.dart';


class NuovoArticolo extends StatelessWidget{
  const NuovoArticolo({Key? key}) : super(key: key);

  static Future pickImage() async{
    log("Testing camera");
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nuovo Articolo"),
        elevation: 0,
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
                    decoration: BoxDecoration(color: Theme.of(context).appBarTheme.backgroundColor),
                    height: 220,
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.pink, border: Border.all(width: 0, color: Colors.pink), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                    height: 130,
                    margin: EdgeInsets.only(top: 190),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 40),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) {
                              return FullScreenImage(imageUrl: "https://picsum.photos/500?image=25", tag:"articolo");
                            })
                        );
                      },
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
                                    onPressed: (){},
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.photo_camera),
                                        Text("Fai Foto")
                                      ]
                                    ),
                                ),
                                Text("oppure"),
                                OutlinedButton(
                                  onPressed: (){},
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.collections),
                                        Text("Scegli da Galleria")
                                      ]
                                  ),
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
                  padding: EdgeInsets.only(left: 35, top:20, right: 35),
                  decoration: BoxDecoration(
                      color: Colors.pink,
                      border: Border.all(width: 0, color: Colors.pink)
                  ),
                  child: Column(
                    children: [
                      TextField(
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                            labelText: 'Titolo Articolo',
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 2, color: Colors.blue),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 2, color: Colors.red),
                              borderRadius: BorderRadius.circular(10),
                            )
                        ),
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField(
                        hint: Text("Brand"),
                        isExpanded: true,
                        value: "Armani",
                        onChanged: (String? newValue){
                        },
                        items: [
                          DropdownMenuItem(child: Text("Armani"),value: "Armani"),
                          DropdownMenuItem(child: Text("Gucci"),value: "Gucci"),
                          DropdownMenuItem(child: Text("Valentino"),value: "Valentino"),
                          DropdownMenuItem(child: Text("Generico"),value: "Generico"),
                        ],
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField(
                        hint: Text("Tipo"),
                        isExpanded: true,
                        value: "tshirt",
                        onChanged: (String? newValue){
                        },
                        items: [
                          DropdownMenuItem(child: Text("T-Shirt"),value: "tshirt"),
                          DropdownMenuItem(child: Text("Felpa"),value: "felpa"),
                          DropdownMenuItem(child: Text("Maglione"),value: "maglione"),
                          DropdownMenuItem(child: Text("Altro"),value: "altro"),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Seleziona Colore"),
                              content: MaterialPicker(
                                pickerColor: Colors.red,
                                onColorChanged: (color){},
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Fatto"),
                                ),
                              ],
                            ),
                          ),
                          child: Text("seleziona colore primario")
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Seleziona Colore"),
                              content: MaterialPicker(
                                pickerColor: Colors.red,
                                onColorChanged: (color){},
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Fatto"),
                                ),
                              ],
                            ),
                          ),
                          child: Text("seleziona colore secondario")
                      ),
                      SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.green)
                              ),
                              child: Text("Salva Articolo"),
                              onPressed: (){},
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                childCount: 1
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Expanded(child: Container(decoration: BoxDecoration(color: Colors.pink, border: Border.all(width: 0, color: Colors.pink, style: BorderStyle.none))))
              ],
            ),
          ),
        ],
      ),
    );
  }

}



class Articolo extends StatelessWidget{
  const Articolo({Key? key, ArticleModel? articleModel}) : super(key: key);

  static Future pickImage() async{
    log("Testing camera");
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nome Articolo"),
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
                    decoration: BoxDecoration(color: Theme.of(context).appBarTheme.backgroundColor),
                    height: 220,
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.pink, border: Border.all(width: 0, color: Colors.pink), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                    height: 130,
                    margin: EdgeInsets.only(top: 190),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 40),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) {
                              return FullScreenImage(imageUrl: "https://picsum.photos/500?image=25", tag:"articolo");
                            })
                        );
                      },
                      child: Hero(
                        tag: "articolo",
                        child: Container(
                          width: 250,
                          height: 250,
                          child: Card( child: Image.network('https://picsum.photos/500?image=25', fit: BoxFit.fitHeight,),),
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
                  padding: EdgeInsets.only(left: 35, right: 35),
                  decoration: BoxDecoration(
                      color: Colors.pink,
                      border: Border.all(width: 0, color: Colors.pink)
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 30),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 0.4)
                          )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Titolo",style: TextStyle(fontWeight: FontWeight.bold),),
                            Text("Valore")
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 30),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(width: 0.4)
                            )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Titolo",style: TextStyle(fontWeight: FontWeight.bold),),
                            Text("Valore")
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 30),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(width: 0.4)
                            )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Titolo",style: TextStyle(fontWeight: FontWeight.bold),),
                            Text("Valore")
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                childCount: 1
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Expanded(child: Container(decoration: BoxDecoration(color: Colors.pink, border: Border.all(width: 0, color: Colors.pink, style: BorderStyle.none))))
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class FullScreenImage extends StatelessWidget{
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
                  )
              ),
              Material(
                child: InkWell(
                  child: Icon(Icons.close, size: 48,),
                  onTap: ()=>{Navigator.pop(context)},
                ),
                color: Colors.transparent,
              ),
            ],
          ),
        )
    );
  }

}
