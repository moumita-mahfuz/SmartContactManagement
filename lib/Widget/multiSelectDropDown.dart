import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Multi Select widget
// This widget is reusable
class MultiSelect extends StatefulWidget {
  final List<String> items;
  final List<String> checkedItems;
  const MultiSelect({Key? key, required this.items, required this.checkedItems})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  // this variable holds the selected items
  final List<String> _selectedItems = [];

// This function is triggered when a checkbox is checked or unchecked
  void _itemChange(String itemValue, bool isSelected) {
    if (kDebugMode) {
      print("$itemValue : $isSelected");
    }
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
        widget.checkedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
        widget.checkedItems.remove(itemValue);
      }
    });
  }

  // this function is called when the Cancel button is pressed
  void _cancel() {
    Navigator.pop(context);
  }

// this function is called when the Submit button is tapped
  void _submit() {
    Navigator.pop(context, widget.checkedItems);
  }

  @override
  Widget build(BuildContext context) {
    MaterialColor myColor = const MaterialColor(0xFF926AD3, <int, Color>{
      50: Color(0xFF926AD3),
      100: Color(0xFF926AD3),
      200: Color(0xFF926AD3),
      300: Color(0xFF926AD3),
      400: Color(0xFF926AD3),
      500: Color(0xFF926AD3),
      600: Color(0xFF926AD3),
      700: Color(0xFF926AD3),
      800: Color(0xFF926AD3),
      900: Color(0xFF926AD3),
    },
    );
    return AlertDialog(
      title: const Text('Select Contact',
        style: TextStyle(color: Color(0xFF926AD3)),),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items
              .map((item) => Theme(
                data:  ThemeData(
                  primarySwatch: myColor,
                  unselectedWidgetColor: myColor, // Your color
                ),
                child: CheckboxListTile(
                      // List<String>data= ["Mathew","Deon","Sara","Yeu"];
                      // List<String> userChecked = [];
                      // value: userChecked.contains(data[i]),
                      value: _selectedItems.contains(item),
                      selected: widget.checkedItems.contains(item),
                      title: Text(item),
                      key: Key(item),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (isChecked) => {_itemChange(item, isChecked!)},
                    ),
              ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

// // Implement a multi select on the Home screen
// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   List<String> _selectedItems = [];
//
//   void _showMultiSelect() async {
//     // a list of selectable items
//     // these items can be hard-coded or dynamically fetched from a database/API
//     final List<String> items = [
//       'Flutter',
//       'Node.js',
//       'React Native',
//       'Java',
//       'Docker',
//       'MySQL',
//       'option 1',
//       'Option 2',
//       'Option 3',
//       'option 1',
//       'Option 2',
//       'Option 3'
//     ];
//
//     final List<String>? results = await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return MultiSelect(items: items);
//       },
//     );
//
//     // Update UI
//     if (results != null) {
//       setState(() {
//         _selectedItems = results;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('KindaCode.com'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // use this button to open the multi-select dialog
//             ElevatedButton(
//               onPressed: _showMultiSelect,
//               child: const Text('Select Your Favorite Topics'),
//             ),
//             const Divider(
//               height: 30,
//             ),
//             // display selected items
//             Wrap(
//               children: _selectedItems
//                   .map((e) => Chip(
//                         label: Text(e),
//                       ))
//                   .toList(),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
