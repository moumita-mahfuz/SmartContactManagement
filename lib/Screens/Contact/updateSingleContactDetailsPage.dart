import 'dart:convert';
import 'dart:io';

import 'package:community_app/Screens/Contact/singleContactDetailsPage.dart';
import 'package:community_app/Screens/contactListPage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../Model/contact.dart';
import '../../Widget/bezierContainer.dart';
import '../../Widget/multiSelectDropDown.dart';
import 'package:get/get.dart'  hide Response, FormData, MultipartFile;


class UpdateSingleContactDetailsPage extends StatefulWidget {
  final Contact contact;
  const UpdateSingleContactDetailsPage({Key? key, required this.contact})
      : super(key: key);

  @override
  State<UpdateSingleContactDetailsPage> createState() =>
      _UpdateSingleContactDetailsPageState();
}

class _UpdateSingleContactDetailsPageState
    extends State<UpdateSingleContactDetailsPage> {
  //name, designation, organization, connected_id, phone_no, email,
  // date_of_birth, gender, address, social_media, note, photo
  TextEditingController nameController = TextEditingController();
  TextEditingController designationController = TextEditingController();
  TextEditingController organizationController = TextEditingController();
  TextEditingController connectedController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController socialMediaController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  late String initName;
  // late String photo;
  // late String phone_no;
  // late String email;
  // late String designation;
  // late String organization;
  // late String dob;
  // late String gender;
  // late String address;
  // late String connections;
  // late String socialLinks;
  // late String note;
  String image = 'https://scm.womenindigital.net/storage/uploads/';

  List<Contact> connectionsContact = [];
  List<String> connectionsContactString = [];
  // Initial Selected Value
  var _image;
  CroppedFile? _croppedFile;
  final picker = ImagePicker();
  late String dropdownvalue;
  late String connections;
  FocusNode searchFocusNode = FocusNode();
  List<String> _checkedItems = [];
  List<String> _mItems = [];
  bool readOnly = true;
  FocusNode f1 = FocusNode();
  bool showSpinner = false;
  bool isLoading = false;
  bool _validate = false;
  String errorText = 'Name Can\'t Be Empty';
  String _completePhnNo = '', updatedNo = '';

  @override
  void initState() {
    super.initState();
    //imagePicker = new ImagePicker();
    //myController.addListener(_printLatestValue);
    //nameController.addListener(() { })
    dobController.text = ""; //set the initial value of text field
// Store Connection name in mItems
    getConnectionItemList(
        ContactListPage.contactList, widget.contact.name.toString());
    valueInitialization();
  }

  void valueInitialization() {
    if (widget.contact.name?.isEmpty ?? true) {
      nameController.text = "";
    } else {
      nameController.text = widget.contact.name.toString();
      initName = widget.contact.name.toString();
    }
    // if (widget.contact.photo?.isEmpty ?? true) {
    //   photo = "";
    // } else {
    //   photo = widget.contact.photo.toString();
    // }

    if (widget.contact.phone_no?.isEmpty ?? true) {
      phoneController.text = "";
    } else {
      //if(widget.contact.phone_no)
      _completePhnNo = widget.contact.phone_no.toString();
      phoneController.text = _getPhnInfo(widget.contact.phone_no!, 'no');
    }

    if (widget.contact.email?.isEmpty ?? true) {
      emailController.text = "";
    } else {
      emailController.text = widget.contact.email.toString();
    }

    if (widget.contact.designation?.isEmpty ?? true) {
      designationController.text = "";
    } else {
      designationController.text = widget.contact.designation.toString();
    }
    if (widget.contact.date_of_birth?.isEmpty ?? true) {
      //dobController.text = "";
    } else {
      dobController.text = widget.contact.date_of_birth.toString();
    }

    if (widget.contact.organization?.isEmpty ?? true) {
      organizationController.text = "";
    } else {
      organizationController.text = widget.contact.organization.toString();
    }

    if (widget.contact.gender?.isEmpty ?? true) {
      dropdownvalue = 'Male';
      //genderController.text = "";
    } else {
      genderController.text = widget.contact.gender.toString();
      dropdownvalue = widget.contact.gender.toString();
    }

    if (widget.contact.address?.isEmpty ?? true) {
      addressController.text = "";
    } else {
      addressController.text = widget.contact.address.toString();
    }

    if (widget.contact.social_media?.isEmpty ?? true) {
      socialMediaController.text = "";
    } else {
      socialMediaController.text = widget.contact.social_media.toString();
    }
    if (widget.contact.connected_id.toString() == '[]') {
      connectedController.text = "";
    } else {
      getConnectionString();
    }

    if (widget.contact.note?.isEmpty ?? true) {
      noteController.text = "";
    } else {
      noteController.text = widget.contact.note.toString();
    }
    // print('$name : $photo : $phone_no : $email : $designation : $organization : $dob :'
    //     '$gender : $address : $connections : $socialLinks : $note');
  }

  String _getPhnInfo(String comPhnNo, String type) {
    String s = "+54-123456789123-AR";
    final temp = comPhnNo.split('-');
    print(temp);
    if (temp.length != 3 && type == 'textCode') {
      return 'BD';
    } else if (temp.length != 3 && type == 'no') {
      return comPhnNo;
    } else if (type == 'textCode') {
      return temp[2];
    } else if (type == 'no') {
      return temp[1];
    } else if (type == 'noCode') {
      return temp[0];
    } else
      return comPhnNo;
  }

  String getConnectionString() {
    //Store Connection Contact in connectionsContact
    getConnectionsContact(widget.contact.connected_id.toString());
    print('Connection list: $connectionsContact');
    //connections = " ";
    for (Contact x in connectionsContact) {
      _checkedItems.add(x.name.toString());
    }
    return _checkedItems.toString();
  }

  getConnectionsContact(String connectionsArray) {
    //String s= '[3,23,24,01,2]';
    final temp = connectionsArray.split("[");
    final temp0 = temp[1].split(']');
    final contactIDs = temp0[0];
    //print(contactIDs);
    final list = contactIDs.split(', ');
    for (Contact x in ContactListPage.contactList) {
      //print("Name: " + x.name.toString() + x.id.toString());
      if (list.contains(x.id.toString())) {
        print("inside if Name: ${x.name}${x.id}");
        connectionsContact.add(x);
      }
    }
    for (String s in list) {
      bool check = isNumericUsing_tryParse(s);
      if (check == false) {
        connectionsContactString.add(s);
      }
    }
    connections = "";
    for (String s in connectionsContactString) {
      connections = "$connections$s ";
    }
    setState(() {
      connectedController.text = connections.toString();
    });
    print("connectionsContact: $connectionsContact");
  }

  void getConnectionItemList(List<Contact> contactList, String contactName) {
    for (Contact x in contactList) {
      if (contactName != x.name.toString()) {
        _mItems.add(x.name.toString());
      }
    }
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

  Future<void> submitForm(
      String name,
      String designation,
      String organization,
      String connected_id,
      String phone_no,
      String email,
      String date_of_birth,
      String gender,
      String address,
      String social_media,
      String note) async {
    final prefs = await SharedPreferences.getInstance();
    String id = widget.contact.id.toString();
    var uriData = 'https://scm.womenindigital.net/api/connection/$id/update';

    Map<String, String> headers = {
      "Accept": 'application/json',
      'Authorization': 'Bearer ${prefs.getString('token')}'
    };
    Map<String, String> body = {
      'name': name,
      'designation': designation,
      'organization': organization,
      'connected_id': getCheckedItemsID(_checkedItems).toString(),
      'phone_no': phone_no,
      'email': email,
      'date_of_birth': date_of_birth,
      'gender': gender,
      'address': address,
      'social_media': social_media,
      'note': note,
      'created_by': prefs.getInt('loginID').toString()
    };

    if (kDebugMode) {
      print("Body $name $designation $organization $_checkedItems"
          "$phone_no $email $date_of_birth $gender $address $social_media  $note"
          " ${prefs.getInt('loginID')}");
    }
    // name, designation, organization, connected_id, phone_no, email,
    // date_of_birth, gender, address, social_media, note, photo
    //http://scm.womenindigital.net/api/connection/19/update

    var request = http.MultipartRequest('POST', Uri.parse(uriData));
    if (kDebugMode) {
      print("IMAGE $_croppedFile ");
    }
    if (_croppedFile != null) {
      //File f = await getImageFileFromAssets('images/profile.png');
      request.headers.addAll(headers);
      request.fields.addAll(body);
      request.files
          .add(await http.MultipartFile.fromPath('photo', _croppedFile!.path));
    } else {
      // File f = await getImageFileFromAssets('images/profile-white.png');
      request.headers.addAll(headers);
      request.fields.addAll(body);
      //request.files.add(await http.MultipartFile.fromPath('photo', f.path));
    }
    var streamedResponse = await request.send();
    print("STREAM " + streamedResponse.stream.toString());
    var response = await http.Response.fromStream(streamedResponse);
    print(response.body.toString());
    String rawData = response.body.toString().replaceAll("\"", ' ');
    print("RAW DATA " + rawData);
    if (streamedResponse.statusCode == 200) {
     // Navigator.pop(context);
      print('info uploaded  ' + _getPhotoID(rawData).toString() + ".");
      Contact c = Contact(
          id: widget.contact.id,
          name: name,
          photo: _getPhotoID(rawData),
          designation: designation,
          organization: organization,
          connected_id: getCheckedItemsID(_checkedItems).toString(),
          phone_no: phone_no,
          email: email,
          date_of_birth: date_of_birth,
          gender: gender,
          address: address,
          social_media: social_media,
          note: note,
          created_by: prefs.getInt('loginID'));
      //Navigator.pop(context);
      //Navigator.pop(context);
      Get.off(SingleContactDetailsPage(
        contactID: c.id!,
        contact: c,
        token: ContactListPage.barerToken,
        isChanged: true, from: 'update', creator: c.created_by!,
      ));
      // Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //         builder: ((context) => SingleContactDetailsPage(
      //           contactID: c.id!,
      //               contact: c,
      //               token: ContactListPage.barerToken,
      //               isChanged: true,
      //             ))));
    } else {
      print('failed ${response.statusCode}');
    }
    // try {
    //
    // } catch (e) {
    //   print('failed');
    //   setState(() {
    //     showSpinner = false;
    //   });
    // }

    // String rawDetails =" { message : Ok , data :{ id :13, created_at :null, updated_at :null, name : test 12 , designation :null, organization :null, connected_id : [] , phone_no :null, email :null, date_of_birth :null, gender :null, address :null, social_media :null, note :null, photo : 202302161059-FB_IMG_1676264759097.jpg , created_by : 5 }}";
    // final value = rawDetails.split('data :');
    // String details = value[1].replaceAll(RegExp('[^A-Za-z0-9,:._@ -+]'), '');
    // print("DETAILS "+ details.toString());
    // final res = details.split(', ');
    // print(res[14]);
    // final photoString = res[14].split(': ');
    // print(photoString[1]);
  }

  String _getPhotoID(String rawDetails) {
    final value = rawDetails.split('data :');
    String photo = '';
    //String rawDetails = "{ message : Ok , data :{ id :91, created_at :null, updated_at :null, name : Elephant testing , designation :null, organization :null, connected_id : [81, 84, 107, 85, shanto Test test test test moumita] , phone_no :null, email :null, date_of_birth :null, gender :null, address :null, social_media :null, note :null, photo : 202303160957-image_cropper_1678960594713.jpg , favourite : false , created_by : 88 }}";
    //final value = rawDetails.split('data :');
    //print(value[1]);
    value[1] = value[1].replaceAll('{', '');
    value[1] = value[1].replaceAll('}', '');
    //print(value[1]);

    // String details = value[1].replaceAll(RegExp('[^-A-Za-z0-9,:._@ +]'), '');
    //print(details);
    final res = value[1].split(', ');

    for (String s in res) {
      //print (s);
      final split = s.split(' :');
      if (split[0] == 'photo') {
        photo = split[1].trimLeft();
        photo = photo.trimRight();
      }
    }

    return photo;
  }

  List<String> getCheckedItemsID(List<String> checkedItems) {
    List<Contact> selectedContact = [];
    List<String> selectedContactIds = [];
    for (String s in checkedItems) {
      for (int i = 0; i < ContactListPage.contactList.length; i++) {
        if (ContactListPage.contactList[i].name != null) {
          if (ContactListPage.contactList[i].name!.contains(s)) {
            selectedContact.add(ContactListPage.contactList[i]);
          }
        }
      }
    }
    for (Contact x in selectedContact) {
      selectedContactIds.add(x.id.toString());
    }
    if (connectedController.text.isNotEmpty) {
      selectedContactIds.add(connectedController.text.toString());
    }
    return selectedContactIds;
  }

  Widget _backButton() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
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

  bool isPresent(String name) {
    bool status = false;
    if (name == initName) {
      return false;
    } else {
      for (Contact x in ContactListPage.contactList) {
        // print("isPresent name: ${x.name} == $name");
        if (name == x.name.toString()) {
          status = true;
        }
      }
    }

    return status;
  }

  Widget _updateButton() {
    return InkWell(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        setState(() {
          nameController.text.isEmpty ? _validate = true : _validate = false;

          bool status = isPresent(nameController.text.toString());
          if (status == true) {
            _validate = true;
            errorText = 'Can\'t use same name';
          } else {
            _validate = false;
            showSpinner = true;
          }
        });
        if (showSpinner == true) {
          showModalBottomSheet<void>(
            context: context,
            isDismissible: false,
            builder: (BuildContext context) {
              return Container(
                height: 80,
                color: Color(0xFF926AD3),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          backgroundColor: Colors.white,
                        ),
                        height: 18,
                        width: 18,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Please wait...",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //   backgroundColor: Color(0xFF926AD3),
          //   content: Row(
          //     children: [
          //       SizedBox(
          //         child: CircularProgressIndicator(
          //           strokeWidth: 3,
          //           backgroundColor: Color(0xFF9A9A9A),
          //         ),
          //         height: 14,
          //         width: 14,
          //       ),
          //       SizedBox(
          //         width: 10,
          //       ),
          //       Text(
          //         "Please wait...",
          //         style: TextStyle(fontSize: 14),
          //       ),
          //     ],
          //   ),
          //   //duration: Duration(milliseconds: 1500),
          // ));
        }

        if (nameController.text.isNotEmpty && _validate == false) {
          setState(() {
            showSpinner = true;
          });
          submitForm(
              nameController.text.toString(),
              designationController.text.toString(),
              organizationController.text.toString(),
              connectedController.text.toString(),
              updatedNo,
              emailController.text.toString(),
              dobController.text.toString(),
              genderController.text.toString(),
              addressController.text.toString(),
              socialMediaController.text.toString(),
              noteController.text.toString());
        }
        //Navigator.pop(context);
      },
      // onTap: () {
      //   setState(() {
      //     nameController.text.isEmpty ? _validate = true : _validate = false;
      //     showSpinner = true;
      //   });
      //
      //   if (nameController.text.isNotEmpty) {
      //     submitForm(
      //         nameController.text.toString(),
      //         designationController.text.toString(),
      //         organizationController.text.toString(),
      //         connectedController.text.toString(),
      //         phoneController.text.toString(),
      //         emailController.text.toString(),
      //         dobController.text.toString(),
      //         genderController.text.toString(),
      //         addressController.text.toString(),
      //         socialMediaController.text.toString(),
      //         noteController.text.toString());
      //
      //   }
      //   //Navigator.pop(context);
      // },
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 15, 20, 0),
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        child: const Text(' Update ',
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  void _showMultiSelect() async {
    // a list of selectable items
    // these items can be hard-coded or dynamically fetched from a database/API
    final List<String> items = ['1', '2', '3', '4', '5'];
    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        if (_checkedItems.isEmpty == true) {
          return MultiSelect(items: _mItems, checkedItems: _checkedItems);
        } else {
          for (int i = 0; i < _checkedItems.length; i++) {
            if (_mItems.contains(_checkedItems[i])) {
              _mItems.remove(_checkedItems[i]);
            }
          }
          return MultiSelect(items: _mItems, checkedItems: _checkedItems);
        }
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        _checkedItems = results;
        print("connection with: $_checkedItems");
      });
    }
  }

  Future getImage(int status) async {
    if (status == 1) {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          _cropImage(pickedFile);
        } else {
          print('No image selected.');
        }
      });
    } else if (status == 2) {
      final pickedFile = await picker.getImage(source: ImageSource.camera);
      setState(() {
        if (pickedFile != null) {
          _cropImage(pickedFile);
        } else {
          print('No image selected.');
        }
      });
    }
  }

  /// Crop Image
  Future<void> _cropImage(final _pickedFile) async {
    if (_pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        // maxWidth: 1080,
        // maxHeight: 1080,
        aspectRatio: CropAspectRatio(ratioX: 6.2, ratioY: 5),
      );
      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
        });
      }
    }
  }

  Widget _imagePicker(double height, double width) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 100,
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ElevatedButton(
                        onPressed: () async {
                          Get.back();
                          //Navigator.pop(context);

                          getImage(1);
                        },
                        child: const Text('Pick Image from Gallery')),
                    ElevatedButton(
                        onPressed: () async {
                          Get.back();
                          //Navigator.pop(context);
                          getImage(2);
                        },
                        child: const Text('Pick Image from Camera')),
                    // ElevatedButton(
                    //   child: const Text('Close BottomSheet'),
                    //   onPressed: () => Navigator.pop(context),
                    // ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: SizedBox(
        //color: Colors.orange,
        height: height * (23 / 100),
        width: width * (35 / 100) + 100,
        child: Container(
          // color: Colors.red,
          //X = 480 × (384/805)
          width: width * (38 / 100),
          //X = 540 × (805/384)
          height: height * (23 / 100),
          margin: const EdgeInsets.only(bottom: 5),
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Stack(
            children: [
              Center(
                child: Container(
                  child: (_croppedFile != null)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            File(_croppedFile!.path).absolute,
                            // _image,
                            width: width * (38 / 100),
                            height: height * (23 / 100),
                            fit: BoxFit.fitHeight,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Color(0xfff3f3f4),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          width: width * (38 / 100),
                          height: height * (23 / 100),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              image + widget.contact.photo.toString(),
                              fit: BoxFit.fitHeight,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            //Image.network(image+widget.contact.photo.toString(),fit: BoxFit.fitHeight,),
                          ),
                        ),
                ),
              ),
              Positioned(bottom: 0, right: 15, child: _cameraIcon()),

              // Align(
              //   alignment: Alignment.bottomRight,
              //   child: Padding(
              //     padding: EdgeInsets.all(8),
              //     child: Icon(
              //       Icons.camera_alt,
              //       color: Colors.grey[800],
              //     ),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }

  Widget _cameraIcon() {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: CircleAvatar(
        backgroundColor: Color(0xFF926AD3),
        radius: 20,
        child: Icon(
          Icons.camera_alt,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _genderSuffixPopUpMenu() {
    return PopupMenuButton(
        // add icon, by default "3 dot" icon
        icon: Icon(Icons.keyboard_arrow_down_rounded),
        itemBuilder: (context) {
          return [
            const PopupMenuItem<int>(
              value: 0,
              child: Text("Male"),
            ),
            const PopupMenuItem<int>(
              value: 1,
              child: Text("Female"),
            ),
          ];
        },
        onSelected: (value) {
          if (value == 0) {
            setState(() {
              dropdownvalue = value.toString();
              genderController.text = "Male";
              //hintText = newValue!;
            });
            print("Male is selected.");
          } else if (value == 1) {
            setState(() {
              dropdownvalue = value.toString();
              genderController.text = "Female";
              //hintText = newValue!;
            });
            print("Female is selected.");
          }
        });
  }

  Widget _genderPrefixPopUpMenu() {
    return PopupMenuButton(
        // add icon, by default "3 dot" icon
        icon: Icon(Icons.accessibility_new),
        itemBuilder: (context) {
          return [
            const PopupMenuItem<int>(
              value: 0,
              child: Text("Male"),
            ),
            const PopupMenuItem<int>(
              value: 1,
              child: Text("Female"),
            ),
          ];
        },
        onSelected: (value) {
          if (value == 0) {
            setState(() {
              dropdownvalue = value.toString();
              genderController.text = "Male";
              //hintText = newValue!;
            });
            print("Male is selected.");
          } else if (value == 1) {
            setState(() {
              dropdownvalue = value.toString();
              genderController.text = "Female";
              //hintText = newValue!;
            });
            print("Female is selected.");
          }
        });
  }

  Widget _genderDropDown(String hintText, Icon icon) {
    // if (gender != " ") {
    //   genderController.text = gender;
    // }
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.only(right: 15),
      //padding: EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: genderController,
              style: TextStyle(
                  color:
                      Color(0xFF926AD3)), //editing controller of this TextField
              decoration: InputDecoration(
                  hintText: dropdownvalue,
                  suffixIcon: _genderSuffixPopUpMenu(),
                  prefixIcon: _genderPrefixPopUpMenu(),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFF9A9A9A)), //<-- SEE HERE
                  ),
                  fillColor: Colors.transparent,
                  filled: true),
              readOnly: readOnly,
              focusNode: f1,
              onTap: () {}, //Clickable and not editable
            ),
          ),
        ],
      ),
    );
  }

  Widget _connectionWithDropDown(String hintText, Icon icon) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          // display selected items
          Wrap(
            spacing: 5,
            children: _checkedItems
                .map((e) => Chip(
                      backgroundColor: Color(0xFF926AD3),
                      deleteIcon: Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onDeleted: () {
                        setState(() {
                          _mItems.add(e);
                          _checkedItems.remove(e);
                        });
                      },
                      label: Text(
                        e,
                        style: TextStyle(color: Colors.white),
                      ),
                    ))
                .toList(),
          ),
          TextField(
            controller: connectedController,
            style: const TextStyle(color: Color(0xFF9A9A9A)),
            //controller: dateController, //editing controller of this TextField
            decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: _iconCW(icon),
                suffixIcon: _iconCW(Icon(Icons.keyboard_arrow_down_rounded)),
                enabledBorder: const UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color(0xFF9A9A9A)), //<-- SEE HERE
                ),
                fillColor: Colors.transparent,
                filled: true),
            // readOnly: true, //Clickable and not editable
            //  onTap: () async {
            //    _showMultiSelect();
            //  },
          ),
        ],
      ),
    );
  }

  Widget _iconCW(Icon icon) {
    return InkWell(
      onTap: () async {
        _showMultiSelect();
      },
      child: icon,
    );
  }

  Widget _dateOfBirth(String hintText, Icon icon) {
    // if (dob != " ") {
    //   dobController.text = dob;
    // }
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: dobController,
        style: TextStyle(
            color: Color(0xFF926AD3)), //editing controller of this TextField
        decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: icon,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF9A9A9A)), //<-- SEE HERE
            ),
            fillColor: Colors.transparent,
            filled: true),
        readOnly: true, // when true user cannot edit text
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(), //get today's date
              firstDate: DateTime(1950,
                  1), //DateTime.now() - not to allow to choose before today.
              lastDate: DateTime(2101));

          if (pickedDate != null) {
            print(
                pickedDate); //get the picked date in the format => 2022-07-04 00:00:00.000
            String formattedDate = DateFormat('yyyy-MM-dd').format(
                pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
            print(
                formattedDate); //formatted date output using intl package =>  2022-07-04
            //You can format date as per your need

            setState(() {
              dobController.text =
                  formattedDate; //set foratted date to TextField value.
            });
          } else {
            print("Date is not selected");
          }
        },
      ),
    );
  }

  Widget _entryField(
      String hintText,
      //String value,
      TextEditingController controller,
      TextCapitalization type,
      TextInputType inputType,
      Icon icon,
      {bool isPassword = false}) {
    controller.selection =
        TextSelection.collapsed(offset: controller.text.length);
    if (hintText == "Name") {
      //TextEditingController controllerTitle,
      return Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        child: TextField(
          //enabled: false, //Not clickable and not editable
          keyboardType: inputType,
          textInputAction: TextInputAction.next,
          textCapitalization: type,
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Color(0xFF926AD3)),
          decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: icon,
              errorText: _validate ? errorText : null,
              //suffixIcon: Icon(Icons.),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF9A9A9A)), //<-- SEE HERE
              ),
              fillColor: Colors.transparent,
              filled: true),
        ),
      );
    } else {
      //TextEditingController controllerTitle,
      return Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        child: TextField(
          controller: controller,
          //enabled: false, //Not clickable and not editable
          keyboardType: inputType,
          textInputAction: TextInputAction.next,
          textCapitalization: type,
          obscureText: isPassword,
          style: const TextStyle(color: Color(0xFF926AD3)),
          decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: icon,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF9A9A9A)), //<-- SEE HERE
              ),
              fillColor: Colors.transparent,
              filled: true),
        ),
      );
    }
    // if(hintText == 'Name') {
    //   if (value != " ") {
    //     controller.text = value;
    //     controller.selection =
    //         TextSelection.collapsed(offset: controller.text.length);
    //   }
    //   //TextEditingController controllerTitle,
    //   return Container(
    //     margin: EdgeInsets.symmetric(vertical: 10),
    //     child: TextField(
    //       //enabled: false, //Not clickable and not editable
    //       keyboardType: inputType,
    //       textInputAction: TextInputAction.next,
    //       textCapitalization: type,
    //       controller: controller,
    //       obscureText: isPassword,
    //       style: const TextStyle(color: Color(0xFF926AD3)),//editing controller of this TextField
    //       decoration: InputDecoration(
    //           hintText: hintText,
    //           prefixIcon: icon,
    //           errorText: _validate ? 'Name Can\'t Be Empty' : null,
    //
    //           //suffixIcon: Icon(Icons.),
    //           enabledBorder: const UnderlineInputBorder(
    //             borderSide: BorderSide(color: Color(0xFF9A9A9A)), //<-- SEE HERE
    //           ),
    //           fillColor: Colors.transparent,
    //           filled: true),
    //     ),
    //   );
    //
    // }
    // else {
    //   if (value != " ") {
    //     //controller.text = value;
    //
    //   }
    //   //TextEditingController controllerTitle,
    //
    // }
  }

  Widget _phoneEntryField() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: IntlPhoneField(
        controller: phoneController,
        //dropdownIcon: Icon(Icons.phone_rounded),
        dropdownTextStyle: const TextStyle(color: Color(0xFF9A9A9A)),
        //dropdownIconPosition: IconPosition.trailing,
        style: const TextStyle(color: Color(0xFF926AD3)),
        decoration: InputDecoration(
          hintText: 'Phone',
          prefixIcon: Icon(Icons.phone_rounded),
          fillColor: Colors.transparent,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF9A9A9A)), //<-- SEE HERE
          ),
        ),
        initialCountryCode: _getPhnInfo(_completePhnNo, 'textCode').trim(),
        onChanged: (phone) {
          setState(() {
            updatedNo = phone.countryCode +
                "-" +
                phone.number +
                "-" +
                phone.countryISOCode;
          });
          //phone.countryCode = _getPhnInfo(_completePhnNo, 'textCode').trim();
          print(phone.completeNumber);
        },
      ),
    );
  }

  Widget _textFieldWidget() {
    return Column(
      children: <Widget>[
        //String hintText,TextEditingController controller,
        //TextInputType inputType, Icon icon, {bool isPassword = false}
        _entryField(
          "Name",
          // name,
          nameController,
          TextCapitalization.words,
          TextInputType.name,
          Icon(Icons.person),
        ),
        _entryField(
          "Designation",
          // designation,
          designationController,
          TextCapitalization.words,
          TextInputType.text,
          Icon(Icons.workspace_premium_rounded),
        ),
        _entryField(
          "Organization",
          //organization,
          organizationController,
          TextCapitalization.words,
          TextInputType.text,
          Icon(Icons.work_rounded),
        ),
        _phoneEntryField(),
        // _entryField(
        //   "Phone",
        //   //phone_no,
        //   phoneController,
        //   TextCapitalization.none,
        //   TextInputType.phone,
        //   Icon(Icons.phone_rounded),
        // ),
        _entryField(
          "Email",
          //email,
          emailController,
          TextCapitalization.none,
          TextInputType.emailAddress,
          Icon(Icons.email_rounded),
        ),
        _dateOfBirth("Birthday", Icon(Icons.cake_rounded)),
        _genderDropDown("Male", Icon(Icons.calendar_today)),
        _entryField(
          "Address",
          //address,
          addressController,
          TextCapitalization.words,
          TextInputType.streetAddress,
          Icon(Icons.location_on_rounded),
        ),
        _connectionWithDropDown(
          "Connection With",
          Icon(Icons.group),
        ),
        _entryField(
          "Social Media Link",
          //socialLinks,
          socialMediaController,
          TextCapitalization.none,
          TextInputType.text,
          Icon(Icons.insert_link_rounded),
        ),
        _entryField(
          "Note",
          //note,
          noteController,
          TextCapitalization.sentences,
          TextInputType.text,
          Icon(Icons.note_alt_rounded),
        ),
        // _entryField("Password", isPassword: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: width,
                    height: (width * (870 / 1080)),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          right: 0,
                          height: (width * (870 / 1080)),
                          width: width,
                          child: Image.asset('assets/images/add-user.png'),
                        ),
                        Positioned(
                            top: 90,
                            width: width,
                            child: Center(child: _imagePicker(height, width))),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      child: _textFieldWidget()),
                ],
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
            Positioned(top: 30, right: 0, child: _updateButton()),
          ],
        ),
      ),
    );
  }
}
