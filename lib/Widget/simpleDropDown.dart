import 'package:flutter/material.dart';

class DropdownHandler {
  String dropdownValue = 'Name';
  Function(String?) onDropdownChanged = (value) {};

  void handleDropdownChange(String? value) {
    dropdownValue = value ?? '';
    onDropdownChanged(value);
  }
}

class DropdownDemo extends StatefulWidget {
  final DropdownHandler dropdownHandler;

  DropdownDemo({required this.dropdownHandler});

  @override
  _DropdownDemoState createState() => _DropdownDemoState();
}

class _DropdownDemoState extends State<DropdownDemo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF926AD3)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.dropdownHandler.dropdownValue,
          icon: Icon(Icons.arrow_drop_down, color: Color(0xFF926AD3),),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(color: Color(0xFF926AD3), fontSize: 16),
          onChanged: (newValue) {
            setState(() {
              widget.dropdownHandler.handleDropdownChange(newValue);
            });
          },
          items: <String>[
            'Name',
            'Designation',
            'Organization',
            'Phone',
            'Email'
          ].map<DropdownMenuItem<String>>(
                (String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
