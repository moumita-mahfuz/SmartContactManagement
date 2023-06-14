import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

import '../Model/contact.dart';

class ContactDetails extends StatefulWidget {
  ContactDetails({Key? key}) : super(key: key);

  @override
  State<ContactDetails> createState() => _ContactDetailsState();
}

class _ContactDetailsState extends State<ContactDetails> {
  late String name = '';
  late String photo = '';
  late String phone_no = '';
  late String email = '';
  late String designation = '';
  late String organization = '';
  late String dob = '';
  late String gender = '';
  late String address = '';
  late String connections = '';
  late String socialLinks = '';
  late String note = '';
  late String favourite = '';
  late int createdBy = 1;
  String creator = '';
  Contact x = Contact();
  List<Contact> connectionsContact = [];
  List<String> connectionsContactString = [];
  String image = 'https://scm.womenindigital.net/storage/uploads/';
  bool _hasCallSupport = false;
  bool _isFav = false;
  bool _isChange = false;
  Future<void>? _launched;
  String shareText = '';

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0.0,
      // ),
      body: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            Container(
              height: height+600,
              width: width,
              child: Column(
                children: [
                  Container(
                    height: width * (870 / 1080),
                    width: width,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          right: 0,
                          child: ClipPath(
                            clipper: OvalBottomBorderClipper(),
                            child: Container(
                              height: (width * (870 / 1080)) + 10,
                              width: width,
                              color: Color(0xFF926AD3),
                              child: Image.asset(
                                'assets/images/profile.png',
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          height: (width * (300 / 1080)),
                          width: width,
                          child: Image.asset(
                            'assets/images/overlay.png',
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        Positioned(top: 30, left: 0, child: _backButton()),
                        Positioned(
                          top: 30,
                          right: 0,
                          child: _topRightButtons(context),
                        ),
                        Positioned(
                          top: (width * (870 / 1080)) - 30,
                          child: Center(child: _bottomCenterOptions()),
                        ),
                      ],
                    ),
                  ),
                  _textFieldWidget(),
                  Expanded(
                    child: GridView(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      children: [
                        Image.network('https://picsum.photos/250?image=1'),
                        Image.network('https://picsum.photos/250?image=2'),
                        Image.network('https://picsum.photos/250?image=3'),
                        Image.network('https://picsum.photos/250?image=4'),
                        Image.network('https://picsum.photos/250?image=1'),
                        Image.network('https://picsum.photos/250?image=2'),
                        Image.network('https://picsum.photos/250?image=3'),
                        Image.network('https://picsum.photos/250?image=4'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(String hintText, String value, Icon icon) {
    //print(hintText +value+"/");
    TextEditingController controller = TextEditingController();
    if (value != " ") {
      controller.text = value;
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
          // border: InputBorder.none,
          border: InputBorder.none,
          //fillColor: Color(0xfff3f3f4),
          fillColor: Colors.transparent,
          filled: true),
    );
  }

  Widget _textFieldWidget() {
    return Container(
      child: Padding(
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
      ),
    );
  }
  Widget _backButton() {
    return Column(
      children: [
        InkWell(
          onTap: () {},
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

  Widget _topRightButtons(BuildContext context) {
    return Container(
      child: Row(
        children: [
          //SHARE BUTTON
          PopupMenuButton(
              // add icon, by default "3 dot" icon
              icon: const Icon(
                Icons.share,
                color: Colors.white,
              ),
              itemBuilder: (context) {
                return [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Text(" as Text "),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: Text(" as Vcard "),
                  ),
                ];
              },
              onSelected: (value) async {
                if (value == 0) {
                  if (kDebugMode) {
                    print("as Text is selected.");
                  }
                } else if (value == 1) {
                  if (kDebugMode) {
                    print("as Vcard is selected.");
                  }
                }
              }),
          InkWell(
            onTap: () {
              setState(() {
                _isChange = true;
              });
              print("Taped edit");
            },
            child: Container(
              padding:
                  const EdgeInsets.only(left: 0, top: 10, bottom: 10, right: 10),
              //Icon(Icons.more_vert)
              child: Icon(Icons.drive_file_rename_outline_rounded,
                  color: Colors.white),
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

                                //Navigator.pop(context);
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
                          Icons.account_circle_rounded,
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
                } else if (value == 1) {
                  if (kDebugMode) {
                    print("Settings menu is selected.");
                  }
                } else if (value == 2) {
                  if (kDebugMode) {
                    print("Logout menu is selected.");
                  }
                }
              }),
        ],
      ),
    );
  }

  Widget _bottomCenterOptions() {
    return Center(
      child: Row(
        children: [
          //FAVOURITE
          InkWell(
              onTap: () {
                if (_isFav == true) {
                  print("ISIDE " + _isFav.toString());
                } else {
                  print("ISIDE " + _isFav.toString());
                }
                setState(
                  () {
                    _isFav = !_isFav;
                  },
                );
              },
              child: (_isFav)
                  ? Icon(
                      Icons.star_rate_rounded,
                      color: Colors.white,
                    )
                  : Icon(
                      Icons.star_border_rounded,
                      color: Colors.white,
                    )),

          const SizedBox(
            width: 15,
          ),
          //EMAIL
          InkWell(
            onTap: () {},
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
            onTap: () => {},
            child: Icon(
              Icons.call,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          //MASSAGE
          InkWell(
            onTap: () {},
            child: const Icon(
              Icons.message,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
