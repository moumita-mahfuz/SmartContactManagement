import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:page_indicator/page_indicator.dart';

import '../../Model/group.dart';
import '../../Model/group_invitation.dart';

class NotificationDialogContent extends StatefulWidget {
  NotificationDialogContent({Key? key}) : super(key: key);

  @override
  State<NotificationDialogContent> createState() =>
      _NotificationDialogContentState();
}

class _NotificationDialogContentState extends State<NotificationDialogContent> {
  late Future<List<GroupInvitation>> _invitationList;
  late Future<List<Group>> _joinReqList;
  bool invitationStatus = true, joinStatus = true;
  String joinReqListUri =
      'https://scm.womenindigital.net/api/show-join-invitation';
  String invitationListUri =
      'https://scm.womenindigital.net/api/show-invitation';
  String rejectInvitationUri =
      'https://scm.womenindigital.net/api/delete-invitation/'; //
  String acceptInvitationUri =
      'https://scm.womenindigital.net/api/accept-invitation/';
  String rejectJoinUri =
      'https://scm.womenindigital.net/api/delete-join-invitation/';
  String acceptJoinUri =
      'https://scm.womenindigital.net/api/accept-join-invitation/';
  List<GroupInvitation> _invitationListData = [];
  List<Group> _joinReqListData = [];
  int _selectedItemIndex = -1;
  int _rejectedItemIndex = -1;

  late PageController _pageController;
  int _currentPage = 0;

  void _refreshLists() {
    setState(() {
      _joinReqList = fetchGroups(joinReqListUri, "joinRequestList");
      _invitationList = fetch(invitationListUri, "invitationList");
    });
  }

