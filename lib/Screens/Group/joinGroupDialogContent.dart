import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Model/group.dart';

class JoinGroupDialogContent extends StatefulWidget {
  const JoinGroupDialogContent({Key? key}) : super(key: key);

  @override
  State<JoinGroupDialogContent> createState() => _JoinGroupDialogContentState();
}

class _JoinGroupDialogContentState extends State<JoinGroupDialogContent> {
  final _joinGroupSearchFormKey = GlobalKey<FormState>();
  TextEditingController joinGroupNameController = TextEditingController();
  TextEditingController joinGroupOwnerEmailController = TextEditingController();
  String joinSearchUri = 'https://scm.womenindigital.net/api/search-for-join';
  String joinGroupUri = 'https://scm.womenindigital.net/api/sent-join';
  bool _searchCircularIndicator = false;
  bool _joinCircularIndicator = false;
  bool _validate = false;
  bool status = false;
  String errorText = 'Group not found!';
  late String groupName;
  late String ownerEmail;
  late String groupID;

  Map<String, String> body = {};
  Map<String, String> body2 = {};
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: (status)
          ? Column(
              children: [
                // IconButton(onPressed: () => {
                // }, icon: Icon(Icons.chevron_left_outlined)),
                Padding(
                  padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 18),
                  child: Text(
                    'Join Group',
                    style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF926AD3),
                        fontWeight: FontWeight.w500),
                  ),
                ),
                _textShowField('Group Name', joinGroupNameController),
                SizedBox(
                  height: 20,
                ),
                _textShowField('Owner\'s Email', joinGroupOwnerEmailController),
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
                          side: BorderSide(color: Color(0xFF926AD3))
                          // Background color
                          ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        body2 = {
                          'group_id': groupID,
                          'group_name': groupName,
                        };
                        print(groupID + groupName);
                        setState(() {
                          _joinCircularIndicator = true;
                        });
                        await _postMethod(joinGroupUri, body2,
                            _joinCircularIndicator, 'join');
                        setState(() {
                          _joinCircularIndicator = false;
                        });
                        Future.delayed(Duration(milliseconds: 100), () {
                          Get.back(); // Close the sheet after the request is completed and the snackbar is closed
                          Get.snackbar('Success!',
                              'Joining Request has been sent. Please wait for approval from group owner!',
                              colorText: Colors.white,
                              backgroundColor: Color(0xFF926AD3),
                              snackPosition: SnackPosition.BOTTOM);
                        });
                      },
                      child: (_joinCircularIndicator)
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
                                Text(" Joining "),
                              ],
                            )
                          : Text("   Join   "),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 14),
                  child: Text(
                    'Search Group',
                    style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF926AD3),
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Form(
                  key: _joinGroupSearchFormKey,
                  child: Column(
                    children: [
                      _textInputField('Group Name', joinGroupNameController,
                          TextInputType.name, TextCapitalization.words),
                      SizedBox(
                        height: 20,
                      ),
                      _textInputField(
                          'Owner\'s Email',
                          joinGroupOwnerEmailController,
                          TextInputType.emailAddress,
                          TextCapitalization.none),
                      SizedBox(
                        height: 20,
                      ),
                    ],
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
                          side: BorderSide(color: Color(0xFF926AD3))
                          // Background color
                          ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                        onPressed: () async => {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_joinGroupSearchFormKey.currentState!
                                  .validate())
                                {
                                  body = {
                                    'group_name': joinGroupNameController.text,
                                    'email': joinGroupOwnerEmailController.text
                                  },
                                  await _postMethod(joinSearchUri, body,
                                      _searchCircularIndicator, 'search'),
                                  setState(() {
                                    _searchCircularIndicator = false;
                                  }),
                                  Future.delayed(Duration(milliseconds: 100), ) ,
                                }
                            },
                        child: (_searchCircularIndicator)
                            ? Row(
                                children: [
                                  CircularProgressIndicator(
                                    strokeWidth: 3,
                                    backgroundColor: Colors.white,
                                  ),
                                  Text(" Searching "),
                                ],
                              )
                            : Text("  Search  ")),
                  ],
                ),
              ],
            ),
    );
  }

  void back() {
    Get.back();
  }

  _postMethod(String uri, Map<String, String> body, bool circularIndicator,
      String callFor) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, String> headers = {
      "Accept": 'application/json',
      'Authorization': 'Bearer ${prefs.getString('token')}'
    };
    Response response =
        await post(Uri.parse(uri), headers: headers, body: body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      print(response.body.toString());
      final jsonBody = jsonDecode(response.body);
      final message = jsonBody['message'] as String;
      print(body.entries.last.value);
      if (message == 'Group not found') {
        setState(() {
          _validate = true;
        });
      } else if (message == 'Find Group') {
        final responseBody = jsonBody['data'] as Map<String, dynamic>;
        print(responseBody);
        Group groupInfo = Group.fromJson(responseBody);
        setState(() {
          groupID = groupInfo.groupId.toString();
          groupName = groupInfo.groupName.toString();
          _validate = false;
          status = true;
        });
      } else if (message == 'Successfully Send invitation') {
        Get.snackbar('',
            'Joining Request has been sent. Please wait for approval from group owner!',
            colorText: Colors.white,
            backgroundColor: Color(0xFF926AD3),
            snackPosition: SnackPosition.BOTTOM);
        back();
      }
    }
    if (response.statusCode == 422) {
      if (callFor == 'join') {
        Get.snackbar('',
            'Joining Request has been sent already. Please wait for approval from group owner!',
            colorText: Colors.white,
            backgroundColor: Color(0xFF926AD3),
            snackPosition: SnackPosition.BOTTOM);

        back();
      }
      if (callFor == 'search') {
        Get.snackbar('Warning', 'Please Try Again!',
            colorText: Colors.white,
            backgroundColor: Color(0xFF926AD3),
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Widget _textShowField(
    String field,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      enabled: false, // Set enabled to false to make it read-only
      textInputAction: TextInputAction.next,
      //keyboardType: inputType,
      //textCapitalization: capitalizationValue,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF926AD3)),
        ), // Set the border color here),
        labelText: '$field',
        //errorText: _validate ? errorText : null,
      ),
    );
  }

  Widget _textInputField(String field, TextEditingController controller,
      TextInputType inputType, TextCapitalization capitalizationValue) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      keyboardType: inputType,
      textCapitalization: capitalizationValue,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: '$field',
        errorText: _validate ? errorText : null,
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
}
