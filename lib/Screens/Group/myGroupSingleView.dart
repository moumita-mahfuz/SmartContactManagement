import 'dart:convert';

import 'package:community_app/Screens/Group/groupListPage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import '../../Model/contact.dart';

class MyGroupSingleView extends StatefulWidget {
  String groupName;
  String groupId;

  MyGroupSingleView({Key? key, required this.groupName, required this.groupId})
      : super(key: key);

  @override
  State<MyGroupSingleView> createState() => _MyGroupSingleViewState();
}

class _MyGroupSingleViewState extends State<MyGroupSingleView> {
  late Future<List<Contact>> _futureMemberList;
  //https://scm.womenindigital.net/api/my-group-list/{group_id}
  String myGroupMemberListUri =
      'https://scm.womenindigital.net/api/my-group-list/';
  String deleteGroupUri = 'https://scm.womenindigital.net/api/delete-group/';
  String removeMemberUri =
      'https://scm.womenindigital.net/api/delete-group-member';
  String exGroupMemberListUri =
      'https://scm.womenindigital.net/api/external-group-member/';

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    print(widget.groupName + " " + widget.groupId);

    _futureMemberList = fetchGroupMember(myGroupMemberListUri);
  }

  final _sentInviteFormKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text("Group: " + widget.groupName.toString()),
        actions: [
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: InkWell(
              onTap: () => _inviteBottomSheet(),
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
          _topPopupMenu(),
        ],
      ),
      body: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
            //child: Text("under construction"),
            child: FutureBuilder(
          future: _futureMemberList,
          builder:
              (BuildContext context, AsyncSnapshot<List<Contact>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }
            else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  "No member added yet!\nAdd member, press the +(plus) icon above.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
            }
            else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  "No member added yet!\nAdd member, press the +(plus) icon above.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
            }
            else if (snapshot.hasData) {
              return Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20),
                child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data![index];
                      return ListTile(
                        title: Text(
                          item.name.toString(),
                          style: TextStyle(
                            color: Colors.white, // fontSize: 20
                          ),
                        ),
                        subtitle: Text(
                          item.email.toString(),
                          style: TextStyle(
                            color: Colors.white, // fontSize: 20
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.remove_circle_outline_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _removeGroupMemberDialog(item.email.toString());
                          },
                        ),
                      );
                    }),
              );
            }
            else {
              return const Center(
                child: Text(
                  "Something went wrong",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
          },
        )),
      ),
    );
  }

  _inviteBottomSheet() {
    emailController.text = '';
    return Get.bottomSheet(
      isScrollControlled: true,
      Container(
        height: 300,
        color: Colors.white,
        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: Center(
          child: Form(
            key: _sentInviteFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 40),
                  child: Text(
                    'Add Member',
                    style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF926AD3),
                        fontWeight: FontWeight.w500),
                  ),
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
        ),
      ),
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(35),
      ),
      enableDrag: false,
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
      if (data['massage'] == 'not user') {
        Get.snackbar('Error', 'Not a user of SCM. Try Again!',
            colorText: Colors.white,
            backgroundColor: Color(0xFF926AD3),
            snackPosition: SnackPosition.BOTTOM);
      } else if (data['massage'] == 'All Ready exists') {
        Get.snackbar(
            'Error', 'Already exists or sent invitation. Wait for approval!',
            colorText: Colors.white,
            backgroundColor: Color(0xFF926AD3),
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      Get.snackbar('Error', 'Group invitation sent is failed. Try Again!',
          colorText: Color(0xFF926AD3),
          backgroundColor: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  _topPopupMenu() {
    return PopupMenuButton(
        // add icon, by default "3 dot" icon
        icon: const Icon(
          Icons.more_vert_rounded,
          color: Colors.white,
        ),
        itemBuilder: (context) {
          return [
            PopupMenuItem<int>(
              value: 0,
              child: Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.settings,
                      color: Color(0xFF926AD3),
                    ),
                  ),
                  Text("  Group Settings"),
                ],
              ),
            ),
            PopupMenuItem<int>(
              value: 1,
              child: Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.delete,
                      color: Color(0xFF926AD3),
                    ),
                  ),
                  Text("   Delete Group"),
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
              print("Delete menu is selected.");
              _deleteGroupDialog();
            }
          }
        });
  }

  Widget _textInputField(
      String field, TextEditingController controller, TextInputType inputType) {
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

  Future<List<Contact>> fetchGroupMember(String uri) async {
    final prefs = await SharedPreferences.getInstance();
    String url = uri + widget.groupId;
    final response = await http.get(Uri.parse(url), headers: {
      "Accept": 'application/json',
      'Authorization': 'Bearer ${prefs.getString('token')}'
    });

    if (response.statusCode == 200) {
      print(response.body.toString());
      final jsonBody = jsonDecode(response.body);
      final data = jsonBody['data'] as List<dynamic>;
      if (data.isEmpty) {
        print("Empty");
      }
      return data.map((jsonData) => Contact.fromJson(jsonData)).toList();
    } else {
      throw Exception('Failed to fetch groups');
    }
  }

  _deleteGroupDialog() {
    return Get.defaultDialog(
      title: "Delete Group",
      backgroundColor: Colors.white,
      titleStyle: TextStyle(color: Color(0xFF926AD3)),
      // middleTextStyle: TextStyle(color: Colors.white),
      cancel: ElevatedButton(
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
      content: Text("Are you sure?"),
      confirm: ElevatedButton(
          onPressed: () {
            _deleteGroup(deleteGroupUri);
            Get.to(() => GroupListPage());
          },
          child: Text('DELETE')),
    );
  }

  _deleteGroup(String uri) async {
    final prefs = await SharedPreferences.getInstance();
    uri = uri + widget.groupId;
    final response = await http.delete(Uri.parse(uri), headers: {
      "Accept": 'application/json',
      'Authorization': 'Bearer ${prefs.getString('token')}'
    });
    if (response.statusCode == 200) {
      print(response.body.toString());
    } else {
      throw Exception('Failed to Delete group');
    }
  }

  _removeGroupMemberDialog(String email) {
    return Get.defaultDialog(
      title: "Remove Group Member",
      backgroundColor: Colors.white,
      titleStyle: TextStyle(color: Color(0xFF926AD3)),
      // middleTextStyle: TextStyle(color: Colors.white),
      cancel: ElevatedButton(
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
      content: Text("Are you sure?"),
      confirm: ElevatedButton(
          onPressed: () async {
            await _removeMember(removeMemberUri, widget.groupName, email);
            Future.delayed(Duration(milliseconds: 100), () {
              Get.back(); // Close the sheet after the request is completed and the snackbar is closed
              Get.snackbar('Success!', 'Member has been removed.',
                  colorText: Colors.white,
                  backgroundColor: Color(0xFF926AD3),
                  snackPosition: SnackPosition.BOTTOM);
            });
          },
          child: Text('REMOVE')),
    );
  }

  _removeMember(String uri, String group_name, String user_email) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, String> headers = {
      "Accept": 'application/json',
      'Authorization': 'Bearer ${prefs.getString('token')}'
    };
    Map<String, String> body = {
      'group_name': group_name,
      'user_email': user_email
    };
    Response response =
        await post(Uri.parse(uri), headers: headers, body: body);
    //var request = http.post(Uri.parse(uri), headers: headers, body: body);
    print(response.statusCode);
    if (response.statusCode == 200) {
    } else {
      Get.snackbar('Error', 'Group not created. Try Again!',
          colorText: Color(0xFF926AD3),
          backgroundColor: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
