import 'package:checklist/view/home.dart';
import 'package:checklist/widget/WidgetBody.dart';
import 'package:checklist/widget/WidgetButton.dart';
import 'package:checklist/widget/WidgetInput.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});
  @override
  State<Cadastro> createState() => _Cadastro();
}

class _Cadastro extends State<Cadastro> {

  final controllerTitle = TextEditingController();
  final controllerDescription = TextEditingController();
  final controllerAmount = TextEditingController();
  final controllerPrice = TextEditingController();


  void cadastrar() async {

    String title=controllerTitle.text;
    String description=controllerDescription.text;
    int amount=int.parse(controllerAmount.text);
    int price=int.parse(controllerPrice.text);

    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = '${databasesPath}checklist-1.0.0.db';

    // Delete the database
    //await deleteDatabase(path);

    // open the database
    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
              'CREATE TABLE item (id INTEGER PRIMARY KEY, title TEXT, description TEXT, amount INTEGER, price INTEGER, checked INTEGER)');
        });

    // Insert some records in a transaction
    await database.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO item (title, description, amount, price) VALUES("$title", "$description", "$amount", "$price")');
      print('inserted1: $id1');
    });

    Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Home())
    );

  }

  @override
  Widget build(BuildContext context) {
    return WidgetBody(
        child: Column(children: [




            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(children: [
                Text('Cadastro de ítem'),


                WidgetInput(label: 'Título', controller: controllerTitle),
                WidgetInput(label: 'Description', controller: controllerDescription),
                WidgetInput(label: 'Quantidade', controller: controllerAmount),
                WidgetInput(label: 'Preço', controller: controllerPrice),

                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                      onTap: () {
                        cadastrar();
                      },
                      child: WidgetButton(text: 'Cadastrar')
                  ),
                ),




              ]),
            ),






        ])
    );
  }
}