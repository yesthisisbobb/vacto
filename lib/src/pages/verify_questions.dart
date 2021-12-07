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
    news = [];
  }

  getDatas() async {
    news = [];
    var res = await http.get(Uri.parse("http://localhost:3000/api/news/get/all/all"));
    if (res.statusCode == 200) {
      var jsonData = res.body.toString();
      var parsedJson = json.decode(jsonData);

      news = [];
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
            updateSuccessful = await vBloc.verifyQuestion(news[index].id, bool);
            // if(updateSuccessful == false) switchValue = false; // butuh setState
            
            // switchValue = bool;
            
            // await getDatas();

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
  List<News> news = [];

  getDatas() async {
    news = [];
    var res = await http.get(Uri.parse("http://localhost:3000/api/news/get/all/all"));
    if (res.statusCode == 200) {
      var jsonData = res.body.toString();
      var parsedJson = json.decode(jsonData);

      news = [];
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
  Widget build(BuildContext context) {
    vBloc = VariablesProvider.of(context);
    nds = NewsDataSources(context, vBloc);

    return Scaffold(
      body: baseContainer(),
      // StreamBuilder(
      //   initialData: "a",
      //   stream: vBloc.verifyQuestionStream,
      //   builder: (context, snapshot){
      //     if (snapshot.hasData) {
      //       print(snapshot);
      //       return baseContainer();
            
      //       FutureBuilder(
      //         future: nds.getDatas(),
      //         builder: (context, snapshot){
      //           if(snapshot.hasData){
      //             if(snapshot.data == true){
      //               return baseContainer();
      //             }
      //             else{
      //               return Text("Zonk");
      //             }
      //           }
      //           else{
      //             return CircularProgressIndicator();
      //           }
      //         },
      //       );
      //     }
      //     return CircularProgressIndicator();
      //   }
      // ),
    );
  }

  Widget baseContainer(){
    return FutureBuilder(
      future: getDatas(),
      builder: (context, snapshot){
        if(snapshot.hasData){
          return Container(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: dataTable(),
              ),
            ),
          );
        }
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget dataTable(){
    List<DataRow> newsWidget = [];
    for (var item in news) {
      String dateText = "${item.date.day}-${item.date.month}-${item.date.year}";
      bool switchValue = (item.valid == "y") ? true : false;

      DataRow temp = DataRow(
        cells: [
          DataCell(Text(item.id.toString())),
          DataCell(Text(item.author)),
          DataCell(Text(dateText)),
          DataCell(Text(item.title)),
          DataCell(Text(item.source)),
          DataCell(Text(item.subtype)),
          DataCell(Text(item.answer)),
          DataCell(Switch(
            activeColor: Colors.green[400],
            value: switchValue,
            onChanged: (val) async {
              // bool temp = await vBloc.verifyQuestion(item.id, val);
              bool temp = await vBloc.changeState(item.id, val);
              setState(() {});
            },
          ))
        ]
      );
      newsWidget.add(temp);
    }

    print(newsWidget.length);

    return DataTable(
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
      rows: newsWidget,

    );
    
    PaginatedDataTable(
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