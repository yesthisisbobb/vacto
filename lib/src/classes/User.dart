import 'package:http/http.dart' as http;
import 'dart:convert';

class User{
  String id;
  String username;
  String password;
  String email;
  String name;
  String nationality;
  DateTime dob;
  String gender;
  String pp; // TODO: may need to change this
  int level;
  String role;

  User();

  User.fromId(id){
    this.id = id;
    // print("Id initialized: $id");
    Future<String> fillData = fillOutDataFromID(id);
    // print("fill data finished");
    fillData.then((value) => print(value)).whenComplete(() => print("fillData complete"));
  }

  User.fromCompleteData({id, username, password, email, name, nationality, dob, gender, pp, level, role}){
    this.id = id;
    this.username = username;
    this.password = password;
    this.email = email;
    this.name = name;
    this.nationality = nationality;
    this.dob = dob;
    this.gender = gender;
    this.pp = pp;
    this.level = level;
    this.role = role;
  }

  Future<String> fillOutDataFromID(id) async {
    this.id = id;

    var res = await http.get(Uri.parse("http://localhost:3000/api/user/get/$id"));
    print("query done with url: http://localhost:3000/api/user/get/$id");
    print(res.body.toString());
    if(res.statusCode == 200){
      // print("200 received: ${res.body.toString()}");

      var receivedData = res.body.toString();
      var parsedData = json.decode(receivedData);

      this.username = parsedData["username"];
      // print("username: ${parsedData['username']}");
      this.password = parsedData["password"];
      // print("password: ${parsedData['password']}");
      this.email = parsedData["email"];
      // print("email: ${parsedData['email']}");
      this.name = parsedData["name"];
      // print("name: ${parsedData['name']}");
      this.nationality = parsedData["nationality"];
      // print("nationality: ${parsedData['nationality']}");
      this.dob = DateTime.parse(parsedData["dob"]);
      // print("dob: ${parsedData['dob']}");
      this.gender = parsedData["gender"];
      // print("gender: ${parsedData['gender']}");
      this.pp = parsedData["pp"];
      // print("pp: ${parsedData['pp']}");
      this.level = parsedData["level"];
      // print("level: ${parsedData['level']}");
      this.role = parsedData["role"];
      // print("role: ${parsedData['role']}");

      return "User created";
    }
    else if(res.statusCode == 400){
      print("400 received: ${res.body.toString()}");
      return res.body.toString();
    }
    else{
      print("None of the above fucking fired");
      return null;
    }
  }

  @override
  String toString() {
    return "ID: $id, Username: $username, Level: $level";
  }
}