
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart'  hide Response, FormData, MultipartFile;

class GroupListPage extends StatefulWidget {
  const GroupListPage({Key? key}) : super(key: key);

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  @override
  Widget build(BuildContext context) {

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return DefaultTabController(length: 2, child: Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text("Groups"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: InkWell(
              onTap: () => groupAddDialog(),
              child: Icon(
                Icons.add, color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(
              Icons.notifications_none_rounded, color: Colors.white,
            ),
          ),

        ],
        bottom: TabBar(
          tabs: [
            //badge_rounded
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_ind_rounded),
                  Text('  My Groups')
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_rate_rounded),
                  Text('   External Groups')
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
          SafeArea(child: Stack(children: [
            Text("No Group Created yet"),
            Positioned(
                bottom: 20, right: 20, child: _addMemberFAB()),
          ],)),
          SafeArea(child: Text("No Group Created yet")),
        ]),
      ),
    ));
  }

  groupAddDialog() {
    return Get.defaultDialog(
        title: "Create Group",
        middleText: "Hello world!",
        backgroundColor: Colors.white,
        titleStyle: TextStyle(color: Color(0xFF926AD3)),
        middleTextStyle: TextStyle(color: Colors.white),
        textConfirm: " Create ",
        textCancel: "  Cancel  ",
        cancelTextColor: Color(0xFF926AD3),
        confirmTextColor: Colors.white,
        buttonColor: Color(0xFF926AD3),
        barrierDismissible: false,
        radius: 10,
        content: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a search term',
              ),
            ),
          ),
        ),

    );
  }

  _addMemberFAB() {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF926AD3),
      onPressed: () {
        // Get.to(NewContactAddPage(
        //   contactList: ContactListPage.contactList,
        // ));

      },
      child: const Icon(Icons.person_add_alt_1_rounded),
    );
  }

}
