import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../blocs/variables_provider.dart';
import '../classes/News.dart';

class Play extends StatefulWidget {
  Play({Key key}) : super(key: key);

  @override
  _PlayState createState() => _PlayState();
}

class _PlayState extends State<Play> with TickerProviderStateMixin{
  VariablesBloc vBloc;
  bool isRatingAndTierFilled = false;
  int currentRating = 0;
  int currentTier = 0;
  List<int> newsIds;
  List<News> news;
  bool newsHasAlreadyInitialized = false;

  FToast fToast;

  bool isTimerStarted = false;
  double maxTime = 180;
  // double maxTime = 5;
  double timerValue = 0;
  Timer timer;
  AnimationController timerColorC;
  Animation<Color> timerColor;

  int currentRound = 1;
  int maxRound = 10;
  int score = 0;
  int recentScorePoint = 0;
  int answeredCorrect = 0;
  int answeredCorrectOpponent = 0;
  TextEditingController reasoningC;
  String reasoning = "";
  String challengeStatus = "";
  bool isDraggedToLeft = false;
  bool isDraggedToRight = false;
  bool canDoNextRound = true; 
  bool isChallengeWithdrawn = false;
  bool isGameOver = false;
  bool canShowGameOverScreen = false;

  String reference1 = "";
  String reference2 = "";

  AnimationController swipeRightController;
  AnimationController swipeLeftController;

  Animation<Offset> swipeRightCardAnimation;
  Animation<Offset> swipeLeftCardAnimation;

