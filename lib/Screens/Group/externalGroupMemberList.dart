import 'dart:convert';

import 'package:community_app/Screens/Group/groupListPage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import '../../Model/contact.dart';
import '../contactListPage.dart';

class ExternalGroupMemberList extends StatefulWidget {
  String groupName;
  String groupId;

  ExternalGroupMemberList({Key? key, required this.groupName, required this.groupId})
      : super(key: key);

  @override
  State<ExternalGroupMemberList> createState() => _ExternalGroupMemberListState();
}

class _ExternalGroupMemberListState extends State<ExternalGroupMemberList> {
  late Future<List<Contact>> _futureMemberList;
  //https://scm.womenindigital.net/api/my-group-list/{group_id}
  String removeMemberUri =
      'https://scm.womenindigital.net/api/delete-group-member';
  String exGroupMemberListUri = 'https://scm.womenindigital.net/api/external-group-member/';

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    print(widget.groupName + " " + widget.groupId);
    //_futureMemberList = fetchGroupMember(myGroupMemberListUri);
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
              future: fetchGroupMember(exGroupMemberListUri),
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
                      return const Center(
                        child: Text(
                          "No member added yet!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    else if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(
                          "No member added yet!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white,),
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
                                  item.name.toString() +' ',
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
                                // trailing: IconButton(
                                //   icon: Icon(
                                //     Icons.remove_circle_outline_rounded,
                                //     color: Colors.white,
                                //   ),
                                //   onPressed: () {
                                //     _removeMember(removeMemberUri, widget.groupName,
                                //         item.email.toString());
                                //   },
                                // ),
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
                      Icons.remove_circle_outline_rounded,
                      color: Color(0xFF926AD3),
                    ),
                  ),
                  Text("   Leave Group"),
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
              print("Leave Group menu is selected.");
              _leaveGroupDialog();
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
      print (response.body);
      final data = jsonBody['data'] as List<dynamic>;
      if (data.isEmpty) {
        print("Empty");
      }
      return data.map((jsonData) => Contact.fromJson(jsonData)).toList();
    } else {
      throw Exception('Failed to fetch groups');
    }
  }

  _leaveGroupDialog() {
    return Get.defaultDialog(
      title: "Leave Group",
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
            _removeMember(removeMemberUri, widget.groupName,
                ContactListPage.user[0].email.toString());
            Get.to(() => GroupListPage());
            },
          child: Text('Leave')),
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
      Get.snackbar('Error', 'Try Again!',
          colorText: Color(0xFF926AD3),
          backgroundColor: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
