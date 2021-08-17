import 'package:flutter/material.dart';
import 'package:untitled/main.dart';
import 'package:untitled/models/kategori.dart';
import 'package:untitled/utils/database_helper.dart';

import 'models/notlar.dart';

class NotDetay extends StatefulWidget {
  String baslik;
  Not duzenlenecekNot;

  NotDetay({this.baslik, this.duzenlenecekNot});

  @override
  _NotDetayState createState() => _NotDetayState();
}

class _NotDetayState extends State<NotDetay> {
  var formKey = GlobalKey<FormState>();
  List<Kategori> tumKategoriler;
  DatabaseHelper databaseHelper;
  int kategoriID;
  int secilenOncelik;
  String notBaslik, notIcerik;
  static var _oncelik = ["Düşük", "Orta", "Yüksek"];

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

      if(widget.duzenlenecekNot!=null){
        kategoriID=widget.duzenlenecekNot.kategoriID;
        secilenOncelik=widget.duzenlenecekNot.notOncelik;
      }else{
        kategoriID=1;
        secilenOncelik=0;
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(widget.baslik),
      ),
      body: tumKategoriler.length <= 0
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "Kategori: ",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.blueGrey, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              items: kategoriItemleriOlustur(),
                              value: kategoriID,
                              onChanged: (secilenKategoriID) {
                                setState(() {
                                  kategoriID = secilenKategoriID;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        textInputAction: TextInputAction.done,
                        initialValue: widget.duzenlenecekNot != null
                            ? widget.duzenlenecekNot.notBaslik
                            : "",
                        validator: (text) {
                          if (text.length < 2) {
                            return "En az 2 karakter olmalı";
                          }
                        },
                        onSaved: (text) {
                          notBaslik = text;
                        },
                        decoration: InputDecoration(
                          hintText: "Not başlığını giriniz",
                          labelText: "Başlık",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        textInputAction: TextInputAction.done,
                        initialValue: widget.duzenlenecekNot != null
                            ? widget.duzenlenecekNot.notIcerik
                            : "",
                        onSaved: (text) {
                          notIcerik = text;
                        },
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Not içeriğini giriniz",
                          labelText: "İçerik",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "Öncelik: ",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.blueGrey, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              items: _oncelik.map((oncelik) {
                                return DropdownMenuItem<int>(
                                  child: Text(
                                    oncelik,
                                    style: TextStyle(fontSize: 24),
                                  ),
                                  value: _oncelik.indexOf(oncelik),
                                );
                              }).toList(),
                              value: secilenOncelik,
                              onChanged: (secilenOncelikID) {
                                setState(() {
                                  secilenOncelik = secilenOncelikID;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Vazgeç"),
                          color: Colors.blueGrey.shade200,
                        ),
                        RaisedButton(
                          onPressed: () {
                            if (formKey.currentState.validate()) {
                              formKey.currentState.save();

                              var now = DateTime.now();
                              if (widget.duzenlenecekNot == null) {
                                databaseHelper
                                    .notEkle(Not(
                                        kategoriID,
                                        notBaslik,
                                        notIcerik,
                                        now.toString(),
                                        secilenOncelik))
                                    .then((kaydedilenNotID) {
                                  if (kaydedilenNotID != 0) {
                                    print("Kaydetme çalıştı ve pop oldu");
                                    Navigator.pop(context);
                                  }
                                });
                              } else {
                                databaseHelper.notGuncelle(Not.withID(
                                    widget.duzenlenecekNot.notID,
                                    kategoriID,
                                    notBaslik,
                                    notIcerik,
                                    now.toString(),
                                    secilenOncelik)).then((guncellenenID){
                                      if(guncellenenID!=0){
                                        Navigator.pop(context);
                                      }
                                });
                              }
                            }
                          },
                          child: Text("Kaydet"),
                          color: Colors.blueGrey.shade700,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  List<DropdownMenuItem<int>> kategoriItemleriOlustur() {
    return tumKategoriler
        .map((kategori) => DropdownMenuItem<int>(
              value: kategori.kategoriID,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  kategori.kategoriBaslik,
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ))
        .toList();
  }
}
