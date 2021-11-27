import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vacto/src/blocs/variables_bloc.dart';
import 'package:vacto/src/blocs/variables_provider.dart';
import 'dart:convert';

import 'package:vacto/src/classes/Answer.dart';
import 'package:vacto/src/classes/Challenge.dart';
import 'package:vacto/src/classes/News.dart';
import 'package:vacto/src/classes/User.dart';

class AnswersDataSources extends DataTableSource{
  String uid;
  List<Answer> answers = [];

  getDatas(String uid) async {
    this.uid = uid;

    print("http://localhost:3000/api/answer/get/formatted/all/$uid");
    var res = await http.get(Uri.parse("http://localhost:3000/api/answer/get/formatted/all/$uid"));
    if(res.statusCode == 200){
      var jsonData = res.body.toString();
      var parsedJson = json.decode(jsonData);

      for (var item in parsedJson) {
        Answer temp = new Answer();
        await temp.filloutDataFromID(item["Answer id"]);

        answers.add(temp);
      }

      return true;
    }
    return false;
  }

  @override
  DataRow getRow(int index) {
    if(answers.isNotEmpty){
      String dateText = "${answers[index].dateAnswered.day}-${answers[index].dateAnswered.month}-${answers[index].dateAnswered.year} ${answers[index].dateAnswered.hour}:${answers[index].dateAnswered.minute}:${answers[index].dateAnswered.second}";
      String scoreText = "+";
      if(answers[index].answer != answers[index].actualAnswer) scoreText = "-";
      scoreText += answers[index].score.toString();

      return DataRow(
        cells: [
          DataCell(Text(dateText)),
          DataCell(Text(answers[index].news)),
          DataCell(Text(answers[index].answer)),
          DataCell(Text(answers[index].actualAnswer)),
          DataCell(Text(scoreText)),
          DataCell(Text(answers[index].reasoning)),
        ]
      );
    }
    else{
      return DataRow(cells: [
        DataCell(Text("")),
        DataCell(Text("")),
        DataCell(Text("")),
        DataCell(Text("")),
        DataCell(Text("")),
        DataCell(Text("")),
      ]);
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => answers.length;

  @override
  int get selectedRowCount => 0;
}

class ChallengeDataSources extends DataTableSource {
  String uid;
  List<Challenge> challenges = [];

  getDatas(String uid) async {
    this.uid = uid;

    var res = await http.get(Uri.parse("http://localhost:3000/api/challenge/get/by/$uid"));
    if (res.statusCode == 200) {
      var jsonData = res.body.toString();
      var parsedJson = json.decode(jsonData);

      for (var item in parsedJson) {
        Challenge temp = new Challenge();
        await temp.filloutDataFromID(item["id"]);

        User userTemp = User();
        await userTemp.fillOutDataFromID(item["user2"]);
        temp.challenged = userTemp.username;

        challenges.add(temp);
      }

      return true;
    }
    return false;
  }

  @override
  DataRow getRow(int index) {
    if (challenges.isNotEmpty) {
      String dateText = "${challenges[index].date.day}-${challenges[index].date.month}-${challenges[index].date.year} ${challenges[index].date.hour}:${challenges[index].date.minute}:${challenges[index].date.second}";
      String winLossText = "Haven't responded";
      TextStyle winLossTStyle = TextStyle(
        color: Colors.black
      );
      if(challenges[index].user1Ca < challenges[index].user2Ca && challenges[index].user2Completed == "y"){ 
        winLossText += ((challenges[index].user1Ca - challenges[index].user2Ca).abs() * 3).toString();
        TextStyle(color: Colors.red[800]);
      }
      if(challenges[index].user1Ca > challenges[index].user2Ca && challenges[index].user2Completed == "y") {
        winLossText = "+${((challenges[index].user1Ca - challenges[index].user2Ca).abs() * 3).toString()}";
        TextStyle(color: Colors.green[800]);
      }
      if(challenges[index].user1Ca == challenges[index].user2Ca && challenges[index].user2Completed == "y") {
        winLossText = "0";
      }

      return DataRow(cells: [
        DataCell(Text(dateText)),
        DataCell(Text(challenges[index].challenged)),
        DataCell(Text(challenges[index].user1Ca.toString())),
        DataCell(Text(challenges[index].user2Ca.toString())),
        DataCell(Text(winLossText, style: winLossTStyle,)),
      ]);
    } else {
      return DataRow(cells: [
        DataCell(Text("")),
        DataCell(Text("")),
        DataCell(Text("")),
        DataCell(Text("")),
        DataCell(Text("")),
      ]);
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => challenges.length;

  @override
  int get selectedRowCount => 0;
}

class NewsDataSources extends DataTableSource {
  BuildContext context;
  VariablesBloc vBloc;
  String uid;
  List<News> news = [];

  NewsDataSources(BuildContext context, VariablesBloc vBloc){
    this.context = context;
    this.vBloc = vBloc;
  }

  getDatas(String uid) async {
    this.uid = uid;

    var res = await http.get(Uri.parse("http://localhost:3000/api/news/get/all/by/$uid"));
    if (res.statusCode == 200) {
      var jsonData = res.body.toString();
      var parsedJson = json.decode(jsonData);

      for (var item in parsedJson) {
        News temp = new News();
        await temp.fillOutDataFromID(item["id"]);

        news.add(temp);
      }

      return true;
    }
    return false;
  }

  @override
  DataRow getRow(int index) {
    if (news.isNotEmpty) {
      String dateText = "${news[index].date.day}-${news[index].date.month}-${news[index].date.year}";

      return DataRow(cells: [
        DataCell(Text(dateText)),
        DataCell(Text(news[index].id.toString())),
        DataCell(Text(news[index].title)),
        DataCell(OutlinedButton(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("View Answers"),
              SizedBox(width: 12.0,),
              Icon(Icons.remove_red_eye_rounded)
            ],
          ),
          onPressed: (){
            vBloc.userNewsViewedId = news[index].id;
            vBloc.userNewsViewedTitle = news[index].title;
            vBloc.userNewsViewedAnswer = news[index].answer;
            Navigator.pushNamed(context, "/profile/detail/news");
          },
        )),
      ]);
    } else {
      return DataRow(cells: [
        DataCell(Text("")),
        DataCell(Text("")),
        DataCell(Text("")),
        DataCell(Text("")),
      ]);
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => news.length;

  @override
  int get selectedRowCount => 0;
}

class ProfileDatasView extends StatefulWidget {
  ProfileDatasView({Key key}) : super(key: key);

  @override
  _ProfileDatasViewState createState() => _ProfileDatasViewState();
}

class _ProfileDatasViewState extends State<ProfileDatasView> {
  VariablesBloc vBloc;

  static const DATA_SOURCE_ANSWERS = "answer";
  static const DATA_SOURCE_CHALLENGE = "challenge";
  static const DATA_SOURCE_NEWS = "news";

  AnswersDataSources ads;
  ChallengeDataSources cds;
  NewsDataSources nds;

  String headerText = "";
  String detailText = "";

  Future<bool> futurePicker(String uid, String type) async {
    print("UID profile datas $uid");
    print("type profile datas $type");
    if (type == DATA_SOURCE_ANSWERS){
      bool result = await ads.getDatas(uid);
      print("result: $result");
      return result;
    }
    else if (type == DATA_SOURCE_CHALLENGE){
      print("here?");
      return await cds.getDatas(uid);
    }
    else if (type == DATA_SOURCE_NEWS) {
      return await nds.getDatas(uid);
    }
    else{
      return false;
    }
  }

  dataSourcePicker(String type){
    if (type == DATA_SOURCE_ANSWERS){
      return ads;
    }
    else if (type == DATA_SOURCE_CHALLENGE){
      return cds;
    }
    else if (type == DATA_SOURCE_NEWS) {
      return nds;
    }
  }

  @override
  Widget build(BuildContext context) {
    vBloc = VariablesProvider.of(context);

    if (vBloc.chosenProfileDataSource == DATA_SOURCE_ANSWERS) {
      ads = AnswersDataSources();
      headerText = "Your answer history";
      detailText = "Here you can find all your answers to a news";
    }
    else if(vBloc.chosenProfileDataSource == DATA_SOURCE_CHALLENGE){
      cds = ChallengeDataSources();
      headerText = "Your challenge history";
      detailText = "Here you can find all your challenge submissions";
    }
    else if (vBloc.chosenProfileDataSource == DATA_SOURCE_NEWS) {
      nds = NewsDataSources(context, vBloc);
      headerText = "Your added news history";
      detailText = "Here you can find all your news submissions";
    }

    return Scaffold(
      body: FutureBuilder(
        future: futurePicker(vBloc.currentUser.id, vBloc.chosenProfileDataSource),
        builder: (context, snapshot){
          if(snapshot.hasData){
            if(snapshot.data == true){
              return mainContainer();
            }
            else{
              return Text("No data :(");
            }
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }

  Widget mainContainer(){
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      padding: EdgeInsets.fromLTRB(30.0, 30.0, 40.0, 0.0),
      child: SingleChildScrollView(
        child: FractionallySizedBox(
          widthFactor: 0.9,
          child: Column(
            children: [
              backButton(context),
              SizedBox(height: 24,),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(headerText,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                  ),
                ),
              ),
              SizedBox(height: 8.0,),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  detailText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
              ),
              SizedBox(height: 12.0,),
              dataTable(),
              SizedBox(height: 60,),
            ],
          ),
        )
      ),
    );
  }

  Widget dataTable() {
    if (vBloc.chosenProfileDataSource == DATA_SOURCE_ANSWERS){
      return PaginatedDataTable(
        source: dataSourcePicker(DATA_SOURCE_ANSWERS),
        columns: [
          DataColumn(
            label: Text("Date"),
          ),
          DataColumn(
            label: Text("News Title"),
          ),
          DataColumn(
            label: Text("Your Answer"),
          ),
          DataColumn(
            label: Text("Actual Answer"),
          ),
          DataColumn(
            label: Text("Score"),
          ),
          DataColumn(
            label: Text("Reasoning"),
          ),
        ],
      );
    }
    else if (vBloc.chosenProfileDataSource == DATA_SOURCE_CHALLENGE){
      return PaginatedDataTable(
        source: dataSourcePicker(DATA_SOURCE_CHALLENGE),
        columns: [
          DataColumn(
            label: Text("Date"),
          ),
          DataColumn(
            label: Text("Opponent"),
          ),
          DataColumn(
            label: Text("Your Correct Answer"),
          ),
          DataColumn(
            label: Text("Opponent Correct Answer"),
          ),
          DataColumn(
            label: Text("Rating Change"),
          ),
        ],
      );
    }
    else if (vBloc.chosenProfileDataSource == DATA_SOURCE_NEWS) {
      return PaginatedDataTable(
        source: dataSourcePicker(DATA_SOURCE_NEWS),
        columns: [
          DataColumn(
            label: Text("Date"),
          ),
          DataColumn(
            label: Text("News ID"),
          ),
          DataColumn(
            label: Text("News Title"),
          ),
          DataColumn(
            label: Text("Answers"),
          ),
        ],
      );
    }
  }

  Widget backButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: Icon(Icons.arrow_back_rounded),
        iconSize: 40,
        color: Colors.white,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}