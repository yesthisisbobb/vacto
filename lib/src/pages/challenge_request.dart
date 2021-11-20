import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../blocs/variables_provider.dart';
import '../classes/User.dart';
import '../classes/Challenge.dart';

class Requests extends DataTableSource{
  BuildContext context;
  VariablesBloc vBloc;
  List<Challenge> challengeList;

  Requests(BuildContext context, VariablesBloc vBloc){
    this.context = context;
    this.vBloc = vBloc;
    challengeList = [];
  }

  Future<bool> getChallenges() async {
    var res = await http.get(Uri.parse("http://localhost:3000/api/challenge/get/for/${vBloc.currentUser.id}"));
    if(res.statusCode == 200){
      var jsonData = res.body.toString();
      var parsedData = json.decode(jsonData);

      for (var item in parsedData) {
        Challenge temp = new Challenge();
        await temp.filloutDataFromID(item["id"]);

        challengeList.add(temp);
      }

      print(challengeList.toString());

      return true;
    }
    return false;
  }

  storeAndNavigate(challengeId, opponentId){
    vBloc.isGameModeChallenge = true;
    vBloc.isChallenged = true;
    vBloc.opponentId = opponentId;
    vBloc.challengeId = challengeId;
    Navigator.popAndPushNamed(context, "/play");
  }

  @override
  DataRow getRow(int index) {
    if (challengeList.length > 0) {
      bool canPlay = false;
      int scoreDiff = (challengeList[index].user1Ca - challengeList[index].user2Ca).abs() * 3;
      String plusorminus = "";
      Color statusColor = Colors.black;

      if(challengeList[index].user1Ca > challengeList[index].user2Ca){
        plusorminus = "-";
        statusColor = Colors.red[700];
      }
      else if(challengeList[index].user1Ca < challengeList[index].user2Ca){
        plusorminus = "+";
        statusColor = Colors.green[700];
      }

      if(challengeList[index].user1Completed == "y" && challengeList[index].user2Completed == "n"){
        canPlay = true;
      }

      Text status = Text(
        "$plusorminus${scoreDiff.toString()}",
        style: TextStyle(
          fontSize: 16.0,
          color: statusColor,
        ),
      );

      ElevatedButton buttonPlay = ElevatedButton(
        child: Text(
          "Battle",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          primary: Colors.green[800]
        ),
        onPressed: () {
          storeAndNavigate(challengeList[index].id, challengeList[index].user1);
        }
      );

      String hourText = (challengeList[index].date.hour + 7 < 10) ? "0${challengeList[index].date.hour + 7}" : "${challengeList[index].date.hour + 7}";
      if (challengeList[index].date.hour + 7 < 23) hourText = "${challengeList[index].date.hour + 7 - 24}";
      String minuteText = (challengeList[index].date.minute < 10) ? "0${challengeList[index].date.minute}" : "${challengeList[index].date.minute}";
      String dateText = "${challengeList[index].date.day}/${challengeList[index].date.month}/${challengeList[index].date.year} at $hourText:$minuteText" ;
      return DataRow(cells: [
        DataCell(
          Align(
            alignment: Alignment.center,
            child: Text(dateText),
          ),
        ),
        DataCell(
          Align(
            alignment: Alignment.center,
            child: Text(challengeList[index].challenger
            ),
          ),
        ),
        DataCell(
          Align(
            alignment: Alignment.center,
            child: (canPlay == true) ? buttonPlay : status,
          )
        )
      ]);
    } else {
      return DataRow(cells: [
        DataCell(Text("01-01-1970")),
        DataCell(Text("John Doe")),
        DataCell(Text("0")),
      ]);
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => challengeList.length;

  @override
  int get selectedRowCount => 0;
  
}

class ChallengeRequest extends StatefulWidget {
  ChallengeRequest({Key key}) : super(key: key);

  @override
  _ChallengeRequestState createState() => _ChallengeRequestState();
}

class _ChallengeRequestState extends State<ChallengeRequest> {
  VariablesBloc vBloc;
  Requests cRequests;

  @override
  Widget build(BuildContext context) {
    vBloc = VariablesProvider.of(context);
    cRequests = Requests(context, vBloc);

    return Scaffold(
      body: baseContainer(),
    );
  }

  Widget baseContainer(){
    return FutureBuilder(
      future: cRequests.getChallenges(),
      builder: (context, snapshot){
        print(snapshot);
        if(snapshot.hasData && snapshot.data == true){
          return mainContainer();
        }
        else if(snapshot.hasData && snapshot.data == false){
          return Container(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Looks like nobody has challenged you yet :)"),
                ],
              ),
            ),
          );
        }
        else{
          return Container(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 16.0,
                  ),
                  Text("Fetching challenge requests..."),
                ],
              ),
            ),
          );
        }
      }
    );
  }

  Widget mainContainer(){
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 40.0,
                ),
                backButton(context),
                SizedBox(
                  height: 24.0,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Challenge requests",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Here you can find all requests from other users that challenges you",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(
                  height: 24.0,
                ),
                Container(
                  width: double.infinity,
                  child: dataTable(),
                ),
                SizedBox(
                  height: 70.0,
                ),
              ],
            ),
          ),
        )
      )
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

  Widget dataTable(){
    return PaginatedDataTable(
      source: cRequests,
      showFirstLastButtons: false,
      columns: [
        DataColumn(
          label: Expanded(
            child:Align(
              alignment: Alignment.center,
              child: Text("Date"),
            )
          ),
        ),
        DataColumn(
          label: Expanded(
            child:Align(
              alignment: Alignment.center,
              child: Text("Challenger"),
            )
          ),
        ),
        DataColumn(
          label: Expanded(
            child:Align(
              alignment: Alignment.center,
              child: Text("Status"),
            )
          ),
        ),
      ],
    );
  }
}