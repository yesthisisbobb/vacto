import 'package:http/http.dart' as http;
import 'dart:convert';

class News{
  int id;
  String author;
  String title;
  DateTime date;
  String picture;
  String content;
  String source;
  String type;
  String subtype;
  String answer;
  List<String> tags;

  News();

  fillOutDataFromID(int id) async{
    this.id = id;

    var res = await http.get(Uri.parse("http://localhost:3000/api/news/get/$id"));
    if(res.statusCode == 200){
      var jsonData = res.body.toString();
      var parsedData = json.decode(jsonData);

      this.id = parsedData["id"];
      // print("id: $id");
      this.author = parsedData["author"];
      // print("author: $author");
      this.title = parsedData["title"];
      // print("title: $title");
      this.date = DateTime.parse(parsedData["date"]);
      // print("date: $date");
      this.picture = parsedData["picture"];
      // print("picture: $picture");
      this.content = parsedData["content"];
      // print("content: $content");
      this.source = parsedData["source"];
      // print("source: $source");
      this.type = parsedData["type"];
      // print("type: $type");
      this.subtype = parsedData["subtype"];
      // print("subtype: $subtype");
      this.answer = parsedData["answer"];
      // print("answer: $answer");
      String temp = parsedData["tags"];
      tags = temp.split(",");
      // print("tags: $tags");

      return "News with id: $id succesfully created";
    }
    else{
      return "News init failed";
    }
  }

  @override
  toString(){
    return "id: $id, author: $author, title: $title";
  }
}