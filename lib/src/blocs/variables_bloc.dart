import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:rxdart/rxdart.dart';
import '../classes/User.dart';
import 'package:http/http.dart' as http;

class VariablesBloc{
  LocalStorage localS = new LocalStorage("user");
  User currentUser;

  final String DATA_SOURCE_ANSWERS = "answer";
  final String DATA_SOURCE_CHALLENGE = "challenge";
  final String DATA_SOURCE_NEWS = "news";
  String chosenProfileDataSource = "challenge";

  int userNewsViewedId = 0;
  String userNewsViewedTitle = "";
  String userNewsViewedAnswer = "";

  final CARD_SWIPE_RIGHT = "right";
  final CARD_SWIPE_LEFT = "left";
  
  bool isGameModeTimed = false;

  bool isGameModeChallenge = false;
  bool isChallenged = false;
  String opponentId = "";
  int challengeId = 0;

  // bool isGameModeChallenge = true;
  // bool isChallenged = true;
  // String opponentId = "1103003";
  // int challengeId = 1;

  String complexity = "";
  String swipeDirection = "";

  // STREAMS ZONE
  final feedTypeController = BehaviorSubject<String>();
  feedTypeChange(String type) => feedTypeController.sink.add(type);
  Stream<String> get feedTypeStream => feedTypeController.stream;

  final cardDirectionController = BehaviorSubject<String>();
  addCardDirection(String dir) => cardDirectionController.sink.add(dir);
  Stream<String> get cardDirectionStream => cardDirectionController.stream;

  final profileAchievementsController = BehaviorSubject<String>();
  changeProfileAchievement(uaid, state) {
    changeAchievementPicked(uaid, state);
    profileAchievementsController.sink.add(uaid);
  }
  Stream<String> get profileAchievementsStream => profileAchievementsController.stream;

  final userUpdateErrorController = BehaviorSubject<String>();
  addUserUpdateError(String msg) => userUpdateErrorController.sink.add(msg);
  Stream<String> get userUpdateErrorStream => userUpdateErrorController.stream;

  dispose(){
    feedTypeController.close();
    cardDirectionController.close();
    profileAchievementsController.close();
    userUpdateErrorController.close();
  }

  Future<bool> changeAchievementPicked(uaid, state) async {
    String sentState = "n";
    if(state == true) sentState = "y";
    var res = await http.post(Uri.parse("http://localhost:3000/api/user/achievement/update/"),
      body: {
        "uaid": uaid.toString(),
        "state": sentState
      }
    );
    if (res.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> changeState(nid, validity) async {
    String valid = "n";
    if (validity == true) valid = "y";

    var res = await http.post(
        Uri.parse("http://localhost:3000/api/news/update/validity/$nid"),
        body: {"validity": valid});
    if (res.statusCode == 200) {
      return true;
    }
    return false;
  }
}