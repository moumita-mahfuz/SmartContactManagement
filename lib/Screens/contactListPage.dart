import 'dart:convert';
import 'package:community_app/Screens/User/userProfile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mailto/mailto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Model/contact.dart';
import '../Widget/bezierContainer.dart';
import 'Auth/loginPage.dart';
import 'Contact/singleContactDetailsPage.dart';
import 'customSearchDelegate.dart';
import 'Contact/newContactAddPage.dart';

class ContactListPage extends StatefulWidget {
  final String token;
  static List<Contact> contactList = [];
  static List<Contact> c = [];
  const ContactListPage({Key? key, required this.token}) : super(key: key);
  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  bool isFabVisible = true;
  bool _customTileExpanded = false;

  String image = 'https://scm.womenindigital.net/storage/uploads/';

  bool _hasCallSupport = false;
  Future<void>? _launched;
  //https://scm.womenindigital.net/storage/uploads/202302120406-Twitter-logo-png.png

  @override
  void initState() {
    // initializing states
    super.initState();
    getUserDetailsApi();
    canLaunchUrl(Uri(scheme: 'tel', path: '123')).then((bool result) {
      setState(() {
        _hasCallSupport = result;
      });
    });
  }

  Future<List<Contact>> getContactListApi() async {
    ContactListPage.contactList.clear();
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
        bool status = isPresent(i['name']);
        if (status == false) {
          //tempList.add(Contact.fromJson(i));
          ContactListPage.contactList.add(Contact.fromJson(i));
        }
      }

