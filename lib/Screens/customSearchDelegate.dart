import 'package:community_app/Screens/contactListPage.dart';
import 'package:flutter/material.dart';

import '../Model/contact.dart';
import 'Contact/singleContactDetailsPage.dart';

class CustomSearchDelegate extends SearchDelegate {

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
  List<Contact> searchContactList = ContactListPage.contactList;
  String image = 'https://scm.womenindigital.net/storage/uploads/';

// first overwrite to
// clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear,color: Color(0xFF926AD3),),
      ),
    ];
  }

// second overwrite to pop out of search menu
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
      icon: Icon(Icons.arrow_back, color: Color(0xFF926AD3),),
    );
  }
  List<Contact> getConnectionsId(String connectionsArray) {
    //String s= '[3,23,24,01,2]';
    List<Contact> connectionsContact = [];
    final temp = connectionsArray.split("[");
    final temp0 = temp[1].split(']');
    final contactIDs = temp0[0];
    //print(contactIDs);
    final list = contactIDs.split(', ');
    for (Contact x in ContactListPage.contactList) {
      //print("Connection Name: " + x.name.toString() + x.id.toString());
      if (list.contains(x.id.toString())) {
        print("inside if Name: " + x.name.toString() + x.id.toString());
        connectionsContact.add(x);
      }
    }

    //print("connectionsContact: " + connectionsContact.toString());
    return connectionsContact;
  }

// third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    // List<String> matchQuery = [];
    // for (var fruit in searchTerms) {
    //   if (fruit.toLowerCase().contains(query.toLowerCase())) {
    //     matchQuery.add(fruit);
    //   }
    // }
    // return ListView.builder(
    //   itemCount: matchQuery.length,
    //   itemBuilder: (context, index) {
    //     var result = matchQuery[index];
    //     return ListTile(
    //       title: Text(result),
    //     );
    //   },
    // );

    List<Contact> matchContact = [];
    query = query.trimLeft();
    for (Contact x in searchContactList) {
      if (x.name.toString().toLowerCase().contains(query.trimRight().toLowerCase())) {
        matchContact.add(x);
      } else if (x.phone_no.toString().toLowerCase().contains(query.trimRight().toLowerCase())) {
        matchContact.add(x);
      } else if (x.email.toString().toLowerCase().contains(query.trimRight().toLowerCase())) {
        matchContact.add(x);
      } else if (x.designation.toString().toLowerCase().toLowerCase().contains(query.trimRight().toLowerCase())) {
        matchContact.add(x);
      } else if (x.organization.toString().toLowerCase().contains(query.trimRight().toLowerCase())) {
        matchContact.add(x);
      }
      print(x.name.toString() +"  Connection ID " + x.connected_id.toString());
      if(x.connected_id?.isNotEmpty ?? true) {
        List<Contact> connectionID = getConnectionsId(x.connected_id.toString());
        for (Contact y in connectionID) {
          print("ConnectionList Item " + y.name.toString());
          if(y.name.toString().toLowerCase().contains(query.trimRight().toLowerCase())) {
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
                        contact: matchContact[index],
                        token: ContactListPage.barerToken ,
                        isChanged: false, )));
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
              title: Text(result,style: TextStyle(color: Colors.white),),
            ),
          );
        },
      ),
    );
  }

// last overwrite to show the
// querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    List<Contact> matchContact = [];
    for (Contact x in searchContactList) {
      query = query.trimLeft();
      if(x.name.toString().toLowerCase().contains(query.trimRight().toLowerCase())) {
        matchContact.add(x);
      } else if (x.phone_no.toString().toLowerCase().contains(query.trimRight().toLowerCase())) {
        matchContact.add(x);
      } else if (x.email.toString().toLowerCase().contains(query.trimRight().toLowerCase())) {
        matchContact.add(x);
      } else if (x.designation.toString().toLowerCase().toLowerCase().contains(query.trimRight().toLowerCase())) {
        matchContact.add(x);
      } else if (x.organization.toString().toLowerCase().contains(query.trimRight().toLowerCase())) {
        matchContact.add(x);
      }
      if(x.connected_id?.isNotEmpty ?? true) {
        List<Contact> connectionID = getConnectionsId(x.connected_id.toString());
        for (Contact y in connectionID) {
          print("ConnectionList Item " + y.name.toString());
          if(y.name.toString().toLowerCase().contains(query.trimRight().toLowerCase())) {
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
                        contact: matchContact[index],
                        token: ContactListPage.barerToken ,
                          isChanged: false, )));
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
              title: Text(result,style: TextStyle(color: Colors.white),),
            ),
          );
        },
      ),
    );
    // List<String> matchQuery = [];
    // for (var fruit in searchTerms) {
    //   if (fruit.toLowerCase().contains(query.toLowerCase())) {
    //     matchQuery.add(fruit);
    //   }
    // }
    // return ListView.builder(
    //   itemCount: matchQuery.length,
    //   itemBuilder: (context, index) {
    //     var result = matchQuery[index];
    //     return ListTile(
    //       title: Text(result),
    //     );
    //   },
    // );
  }
}
