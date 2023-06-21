import 'dart:convert';

import 'package:community_app/Screens/Contact/singleContactDetailsPage.dart';
import 'package:community_app/Widget/staticMethods.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../Model/contact.dart';
import '../Auth/loginPage.dart';
import '../Auth/settingsPage.dart';

class CreatorProfile extends StatefulWidget {
  Contact creator;
  CreatorProfile({Key? key, required this.creator}) : super(key: key);

  @override
  State<CreatorProfile> createState() => _CreatorProfileState();
}

class _CreatorProfileState extends State<CreatorProfile> {
  late String name = "";
  late String phone_no = "";
  late String email = "";
  late String designation = "";
  late String organization = "";
  late String dob = "";
  late String gender = "";
  late String address = "";
  late String socialLinks = "";
  late String photo = "";
  late String note = "";
  // var img = Image.network(src);
  // var placeholder = AssetImage(assetName)
  ///storage/profile_photo
  String image = 'https://scm.womenindigital.net/storage/profile_photo/';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    valueInitialization();
  }
  void valueInitialization() {
    //print('$widget.user.photo  $widget.user.email');
    if (widget.creator.name?.isEmpty ?? true) {
      name = "";
    } else {
      name = widget.creator.name.toString();
    }

    if (widget.creator.phone_no?.isEmpty ?? true) {
      phone_no = " ";
    } else {
      phone_no = widget.creator.phone_no.toString().replaceAll(RegExp('[^0-9+]'), '');
    }
    if (widget.creator.photo?.isEmpty ?? true) {
      photo = '202302160552-profile-white.png';
    } else {
      photo = widget.creator.photo.toString();
    }

    if (widget.creator.email?.isEmpty ?? true) {
      email = " ";
    } else {
      email = widget.creator.email.toString();
    }

    if (widget.creator.designation?.isEmpty ?? true) {
      designation = " ";
    } else {
      designation = widget.creator.designation.toString();
    }

    if (widget.creator.organization?.isEmpty ?? true) {
      organization = " ";
    } else {
      organization = widget.creator.organization.toString();
    }

    if (widget.creator.date_of_birth?.isEmpty ?? true) {
      dob = " ";
    } else {
      //final splitted = string.split(' ');
      final temp = widget.creator.date_of_birth.toString().split('-');
      print(temp);
      final year = temp[0];
      final month = StaticMethods.getMonth(temp[1]);
      final date = temp[2];
      dob = '$date $month';
    }

    if (widget.creator.gender?.isEmpty ?? true) {
      gender = " ";
    } else {
      gender = widget.creator.gender.toString();
    }

    if (widget.creator.address?.isEmpty ?? true) {
      address = " ";
    } else {
      address = widget.creator.address.toString();
    }

    if (widget.creator.social_media?.isEmpty ?? true) {
      socialLinks = " ";
    } else {
      socialLinks = widget.creator.social_media.toString();
    }

    if (widget.creator.note?.isEmpty ?? true) {
      note = " ";
    } else {
      note = widget.creator.note.toString();
    }

    print(
        '$name : $photo : $phone_no : $email : $designation : $organization : $dob :'
            '$gender : $address : $socialLinks : $note');
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        //color: Colors.green,
        child: Stack(
          children: <Widget>[
//User Image
            //Contact Image
            Positioned(
              top: 0,
              right: 0,
              child: ClipPath(
                  clipper: OvalBottomBorderClipper(),
                  child: Container(
                    height: (width * (870 / 1080)) + 10,
                    width: width,
                    decoration: const BoxDecoration(
                      color: Color(0xFF926AD3),
                    ),

                    child: Image.network(
                      image + photo.toString(),
                      fit: BoxFit.fitHeight,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, url, error) => Icon(
                        Icons.error,
                        color: Colors.white,
                      ),
                    ),
                    //color: Colors.red,
                    // child: Image.network(
                    //   image + widget.user.photo.toString(),
                    //   fit: BoxFit.fitHeight,
                    // ),
                  )),
            ),
            //Image shadow
            Positioned(
                top: 0,
                height: (width * (300 / 1080)),
                width: width,
                child: Image.asset(
                  'assets/images/overlay.png',
                  fit: BoxFit.fitWidth,
                )),
            Positioned(top: 30, left: 0, child: _backButton()),
            Positioned(top: 30, right: 0, child: _topRightButtons()),

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

  Widget _backButton() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Get.back();
            //Navigator.pop(context);
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
        //Settings & Logout
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
                        Icons.settings,
                        color: Color(0xFF926AD3),
                      ),
                      Text(" Settings"),
                    ],
                  ),
                ),
                PopupMenuItem<int>(
                  value: 1,
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => SettingPage(isShow: true, parent: '',))));
                if (kDebugMode) {
                  print("Settings menu is selected.");
                }
              } else if (value == 1) {
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
  Widget _textField(String hintText, String value, Icon icon) {
    TextEditingController controller = TextEditingController();
    if (value != " ") {
      controller.text = value;
      print("VALUE CONTROLLER  " + value + " " + controller.text.toString());
    }
    //TextEditingController controllerTitle,
    return TextField(
      //enabled: false, //Not clickable and not editable
      readOnly: true,
      enabled: false,
      controller: controller,
      maxLines: 4,
      minLines: 1,
      style: TextStyle(color: Color(0xFF926AD3)),
      decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: icon,
          //suffixIcon: Icon(Icons.),
          border: InputBorder.none,
          fillColor: Colors.transparent,
          //fillColor: Colors.transparent,
          filled: true),
    );
  }
  Widget _textFieldWidget() {
    print("_TEXT_FIELD " + name + phone_no + email);
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
}
