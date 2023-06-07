
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddMemberToGroup extends StatefulWidget {
  String groupName;
  String groupId;
  AddMemberToGroup({Key? key, required this.groupName, required this.groupId}) : super(key: key);

  @override
  State<AddMemberToGroup> createState() => _AddMemberToGroupState();
}

class _AddMemberToGroupState extends State<AddMemberToGroup> {
  final _sentInviteFormKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    emailController.text = '';
    return Center(
      child: Form(
        key: _sentInviteFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 40),
              child: Text('Add Member', style: TextStyle(fontSize: 20, color: Color(0xFF926AD3),fontWeight: FontWeight.w500),),
            ),
            //quantity": 0, "unit": "string", "unitValue": 0, "pastQuantity": 0
            _textInputField(
                'Email', emailController, TextInputType.emailAddress),
            const SizedBox(
              height: 20,
            ),

            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text("Cancel"),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_sentInviteFormKey.currentState!.validate()) {
                      await _inviteToGroup(emailController.text);
                      Future.delayed(Duration(milliseconds: 100), () {
                        Get.back(); // Close the sheet after the request is completed and the snackbar is closed
                      });
                    }
                  },
                  child: Text('Submit'),
                  //child: (_quantityCircularIndicator) ? Text("Loading...") : const Text('okay'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
  Widget _textInputField(
      String field, TextEditingController controller, TextInputType inputType) {
    controller.text = '';
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      keyboardType: inputType,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: '$field',
      ),
      // The validator receives the text that the user has entered.
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$field is required';
        }
        return null;
      },
    );
  }

  _inviteToGroup(String email) async {
    final prefs = await SharedPreferences.getInstance();
    String uri = 'https://scm.womenindigital.net/api/search-and-send-invite';
    Map<String, String> headers = {
      "Accept": 'application/json',
      'Authorization': 'Bearer ${prefs.getString('token')}'
    };
    Map<String, String> body = {
      'group_id': widget.groupId.toString(),
      'group_name': widget.groupName.toString(),
      'email': email
    };
    Response response =
    await post(Uri.parse(uri), headers: headers, body: body);
    //var request = http.post(Uri.parse(uri), headers: headers, body: body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.body.toString());
      var data = jsonDecode(response.body.toString());
      print(data['massage']);
      if(data['massage'] == 'not user') {
        Get.snackbar('Error', 'Not a user of SCM. Try Again!',
            colorText: Colors.white,
            backgroundColor: Color(0xFF926AD3),
            snackPosition: SnackPosition.BOTTOM);
      } else if (data['massage'] == 'All Ready exists') {
        Get.snackbar('Error', 'Already exists or sent invitation. Wait for approval!',
            colorText: Colors.white,
            backgroundColor: Color(0xFF926AD3),
            snackPosition: SnackPosition.BOTTOM);
      }
      setState(() {
        //_circularIndicator = false;
      });
    } else {
      setState(() {
        //_circularIndicator = false;
      });
      Get.snackbar('Error', 'Group invitation sent is failed. Try Again!',
          colorText: Color(0xFF926AD3),
          backgroundColor: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
