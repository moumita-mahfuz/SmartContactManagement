import 'package:community_app/Screens/contactListPage.dart';
import 'package:flutter/material.dart';

import '../Model/contact.dart';
import '../Widget/simpleDropDown.dart';
import 'Contact/singleContactDetailsPage.dart';

class CustomSearchDelegate extends SearchDelegate {
  final DropdownHandler dropdownHandler = DropdownHandler();
  void handleDropdownChange(String value) {
    dropdownHandler.dropdownValue = value;
    // Use the selected dropdown value as needed
    // ...
  }

  // Demo list to show querying
  List<String> searchTerms = [
    "Apple",
    "Banana",
    "Mango",
    "Pear",
    "Watermelons",
    "Blueberries",
    "Pineapples",
    "Strawberries"
  ];
  List<Contact> searchContactList = ContactListPage.allContacts;
  List<Contact> list = ContactListPage.allContacts;
  List<Contact> finalContactList = [];
  String image = 'https://scm.womenindigital.net/storage/uploads/';
  String dropdownValue = 'Name';

  bool isPresent(String name) {
    bool status = false;
    for (Contact x in ContactListPage.allContacts) {
      // print("isPresent name: ${x.name} == $name");
      if (name == x.name.toString()) {
        status = true;
      }
    }
    return status;
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      Row(
        children: [
          DropdownDemo(dropdownHandler: dropdownHandler),
          IconButton(
            onPressed: () {
              query = '';
            },
            icon: Icon(
              Icons.clear,
              color: Color(0xFF926AD3),
            ),
          ),
        ],
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        close(context, null);
      },
      icon: Icon(
        Icons.arrow_back,
        color: Color(0xFF926AD3),
      ),
    );
  }

  List<Contact> getConnectionsId(String connectionsArray) {
    List<Contact> connectionsContact = [];
    final temp = connectionsArray.split("[");
    final temp0 = temp[1].split(']');
    final contactIDs = temp0[0];
    final list = contactIDs.split(', ');
    for (Contact x in ContactListPage.allContacts) {
      if (list.contains(x.id.toString())) {
        print("inside if Name: " + x.name.toString() + x.id.toString());
        connectionsContact.add(x);
      }
    }
    return connectionsContact;
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Contact> matchContact = [];
    query = query.trimLeft();
    for (Contact x in searchContactList) {
      if (dropdownHandler.dropdownValue == 'Name') {
        if (x.name.toString().toLowerCase().contains(query.trimRight().toLowerCase())) {
          matchContact.add(x);
        }
      }
      if (dropdownHandler.dropdownValue == 'Designation') {
        if (x.designation.toString().toLowerCase().toLowerCase().contains(query.trimRight().toLowerCase())) {
          matchContact.add(x);
        }
      }
      if (dropdownHandler.dropdownValue == 'Organization') {
        if (x.organization.toString().toLowerCase().contains(query.trimRight().toLowerCase())) {
          matchContact.add(x);
        }
      }
      if (dropdownHandler.dropdownValue == 'Phone') {
        if (x.phone_no.toString().toLowerCase().contains(query.trimRight().toLowerCase())) {
          matchContact.add(x);
        }
      }
      if (dropdownHandler.dropdownValue == 'Email') {
        if (x.email.toString().toLowerCase().contains(query.trimRight().toLowerCase())) {
          matchContact.add(x);
        }
      }
      print(x.name.toString() + "  Connection ID " + x.connected_id.toString());
      if (x.connected_id?.isNotEmpty ?? true) {
        List<Contact> connectionID = getConnectionsId(x.connected_id.toString());
        for (Contact y in connectionID) {
          print("ConnectionList Item " + y.name.toString());
          if (y.name.toString().toLowerCase().contains(query.trimRight().toLowerCase())) {
            matchContact.add(x);
          }
        }
      }
    }
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: matchContact.length,
            itemBuilder: (context, index) {
              var result = matchContact[index].name.toString();
              var photo = matchContact[index].photo.toString();
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SingleContactDetailsPage(
                        contactID: matchContact[index].id!,
                        contact: matchContact[index],
                        token: ContactListPage.barerToken,
                        isChanged: false,
                      ),
                    ),
                  );
                },
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        image + photo,
                      ),
                    ),
                  ),
                  title: Text(
                    result,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Contact> matchContact = [];
    for (Contact x in searchContactList) {
      query = query.trimLeft();
      if (dropdownHandler.dropdownValue == 'Name') {
        if (x.name.toString().toLowerCase().contains(query.trimRight().toLowerCase())) {
          matchContact.add(x);
        }
      }
      if (dropdownHandler.dropdownValue == 'Designation') {
        if (x.designation.toString().toLowerCase().toLowerCase().contains(query.trimRight().toLowerCase())) {
          matchContact.add(x);
        }
      }
      if (dropdownHandler.dropdownValue == 'Organization') {
        if (x.organization.toString().toLowerCase().contains(query.trimRight().toLowerCase())) {
          matchContact.add(x);
        }
      }
      if (dropdownHandler.dropdownValue == 'Phone') {
        if (x.phone_no.toString().toLowerCase().contains(query.trimRight().toLowerCase())) {
          matchContact.add(x);
        }
      }
      if (dropdownHandler.dropdownValue == 'Email') {
        if (x.email.toString().toLowerCase().contains(query.trimRight().toLowerCase())) {
          matchContact.add(x);
        }
      }
      if (x.connected_id?.isNotEmpty ?? true) {
        List<Contact> connectionID = getConnectionsId(x.connected_id.toString());
        for (Contact y in connectionID) {
          print("ConnectionList Item " + y.name.toString());
          if (y.name.toString().toLowerCase().contains(query.trimRight().toLowerCase())) {
            matchContact.add(x);
          }
        }
      }
    }
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: ListView.builder(
        itemCount: matchContact.length,
        itemBuilder: (context, index) {
          var result = matchContact[index].name.toString();
          var photo = matchContact[index].photo.toString();
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SingleContactDetailsPage(
                    contactID: matchContact[index].id!,
                    contact: matchContact[index],
                    token: ContactListPage.barerToken,
                    isChanged: false,
                  ),
                ),
              );
            },
            child: ListTile(
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    image + photo,
                  ),
                ),
              ),
              title: Text(
                result,
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}

