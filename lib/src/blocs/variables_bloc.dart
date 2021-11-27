import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:rxdart/rxdart.dart';
import '../classes/User.dart';

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

  dispose(){
    feedTypeController.close();
    cardDirectionController.close();
  }
}