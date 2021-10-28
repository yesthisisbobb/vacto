import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/mainmenu.dart';

// TODO: Move these codes to someplace else
Map<int, Color> vactoBlue = {
  50: Color.fromRGBO(0, 51, 153, .1),
  100: Color.fromRGBO(0, 51, 153, .2),
  200: Color.fromRGBO(0, 51, 153, .3),
  300: Color.fromRGBO(0, 51, 153, .4),
  400: Color.fromRGBO(0, 51, 153, .5),
  500: Color.fromRGBO(0, 51, 153, .6),
  600: Color.fromRGBO(0, 51, 153, .7),
  700: Color.fromRGBO(0, 51, 153, .8),
  800: Color.fromRGBO(0, 51, 153, .9),
  900: Color.fromRGBO(0, 51, 153, 1),
};
MaterialColor vactoColor = MaterialColor(0xFF003399, vactoBlue);

class Vacto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vacto',
      theme: ThemeData(
        fontFamily: "HKGrotesk",
        primarySwatch: vactoColor,
      ),
      routes: {
        "/": (context) => MainMenu(),
        "/register": (context) => Register(),
        "/main": (context) => MainMenu(),
      },
      debugShowMaterialGrid: false,
      debugShowCheckedModeBanner: false,
    );
  }
}