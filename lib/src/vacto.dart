import 'package:flutter/material.dart';
import 'package:vacto/src/blocs/login_provider.dart';
import 'package:vacto/src/blocs/register_provider.dart';
import 'package:vacto/src/blocs/variables_provider.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/registersuccess.dart';
import 'pages/mainmenu.dart';
import 'pages/play.dart';
import 'pages/challenge.dart';
import 'pages/challenge_find.dart';
import 'pages/challenge_request.dart';
import 'pages/addnews.dart';
import 'pages/leaderboard.dart';
import 'pages/profile.dart';
import 'pages/profile_edit.dart';
import 'pages/profile_datas_view.dart';
import 'pages/profile_news_detail.dart';
import 'pages/viewdata.dart';
import 'pages/verify_questions.dart';
import 'pages/loadingscreen.dart';

import 'pages/paintingground.dart';

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
  // TODO: make another file to check storage on whether or not the user has already logged in and call it in "/" route
  @override
  Widget build(BuildContext context) {
    return VariablesProvider(
      child: RegisterProvider(
        child: LoginProvider(
          child: MaterialApp(
            title: 'Vacto',
            theme: ThemeData(
              fontFamily: "HKGrotesk",
              primarySwatch: vactoColor,
            ),
            routes: {
              "/": (context) => Login(),
              // "/": (context) => PaintingGround(),
              "/login": (context) => Login(),
              "/register": (context) => Register(),
              "/register/success": (context) =>RegisterSuccess(),
              "/main": (context) => MainMenu(),
              "/play": (context) => Play(),
              "/challenge": (context) => Challenge(),
              "/challenge/find": (context) => ChallengeFind(),
              "/challenge/requests": (context) => ChallengeRequest(),
              "/add": (context) => AddNews(),
              "/leaderboard": (context) => Leaderboard(),
              "/profile": (context) => Profile(),
              "/profile/edit": (context) => ProfileEdit(),
              "/profile/detail": (context) => ProfileDatasView(),
              "/profile/detail/news": (context) => ProfileNewsDetail(),
              "/data/view": (context) => ViewData(),
              "/questions/verify": (context) => VerifyQuestions(),
              "/loading": (context) => LoadingScreen()
            },
            debugShowMaterialGrid: false,
            debugShowCheckedModeBanner: false,
          ),
        ),
      )
    );
  }
}