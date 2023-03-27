import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../Model/User.dart';
import '../User/userProfilePage.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  TextEditingController oldPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController conNewPassController = TextEditingController();
  bool _isShow = true;
  bool _obscureText = true;
  bool _passValidate = false;
  bool _oldPassValidate = false;
  bool _newPassValidate = false;
  bool _conPassValidate = false;
  Icon icon = Icon(Icons.visibility_off);

  String oldPassMassage = '';
  String conPassMassage = '';
  bool _circularIndicator = false;

  Future<void> updatePassword(String newPass) async {
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('loginID');
    print(id);
    ///api/profile/6/update_password
    var uriData = 'https://scm.womenindigital.net/api/profile/$id/update_password';
    Map<String, String> headers = {
      "Accept": 'application/json',
      'Authorization': 'Bearer ${prefs.getString('token')}'
    };
    Map<String, String> body = {
      'password': newPass,
    };
    var req = http.MultipartRequest('Post', Uri.parse(uriData));
    req.headers.addAll(headers);
    req.fields.addAll(body);
    var streamedResponse = await req.send();

    var response = await http.Response.fromStream(streamedResponse);
    //print(response.body.toString());
    String rawData = response.body.toString().replaceAll("\"", ' ');
    print ("RAW DATA " + rawData);
    if (streamedResponse.statusCode == 200) {
      prefs.setString('login-pass', newPass);
      setState(() {
        _circularIndicator = false;
      });
      Navigator.pop(context);
      // Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //         builder: ((context) => UserProfilePage(user: user, isChanged: true,))));

    } else {
      setState(() {
      _circularIndicator = false;
    });
      print('failed ${response.statusCode}');
    }

  }



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

  Widget _backButton() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            Navigator.pop(context);
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

  Widget _welcome() {
    return Container(
      padding: EdgeInsets.only(left: 30, right: 30),
      alignment: Alignment.centerLeft,
      child: const Text('Change Password!',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
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
              errorText: _passValidate ? 'Can\'t Be Empty' : null,
              fillColor: Colors.transparent,
              filled: true)),
    );
  }

  Widget _oldPasswordWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          //margin: const EdgeInsets.symmetric(vertical: 10),
          child: TextField(
              controller: oldPassController,
              obscureText: _obscureText,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  labelText: "Old Password",
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
                  errorText: _oldPassValidate ? oldPassMassage : null,
                  fillColor: Colors.transparent,
                  filled: true)),
        ),
      ],
    );
  }

  Widget _newPasswordWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          //margin: const EdgeInsets.symmetric(vertical: 10),
          child: TextField(
              controller: newPassController,
              obscureText: _obscureText,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  labelText: "New Password",
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
                  errorText: _newPassValidate ? 'Can\'t Be Empty' : null,
                  fillColor: Colors.transparent,
                  filled: true)),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          //margin: const EdgeInsets.symmetric(vertical: 10),
          child: TextField(
              controller: conNewPassController,
              obscureText: _obscureText,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  labelText: "Confirm Password",
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
                  errorText: _conPassValidate ? conPassMassage : null,
                  fillColor: Colors.transparent,
                  filled: true)),
        )
      ],
    );
  }

  Future<bool> _passwordMatch(String oldPass) async {
    final prefs = await SharedPreferences.getInstance();
    String? pass = prefs.getString('login-pass');
    print("OLD - NEW  " + " " + pass.toString() + " " + oldPass.toString());
    if (pass.toString() == oldPass.toString()) {
      return true;
      print("on Create" + _isShow.toString());
    } else
      return false;
  }

  Future<bool> getstatus(String oldPass) async {
    bool message = await _passwordMatch(oldPass);
    return (message); // will print one on console.
  }

  Widget _submitButton() {
    return GestureDetector(
      onTap: () async {
        String oldPass = oldPassController.text;
        String newPass = newPassController.text;
        String conPass = conNewPassController.text;
        if (_isShow) {
          setState(() {
            (oldPass.isEmpty)
                ? {
                    _oldPassValidate = true,
                    oldPassMassage = "Can\'t Be Empty"
                  }
                : _oldPassValidate = false;
          });
          if (oldPass.isNotEmpty) {
            bool result = await getstatus(oldPass);
            //print(c);
            print("final Result " + result.toString());
            if (result == true) {
              setState(
                () {
                  _isShow = !_isShow;
                },
              );
            }
            else {
              setState(() {
                _oldPassValidate = true;
                oldPassMassage = "Old Password don't match!";
              });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                backgroundColor: Color(0xFF926AD3),
                content: Text(
                  "Password don't match. Try again!",
                  style: TextStyle(fontSize: 14),
                ),
                duration: Duration(milliseconds: 1500),
              ));
            }
          }
        } else {
          setState(() {
            newPass.isEmpty
                ? {
                    _newPassValidate = true,
                    conPassMassage = "Can\'t Be Empty"
                  }
                : _newPassValidate = false;
            conPass.isEmpty
                ? _conPassValidate = true
                : _conPassValidate = false;
          });
          if(newPass.isNotEmpty && conPass.isNotEmpty) {
            if(newPass == conPass) {
              setState(() {
                _circularIndicator = true;
              });
              updatePassword(newPass);
              //Change pass word code will be here

              //Navigator.pop(context);
              // Navigator.pushReplacement(
              //     context,
              //     MaterialPageRoute(
              //         builder: ((context) => ContactListPage(
              //           token: data['token'],
              //         ))));
            }
            else {
              setState(() {
                _conPassValidate = true;
                conPassMassage = "Confirm Password don't match!";
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  backgroundColor: Color(0xFF926AD3),
                  content: Text(
                    "Confirm Password don't match. Try again!",
                    style: TextStyle(fontSize: 14),
                  ),
                  duration: Duration(milliseconds: 1500),
                ));
              });
            }
          }
        }

        //if(emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
        // login(emailController.text.toString(),
        //   passwordController.text.toString());
        //}
      },
      child: Container(
        width: MediaQuery.of(context).size.width - 60,
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
          _isShow ? 'Next' : 'Update',
          style:
          TextStyle(color: Color(0xFF926AD3), fontWeight: FontWeight.bold),
        ),

      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    print("on Create " + _isShow.toString());
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          child: Stack(
            children: <Widget>[
              Positioned(
                top: height * .17,
                child: _welcome(),
              ),
              Positioned(
                  top: height * .25,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    width: width,
                    height: (height * .48 - height * .25),
                    //padding: EdgeInsets.only(left: 30, right: 30),
                    color: Colors.transparent,
                    child: Visibility(
                      visible: _isShow,
                      // maintainSize: true, //NEW
                      // maintainAnimation: true, //NEW
                      // maintainState: true, //NEW
                      replacement: _newPasswordWidget(),
                      child: _oldPasswordWidget(),
                    ),
                  )),
              Positioned(
                top: height * .49,
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: _submitButton()),

                // ElevatedButton(
                //   onPressed: () {
                //
                //   },
                //   child: Container(
                //     child: Text(
                //
                //       style: TextStyle(fontSize: 20),
                //     ),
                //   ),
                // )
              ),
              Positioned(top: 30, left: 0, child: _backButton()),
            ],
          ),
        ),
      ),
    );
  }
}
