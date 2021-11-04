import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:vacto/src/blocs/register_bloc.dart';
import 'package:vacto/src/blocs/register_provider.dart';

class Register extends StatefulWidget {
  Register({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}
class _RegisterState extends State<Register> {
  RegisterBloc rBloc;
  int _idx = 0, _idxM = 1;
  final _dateController = TextEditingController();
  String dob = "";
  String gender = "";
  String dropdownValue = "ID";

  @override
  Widget build(BuildContext context) {
    rBloc = RegisterProvider.of(context);
    return Scaffold(
      body: registerInputs(context),
    );
  }

  @override
  void dispose(){
    _dateController.dispose();
    super.dispose();
  }
  
  Widget registerInputs(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Center(
          child: FractionallySizedBox(
        widthFactor: 0.7,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stepper(
                currentStep: _idx,
                onStepCancel: () {
                  if (_idx == 0) {
                    Navigator.pushNamed(context, "/login");
                  } else {
                    setState(() {
                      _idx -= 1;
                    });
                  }
                },
                onStepContinue: () {
                  if (_idx == _idxM) {
                    // Navigator.pushNamed(context, "/somewhere");
                    print("made it here");
                    rBloc.addExtras("$dropdownValue|$gender");
                    print("made it here 2");
                    if(rBloc.extrasStream != null){
                      rBloc.submit();
                    }
                    print("made it here 3");
                  } else {
                    setState(() {
                      _idx += 1;
                    });
                  }
                },
                onStepTapped: (idx) {
                  setState(() {
                    _idx = idx;
                  });
                },
                steps: [
                  Step(
                    title: Text("Account"),
                    content: Container(
                      child: cardBase(context, stepOne(context))
                    ),
                  ),
                  Step(
                    title: Text("Details"),
                    content: cardBase(context, stepTwo(context))
                  ),
                ],
              ),
              SizedBox(height: 50.0,)
            ],
          ),
        ),
      )),
    );
  }

  Widget cardBase(BuildContext context , List<Widget> content) {     
    return Container(
      child: Card(
        child: Container(
          padding: EdgeInsets.fromLTRB(46.0, 46.0, 46.0, 64.0),
          child: Column(
            children: content
          ),
        ),
      ),
    );
  }

  List<Widget> stepOne(BuildContext context){
    return [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Hello and Welcome!",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "First things first, let's set up your credentials",
          style: TextStyle(fontSize: 24),
        ),
      ),
      SizedBox(
        height: 24.0,
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          // widthFactor: 0.8,
          child: Table(
            columnWidths: <int, TableColumnWidth>{
              0: FlexColumnWidth(0.5),
              1: FlexColumnWidth(0.14),
              2: FlexColumnWidth(2.0)
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              TableRow(
                children: [
                  Text(
                    "Name",
                    textAlign: TextAlign.start,
                  ),
                  Container(),
                  StreamBuilder(
                    stream: rBloc.nameStream,
                    builder: (context, snapshot){
                      return TextField(
                        decoration: InputDecoration(hintText: "John Doe"),
                        onChanged: rBloc.changeName,
                      );
                    }
                  ),
                ],
              ),
              TableRow(
                children: [
                  Text(
                    "Email",
                    textAlign: TextAlign.start,
                  ),
                  Container(),
                  StreamBuilder(
                    stream: rBloc.emailStream,
                    builder: (context, snapshot){
                      return TextField(
                        decoration: InputDecoration(hintText: "johndoe@example.com"),
                        onChanged: rBloc.changeEmail,
                      );
                    }
                  ),
                ],
              ),
              TableRow(
                children: [
                  Text(
                    "Password",
                    textAlign: TextAlign.start,
                  ),
                  Container(),
                  StreamBuilder(
                    stream: rBloc.passwordStream,
                    builder: (context, snapshot){
                      return TextField(
                        obscureText: true,
                        decoration: InputDecoration(hintText: "******"),
                        onChanged: rBloc.changePass,
                      );
                    }
                  ),
                ],
              ),
              TableRow(
                children: [
                  Text(
                    "Confirm Password",
                    textAlign: TextAlign.start,
                  ),
                  Container(),
                  StreamBuilder(
                    stream: rBloc.cpasswordStream,
                    builder: (context, snapshot){
                      return TextField(
                        obscureText: true,
                        decoration: InputDecoration(hintText: "******"),
                        onChanged: rBloc.changeCpass,
                      );
                    }
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> stepTwo(BuildContext context) {
    Map<String, String> data;
    List<DropdownMenuItem<String>> dropdowns = [];

    return [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Alright!",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Next, let's fill out details about yourself",
          style: TextStyle(fontSize: 24),
        ),
      ),
      SizedBox(
        height: 24.0,
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          // widthFactor: 0.8,
          child: Table(
            columnWidths: <int, TableColumnWidth>{
              0: FlexColumnWidth(0.5),
              1: FlexColumnWidth(0.14),
              2: FlexColumnWidth(2.0)
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              TableRow(
                children: [
                  Text(
                    "Nationality",
                    textAlign: TextAlign.start,
                  ),
                  Container(),
                  FutureBuilder(
                    future: Future<Map<String, String>>(() async {
                      var res = await http.get(Uri.parse("http://localhost:3000/api/countries/get/all"));
                      if(res.statusCode == 200){
                        var jsonData = res.body.toString();
                        var parsedJson = json.decode(jsonData);
                        
                        List<String> name = [];
                        List<String> abv = [];
                        for (var item in parsedJson) {
                          name.add(item["name"]);
                          abv.add(item["abv"]);
                        }

                        Map<String, String> result = Map.fromIterables(name, abv);
                        return result;
                      }
                      else{
                        return null;
                      }
                      
                    }),
                    builder: (context, snapshot){
                      if(!snapshot.hasData){
                        return LinearProgressIndicator();
                      }
                      else{
                        data = snapshot.data;
                        dropdowns.clear();

                        data.forEach((k, v) {
                          dropdowns.add(
                            DropdownMenuItem(
                              value: v,
                              child: Text(k),
                            )
                          );
                        });
                        
                        return DropdownButton<String>(
                          onChanged: (val){
                            setState(() {
                              dropdownValue = val;
                            });
                          },
                          items: dropdowns,
                          value: dropdownValue,
                        );
                      }
                    }
                  ),
                  
                ],
              ),
              TableRow(
                children: [
                  Text(
                    "Date of Birth",
                    textAlign: TextAlign.start,
                  ),
                  Container(),
                  StreamBuilder(
                    stream: rBloc.dobStream,
                    builder: (context, snapshot){
                      return TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: "dd-mm-yyyy",
                          errorText: (snapshot.hasError) ? snapshot.error : null,
                        ),
                        controller: _dateController,
                        onTap: () async {
                          var date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now());
                          if (date != null) {
                            var initDate = date.toString().substring(0, 10);
                            var splitDate = initDate.split("-");
                            _dateController.text = "${splitDate[2]}-${splitDate[1]}-${splitDate[0]}";
                            rBloc.changeDob("${splitDate[2]}-${splitDate[1]}-${splitDate[0]}");
                          }
                        }
                      );
                    } 
                  ),
                ],
              ),
              TableRow(
                children: [
                  Text(
                    "Gender",
                    textAlign: TextAlign.start,
                  ),
                  Container(),
                  Column(
                    children: [
                      SizedBox(height: 20.0,),
                      RadioListTile<String>(
                        title: Text("Male"),
                        value: "m",
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value;
                          });
                        }
                      ),
                      RadioListTile<String>(
                        title: Text("Female"),
                        value: "f",
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value;
                          });
                        }
                      ),
                      RadioListTile<String>(
                        title: Text("Prefer not to say"),
                        value: "n",
                        groupValue: gender,
                        onChanged: (value) {
                          setState(() {
                            gender = value;
                          });
                        }
                      ),
                    ],
                  ),
                  
                ],
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget continueButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () {},
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Continue"),
            Icon(
              Icons.arrow_right,
              color: Colors.white,
              size: 20.0,
            )
          ],
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
        ),
      ),
    );
  }

  Widget loginRedirect(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Not the page you're looking for? "),
        TextButton(
          child: Text("Return to login page"),
          onPressed: () {
            Navigator.pushNamed(context, "/login");
          },
        )
      ],
    );
  }
}
