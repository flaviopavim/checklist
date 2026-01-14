import 'package:flutter/material.dart';

import '../view/cadastro.dart';
import '../view/home.dart';
import 'WidgetButton.dart';

class WidgetBody extends StatefulWidget {

  final Widget child;

  const WidgetBody({
    super.key,
    required this.child
  });

  @override
  _WidgetBody createState() => _WidgetBody();
}

class _WidgetBody extends State<WidgetBody> {

  bool menuOpened = false;

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery
        .of(context)
        .padding
        .top;

    return Scaffold(
        backgroundColor: Color(0xFFEEEEEE),
        body: Stack(children: [

          // Barra do topo
          Positioned(
            top: 0,
            height: statusBarHeight,
            child: Container(
                color: Colors.black12
            ),
          ),

          // Navbar
          Positioned(
            left: 0,
            top: statusBarHeight,
            right: 0,
            height: 60.0,
            child: Container(
                color: Colors.white,
                child: Row(children: [
                  SizedBox(width: 15.0),
                  Expanded(
                      child: Text('Checklist', style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.w700))
                  ),

                  // Botão do menu
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        menuOpened = !menuOpened;
                      });
                    },
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      color: Color(0xFFEEEEEE),
                      child: Icon(Icons.menu),
                    ),
                  ),

                  SizedBox(width: 5.0),
                ])
            ),
          ),


          // Conteúdo
          Positioned(
              top: (60.0 + statusBarHeight),
              right: 0,
              left: 0,
              height: MediaQuery
                  .of(context)
                  .size
                  .height - (60.0 + statusBarHeight),
              child: Container(
                color: Colors.grey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: widget.child,
                ),
              )
          ),


          // Menu
          AnimatedPositioned(
            duration: Duration(milliseconds: 200),
            top: (60.0 + statusBarHeight),
            right: menuOpened ? 0 : -180.0,
            width: 180.0,
            height: 600.0,
            child: Container(
              color: Color(0xFFF3F3F3),
              child: Column(children: [


                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 50.0,
                      color: Colors.white,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => Home())
                          );
                        },
                          child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.home, size: 18.0),
                                    SizedBox(width: 5.0),
                                    Text('Início'),
                                  ],
                                ),
                              )
                          )
                      ),
                    ),
                    SizedBox(height: 1),
                  ],
                ),



                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 50.0,
                      color: Colors.white,
                      child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => Cadastro())
                            );
                          },
                          child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.plus_one, size: 18.0),
                                    SizedBox(width: 5.0),
                                    Text('Cadastro'),
                                  ],
                                ),
                              )
                          )
                      ),
                    ),
                    SizedBox(height: 1),
                  ],
                ),




              ]),
            ),
          ),

        ])
    );
  }
}