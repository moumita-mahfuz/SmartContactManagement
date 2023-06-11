import 'package:flutter/material.dart';

class GenderDropDown extends StatefulWidget {
  TextEditingController genderController;
  String dropdownvalue;
  GenderDropDown({Key? key, required this.genderController, required this.dropdownvalue}) : super(key: key);

  @override
  State<GenderDropDown> createState() => _GenderDropDownState();
}

class _GenderDropDownState extends State<GenderDropDown> {
  FocusNode f1 = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.only(right: 15),
      //padding: EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.genderController,
              style: const TextStyle(
                  color:
                  Color(0xFF9A9A9A)), //editing controller of this TextField
              decoration: InputDecoration(
                  hintText: widget.dropdownvalue,
                  suffixIcon: _genderSuffixPopUpMenu(),
                  prefixIcon: _genderPrefixPopUpMenu(),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide:
                    BorderSide(color: Color(0xFF9A9A9A)), //<-- SEE HERE
                  ),
                  fillColor: Colors.transparent,
                  filled: true),
              readOnly: true,
              focusNode: f1,
              onTap: () {}, //Clickable and not editable
            ),
          ),
        ],
      ),
    );
  }
  Widget _genderSuffixPopUpMenu() {
    return PopupMenuButton(
      // add icon, by default "3 dot" icon
        icon: Icon(Icons.keyboard_arrow_down_rounded),
        itemBuilder: (context) {
          return [
            const PopupMenuItem<int>(
              value: 0,
              child: Text("Male"),
            ),
            const PopupMenuItem<int>(
              value: 1,
              child: Text("Female"),
            ),
          ];
        },
        onSelected: (value) {
          if (value == 0) {
            setState(() {
              widget.dropdownvalue = value.toString();
              widget.genderController.text = "Male";
              //hintText = newValue!;
            });
            print("Male is selected.");
          } else if (value == 1) {
            setState(() {
              widget.dropdownvalue = value.toString();
              widget.genderController.text = "Female";
              //hintText = newValue!;
            });
            print("Female is selected.");
          }
        });
  }

  Widget _genderPrefixPopUpMenu() {
    return PopupMenuButton(
      // add icon, by default "3 dot" icon
        icon: Icon(Icons.accessibility_new),
        itemBuilder: (context) {
          return [
            const PopupMenuItem<int>(
              value: 0,
              child: Text("Male"),
            ),
            const PopupMenuItem<int>(
              value: 1,
              child: Text("Female"),
            ),
          ];
        },
        onSelected: (value) {
          if (value == 0) {
            setState(() {
              widget.dropdownvalue = value.toString();
              widget.genderController.text = "Male";
              //hintText = newValue!;
            });
            print("Male is selected.");
          } else if (value == 1) {
            setState(() {
              widget.dropdownvalue = value.toString();
              widget.genderController.text = "Female";
              //hintText = newValue!;
            });
            print("Female is selected.");
          }
        });
  }
}
