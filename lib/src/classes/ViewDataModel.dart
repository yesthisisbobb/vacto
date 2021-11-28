import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewDataModel{
  int aid;
  DateTime ad;
  String nt;
  String ua;
  String aa;
  int rs;
  String name;
  String nat;
  DateTime dob;
  String gender;

  ViewDataModel();

  fillOutDataFromID(int aid) async {
    this.aid = aid;

    var res = await http.get(Uri.parse("http://localhost:3000/api/answer/get/formatted/$aid"));
    if(res.statusCode == 200){
      var jsonData = res.body.toString();
      var parsedJson = json.decode(jsonData);

      this.ad = DateTime.parse(parsedJson["Answer Date"]);
      this.nt = parsedJson["News Title"];
      this.ua = parsedJson["User Answer"];
      this.aa = parsedJson["Actual Answer"];
      this.rs = parsedJson["Resulting Score"];
      this.name = parsedJson["Name"];
      this.nat = parsedJson["Nationality"];
      this.dob = DateTime.parse(parsedJson["Date of Birth"]);
      if(parsedJson["Gender"] == "f"){
        this.gender = "female";
      }
      else if (parsedJson["Gender"] == "m"){
        this.gender = "male";
      }
      else{
        this.gender = "not-specified";
      }

      return "ViewDataModel creation successful";
    }
    
    return "ViewDataModel creation failed";
  }
}