import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:community_app/Screens/contactListPage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Model/contact.dart';
import '../../Widget/bezierContainer.dart';
import '../../Widget/multiSelectDropDown.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart';

class NewContactAddPage extends StatefulWidget {
  final List<Contact> contactList;

  const NewContactAddPage({Key? key, required this.contactList})
      : super(key: key);

  @override
  State<NewContactAddPage> createState() => _NewContactAddPageState();
}

class _NewContactAddPageState extends State<NewContactAddPage> {
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
  // Initial Selected Value
  //File f = await getImageFileFromAssets('images/myImage.jpg');
  File _image = File('/');
  CroppedFile? _croppedFile;
  final picker = ImagePicker();
  late String dropdownvalue;
  FocusNode searchFocusNode = FocusNode();
  List<String> _checkedItems = [];
  List<String> _mItems = [];
  bool readOnly = true;
  FocusNode f1 = FocusNode();
  bool showSpinner = false;
  bool isLoading = false;
  bool _validate = false;
  String errorText = 'Name Can\'t Be Empty';
  String _completePhnNo = '';
  late String _id;

  @override
  void initState() {
    super.initState();
    dobController.text = ""; //set the initial value of text field
    dropdownvalue = 'Male';
    getConnectionItemList(widget.contactList);
    //genderController = dropdownvalue;
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');
    final file = await File('${(await getTemporaryDirectory()).path}/$path')
        .create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  // void submitForm(
  //     String name,
  //     designation,
  //     organization,
  //     connected_id,
  //     phone_no,
  //     email,
  //     date_of_birth,
  //     gender,
  //     address,
  //     social_media,
  //     note) async {
  //   final prefs = await SharedPreferences.getInstance();
  //
  //   Map<String, String> headers = {
  //     "Accept": 'application/json',
  //     'Authorization': 'Bearer ${prefs.getString('token')}'
  //   };
  //   Map<String, String> body = {
  //     'name': name,
  //     'designation': designation,
  //     'organization': organization,
  //     'connected_id': getCheckedItemsID(_checkedItems).toString(),
  //     'phone_no': phone_no,
  //     'email': email,
  //     'date_of_birth': date_of_birth,
  //     'gender': gender,
  //     'address': address,
  //     'social_media': social_media,
  //     'note': note,
  //     'created_by': prefs.getInt('loginID').toString()
  //   };
  //   if (kDebugMode) {
  //     print('Bearer ' +
  //         prefs.getString('token').toString() +
  //         " " +
  //         prefs.getInt('loginID').toString());
  //   }
  //   if (kDebugMode) {
  //     print(
  //         "${"${"Body  " + name + "  " + designation + "  " + organization + "  " + _checkedItems.toString() + "  " + phone_no + "  " + email + "  " + date_of_birth + "  " + gender + "  " + address + "  " + social_media}  " + note}  ${prefs.getInt('loginID')}");
  //   }
  //   // name, designation, organization, connected_id, phone_no, email,
  //   // date_of_birth, gender, address, social_media, note, photo
  //   //http://scm.womenindigital.net//api/form/post
  //   try {
  //     var uri = Uri.parse('http://scm.womenindigital.net/api/form/post');
  //     var request = http.MultipartRequest('POST', uri);
  //     request.headers.addAll(headers);
  //     request.fields.addAll(body);
  //     //var response = await request.send();
  //     http.Response response =
  //         await http.Response.fromStream(await request.send());
  //     print("Result: ${response.statusCode}");
  //     //print(response.stream.toString());
  //     if (response.statusCode == 200) {
  //       _id = getFormID(response.body);
  //       print("IMAGE PATH" + _image.path.toString() + "khatam");
  //       if ((_image != null || _image == '/') && _image.path != '/') {
  //         addImage(_id, _image!.path);
  //       } else {
  //         Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(
  //                 builder: ((context) => ContactListPage(
  //                     token:
  //                         'Bearer ' + prefs.getString('token').toString()))));
  //       }
  //
  //       setState(() {
  //         showSpinner = false;
  //       });
  //       print('info uploaded');
  //     } else {
  //       print('failed ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('failed');
  //     setState(() {
  //       showSpinner = false;
  //     });
  //   }
  // }
  //
  // String getFormID(String s) {
  //   final temp = s.split(',');
  //   print("Last INDEX: " + temp.last.toString());
  //   String r = temp.last.toString();
  //   String id = r.replaceAll(RegExp('[^0-9]'), '');
  //   print("ID: $id");
  //   return id;
  // }

  void submitForm(
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
    //https://scm.womenindigital.net/api/form/post
    String uri = 'https://scm.womenindigital.net/api/form/post';
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
      'created_by': prefs.getInt('loginID').toString(),
      'favourite': 'false'
    };
    var request = http.MultipartRequest('POST', Uri.parse(uri));
    //print("IMAGE" + _croppedFile.toString() + " " + _croppedFile!.path.toString());
    if (_croppedFile != null ) {
      //File f = await getImageFileFromAssets('images/profile.png');
      request.headers.addAll(headers);
      request.fields.addAll(body);
      request.files
          .add(await http.MultipartFile.fromPath('photo', _croppedFile!.path));
    } else {
      File f = await getImageFileFromAssets('images/profile-white.png');
      request.headers.addAll(headers);
      request.fields.addAll(body);
      request.files.add(await http.MultipartFile.fromPath('photo', f.path));
    }
    var response = await request.send();
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200) {
      Navigator.pop(context);
      Navigator.pop(context);
      goBack();
      //return true;
    } else {
      // return false;
    }
  }


  //
  // //http://scm.womenindigital.net/api/form/post/images
  // Future<bool> addImage(String id, String imagePath) async {
  //   String addImageUrl = 'http://scm.womenindigital.net/api/form/post/images';
  //   final prefs = await SharedPreferences.getInstance();
  //   print(id);
  //   print(_image?.path.toString());
  //   Map<String, String> headers = {
  //     'Authorization': 'Bearer ${prefs.getString('token')}',
  //     'Content-Type': 'multipart/form-data',
  //   };
  //   Map<String, String> body = {
  //     'created_by': prefs.getInt('loginID').toString(),
  //     'connection_id': id.toString(),
  //   };
  //   var request = http.MultipartRequest('POST', Uri.parse(addImageUrl))
  //     ..fields.addAll(body)
  //     ..headers.addAll(headers)
  //     ..files.add(await http.MultipartFile.fromPath('photo', _image!.path));
  //   var response = await request.send();
  //   if (kDebugMode) {
  //     print(response.statusCode);
  //   }
  //   if (response.statusCode == 200) {
  //     goBack();
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  goBack() async {
    final prefs = await SharedPreferences.getInstance();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: ((context) => ContactListPage(
                token: 'Bearer ' + prefs.getString('token').toString()))));
  }

  void getConnectionItemList(List<Contact> contactList) {
    for (Contact x in contactList) {
      _mItems.add(x.name.toString());
    }
  }

  //List for connection with DD
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
        if(pickedFile != null) {
          _cropImage(pickedFile);
        } else {
          print('No image selected.');
        }
      });
    } else if (status == 2) {
      final pickedFile = await picker.getImage(source: ImageSource.camera);
      setState(() {
        if(pickedFile != null) {
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
        print("tapped");
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
                          Navigator.pop(context);
                          getImage(1);
                        },
                        child: const Text('Pick Image from Gallery')),
                    ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
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
                          decoration: const BoxDecoration(
                            color: Color(0xfff3f3f4),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          width: width * (38 / 100),
                          height: height * (23 / 100),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/profile-white.png',
                              // _image,
                              width: width * (35 / 100),
                              height: height * (23 / 100),
                              fit: BoxFit.fitHeight,
                            ),
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
              //       color: Color(0xFF926AD3),
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
              style: const TextStyle(
                  color:
                      Color(0xFF9A9A9A)), //editing controller of this TextField
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
                      deleteIcon: Icon(Icons.close,color: Colors.white,),
                      onDeleted: () {
                        setState(() {
                          _checkedItems.remove(e);
                          _mItems.add(e);
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
            style: const TextStyle(color: Color(0xFF9A9A9A)),
            controller: connectedController,
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
            //readOnly: true,
            //Clickable and not editable
            // onTap: () async {
            //   _showMultiSelect();
            // },
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: dobController,
        style: const TextStyle(
            color: Color(0xFF9A9A9A)), //editing controller of this TextField
        decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: icon,
            suffixIcon: Icon(Icons.calendar_month_rounded),
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

  Widget _entryField(String hintText, TextEditingController controller,
      TextCapitalization type, TextInputType inputType, Icon icon,
      {bool isPassword = false}) {
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
    }
    else if (hintText == "Email") {
      return Container(
        margin: EdgeInsets.only(bottom: 10),
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

              //suffixIcon: Icon(Icons.),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF9A9A9A)), //<-- SEE HERE
              ),
              fillColor: Colors.transparent,
              filled: true),
        ),
      );
    }
    else {
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

              //suffixIcon: Icon(Icons.),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF9A9A9A)), //<-- SEE HERE
              ),
              fillColor: Colors.transparent,
              filled: true),
        ),
      );
    }
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
          prefixIcon:  Icon(Icons.phone_rounded),
          fillColor: Colors.transparent,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF9A9A9A)), //<-- SEE HERE
          ),
        ),
        initialCountryCode: 'BD',
        onChanged: (phone) {
          _completePhnNo =  phone.countryCode +"-"+ phone.number +"-"+ phone.countryISOCode;
          print("COMPLETE NUMBER  "+ phone.countryISOCode + phone.countryCode + phone.number);
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
          nameController,
          TextCapitalization.words,
          TextInputType.name,
          Icon(Icons.person),
        ),
        _entryField(
          "Designation",
          designationController,
          TextCapitalization.words,
          TextInputType.text,
          Icon(Icons.workspace_premium_rounded),
        ),
        _entryField(
          "Organization",
          organizationController,
          TextCapitalization.words,
          TextInputType.text,
          Icon(Icons.work_rounded),
        ),
        _phoneEntryField(),
        // _entryField(
        //   "Phone",
        //   phoneController,
        //   TextCapitalization.none,
        //   TextInputType.phone,
        //   Icon(Icons.phone_rounded),
        // ),
        _entryField(
          "Email",
          emailController,
          TextCapitalization.none,
          TextInputType.emailAddress,
          Icon(Icons.email_rounded),
        ),
        _dateOfBirth("Birthday", Icon(Icons.cake_rounded)),
        _genderDropDown("Male", Icon(Icons.calendar_today)),
        _entryField(
          "Address",
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
          socialMediaController,
          TextCapitalization.none,
          TextInputType.text,
          Icon(Icons.insert_link_rounded),
        ),
        _entryField(
          "Note",
          noteController,
          TextCapitalization.sentences,
          TextInputType.text,
          Icon(Icons.note_alt_rounded),
        ),

        // _entryField("Password", isPassword: true),
      ],
    );
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
            if(nameController.text.isNotEmpty) {
              setState(() {
                _showDialog();
              });
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
            child: const Text('    Exit    ',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }

  Future<void> _showDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Exit'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('If you exit all input text will vanish.'),
                Text('Do you really want to exit?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => {
                Navigator.pop(context, 'Cancel'),
              Navigator.pop(context),
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('No'),
            ),
          ],
        );
      },
    );
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

  Widget _saveButton() {
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
                        style: TextStyle(fontSize: 18,color: Colors.white),
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
          if(_completePhnNo== ''){
            submitForm(
                nameController.text.toString(),
                designationController.text.toString(),
                organizationController.text.toString(),
                connectedController.text.toString(),
                phoneController.text.toString(),
                emailController.text.toString(),
                dobController.text.toString(),
                genderController.text.toString(),
                addressController.text.toString(),
                socialMediaController.text.toString(),
                noteController.text.toString());
          } else {
            submitForm(
                nameController.text.toString(),
                designationController.text.toString(),
                organizationController.text.toString(),
                connectedController.text.toString(),
                _completePhnNo.toString(),
                emailController.text.toString(),
                dobController.text.toString(),
                genderController.text.toString(),
                addressController.text.toString(),
                socialMediaController.text.toString(),
                noteController.text.toString());
          }
        }

        //Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 15, 20, 0),
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        child: const Text('  Save  ',
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  List<String> getCheckedItemsID(List<String> checkedItems) {
    List<Contact> selectedContact = [];
    List<String> selectedContactIds = [];
    for (String s in checkedItems) {
      for (int i = 0; i < widget.contactList.length; i++) {
        if (widget.contactList[i].name != null) {
          if (widget.contactList[i].name!.contains(s)) {
            selectedContact.add(widget.contactList[i]);
          }
        }
      }
    }
    for (Contact x in selectedContact) {
      selectedContactIds.add(x.id.toString());
    }
    if(connectedController.text.isNotEmpty) {
      selectedContactIds.add(connectedController.text.toString());
    }
    return selectedContactIds;
  }

  Widget _submitButton() {
    return Container(
      //width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xfffbb448), Color(0xfff7892b)])),
      child: Text(
        'Submit',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    //print(width.toString());
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        color: Colors.white,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: (width * (870 / 1080)),
                        width: width,
                        child: Image.asset('assets/images/add-user.png'),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        margin: EdgeInsets.only(top: 30),
                        height: (width * (870 / 1080)),
                        width: width,
                        child: Center(
                          child: _imagePicker(height, width),
                        ),
                      ),
                    ],
                  ),
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
            Positioned(top: 30, right: 0, child: _saveButton()),
          ],
        ),
      ),
    );
  }
}
// class DialogExample extends StatelessWidget {
//   const DialogExample({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return TextButton(
//       onPressed: () => showDialog<String>(
//         context: context,
//         builder: (BuildContext context) => AlertDialog(
//           title: const Text('AlertDialog Title'),
//           content: const Text('AlertDialog description'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.pop(context, 'Cancel'),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context, 'OK'),
//               child: const Text('OK'),
//             ),
//           ],
//         ),
//       ),
//       child: const Text('Show Dialog'),
//     );
//   }
// }

