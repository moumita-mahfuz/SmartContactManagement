import 'dart:convert';
import 'dart:io';
import 'package:community_app/Screens/Auth/settingsPage.dart';
import 'package:community_app/Screens/Contact/creatorProfile.dart';
import 'package:community_app/Screens/Contact/updateSingleContactDetailsPage.dart';
import 'package:community_app/Screens/contactListPage.dart';
import 'package:community_app/Widget/staticMethods.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

import 'package:http/http.dart' as http;
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:http/http.dart';
import 'package:mailto/mailto.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Model/User.dart';
import '../../Model/contact.dart';
import '../../Model/contactGallery.dart';
import '../../Widget/addPhotoBottomSheet.dart';
import '../../Widget/galleryBottomSheet.dart';
import '../../Widget/multipleImageSelector.dart';
import '../../Widget/networkImageLoader.dart';
import '../Auth/loginPage.dart';
import '../User/userProfilePage.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

class SingleContactDetailsPage extends StatefulWidget {
  final int contactID;
  final Contact contact;
  final String token;
  final bool isChanged;
  final String from;
  final int creator;
  const SingleContactDetailsPage(
      {Key? key,
      required this.contactID,
      required this.contact,
      required this.token,
      required this.isChanged,
      required this.from,
      required this.creator})
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
  late String favourite;
  late int createdBy;
  String creator = '';
  Contact x = Contact();
  Contact creatorProfile = Contact();
  List<Contact> connectionsContact = [];
  List<String> connectionsContactString = [];
  String image = 'https://scm.womenindigital.net/storage/uploads/';
  bool _hasCallSupport = false;
  bool _isFav = false;
  bool _isChange = false;
  Future<void>? _launched;
  String shareText = '';



  //https://scm.womenindigital.net/storage/uploads/202302120406-Twitter-logo-png.png
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    shareText = valueInitialization();

