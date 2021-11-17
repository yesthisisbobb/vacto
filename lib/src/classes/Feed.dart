import 'package:http/http.dart' as http;
import 'dart:convert';

class Feed {
  // Content type: achievement, win/loss challenge

  int id;
  DateTime date;
  String content;
  String user;
  String opponent;
  String achievement;
  String username;

  Feed(id, date, content, user, opponent, achievement, username){
    this.id = id;
    this.date = DateTime.parse(date);
    this.content = "$content";
    this.user = "$user";
    this.opponent = "$opponent";
    this.achievement = "$achievement";
    this.username = "$username";
  }

  @override
  toString(){
    String hour = "${date.hour + 7}";
    if(date.hour + 7 < 10) hour = "0${date.hour + 7}";
    if(date.hour + 7 > 23) hour = "0${date.hour + 7 - 24}";
    String minute = "${date.minute}";
    if(date.minute < 10) minute = "0${date.minute}";
    String second = "${date.second}";
    if(date.second < 10) second = "0${date.second}";
    String text = "$hour:$minute:$second ";

    if(content == "achievement"){
      text += "$username has just earned achievement '$achievement'";
    }
    else if(content == "challenge_w"){
      text += "$username has just won a challenge against $opponent!";
    }
    else if(content == "challenge_l"){
      text += "$username has just lost a challenge $opponent";
    }

    return text;
  }
}