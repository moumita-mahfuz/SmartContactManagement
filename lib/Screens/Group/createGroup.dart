import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({Key? key}) : super(key: key);

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final _createGroupFormKey = GlobalKey<FormState>();
  TextEditingController groupNameController = TextEditingController();
  bool _circularIndicator = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(8.0, 14, 8.0, 14),
            child: Text(
              'Create Group',
              style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF926AD3),
                  fontWeight: FontWeight.w500),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _createGroupFormKey,
                child: TextFormField(
                  controller: groupNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Group Name',
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Group Name is required!';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () => Get.back(),
                child: Text(
                  "  Cancel  ",
                  style: TextStyle(color: Color(0xFF926AD3)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Color(0xFF926AD3)),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                  onPressed: () async => {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_createGroupFormKey.currentState!.validate())
                          {
                            // setState(() {
                            //   _circularIndicator = true;
                            // }),
                            await _createGroup(groupNameController.text),
                          //   setState(() {
                          //     _circularIndicator = false;
                          //   }),
                          // Get.back(),
                          //   Future.delayed(Duration(milliseconds: 100), () {
                          //     Get.back(); // Close the sheet after the request is completed and the snackbar is closed
                          //   }),
                          }
                      },
                  child: (_circularIndicator)
                      ? Row(
                          children: [
                            SizedBox(
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                backgroundColor: Colors.white,
                              ),
                              height: 12,
                              width: 12,
                            ),
                            Text(" Creating "),
                          ],
                        )
                      : Text("  Create  ")),
            ],
          ),
          Spacer(),
          Spacer(),
        ],
      ),
    );
  }
  _createGroup(String name) async {
    final prefs = await SharedPreferences.getInstance();
    String uri = 'https://scm.womenindigital.net/api/group/create';
    Map<String, String> headers = {
      "Accept": 'application/json',
      'Authorization': 'Bearer ${prefs.getString('token')}'
    };
    Map<String, String> body = {'name': name};

    setState(() {
      _circularIndicator = true;
    });

    try {
      Response response = await post(Uri.parse(uri), headers: headers, body: body);

      print(response.statusCode);

      if (response.statusCode == 200) {
        Get.snackbar('Congratulations', 'Your group has been created!',
            colorText: Color(0xFF926AD3),
            backgroundColor: Colors.white,
            snackPosition: SnackPosition.BOTTOM);

        // Close the sheet after the snackbar is shown
          Future.delayed(Duration(milliseconds: 1500), () {
            Get.back(); // Close the sheet after the request is completed and the snackbar is closed
          });
        Get.back();
      } else if (response.statusCode == 404) {
        Get.snackbar('Error', 'Group already created. Try with another Name!',
            colorText: Color(0xFF926AD3),
            backgroundColor: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', 'Group not created. Try Again!',
            colorText: Color(0xFF926AD3),
            backgroundColor: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (error) {
      print(error.toString());
      Get.snackbar('Error', 'An error occurred. Please try again later.',
          colorText: Color(0xFF926AD3),
          backgroundColor: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() {
        _circularIndicator = false;
      });
    }
  }
  // _createGroup(String name) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   String uri = 'https://scm.womenindigital.net/api/group/create';
  //   Map<String, String> headers = {
  //     "Accept": 'application/json',
  //     'Authorization': 'Bearer ${prefs.getString('token')}'
  //   };
  //   Map<String, String> body = {'name': name};
  //   Response response =
  //       await post(Uri.parse(uri), headers: headers, body: body);
  //   //var request = http.post(Uri.parse(uri), headers: headers, body: body);
  //   print(response.statusCode);
  //   if (response.statusCode == 200) {
  //     setState(() {
  //       _circularIndicator = false;
  //     });
  //     Get.snackbar('Congratulations',
  //         'Your group has been created!',
  //         colorText: Color(0xFF926AD3),
  //         backgroundColor: Colors.white,
  //         snackPosition: SnackPosition.BOTTOM);
  //   } else if(response.statusCode == 404) {
  //     setState(() {
  //       _circularIndicator = false;
  //     });
  //     Get.snackbar('Error', 'Group already created. Try with another Name!',
  //         colorText: Color(0xFF926AD3),
  //         backgroundColor: Colors.white,
  //         snackPosition: SnackPosition.BOTTOM);
  //   }else {
  //     setState(() {
  //       _circularIndicator = false;
  //     });
  //     Get.snackbar('Error', 'Group not created. Try Again!',
  //         colorText: Color(0xFF926AD3),
  //         backgroundColor: Colors.white,
  //         snackPosition: SnackPosition.BOTTOM);
  //   }
  // }
}
