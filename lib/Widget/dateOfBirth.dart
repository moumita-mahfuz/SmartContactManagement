import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateOfBirth extends StatefulWidget {
  TextEditingController dobController;
  String hintText;
  Icon icon;

  DateOfBirth({Key? key, required this.dobController, required this.hintText, required this.icon}) : super(key: key);

  @override
  State<DateOfBirth> createState() => _DateOfBirthState();
}

class _DateOfBirthState extends State<DateOfBirth> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: widget.dobController,
        style: const TextStyle(
            color: Color(0xFF9A9A9A)), //editing controller of this TextField
        decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: widget.icon,
            suffixIcon: Icon(Icons.calendar_month_rounded),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF9A9A9A)), //<-- SEE HERE
            ),
            fillColor: Colors.transparent,
            filled: true),
        readOnly: true, // when true user cannot edit text
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(), //get today's date
              firstDate: DateTime(1950,
                  1), //DateTime.now() - not to allow to choose before today.
              lastDate: DateTime(2101));

          if (pickedDate != null) {
            print(
                pickedDate); //get the picked date in the format => 2022-07-04 00:00:00.000
            String formattedDate = DateFormat('yyyy-MM-dd').format(
                pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
            print(
                formattedDate); //formatted date output using intl package =>  2022-07-04
            //You can format date as per your need

            setState(() {
              widget.dobController.text =
                  formattedDate; //set foratted date to TextField value.
            });
          } else {
            print("Date is not selected");
          }
        },
      ),
    );
  }
}
