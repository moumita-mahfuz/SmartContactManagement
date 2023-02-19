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

// first overwrite to
// clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

// second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
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
    for (Contact x in searchContactList) {
      if (x.name.toString().toLowerCase().contains(query.toLowerCase())) {
        matchContact.add(x);
      } else if (x.phone_no.toString().toLowerCase().contains(query.toLowerCase())) {
        matchContact.add(x);
      } else if (x.email.toString().toLowerCase().contains(query.toLowerCase())) {
        matchContact.add(x);
      } else if (x.designation.toString().toLowerCase().toLowerCase().contains(query.toLowerCase())) {
        matchContact.add(x);
      } else if (x.organization.toString().toLowerCase().contains(query.toLowerCase())) {
        matchContact.add(x);
      }
    }
    return ListView.builder(
      itemCount: matchContact.length,
      itemBuilder: (context, index) {
        var result = matchContact[index].name.toString();
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

// last overwrite to show the
// querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    List<Contact> matchContact = [];
    for (Contact x in searchContactList) {
      if(x.name.toString().toLowerCase().contains(query.toLowerCase())) {
        matchContact.add(x);
      } else if (x.phone_no.toString().toLowerCase().contains(query.toLowerCase())) {
        matchContact.add(x);
      } else if (x.email.toString().toLowerCase().contains(query.toLowerCase())) {
        matchContact.add(x);
      } else if (x.designation.toString().toLowerCase().toLowerCase().contains(query.toLowerCase())) {
        matchContact.add(x);
      } else if (x.organization.toString().toLowerCase().contains(query.toLowerCase())) {
        matchContact.add(x);
      }
    }

    return ListView.builder(
      itemCount: matchContact.length,
      itemBuilder: (context, index) {
        var result = matchContact[index].name.toString();
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SingleContactDetailsPage(contact: matchContact[index]                                                                                                                                                                                 ,)));
          },
          child: ListTile(
            title: Text(result),
          ),
        );
      },
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
