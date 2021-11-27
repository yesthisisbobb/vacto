import 'package:http/http.dart' as http;
import 'dart:convert';

class Answer {
  int id;
  String user;
  String news;
  DateTime dateAnswered;
  String answer;
  int score;
  String reasoning;

  String username;
  String actualAnswer;

  Answer();

  filloutDataFromID(int id) async {
    print("Masuk kelas answer-------------------");
    print("ID: $id");
    this.id = id;

    print("http://localhost:3000/api/answer/get/formatted/$id");
    var res = await http.get(Uri.parse("http://localhost:3000/api/answer/get/formatted/$id"));
    if (res.statusCode == 200) {
      var jsonData = res.body.toString();
      var parsedData = json.decode(jsonData);

      print(parsedData);

      this.id = parsedData["id"];
      this.user = parsedData["Name"];
      this.news = parsedData["News Title"];
      this.dateAnswered = DateTime.parse(parsedData["Answer Date"]);
      this.answer = parsedData["User Answer"];
      this.score = parsedData["Resulting Score"];
      this.reasoning = parsedData["Reasoning"];

      this.actualAnswer = parsedData["Actual Answer"];

      print("KELUAR BERSIH ---------------");
      return "Answer with id $id successfully created";
    }

    print("KELUAR ERROR ---------------");
    return "Answer creation failed";
  }
}