  @override
  void initState() {
    super.initState();

    fToast = FToast();
    fToast.init(context);

    reasoningC = TextEditingController();

    timerColorC = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1)
    );

    timerColor = ColorTween(
      begin: Colors.blue,
      end: Colors.grey
    ).animate(timerColorC);

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

    swipeRightCardAnimation.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        print("OK Kanan");
        if (news[currentRound - 1].type == "uc") await showReasoningScreen();
        await uploadAnswer();
        nextRound();
        await gameOverProccess();
        if (isGameOver == false) swipeRightController.reverse();
      }
    });

    swipeLeftCardAnimation =
        Tween<Offset>(begin: Offset.zero, end: Offset(-1.5, 0.0)).animate(
            CurvedAnimation(parent: swipeLeftController, curve: Curves.easeInQuad));

    swipeLeftCardAnimation.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        print("OK Kiri");
        if (news[currentRound - 1].type == "uc") await showReasoningScreen();
        await uploadAnswer();
        nextRound();
        await gameOverProccess();
        if (isGameOver == false) swipeLeftController.reverse();
      }
    });
  }

  getReference(int idx) {
    SnackBar notif = SnackBar(
      content: Text("Reference isn't available for this news article"),
    );

    if(news[currentRound - 1].references.length < idx){
      ScaffoldMessenger.of(context).showSnackBar(notif);
    }
    else if (news[currentRound - 1].references[idx - 1].toString() != "") {
      launch(news[currentRound - 1].references[idx - 1].toString());
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(notif);
    }
  }

  validateAnswer(String dir){
    if(dir == vBloc.CARD_SWIPE_LEFT && news[currentRound - 1].answer == "hoax"){
      print("bener hoax");

      if (news[currentRound - 1].type == "or") {
        recentScorePoint = Random().nextInt(6) + 5;
      } else if(news[currentRound - 1].type == "uc"){
        recentScorePoint = Random().nextInt(4) + 1;
      }
      print(recentScorePoint.toString());

      setState(() {
        score += recentScorePoint;
        answeredCorrect++;
      });

      scoreToast(true, recentScorePoint);
    }
    else if(dir == vBloc.CARD_SWIPE_RIGHT && news[currentRound - 1].answer == "legit"){
      print("bener legit");
      
      if (news[currentRound - 1].type == "or") {
        recentScorePoint = Random().nextInt(6) + 5;
      } else if (news[currentRound - 1].type == "uc") {
        recentScorePoint = Random().nextInt(4) + 1;
      }
      print(recentScorePoint.toString());

      setState(() {
        score += recentScorePoint;
        answeredCorrect++;
      });

      scoreToast(true, recentScorePoint);
    }
    else{
      print("salah");

      if (news[currentRound - 1].type == "or") {
        recentScorePoint = Random().nextInt(6) + 2;
      } else if (news[currentRound - 1].type == "uc") {
        recentScorePoint = Random().nextInt(4) + 1;
      }
      print(recentScorePoint.toString());

      setState(() {
        (news[currentRound - 1].type == "uc") ? score += recentScorePoint : score -= recentScorePoint;
      });

      (news[currentRound - 1].type == "uc") ? scoreToast(true, recentScorePoint) : scoreToast(false, recentScorePoint);
    }
    print("score: $score");
  }

  uploadAnswer() async {
    String recentAnswer = "";
    if (vBloc.swipeDirection == vBloc.CARD_SWIPE_LEFT) recentAnswer = "hoax";
    else if (vBloc.swipeDirection == vBloc.CARD_SWIPE_RIGHT) recentAnswer = "legit";

    if(news[currentRound - 1].type != "uc") reasoning = "";
    print("noprob");

    print(vBloc.localS.getItem("id"));
    print(news[currentRound - 1].id.toString());
    print(recentAnswer);
    print(recentScorePoint.toString());

    var res = await http.post(Uri.parse("http://localhost:3000/api/answer/upload"),
      body: {
        "user": vBloc.localS.getItem("id"),
        "news": news[currentRound - 1].id.toString(),
        "answer": recentAnswer,
        "score": recentScorePoint.toString(),
        "reasoning": reasoning
      }
    );
    print("noprob2");

    if (res.statusCode == 200) {
      print("noprob3a");
      return true;
    }
    else{
      print("noprob3b");
      return false;
    }
  }

  nextRound(){
    setState(() {
      if (vBloc.isGameModeTimed == false) {
        if (currentRound <= maxRound) {
          currentRound++;
          canDoNextRound = true;
        }
        if (currentRound == maxRound + 1) {
          currentRound = 10;
          canDoNextRound = false;
          isGameOver = true;
        }
      } else {
        currentRound++;
        canDoNextRound = true;
      }
    });

    print("============== NEXT ROUND ==============");
    print("currentRound: $currentRound");
    return canDoNextRound;
  }

  Future<bool> updateStats() async {
    // user id
    // gamemode (s standard / t timed / c challenge)
    // rating (MMR)
    // tstg (Times Spent on Timed Gamemode)
    // ca (Correct Answers)
    // tqf (Total Questions Faced)

    String gameMode = "";
    String changesToRating = score.toString();
    String timeAddition;
    String caAddition = answeredCorrect.toString();
    String questionAddition = currentRound.toString();
    
    if (vBloc.isGameModeTimed == true) {
      gameMode = "t";
      timeAddition = timer.tick.toString();
    } else if (vBloc.isGameModeChallenge == true){
      gameMode = "c";
      timeAddition = "0";
      changesToRating = "0";
    } else{
      gameMode = "s";
      timeAddition = "0";
    }

    print("============== UPDATE STATS ==============");
    print("ca: $caAddition");
    print("tqf: $questionAddition");
    print("gamemode: $gameMode");

    var res = await http.post(Uri.parse("http://localhost:3000/api/user/update/stats"),
      body: {
        "id": vBloc.currentUser.id,
        "gamemode": gameMode,
        "rating": changesToRating,
        "tstg": timeAddition,
        "ca": caAddition,
        "tqf": questionAddition,
      }
    );
    if (res.statusCode == 200) {
      print("berhasil update");
    }

    // Update class user habis proses
    await vBloc.currentUser.fillOutDataFromID(vBloc.localS.getItem("id"));

    return true;
  }

  uploadChallenge() async{
    String questions = "";
    for (var i = 0; i < news.length; i++) {
      if(i < news.length - 1) questions += "${news[i].id.toString()},";
      else questions += "${news[i].id.toString()}";
    }

    print("UPLOAD CHALLENGE -------------------");
    print(questions);
    print(vBloc.currentUser.id);
    print(vBloc.opponentId);
    print(answeredCorrect.toString());

    var res = await http.post(Uri.parse("http://localhost:3000/api/challenge/add"),
      body: {
        "questions": questions,
        "user1": vBloc.currentUser.id,
        "user2": vBloc.opponentId,
        "user1ca": answeredCorrect.toString()
      }
    );

    if(res.statusCode == 200) return true;
    return false;
  }

  updateChallenge() async {
    print("MASUK UPDATE CHALLENGE ====");
    int scoreDiff = ((answeredCorrectOpponent - answeredCorrect).abs()) * 3;
    String winner, loser;
    if(answeredCorrectOpponent > answeredCorrect || isChallengeWithdrawn == true){
      winner = vBloc.opponentId;
      loser = vBloc.currentUser.id;
      setState(() {
        challengeStatus = "lose";
      });
    }
    else if(answeredCorrectOpponent < answeredCorrect){
      winner = vBloc.currentUser.id;
      loser = vBloc.opponentId;
      setState(() {
        challengeStatus = "win";
      });
    }
    else{
      winner = vBloc.currentUser.id;
      loser = vBloc.opponentId;
      setState(() {
        challengeStatus = "draw";
      });
    }
    print("$winner");
    print("$loser");
    print("$challengeStatus");

    var res = await http.post(Uri.parse("http://localhost:3000/api/challenge/update"),
      body: {
        "id": vBloc.challengeId.toString(),
        "user2ca": answeredCorrect.toString(),
        "score": scoreDiff.toString(),
        "winner": winner,
        "loser": loser,
        "challengestatus": challengeStatus
      }
    );

    if(res.statusCode == 200) return true;
    return false;
  }

  Future<bool> achievementProcess() async {
    List<int> userAchievements = [];
    int timeAchievement = 0;
    int standardGamemodeAchievement = 0;
    int timedGamemodeAchievement = 0;
    int challengeAchievement = 0;
    int tierUpAchievement = 0;

    var res = await http.get(Uri.parse("http://localhost:3000/api/user/achievement/get/${vBloc.currentUser.id}"));
    if(res.statusCode == 200){
      var jsonData = res.body.toString();
      var parsedData = json.decode(jsonData);

      for (var item in parsedData) {
        userAchievements.add(item["achievement"]);
      }
      print("User Achievements");
      print(userAchievements);
    }

    // Time played check (needs work)
    DateTime nowTime = DateTime.now();
    print(nowTime.toString());
    print(nowTime.hour.toString());

    if(nowTime.hour>= 22 && nowTime.hour<= 24){
      timeAchievement = 3;
    }
    else if((nowTime.hour >= 25 && nowTime.hour <= 30) || (nowTime.hour >= 1 && nowTime.hour<= 5)){
      timeAchievement = 2;
    }

    // Standard gamemode check
    if(vBloc.isGameModeTimed == false && vBloc.isGameModeChallenge == false){
      if(vBloc.currentUser.sgp + 1 >= 1 && vBloc.currentUser.sgp + 1 < 10){
        standardGamemodeAchievement = 1;
      }
      else if (vBloc.currentUser.sgp + 1 >= 10 && vBloc.currentUser.sgp + 1 < 100) {
        standardGamemodeAchievement = 11;
      }
      else if (vBloc.currentUser.sgp + 1 >= 100) {
        standardGamemodeAchievement = 12;
      }
    }

    // Timed gamemode check
    if(vBloc.isGameModeTimed == true){
      if (vBloc.currentUser.tstg + timer.tick >= 180){
        timedGamemodeAchievement = 4;
      }
      if (vBloc.currentUser.tstg + timer.tick >= 900) {
        timedGamemodeAchievement = 13;
      }
      if (vBloc.currentUser.tstg + timer.tick >= 1800) {
        timedGamemodeAchievement = 14;
      }
    }

    // Challenge check
    if(vBloc.isGameModeChallenge == true && vBloc.isChallenged == true){
      if (challengeStatus == "win") {
        if (vBloc.currentUser.cw + 1 == 1) {
          challengeAchievement = 15;
        } if (vBloc.currentUser.cw + 1 == 10) {
          challengeAchievement = 16;
        } if (vBloc.currentUser.cw + 1 == 100) {
          challengeAchievement = 17;
        }
      }
    }

    // Tier up check
    if(vBloc.isGameModeChallenge == false && vBloc.isChallenged == false){
      print("Tier up check: ${vBloc.currentUser.rating + score}");
      if (vBloc.currentUser.rating + score >= 200){
        tierUpAchievement = 5;
      }
      if (vBloc.currentUser.rating + score >= 400) {
        tierUpAchievement = 6;
      }
      if (vBloc.currentUser.rating + score >= 800) {
        tierUpAchievement = 7;
      }
      if (vBloc.currentUser.rating + score >= 1600) {
        tierUpAchievement = 8;
      }
      if (vBloc.currentUser.rating + score >= 3200) {
        tierUpAchievement = 9;
      }
      if (vBloc.currentUser.rating + score >= 6400) {
        tierUpAchievement = 10;
      }
    }
    else{
      if(challengeStatus == "win"){
        int scoreDiff = (answeredCorrect - answeredCorrectOpponent).abs() * 3;

        if (vBloc.currentUser.rating + scoreDiff >= 200) {
          tierUpAchievement = 5;
        }
        if (vBloc.currentUser.rating + scoreDiff >= 400) {
          tierUpAchievement = 6;
        }
        if (vBloc.currentUser.rating + scoreDiff >= 800) {
          tierUpAchievement = 7;
        }
        if (vBloc.currentUser.rating + scoreDiff >= 1600) {
          tierUpAchievement = 8;
        }
        if (vBloc.currentUser.rating + scoreDiff >= 3200) {
          tierUpAchievement = 9;
        }
        if (vBloc.currentUser.rating + scoreDiff >= 6400) {
          tierUpAchievement = 10;
        }
      }
    }

    // Klo achievement udah ada
    if (userAchievements.contains(timeAchievement)) timeAchievement = 0;
    if (userAchievements.contains(standardGamemodeAchievement)) standardGamemodeAchievement = 0;
    if (userAchievements.contains(timedGamemodeAchievement)) timedGamemodeAchievement = 0;
    if (userAchievements.contains(challengeAchievement)) challengeAchievement = 0;
    if (userAchievements.contains(tierUpAchievement)) tierUpAchievement = 0;

    if(timeAchievement != 0){
      var res = await http.post(Uri.parse("http://localhost:3000/api/user/achievement/add"),
        body: {
          "uid": vBloc.currentUser.id,
          "aid": timeAchievement.toString()
        }
      );
      if (res.statusCode == 400) print(res.body.toString());
      else{
        achievementToast(Image.asset("vacto_logo.png",height: 20,));
      }
    }
    if (standardGamemodeAchievement != 0) {
      var res = await http.post(
          Uri.parse("http://localhost:3000/api/user/achievement/add"),
          body: {"uid": vBloc.currentUser.id, "aid": standardGamemodeAchievement.toString()});
      if (res.statusCode == 400) print(res.body.toString());
      else {
        achievementToast(Image.asset("vacto_logo.png",height: 20,));
      }
    }
    if (timedGamemodeAchievement != 0) {
      var res = await http.post(
          Uri.parse("http://localhost:3000/api/user/achievement/add"),
          body: {"uid": vBloc.currentUser.id, "aid": timedGamemodeAchievement.toString()});
      if (res.statusCode == 400) print(res.body.toString());
      else {
        achievementToast(Image.asset("vacto_logo.png",height: 20,));
      }
    }
    if (challengeAchievement != 0) {
      var res = await http.post(
          Uri.parse("http://localhost:3000/api/user/achievement/add"),
          body: {"uid": vBloc.currentUser.id, "aid": challengeAchievement.toString()});
      if (res.statusCode == 400) print(res.body.toString());
      else {
        achievementToast(Image.asset("vacto_logo.png",height: 20,));
      }
    }
    if (tierUpAchievement != 0) {
      var res = await http.post(
          Uri.parse("http://localhost:3000/api/user/achievement/add"),
          body: {"uid": vBloc.currentUser.id, "aid": tierUpAchievement.toString()});
      if (res.statusCode == 400) print(res.body.toString());
      else {
        achievementToast(Image.asset("vacto_logo.png",height: 20,));
      }
    }

    return true;
  }

  gameOverProccess() async {
    // Perhitungan game over screen
    if (isGameOver == true) {
      if(vBloc.isGameModeChallenge == true && vBloc.isChallenged == false){
        await uploadChallenge();
      }
      if(vBloc.isGameModeChallenge == true && vBloc.isChallenged == true){
        await updateChallenge();
      }

      await achievementProcess();

      if(await updateStats()){
        setState(() {
          canShowGameOverScreen = true;
        });
      }
    }
  }

  scoreToast(bool isCorrect , int score){
    String plusminus = isCorrect == true ? "+" : "-";
    Widget toast = Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50.0),
        color: isCorrect == true ? Colors.green[300] : Colors.red[400],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCorrect ? Icons.check : Icons.close,
            color: isCorrect == true ? Colors.green[900] : Colors.red[900],
          ),
          SizedBox(width: 12.0,),
          Text("$plusminus$score")
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      toastDuration: Duration(milliseconds: 1500),
      positionedToastBuilder: (context, child){
        return Positioned(
          top: 80,
          left: 24,
          child: child
        );
      }
    );
  }

  achievementToast(Image img){
    Widget toast = Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50.0),
        color: Colors.green[300],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check,
            size: 20,
          ),
          SizedBox(width: 12.0,),
          Text("An Achievement Reached!"),
          SizedBox(width: 12.0,),
          img,
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      toastDuration: Duration(seconds: 2),
      positionedToastBuilder: (context, child){
        return Positioned(
          child: child,
          bottom: 100,
          left: 24,
        );
      },
    );
  }
  
  Future<bool> showExitDialog() async {
    String titleText = "Quit?",
      text1 = "Are you sure you want to quit?",
      text2 = "If you quit, the ongoing game will be counted as a loss",
      buttonText = "Quit game";
    
    if (vBloc.isGameModeChallenge == true && vBloc.isChallenged == false) {
      text2 = "If you quit, this challenge will be discarded";
      buttonText = "Discard Challenge";
    }
    else if(vBloc.isGameModeChallenge == true && vBloc.isChallenged == true){
      text1 = "Are you sure you want to withdraw from challenge?";
      text2 = "If you quit, this challenge will be counted as a loss";
      buttonText = "Withdraw";
    }

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context){
        return AlertDialog(
          title: Text(titleText),
          titlePadding: EdgeInsets.only(top: 24.0, left: 24.0),
          actionsPadding: EdgeInsets.all(12.0),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text1,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600
                  ),
                ),
                Text(text2)
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              child: Text(buttonText),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context, false);
              },
            )
          ],
        );
      }
    );
  }

  Future<bool> showReasoningScreen() async {
    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          content: Container(
            padding: EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.contact_support_rounded,
                  size: 50,
                ),
                SizedBox(
                  height: 12.0,
                ),
                Text("Why did you choose your answer?"),
                SizedBox(
                  height: 12.0,
                ),
                Container(
                  width: 300,
                  child: TextField(
                    controller: reasoningC,
                    maxLines: null,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Your reasoning",
                    ),
                  ),
                ),
                SizedBox(
                  height: 12.0,
                ),
                ElevatedButton(
                  child: Text("Submit"),
                  onPressed: () {
                    reasoning = reasoningC.text;
                    reasoningC.text = "";
                    Navigator.pop(context, true);
                  },
                )
              ],
            ),
          ),
        );
      }
    );
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

    // Biar ga keisi lagi setiap build
    if(!isRatingAndTierFilled){
      currentRating = vBloc.currentUser.rating;
      currentTier = vBloc.currentUser.level;
      isRatingAndTierFilled = true;
    }

    return Scaffold(
      body: Container(
        child: initProcess(context)
      ),
      endDrawer: drawerReference(),
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

  Widget drawerReference(){
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: Text(
              "News Article References",
              style: TextStyle(color: Colors.white, fontSize: 24.0),
            ),
          ),
          ListTile(
            leading: Text("I"),
            title: Text("Reference 1"),
            onTap: (){
              getReference(1);
            },
          ),
          (vBloc.complexity != "normal") ? ListTile(
            leading: Text("II"),
            title: Text("Reference 2"),
            onTap: (){
              getReference(2);
            },
          ) : Container(),
        ],
      ),
    );
  }

  Widget initProcess(BuildContext context){
    return FutureBuilder(
      future: Future<List<int>>(() async {
        List<int> result = [];
        int numOfNews = 10;

        // If news has already been generated, to prevent regenerating news
        if (newsHasAlreadyInitialized == true) return result;

        // If it's a challenge, don't generate news, get the news
        if (vBloc.isGameModeChallenge == true && vBloc.isChallenged == true) {
          var res = await http.get(Uri.parse("http://localhost:3000/api/challenge/get/${vBloc.challengeId}"));
          if (res.statusCode == 200) {
            var jsonData = res.body.toString();
            var parsedJson = json.decode(jsonData);
            
            print(parsedJson.toString());
            // Because if challenged, that means this is a second user
            answeredCorrectOpponent = parsedJson["user1_ca"];

            String receivedIds = parsedJson["questions"];
            List<String> receivedIdArr = receivedIds.split(",");
            maxRound = receivedIdArr.length;

            for (var item in receivedIdArr) {
              result.add(int.parse(item));
            }

            return result;
          }
          else{
            return result;
          }
        } else {
          // Not a challenge gamemode
          // Set news amount to 360 to overcompensate user clicking an answer every second
          if (vBloc.isGameModeTimed == true) numOfNews = maxTime.round() * 2;

          var res = await http.get(
              Uri.parse("http://localhost:3000/api/news/generate/$numOfNews"));
          if (res.statusCode == 200) {
            var jsonData = res.body.toString();
            var parsedJson = json.decode(jsonData);

            for (var item in parsedJson) {
              result.add(item["id"]);
            }

            return result;
          } else {
            return result;
          }
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

                    // TIMER INIT
                    if(isTimerStarted == false && vBloc.isGameModeTimed){
                      timer = Timer.periodic(Duration(seconds: 1), (timer) async {
                        if (timer.tick == maxTime) {
                          timer.cancel();
                          setState(() {
                            isGameOver = true;
                          });
                          await gameOverProccess();
                        }
                        setState(() {
                          timerValue = timer.tick / maxTime;
                        });
                      });
                      isTimerStarted = true;
                    }

                    return baseWidget(context);
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
            return baseWidget(context);
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

  Widget baseWidget(BuildContext context){
    return Stack(
      children: [
        Column(
          children: [
            infoPanel(),
            topContent(),
            bottomContent(),
          ],
        ),
        drawerButton(context),
        // reasoningScreen(),
        gameOverScreen(),
        // gameOverDebug(),
        // uploadDebug(),
        // newsInfoDebug(),
      ],
    );
  }

  Widget gameOverDebug(){
    return Positioned(
      top: 70,
      left: 0,
      child: ElevatedButton(
        child: Text("Debug game over"),
        onPressed: (){
          setState(() {
            isGameOver = !isGameOver;
          });
        },
      )
    );
  }

  Widget uploadDebug(){
    return Positioned(
      top: 100,
      left: 0,
      child: ElevatedButton(
        child: Text("Debug upload"),
        onPressed: () async {
          print(await updateStats());
        },
      )
    ); 
  }

  Widget newsInfoDebug() {
    return Positioned(
        top: 130,
        left: 0,
        child: ElevatedButton(
          child: Text("Debug News Info"),
          onPressed: () {
            print(news[currentRound - 1].toString());
            print(news[currentRound - 1].subtype);
          },
        ));
  }

  Widget drawerButton(BuildContext context){
    if (news[currentRound-1].type == "uc"){
      return Container();
    }
    else if(vBloc.complexity != "hard"){
      return Positioned(
        right: 10,
        top: 70,
        child: IconButton(
          icon: Icon(Icons.article_rounded),
          iconSize: 40.0,
          color: Colors.white,
          onPressed: (){
            Scaffold.of(context).openEndDrawer();
          },
        )
      ); 
    }
    else{
      return Container();
    }
  }

  Widget gameOverScreen(){
    String headerText = "Congratulations";

    if(vBloc.isGameModeChallenge == true){
      if (challengeStatus == "lose") headerText = "You lost";
      if (challengeStatus == "win") headerText = "You won";
      if (challengeStatus == "draw") headerText = "It's a draw";
    }
    else{
      if (answeredCorrect < 5) headerText = "Nice try";
      if (answeredCorrect == 5) headerText = "Well balanced";
    }

    TextStyle headerStyle = TextStyle(
      fontSize: 42.0,
      fontWeight: FontWeight.bold,
    );
    TextStyle scoreStyle = TextStyle(
      fontSize: 30.0,
      fontWeight: FontWeight.w600,
    );
    TextStyle otherStyle = TextStyle(
      fontSize: 18.0,
    );
    TextStyle otherStyleBold = TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w500
    );

    String topText = "You finished the game with a score of";
    if(vBloc.isChallenged == true) topText = "You finished the game and answered correctly";

    Column addedTopTextWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Within a span of 3 minutes",
          style: otherStyle,
        ),
        SizedBox(
          height: 8.0,
        )
      ],
    );

    Column topTextWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 16.0,
        ),
        (vBloc.isGameModeTimed == true) ? addedTopTextWidget : SizedBox.shrink(),
        Text(
          "$topText",
          style: otherStyle,
        ),
      ],
    );

    Column scoreWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 10.0,
        ),
        Text(
          (vBloc.isChallenged == false) ? "$score" : "$answeredCorrect",
          style: scoreStyle,
        ),
      ],
    );

    
    String bottomText = "And answered correctly ";
    String bottomText2 = "$answeredCorrect ";
    String bottomText3 = "times out of ";
    String bottomText4 = "$maxRound ";
    if (vBloc.isGameModeTimed == true) bottomText4 = "$currentRound ";
    String bottomText5 = "news article!";

    RichText bottomTextV1 = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: bottomText,
          style: Theme.of(context).textTheme.bodyText2,
          children: [
            TextSpan(text: bottomText2, style: otherStyleBold),
            TextSpan(text: bottomText3),
            TextSpan(text: bottomText4, style: otherStyleBold),
            TextSpan(text: bottomText5),
          ]),
    );

    int finalRatingChanges = ((answeredCorrectOpponent - answeredCorrect).abs()) * 3;
    String plusorminus = "";
    if (challengeStatus == "win") plusorminus = "You took $finalRatingChanges points from your opponent's rating";
    if (challengeStatus == "lose") plusorminus = "Your opponent's ratings changes by $finalRatingChanges thanks to you";

    Widget scoreChangesWidget = Text(
      (challengeStatus == "draw")
        ? "You and your opponent's rating is unchanged"
        : "$plusorminus",
      style: otherStyle,
      textAlign: TextAlign.center,
    );
    Column bottomTextV2 = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Times compared to your opponent's", style: otherStyle, textAlign: TextAlign.center,),
        SizedBox(height: 10.0,),
        Text("$answeredCorrectOpponent", style: scoreStyle, textAlign: TextAlign.center,),
        SizedBox(height: 10.0,),
        scoreChangesWidget,
      ],
    );

    Column bottomTextWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 10.0,
        ),
        Container(
          width: 220,
          child: (vBloc.isChallenged == false) ? bottomTextV1 : bottomTextV2,
        ),
      ],
    );

    int nextTier = currentTier + 1;
    if(nextTier > 7) nextTier = 7;
    print("Current rating: $currentRating");
    print("Score: $score");
    double endRating = (currentRating + score) * 1.0;
    print("endRating: $endRating");
    double per = 200;
    if (nextTier == 3) per = 400;
    if (nextTier == 4) per = 800;
    if (nextTier == 5) per = 1600;
    if (nextTier == 6) per = 3200;
    if (nextTier == 7) per = 6400;
    double progressEnd = (endRating/per);
    if(progressEnd > 1) progressEnd = 1;

    Widget levelUp = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 12.0,
        ),
        Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "tiers/tier$currentTier.png",
                height: 30,
              ),
              SizedBox(
                width: 12.0,
              ),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: progressEnd),
                duration: Duration(milliseconds: 1500),
                builder: (context, value, _) {
                  return Container(
                    width: 180,
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      backgroundColor: Colors.grey[400],
                      value: value,
                    ),
                  );
                }),
              SizedBox(
                width: 12.0,
              ),
              Image.asset(
                "tiers/tier$nextTier.png",
                height: 30,
              )
            ],
          ),
        ),
        SizedBox(
          height: 12.0,
        ),
        Container(
          width: 180,
          child: Align(
            alignment: Alignment.center,
            child: Text("$endRating/$per"),
          ),
        ),
        (endRating >= per) ? Container(
          width: 180,
          child: Align(
            alignment: Alignment.center,
            child: Text("You advance to the next tier: Tier $nextTier!"),
          ),
        ) : SizedBox.shrink(),
      ],
    );

    Row tryAgainButton = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20.0,
        ),
        ElevatedButton(
          child: Text("Try again"),
          onPressed: () {
            Navigator.popAndPushNamed(context, "/play");
          },
        ),
      ]
    );

    if (isGameOver == true) {
      if(canShowGameOverScreen == true){
        return Container(
          height: double.infinity,
          width: double.infinity,
          color: Color.fromRGBO(0, 0, 0, 0.5),
          child: Center(
            child: Container(
                child: Stack(
              clipBehavior: Clip.none,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(32.0),
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "$headerText!",
                            style: headerStyle,
                          ),
                          topTextWidget,
                          scoreWidget,
                          bottomTextWidget,
                          levelUp,
                          SizedBox(
                            height: 30.0,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton(
                                child: Text("Back to main menu"),
                                onPressed: () {
                                  vBloc.isGameModeTimed = false;
                                  vBloc.isGameModeChallenge = false;
                                  vBloc.isChallenged = false;

                                  Navigator.pop(context);
                                },
                              ),
                              (vBloc.isGameModeChallenge == false) ? tryAgainButton : Container(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -46,
                  right: -32,
                  child: Image.asset(
                    "vacto_logo.png",
                    width: 100,
                  ),
                ),
              ],
            )),
          ),
        );
      }
      else{
        return Container();
      }
    }
    else{
      return Container();
    }
  }

  Widget infoPanel(){
    return Container(
      height: MediaQuery.of(context).size.height * 0.08,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 7,
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              scorePanel(),
              correctAnswerPanel(),
            ]
          ),
        )
      ),
    );
  }

  Widget scorePanel() {
    String iconPath = "difficulty/${vBloc.complexity}_white.png";
    if(vBloc.isGameModeChallenge) iconPath = "menu_icon/challenge.png";

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
              child: Image.asset("$iconPath"),
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

  Widget correctAnswerPanel(){
    if(vBloc.isGameModeChallenge == true){
      String text = "Correct Answers:";
      if(vBloc.isChallenged) text = "Your Correct Answers / Opponent's Correct Answers:";

      Text defaultPerText = Text(
        "10",
        style: TextStyle(fontWeight: FontWeight.bold),
      );

      return Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("$text"),
            SizedBox(
              width: 10.0,
            ),
            Text(
              "$answeredCorrect",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 8.0,
            ),
            Text("/"),
            SizedBox(
              width: 8.0,
            ),
            (vBloc.isChallenged == false) 
              ? defaultPerText
              : Text("$answeredCorrectOpponent",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
            SizedBox(
              width: 22.0,
            ),
          ],
        ),
      );
    }
    else{
      return Container();
    }
  }

  Widget topContent(){
    return Expanded(
      child: Container(
        color: Theme.of(context).colorScheme.primaryVariant,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset("play_decor/left-bg.png"),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Image.asset("play_decor/right-bg.png"),
                  ),
                ),
              ],
            ),
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
                      color: Color.fromRGBO(27, 66, 143, 1.0),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: mainNewsContainer(),
                  onDragCompleted: () {
                    if (isDraggedToLeft == true && isDraggedToRight == false) {
                      if(isGameOver == false){
                        validateAnswer(vBloc.CARD_SWIPE_LEFT);
                        vBloc.addCardDirection(vBloc.CARD_SWIPE_LEFT);
                        swipeLeftController.forward();
                      }
                    }
                    else if (isDraggedToLeft == false && isDraggedToRight == true){
                      if(isGameOver == false){
                        validateAnswer(vBloc.CARD_SWIPE_RIGHT);
                        vBloc.addCardDirection(vBloc.CARD_SWIPE_RIGHT);
                        swipeRightController.forward();
                      }
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
          isDraggedToLeft = data;
          isDraggedToRight = false;
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
          isDraggedToLeft = false;
          isDraggedToRight = data;
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
    Column picWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 400,
          child: (news[currentRound - 1].picture != "") 
          ? newsImageSelector()
          : Image.asset(
            "placeholders/wide-pic.png",
            fit: BoxFit.fitWidth,
          ),
        ),
        SizedBox(
          height: 18.0,
        ),
      ],
    );
    Column descWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          child: Text(
            "${news[currentRound - 1].content}...",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(
          height: 18.0,
        ),
      ],
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      clipBehavior: Clip.hardEdge,
      elevation: 8,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: (news[currentRound - 1].type != "uc") ? 25.0 : 34.0, right: 25.0, bottom: 25.0, left: 25.0),
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
                  (news[currentRound - 1].subtype != "url") ? picWidget : Container(),
                  (news[currentRound - 1].subtype == "nor") ? descWidget : Container(),
                  (news[currentRound - 1].subtype != "pho") ? Text(news[currentRound - 1].source) : Container(),
                  SizedBox(
                    height: 36.0,
                  ),
                ],
              ),
            ),
          ),
          (news[currentRound - 1].type == "uc") ? Positioned(
            top: 0,
            right: 0,
            child: Tooltip(
              padding: EdgeInsets.all(12.0),
              message: "Bonus' answer counts as correct no matter which answer you pick",
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 24.0
                ),
                decoration: BoxDecoration(
                  color: Colors.amber[800],
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0))
                ),
                child: Text(
                  "Bonus Round",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
          : Container(),
        ],
      ),
    );
  }

  Widget newsImageSelector(){
    if(news[currentRound - 1].picture.startsWith("https")){
      // TODO: Loading builder ga bekerja
      return Image.network(news[currentRound - 1].picture,
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          else{
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes
                    : null,
              ),
            );
          }
        }
      );
    }
    else{
      return Image.network("http://localhost:3000/images/news/${news[currentRound - 1].picture}");
    }
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
            timerPanel(),
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
            width: 30.0,
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app_rounded),
            iconSize: 24,
            onPressed: () async {
              bool confirmExit = await showExitDialog();
              if (confirmExit == true) {
                setState(() { isGameOver = true; });
                
                if (vBloc.isGameModeTimed == true) timer.cancel();

                if (vBloc.isGameModeChallenge == true && vBloc.isChallenged == true) isChallengeWithdrawn = true;

                await gameOverProccess();
              }
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
            splashColor: Colors.red[200],
            color: Colors.red,
            onPressed: () {
              if (isGameOver == false) {
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
              if (isGameOver == false) {
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

  Widget timerPanel(){
    double  wi = 50.0, he = 50.0;

    if (vBloc.isGameModeTimed == true) {
      return Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: wi,
              width: he,
              child: CircularProgressIndicator.adaptive(
                value: timerValue,
                backgroundColor: Colors.grey,
                valueColor: timerColor,
                strokeWidth: 3.0,
              ),
            ),
            SizedBox(
              width: 30.0,
            ),
          ],
        ),
      );
    }
    else{
      return Container();
    }
  }
}