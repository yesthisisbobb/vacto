import 'dart:convert';
import 'dart:js';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../blocs/variables_provider.dart';
import '../classes/User.dart';

class UserChallenges extends DataTableSource {
  BuildContext context;
  VariablesBloc vBloc;
  List<User> users;
  String selectedOpponent;

  UserChallenges(BuildContext context, VariablesBloc vBloc) {
    this.context = context;
    this.vBloc = vBloc;
    users = [];
  }

  Future<bool> getUsers() async {
    var res = await http.get(Uri.parse("http://localhost:3000/api/users/get/20"));
    if (res.statusCode == 200) {
      String jsonData = res.body.toString();
      var parsedJson = json.decode(jsonData);
      print(parsedJson);

      for (var item in parsedJson) {
        if (item["id"] != vBloc.currentUser.id) {
          User temp = new User();
          await temp.fillOutDataFromID(item["id"]);

          users.add(temp);
        }
      }

      return true;
    }

    return false;
  }

  storeAndNavigate(id) {
    vBloc.opponentId = id;
    vBloc.isGameModeChallenge = true;
    Navigator.pushNamed(context, "/play");
  }

  @override
  DataRow getRow(int index) {
    if (users.length > 0) {
      return DataRow(cells: [
        DataCell(
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              "country-flags/${users[index].nationality}.png",
              height: 20,
            ),
          ),
        ),
        DataCell(
            Align(
              alignment: Alignment.center,
              child: Text(users[index].username),
            ), onTap: () {
          storeAndNavigate(users[index].id);
        }),
        DataCell(
          Center(
            child: Text(users[index].level.toString()),
          ),
        ),
        DataCell(
          Center(
            child: Text(users[index].rating.toString()),
          ),
        ),
      ]);
    } else {
      return DataRow(cells: [
        DataCell(Text("ID")),
        DataCell(Text("John Doe")),
        DataCell(Text("1")),
        DataCell(Text("0")),
      ]);
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => users.length;

  @override
  int get selectedRowCount => 0;
}

class ChallengeFind extends StatefulWidget {
  ChallengeFind({Key key}) : super(key: key);

  @override
  _ChallengeFindState createState() => _ChallengeFindState();
}

class _ChallengeFindState extends State<ChallengeFind> {
  VariablesBloc vBloc;
  UserChallenges usersData;

  @override
  Widget build(BuildContext context) {
    vBloc = VariablesProvider.of(context);
    usersData = UserChallenges(context, vBloc);

    return Scaffold(
      body: challenge(),
    );
  }

  Widget challenge() {
    return FutureBuilder(
      future: usersData.getUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          return baseContainer(context);
        } else {
          return Container(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 16.0,
                  ),
                  Text("Fetching players..."),
                ],
              ),
            ),
          );
        }
      }
    );
  }

  Widget baseContainer(context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
          child: FractionallySizedBox(
        widthFactor: 0.8,
        child: Column(
          children: [
            SizedBox(
              height: 40,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Challenge Another Player",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select the username of your would-be opponent!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(
              height: 24,
            ),
            FractionallySizedBox(
              widthFactor: 1,
              child: Container(
                child: dataTable(),
              ),
            ),
            SizedBox(
              height: 70,
            ),
          ],
        ),
      )),
    );
  }

  Widget dataTable() {
    return PaginatedDataTable(
      source: usersData,
      rowsPerPage: 20,
      showFirstLastButtons: false,
      columns: [
        DataColumn(
          label: Expanded(
              child: Center(
            child: Text("Nationality"),
          )),
        ),
        DataColumn(
          label: Expanded(
            child: Center(
              child: Text("Username"),
            ),
          ),
        ),
        DataColumn(
          numeric: true,
          label: Expanded(
            child: Center(
              child: Text("Tier"),
            ),
          ),
        ),
        DataColumn(
          numeric: true,
          label: Expanded(
            child: Center(
              child: Text("Rating"),
            ),
          ),
        ),
      ],
    );
  }
}