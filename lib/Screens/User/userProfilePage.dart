import 'dart:convert';

import 'package:community_app/Screens/User/updateUserProfilePage.dart';
import 'package:community_app/Screens/contactListPage.dart';
import 'package:community_app/Screens/contactListPage.dart';
import 'package:community_app/Screens/Contact/updateSingleContactDetailsPage.dart';
import 'package:community_app/Widget/networkImageLoader.dart';
import 'package:community_app/Widget/staticMethods.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Model/User.dart';
import '../../Model/contact.dart';
import '../Auth/loginPage.dart';
import '../Auth/settingsPage.dart';

class UserProfilePage extends StatefulWidget {
  final bool isChanged;
  UserProfilePage({Key? key, required this.isChanged}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
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
  User userProfile = User();
  // var img = Image.network(src);
  // var placeholder = AssetImage(assetName)
  ///storage/profile_photo
  String image = 'https://scm.womenindigital.net/storage/profile_photo/';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetails();
    //valueInitialization();
  }

  Future<void> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String url =
        'https://scm.womenindigital.net/api/user/${prefs.getInt('loginID')}/show';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        "Accept": 'application/json',
        'Authorization': 'Bearer ${prefs.getString('token')}'
      });
      var data = jsonDecode(response.body.toString());
      // print("${response.statusCode} $data");
      if (response.statusCode == 200) {
        for (Map i in data) {
          // print("name " + i['name']);
          setState(() {
            userProfile = User(
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
            );
            valueInitialization(userProfile);
          });
        }
      } else {}
    } catch (e) {
      // TODO
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Color(0xFF926AD3),
        content: Text(
          '$e!',
          style: TextStyle(fontSize: 14),
        ),
        duration: Duration(milliseconds: 2000),
      ));
      print(e.toString());
    }
  }

  void valueInitialization(User user) {
    //print('$widget.user.photo  $widget.user.email');
    if (user.name?.isEmpty ?? true) {
      name = "";
    } else {
      name = user.name.toString();
    }

    if (user.phone_no?.isEmpty ?? true) {
      phone_no = " ";
    } else {
      phone_no = user.phone_no.toString().replaceAll(RegExp('[^0-9+]'), '');
    }
    if (user.photo?.isEmpty ?? true) {
      photo = '202302160552-profile-white.png';
    } else {
      photo = user.photo.toString();
    }

    if (user.email?.isEmpty ?? true) {
      email = " ";
    } else {
      email = user.email.toString();
    }

    if (user.designation?.isEmpty ?? true) {
      designation = " ";
    } else {
      designation = user.designation.toString();
    }

    if (user.organization?.isEmpty ?? true) {
      organization = " ";
    } else {
      organization = user.organization.toString();
    }

    if (user.date_of_birth?.isEmpty ?? true) {
      dob = " ";
    } else {
      //final splitted = string.split(' ');
      final temp = user.date_of_birth.toString().split('-');
      print(temp);
      final year = temp[0];
      final month = StaticMethods.getMonth(temp[1]);
      final date = temp[2];
      dob = '$date $month';
    }

    if (user.gender?.isEmpty ?? true) {
      gender = " ";
    } else {
      gender = user.gender.toString();
    }

    if (user.address?.isEmpty ?? true) {
      address = " ";
    } else {
      address = user.address.toString();
    }

    if (user.social_media?.isEmpty ?? true) {
      socialLinks = " ";
    } else {
      socialLinks = user.social_media.toString();
    }

    if (user.note?.isEmpty ?? true) {
      note = " ";
    } else {
      note = user.note.toString();
    }

    print(
        '$name : $photo : $phone_no : $email : $designation : $organization : $dob :'
            '$gender : $address : $socialLinks : $note');
  }

  Widget _backButton() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if(widget.isChanged) {
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => ContactListPage(
                        token: ContactListPage.barerToken,
                      ))));
            } else {
              Navigator.pop(context);
            }
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
                    builder: ((context) => UpdateUserProfilePage(
                      user: userProfile,
                    ))));
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
                Get.to(() => SettingPage(isShow: true, parent: '',));
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
      //print("VALUE CONTROLLER  " + value + " " + controller.text.toString());
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
                    height: (width * (870 / 1080)) ,
                    width: width,
                    decoration: const BoxDecoration(
                      color: Color(0xFF926AD3),
                    ),

                    child: NetworkImageLoader(imageUrl: image + photo.toString(),),

                    // Image.network(
                    //   image + photo.toString(),
                    //   fit: BoxFit.fitHeight,
                    //   loadingBuilder: (context, child, loadingProgress) {
                    //     if (loadingProgress == null) return child;
                    //     return Center(
                    //       child: CircularProgressIndicator(
                    //         value: loadingProgress.expectedTotalBytes != null
                    //             ? loadingProgress.cumulativeBytesLoaded /
                    //             loadingProgress.expectedTotalBytes!
                    //             : null,
                    //       ),
                    //     );
                    //   },
                    //   errorBuilder: (context, url, error) => Icon(Icons.error,color: Colors.white,),
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
