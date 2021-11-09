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
  bool isDraggedToLeft = false;
  bool isDraggedToRight = false;

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
    ).animate(CurvedAnimation(parent: swipeRightController, curve: Curves.easeInQuad));

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
            CurvedAnimation(parent: swipeLeftController, curve: Curves.easeInQuad));

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

  validateAnswer(String dir){
    if(dir == vBloc.CARD_SWIPE_LEFT && news[currentRound - 1].answer == "hoax"){
      setState(() {
        score += Random().nextInt(7) + 5;
      });
    }
    else if(dir == vBloc.CARD_SWIPE_RIGHT && news[currentRound - 1].answer == "legit"){
      setState(() {
        score += Random().nextInt(7) + 5;
      });
    }
    else{
      setState(() {
        score -= Random().nextInt(7) + 2;
      });
    }
    print("score: $score");
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

  Widget loadingScreen() {
    // TODO: alternating text with timers
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircularProgressIndicator(
          color: Colors.white,
        ),
        SizedBox(
          height: 18.0,
        ),
        Text(
          "Generating Questions...",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        )
      ])),
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

  Widget baseWidget(){
    return Column(
      children: [
        infoPanel(),
        topContent(),
        bottomContent(),
      ],
    );
  }

  Widget infoPanel(){
    return Container(
      height: MediaQuery.of(context).size.height * 0.08,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 7,
        child: Container(
          child: Row(
            children: [
              scorePanel(),
            ]
          ),
        )
      ),
    );
  }

  Widget scorePanel() {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 22.0,
          ),
          Container(
            height: 22,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcATop),
              child: Image.asset("difficulty/hard_white.png"),
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Score:",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 6.0,),
              Text(
                "$score",
                style: TextStyle(
                    fontSize: 22.0,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget topContent(){
    return Expanded(
      child: Container(
        color: Theme.of(context).colorScheme.primaryVariant,
        child: Stack(
          children: [
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.74,
                heightFactor: 0.95,
                child: Draggable<bool>(
                  data: true,
                  affinity: Axis.horizontal,
                  // axis: Axis.horizontal,
                  feedback: Container(
                    width: MediaQuery.of(context).size.width * 0.74,
                    height: MediaQuery.of(context).size.height * 0.74,
                    child: mainCard(),
                  ),
                  childWhenDragging: Container(
                    width: MediaQuery.of(context).size.width * 0.74,
                    height: MediaQuery.of(context).size.height * 0.74,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryVariant,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: mainNewsContainer(),
                  onDragCompleted: () {
                    if (isDraggedToLeft == true && isDraggedToRight == false) {
                      vBloc.addCardDirection(vBloc.CARD_SWIPE_LEFT);
                      swipeLeftController.forward();
                    }
                    else if (isDraggedToLeft == false && isDraggedToRight == true){
                      vBloc.addCardDirection(vBloc.CARD_SWIPE_RIGHT);
                      swipeRightController.forward();
                    }
                  },
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [dragTargetLeft(), dragTargetRight()],
            ),
          ],
        ),
      ),
    );
  }

  Widget dragTargetLeft(){
    return Expanded(
      child: DragTarget<bool>(
        builder: (context, accepted, rejected){
          return SizedBox.expand();
        },
        onAccept: (data){
          setState(() {
            isDraggedToLeft = data;
            isDraggedToRight = false;
          });
          print("left: $isDraggedToLeft, right: $isDraggedToRight");
        },
      ),
    );
  }

  Widget dragTargetRight() {
    return Expanded(
      child: DragTarget<bool>(
        builder: (context, accepted, rejected) {
          return SizedBox.expand();
        },
        onAccept: (data) {
          setState(() {
            isDraggedToLeft = false;
            isDraggedToRight = data;
          });
          print("left: $isDraggedToLeft, right: $isDraggedToRight");
        },
      ),
    );
  }

  Widget mainNewsContainer() {
    return StreamBuilder(
      stream: vBloc.cardDirectionStream,
      builder: (context, snapshot) {
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
        } else {
          return mainCard();
        }
      },
    );
  }

  Widget mainCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      elevation: 8,
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
                child: Text(
                    "${news[currentRound - 1].date.day}/${news[currentRound - 1].date.month}/${news[currentRound - 1].date.year}"),
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

  List<Widget> chips() {
    List<String> currentRoundTags = news[currentRound - 1].tags;

    if (currentRoundTags.isNotEmpty) {
      // Kadang-kadang array e isi e satu dan merupakan -> ""
      if (currentRoundTags.length == 1 && currentRoundTags[0] == "") return [];

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
    } else {
      return [];
    }
  }

  Widget bottomContent(){
    return Card(
      margin: EdgeInsets.zero,
      elevation: 7,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.15,
        child: Stack(
          children: [
            backButton(),
            middleActions(),
          ],
        ),
      ),
    );
  }

  Widget backButton(){
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20.0,
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app_rounded),
            iconSize: 24,
            onPressed: () {
              Navigator.pushNamed(context, "/main");
            },
          ),
        ],
      ),
    );
  }

  Widget middleActions(){
    return FractionallySizedBox(
      heightFactor: 1.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.close_rounded),
            iconSize: 36,
            highlightColor: Colors.red[50],
            splashColor: Colors.green[200],
            color: Colors.red,
            onPressed: () {
              if (currentRound != 10) {
                validateAnswer(vBloc.CARD_SWIPE_LEFT);
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
            width: 74,
            height: 74,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Round",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white),
                  ),
                  Text(
                    "$currentRound",
                    style: TextStyle(
                        fontSize: 18,
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
            iconSize: 36,
            highlightColor: Colors.green[100],
            splashColor: Colors.green[200],
            color: Theme.of(context).colorScheme.secondary,
            onPressed: () {
              if (currentRound != 10) {
                validateAnswer(vBloc.CARD_SWIPE_RIGHT);
                vBloc.addCardDirection(vBloc.CARD_SWIPE_RIGHT);
                vBloc.swipeDirection = vBloc.CARD_SWIPE_RIGHT;

                swipeRightController.forward();
              }
            },
          ),
        ],
      ),
    ); 
  }
}