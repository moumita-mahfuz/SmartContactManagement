import 'dart:convert';

import 'package:community_app/Screens/Contact/updateSingleContactDetailsPage.dart';
import 'package:community_app/Screens/contactListPage.dart';
import 'package:community_app/Screens/contactListPage.dart';
import 'package:community_app/Screens/User/userProfile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mailto/mailto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Model/contact.dart';
import '../Auth/loginPage.dart';

class SingleContactDetailsPage extends StatefulWidget {
  final Contact contact;
  const SingleContactDetailsPage({Key? key, required this.contact})
      : super(key: key);

  @override
  State<SingleContactDetailsPage> createState() =>
      _SingleContactDetailsPageState();
}

class _SingleContactDetailsPageState extends State<SingleContactDetailsPage> {
  late String name;
  late String photo;
  late String phone_no;
  late String email;
  late String designation;
  late String organization;
  late String dob;
  late String gender;
  late String address;
  late String connections;
  late String socialLinks;
  late String note;
  List<Contact> connectionsContact = [];
  String image = 'https://scm.womenindigital.net/storage/uploads/';
  bool _hasCallSupport = false;
  Future<void>? _launched;

  //https://scm.womenindigital.net/storage/uploads/202302120406-Twitter-logo-png.png
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    valueInitialization();
    // Check for phone call support.
    canLaunchUrl(Uri(scheme: 'tel', path: '123')).then((bool result) {
      setState(() {
        _hasCallSupport = result;
      });
    });
  }

  void valueInitialization() {
    if (widget.contact.name?.isEmpty ?? true) {
      name = "";
    } else {
      name = widget.contact.name.toString();
    }
    if (widget.contact.photo?.isEmpty ?? true) {
      photo = '202302160552-profile-white.png';
    } else {
      photo = widget.contact.photo.toString();
    }

    if (widget.contact.phone_no?.isEmpty ?? true) {
      phone_no = " ";
    } else {
      phone_no = widget.contact.phone_no.toString();
    }

    if (widget.contact.email?.isEmpty ?? true) {
      email = " ";
    } else {
      email = widget.contact.email.toString();
    }

    if (widget.contact.designation?.isEmpty ?? true) {
      designation = " ";
    } else {
      designation = widget.contact.designation.toString();
    }

    if (widget.contact.organization?.isEmpty ?? true) {
      organization = " ";
    } else {
      organization = widget.contact.organization.toString();
    }

    if (widget.contact.connected_id?.isEmpty ?? true) {
      connections = " ";
    } else {
      getConnectionsId(widget.contact.connected_id.toString());
      // print('Connection list: $connectionsContact');
      connections = " ";
      for (Contact x in connectionsContact) {
        connections = "$connections${x.name} ";
        //print(connections);
      }
    }

    if (widget.contact.date_of_birth?.isEmpty ?? true) {
      dob = " ";
    } else {
      //final splitted = string.split(' ');
      final temp = widget.contact.date_of_birth.toString().split('-');
      print(temp);
      final year = temp[0];
      final month = getMonth(temp[1]);
      final date = temp[2];
      dob = '$date $month, $year';
    }

    if (widget.contact.gender?.isEmpty ?? true) {
      gender = " ";
    } else {
      gender = widget.contact.gender.toString();
    }

    if (widget.contact.address?.isEmpty ?? true) {
      address = " ";
    } else {
      address = widget.contact.address.toString();
    }

    if (widget.contact.social_media?.isEmpty ?? true) {
      socialLinks = " ";
    } else {
      socialLinks = widget.contact.social_media.toString();
    }

    if (widget.contact.note?.isEmpty ?? true) {
      note = " ";
    } else {
      note = widget.contact.note.toString();
    }
    print(
        '$name : $photo : $phone_no : $email : $designation : $organization : $dob :'
        '$gender : $address : $connections : $socialLinks : $note');
  }

  getConnectionsId(String connectionsArray) {
    //String s= '[3,23,24,01,2]';
    final temp = connectionsArray.split("[");
    final temp0 = temp[1].split(']');
    final contactIDs = temp0[0];
    //print(contactIDs);
    final list = contactIDs.split(', ');
    for (Contact x in ContactListPage.contactList) {
      //print("Name: " + x.name.toString() + x.id.toString());
      if (list.contains(x.id.toString())) {
        print("inside if Name: " + x.name.toString() + x.id.toString());
        connectionsContact.add(x);
      }
    }
    print("connectionsContact: " + connectionsContact.toString());
  }

  Future<http.Response> deleteContact() async {
    final prefs = await SharedPreferences.getInstance();
    String id = widget.contact.id.toString();
    print("Inside Delete Contact $id");
    //String url =  'http://scm.womenindigital.net/api/${prefs.getInt('loginID')}/allConnections';
    // http://scm.womenindigital.net/api/connection/18/delete --> Delete endpoint
    final http.Response response = await http.delete(
      Uri.parse('http://scm.womenindigital.net/api/connection/$id/delete'),
      headers: {'Authorization': 'Bearer ${prefs.getString('token')}'},
    );
    if (response.statusCode == 200) {
      print("successfully deleted Contact: $id");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: ((context) => ContactListPage(
                  token: 'Bearer ' + prefs.getString('token').toString()))));
    }

    return response;
  }

  // Contact getConnections(String id) {
  //   String name = " ";
  //   Contact cContact = Contact();
  //   for (Contact x in ContactListPage.contactList) {
  //     if(x.id.toString() == id) {
  //       print("getConnections: name-  "+ x.name.toString());
  //       name = x.name!;
  //       cContact = x;
  //     }
  //   }
  //   return cContact;
  // }

  Widget _backButton() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 15, 0, 0),
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.all(Radius.circular(40)),
            ),
            child: const Text('  Back  ',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }

  Widget _topRightButtons() {
    return Row(
      children: [
        //EDIT BUTTON
        InkWell(
          onTap: () {
            print("Taped edit");
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: ((context) => UpdateSingleContactDetailsPage(
                        contact: widget.contact))));
          },
          child: Container(
            padding:
                const EdgeInsets.only(left: 0, top: 10, bottom: 10, right: 10),
            //Icon(Icons.more_vert)
            child: Icon(Icons.drive_file_rename_outline_rounded,
                color: Colors.white),
          ),
        ),
        InkWell(
          onTap: () {
            print("Taped middle");
          },
          child: Container(
            padding:
                const EdgeInsets.only(left: 0, top: 10, bottom: 10, right: 10),
            //Icon(Icons.more_vert)
            child: Icon(Icons.share, color: Colors.white),
          ),
        ),
        //DELETE BUTTON
        InkWell(
          onTap: () {
            showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: 100,
                    color: Color(0xFF926AD3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              print("Pressed delete");
                              deleteContact();
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(200, 40),
                              maximumSize: const Size(200, 40),
                              backgroundColor: Colors.white,
                            ),
                            child: const Text(
                              'Delete Contact',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            )),
                        ElevatedButton(
                            onPressed: () async {
                              print("Pressed Cancel");
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(200, 40),
                              maximumSize: const Size(200, 40),
                              backgroundColor: Colors.white,
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF926AD3)),
                            )),
                      ],
                    ),
                  );
                });
          },
          child: Container(
            padding:
                const EdgeInsets.only(left: 0, top: 10, bottom: 10, right: 10),
            //Icon(Icons.more_vert)
            child: Icon(Icons.delete_rounded, color: Colors.white),
          ),
        ),

        PopupMenuButton(
            // add icon, by default "3 dot" icon

            icon: Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
            ),
            itemBuilder: (context) {
              return [
                PopupMenuItem<int>(
                  value: 0,
                  child: Row(
                    children: [
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
                    children: [
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
                    children: [
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Widget _bottomCenterOptions() {
    return Center(
      child: Row(
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
              if (widget.contact.email?.isEmpty ?? true) {
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
                  to: [widget.contact.email!],
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
                (_hasCallSupport && (widget.contact.phone_no?.isNotEmpty ?? false))
                    ? () => setState(() {
                          _launched = _makePhoneCall(widget.contact.phone_no!);
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
              if (widget.contact.phone_no?.isEmpty ?? true) {
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
                _sendingSMS(widget.contact.phone_no!);
              }
            },
            child: const Icon(
              Icons.message,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
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

  Widget _contactImage() {
    return Container(
      // height: MediaQuery.of(context).size.height *.5,
      width: MediaQuery.of(context).size.width,

      child: Image.asset('assets/images/contact.jpg'),
    );
  }

  Widget _textField(String hintText, String value, Icon icon) {
    TextEditingController controller = TextEditingController();
    if (value != " ") {
      controller.text = value;
    }
    //TextEditingController controllerTitle,
    return Container(
      // margin: EdgeInsets.symmetric(vertical: 1),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(6.0),
      // ),

      child: TextField(
        //enabled: false, //Not clickable and not editable
        readOnly: true,
        enabled: false,
        controller: controller,
        style: TextStyle(color: Color(0xFF926AD3)),
        decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: icon,
            //suffixIcon: Icon(Icons.),
            // border: InputBorder.none,
            border: InputBorder.none,
            //fillColor: Color(0xfff3f3f4),
            fillColor: Colors.transparent,
            filled: true),
      ),
    );
  }

  Widget _textFieldWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Column(
        children: <Widget>[
          _textField("Name", name, Icon((Icons.person))),
          //String hintText,TextEditingController controller,
          //TextInputType inputType, Icon icon, {bool isPassword = false}
          _textField(
            "Phone",
            phone_no,
            Icon(Icons.phone_rounded),
          ),
          _textField(
            "Email",
            email,
            Icon(Icons.email_rounded),
          ),
          _textField(
            "Designation",
            designation,
            Icon(Icons.workspace_premium_rounded),
          ),
          _textField(
            "Organization",
            organization,
            Icon(Icons.work_rounded),
          ),
          _textField("Connection With", connections, Icon(Icons.group)),
          _textField("Birthday", dob, Icon(Icons.cake_rounded)),
          _textField("Gender", gender, Icon(Icons.accessibility_new)),
          _textField("Address", address, Icon(Icons.location_on_rounded)),
          _textField("Social Media Link", socialLinks,
              Icon(Icons.insert_link_rounded)),
          _textField("Note", note, Icon(Icons.note_alt_rounded))

          // _entryField("Password", isPassword: true),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        /* Set your status bar color here */
        child: Stack(
          alignment: Alignment.center,
          textDirection: TextDirection.rtl,
          fit: StackFit.loose,
          clipBehavior: Clip.hardEdge,
          children: <Widget>[
            //Contact Image
            Positioned(
                top: 0,
                right: 0,
                child: Container(
                  height: (width * (870 / 1080)),
                  width: width,
                  decoration: const BoxDecoration(
                    color: Color(0xFF926AD3),
                    // color: Colors.deepOrange,
                    // borderRadius: BorderRadius.only(
                    //   bottomLeft: Radius.circular(100),
                    //   bottomRight: Radius.circular(100),
                    // ),
                  ),
                  //color: Colors.red,
                  child: Image.network(
                    image + photo,
                    fit: BoxFit.fitHeight,
                  ),
                )),
            Positioned(
              top: 0,
              right: 0,
              width: width,
              child: Image.asset('assets/images/overlay.png'),
            ),
            Positioned(top: 30, left: 0, child: _backButton()),
            Positioned(top: 30, right: 0, child: _topRightButtons()),
            Positioned(
                top: (width * (870 / 1080)) - 30,
                child: _bottomCenterOptions()),

            Positioned(
                top: (width * (870 / 1080)),
                left: 20,
                right: 20,
                bottom: 2,
                child: ListView(
                  //physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    _textFieldWidget(),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  String getMonth(String monthNo) {
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
}
// Container(
//   //padding: EdgeInsets.symmetric(horizontal: 20),
//   margin: EdgeInsets.only(top: 80),
//   child: SingleChildScrollView(
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         //Image.asset('assets/images/contact.jpg'),
//         Positioned(
//           top: -MediaQuery.of(context).size.height * .15,
//           //right: -MediaQuery.of(context).size.width * .4,
//           child: Image.asset('assets/images/contact.jpg'),
//         ),
//         SizedBox(height: 50),
//
//         SizedBox(height: 20),
//
//
//         // _genderDropDown(),
//         SizedBox(height: 20),
//         // _submitButton(),
//         SizedBox(height: 20),
//       ],
//     ),
//   ),
// ),
//Positioned(top: 14,child: Image.asset('assets/images/contact.jpg',width: 50,height: 50,),),
//Positioned(top: 40, right: 0, child: _button()),
// Positioned(top: 10,child: Image.asset('assets/images/contact.jpg',width: 100,height: 100,),),
