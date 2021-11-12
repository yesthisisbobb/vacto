import 'package:flutter/material.dart';
import 'package:vacto/src/blocs/variables_bloc.dart';
import 'package:vacto/src/blocs/variables_provider.dart';
import '../classes/User.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LeaderboardDataTableSource extends DataTableSource{
  BuildContext context;
  VariablesBloc vBloc;
  List<User> users;

  LeaderboardDataTableSource(BuildContext context, VariablesBloc vBloc){
    this.context = context;
    this.vBloc = vBloc;
    this.users = [];
  }

  getDatas() async {
    var res = await http.get(Uri.parse("http://localhost:3000/api/users/get/sorted/100"));
    if(res.statusCode == 200){
      var jsonData = res.body.toString();
      var parsedJson = json.decode(jsonData);

      for (var item in parsedJson) {
        User temp = new User();
        await temp.fillOutDataFromID(item["id"]);

        users.add(temp);
      }

      return true;
    }
    return false;
  }

  @override
  DataRow getRow(int index) {
    if (users.length > 0) {
      double cap = (users[index].ca / users[index].tqf) * 100;
      String capText = "${cap.toStringAsFixed(2)}%";
      if(cap.isNaN) capText = "-";

      return DataRow(
        cells: [
          DataCell(
            Image.asset(
              "country-flags/${users[index].nationality}.png",
              height: 20,
            )
          ),
          DataCell(Text(users[index].username)),
          DataCell(Text(users[index].level.toString())),
          DataCell(Text(users[index].rating.toString())),
          DataCell(Text(capText)),
        ]
      );
    }
    else{
      return DataRow(
        cells: [
          DataCell(Text("")),
          DataCell(Text("")),
          DataCell(Text("")),
          DataCell(Text("")),
          DataCell(Text("")),
        ]
      );
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => users.length;

  @override
  int get selectedRowCount => 0;
  
}

class Leaderboard extends StatefulWidget {
  Leaderboard({Key key}) : super(key: key);

  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  VariablesBloc vBloc;
  LeaderboardDataTableSource lds;

  @override
  Widget build(BuildContext context) {
    vBloc = VariablesProvider.of(context);
    lds = new LeaderboardDataTableSource(context, vBloc);

    return Scaffold(
      body: FutureBuilder(
        future: lds.getDatas(),
        builder: (context, snapshot){
          if(snapshot.hasData && snapshot.data == true){
            return mainContainer();
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
                    Text("Loading users..."),
                  ],
                ),
              ),
            );
          }
        }
      ),
    );
  }

  Widget mainContainer(){
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(66.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_rounded),
                  iconSize: 40,
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Leaderboard",
                  style: TextStyle(
                    fontSize: 46.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 8.0,),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Top 100",
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 24.0,),
              FractionallySizedBox(
                widthFactor: 1.0,
                child: SingleChildScrollView(
                  child: dataTable(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget dataTable(){
    return PaginatedDataTable(
      source: lds,
      columns: [
        DataColumn(
          label: Text("Nationality"),
        ),
        DataColumn(
          label: Text("Username"),
        ),
        DataColumn(
          label: Text("Tier"),
        ),
        DataColumn(
          label: Text("Rating"),
        ),
        DataColumn(
          label: Text("Correct Answer %"),
        ),
      ],
    );
  }
}