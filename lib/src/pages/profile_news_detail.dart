import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vacto/src/blocs/variables_bloc.dart';
import 'package:vacto/src/blocs/variables_provider.dart';
import 'package:vacto/src/classes/Answer.dart';

class AnswersDataSources extends DataTableSource {
  int nid;
  List<Answer> answers = [];

  getDatas(int nid) async {
    this.nid = nid;

    print("http://localhost:3000/api/answer/get/formatted/all/news/$nid");
    var res = await http.get(Uri.parse("http://localhost:3000/api/answer/get/formatted/all/news/$nid"));
    if (res.statusCode == 200) {
      var jsonData = res.body.toString();
      var parsedJson = json.decode(jsonData);

      for (var item in parsedJson) {
        Answer temp = new Answer();
        await temp.filloutDataFromID(item["Answer id"]);
        temp.username = item["Username"];

        answers.add(temp);
      }

      return true;
    }
    return false;
  }

  @override
  DataRow getRow(int index) {
    if (answers.isNotEmpty) {
      String dateText =
          "${answers[index].dateAnswered.day}-${answers[index].dateAnswered.month}-${answers[index].dateAnswered.year} ${answers[index].dateAnswered.hour}:${answers[index].dateAnswered.minute}:${answers[index].dateAnswered.second}";
      String scoreText = "+";
      if (answers[index].answer != answers[index].actualAnswer) scoreText = "-";
      scoreText += answers[index].score.toString();

      return DataRow(cells: [
        DataCell(Text(dateText)),
        DataCell(Text(answers[index].username)),
        DataCell(Text(scoreText)),
        DataCell(Text(answers[index].answer)),
        DataCell(Text(answers[index].reasoning)),
      ]);
    } else {
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

class ProfileNewsDetail extends StatefulWidget {
  ProfileNewsDetail({Key key}) : super(key: key);

  @override
  _ProfileNewsDetailState createState() => _ProfileNewsDetailState();
}

class _ProfileNewsDetailState extends State<ProfileNewsDetail> {
  VariablesBloc vBloc;
  AnswersDataSources ads;

  @override
  Widget build(BuildContext context) {
    vBloc = VariablesProvider.of(context);
    ads = AnswersDataSources();

    return Scaffold(
      body: FutureBuilder(
        future: ads.getDatas(vBloc.userNewsViewedId),
        builder: (context, snapshot){
          if(snapshot.hasData){
            if (snapshot.data == true){
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
      padding: EdgeInsets.fromLTRB(30.0, 30.0, 40.0, 0.0),
      color: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
        child: FractionallySizedBox(
          widthFactor: 0.9,
          child: Column(
            children: [
              backButton(context),
              SizedBox(height: 24,),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "News Title: ${vBloc.userNewsViewedTitle}",
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
                  "You set the answer to be: ${vBloc.userNewsViewedAnswer}",
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

  Widget dataTable(){
    return PaginatedDataTable(
      source: ads,
      columns: [
        DataColumn(
          label: Text("Date Answered"),
        ),
        DataColumn(
          label: Text("Username"),
        ),
        DataColumn(
          label: Text("Score"),
        ),
        DataColumn(
          label: Text("User Answer"),
        ),
        DataColumn(
          label: Text("Reasoning"),
        ),
      ],
    );
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