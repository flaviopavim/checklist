import 'package:flutter/material.dart';

class WidgetInput extends StatefulWidget {

  final String label;
  final TextEditingController controller;

  const WidgetInput({
    super.key,
    required this.label,
    required this.controller
  });

  @override
  _WidgetInput createState() => _WidgetInput();
}

class _WidgetInput extends State<WidgetInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label,style: TextStyle(color: Colors.white, fontSize: 18.0)),
          SizedBox(height: 5.0),
          TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white
            ),

          ),
        ],
      )
    );
  }
}