import 'dart:convert';

import 'package:community_app/Screens/Auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../contactListPage.dart';
import 'forgetPasswordPage.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  // Initially password is obscure
  bool _obscureText = true;
  Icon icon = Icon(Icons.visibility_off);

  bool _emaiValidate = false;
  bool _passValidate = false;

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

//{{scm}}/api/4/allConnections
  void login(String email, password) async {
    try {
      Response response = await post(
          Uri.parse('http://scm.womenindigital.net/api/auth/login'),
          body: {'email': email, 'password': password});

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);
        prefs.setString('token', data['token']);
        prefs.setInt('loginID', data['data']['id']);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: ((context) => ContactListPage(
                      token: data['token'],
                    ))));
        print(data['token']);
        print(data['data']['id']);
        print('Login successfully');
      } else {
        print('failed' + response.statusCode.toString());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Color(0xFF926AD3),
          content: Text(
            "Please check your Email & Password!",
            style: TextStyle(fontSize: 14),
          ),
          duration: Duration(milliseconds: 1500),
        ));
      }
    } catch (e) {
      print(e.toString());
    }
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

  Widget _welcome() {
    return Container(
      alignment: Alignment.centerLeft,
      child: const Text('Welcome!',
          style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _entryField(
      String title, TextInputType inputType, TextEditingController controller,
      {bool isPassword = false}) {
    return Container(
      //margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
          controller: controller,
          textInputAction: TextInputAction.next,
          obscureText: isPassword,
          keyboardType: inputType,
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
              errorText: _emaiValidate ? 'Email Can\'t Be Empty' : null,
              fillColor: Colors.transparent,
              filled: true)),
    );
  }

  Widget _passwordField(String title, TextEditingController controller,
      {bool isPassword = false}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      //margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
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
              errorText: _passValidate ? 'Password Can\'t Be Empty' : null,
              fillColor: Colors.transparent,
              filled: true)),
    );
  }

  Widget _submitButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          emailController.text.isEmpty ? _emaiValidate = true : _emaiValidate = false;
          passwordController.text.isEmpty ? _passValidate = true : _passValidate = false;
        });

        if(emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
          login(emailController.text.toString(),
              passwordController.text.toString());
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
        child: const Text(
          'Login',
          style:
              TextStyle(color: Color(0xFF926AD3), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _forgetPassword() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ForgetPasswordPage()));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        child: const Text('Forget Password?',
            style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
      ),
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
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => SignUpPage()));
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
              style:
              TextStyle(color: Color(0xFF926AD3), fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('or'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Widget _facebookButton() {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xff1959a9),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    topLeft: Radius.circular(5)),
              ),
              alignment: Alignment.center,
              child: Text('f',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w400)),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xff2872ba),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(5),
                    topRight: Radius.circular(5)),
              ),
              alignment: Alignment.center,
              child: Text('Log in with Facebook',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Email", TextInputType.emailAddress, emailController),
        _passwordField("Password", passwordController,
            isPassword: _obscureText),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    // MediaQuery.of(context).
    debugPrint(MediaQuery.of(context).devicePixelRatio.toString());
    debugPrint(MediaQuery.of(context).size.height.toString());
    debugPrint(MediaQuery.of(context).size.width.toString());
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
          // Positioned(
          //     top: -height * .15,
          //     right: -MediaQuery.of(context).size.width * .4,
          //     child: BezierContainer()),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height * .12),
                  _title(),
                  const SizedBox(height: 50),
                  _welcome(),
                  //_textField(),
                  _emailPasswordWidget(),
                  const SizedBox(height: 20),

                  _submitButton(),
                  _forgetPassword(),
                  //_divider(),
                  //_facebookButton(),
                  SizedBox(height: height * .055),
                  _createAccountLabel(),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
