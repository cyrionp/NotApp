import 'dart:io';

import 'package:flutter/material.dart';
import 'package:untitled/utils/database_helper.dart';

import 'models/kategori.dart';
import 'models/notlar.dart';
import 'not_detay.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: NotListesi(),
    );
  }
}

class NotListesi extends StatelessWidget {
  DatabaseHelper databaseHelper = DatabaseHelper();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Center(
          child: Text("Not App"),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
              onPressed: () {
                kategoriEkleDialog(context);
              },
              heroTag: "KategoriEkle",
              tooltip: "Kategori Ekle",
              child: Icon(Icons.add_circle),
              mini: true),
          FloatingActionButton(
            onPressed: () => _detaySayfasinaGit(context),
            tooltip: "Not Ekle",
            heroTag: "NotEkle",
            child: Icon(Icons.add),
          ),
        ],
      ),
      body: Notlar(),
    );
  }

  Future kategoriEkleDialog(BuildContext context) {
    var formKey = GlobalKey<FormState>();
    String yeniKategoriAdi;

    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Kategori Ekle",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            children: <Widget>[
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onSaved: (yeniDeger) {
                      yeniKategoriAdi = yeniDeger;
                    },
                    decoration: InputDecoration(
                      labelText: "Kategori Adı",
                      border: OutlineInputBorder(),
                    ),
                    validator: (girilenKategoriAdi) {
                      if (girilenKategoriAdi.length < 3) {
                        return "En az 3 karakter giriniz";
                      }
                    },
                  ),
                ),
              ),
              ButtonBar(
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.blueGrey.shade300,
                    child: Text(
                      "Vazgeç",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {
                      if (formKey.currentState.validate()) {
                        formKey.currentState.save();
                        databaseHelper
                            .kategoriEkle(Kategori(yeniKategoriAdi))
                            .then((kategoriID) {
                          if (kategoriID > 0) {
                            _scaffoldKey.currentState.showSnackBar(
                              SnackBar(
                                content: Text("Kategori Eklendi"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        });
                      }
                    },
                    color: Colors.blueGrey.shade700,
                    child: Text(
                      "Kaydet",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }

  _detaySayfasinaGit(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NotDetay(
                  baslik: "Yeni Not",
            )));
  }
}

class Notlar extends StatefulWidget {
  @override
  _NotlarState createState() => _NotlarState();
}

class _NotlarState extends State<Notlar> {
  List<Not> tumNotlar;
  DatabaseHelper databaseHelper;
  @override
  void initState() {
    super.initState();
    tumNotlar = List<Not>();
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: databaseHelper.notListesiniGetir(),
      builder: (context, AsyncSnapshot<List<Not>> snapShot) {
        if (snapShot.connectionState == ConnectionState.done) {
          tumNotlar = snapShot.data;
          sleep(Duration(milliseconds: 500));
          return ListView.builder(
              itemCount: tumNotlar.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  leading: _oncelikIconuAta(tumNotlar[index].notOncelik),
                  title: Text(tumNotlar[index].notBaslik),
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Kategori",
                                  style: TextStyle(
                                      color: Colors.blueGrey.shade400),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  tumNotlar[index].kategoriBaslik,
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Oluşturulma Tarihi",
                                  style: TextStyle(
                                      color: Colors.blueGrey.shade400),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  databaseHelper.dateFormat(DateTime.parse(
                                      tumNotlar[index].notTarih)),
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "İçerik:\n\n" + tumNotlar[index].notIcerik,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          ButtonBar(
                            children: <Widget>[
                              FlatButton(
                                  onPressed: () =>
                                      _notSil(tumNotlar[index].notID),
                                  child: Text("SİL")),
                              FlatButton(
                                  onPressed: () {
                                    _detaySayfasinaGit(context, tumNotlar[index]);
                                  }, child: Text("GÜNCELLE")),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              });
        } else {
          return Center(
            child: Center(
              child: Text("Yükleniyor.."),
            ),
          );
        }
      },
    );
  }

  _detaySayfasinaGit(BuildContext context,Not not) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NotDetay(
              baslik: "Notu Düzenle",
              duzenlenecekNot:not,
            )));
  }

  _oncelikIconuAta(int notOncelik) {
    switch (notOncelik) {
      case 0:
        return CircleAvatar(
          child: Text("AZ"),
          backgroundColor: Colors.blueGrey.shade100,
        );
        break;
      case 1:
        return CircleAvatar(
          child: Text(
            "ORTA",
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          backgroundColor: Colors.blueGrey.shade300,
        );
        break;
      case 2:
        return CircleAvatar(
          child: Text("ACİL"),
          backgroundColor: Colors.blueGrey.shade700,
        );
        break;
    }
  }

  _notSil(int notID) {
    databaseHelper.notSil(notID).then((silinenID) {
      if (silinenID != 0) {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text("Not Silindi")));
        setState(() {});
      }
    });
  }
}
