import 'dart:js';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:vacto/src/blocs/login_bloc.dart';
import 'package:vacto/src/blocs/login_provider.dart';
import 'package:vacto/src/classes/Feed.dart';
import 'package:vacto/src/classes/User.dart';
import 'package:vacto/src/pages/loadingscreen.dart';
import 'package:soundpool/soundpool.dart';
import 'package:url_launcher/url_launcher.dart';

import '../blocs/variables_provider.dart';

class MainMenu extends StatefulWidget {
  MainMenu({Key key}) : super(key: key);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  Soundpool pool = Soundpool.fromOptions(options: SoundpoolOptions(streamType: StreamType.notification));
  VariablesBloc vBloc;
  LoginBloc lBloc;
  List<Feed> feeds;

  String feedType = "";
  List<String> achievementIds = [];

  Future<bool> getUserAchievement(String uid) async {
    var res = await http.get(Uri.parse("http://localhost:3000/api/user/achievement/get/picked/$uid"));
    if(res.statusCode == 200){
      print("ACHIEVEMENT MASUK 200");
      var jsonData = res.body.toString();
      var parsedData = json.decode(jsonData);
      print(parsedData);

      achievementIds = [];
      for (var item in parsedData) {
        achievementIds.add(item["aid"].toString());
      }
      print(achievementIds.length);

      return true;
    }
    print("ACHIEVEMENT GAMASUK 200");
    return false;
  }

  playClickSound() async {
    int soundId = await rootBundle.load("sfx/menu_click.mp3").then((value) {
      return pool.load(value);
    });
    int streamId = await pool.play(soundId);
  }

