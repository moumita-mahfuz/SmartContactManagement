import 'dart:io';

import 'package:flutter/material.dart';
class StaticMethods {
  static String getMonth(String monthNo) {
    String month = '';
    if (monthNo == '01') {
      month = 'January';
    } else if (monthNo == '02') {
      month = 'February';
    } else if (monthNo == '03') {
      month = 'March';
    } else if (monthNo == '04') {
      month = 'April';
    } else if (monthNo == '05') {
      month = 'May';
    } else if (monthNo == '06') {
      month = 'June';
    } else if (monthNo == '07') {
      month = 'July';
    } else if (monthNo == '08') {
      month = 'August';
    } else if (monthNo == '09') {
      month = 'September';
    } else if (monthNo == '10') {
      month = 'October';
    } else if (monthNo == '11') {
      month = 'November';
    } else if (monthNo == '12') {
      month = 'December';
    }
    return month;
  }

  static List<int> getImageBytesList (List<File> images)  {
    List<int> imageBytes = [];
    for (var image in images) {
      List<int> bytes = image.readAsBytesSync();
      imageBytes.addAll(bytes);
    }
    return imageBytes;
  }
}
// class StaticMethods extends StatelessWidget {
//   const StaticMethods({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
//
//
// }