      //print("ContactListPage Contact List: ${ContactListPage.contactList}");
      return ContactListPage.contactList;
    } else {
      return ContactListPage.contactList;
    }
  }

  bool isPresent(String name) {
    bool status = false;
    for (Contact x in ContactListPage.contactList) {
      // print("isPresent name: ${x.name} == $name");
      if (name == x.name.toString()) {
        status = true;
      }
    }
    return status;
  }

  Widget? _designationText(String des) {
    if (des == 'null') {
      return null;
    } else {
      return InkWell(
        child: Text(
          des,
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }

  void logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('Bearer ${prefs.getString('token')}');
      Response response = await post(
        Uri.parse('http://scm.womenindigital.net/api/auth/logout'),
        headers: {'Authorization': 'Bearer ${prefs.getString('token')}'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        prefs.setBool('isLoggedIn', false);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: ((context) => LoginPage())));

        print('Logout successfully');
      } else {
        print('failed${response.statusCode}');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Widget _listView() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(left: 10, right: 10),
      //margin: EdgeInsets.only(top: 32),
      child: FutureBuilder(
        future: getContactListApi(),
        builder: (context, AsyncSnapshot<List<Contact>> snapshot) {
          //print(snapshot.data.toString());
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          } else {
            snapshot.data!.sort((a, b) {
              return a.name
                  .toString()
                  .toLowerCase()
                  .compareTo(b.name.toString().toLowerCase());
            });
            return ListView.builder(
              key: UniqueKey(),
              itemCount: ContactListPage.contactList.length,
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.transparent,
                  child: ExpansionTile(
                    backgroundColor: Colors.transparent,
                    collapsedBackgroundColor: Colors.transparent,
                    //image+snapshot.data![index].photo.toString()
                    leading: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SingleContactDetailsPage(
                                    contact: snapshot.data![index])));
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: Image.network(
                          image + snapshot.data![index].photo.toString(),
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // leading: const Icon(
                    //   Icons.person,
                    //   size: 56.0,
                    // ),
                    title: Text(snapshot.data![index].name.toString()),
                    //subtitle: Text(snapshot.data![index].designation.toString()),
                    subtitle: _designationText(
                        snapshot.data![index].designation.toString()),
                    children: <Widget>[
                      Column(
                        children: [

                          Container(
                              alignment: Alignment.bottomLeft,
                              child: _moreButton(snapshot.data![index])),
                        ],
                      ),
                      // ListTile(
                      //   title: Text('This is tile number 1'),
                      //   subtitle: InkWell(
                      //     onTap: () {
                      //       Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //               builder: (context) => SingleContactDetailsPage()));
                      //     },
                      //       child: Text('see details'),
                      //
                      //   ),
                      //   //trailing: Icon(Icons.more_vert),
                      // ),
                    ],
                  ),
                );
              },
              // children: <Widget>[
              //   Card(
              //     child: ExpansionTile(
              //       leading: Icon(
              //         Icons.person,
              //         size: 56.0,
              //       ),
              //       title: Text('Jhon Deo'),
              //       subtitle: Text('XYZ Limited'),
              //       children: <Widget>[
              //         // ListTile(
              //         //   title: Text('This is tile number 1'),
              //         //   subtitle: Text('Here is a second line'),
              //         //     onTap: () {
              //         //       Navigator.push(context,
              //         //           MaterialPageRoute(builder: (context) => SingleContactDetailsPage()));
              //         //     },
              //         //   //trailing: Icon(Icons.more_vert),
              //         // ),
              //         Row(
              //           children: [
              //             _socialMediaLinks('', "assets/images/facebook.png"),
              //             _socialMediaLinks('', "assets/images/facebook.png"),
              //             _socialMediaLinks('', "assets/images/facebook.png"),
              //           ],
              //         ),
              //         Row(
              //           children: [
              //             _moreButton(),
              //           ],
              //         ),
              //       ],
              //     ),
              //   ),
              //
              // ],
            );
          }
        },
      ),
    );
  }
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Widget _socialMediaLinks(String link, String imageAddress) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
        child: Image.asset(
          imageAddress,
          height: 35,
          width: 35,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }

  _sendingSMS(String phone) async {
    var url = Uri.parse(phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _moreButton(Contact contact) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Divider(
              color: Colors.white
          ),
          Row(
            children: [
              //FAVOURITE
              InkWell(
                  onTap: () {},
                  child: const Icon(
                    Icons.star_border_rounded,
                    color: Colors.white,
                  )),
              const SizedBox(
                width: 15,
              ),
              //EMAIL
              InkWell(
                onTap: () {
                  if (contact.email?.isEmpty ?? true) {
                    setState(() {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        backgroundColor: Color(0xFF926AD3),
                        content: Text(
                          "eMail address is not saved!",
                          style: TextStyle(fontSize: 14),
                        ),
                        duration: Duration(milliseconds: 1000),
                      ));
                    });
                  } else {
                    final mailtoLink = Mailto(
                      to: [contact.email!],
                      //cc: ['cc1@example.com', 'cc2@example.com'],
                      //subject: 'mailto example subject',
                      //body: 'mailto example body',
                    );
                    // Convert the Mailto instance into a string.
                    // Use either Dart's string interpolation
                    // or the toString() method.
                    launch('$mailtoLink');
                  }
                },
                child: const Icon(
                  Icons.email_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              //CALL
              InkWell(
                onTap:
                (_hasCallSupport && (contact.phone_no?.isNotEmpty ?? false))
                    ? () => setState(() {
                  _launched = _makePhoneCall(contact.phone_no!);
                })
                    : ()=> setState(() {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    backgroundColor: Color(0xFF926AD3),
                    content: Text(
                      "Phone number is not saved!",
                      style: TextStyle(fontSize: 14),
                    ),
                    duration: Duration(milliseconds: 1000),
                  ));
                }),
                child: Icon(
                  Icons.call,
                  color: Colors.white,
                ),
              ),
              // ElevatedButton(
              //   onPressed: _hasCallSupport
              //       ? () => setState(() {
              //             _launched = _makePhoneCall(widget.contact.phone_no!);
              //           })
              //       : null,
              //   child: _hasCallSupport
              //       ? const Text('Make phone call')
              //       : const Text('Calling not supported'),
              // ),
              const SizedBox(
                width: 15,
              ),
              //MASSAGE
              InkWell(
                onTap: () {
                  if (contact.phone_no?.isEmpty ?? true) {
                    setState(() {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        backgroundColor: Color(0xFF926AD3),
                        content: Text(
                          "Phone number is not saved!",
                          style: TextStyle(fontSize: 14),
                        ),
                        duration: Duration(milliseconds: 1000),
                      ));
                    });
                  } else {
                    _sendingSMS(contact.phone_no!);
                  }
                },
                child: const Icon(
                  Icons.message,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 5,),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SingleContactDetailsPage(contact: contact)));
                },
                child: Text ("View Details"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _floatingActionButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewContactAddPage(
                      contactList: ContactListPage.contactList,
                    )));
      },
      child: isFabVisible
          ? FloatingActionButton(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF926AD3),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewContactAddPage(
                              contactList: ContactListPage.contactList,
                            )));
              },
              child: const Icon(Icons.person_add_alt_1_rounded),
            )
          : null,
    );
  }

  Future<void> getUserDetailsApi() async {
    final prefs = await SharedPreferences.getInstance();

    ///api/user/10/show
    String url =
        'http://scm.womenindigital.net/api/user/${prefs.getInt('loginID')}/show';

    final response = await http.get(Uri.parse(url), headers: {
      "Accept": 'application/json',
      'Authorization': 'Bearer ${prefs.getString('token')}'
    });
    var data = jsonDecode(response.body.toString());
    print("${response.statusCode} $data");
    if (response.statusCode == 200) {
      for (Map i in data) {
        print("name " + i['name']);
        //bool status = isPresent(i['name']);
        // if(status== false) {
        //   //tempList.add(Contact.fromJson(i));
        //   ContactListPage.contactList.add(Contact.fromJson(i));
        // }
        ContactListPage.c.add(Contact.fromJson(i));
      }
    } else {}
  }

  Widget _customCircularIndicator() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        //automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            showSearch(
                context: context,
                // delegate to customize the search bar
                delegate: CustomSearchDelegate());
          },
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 35,
                  decoration: BoxDecoration(
                    color: const Color(0xFF926AD3),
                    border:
                        Border.all(width: 2, color: const Color(0xFF926AD3)),
                    borderRadius: BorderRadius.circular(100), //<-- SEE HERE
                  ),
                  child: Row(
                    children: const [
                      SizedBox(
                        width: 15,
                      ),
                      Icon(Icons.search_rounded),
                      SizedBox(
                        width: 10,
                      ),
                      Center(
                          child: Text(
                        "Search",
                        style: TextStyle(fontSize: 14),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          PopupMenuButton(
              // add icon, by default "3 dot" icon
              icon: const Icon(
                Icons.more_vert_rounded,
                color: Colors.white,
              ),
              itemBuilder: (context) {
                return [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Row(
                      children: const [
                        Icon(
                          Icons.person,
                          color: Color(0xFF926AD3),
                        ),
                        Text(" My Account"),
                      ],
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: Row(
                      children: const [
                        Icon(
                          Icons.settings,
                          color: Color(0xFF926AD3),
                        ),
                        Text(" Settings"),
                      ],
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 2,
                    child: Row(
                      children: const [
                        Icon(
                          Icons.logout,
                          color: Color(0xFF926AD3),
                        ),
                        Text(" Logout"),
                      ],
                    ),
                  ),
                ];
              },
              onSelected: (value) async {
                if (value == 0) {
                  if (kDebugMode) {
                    print("My account menu is selected.");
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => UserProfilePage(
                                user: ContactListPage.c[0],
                              ))));
                } else if (value == 1) {
                  if (kDebugMode) {
                    print("Settings menu is selected.");
                  }
                } else if (value == 2) {
                  // final prefs = await SharedPreferences.getInstance();
                  // prefs.setBool('isLoggedIn',false);
                  // Navigator.pushReplacement(context, MaterialPageRoute(builder: ((context) => LoginPage())));
                  logout();
                  if (kDebugMode) {
                    print("Logout menu is selected.");
                  }
                }
              }),
        ],
      ),
      body: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: <Widget>[
            SafeArea(
              child: Container(
                color: Colors.transparent,
                //margin: EdgeInsets.only(top: 20),
                padding: const EdgeInsets.only(left: 10, right: 10),
                //margin: EdgeInsets.only(top: 32),
                child: FutureBuilder(
                  future: getContactListApi(),
                  builder: (context, AsyncSnapshot<List<Contact>> snapshot) {
                    //print(snapshot.data.toString());
                    if (!snapshot.hasData) {
                      return Center(
                          child: const CircularProgressIndicator(
                        color: Colors.white,
                      ));
                    } else {
                      snapshot.data!.sort((a, b) {
                        return a.name
                            .toString()
                            .toLowerCase()
                            .compareTo(b.name.toString().toLowerCase());
                      });
                      return ListView.builder(
                        key: UniqueKey(),
                        itemCount: ContactListPage.contactList.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return ExpansionTile(
                            leading: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SingleContactDetailsPage(contact: snapshot.data![index])));
                              },
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(
                                    image +
                                        snapshot.data![index].photo.toString(),
                                  ),
                                ),
                              ),
                            ),
                            // leading: Container(
                            //   color: Colors.transparent,
                            //   padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                            //   decoration: BoxDecoration(
                            //     borderRadius:
                            //   ),
                            //   child: Image.network(
                            //     image + snapshot.data![index].photo.toString(),
                            //     width: 56,
                            //     height: 56,
                            //     fit: BoxFit.cover,
                            //   ),
                            // ),

                            title: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SingleContactDetailsPage(
                                                  contact:
                                                      snapshot.data![index])));
                                },
                                child: Text(
                                  snapshot.data![index].name.toString(),
                                  style: const TextStyle(color: Colors.white),
                                )),
                            subtitle: _designationText(
                                snapshot.data![index].phone_no.toString()),
                            children: <Widget>[
                              Column(
                                children: [
                                  Container(
                                      alignment: Alignment.bottomLeft,
                                      child:
                                          _moreButton(snapshot.data![index])),
                                ],
                              ),
                              // ListTile(
                              //   title: Text('This is tile number 1'),
                              //   subtitle: InkWell(
                              //     onTap: () {
                              //       Navigator.push(
                              //           context,
                              //           MaterialPageRoute(
                              //               builder: (context) => SingleContactDetailsPage()));
                              //     },
                              //       child: Text('see details'),
                              //
                              //   ),
                              //   //trailing: Icon(Icons.more_vert),
                              // ),
                            ],
                          );
                        },
                        // children: <Widget>[
                        //   Card(
                        //     child: ExpansionTile(
                        //       leading: Icon(
                        //         Icons.person,
                        //         size: 56.0,
                        //       ),
                        //       title: Text('Jhon Deo'),
                        //       subtitle: Text('XYZ Limited'),
                        //       children: <Widget>[
                        //         // ListTile(
                        //         //   title: Text('This is tile number 1'),
                        //         //   subtitle: Text('Here is a second line'),
                        //         //     onTap: () {
                        //         //       Navigator.push(context,
                        //         //           MaterialPageRoute(builder: (context) => SingleContactDetailsPage()));
                        //         //     },
                        //         //   //trailing: Icon(Icons.more_vert),
                        //         // ),
                        //         Row(
                        //           children: [
                        //             _socialMediaLinks('', "assets/images/facebook.png"),
                        //             _socialMediaLinks('', "assets/images/facebook.png"),
                        //             _socialMediaLinks('', "assets/images/facebook.png"),
                        //           ],
                        //         ),
                        //         Row(
                        //           children: [
                        //             _moreButton(),
                        //           ],
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        //
                        // ],
                      );
                    }
                  },
                ),
              ),
            ),
            Positioned(bottom: 20, right: 20, child: _floatingActionButton()),
          ],
        ),
      ),
    );
  }

