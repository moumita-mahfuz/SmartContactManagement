import 'dart:convert';

import 'package:community_app/Screens/Auth/settingsPage.dart';
import 'package:community_app/Screens/Auth/signup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  String uri = 'https://scm.womenindigital.net/api/profile/forget_password';
  TextEditingController emailController = TextEditingController();
  bool _circularIndicator = false;
  Widget _backButton() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Get.back();
            // Navigator.pop(context);
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

  Widget _title() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
//        color: Colors.orange,
        child: Center(
          child: Column(
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: Color(0xFF926AD3),
                  border: Border.all(width: 2, color: Colors.white),
                  borderRadius: BorderRadius.circular(100), //<-- SEE HERE
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    'assets/images/file-person-fill.png',
                    width: 48.5,
                    height: 48.5,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              const Text(
                "Smart Contact Management",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 35.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _verifyEmail() {
    return Container(
      alignment: Alignment.centerLeft,
      child: const Text('Verify Email!',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
    );
  }

  Widget _entryField(TextEditingController controller, String title,
      {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
              labelText: title,
              labelStyle: const TextStyle(
                color: Colors.white, //<-- SEE HERE
              ),
              // hintText: 'Write your email',
              // hintStyle: const TextStyle(fontSize: 12, color: Colors.white),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white), //<-- SEE HERE
              ),
              fillColor: Colors.transparent,
              filled: true)),
    );
  }

  Widget _submitButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _circularIndicator = true;
        });
        _forgetPasswordApi(emailController.text);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(40)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black12,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
        ),
        child: (_circularIndicator)
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                backgroundColor: Color(0xFF9A9A9A),
              ),
              height: 12,
              width: 12,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Please Wait...',
              style: TextStyle(
                  color: Color(0xFF9A9A9A), fontWeight: FontWeight.bold),
            ),
          ],
        )
            : Text(
          'Get Verification Code',
          style: TextStyle(
              color: Color(0xFF926AD3), fontWeight: FontWeight.bold),
        ),
      ),

      // child: Container(
      //   width: MediaQuery.of(context).size.width,
      //   padding: EdgeInsets.symmetric(vertical: 15),
      //   alignment: Alignment.center,
      //   decoration: const BoxDecoration(
      //     color: Colors.white,
      //     borderRadius: BorderRadius.all(Radius.circular(40)),
      //     boxShadow: <BoxShadow>[
      //       BoxShadow(
      //           color: Colors.black12,
      //           offset: Offset(2, 4),
      //           blurRadius: 5,
      //           spreadRadius: 2)
      //     ],
      //     // gradient: LinearGradient(
      //     //     begin: Alignment.centerLeft,
      //     //     end: Alignment.centerRight,
      //     //     colors: [Colors.white70, Colors.white])
      //   ),
      //   child: (_circularIndicator)
      //       ? Center(
      //         child: Row(children: [
      //     SizedBox(
      //         child: CircularProgressIndicator(
      //           strokeWidth: 3,
      //           backgroundColor: Color(0xFF9A9A9A),
      //         ),
      //         height: 12,
      //         width: 12,
      //     ),
      //     SizedBox(
      //         width: 10,
      //     ),
      //     const Text(
      //         'Please wait..',
      //         style: TextStyle(
      //             color: Color(0xFF926AD3), fontWeight: FontWeight.bold),
      //     ),
      //   ],),
      //       )
      //       : const Text(
      //           'Get Verification Code',
      //           style: TextStyle(
      //               color: Color(0xFF926AD3), fontWeight: FontWeight.bold),
      //         ),
      // ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField(emailController, "Email"),
      ],
    );
  }

  Widget _createAccountLabel() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Text(
            'Don\'t have an account?',
            style: TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        GestureDetector(
          onTap: () {
            Get.to(SignUpPage());
            // Navigator.pushReplacement(
            //     context, MaterialPageRoute(builder: (context) => SignUpPage()));
          },
          child: Container(
            width: MediaQuery.of(context).size.width / 2,
            padding: EdgeInsets.symmetric(vertical: 15),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(40)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.black12,
                    offset: Offset(2, 4),
                    blurRadius: 5,
                    spreadRadius: 2)
              ],
              // gradient: LinearGradient(
              //     begin: Alignment.centerLeft,
              //     end: Alignment.centerRight,
              //     colors: [Colors.white70, Colors.white])
            ),
            child: const Text(
              'Create',
              style: TextStyle(
                  color: Color(0xFF926AD3), fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  void _forgetPasswordApi(String email) async {
    try {
      Response response = await post(
          //https://scm.womenindigital.net/api/auth/login
          Uri.parse(uri),
          body: {'email': email});
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          _circularIndicator = false;
        });
        var data = jsonDecode(response.body.toString());
        print(data);
        Get.to(() => (SettingPage(isShow: false, parent: email,)));
        Get.snackbar(
          "Success",
          "Please check your mail for reset password!",
          colorText: Colors.white,
          //icon: Icon(Icons.person, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Color(0xFF926AD3),
          duration: Duration(seconds: 4),
          isDismissible: true,
        );
        // final prefs = await SharedPreferences.getInstance();
        // prefs.setBool('isLoggedIn', true);
        // prefs.setString('token', data['token']);
        // prefs.setInt('loginID', data['data']['id']);
        // prefs.setString('login-pass', password);
        // print(data['token']);
        // Get.offAll(ContactListPage(
        //   token: data['token'],
        // ));

        // print(data['token']);
        // print(data['data']['id']);
        print('mail sent');
      } else {
        setState(() {
          _circularIndicator = false;
        });
        print('failed' + response.statusCode.toString());
        Get.snackbar(
          "Warning",
          "Please check your Email address!",
          colorText: Colors.white,
          //icon: Icon(Icons.person, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Color(0xFF926AD3),
          duration: Duration(seconds: 4),
          isDismissible: true,
        );
      }
    } catch (e) {
      setState(() {
        //_circularIndicator = false;
      });
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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * .12),
                    _title(),
                    SizedBox(
                      height: 50,
                    ),
                    _verifyEmail(),
                    _emailPasswordWidget(),
                    SizedBox(
                      height: 20,
                    ),
                    _submitButton(),
                    SizedBox(height: height * .14),
                    //_facebookButton(),
                    SizedBox(height: height * .055),
                    _createAccountLabel(),
                  ],
                ),
              ),
            ),
            Positioned(top: 40, left: 0, child: _backButton()),
          ],
        ),
      ),
    );
  }
}
