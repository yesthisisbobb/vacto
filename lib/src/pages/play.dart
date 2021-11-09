import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../blocs/variables_provider.dart';
import '../classes/News.dart';

class Play extends StatefulWidget {
  Play({Key key}) : super(key: key);

  @override
  _PlayState createState() => _PlayState();
}

class _PlayState extends State<Play> with TickerProviderStateMixin{
  VariablesBloc vBloc;
  List<int> newsIds;
  List<News> news;
  bool newsHasAlreadyInitialized = false;

  int currentRound = 1;
  int maxRound = 10;
  int score = 0;

  AnimationController swipeRightController;
  AnimationController swipeLeftController;

  Animation<Offset> swipeRightCardAnimation;
  Animation<Offset> swipeLeftCardAnimation;

  @override
  void initState() {
    super.initState();

    // Controller init
    swipeRightController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    swipeLeftController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    // Animation init
    swipeRightCardAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(1.5, 0.0)
    ).animate(CurvedAnimation(parent: swipeRightController, curve: Curves.easeIn));

    swipeRightCardAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        print("OK Kanan");
        setState(() {
          if(currentRound != maxRound) currentRound++;
        });
        print("currentRound: $currentRound");
        swipeRightController.reverse();
      }
    });

    swipeLeftCardAnimation =
        Tween<Offset>(begin: Offset.zero, end: Offset(-1.5, 0.0)).animate(
            CurvedAnimation(parent: swipeLeftController, curve: Curves.easeIn));

    swipeLeftCardAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        print("OK Kiri");
        setState(() {
          if(currentRound != maxRound) currentRound++;
        });
        print("currentRound: $currentRound");
        swipeLeftController.reverse();
      }
    });
  }

  @override
  void dispose(){
    super.dispose();
    swipeRightController.dispose();
    swipeLeftController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    vBloc = VariablesProvider.of(context);

    return Scaffold(
      body: Container(
        child: initProcess()
      ),
    );
  }

  Widget initProcess(){
    return FutureBuilder(
      future: Future<List<int>>(() async {
        List<int> result = [];

        if (newsHasAlreadyInitialized == true) return result;

        var res = await http.get(Uri.parse("http://localhost:3000/api/news/generate/10"));
        if (res.statusCode == 200) {
          var jsonData = res.body.toString();
          var parsedJson = json.decode(jsonData);
          
          for (var item in parsedJson) {
            result.add(item["id"]);
          }

          return result;
        }
        else{
          return result;
        }
      }),
      builder: (context, snapshot){
        if(snapshot.hasData){
          if(snapshot.data != null && newsHasAlreadyInitialized == false){
            // Get IDs first
            newsIds = List.castFrom(snapshot.data);
            
            return FutureBuilder(
              future: Future<List<News>>(() async {
                List<News> result = [];

                // TODO: handle error
                for (var item in newsIds) {
                  News tempNews = News();
                  await tempNews.fillOutDataFromID(item);

                  result.add(tempNews);
                }

                return result;
              }),
              builder: (context, snapshot){
                // Initialize News Items
                news = List.castFrom(snapshot.data);

                if(snapshot.hasData){
                  if (news.isNotEmpty) {
                    newsHasAlreadyInitialized = true;
                    return baseWidget();
                  }
                  else{
                    return Container(
                      child: Text("Failed initializing news objects"),
                    );
                  }
                }
                else{
                 return loadingScreen();
                }
              },
            );
          }
          else if(newsHasAlreadyInitialized == true){
            return baseWidget();
          }
          else{
            return Container(
              child: Text("Failed retrieving data"),
            );
          }
        }
        else{
          return loadingScreen();
        }
      },
    );
  }

  Widget loadingScreen(){
    // TODO: alternating text with timers
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
            ),
            SizedBox(height: 18.0,),
            Text("Generating Questions...",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white
              ),
            )
          ]
        )
      ),
    );
  }

  Widget baseWidget(){
    return Column(
      children: [
        topContent(),
        bottomContent(),
      ],
    );
  }

  Widget topContent(){
    return Expanded(
      child: FractionallySizedBox(
        widthFactor: 0.7,
        heightFactor: 0.95,
        child: Draggable<bool>(
          data: true,
          affinity: Axis.horizontal,
          axis: Axis.horizontal,
          feedback: Container(color: Colors.red, height: 200, width: 200,),
          child: mainNewsContainer()
        ),
      ),
    );
  }

  Widget bottomContent(){
    return Card(
      margin: EdgeInsets.zero,
      elevation: 7,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.2,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 16.0,),
                  IconButton(
                    icon: Icon(Icons.exit_to_app_rounded),
                    iconSize: 26,
                    onPressed: () {
                      Navigator.pushNamed(context, "/main");
                    },
                  ),
                ],
              ),
            ),
            FractionallySizedBox(
              heightFactor: 1.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.close_rounded),
                    iconSize: 40,
                    color: Colors.red,
                    onPressed: () {
                      if (currentRound != 10) {
                        if (news[currentRound - 1].answer == "hoax") {
                          setState(() {
                            score -= Random().nextInt(7) + 2;
                          });
                          print("score: $score");
                        }

                        vBloc.addCardDirection(vBloc.CARD_SWIPE_LEFT);
                        vBloc.swipeDirection = vBloc.CARD_SWIPE_LEFT;

                        swipeLeftController.forward();
                      }
                    },
                  ),
                  SizedBox(
                    width: 28.0,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Theme.of(context).colorScheme.primary),
                    width: 80,
                    height: 80,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Round",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white),
                          ),
                          Text(
                            "$currentRound",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 28.0,
                  ),
                  IconButton(
                    icon: Icon(Icons.check_rounded),
                    iconSize: 40,
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: () {
                      if (currentRound != 10) {
                        if (news[currentRound - 1].answer == "legit") {
                          setState(() {
                            score += Random().nextInt(7) + 5;
                          });
                          print("score: $score");
                        }

                        vBloc.addCardDirection(vBloc.CARD_SWIPE_RIGHT);
                        vBloc.swipeDirection = vBloc.CARD_SWIPE_RIGHT;

                        swipeRightController.forward();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget mainNewsContainer() {
    return StreamBuilder(
      stream: vBloc.cardDirectionStream,
      builder: (context, snapshot){
        if (snapshot.hasData) {
          if (snapshot.data == vBloc.CARD_SWIPE_RIGHT) {
            return SlideTransition(
              position: swipeRightCardAnimation,
              child: mainCard(),
            );
          } else {
            return SlideTransition(
              position: swipeLeftCardAnimation,
              child: mainCard(),
            );
          }
        }
        else{
          return mainCard();
        }
      },
    );
  }

  Widget mainCard(){
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        padding: EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  news[currentRound - 1].title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text("${news[currentRound - 1].date.day}/${news[currentRound - 1].date.month}/${news[currentRound - 1].date.year}"),
              ),
              SizedBox(
                height: 18.0,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  direction: Axis.horizontal,
                  children: chips(),
                ),
              ),
              SizedBox(
                height: 18.0,
              ),
              Container(
                height: 600,
                child: Image.asset(
                  "placeholders/testpp.jpg",
                  fit: BoxFit.fitWidth,
                ),
              ),                
              SizedBox(
                height: 18.0,
              ),
              Container(
                child: Text(
                  news[currentRound - 1].content,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(
                height: 18.0,
              ),
              Text(news[currentRound - 1].source),
              SizedBox(
                height: 36.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> chips(){
    List<String> currentRoundTags = news[currentRound - 1].tags;

    if (currentRoundTags.isNotEmpty) {
      // Kadang-kadang array e isi e satu dan merupakan -> ""
      if(currentRoundTags.length == 1 && currentRoundTags[0] == "") return [];

      return List<Widget>.generate(news[currentRound - 1].tags.length, (index) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(label: Text(news[currentRound - 1].tags[index])),
            SizedBox(
              width: 8.0,
            )
          ],
        );
      });
    }
    else{
      return [];
    }
  }
}