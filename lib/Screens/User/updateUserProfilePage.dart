import 'dart:io';
import 'package:community_app/Screens/User/userProfile.dart';
import 'package:http/http.dart' as http;
import 'package:community_app/Model/contact.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateUserProfilePage extends StatefulWidget {
  Contact user;
  UpdateUserProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<UpdateUserProfilePage> createState() => _UpdateUserProfilePageState();
}

class _UpdateUserProfilePageState extends State<UpdateUserProfilePage> {
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
  String image = 'https://scm.womenindigital.net/storage/uploads/';
  late String photo;
  // Initial Selected Value
  var _image;
  final picker = ImagePicker();
  late String dropdownvalue;
  FocusNode searchFocusNode = FocusNode();
  List<String> _mItems = [];
  bool readOnly = true;
  FocusNode f1 = FocusNode();
  bool showSpinner = false;
  bool isLoading = false;
  bool _validate = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    valueInitialization();
  }

  void valueInitialization() {
    if (widget.user.name?.isEmpty ?? true) {
      nameController.text = "";
    } else {
      nameController.text = widget.user.name.toString();
    }
    // if (widget.contact.photo?.isEmpty ?? true) {
    //   photo = "";
    // } else {
    //   photo = widget.contact.photo.toString();
    // }

    if (widget.user.phone_no?.isEmpty ?? true) {
      phoneController.text = "";
    } else {
      phoneController.text = widget.user.phone_no.toString();
    }

    if (widget.user.email?.isEmpty ?? true) {
      emailController.text = "";
    } else {
      emailController.text = widget.user.email.toString();
    }

    if (widget.user.designation?.isEmpty ?? true) {
      designationController.text = "";
    } else {
      designationController.text = widget.user.designation.toString();
    }

    if (widget.user.organization?.isEmpty ?? true) {
      organizationController.text = "";
    } else {
      organizationController.text = widget.user.organization.toString();
    }
    if(widget.user.photo?.isEmpty ?? true) {
      photo = "202302151206-profile-white.png";
    } else {
      photo = widget.user.photo.toString();
    }


    if (widget.user.gender?.isEmpty ?? true) {
      dropdownvalue = 'Male';
     //genderController.text = "";
    } else {
      genderController.text = widget.user.gender.toString();
      dropdownvalue = widget.user.gender.toString();
    }

    if (widget.user.address?.isEmpty ?? true) {
      addressController.text = " ";
    } else {
      addressController.text = widget.user.address.toString();
    }

    if (widget.user.social_media?.isEmpty ?? true) {
      socialMediaController.text = " ";
    } else {
      socialMediaController.text = widget.user.social_media.toString();
    }

    if (widget.user.note?.isEmpty ?? true) {
      noteController.text = " ";
    } else {
      noteController.text = widget.user.note.toString();
    }
    // print('$name : $photo : $phone_no : $email : $designation : $organization : $dob :'
    //     '$gender : $address : $connections : $socialLinks : $note');
  }
  ///api/profile/update-profile
  Future<void> submitForm(String name,String designation,String organization,String connected_id,
      String phone_no,String email,String date_of_birth,String gender,String address,
      String social_media,String note) async {
    final prefs = await SharedPreferences.getInstance();
    String id = widget.user.id.toString();
    var uriData = 'http://scm.womenindigital.net/api/profile/update-profile';

    Map<String, String> headers = {
      "Accept": 'application/json',
      'Authorization': 'Bearer ${prefs.getString('token')}'
    };
    Map<String, String> body = {
      'name': name,
      'designation': designation,
      'organization': organization,
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
      print("Body $name $designation $organization "
          "$phone_no $email $date_of_birth $gender $address $social_media  $note"
          " ${prefs.getInt('loginID')}");
    }
    // name, designation, organization, connected_id, phone_no, email,
    // date_of_birth, gender, address, social_media, note, photo
    //http://scm.womenindigital.net/api/connection/19/update

    var request = http.MultipartRequest('POST', Uri.parse(uriData));
    if (kDebugMode) {
      print("IMAGE $_image " );
    }
    if (_image != null ) {
      //File f = await getImageFileFromAssets('images/profile.png');
      request.headers.addAll(headers);
      request.fields.addAll(body);
      request.files
          .add(await http.MultipartFile.fromPath('photo', _image.path));
    } else {
      // File f = await getImageFileFromAssets('images/profile-white.png');
      request.headers.addAll(headers);
      request.fields.addAll(body);
      //request.files.add(await http.MultipartFile.fromPath('photo', f.path));
    }
    var streamedResponse = await request.send();
    print("STREAM "+streamedResponse.stream.toString());
    var response = await http.Response.fromStream(streamedResponse);
    print(response.body.toString());
    String rawData = response.body.toString().replaceAll("\"", ' ');
    print ("RAW DATA " + rawData);
    if (streamedResponse.statusCode == 200) {
      Navigator.pop(context);
      print('info uploaded  ' + _getPhotoID(rawData).toString() + ".");
      Contact c = Contact(
          id: widget.user.id,
          name: name,
          photo: _getPhotoID(rawData),
          designation: designation,
          organization: organization,
          phone_no: phone_no,
          email: email,
          date_of_birth: date_of_birth,
          gender: gender,
          address: address,
          social_media: social_media,
          note: note,
          created_by: prefs.getInt('loginID'));

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: ((context) => UserProfilePage(
                user: c,
              ))));
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
    String details = value[1].replaceAll(RegExp('[^-A-Za-z0-9,:._@ +]'), '');
    final res = details.split(', ');
    if (kDebugMode) {
      print(res[14]);
    }
    final photoString = res[14].split(': ');
    print("PHOTO STRING: "+ photoString[1].toString());
    String photo = photoString[1].replaceAll(" ", '');
    if (kDebugMode) {
      print(photo);
    }
    return photo;
  }

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

  Widget _updateButton() {
    return InkWell(
      onTap: () {
        setState(() {
          nameController.text.isEmpty ? _validate = true : _validate = false;
          showSpinner = true;
        });

        if (nameController.text.isNotEmpty) {
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
        child: const Text(
            ' Update ',
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ),

    );
  }

  Future getImage(int status) async {
    if (status == 1) {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
    } else if (status == 2) {
      final pickedFile = await picker.getImage(source: ImageSource.camera);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
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
                  child: (_image != null && _image.path != '/')
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      File(_image!.path).absolute,
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
                      child: Image.network(image + photo,fit: BoxFit.fitHeight,),
                    ),
                  ),
                ),
              ),
              Positioned(bottom: 0, right: 15 , child: _cameraIcon()),

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
      child:  CircleAvatar(
        backgroundColor:  Color(0xFF926AD3),
        radius: 20,
        child: Icon(Icons.camera_alt,color: Colors.white,),
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
              controller:
              genderController,
              style: TextStyle(color: Color(0xFF926AD3)),//editing controller of this TextField
              decoration: InputDecoration(
                  hintText: dropdownvalue,
                  suffixIcon: _genderSuffixPopUpMenu(),
                  prefixIcon: _genderPrefixPopUpMenu(),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF9A9A9A)), //<-- SEE HERE
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

  Widget _dateOfBirth(String hintText, Icon icon) {
    // if (dob != " ") {
    //   dobController.text = dob;
    // }
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: dobController,
        style: TextStyle(color: Color(0xFF926AD3)),//editing controller of this TextField
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
              firstDate: DateTime(
                  2000), //DateTime.now() - not to allow to choose before today.
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        //enabled: false, //Not clickable and not editable
        keyboardType: inputType,
        textInputAction: TextInputAction.next,
        textCapitalization: type,
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Color(0xFF926AD3)),//editing controller of this TextField
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
        _entryField(
          "Phone",
          //phone_no,
          phoneController,
          TextCapitalization.none,
          TextInputType.phone,
          Icon(Icons.phone_rounded),
        ),
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
                  Container(width: width,height: (width * (870 / 1080)),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          right: 0,
                          height: (width * (870 / 1080)),
                          width: width,
                          child: Image.asset('assets/images/add-user.png'),
                        ),
                        Positioned(top: 90,width: width, child: Center(child: _imagePicker(height, width))),
                      ],
                    ),),
                  SizedBox(height: 10),
                  Container(
                      margin: EdgeInsets.only(left: 20,right: 20),
                      child: _textFieldWidget()),
                ],
              ),
            ),
            Positioned(top: 0 ,height: 50,child: Image.asset('assets/images/overlay.png')),
            Positioned(top: 30, left: 0, child: _backButton()),
            Positioned(top: 30, right: 0, child: _updateButton()),
          ],
        ),
      ),
    );
  }
}
