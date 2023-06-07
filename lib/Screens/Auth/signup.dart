import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'loginPage.dart';

import 'package:get/get.dart'  hide Response, FormData, MultipartFile;

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  // Initially password is obscure
  bool _obscureText = true;
  Icon icon = Icon(Icons.visibility_off);
  bool _nameValidate = false;
  bool _emailValidate = false;
  bool _passValidate = false;
  bool _circularIndicator = false;

  void signup(String name, email, password) async {
    int x = 0;

    // final client = HttpClient();
    // Response r = await client.post(http://127.0.0.1:8000/, port, path)
    // final request = await client.getUrl(Uri.parse(apiUrl));
    // final response = await request.close();
    try {
      Response response = await post(
        ///api/auth/registration
        ///https://scm.womenindigital.net/api/auth/registration
        ///https://scm.womenindigital.net/api/auth/registration/user
        ///https://scm.womenindigital.net  http://127.0.0.1:8000/api/auth/registration
          Uri.parse('https://scm.womenindigital.net/api/auth/register'),
          headers: {
            "Accept": 'application/json',
          },
          //name,email,password,confirm_password,is_verified
          body: {
            'name': name,
            'email': email,
            'password': password,
            'confirm_password': password,
            'is_verified': x.toString()
          });
      
      print(response.statusCode);

      if (response.statusCode == 200) {
        setState(() {
          _circularIndicator = false;
        });
        var data = jsonDecode(response.body.toString());
        print(data['token']);
        print('Register successfully');
        // Navigator.pushReplacement(
        //     context, MaterialPageRoute(builder: ((context) => LoginPage())));
        Get.offAll(LoginPage());
        //set the shared preference instance
        // final prefs = await SharedPreferences.getInstance();
        // prefs.setBool('isLoggedIn', true);
        // prefs.setString('token', data['token']);
        //prefs.setInt('loginID', data['token']);

      } else if(response.statusCode == 422 || response.statusCode == 500) {
        setState(() {
          _circularIndicator = false;
        });
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //   backgroundColor: Color(0xFF926AD3),
        //   content: Text(
        //     "This mail is already taken!",
        //     style: TextStyle(fontSize: 14),
        //   ),
        //   duration: Duration(milliseconds: 1500),
        // ));
        Get.snackbar(
          "Warning",
          "This mail is already taken!!",
          colorText: Colors.white,
          //icon: Icon(Icons.person, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Color(0xFF926AD3),
          duration: Duration(seconds: 4),
          isDismissible: true,
        );
      }else {
        setState(() {
          _circularIndicator = false;
        });
        print('failed' + response.statusCode.toString());
      }
    } catch (e) {
      setState(() {
        _circularIndicator = false;
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
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   backgroundColor: Color(0xFF926AD3),
      //   content: Text(
      //     '$e!',
      //     style: TextStyle(fontSize: 14),
      //   ),
      //   duration: Duration(milliseconds: 2000),
      // ));
      print(e.toString());
    }
  }

  // Toggles the password show status
  void _toggle() {
    setState(() {
      if (_obscureText == true) {
        icon = Icon(
          Icons.visibility,
        );
      } else {
        icon = Icon(Icons.visibility_off);
      }
      _obscureText = !_obscureText;
    });
  }

  Widget _entryField(
      String title, TextInputType inputType, TextEditingController controller,
      {bool isPassword = false}) {
    return Container(
      //margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
          keyboardType: inputType,
          textInputAction: TextInputAction.next,
          controller: controller,
          obscureText: isPassword,
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
              errorText: _errorText(title),
              fillColor: Colors.transparent,
              filled: true)),
    );
  }

  String? _errorText(String title) {
    if(title == "User Name") {
      return _nameValidate ? 'Name can\'t Be Empty': null;
    } else {
      return _emailValidate ? 'Email can\'t Be Empty' : null;
    }
  }


  Widget _passwordField(String title, TextEditingController controller,
      {bool isPassword = false}) {
    return Container(
      width: MediaQuery.of(context).size.width,
     // margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          TextField(
              controller: controller,
              obscureText: isPassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  labelText: title,
                  labelStyle: const TextStyle(
                    color: Colors.white, //<-- SEE HERE
                  ),
                  // hintText: 'Write your password',
                  // hintStyle: const TextStyle(fontSize: 12, color: Colors.white),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), //<-- SEE HERE
                  ),
                  suffixIcon: IconButton(
                    icon: icon,
                    onPressed: _toggle,
                  ),
                  errorText:  _passValidate ? 'Password can\'t Be Empty': null,
                  fillColor: Colors.transparent,
                  filled: true)),
        ],

      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("User Name", TextInputType.name, nameController),
        _entryField("Email", TextInputType.emailAddress, emailController),
        _passwordField("Password", passwordController,
            isPassword: _obscureText),
      ],
    );
  }

  // Widget _submitButton() {
  //   return Container(
  //     width: MediaQuery.of(context).size.width,
  //     padding: EdgeInsets.symmetric(vertical: 15),
  //     alignment: Alignment.center,
  //     decoration: BoxDecoration(
  //         borderRadius: BorderRadius.all(Radius.circular(5)),
  //         boxShadow: <BoxShadow>[
  //           BoxShadow(
  //               color: Colors.grey.shade200,
  //               offset: Offset(2, 4),
  //               blurRadius: 5,
  //               spreadRadius: 2)
  //         ],
  //         gradient: LinearGradient(
  //             begin: Alignment.centerLeft,
  //             end: Alignment.centerRight,
  //             colors: [Color(0xfffbb448), Color(0xfff7892b)])),
  //     child: Text(
  //       'Register Now',
  //       style: TextStyle(fontSize: 20, color: Colors.white),
  //     ),
  //   );
  // }
  Widget _submitButton() {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        setState(() {
          nameController.text.isEmpty ? _nameValidate = true : _nameValidate = false;
          emailController.text.isEmpty? _emailValidate = true : _emailValidate = false;
          passwordController.text.isEmpty? _passValidate = true : _passValidate = false;
        });
        if(nameController.text.isNotEmpty && emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
          signup(nameController.text.toString(), emailController.text.toString(),
              passwordController.text.toString());
          setState(() {
            _circularIndicator = true;
          });
        }
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
          // gradient: LinearGradient(
          //     begin: Alignment.centerLeft,
          //     end: Alignment.centerRight,
          //     colors: [Colors.white70, Colors.white])
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
          'Sign up',
          style: TextStyle(
              color: Color(0xFF926AD3), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _loginAccountLabel() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Text(
            'Already have an account?',
            style: TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        GestureDetector(
          onTap: () {
            Get.offAll(LoginPage());
            // Navigator.pushReplacement(
            //     context, MaterialPageRoute(builder: (context) => LoginPage()));
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
              'Log in',
              style:
              TextStyle(color: Color(0xFF926AD3), fontWeight: FontWeight.bold),
            ),
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
              SizedBox(height: 5,),
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

  Widget _signUp() {
    return Container(
      alignment: Alignment.centerLeft,
      child: const Text('Sign up!',
          style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold)),
    );
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
              padding: const EdgeInsets.symmetric(horizontal: 30),
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
                    _signUp(),
                    _emailPasswordWidget(),
                    SizedBox(
                      height: 20,
                    ),
                    _submitButton(),
                    SizedBox(height: height * .055),
                    _loginAccountLabel(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
