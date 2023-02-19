// import 'package:flutter/material.dart';
// // import 'package:flutter/cupertino.dart'; Unused Dependency
// import 'package:url_launcher/url_launcher.dart';
//
// // app build process is triggered here
// void main() => runApp(const MyApp());
//
// _sendingMails() async {
//   var url = Uri.parse("mailto:feedback@geeksforgeeks.org");
//   if (await canLaunchUrl(url)) {
//     await launchUrl(url);
//   } else {
//     throw 'Could not launch $url';
//   }
// }
//
// _sendingSMS() async {
//   var url = Uri.parse("sms:966738292");
//   if (await canLaunchUrl(url)) {
//     await launchUrl(url);
//   } else {
//     throw 'Could not launch $url';
//   }
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Geeks for Geeks'),
//           backgroundColor: Colors.green,
//         ),
//         body: SafeArea(
//           child: Center(
//             child: Column(
//               children: [
//                 Container(
//                   height: 200.0,
//                 ),
//                 const Text(
//                   'Welcome to GFG!',
//                   style: TextStyle(
//                     fontSize: 35.0,
//                     color: Colors.green,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Container(
//                   height: 20.0,
//                 ),
//                 const Text(
//                   'For any Queries, Mail us',
//                   style: TextStyle(
//                     fontSize: 18.0,
//                     color: Colors.green,
//                     //fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Container(
//                   height: 10.0,
//                 ),
//                 ElevatedButton(
//                   onPressed: _sendingMails,
//                   style: ButtonStyle(
//                     padding:
//                     MaterialStateProperty.all(const EdgeInsets.all(5.0)),
//                     textStyle: MaterialStateProperty.all(
//                       const TextStyle(color: Colors.black),
//                     ),
//                   ),
//                   child: const Text('Here'),
//                 ), // ElevatedButton
//
//                 // DEPRECATED
//                 // RaisedButton(
//                 // onPressed: _sendingMails,
//                 // child: Text('Here'),
//                 // textColor: Colors.black,
//                 // padding: const EdgeInsets.all(5.0),
//                 // ),
//                 Container(
//                   height: 20.0,
//                 ),
//                 const Text(
//                   'Or Send SMS',
//                   style: TextStyle(
//                     fontSize: 18.0,
//                     color: Colors.green,
//                     //fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Container(
//                   height: 10.0,
//                 ),
//                 ElevatedButton(
//                   onPressed: _sendingSMS,
//                   style: ButtonStyle(
//                     padding:
//                     MaterialStateProperty.all(const EdgeInsets.all(5.0)),
//                     textStyle: MaterialStateProperty.all(
//                       const TextStyle(color: Colors.black),
//                     ),
//                   ),
//                   child: const Text('Here'),
//                 ), // ElevatedButton
//
//                 // DEPRECATED
//                 // RaisedButton(
//                 // onPressed: _sendingSMS,
//                 // textColor: Colors.black,
//                 // padding: const EdgeInsets.all(5.0),
//                 // child: Text('Here'),
//                 // ), child: const Text('Here'),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URL Launcher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'URL Launcher'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _hasCallSupport = false;
  Future<void>? _launched;
  String _phone = '';

  @override
  void initState() {
    super.initState();
    // Check for phone call support.
    canLaunchUrl(Uri(scheme: 'tel', path: '123')).then((bool result) {
      setState(() {
        _hasCallSupport = result;
      });
    });
  }



  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    // onPressed calls using this URL are not gated on a 'canLaunch' check
    // because the assumption is that every device can launch a web URL.
    final Uri toLaunch =
    Uri(scheme: 'https', host: 'www.cylog.org', path: 'headers/');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                    onChanged: (String text) => _phone = text,
                    decoration: const InputDecoration(
                        hintText: 'Input the phone number to launch')),
              ),
              ElevatedButton(
                onPressed: _hasCallSupport
                    ? () => setState(() {
                  _launched = _makePhoneCall(_phone);
                })
                    : null,
                child: _hasCallSupport
                    ? const Text('Make phone call')
                    : const Text('Calling not supported'),
              ),

            ],
          ),
        ],
      ),
    );
  }
}