import 'dart:convert';
import 'package:community_app/Screens/Group/externalGroupMemberList.dart';
import 'package:community_app/Screens/Group/myGroupSingleView.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Model/group.dart';
import '../../Model/group_invitation.dart';
import '../Auth/loginPage.dart';
import '../Auth/settingsPage.dart';
import '../User/userProfilePage.dart';
import '../contactListPage.dart';
import 'joinGroupDialogContent.dart';
import 'groupNotification.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({Key? key}) : super(key: key);

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  late Future<List<Group>> _futureGroupList;
  late Future<List<Group>> _exFutureGroupList;
  late Future<List<GroupInvitation>> _invitationList;
  late Future<List<Group>> _joinReqList;
  TextEditingController groupNameController = TextEditingController();
  TextEditingController joinGroupNameController = TextEditingController();
  TextEditingController joinGroupOwnerEmailController = TextEditingController();
  bool _circularIndicator = false;
  bool _searchCircularIndicator = false;
  bool _status = false;
  final _createGroupFormKey = GlobalKey<FormState>();
  final _joinGroupSearchFormKey = GlobalKey<FormState>();
  String myGroupUri = 'https://scm.womenindigital.net/api/my-group';
  String externalGroupUri = 'https://scm.womenindigital.net/api/external-group';
  String joinSearchUri = 'https://scm.womenindigital.net/api/search-for-join';
  String joinReqListUri =
      'https://scm.womenindigital.net/api/show-join-invitation';
  String invitationListUri =
      'https://scm.womenindigital.net/api/show-invitation';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getGroupList();
    _futureGroupList = fetchGroups(myGroupUri, "myGroupList");
    _exFutureGroupList = fetchGroups(externalGroupUri, "externalGroupList");
    _joinReqList = fetchGroups(joinReqListUri, "joinRequestList");
    _invitationList = fetch(invitationListUri, "invitationList");
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            title: Text("Groups"),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: PopupMenuButton(
                    // add icon, by default "3 dot" icon
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem<int>(
                          value: 0,
                          child: Text(
                            " Create Group ",
                            style: TextStyle(
                              color: Color(0xFF926AD3),
                            ),
                          ),
                        ),
                        PopupMenuItem<int>(
                          value: 1,
                          child: Text(
                            " Join Group ",
                            style: TextStyle(
                              color: Color(0xFF926AD3),
                            ),
                          ),
                        ),
                      ];
                    },
                    onSelected: (value) async {
                      if (value == 0) {
                        if (kDebugMode) {
                          print("Create Group is selected.");
                        }
                        _groupAddDialog();
                        //_onShare(context, 0);
                      } else if (value == 1) {
                        if (kDebugMode) {
                          print("Join Group is selected.");
                        }
                        //_groupJoinDialog();
                        _joinGroupBottomSheet();
                        //_onShare(context, 1);
                      }
                    }),
              ),
              InkWell(
                onTap: () => _notificationDialog(),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
              ),
              _topOptionPopupMenu(),
            ],
            bottom: TabBar(
              tabs: [
                //badge_rounded
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_ind_rounded),
                      Text('My Groups')
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_rate_rounded),
                      Text('External Groups')
                    ],
                  ),
                )
                //Tab(icon: Icon(Icons.star_rate_rounded),text: 'Favourites',)
              ],
            ),
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
            child: TabBarView(children: [
              SafeArea(
                  child: FutureBuilder(
                future: fetchGroups(myGroupUri, "myGroupList"),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Group>> snapshot) {
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
                        "No Group created yet!\nto Create Groups, press the +(plus) icon above.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        "No Group created yet!\nto Create Groups, press the +(plus) icon above.",
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
                                item.groupName.toString(),
                                style: TextStyle(
                                  color: Colors.white, // fontSize: 20
                                ),
                              ),
                              // subtitle: Text(item.role.toString(), style: TextStyle(color: Colors.white),),
                              trailing: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                              onTap: () => {
                                Get.to(() => MyGroupSingleView(
                                  groupName: item.groupName.toString(),
                                  groupId: item.groupId.toString(),
                                )),
                              },
                              // subtitle:
                              //     Text("Price: ${item.productPrice!.price}"),
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
              SafeArea(
                  child: FutureBuilder(
                future: _exFutureGroupList,
                builder: (BuildContext context,
                    AsyncSnapshot<List<Group>> snapshot) {
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
                        "You are not add to any other groups!\nJoin Group, press the +(plus) icon above.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        "You are not add to any other groups!\nJoin Group, press the +(plus) icon above.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white,),
                      ),
                    );
                  }
                  else if (snapshot.hasData) {
                    return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final item = snapshot.data![index];
                          return InkWell(
                            // onTap: () => SingleProductDetailsScreen(product: item,),
                            child: Padding(
                              padding: EdgeInsets.only(left: 20.0, right: 20),
                              child: ListTile(
                                title: Text(
                                  item.groupName.toString(),
                                  style: TextStyle(
                                    color: Colors.white, // fontSize: 20
                                  ),
                                ),
                                // subtitle: Text(item.role.toString(), style: TextStyle(color: Colors.white),),
                                trailing: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                ),
                                onTap: () => {
                                  Get.to(() => ExternalGroupMemberList(
                                      groupName: item.groupName.toString(),
                                      groupId: item.groupId.toString())),
                                },
                                // subtitle:
                                //     Text("Price: ${item.productPrice!.price}"),
                              ),
                            ),
                          );
                        });
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
            ]),
          ),
        ));
  }

  _topOptionPopupMenu() {
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
                      Icons.account_circle_rounded,
                      color: Color(0xFF926AD3),
                    ),
                  ),
                  Text(" Profile"),
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
                      Icons.settings,
                      color: Color(0xFF926AD3),
                    ),
                  ),
                  Text(" Settings"),
                ],
              ),
            ),
            PopupMenuItem<int>(
              value: 2,
              child: Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.logout,
                      color: Color(0xFF926AD3),
                    ),
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
            if (ContactListPage.user!.isNotEmpty ?? true) {
              Get.to(UserProfilePage(
                user: ContactListPage.user[0],
                isChanged: false,
              ));
            }
          } else if (value == 1) {
            if (kDebugMode) {
              print("Settings menu is selected.");
            }
            Get.to(SettingPage());
          } else if (value == 2) {
             logout();
            if (kDebugMode) {
              print("Logout menu is selected.");
            }
          }
        });
  }

  _notificationDialog() {
    return Get.defaultDialog(
      title: "Invitations & Requests",
      backgroundColor: Color(0xFF926AD3),
      titleStyle: TextStyle(color: Colors.white),
      cancel: _cancel(),
      //content: _invitedGroupListview(),
      content: Material(
        child: NotificationDialogContent(),
      ),
    );
  }

  _cancel() {
    return ElevatedButton(
      onPressed: () => Get.back(),
      child: Text(
        "  Close  ",
        style: TextStyle(color: Color(0xFF926AD3)),
      ),
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Color(0xFF926AD3))
          // Background color
          ),
    );
  }

  _groupAddDialog() {
    groupNameController.text = '';
    return Get.defaultDialog(
      title: "Create Group",
      //middleText: "Hello world!",
      backgroundColor: Colors.white,
      titleStyle: TextStyle(color: Color(0xFF926AD3)),
      // middleTextStyle: TextStyle(color: Colors.white),
      confirm: ElevatedButton(
          onPressed: () async => {
                // Validate returns true if the form is valid, or false otherwise.
                if (_createGroupFormKey.currentState!.validate())
                  {
                    setState(() {
                      _circularIndicator = false;
                    }),
                    await _createGroup(groupNameController.text),
                    setState(() {
                      _circularIndicator = true;
                    }),
                    Future.delayed(Duration(milliseconds: 100), () {
                      Get.back(); // Close the sheet after the request is completed and the snackbar is closed
                      Get.snackbar('Congratulations', 'Your group has been created!',
                          colorText: Color(0xFF926AD3),
                          backgroundColor: Colors.white,
                          snackPosition: SnackPosition.BOTTOM);
                    }),
                  }
              },
          child: (_circularIndicator)
              ? Row(
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 3,
                      backgroundColor: Colors.white,
                    ),
                    Text(" Creating "),
                  ],
                )
              : Text("  Create  ")),
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
      content: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
    );
  }

  _joinGroupBottomSheet() {
    return Get.bottomSheet(
      isScrollControlled: true,
      Container(
        height: 350,
        color: Colors.white,
        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: JoinGroupDialogContent(),
      ),
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(35),
      ),
      enableDrag: false,
    );
  }

  Future<List<Group>> fetchGroups(String uri, String key) async {
    final prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse(uri), headers: {
      "Accept": 'application/json',
      'Authorization': 'Bearer ${prefs.getString('token')}'
    });

    if (response.statusCode == 200) {
     // print(response.body.toString());
      final jsonBody = jsonDecode(response.body);
      final data = jsonBody['data'] as List<dynamic>;
      if (data.isEmpty) {
        print("Empty");
      }
      return data.map((jsonData) => Group.fromJson(jsonData)).toList();
    } else {
      throw Exception('Failed to fetch groups');
    }
  }

  Future<List<GroupInvitation>> fetch(String uri, String key) async {
    final prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse(uri), headers: {
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
      return data
          .map((jsonData) => GroupInvitation.fromJson(jsonData))
          .toList();
    } else {
      throw Exception('Failed to fetch groups');
    }
  }

  ///https://scm.womenindigital.net/api/external-group

  _createGroup(String name) async {
    final prefs = await SharedPreferences.getInstance();
    String uri = 'https://scm.womenindigital.net/api/group/create';
    Map<String, String> headers = {
      "Accept": 'application/json',
      'Authorization': 'Bearer ${prefs.getString('token')}'
    };
    Map<String, String> body = {'name': name};
    Response response =
        await post(Uri.parse(uri), headers: headers, body: body);
    //var request = http.post(Uri.parse(uri), headers: headers, body: body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      setState(() {
        _circularIndicator = false;
      });
    } else {
      setState(() {
        _circularIndicator = false;
      });
      Get.snackbar('Error', 'Group not created. Try Again!',
          colorText: Color(0xFF926AD3),
          backgroundColor: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
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
        setState(() {
          Get.offAll(LoginPage());
        });

        // Navigator.pushReplacement(
        //     context, MaterialPageRoute(builder: ((context) => LoginPage())));

        print('Logout successfully');
      } else {
        print('failed${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        "Network Issue",
        "Please check your internet connection!",
        colorText: Colors.white,
        //icon: Icon(Icons.person, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF926AD3),
        duration: Duration(seconds: 4),
        isDismissible: true,
      );
      print(e.toString());
    }
  }
}
