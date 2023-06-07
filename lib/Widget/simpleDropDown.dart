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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              // Handle button press
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF926AD3),
              elevation: 4,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                textButtonTheme: TextButtonThemeData(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: widget.dropdownHandler.dropdownValue,
                  dropdownColor: Color(0xFF926AD3),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                  ),
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
                        child: Text(
                          value,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