  @override
  void initState() {
    super.initState();
    _joinReqList = fetchGroups(joinReqListUri, "joinRequestList");
    _invitationList = fetch(invitationListUri, "invitationList");
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      color: Color(0xFF926AD3),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Flexible(
            child: PageIndicatorContainer(
              length: 2,
              indicatorColor: Colors.grey,
              indicatorSelectorColor: Colors.white,
              shape: IndicatorShape.circle(size: 8),
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  buildInvitationsPage(),
                  buildJoinRequestsPage(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInvitationsPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Join Invitations",
            style: TextStyle(color: Colors.white),
          ),
        ),
        Flexible(
          child: FutureBuilder(
            future: _invitationList,
            builder: (BuildContext context,
                AsyncSnapshot<List<GroupInvitation>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "No Join Invitation Found!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "No Join Invitation Found!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                );
              } else if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final item = snapshot.data![index];
                    final isSelected = index == _selectedItemIndex;
                    final isRejected = index == _rejectedItemIndex;
                    return Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Group: ' + item.groupName.toString(),
                                  style: TextStyle(
                                      color: Color(0xFF926AD3), fontSize: 14),
                                ),
                                Text(
                                  'Owner: \n' + item.ownerEmail.toString(),
                                  style: TextStyle(
                                      color: Color(0xFF926AD3),
                                      // color: isSelected
                                      //     ? Colors.white
                                      //     : Color(0xFF926AD3),
                                      fontSize: 14),
                                ),
                                Row(
                                  children: [
                                    ElevatedButton(
                                        onPressed: () => {
                                              _acceptInvitation('invite',
                                                  item.groupId.toString()),
                                              _refreshLists(),
                                              setState(() {
                                                _selectedItemIndex = index;
                                              }),
                                            },
                                        child: isSelected
                                            ? Text(
                                                " Accept ",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )
                                            : Text(
                                                " Accept ",
                                                style: TextStyle(
                                                    color: Color(0xFF926AD3)),
                                              ),
                                        style: isSelected
                                            ? ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Color(0xFF926AD3),
                                              )
                                            : ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                side: BorderSide(
                                                    color: Color(0xFF926AD3)),
                                              )),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    // IconButton(
                                    //   onPressed: () => {
                                    //     _acceptInvitation(
                                    //         'invite', item.groupId.toString()),
                                    //     _refreshLists(),
                                    //     setState(() {
                                    //       _selectedItemIndex = index;
                                    //     }),
                                    //   },
                                    //   icon: isSelected
                                    //       ? CircleAvatar(
                                    //           backgroundColor:
                                    //               Color(0xFF926AD3),
                                    //           child: Icon(
                                    //             Icons.check,
                                    //             color: Colors.white,
                                    //           ),
                                    //         )
                                    //       : Icon(
                                    //           Icons.check,
                                    //           color: Color(0xFF926AD3),
                                    //         ),
                                    // ),
                                    ElevatedButton(
                                        onPressed: () => {
                                              _rejectInvitation(
                                                  'invite', item.id.toString()),
                                              _refreshLists(),
                                              setState(() {
                                                _rejectedItemIndex = index;
                                              }),
                                            },
                                        child: isSelected
                                            ? Text(
                                                " Reject ",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )
                                            : Text(
                                                " Reject ",
                                                style: TextStyle(
                                                    color: Color(0xFF926AD3)),
                                              ),
                                        style: isSelected
                                            ? ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Color(0xFF926AD3),
                                              )
                                            : ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                side: BorderSide(
                                                    color: Color(0xFF926AD3)),
                                              )),
                                    // IconButton(
                                    //   onPressed: () => {
                                    //     _rejectInvitation(
                                    //         'invite', item.id.toString()),
                                    //     _refreshLists(),
                                    //     setState(() {
                                    //       _rejectedItemIndex = index;
                                    //     }),
                                    //   },
                                    //   icon: isRejected
                                    //       ? CircleAvatar(
                                    //           backgroundColor: Colors.red,
                                    //           child: Icon(
                                    //             Icons.close,
                                    //             color: Colors.white,
                                    //           ),
                                    //         )
                                    //       : Icon(
                                    //           Icons.close,
                                    //           color: Color(0xFF926AD3),
                                    //         ),
                                    // ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text(
                    "Something went wrong",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget buildJoinRequestsPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Join Requests",
            style: TextStyle(color: Colors.white),
          ),
        ),
        Flexible(
          child: FutureBuilder(
            future: _joinReqList,
            builder:
                (BuildContext context, AsyncSnapshot<List<Group>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "No Join Request Found!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "No Join Request Found!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                );
              } else if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final item = snapshot.data![index];
                    final isSelected = index == _selectedItemIndex;
                    final isRejected = index == _rejectedItemIndex;
                    return Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Requested by:\n' +
                                      item.userEmail.toString() +
                                      '\n',
                                  style: TextStyle(
                                      color: Color(0xFF926AD3), fontSize: 14),
                                ),
                                Text(
                                  'Group: ' + item.groupName.toString(),
                                  style: TextStyle(
                                      color: Color(0xFF926AD3), fontSize: 14),
                                ),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => {
                                        _acceptInvitation(
                                            'join', item.id.toString()),
                                        setState(() {
                                          _selectedItemIndex = index;
                                        }),
                                        _refreshLists(),
                                      },
                                      child: isSelected
                                          ? Text(
                                              " Accept ",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )
                                          : Text(
                                              " Accept ",
                                              style: TextStyle(
                                                  color: Color(0xFF926AD3)),
                                            ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        side: BorderSide(
                                            color: Color(0xFF926AD3)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    ElevatedButton(
                                        onPressed: () => {
                                              _rejectInvitation(
                                                  'join', item.id.toString()),
                                              setState(() {
                                                _rejectedItemIndex = index;
                                              }),
                                              _refreshLists(),
                                            },
                                        child: isSelected
                                            ? Text(
                                                " Reject ",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )
                                            : Text(
                                                " Reject ",
                                                style: TextStyle(
                                                    color: Color(0xFF926AD3)),
                                              ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          side: BorderSide(
                                              color: Color(0xFF926AD3)),
                                        ),),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Align(
                          //   alignment: Alignment.bottomRight,
                          //   child: Row(
                          //     children: [
                          //       IconButton(
                          //         onPressed: () => {
                          //           _acceptInvitation(
                          //               'join', item.id.toString()),
                          //           setState(() {
                          //             _selectedItemIndex = index;
                          //           }),
                          //           _refreshLists(),
                          //         },
                          //         icon: isSelected
                          //             ? CircleAvatar(
                          //                 backgroundColor: Color(0xFF926AD3),
                          //                 child: Icon(
                          //                   Icons.check,
                          //                   color: Colors.white,
                          //                 ),
                          //               )
                          //             : Icon(
                          //                 Icons.check,
                          //                 color: Color(0xFF926AD3),
                          //               ),
                          //       ),
                          //       IconButton(
                          //         onPressed: () => {
                          //           _rejectInvitation(
                          //               'join', item.id.toString()),
                          //           setState(() {
                          //             _rejectedItemIndex = index;
                          //           }),
                          //           _refreshLists(),
                          //         },
                          //         icon: isRejected
                          //             ? CircleAvatar(
                          //                 backgroundColor: Colors.red,
                          //                 //backgroundColor: Color(0xFF926AD3),
                          //                 child: Icon(
                          //                   Icons.close,
                          //                   color: Colors.white,
                          //                 ),
                          //               )
                          //             : Icon(
                          //                 Icons.close,
                          //                 color: Color(0xFF926AD3),
                          //               ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text(
                    "Something went wrong",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget buildPageIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == 0 ? Colors.white : Colors.grey,
            ),
          ),
          SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == 1 ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  _acceptInvitation(String type, String id) async {
    print("ID: " + id);
    final prefs = await SharedPreferences.getInstance();
    String uri = '';
    if (type == 'join') {
      uri = acceptJoinUri + '$id';
    } else if (type == 'invite') {
      uri = acceptInvitationUri + '$id';
    }

    final response = await http.put(Uri.parse(uri), headers: {
      "Accept": 'application/json',
      'Authorization': 'Bearer ${prefs.getString('token')}'
    });
    if (response.statusCode == 200) {
      print(response.body.toString());
      _refreshLists(); // Refresh the lists after accepting the invitation
    } else {
      throw Exception('Failed to accept invitation');
    }
  }

  _rejectInvitation(String type, String id) async {
    final prefs = await SharedPreferences.getInstance();
    String uri = '';
    if (type == 'join') {
      uri = rejectJoinUri + '$id';
    } else if (type == 'invite') {
      uri = rejectInvitationUri + '$id';
    }
    final response = await http.delete(Uri.parse(uri), headers: {
      "Accept": 'application/json',
      'Authorization': 'Bearer ${prefs.getString('token')}'
    });
    if (response.statusCode == 200) {
      print(response.body.toString());
      _refreshLists(); // Refresh the lists after rejecting the invitation
    } else {
      throw Exception('Failed to reject invitation');
    }
  }

  Future<List<Group>> fetchGroups(String uri, String key) async {
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
        setState(() {
          invitationStatus = true;
        });
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
        setState(() {
          joinStatus = true;
        });
        print("Empty");
      }
      return data
          .map((jsonData) => GroupInvitation.fromJson(jsonData))
          .toList();
    } else {
      throw Exception('Failed to fetch groups');
    }
  }
}
