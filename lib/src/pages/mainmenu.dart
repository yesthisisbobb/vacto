import 'dart:js';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:vacto/src/classes/Feed.dart';
import 'package:vacto/src/classes/User.dart';
import 'package:vacto/src/pages/loadingscreen.dart';

import '../blocs/variables_provider.dart';

class MainMenu extends StatefulWidget {
  MainMenu({Key key}) : super(key: key);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  // TODO: make live feed of people, prolly on left side of screen
  VariablesBloc vBloc;
  List<Feed> feeds;

  String feedType = "";

  @override
  Widget build(BuildContext context) {
    vBloc = VariablesProvider.of(context);
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
              child: Row(
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
              Image(
                image: AssetImage("vacto_full.png"),
                height: 42,
              ),
              SizedBox(
                height: 20,
              ),
              Card(
                borderOnForeground: true,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
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
                            backgroundImage: NetworkImage(
                                'https://www.woolha.com/media/2020/03/eevee.png',
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
                                  "country-flags/${vBloc.currentUser.nationality}.png"),
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
                          child: Text("[Showcase Achievement]"),
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
                            onPressed: () {
                              vBloc.localS.deleteItem("id");
                              Navigator.pushNamed(context, "/login");
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.0,),
              Expanded(
                child: Card(
                  borderOnForeground: true,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(70.0))),
                  shadowColor: Color.fromRGBO(0, 0, 0, 0.2),
                  elevation: 5.0,
                  child: Container(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
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
                          ),
                          SizedBox(height: 12.0,),
                          Expanded(
                            child: feed(),
                          ),
                        ],
                      )
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget feed(){
    vBloc.feedTypeChange(feedType);

    return StreamBuilder(
      stream: vBloc.feedTypeStream,
      builder: (context, snapshot){
        print("Masuk streambuilder feed");
        print(snapshot);
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

                print(tempArr);
                return tempArr;
              }

              return [];
            }),
            builder: (context, snapshot){
              print("Masuk futurebuilder feed");
              print(snapshot);
              if (snapshot.hasData) {
                feeds = List.castFrom(snapshot.data);
                print(feeds);
                print(feeds.length);
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
                  return CircularProgressIndicator();
                }
              }
              else{
                return CircularProgressIndicator();
              }
            }
          );
        }
        else{
          return CircularProgressIndicator();
        }
      }
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
    return Container(
      padding: EdgeInsets.all(20.0),
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 20.0,
        crossAxisSpacing: 20.0,
        children: menus(context),
      ),
    );
  }

  List<Widget> menus(BuildContext context) {
    return [
      menuItem(context, "menu_icon/play.png", "Play", () {
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
                                        onPressed: () {
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
                                        onPressed: () {
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
      menuItem(context, "menu_icon/challenge.png", "Challenge Another Player", () {
        Navigator.pushNamed(context, "/challenge");
      }),
      menuItem(context, "menu_icon/add.png", "Add News", () {
        Navigator.pushNamed(context, "/add");
      }),
      menuItem(context, "menu_icon/leaderboard.png", "Leaderboard", () {
        Navigator.pushNamed(context, "/leaderboard");
      }),
      menuItem(context, "menu_icon/profile.png", "Profile", () {
        Navigator.pushNamed(context, "/profile");
      }),
      menuItem(context, "menu_icon/settings.png", "Settings", () {
        print("setting");
      }),
      (vBloc.currentUser.role != "n") ? menuItem(context, "menu_icon/view-data.png", "View Data", () {
        Navigator.pushNamed(context, "/data/view");
      }) : Container(),
      (vBloc.currentUser.role == "a") ? menuItem(context, "menu_icon/verify.png", "Verify Questions", () {
        print("playtest7");
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
                        vBloc.complexity = "easy";
                        Navigator.pushNamed(context, "/play");
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
                        vBloc.complexity = "normal";
                        Navigator.pushNamed(context, "/play");
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
                      onPressed: () {
                        vBloc.complexity = "hard";
                        Navigator.pushNamed(context, "/play");
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget menuItem(BuildContext context, String path,
      String text, Function ontap) {
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
                Text(
                  text,
                  style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.left,
                ),
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