// @override
// Widget build(BuildContext context) {
//   final height = MediaQuery.of(context).size.height;
//   return Scaffold(
//     appBar: AppBar(
//       title: _title(),
//       automaticallyImplyLeading: false,
//       actions: [
//         IconButton(
//           onPressed: () {
//             // method to show the search bar
//             showSearch(
//                 context: context,
//                 // delegate to customize the search bar
//                 delegate: CustomSearchDelegate());
//           },
//           icon: const Icon(Icons.search),
//         ),
//         PopupMenuButton(
//             // add icon, by default "3 dot" icon
//             // icon: Icon(Icons.book)
//             itemBuilder: (context) {
//           return [
//             PopupMenuItem<int>(
//               value: 0,
//               child: Text("My Account"),
//             ),
//             PopupMenuItem<int>(
//               value: 1,
//               child: Text("Settings"),
//             ),
//             PopupMenuItem<int>(
//               value: 2,
//               child: Text("Logout"),
//             ),
//           ];
//         }, onSelected: (value) async {
//           if (value == 0) {
//             print("My account menu is selected.");
//           } else if (value == 1) {
//             print("Settings menu is selected.");
//           } else if (value == 2) {
//             // final prefs = await SharedPreferences.getInstance();
//             // prefs.setBool('isLoggedIn',false);
//             // Navigator.pushReplacement(context, MaterialPageRoute(builder: ((context) => LoginPage())));
//             logout();
//             print("Logout menu is selected.");
//           }
//         }),
//       ],
//     ),
//     body: NotificationListener<UserScrollNotification>(
//       onNotification: (notification) {
//         if (notification.direction == ScrollDirection.forward) {
//           if (!isFabVisible) setState(() => isFabVisible = true);
//         } else if (notification.direction == ScrollDirection.reverse) {
//           if (isFabVisible) setState(() => isFabVisible = false);
//         }
//         return true;
//       },
//       child: SingleChildScrollView(
//         child: Stack(
//           children: <Widget>[
//             Positioned(
//                 top: -height * .15,
//                 right: -MediaQuery.of(context).size.width * .4,
//                 child: BezierContainer()),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   // SizedBox(height: height * .1),
//                   //_title(),
//                   SizedBox(height: 15),
//                   //  _emailPasswordWidget(),
//                   _listView(),
//                   SizedBox(height: 20),
//
//                   //SizedBox(height: height * .055),
//                 ],
//               ),
//             ),
//             Positioned(bottom: 20, right: 20, child: _floatingActionButton()),
//             //Positioned(top: 40, left: 0, child: _backButton()),
//           ],
//         ),
//       ),
//     ),
//   );
// }
}
// Future<List<Contact>> getContactListApi() async {
//   final prefs = await SharedPreferences.getInstance();
//   // final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//   // final loginID = prefs.getInt('loginID') ?? false;
//   // final token = prefs.getString('token') ?? false;
//   //http://scm.womenindigital.net/api/4/allConnections
//   String url = 'http://scm.womenindigital.net/api/' +
//       prefs.getInt('loginID').toString() +
//       '/allConnections';
//   print(url +" "+ 'Bearer ' + prefs.getString('token').toString());
//   // Response response = await post(
//   //   Uri.parse(url),
//   //   headers: {
//   //     "Accept" : 'application/json',
//   //     'Authorization': 'Bearer ' + prefs.getString('token').toString()
//   //   },
//   // );
//   final response =await http.get(Uri.parse(url));
//   //final response = await http.get(Uri.parse(url));
//   var data = jsonDecode(response.body.toString());
//   print("check" + response.body.toString() +" "+ response.statusCode.toString());
//   if (response.statusCode == 200) {
//     print(response.statusCode.toString() + data);
//     for (Map i in data) {
//       print(i['name']);
//       contactList.add(Contact.fromJson(i));
//     }
//     return contactList;
//   }
//   else {
//     print(response.statusCode.toString());
//     return contactList;
//   }
// }
