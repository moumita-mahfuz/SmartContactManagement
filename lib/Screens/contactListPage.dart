import 'dart:convert';
import 'package:community_app/Screens/AlphabeticScrollView.dart';
import 'package:community_app/Screens/Auth/settingsPage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mailto/mailto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Model/User.dart';
import '../Model/contact.dart';
import 'Auth/loginPage.dart';
import 'Contact/singleContactDetailsPage.dart';
import 'Group/groupListPage.dart';
import 'User/userProfilePage.dart';
import 'customSearchDelegate.dart';
import 'Contact/newContactAddPage.dart';
import 'package:get/get.dart'  hide Response, FormData, MultipartFile;

class ContactListPage extends StatefulWidget {
  final String token;
  static List<Contact> contactList = [];
  static List<Contact> favouriteList = [];
  static List<User> user = [];
  static String barerToken = '';
  const ContactListPage({Key? key, required this.token}) : super(key: key);
  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  bool isFabVisible = true;
  bool _customTileExpanded = false;
  bool _isFav = false;

  String image = 'https://scm.womenindigital.net/storage/uploads/';

  bool _hasCallSupport = false;
  bool _nullMassage = false;
  late Future<List<Contact>> futureContactList;
  late Future<List<Contact>> futureFavouriteList;
  Future<void>? _launched;
  //https://scm.womenindigital.net/storage/uploads/202302120406-Twitter-logo-png.png

  @override
  void initState() {
    // initializing states
    super.initState();
    futureContactList = getContactListApi();
    FocusManager.instance.primaryFocus?.unfocus();
    //futureFavouriteList = getFavouriteListApi();
    getUserDetailsApi();
    canLaunchUrl(Uri(scheme: 'tel', path: '123')).then((bool result) {
      setState(() {
        _hasCallSupport = result;
      });
    });
  }

