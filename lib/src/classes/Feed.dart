import 'package:http/http.dart' as http;
import 'dart:convert';

class Feed {
  // Content type: achievement, win/loss challenge

  int id;
  DateTime date;
  String content;
  String user1;
  String user2;
  String username; // username user1

  Feed(id, date, content, user1, user2, username){
    this.id = id;
    print("DATE BEFORE FORMATTING !!!!!!!!!!!!!!!!!!!!!!!!!!");
    print(date);
    this.date = DateTime.parse(date);
    print("DATE AFTER FORMATTING !!!!!!!!!!!!!!!!!!!!!!!!!!");
    print(this.date);
    this.content = "$content";
    this.user1 = "$user1";
    this.user2 = "$user2";
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
      text += "$username has just earned achievement 'something'";
    }
    else if(content == "challenge_w"){
      text += "$username has just won a challenge!";
    }
    else if(content == "challenge_l"){
      text += "$username has just lost a challenge!";
    }

    return text;
  }
}