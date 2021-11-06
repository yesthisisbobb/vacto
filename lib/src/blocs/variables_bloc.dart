import 'package:flutter/material.dart';
import '../classes/User.dart';

class VariablesBloc{
  User currentUser;

  final CARD_SWIPE_RIGHT = "right";
  final CARD_SWIPE_LEFT = "left";
  
  bool isGameModeTimed = false;
  String swipeDirection = "";
}