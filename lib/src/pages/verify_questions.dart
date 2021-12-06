import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vacto/src/blocs/variables_provider.dart';
import 'package:http/http.dart' as http;
import 'package:vacto/src/classes/News.dart';
import 'package:vacto/src/pages/profile_datas_view.dart';

class NewsDataSources extends DataTableSource {
  BuildContext context;
  VariablesBloc vBloc;
  String uid;
  List<News> news = [];

  NewsDataSources(BuildContext context, VariablesBloc vBloc){
    this.context = context;
    this.vBloc = vBloc;
  }

  getDatas() async {
    news = [];
    var res = await http.get(Uri.parse("http://localhost:3000/api/news/get/all/all"));
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
      bool switchValue = (news[index].valid == "y") ? true : false;
      bool updateSuccessful = false;

      return DataRow(cells: [
        DataCell(Text(news[index].id.toString())),
        DataCell(Text(news[index].author)),
        DataCell(Text(dateText)),
        DataCell(Text(news[index].title)),
        DataCell(Text(news[index].source)),
        DataCell(Text(news[index].subtype)),
        DataCell(Text(news[index].answer)),
        DataCell(Switch(
          activeColor: Colors.green[400],
          value: switchValue,
          onChanged: (bool) async {
            updateSuccessful = await vBloc.changeState(news[index].id, bool);
            if(updateSuccessful == false) switchValue = false; // butuh setState
            
            switchValue = bool;
            
            await getDatas();

            // maybe pop and pushnamed?
          },
        ))
      ]);
    } else {
      return DataRow(cells: [
        DataCell(Text("")),
        DataCell(Text("")),
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
  int get rowCount => news.length;

  @override
  int get selectedRowCount => 0;
}

class VerifyQuestions extends StatefulWidget {
  VerifyQuestions({Key key}) : super(key: key);

  @override
  _VerifyQuestionsState createState() => _VerifyQuestionsState();
}

class _VerifyQuestionsState extends State<VerifyQuestions> {
  NewsDataSources nds;
  VariablesBloc vBloc;

  @override
  Widget build(BuildContext context) {
    vBloc = VariablesProvider.of(context);
    nds = NewsDataSources(context, vBloc);

    return Scaffold(
      body: FutureBuilder(
        future: nds.getDatas(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            if(snapshot.data == true){
              return baseContainer();
            }
            else{
              return Text("Zonk");
            }
          }
          else{
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Widget baseContainer(){
    return Container(
      child: dataTable(),
    );
  }

  Widget dataTable(){
    return PaginatedDataTable(
      source: nds,
      columns: [
        DataColumn(
          label: Text("id"),
        ),
        DataColumn( 
          label: Text("author"),
        ),
        DataColumn(
          label: Text("title"),
        ),
        DataColumn(
          label: Text("date"),
        ),
        DataColumn(
          label: Text("source"),
        ),
        DataColumn(
          label: Text("subtype"),
        ),
        DataColumn(
          label: Text("answer"),
        ),
        DataColumn(
          label: Text("switch"),
        ),
      ],
    );
  }
}