
import 'package:community_app/Screens/contactListPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Screens/Auth/loginPage.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final loginID = prefs.getInt('loginID') ;
  final token = prefs.getString('token') ?? false;
  runApp(MyApp(isLoggedIn: isLoggedIn, token: token.toString()));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String token;
  const MyApp({Key? key, required this.isLoggedIn, required this.token}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    MaterialColor myColor = const MaterialColor(0xFF926AD3, <int, Color>{
      50: Color(0xFF926AD3),
      100: Color(0xFF926AD3),
      200: Color(0xFF926AD3),
      300: Color(0xFF926AD3),
      400: Color(0xFF926AD3),
      500: Color(0xFF926AD3),
      600: Color(0xFF926AD3),
      700: Color(0xFF926AD3),
      800: Color(0xFF926AD3),
      900: Color(0xFF926AD3),
    },
    );
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
      title: 'Smart Contact Management',
        theme: ThemeData(
            primarySwatch: myColor,
          unselectedWidgetColor: Colors.white,
          fontFamily: 'Montserrat',
          // textTheme: const TextTheme(
          //   displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          //   titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          //   bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          // ),
        ),
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? ContactListPage(token: token) : LoginPage()
    );
  }
}
