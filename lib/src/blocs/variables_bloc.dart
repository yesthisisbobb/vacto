import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import '../classes/User.dart';

class VariablesBloc{
  LocalStorage localS = new LocalStorage("user");
  User currentUser;

  final CARD_SWIPE_RIGHT = "right";
  final CARD_SWIPE_LEFT = "left";
  
  bool isGameModeTimed = false;
  String swipeDirection = "";
}