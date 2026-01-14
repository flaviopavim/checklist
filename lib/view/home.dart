import 'package:checklist/widget/WidgetButton.dart';
import 'package:checklist/widget/WidgetInput.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../widget/WidgetBody.dart';
import 'cadastro.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {

  @override
  void initState() {

    getItems();

    super.initState();
  }

  List<Map<String, dynamic>> _items = [];

  /*
  List<Map<String, dynamic>> _items = [
    {
      'title': 'Item 1',
      'description': 'Descrição do item 1',
      'checked': false
    },
    {
      'title': 'Item 2',
      'description': 'Descrição do item 2',
      'checked': false
    },
    {
      'title': 'Item 3',
      'description': 'Descrição do item 3',
      'checked': false
    },
    {
      'title': 'Item 4',
      'description': 'Descrição do item 4',
      'checked': false
    },
    {
      'title': 'Item 5',
      'description': 'Descrição do item 5',
      'checked': false
    },
  ];

   */

  void getItems() async {

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

    // Get the records
    _items = await database.rawQuery('SELECT * FROM item ORDER BY id DESC');
    print(_items);

    setState(() {});

  }

  @override
  Widget build(BuildContext context) {
    return WidgetBody(
        child:Center(
        child: Column(
          children: [
            


            // Listagem de ítens
            Column(children: _items.map((item)=>GestureDetector(
              onTap: () {
                setState((){
                  item['checked'] = !item['checked'];
                });
              },
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: item['checked']=='true'?Color(0xFFDDDDDD):Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['title'],style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                              Text(item['description'], style: TextStyle(fontSize: 16.0)),
                            ],
                          )),

                          Container(
                              width: 40.0,
                              height: 40.0,
                              color: Colors.black12,
                              child: item['checked']=='true'?Icon(Icons.check):Container(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 1),
                ],
              ),
            )).toList()),



          ],
        ),
    ));
  }
}
