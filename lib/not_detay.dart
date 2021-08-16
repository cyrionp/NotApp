import 'package:flutter/material.dart';
import 'package:untitled/models/kategori.dart';
import 'package:untitled/utils/database_helper.dart';

class NotDetay extends StatefulWidget {
  String baslik;
  NotDetay({this.baslik});

  @override
  _NotDetayState createState() => _NotDetayState();
}

class _NotDetayState extends State<NotDetay> {
  var formKey = GlobalKey<FormState>();
  List<Kategori> tumKategoriler;
  DatabaseHelper databaseHelper;
  int kategoriID = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumKategoriler = List<Kategori>();
    databaseHelper = DatabaseHelper();
    databaseHelper.kategorileriGetir().then((kategorileriIcerenMapListesi) {
      for (Map okunanMap in kategorileriIcerenMapListesi) {
        tumKategoriler.add(Kategori.fromMap(okunanMap));
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.baslik),
      ),
      body: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              Center(
                child: Container(
                  child:DropdownButtonHideUnderline(
                  child: tumKategoriler.length <= 0
                      ? CircularProgressIndicator()
                      : DropdownButton<int>(
                            items: kategoriItemleriOlustur(),
                            value: kategoriID,
                            onChanged: (secilenKategoriID) {
                              setState(() {
                                kategoriID = secilenKategoriID;
                              });
                            }),
                      ),
                  padding: EdgeInsets.symmetric(vertical: 4,horizontal: 48),
                  margin: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color:Colors.redAccent,width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              )
            ],
          )),
    );
  }

  List<DropdownMenuItem<int>> kategoriItemleriOlustur() {
    return tumKategoriler
        .map((kategori) => DropdownMenuItem<int>(
              value: kategori.kategoriID,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(kategori.kategoriBaslik,style: TextStyle(fontSize: 24),),
              ),
            ))
        .toList();
  }
}