  Future<List<Contact>> getContactListApi() async {
    setState(() {
      ContactListPage.contactList.clear();
      ContactListPage.favouriteList.clear();
    });
    final prefs = await SharedPreferences.getInstance();
    ContactListPage.barerToken = 'Bearer ${prefs.getString('token')}';
    String url =
        'https://scm.womenindigital.net/api/${prefs.getInt('loginID')}/allConnections';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        "Accept": 'application/json',
        'Authorization': 'Bearer ${prefs.getString('token')}'
      });
      var data = jsonDecode(response.body.toString());
       print(response.body.toString());
      if (response.statusCode == 200) {
        for (Map i in data) {
          // print("photo:   $i['photo']");
          // print("STATUS " + i['favourite']);
          //print("name " + i['name']);
          bool status = isPresent(i['name']);
          if (status == false) {
            //tempList.add(Contact.fromJson(i));
            ContactListPage.contactList.add(Contact.fromJson(i));
            bool favStatus = isFavourite(i['favourite']);
            if (favStatus == true) {
              setState(() {
                ContactListPage.favouriteList.add(Contact.fromJson(i));
              });
            }
          }
          // setState(() {
          //   ContactListPage.contactList.add(Contact.fromJson(i));
          // });
        }

        //print("ContactListPage Contact List: ${ContactListPage.contactList}");
        //return ContactListPage.contactList;
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   backgroundColor: Color(0xFF926AD3),
        //   content: Text(
        //     "Error Code: " + response.statusCode.toString() + "!",
        //     style: TextStyle(fontSize: 14),
        //   ),
        //   duration: Duration(milliseconds: 2000),
        // ));
        Get.snackbar(
          "Error Code: " + response.statusCode.toString() + "!",
          "Please check your internet connection!",
          colorText: Colors.white,
          //icon: Icon(Icons.person, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Color(0xFF926AD3),
          duration: Duration(seconds: 4),
          isDismissible: true,
        );
      }
    } on Exception catch (e) {
      // TODO
      Get.snackbar(
        "Network Issue",
        "Please check your internet connection!",
        colorText: Colors.white,
        //icon: Icon(Icons.person, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF926AD3),
        duration: Duration(seconds: 4),
        isDismissible: true,
      );
      print(e.toString());
    }
    if (futureContactList.toString().isEmpty) {
      _nullMassage = true;
    }
    return ContactListPage.contactList;
  }

  bool isFavourite(String status) {
    if (status == 'true') {
     // print(status);
      return true;
    } else {
      //print(status);
      return false;
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
        Uri.parse('https://scm.womenindigital.net/api/auth/logout'),
        headers: {'Authorization': 'Bearer ${prefs.getString('token')}'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        prefs.setBool('isLoggedIn', false);
        Get.offAll(LoginPage());
        // Navigator.pushReplacement(
        //     context, MaterialPageRoute(builder: ((context) => LoginPage())));

        print('Logout successfully');
      } else {
        print('failed${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        "Network Issue",
        "Please check your internet connection!",
        colorText: Colors.white,
        //icon: Icon(Icons.person, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF926AD3),
        duration: Duration(seconds: 4),
        isDismissible: true,
      );
      print(e.toString());
    }
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
    Uri url = Uri.parse('sms:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _moreButton(Contact contact) {
    String favourite = contact.favourite.toString();
    bool status = false;
    if (favourite == 'true') {
      status = true;
    } else {
      status = false;
    }
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          Divider(color: Colors.white),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //menus
              Row(
                children: [
                  //FAVOURITE
                  // InkWell(
                  //     onTap: () {
                  //       setState(() {
                  //         print("BEFORE "+ status.toString());
                  //         status = !status;
                  //         print("AFTER "+ status.toString());
                  //         _updateStatusApi(contact.id.toString(), status.toString());
                  //       });
                  //       print("Favorite Tapped !");
                  //     },
                  //     child: (status) ? (Icon(Icons.star_rate_rounded, color: Colors.white)) : (Icon(Icons.star_border_rounded, color: Colors.white)),
                  //     ),

                  const SizedBox(
                    width: 15,
                  ),
                  //EMAIL
                  InkWell(
                    onTap: () {
                      if (contact.email?.isEmpty ?? true) {
                        setState(() {
                          // ScaffoldMessenger.of(context)
                          //     .showSnackBar(const SnackBar(
                          //   backgroundColor: Color(0xFF926AD3),
                          //   content: Text(
                          //     "eMail address is not saved!",
                          //     style: TextStyle(fontSize: 14),
                          //   ),
                          //   duration: Duration(milliseconds: 1000),
                          // ));
                          Get.snackbar(
                            "Warning",
                            "Email address is not saved!",
                            colorText: Colors.white,
                            //icon: Icon(Icons.person, color: Colors.white),
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Color(0xFF926AD3),
                            duration: Duration(seconds: 4),
                            isDismissible: true,
                          );
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
                    onTap: (_hasCallSupport &&
                            (contact.phone_no?.isNotEmpty ?? false))
                        ? () => setState(() {
                              _launched = _makePhoneCall(contact.phone_no!);
                            })
                        : () => setState(() {
                              // ScaffoldMessenger.of(context)
                              //     .showSnackBar(const SnackBar(
                              //   backgroundColor: Color(0xFF926AD3),
                              //   content: Text(
                              //     "Phone number is not saved!",
                              //     style: TextStyle(fontSize: 14),
                              //   ),
                              //   duration: Duration(milliseconds: 1000),
                              // ));
                      Get.snackbar(
                        "Warning",
                        "Phone number is not saved!",
                        colorText: Colors.white,
                        //icon: Icon(Icons.person, color: Colors.white),
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Color(0xFF926AD3),
                        duration: Duration(seconds: 4),
                        isDismissible: true,
                      );
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
                          // ScaffoldMessenger.of(context)
                          //     .showSnackBar(const SnackBar(
                          //   backgroundColor: Color(0xFF926AD3),
                          //   content: Text(
                          //     "Phone number is not saved!",
                          //     style: TextStyle(fontSize: 14),
                          //   ),
                          //   duration: Duration(milliseconds: 1000),
                          // ));
                          Get.snackbar(
                            "Warning",
                            "Phone number is not saved!",
                            colorText: Colors.white,
                            //icon: Icon(Icons.person, color: Colors.white),
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Color(0xFF926AD3),
                            duration: Duration(seconds: 4),
                            isDismissible: true,
                          );
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
                  SizedBox(
                    width: 5,
                  ),
                ],
              ),

              ElevatedButton(
                onPressed: () {
                  // Get.to(SingleContactDetailsPage(
                  //   contact: contact,
                  //   token: ContactListPage.barerToken,
                  //   isChanged: false,
                  // ));
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => SingleContactDetailsPage(
                  //         contact: contact,
                  //         token: ContactListPage.barerToken,
                  //         isChanged: false,
                  //       ),
                  //     ));
                },
                child: Text("View Details"),
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
        Get.to(NewContactAddPage(
          contactList: ContactListPage.contactList,
        ));
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => NewContactAddPage(
        //               contactList: ContactListPage.contactList,
        //             )));
      },
      child: isFabVisible
          ? FloatingActionButton(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF926AD3),
              onPressed: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => NewContactAddPage(
                //               contactList: ContactListPage.contactList,
                //             )));
                Get.to(NewContactAddPage(
                  contactList: ContactListPage.contactList,
                ));
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => NewContactAddPage(
                //               contactList: ContactListPage.contactList,
                //             )));
              },
              child: const Icon(Icons.person_add_alt_1_rounded),
            )
          : null,
    );
  }

  Future<void> getUserDetailsApi() async {
    ContactListPage.user.clear();
    final prefs = await SharedPreferences.getInstance();

    ///api/user/10/show
    String url =
        'https://scm.womenindigital.net/api/user/${prefs.getInt('loginID')}/show';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        "Accept": 'application/json',
        'Authorization': 'Bearer ${prefs.getString('token')}'
      });
      var data = jsonDecode(response.body.toString());
      print("${response.statusCode} $data");
      if (response.statusCode == 200) {
        for (Map i in data) {
          print("name " + i['name']);
          ContactListPage.user.add(User(
            id: i['id'],
            name: i['name'],
            photo: i['photo'],
            designation: i['designation'],
            organization: i['organization'],
            phone_no: i['phone_no'],
            email: i['email'],
            date_of_birth: i['date_of_birth'],
            gender: i['gender'],
            address: i['address'],
            social_media: i['social_media'],
            note: i['note'],
          ));

          //bool status = isPresent(i['name']);
          // if(status== false) {
          //   //tempList.add(Contact.fromJson(i));
          //   ContactListPage.contactList.add(Contact.fromJson(i));
          // }
          // ContactListPage.user.add(User.fromJson(i));
        }
      } else {}
    } catch (e) {
      // TODO
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   backgroundColor: Color(0xFF926AD3),
      //   content: Text(
      //     '$e!',
      //     style: TextStyle(fontSize: 14),
      //   ),
      //   duration: Duration(milliseconds: 2000),
      // ));
      Get.snackbar(
        "Network Issue",
        "Please check your internet connection!",
        colorText: Colors.white,
        //icon: Icon(Icons.person, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF926AD3),
        duration: Duration(seconds: 4),
        isDismissible: true,
      );
      print(e.toString());
    }
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

  Widget _popUpMenus() {
    return PopupMenuButton(
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
                    Icons.group_rounded,
                    color: Color(0xFF926AD3),
                  ),
                  Text(" Groups"),
                ],
              ),
            ),
            PopupMenuItem<int>(
              value: 1,
              child: Row(
                children: const [
                  Icon(
                    Icons.account_circle_rounded,
                    color: Color(0xFF926AD3),
                  ),
                  Text(" Profile"),
                ],
              ),
            ),
            PopupMenuItem<int>(
              value: 2,
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
              value: 3,
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
            Get.to(GroupListPage());
          }
          if (value == 1) {
            if (kDebugMode) {
              print("My account menu is selected.");
            }
            //widget.contact.favourite?.isEmpty ?? true
            if (ContactListPage.user!.isNotEmpty ?? true) {
              Get.to(UserProfilePage(
                user: ContactListPage.user[0],
                isChanged: false,
              ));
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: ((context) => UserProfilePage(
              //               user: ContactListPage.user[0],
              //               isChanged: false,
              //             ))));
            }
          } else if (value == 2) {
            if (kDebugMode) {
              print("Settings menu is selected.");
            }
            Get.to(SettingPage());
            // Navigator.push(context,
            //     MaterialPageRoute(builder: ((context) => SettingPage())));
          } else if (value == 3) {
            // final prefs = await SharedPreferences.getInstance();
            // prefs.setBool('isLoggedIn',false);
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: ((context) => LoginPage())));
            logout();
            if (kDebugMode) {
              print("Logout menu is selected.");
            }
          }
        });
  }

  Future _refresh() async {
    setState(() {
      ContactListPage.contactList.clear();
      ContactListPage.favouriteList.clear();
    });
    final prefs = await SharedPreferences.getInstance();
    String url =
        'https://scm.womenindigital.net/api/${prefs.getInt('loginID')}/allConnections';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        "Accept": 'application/json',
        'Authorization': 'Bearer ${prefs.getString('token')}'
      });
      var data = jsonDecode(response.body.toString());
      // print(response.body.toString());
      if (response.statusCode == 200) {
        for (Map i in data) {
          bool status = isPresent(i['name']);
          if (status == false) {
            //tempList.add(Contact.fromJson(i));
            ContactListPage.contactList.add(Contact.fromJson(i));
            bool favStatus = isFavourite(i['favourite']);
            if (favStatus == true) {
              setState(() {
                ContactListPage.favouriteList.add(Contact.fromJson(i));
              });
            }
          }
        }

        //print("ContactListPage Contact List: ${ContactListPage.contactList}");
        //return ContactListPage.contactList;
      } else {
        //return ContactListPage.contactList;
      }
    } on Exception catch (e) {
      // TODO
      Get.snackbar(
        "Network Issue",
        "Please check your internet connection!",
        colorText: Colors.white,
        //icon: Icon(Icons.person, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF926AD3),
        duration: Duration(seconds: 4),
        isDismissible: true,
      );
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();

    }
    print("BUILT");
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                        border: Border.all(
                            width: 2, color: const Color(0xFF926AD3)),
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
              _popUpMenus(),
            ],
            bottom: TabBar(
              tabs: [
                //badge_rounded
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_ind_rounded),
                      Text('  All Contacts')
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_rate_rounded),
                      Text('   Favourites')
                    ],
                  ),
                )
                //Tab(icon: Icon(Icons.star_rate_rounded),text: 'Favourites',)
              ],
            ),
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
              children: [
                TabBarView(
                  children: [
                    SafeArea(
                      child: Container(
                        color: Colors.transparent,
                        padding: const EdgeInsets.only(left: 17, right: 10),
                        child: RefreshIndicator(
                          onRefresh: _refresh,
                          child: FutureBuilder(
                            future: futureContactList,
                            builder: (context,
                                AsyncSnapshot<List<Contact>> snapshot) {
                              //print(snapshot.data.toString());
                              if (!snapshot.hasData) {
                                return Center(
                                    child: const CircularProgressIndicator(
                                  color: Colors.white,
                                ));
                              } else {
                                // snapshot.data!.sort((a, b) {
                                //   return a.name
                                //       .toString()
                                //       .toLowerCase()
                                //       .compareTo(
                                //           b.name.toString().toLowerCase());
                                // });
                                return AlphabeticScrollView(items: snapshot.data!);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Container(
                        color: Colors.transparent,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: RefreshIndicator(
                          onRefresh: _refresh,
                          child: AlphabeticScrollView(items: ContactListPage.favouriteList,)
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                    bottom: 20, right: 20, child: _floatingActionButton()),
              ],
            ),
          )),
    );
  }
}
// ListView.builder(
//   key: UniqueKey(),
//   itemCount: ContactListPage.favouriteList.length,
//   physics: const AlwaysScrollableScrollPhysics(),
//   scrollDirection: Axis.vertical,
//   shrinkWrap: false,
//   itemBuilder: (context, index) {
//     return ExpansionTile(
//       leading: InkWell(
//         onTap: () {
//           Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) =>
//                       SingleContactDetailsPage(
//                         contact: ContactListPage
//                             .favouriteList![index],
//                         token: ContactListPage
//                             .barerToken,
//                         isChanged: false,
//                       )));
//         },
//         child: CircleAvatar(
//           radius: 22,
//           backgroundColor: Colors.white,
//           child: CircleAvatar(
//             radius: 20,
//             backgroundImage: NetworkImage(
//               image +
//                   ContactListPage
//                       .favouriteList![index].photo
//                       .toString(),
//             ),
//           ),
//         ),
//       ),
//
//       title: InkWell(
//           onTap: () {
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) =>
//                         SingleContactDetailsPage(
//                           contact: ContactListPage
//                               .favouriteList![index],
//                           token: ContactListPage
//                               .barerToken,
//                           isChanged: false,
//                         )));
//           },
//           child: Text(
//             ContactListPage.favouriteList![index].name
//                 .toString(),
//             style:
//                 const TextStyle(color: Colors.white),
//           )),
//       //trailing: _favourite(_getBoolStatus(snapshot.data![index].favourite.toString())),
//       subtitle: _designationText(ContactListPage
//           .favouriteList![index].phone_no
//           .toString()),
//       children: <Widget>[
//         Column(
//           children: [
//             Container(
//                 alignment: Alignment.bottomLeft,
//                 child: _moreButton(ContactListPage
//                     .favouriteList![index])),
//           ],
//         ),
//       ],
//     );
//   },
// ),
