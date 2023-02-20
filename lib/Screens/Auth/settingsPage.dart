import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController conNewPassController = TextEditingController();
  bool _obscureText = true;
  bool _passValidate = false;
  Icon icon = Icon(Icons.visibility_off);


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

  Widget _welcome() {
    return Container(
      alignment: Alignment.centerLeft,
      child: const Text('Change Password!',
          style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold)),
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

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _passwordField("Password", passwordController,
            isPassword: _obscureText),
        _passwordField("New Password", newPassController,
            isPassword: _obscureText),
        _passwordField("Confirm Password", conNewPassController,
            isPassword: _obscureText),
      ],
    );
  }

  Widget _submitButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          //emailController.text.isEmpty ? _emaiValidate = true : _emaiValidate = false;
          passwordController.text.isEmpty ? _passValidate = true : _passValidate = false;
        });

        //if(emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
         // login(emailController.text.toString(),
           //   passwordController.text.toString());
        //}
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
          'Submit',
          style:
          TextStyle(color: Color(0xFF926AD3), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
  Widget _body() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
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
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * .12),
                    const SizedBox(height: 50),
                    _welcome(),
                    _emailPasswordWidget(),
                    const SizedBox(height: 20),

                    _submitButton(),

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