  openURL(String aid) async {
    var res = await http.get(Uri.parse("http://localhost:3000/api/user/achievement/get/${vBloc.currentUser.id}"));
    if(res.statusCode == 200){
      print("Masuk openURL");
      var jsonData = res.body.toString();
      var parsedData = json.decode(jsonData);

      for (var item in parsedData) {
        if(item["aid"].toString() == aid){
          String text = "I just got '${item["name"]}' on Vacto!";
          Uri uri = Uri.dataFromString("https://twitter.com/intent/tweet?text=$text");
          String url = uri.query;
          print(url);
          launch("https://twitter.com/intent/tweet?$url");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    vBloc = VariablesProvider.of(context);
    lBloc = LoginProvider.of(context);
    feeds = [];
    context = this.context;

    return FutureBuilder(
      future: Future<String>(() async {
        String resString = "oof";
        if (vBloc.currentUser == null) {
          print("User is NULL");
          try {
            print("Trying to fetch localS");

            String userid = vBloc.localS.getItem("id");
            print(userid);
            vBloc.currentUser = new User();
            await vBloc.currentUser.fillOutDataFromID(userid);
            print("awaited");

            return "created";
          } catch (e) {
            print(e);
          }
        }
        else{
          resString = "found";
        }

        return resString;
      }),
      builder: (context, snapshot){
        if(snapshot.hasData && snapshot.data == "created" || snapshot.hasData && snapshot.data == "found"){
          return Scaffold(
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: MediaQuery.of(context).size.width <= 800 
              ? SingleChildScrollView(
                child: Column(
                  children: [
                    leftContent(context),
                  ],
                ),
              )
              : Row(
                children: [
                  Expanded(flex: 3, child: leftContent(context)),
                  Expanded(flex: 7, child: rightContent(context))
                ],
              ),
            ),
          );
        }
        else{
          // TODO: add navigator when there's no data in localstorage cause i don't know how to do it
          return LoadingScreen();
        }
      },
    );
  }

  Widget leftContent(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      child: Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              SizedBox(
                height: 24.0,
              ),
              vactoLogoSection(),
              SizedBox(
                height: 20.0,
              ),
              profileSection(context),
              SizedBox(
                height: 12.0,
              ),
              MediaQuery.of(context).size.width <= 800
              ? Container(
                width: double.infinity,
                height: 1000,
                child: rightContent(context),
              )
              : Container(),
              SizedBox(
                height: 12.0,
              ),
              MediaQuery.of(context).size.width <= 800
              ? Container(
                height: 300,
                child: feedSection(context),
              )
              : Expanded(child: feedSection(context)),
            ],
          )),
    );
  }

  Widget vactoLogoSection(){
    return Image(
      image: AssetImage("vacto_full.png"),
      height: 42,
    );
  }

  Widget profileSection(BuildContext context){
    return Card(
      borderOnForeground: true,
      margin: MediaQuery.of(context).size.width <= 800 ? EdgeInsets.symmetric(horizontal: 24.0) : EdgeInsets.zero,
      shape: MediaQuery.of(context).size.width <= 800
      ? RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(70.0))
      )
      : RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(70.0),
              bottomRight: Radius.circular(70.0))),
      shadowColor: Color.fromRGBO(0, 0, 0, 0.2),
      elevation: 5.0,
      child: Container(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            children: [
              Container(
                child: CircleAvatar(
                  backgroundImage: (vBloc.currentUser.pp == "default.png")
                      ? AssetImage("placeholders/default.png")
                      : NetworkImage(
                          "http://localhost:3000/images/profile/${vBloc.currentUser.pp}",
                          scale: 0.5),
                  backgroundColor:
                      Theme.of(context).colorScheme.primary,
                  radius: 48,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                direction: Axis.horizontal,
                children: [
                  Container(
                    height: 18,
                    child: Image.asset(
                        "country-flags/${vBloc.currentUser.nationality.toLowerCase()}.png"),
                  ),
                  SizedBox(
                    width: 12.0,
                  ),
                  Text(
                    vBloc.currentUser.username,
                    style: TextStyle(
                        fontSize: 22.0, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    width: 12.0,
                  ),
                  Container(
                    child: Image(
                      image: AssetImage(
                          "tiers/tier${vBloc.currentUser.level}.png"),
                      height: 24,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8.0,
              ),
              Container(
                child: FutureBuilder(
                  future: getUserAchievement(vBloc.currentUser.id),
                  builder: (context, snapshot){
                    if(snapshot.hasData){
                      if(snapshot.data == true){
                        List<Widget> imgs = [];

                        for (var i = 0; i < achievementIds.length; i++) {
                          imgs.add(InkWell(
                            child: Image.asset(
                              "achievements/${achievementIds[i]}.png",
                              height: 34,
                            ),
                            onTap: (){
                              openURL(achievementIds[i]);
                            },
                          ));
                          if (i < achievementIds.length - 1) imgs.add(SizedBox(width: 8.0,),);
                        }

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: imgs,
                        );
                      }
                      else{
                        return Container();
                      }
                    }
                    else{
                      return CircularProgressIndicator();
                    }
                  },
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 12.0)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Logout"),
                      SizedBox(
                        width: 5.0,
                      ),
                      Icon(Icons.logout),
                    ],
                  ),
                  onPressed: () async {            
                    playClickSound();
                    lBloc.errMsgFound(null);

                    vBloc.currentUser = null;
                    vBloc.localS.deleteItem("id");
                    Navigator.pushNamed(context, "/login");
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget feedSection(BuildContext context){
    return Card(
      borderOnForeground: true,
      margin: EdgeInsets.zero,
      shape: MediaQuery.of(context).size.width <= 800 
      ? RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(70.0),
              topRight: Radius.circular(70.0)))
      : RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(70.0))),
      shadowColor: Color.fromRGBO(0, 0, 0, 0.2),
      elevation: 5.0,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            feedButtons(context),
            SizedBox(height: 12.0,),
            Expanded(
              child: feed(),
            ),
          ],
        )
      ),
    );
  }

  Widget feedButtons(BuildContext context){
    return Row(
      mainAxisAlignment: MediaQuery.of(context).size.width <= 800 ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        OutlinedButton(
          child: Text("Global"),
          onPressed: (){
            setState(() {
              feedType = "";
            });
          }
        ),
        SizedBox(width: 8.0,),
        OutlinedButton(
          child: Text("Local"),
          onPressed: (){
            setState(() {
              feedType = vBloc.currentUser.nationality;
            });
          }
        ),
      ]
    );
  }

  Widget feed(){
    vBloc.feedTypeChange(feedType);

    return StreamBuilder(
      stream: vBloc.feedTypeStream,
      builder: (context, snapshot){
        print("Masuk streambuilder feed");
        if (snapshot.hasData) {
          return FutureBuilder(
            future: Future<List<Feed>>(() async {
              String nationality = snapshot.data; // global/local. kalo ada isi e brati local
              String url = "http://localhost:3000/api/feed/get/global/";
              if(nationality != "") url = "http://localhost:3000/api/feed/get/local/$nationality";
              print(url);

              var res = await http.get(Uri.parse(url));
              if(res.statusCode == 200){
                var jsonData = res.body.toString();
                var parsedData = json.decode(jsonData);

                List<Feed> tempArr = [];
                for (var item in parsedData) {
                  Feed temp = Feed(item["id"], item["date"], item["content"], item["user"], item["opponent"], item["achievement"], item["username"]);
                  tempArr.add(temp);
                }

                return tempArr;
              }

              return [];
            }),
            builder: (context, snapshot){
              print("Masuk futurebuilder feed");
              if (snapshot.hasData) {
                feeds = List.castFrom(snapshot.data);
                print("Feed Total: ${feeds.length}");
                if(feeds.isNotEmpty){
                  return ListView(
                    reverse: true,
                    children: List<Widget>.generate(feeds.length, (index) {
                      return Container(
                        child: Text(feeds[index].toString()),
                      );
                    }),
                  );
                }
                else{
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(Colors.grey[200], BlendMode.src),
                          child: Image.asset(
                            "empty_pics/no-feed.png",
                            height: 120,
                          ),
                        ),
                        SizedBox(height: 12.0,),
                        Text(
                          "No activities for now :(",
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }
              }
              else{
                return feedLoading();
              }
            }
          );
        }
        else{
          return feedLoading();
        }
      }
    );
  }

  Widget feedLoading(){
    return Center(
      child: Container(
        height: 50,
        width: 50,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget feedItem(String text){
    return Container(
      width: double.infinity,
      color: Colors.red,
      child: Text(text),
    );
  }

  Widget rightContent(BuildContext context) {
    int caCount = 3;
    if(MediaQuery.of(context).size.width <= 1070) caCount = 2;

    return Container(
      padding: EdgeInsets.all(20.0),
      child: GridView.count(
        crossAxisCount: caCount,
        mainAxisSpacing: 20.0,
        crossAxisSpacing: 20.0,
        children: menus(context),
      ),
    );
  }

  List<Widget> menus(BuildContext context) {
    return [
      menuItem(context, "menu_icon/play.png", "Play", () async {
        playClickSound();
        showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30))),
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(50.0),
                child: Container(
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          "Choose Game Mode",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 24.0,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.all(42.0),
                                        ),
                                        child: Image.asset(
                                          "menu_icon/gamemode-normal.png",
                                          fit: BoxFit.cover,
                                        ),
                                        onPressed: () async {
                                          playClickSound();

                                          vBloc.isGameModeTimed = false;
                                          showModalBottomSheet(
                                              context: context,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  30),
                                                          topRight:
                                                              Radius.circular(
                                                                  30))),
                                              builder: (context) {
                                                return difficultySelector(
                                                    context);
                                              });
                                        }),
                                  ),
                                  SizedBox(
                                    height: 12.0,
                                  ),
                                  Text(
                                    "Standard",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryVariant),
                                  )
                                ],
                              ),
                              SizedBox(
                                width: 24.0,
                              ),
                              Column(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.all(42.0),
                                        ),
                                        child: Image.asset(
                                          "menu_icon/gamemode-timed.png",
                                          fit: BoxFit.cover,
                                        ),
                                        onPressed: () async {
                                          playClickSound();

                                          vBloc.isGameModeTimed = true;
                                          print(vBloc.isGameModeTimed);
                                          showModalBottomSheet(
                                              context: context,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  30),
                                                          topRight:
                                                              Radius.circular(
                                                                  30))),
                                              builder: (context) {
                                                return difficultySelector(
                                                    context);
                                              });
                                        }),
                                  ),
                                  SizedBox(
                                    height: 12.0,
                                  ),
                                  Text(
                                    "Timed",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryVariant),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
      }),
      menuItem(context, "menu_icon/challenge.png", "Challenge Another Player", () async {
        playClickSound();
        Navigator.pushNamed(context, "/challenge").then((value) => setState((){}));
      }),
      menuItem(context, "menu_icon/add.png", "Add News", () async {
        playClickSound();
        Navigator.pushNamed(context, "/add").then((value) => setState(() {}));
      }),
      menuItem(context, "menu_icon/leaderboard.png", "Leaderboard", () async {
        playClickSound();
        Navigator.pushNamed(context, "/leaderboard").then((value) => setState((){}));
      }),
      menuItem(context, "menu_icon/profile.png", "Profile", () async {
        playClickSound();
        Navigator.pushNamed(context, "/profile").then((value) => setState((){}));
      }),
      // menuItem(context, "menu_icon/settings.png", "Settings", () async {
      //   playClickSound();
      //   print("setting");
      // }),
      (vBloc.currentUser.role != "n") ? menuItem(context, "menu_icon/view-data.png", "View Data", () async {
        playClickSound();
        Navigator.pushNamed(context, "/data/view").then((value) => setState((){}));
      }) : Container(),
      (vBloc.currentUser.role == "a") ? menuItem(context, "menu_icon/verify.png", "Verify Questions", () async {
        playClickSound();
        Navigator.pushNamed(context, "/questions/verify").then((value) => setState((){}));
      }) : Container(),
    ];
  }

  Widget difficultySelector(BuildContext context) {
    double buttonwidth = 120;
    EdgeInsets padding = EdgeInsets.symmetric(vertical: 0, horizontal: 28.0);
    TextStyle textstyle = TextStyle(fontSize: 20, fontWeight: FontWeight.w300);

    return Container(
      padding: EdgeInsets.all(50.0),
      child: Column(
        children: [
          Text(
            "Choose your Difficulty",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 24.0,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: padding,
                      ),
                      child: Container(
                        width: buttonwidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "difficulty/easy_white.png",
                              height: 40,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              "Easy",
                              style: textstyle,
                            ),
                          ],
                        ),
                      ),
                      onPressed: () {
                        playClickSound();
                        vBloc.complexity = "easy";
                        Navigator.pushNamed(context, "/play").then((value) => setState((){}));
                      }),
                ),
                SizedBox(
                  height: 12.0,
                ),
                Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: padding,
                      ),
                      child: Container(
                        width: buttonwidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "difficulty/normal_white.png",
                              height: 40,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              "Normal",
                              style: textstyle,
                            ),
                          ],
                        ),
                      ),
                      onPressed: () {
                        playClickSound();
                        vBloc.complexity = "normal";
                        Navigator.pushNamed(context, "/play").then((value) => setState((){}));
                      }),
                ),
                SizedBox(
                  height: 12.0,
                ),
                Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: padding,
                      ),
                      child: Container(
                        width: buttonwidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "difficulty/hard_white.png",
                              height: 40,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              "Hard",
                              style: textstyle,
                            ),
                          ],
                        ),
                      ),
                      onPressed: () async {
                        playClickSound();
                        
                        vBloc.complexity = "hard";
                        Navigator.pushNamed(context, "/play").then((value) => setState((){}));
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget menuItem(BuildContext context, String path, String text, Function ontap) {
    Widget textOnButton = Text(
      text,
      style: TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
          color: Colors.white),
      textAlign: TextAlign.left,
    );
    if (MediaQuery.of(context).size.width <= 600){
      textOnButton = Text(
        text,
        style: TextStyle(
            fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.white),
        textAlign: TextAlign.left,
      );
    }

    return InkWell(
      hoverColor: Theme.of(context).colorScheme.secondary,
      highlightColor: Theme.of(context).colorScheme.secondaryVariant,
      focusColor: Theme.of(context).colorScheme.primaryVariant,
      borderRadius: BorderRadius.all(Radius.circular(35.0)),
      child: Container(
        child: Card(
          color: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          child: Container(
            padding: EdgeInsets.all(22.0),
            alignment: Alignment.topLeft,
            child: Stack(
              children: [
                textOnButton,
                Align(
                  alignment: Alignment.bottomRight,
                  child: Image(
                    image: AssetImage(path),
                    height: 90,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      onTap: ontap,
    );
  }
}


