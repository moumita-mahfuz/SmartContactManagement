import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../Model/contact.dart';

class listPage extends StatefulWidget {
  const listPage({Key? key}) : super(key: key);

  @override
  State<listPage> createState() => _listPageState();
}

class _listPageState extends State<listPage> {
  List<Contact> items = [];

  Future _refresh() async {
    setState(() {
      items.clear();
    });
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://scm.womenindigital.net/api/${prefs.getInt('loginID')}/allConnections';

    final response = await http.get(Uri.parse(url), headers: {
      "Accept": 'application/json',
      'Authorization': 'Bearer ${prefs.getString('token')}'
    });
    var data = jsonDecode(response.body.toString());
    // print(response.body.toString());
    if (response.statusCode == 200) {
      for (Map i in data) {
        // print("photo:   $i['photo']");
        //print("name "+ i['name']);
        //bool status = isPresent(i['name']);
        // if (status == false) {
        //   //tempList.add(Contact.fromJson(i));
        //
        //
        // }
        setState(() {
          items.add(Contact.fromJson(i));
        });
      }

      //print("ContactListPage Contact List: ${ContactListPage.contactList}");
      //return ContactListPage.contactList;
    } else {
      //return ContactListPage.contactList;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          itemCount: items.length,
            itemBuilder: (context, index) {
            //final item = ;
            return Text(items[index].name.toString());

        }),
      ),
    );
  }
}