    // print("Check" +
    //     widget.creator!.toString() +
    //     "<- creator      userid->" +
    //     ContactListPage.user[0].id!.toString());
    // Check for phone call support.
    getContactCreator();
    canLaunchUrl(Uri(scheme: 'tel', path: '123')).then((bool result) {
      setState(() {
        _hasCallSupport = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    print("in BUILD " + _isFav.toString());
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
              child: ClipPath(
                clipper: OvalBottomBorderClipper(),
                child: Container(
                  height: (width * (870 / 1080)) + 10,
                  width: width,
                  color: Color(0xFF926AD3),
                  child: NetworkImageLoader(imageUrl: image + photo,),

                  // Image.network(
                  //   image + photo,
                  //   fit: BoxFit.fitHeight,
                  //   loadingBuilder: (BuildContext context, Widget child,
                  //       ImageChunkEvent? loadingProgress) {
                  //     if (loadingProgress == null) return child;
                  //     return Center(
                  //       child: CircularProgressIndicator(
                  //         value: loadingProgress.expectedTotalBytes != null
                  //             ? loadingProgress.cumulativeBytesLoaded /
                  //                 loadingProgress.expectedTotalBytes!
                  //             : null,
                  //       ),
                  //     );
                  //   },
                  //   errorBuilder: (context, url, error) => Icon(Icons.error),
                  // ),
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
                )),
            Positioned(top: 30, left: 0, child: _backButton()),
            Positioned(
              top: 30,
              right: 0,
              child: (widget.creator == ContactListPage.user[0].id)
                  ? _topRightThreeButtons(context)
                  : _topRightTwoButtons(context),
            ),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 20.0),
                      child: Container(
                        child: (widget.from == 'search')
                            ? Row(
                                children: [
                                  Text('Contact from: '),
                                  InkWell(
                                    onTap: () => {
                                      if (widget.creator !=
                                          ContactListPage.user[0].id)
                                        {
                                          print("tapped"),
                                          Get.to(() => CreatorProfile(
                                                creator: creatorProfile,
                                              )),
                                        }
                                    },
                                    child: Text(
                                      '$creator',
                                      style: TextStyle(
                                          color: Color(0xFF926AD3),
                                          fontSize: 18),
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                    _textFieldWidget(),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  String valueInitialization() {
    String text = '';
    if (widget.contact.name?.isEmpty ?? true) {
      name = "";
    } else {
      name = widget.contact.name.toString();
      text = "Name: " + widget.contact.name.toString() + '\n';
    }
    if (widget.contact.photo?.isEmpty ?? true) {
      photo = '202302160552-profile-white.png';
    } else {
      photo = widget.contact.photo.toString();
    }

    if (widget.contact.phone_no?.isEmpty ?? true) {
      phone_no = " ";
    } else {
      phone_no =
          widget.contact.phone_no.toString().replaceAll(RegExp('[^0-9+]'), '');
      text = text + "Phone: " + widget.contact.phone_no.toString() + '\n';
    }

    if (widget.contact.email?.isEmpty ?? true) {
      email = " ";
    } else {
      email = widget.contact.email.toString();
      text = text + "Email: " + widget.contact.email.toString() + '\n';
    }

    if (widget.contact.designation?.isEmpty ?? true) {
      designation = " ";
    } else {
      designation = widget.contact.designation.toString();
      text = text + widget.contact.designation.toString() + ' ';
    }

    if (widget.contact.organization?.isEmpty ?? true) {
      organization = " ";
    } else {
      organization = widget.contact.organization.toString();
      text = text + "- " + widget.contact.organization.toString();
    }
    print("CONNECTION" + widget.contact.connected_id.toString() + "END");
    if (widget.contact.connected_id?.isEmpty ?? true) {
      connections = " ";
    } else {
      connections = "";
      getConnectionsId(widget.contact.connected_id.toString());
      //print('Connection list: ' + widget.contact.connected_id.toString());

      for (Contact x in connectionsContact) {
        connections = "$connections${x.name} ";
        //print(connections);
      }
      if (connectionsContactString.isNotEmpty) {
        for (String s in connectionsContactString) {
          connections = "$connections$s ";
        }
      }
    }

    if (widget.contact.date_of_birth?.isEmpty ?? true) {
      dob = " ";
    } else {
      //final splitted = string.split(' ');
      final temp = widget.contact.date_of_birth.toString().split('-');
      //print(temp);
      final year = temp[0];
      final month = StaticMethods.getMonth(temp[1]);
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
    if (widget.contact.favourite?.isEmpty ?? true) {
      favourite = 'false';
      _isFav = false;
    } else {
      favourite = widget.contact.favourite.toString();
      if (widget.contact.favourite.toString() == 'true') {
        _isFav = true;
      } else {
        _isFav = false;
      }
    }
    createdBy = widget.contact.created_by!;
    // print(
    //     '$name : $photo : $phone_no : $email : $designation : $organization : $dob :'
    //     '$gender : $address : $connections : $socialLinks : $note');
    return text;
  }

  getConnectionsId(String connectionsArray) {
    //String s= '[3,23,24,01,2]';
    final temp = connectionsArray.split("[");
    final temp0 = temp[1].split(']');
    final contactIDs = temp0[0];
    //print(contactIDs);
    final list = contactIDs.split(', ');
    //print("LIST LENGTH "+list.length.toString());
    for (Contact x in ContactListPage.contactList) {
      //print("Name: " + x.name.toString() + x.id.toString());
      if (list.contains(x.id.toString())) {
        // print("inside if Name: " + x.name.toString() + x.id.toString());
        connectionsContact.add(x);
      }
    }
    for (String s in list) {
      bool check = isNumericUsing_tryParse(s);
      if (check == false) {
        connectionsContactString.add(s);
      }
    }
    //print("connectionsContact: " + connectionsContact.toString());
  }

  bool isNumericUsing_tryParse(String string) {
    // Null or empty string is not a number
    // if (string == null || string.isEmpty) {
    //   return false;
    // }

    // Try to parse input string to number.
    // Both integer and double work.
    // Use int.tryParse if you want to check integer only.
    // Use double.tryParse if you want to check double only.
    final number = num.tryParse(string);

    if (number == null) {
      return false;
    }

    return true;
  }

  Future<void> getContactDetailsApi() async {
    //ContactListPage.user.clear();
    final prefs = await SharedPreferences.getInstance();
    String contactID = widget.contactID.toString();
    //https://scm.womenindigital.net/api/connection/3/show
    String url =
        'https://scm.womenindigital.net/api/connection/${contactID}/show';

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
          x = Contact(
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

  Future<void> getContactCreator() async {
    final prefs = await SharedPreferences.getInstance();
    String url =
        'https://scm.womenindigital.net/api/user/${widget.contact.created_by}/show';

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
            creator = i['name'];
            creatorProfile = Contact(
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

  Future<http.Response> deleteContact() async {
    final prefs = await SharedPreferences.getInstance();
    String id = widget.contact.id.toString();
    print("Inside Delete Contact $id");
    //String url =  'http://scm.womenindigital.net/api/${prefs.getInt('loginID')}/allConnections';
    // http://scm.womenindigital.net/api/connection/18/delete --> Delete endpoint
    final http.Response response = await http.delete(
      Uri.parse('https://scm.womenindigital.net/api/connection/$id/delete'),
      headers: {'Authorization': 'Bearer ${prefs.getString('token')}'},
    );
    if (response.statusCode == 200) {
      print("successfully deleted Contact: $id");
      Get.offAll(ContactListPage(
          token: 'Bearer ' + prefs.getString('token').toString()));
    }

    return response;
  }

  Widget _backButton() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (_isChange || widget.isChanged) {
              Get.offAll(ContactListPage(
                token: widget.token,
              ));
            } else {
              Get.back();
              // Navigator.pop(context);
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

  Future<String> get _localPath async {
    final directory = await getDownloadsDirectory();

    return directory!.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File(path + "/" + widget.contact.name.toString() + ".vcf");
  }

  Future<File> _createFile(String data) async {
    final file = await _localFile;
    return file.writeAsString(data);
  }

  _onShare(BuildContext context, int value) async {
    final box = context.findRenderObject() as RenderBox?;
    Contact p = widget.contact;
    //0 = text, 1= vCard
    if (value == 0) {
      await Share.share(shareText,
          subject: 'Smart Contact Management - $name',
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    } else if (value == 1) {
      final directory = await getExternalStorageDirectory();
      final path = directory!.path;
      File vcfFile = File(path + "/" + widget.contact.name.toString() + ".vcf");
      print(vcfFile);
      String contact = "BEGIN:VCARD\r\n" +
          "VERSION:3.0\r\n" +
          "N:" +
          p.name.toString() +
          ";" +
          "\r\n" +
          "ORG:" +
          p.organization.toString() +
          "\r\n" +
          "TEL;TYPE=WORK,VOICE:" +
          p.phone_no.toString() +
          "\r\n" +
          "END:VCARD\r\n";
      vcfFile.writeAsString('$contact');
      //ShareExtend.share(_vcf.path, "file");

      XFile? xfile = XFile(vcfFile!.path);
      await Share.shareXFiles([xfile],
          text: shareText,
          subject: 'Smart Contact Management - $name',
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    }
  }

  Widget _topRightThreeButtons(BuildContext context) {
    return Row(
      children: [
        //EDIT BUTTON
        InkWell(
          onTap: () {
            setState(() {
              _isChange = true;
            });
            print("Taped edit");
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: ((context) => UpdateSingleContactDetailsPage(
            //             contact: widget.contact))));
            Get.to(UpdateSingleContactDetailsPage(contact: widget.contact));
          },
          child: Container(
            padding:
                const EdgeInsets.only(left: 0, top: 10, bottom: 10, right: 10),
            //Icon(Icons.more_vert)
            child: Icon(Icons.drive_file_rename_outline_rounded,
                color: Colors.white),
          ),
        ),
        //PHOTO ADD BUTTON
        InkWell(
          onTap: () {
            setState(() {

              _isChange = true;
            });
            print("Taped add photo");

            Get.bottomSheet(
                AddPhotoBottomSheet(contactId: widget.contactID,),
              //backgroundColor: Colors.transparent,
            );
          },
          child: Container(
            padding:
                const EdgeInsets.only(left: 0, top: 10, bottom: 10, right: 10),
            //Icon(Icons.more_vert)
            child: Icon(Icons.add_photo_alternate_rounded, color: Colors.white),
          ),
        ),
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
                _onShare(context, 0);
              } else if (value == 1) {
                if (kDebugMode) {
                  print("as Vcard is selected.");
                }
                _onShare(context, 1);
              }
            }),
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
                              Get.back();
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
                Get.to(() => UserProfilePage(
                      isChanged: false,
                    ));
              } else if (value == 1) {
                if (kDebugMode) {
                  print("Settings menu is selected.");
                }
                Get.to(SettingPage(isShow: true, parent: '',));
              } else if (value == 2) {
                logout();
                if (kDebugMode) {
                  print("Logout menu is selected.");
                }
              }
            }),
      ],
    );
  }

  Widget _topRightTwoButtons(BuildContext context) {
    return Row(
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
                _onShare(context, 0);
              } else if (value == 1) {
                if (kDebugMode) {
                  print("as Vcard is selected.");
                }
                _onShare(context, 1);
              }
            }),
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
                              Get.back();
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
                Get.to(() => UserProfilePage(
                      isChanged: false,
                    ));
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: ((context) => UserProfilePage(
                //               user: ContactListPage.user[0],
                //               isChanged: false,
                //             ))));
              } else if (value == 1) {
                if (kDebugMode) {
                  print("Settings menu is selected.");
                }
                Get.to(SettingPage(isShow: true, parent: '',));
                // Navigator.push(context,
                //     MaterialPageRoute(builder: ((context) => SettingPage())));
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
    Uri url = Uri.parse('sms:$phone');
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

  _snackBar(String massage) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Color(0xFF926AD3),
      content: Text(
        massage,
        style: TextStyle(fontSize: 14),
      ),
      duration: Duration(milliseconds: 1500),
    ));
  }

  Future _updateStatusApi(String contactID, String status) async {
    ///api/form/64/updateFavourite
    setState(() {
      _isChange = true;
    });
    final prefs = await SharedPreferences.getInstance();
    String url =
        'https://scm.womenindigital.net/api/form/$contactID/updateFavourite';
    Map<String, String> headers = {
      "Accept": 'application/json',
      'Authorization': 'Bearer ${prefs.getString('token')}'
    };
    Map<String, String> body = {'favourite': status};
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(headers);
    request.fields.addAll(body);
    var response = await request.send();
    if (kDebugMode) {
      print(response.statusCode);
    }
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
                  _snackBar("Removed from Favorites!");
                  _updateStatusApi(widget.contact.id.toString(), 'false');
                } else {
                  print("ISIDE " + _isFav.toString());
                  _snackBar("Added to Favorites!");
                  _updateStatusApi(widget.contact.id.toString(), 'true');
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
            onTap: (_hasCallSupport &&
                    (widget.contact.phone_no?.isNotEmpty ?? false))
                ? () => setState(() {
                      _launched = _makePhoneCall(widget.contact.phone_no!);
                    })
                : () => setState(() {
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
          const SizedBox(
            width: 15,
          ),
          InkWell(
            onTap: () {
              Get.bottomSheet(
                GalleryBottomSheet(
                  contactId: widget.contactID,
                ),
                backgroundColor: Colors.transparent,
              );
            },
            child: const Icon(
              Icons.image,
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
      print(e.toString());
    }
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
}
