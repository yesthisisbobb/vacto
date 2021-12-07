import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:file_saver/file_saver_web.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:vacto/src/blocs/variables_bloc.dart';
import 'package:vacto/src/blocs/variables_provider.dart';
import '../classes/ViewDataModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewDataTableSource extends DataTableSource{
  BuildContext context;
  VariablesBloc vBloc;
  List<ViewDataModel> dataList;
  List<dynamic> toExportList;
  List<Map<String, dynamic>> labels;
  String type;

  ViewDataTableSource(BuildContext context, VariablesBloc vBloc, String type){
    this.context = context;
    this.vBloc = vBloc;
    dataList = [];
    toExportList = [];
    labels = [];
    this.type = type;
  }

  getDatas() async {
    var res = await http.get(Uri.parse("http://localhost:3000/api/answer/get/formatted/all/all"));
    if(res.statusCode == 200) {
      var jsonData = res.body.toString();
      var parsedJson = json.decode(jsonData);

      for (var item in parsedJson) {
        ViewDataModel temp = new ViewDataModel();
        await temp.fillOutDataFromID(item["Answer id"]);

        dataList.add(temp);
        toExportList.add(item);
      }

      majorityVoting();
      return true;
    }
    return false;
  }

  majorityVoting(){
    String ntTemp = "";
    int hoaxCtr = 0;
    int legitCtr = 0;
    String label = "";
    for (var i = 0; i < dataList.length; i++) {
      if (ntTemp != dataList[i].nt) {
        label = "hoax";
        if (legitCtr > hoaxCtr) label = "legit";

        if (ntTemp != "")
        labels.add({
          "News Title": ntTemp,
          "Actual Answer": dataList[i].aa,
          "Hoax answer total": hoaxCtr,
          "Legit answer total": legitCtr,
          "Resulting label": label
        });

        ntTemp = dataList[i].nt;
        hoaxCtr = 0;
        legitCtr = 0;
      } else {
        if (dataList[i].ua == "hoax") hoaxCtr++;
        if (dataList[i].ua == "legit") legitCtr++;
      }
    }
  }

  @override
  DataRow getRow(int index) {
    // String adText = "${dataList[index].ad.day}-${dataList[index].ad.month}-${dataList[index].ad.year} ${dataList[index].ad.hour}:${dataList[index].ad.minute}:${dataList[index].ad.second}";
    String rsText = "+${dataList[index].rs.toString()}";
    if (dataList[index].ua != dataList[index].aa) {
      rsText = "-${dataList[index].rs.toString()}";
    }
    // String dobText = "${dataList[index].dob.day}-${dataList[index].dob.month}-${dataList[index].dob.year}";

    if(type == "normal"){
      if(dataList.length > 0){
        return DataRow(cells: [
          DataCell(
            Text(dataList[index].aid.toString()),
          ),
          DataCell(
            Text(dataList[index].ad.toString()),
          ),
          DataCell(
            Text(dataList[index].nt.toString()),
          ),
          DataCell(
            Text(dataList[index].ua.toString()),
          ),
          DataCell(
            Text(dataList[index].aa.toString()),
          ),
          DataCell(
            Text(rsText),
          ),
          DataCell(
            Text(dataList[index].name.toString()),
          ),
          DataCell(
            Text(dataList[index].nat.toString()),
          ),
          DataCell(
            Text(dataList[index].dob.toString()),
          ),
          DataCell(
            Text(dataList[index].gender.toString()),
          ),
        ]);
      }
      else{
        return DataRow(cells: [
          DataCell(
            Text(""),
          ),
          DataCell(
            Text(""),
          ),
          DataCell(
            Text(""),
          ),
          DataCell(
            Text(""),
          ),
          DataCell(
            Text(""),
          ),
          DataCell(
            Text(""),
          ),
          DataCell(
            Text(""),
          ),
          DataCell(
            Text(""),
          ),
          DataCell(
            Text(""),
          ),
          DataCell(
            Text(""),
          ),
        ]);
      }
    }
    else{
      if(labels.length > 0){
        // print({
        //   "News Title": labels[index]["News Title"].toString(),
        //   "Actual Answer": labels[index]["Actual Answer"].toString(),
        //   "Hoax answer total": labels[index]["Hoax answer total"].toString(),
        //   "Legit answer total": labels[index]["Legit answer total"].toString(),
        //   "Resulting label": labels[index]["Resulting label"].toString()
        // });
        return DataRow(cells: [
          DataCell(
            Text(labels[index]["News Title"].toString()),
          ),
          DataCell(
            Text(labels[index]["Actual Answer"].toString()),
          ),
          DataCell(
            Text(labels[index]["Hoax answer total"].toString()),
          ),
          DataCell(
            Text(labels[index]["Legit answer total"].toString()),
          ),
          DataCell(
            Text(labels[index]["Resulting label"].toString()),
          ),
        ]);
      }
      else{
        return DataRow(cells: [
          DataCell(
            Text(""),
          ),
          DataCell(
            Text(""),
          ),
          DataCell(
            Text(""),
          ),
          DataCell(
            Text(""),
          ),
          DataCell(
            Text(""),
          ),
        ]);
      }
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount {
    if(type == "normal"){
      return dataList.length;
    }
    else{
      return labels.length;
    }
  }

  @override
  int get selectedRowCount => 0;
  
}

class ViewData extends StatefulWidget {
  ViewData({Key key}) : super(key: key);

  @override
  _ViewDataState createState() => _ViewDataState();
}

class _ViewDataState extends State<ViewData> {
  VariablesBloc vBloc;
  ViewDataTableSource dts;
  String dataType = "normal";

  @override
  Widget build(BuildContext context) {
    vBloc = VariablesProvider.of(context);
    dts = ViewDataTableSource(context, vBloc, vBloc.viewDataDatatype);

    return Scaffold(
      body: FutureBuilder(
        future: dts.getDatas(),
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
                    Text("Fetching Answers..."),
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
          padding: EdgeInsets.all(50.0),
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
              SizedBox(height: 24.0,),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Answers Data",
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 8.0,),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Here is all the answers from all users",
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 8.0,),
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: (){
                        setState(() {
                          // dataType = "normal";
                          vBloc.viewDataDatatype = "normal";
                        });
                        Navigator.popAndPushNamed(context, "/data/view");
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        padding: EdgeInsets.all(20.0)
                      ),
                      child: Text(
                        "Normal",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16
                        ),
                      )
                    ),
                    SizedBox(width: 8.0,),
                    ElevatedButton(
                      onPressed: (){
                        setState(() {
                          // dataType = "label";
                          vBloc.viewDataDatatype = "label";
                        });
                        Navigator.popAndPushNamed(context, "/data/view");
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        padding: EdgeInsets.all(20.0)
                      ),
                      child: Text(
                        "Labelled Answer Data",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16
                        ),
                      )
                    ),
                  ],
                )
              ),
              SizedBox(height: 24.0,),
              SingleChildScrollView(
                child: dataTable(),
              ),
              SizedBox(height: 24.0,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  padding: EdgeInsets.all(20.0)
                ),
                child: Text("Download as csv"),
                onPressed: () async {
                  List<List<dynamic>> rows = [];
                  List<String> row = [];

                  if (vBloc.viewDataDatatype == "normal"){
                    row.add("Answer ID");
                    row.add("Answer Date");
                    row.add("News Title");
                    row.add("User Answer");
                    row.add("Actual Answer");
                    row.add("Resulting Score");
                    row.add("Name");
                    row.add("Nationality");
                    row.add("Date of Birth");
                    row.add("Gender");
                    rows.add(row);

                    for (var i = 0; i < dts.toExportList.length; i++) {
                      List<String> row = [];
                      row.add(dts.toExportList[i]["Answer id"].toString());
                      row.add(dts.toExportList[i]["Answer Date"].toString());
                      row.add(dts.toExportList[i]["News Title"].toString());
                      row.add(dts.toExportList[i]["User Answer"].toString());
                      row.add(dts.toExportList[i]["Actual Answer"].toString());
                      row.add(
                          dts.toExportList[i]["Resulting Score"].toString());
                      row.add(dts.toExportList[i]["Name"].toString());
                      row.add(dts.toExportList[i]["Nationality"].toString());
                      row.add(dts.toExportList[i]["Date of Birth"].toString());
                      row.add(dts.toExportList[i]["Gender"].toString());
                      rows.add(row);
                    }
                  }
                  else{
                    row.add("News Title");
                    row.add("Actual Answer");
                    row.add("Hoax answer total");
                    row.add("Legit answer total");
                    row.add("Resulting label");
                    rows.add(row);

                    for (var i = 0; i < dts.labels.length; i++) {
                      List<String> row = [];
                      row.add(dts.labels[i]["News Title"].toString());
                      row.add(dts.labels[i]["Actual Answer"].toString());
                      row.add(dts.labels[i]["Hoax answer total"].toString());
                      row.add(dts.labels[i]["Legit answer total"].toString());
                      row.add(dts.labels[i]["Resulting label"].toString());
                      rows.add(row);
                    }
                  }

                  String csv = const ListToCsvConverter().convert(rows);
                  List<int> step1 = csv.codeUnits;
                  Uint8List bytes = Uint8List.fromList(step1);
                  // await FileSaver.instance.saveAs("vacto-dataset", bytes, "csv", MimeType.CSV);
                  await FileSaverWeb().downloadFile(bytes, "vacto-dataset", "text/csv");
                },
              ),
              SizedBox(height: 60.0,),
            ],
          ),
        ),
      ),
    );
  }

  Widget dataTable(){
    List<DataColumn> dataColumns = [];
    if(vBloc.viewDataDatatype == "normal"){
      dataColumns = [
        DataColumn(
            label: Expanded(
          child: Center(
            child: Text("Answer ID"),
          ),
        )),
        DataColumn(
            label: Expanded(
          child: Center(
            child: Text("Answer Date"),
          ),
        )),
        DataColumn(
            label: Expanded(
          child: Center(
            child: Text("News Title"),
          ),
        )),
        DataColumn(
            label: Expanded(
          child: Center(
            child: Text("User Answer"),
          ),
        )),
        DataColumn(
            label: Expanded(
          child: Center(
            child: Text("Actual Answer"),
          ),
        )),
        DataColumn(
            label: Expanded(
          child: Center(
            child: Text("Resulting Score"),
          ),
        )),
        DataColumn(
            label: Expanded(
          child: Center(
            child: Text("Name"),
          ),
        )),
        DataColumn(
            label: Expanded(
          child: Center(
            child: Text("Nationality"),
          ),
        )),
        DataColumn(
            label: Expanded(
          child: Center(
            child: Text("Date of Birth"),
          ),
        )),
        DataColumn(
            label: Expanded(
          child: Center(
            child: Text("Gender"),
          ),
        )),
      ];
    }
    else{
      dataColumns = [
        DataColumn(
            label: Expanded(
          child: Center(
            child: Text("News Title"),
          ),
        )),
        DataColumn(
            label: Expanded(
          child: Center(
            child: Text("Actual Answer"),
          ),
        )),
        DataColumn(
            label: Expanded(
          child: Center(
            child: Text("Hoax answer total"),
          ),
        )),
        DataColumn(
            label: Expanded(
          child: Center(
            child: Text("Legit answer total"),
          ),
        )),
        DataColumn(
            label: Expanded(
          child: Center(
            child: Text("Resulting label"),
          ),
        )),
      ];
    }
    return PaginatedDataTable(
      source: dts,
      columns: dataColumns
    );
  }
}