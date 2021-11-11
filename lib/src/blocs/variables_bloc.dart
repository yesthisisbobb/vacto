import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:rxdart/rxdart.dart';
import '../classes/User.dart';

class VariablesBloc{
  LocalStorage localS = new LocalStorage("user");
  User currentUser;

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
  final cardDirectionController = BehaviorSubject<String>();
  addCardDirection(String dir) => cardDirectionController.sink.add(dir);
  Stream<String> get cardDirectionStream => cardDirectionController.stream;

  dispose(){
    cardDirectionController.close();
  }
}