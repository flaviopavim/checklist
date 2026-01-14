import 'package:flutter/material.dart';

class WidgetButton extends StatefulWidget {

  final String text;

  const WidgetButton({
    super.key,
    required this.text
  });

  @override
  _WidgetButton createState() => _WidgetButton();
}

class _WidgetButton extends State<WidgetButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(4.0)
    ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        child: Text(widget.text,style: TextStyle(color: Colors.white,fontSize: 18)),
      ),
    );
  }
}