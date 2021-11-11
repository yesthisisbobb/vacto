import 'package:http/http.dart' as http;
import 'dart:convert';

class Challenge{
  int id;
  DateTime date;
  String questions;
  String user1;
  String challenger;
  String user2;
  String user1Completed;
  String user2Completed;
  int user1Ca;
  int user2Ca;

  Challenge();

  filloutDataFromID(int id) async {
    print("Masuk kelas challenge-------------------");
    this.id = id;

    print("http://localhost:3000/api/challenge/get/$id");
    var res = await http.get(Uri.parse("http://localhost:3000/api/challenge/get/$id"));
    if(res.statusCode == 200){
      var jsonData = res.body.toString();
      var parsedData = json.decode(jsonData);

      print(parsedData);

      this.date = DateTime.parse(parsedData["date"]);
      print(parsedData["date"]);
      this.questions = parsedData["questions"];
      print(parsedData["questions"]);
      this.user1 = parsedData["user1"];
      print(parsedData["user1"]);
      this.challenger = parsedData["challenger"];
      print(parsedData["challenger"]);
      this.user2 = parsedData["user2"];
      print(parsedData["user2"]);
      this.user1Completed = parsedData["user1_completed"];
      print(parsedData["user1_completed"]);
      this.user2Completed = parsedData["user2_completed"];
      print(parsedData["user2_completed"]);
      this.user1Ca = parsedData["user1_ca"];
      print(parsedData["user1_ca"]);
      this.user2Ca = parsedData["user2_ca"];
      print(parsedData["user2_ca"]);

      print("KELUAR BERSIH ---------------");
      return "Challenge with id $id successfully created";
    }

    print("KELUAR ERROR ---------------");
    return "Challenge creation failed";
  }
}