import 'dart:js';

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
class _RegisterState extends State<Register> with TickerProviderStateMixin{
  RegisterBloc rBloc;
  int _idx = 0, _idxM = 3;
  final _dateController = TextEditingController();
  String dob = "";
  String gender = "n";
  String dropdownValue = "ID";
  String role = "n";

  Animation<Color> colorAnimN;
  AnimationController colorContN;
  Animation<Color> colorAnimD;
  AnimationController colorContD;

  double cardHeaderFontSize = 40.0, cardDetailFontSize = 24.0;

  @override
  void initState() {
    super.initState();

    colorContN = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this
    );
    colorAnimN = ColorTween(
      begin: Colors.blue[900],
      end: Colors.grey
    ).animate(colorContN)..addListener(() {setState(() {});});

    colorContD =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    colorAnimD = ColorTween(begin: Colors.grey, end: Colors.blue[900])
        .animate(colorContD)
          ..addListener(() {
            setState(() {});
          });
  }

  void normalRoleSelected(){
    colorContN.reverse();
    colorContD.reverse();
  }
  void dataRoleSelected(){
    colorContN.forward();
    colorContD.forward();
  }

  @override
  Widget build(BuildContext context) {
    rBloc = RegisterProvider.of(context);
    double psSize = 0.68;
    if (MediaQuery.of(context).size.height <= 1000) psSize = 0.5;
    if (MediaQuery.of(context).size.height <= 700){
      cardHeaderFontSize = 30;
      cardDetailFontSize = 20;
    }

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              bottom: -60,
              right: -20,
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  "register_page/plus-1.png",
                  height: MediaQuery.of(context).size.height * psSize,
                ),
              ),
            ),
            Positioned(
              top: -60,
              left: -20,
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  "register_page/plus-2.png",
                  height: MediaQuery.of(context).size.height * psSize,
                ),
              ),
            ),
            registerInputs(context)
          ],
        ),
      ),
    );
  }

  @override
  void dispose(){
    _dateController.dispose();
    colorContN.dispose();
    colorContD.dispose();
    super.dispose();
  }
  
  Widget registerInputs(BuildContext context) {
    print(MediaQuery.of(context).size.width);
    double wf = 0.7;
    if (MediaQuery.of(context).size.width <= 1000) wf = 0.8;
    if (MediaQuery.of(context).size.width <= 770) wf = 0.9;
    if (MediaQuery.of(context).size.width <= 500) wf = 1;
    return Center(
      child: FractionallySizedBox(
        widthFactor: wf,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 28.0,),
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
                    rBloc.addExtras("$dropdownValue|$gender|$role");
                    if(rBloc.extrasStream != null){
                      rBloc.submit(context);
                    }
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
                    title: Text("Username"),
                    content: Container(
                      child: cardBase(context, initialStep(context))
                    ),
                  ),
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
                  Step(
                    title: Text("Role"),
                    content: cardBase(context, stepThree(context))
                  )
                ],
              ),
              StreamBuilder(
                  stream: rBloc.errorStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        decoration: BoxDecoration(color: Colors.red[50]),
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Text(
                            snapshot.data.toString(),
                            style: TextStyle(color: Colors.red[900], fontSize: 16.0),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }),
              SizedBox(height: 50.0,),
            ],
          ),
        ),
      )
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

  List<Widget> initialStep(BuildContext context){
    return [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Hello and Welcome!",
          style: TextStyle(fontSize: cardHeaderFontSize, fontWeight: FontWeight.bold),
        ),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "What should we call you?",
          style: TextStyle(fontSize: cardDetailFontSize),
        ),
      ),
      SizedBox(
        height: 24.0,
      ),
      StreamBuilder(
        stream: rBloc.usernameStream,
        builder: (context, snapshot){
          return TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Your username",
              errorText: (snapshot.hasError) ? snapshot.error.toString() : null
            ),
            onChanged: rBloc.changeUsername,
          );
        }
      ),
    ];
  }

  List<Widget> stepOne(BuildContext context){
    return [
      Align(
        alignment: Alignment.centerLeft,
        child: StreamBuilder(
          stream: rBloc.usernameStream,
          builder: (context, snapshot){
            if(snapshot.hasData){
              var temp = snapshot.data.toString();
              return Text( "Hello, $temp!",
                style: TextStyle(fontSize: cardHeaderFontSize, fontWeight: FontWeight.bold),
              );
            }
            else{
              return Text( "Hello, user!",
                style: TextStyle(fontSize: cardHeaderFontSize, fontWeight: FontWeight.bold),
              );
            }
          }
        ),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "First things first, let's set up your credentials",
          style: TextStyle(fontSize: cardDetailFontSize),
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
                        decoration: InputDecoration(
                          hintText: "John Doe",
                          errorText: (snapshot.hasError) ? snapshot.error.toString() : null,
                        ),
                        textCapitalization: TextCapitalization.words,
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
                        decoration: InputDecoration(
                          hintText: "johndoe@example.com",
                          errorText: (snapshot.hasError)
                              ? snapshot.error.toString()
                              : null,
                        ),
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
                        decoration: InputDecoration(
                          hintText: "******",
                          errorText: (snapshot.hasError)
                              ? snapshot.error.toString()
                              : null,
                        ),
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
                        decoration: InputDecoration(
                          hintText: "******",
                          errorText: (snapshot.hasError)
                              ? snapshot.error.toString()
                              : null,
                        ),
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
    double fontsize = 14.0;
    double flexfactor = 0.5;

    Map<String, String> data;
    List<DropdownMenuItem<String>> dropdowns = [];

    Widget natTextW = Text(
      "Nationality",
      textAlign: TextAlign.start,
      style: TextStyle(
        fontSize: fontsize,
      ),
    );

    Widget dobTextW = Text(
      "Date of Birth",
      textAlign: TextAlign.start,
      style: TextStyle(
        fontSize: fontsize,
      ),
    );

    Widget genderTextW = Text(
      "Gender",
      textAlign: TextAlign.start,
      style: TextStyle(
        fontSize: fontsize,
      ),
    );

    Widget dropdown = FutureBuilder(
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
    );

    Widget dobStreamB = StreamBuilder(
      stream: rBloc.dobStream,
      builder: (context, snapshot){
        return TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: "dd-mm-yyyy",
            errorText: (snapshot.hasError) ? snapshot.error.toString() : null,
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
    );

    Widget genderRadioL = Column(
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
    );

    Widget smallDetailField = Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          natTextW,
          SizedBox(
            height: 8.0,
          ),
          dropdown,
          SizedBox(
            height: 28.0,
          ),
          dobTextW,
          SizedBox(
            height: 8.0,
          ),
          dobStreamB,
          SizedBox(
            height: 28.0,
          ),
          genderTextW,
          SizedBox(
            height: 8.0,
          ),
          genderRadioL,
        ],
      ),
    );

    return [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Alright!",
          style: TextStyle(fontSize: cardHeaderFontSize, fontWeight: FontWeight.bold),
        ),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Next, let's fill out details about yourself",
          style: TextStyle(fontSize: cardDetailFontSize),
        ),
      ),
      SizedBox(
        height: 24.0,
      ),
      (MediaQuery.of(context).size.width <= 600)
      ? smallDetailField
      : Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          // widthFactor: 0.8,
          child: Table(
            columnWidths: <int, TableColumnWidth>{
              0: FlexColumnWidth(flexfactor),
              1: FlexColumnWidth(0.12),
              2: FlexColumnWidth(2.0)
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              TableRow(
                children: [
                  natTextW,
                  Container(),
                  dropdown,
                ],
              ),
              TableRow(
                children: [
                  dobTextW,
                  Container(),
                  dobStreamB,
                ],
              ),
              TableRow(
                children: [
                  genderTextW,
                  Container(),
                  genderRadioL,
                ],
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> stepThree(BuildContext context){
    TextStyle kindaBigStyle = TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w500,
    );
    TextStyle justItalic = TextStyle(
      fontStyle: FontStyle.italic,
    );

    Widget normalW = Column(
      children: [
        IconButton(
          icon: Icon(Icons.person),
          iconSize: 80,
          color: colorAnimN.value,
          onPressed: () {
            setState(() {
              role = "n";
            });
            normalRoleSelected();
          },
        ),
        Text(
          "Normal User",
          style: kindaBigStyle,
        ),
        Text("I'm just here to play",
          style: justItalic,
        )
      ],
    );

    Widget dsW = Column(
      children: [
        IconButton(
          icon: Icon(Icons.assessment),
          iconSize: 80,
          color: colorAnimD.value,
          onPressed: () {
            setState(() {
              role = "d";
            });
            dataRoleSelected();
          },
        ),
        Text("Data Scientist",
          style: kindaBigStyle,
        ),
        Text("I'm here to do sciency stuff",
          style: justItalic,
        ),
      ],
    );

    return [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Last Step!",
          style: TextStyle(fontSize: cardHeaderFontSize, fontWeight: FontWeight.bold),
        ),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Okay! Now onto the last step, choose your desired role",
          style: TextStyle(fontSize: cardDetailFontSize),
        ),
      ),
      SizedBox(
        height: 24.0,
      ),
      Column(
        children: [
          SizedBox(height: 30.0,),
          (MediaQuery.of(context).size.width <= 600)
          ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              normalW,
              SizedBox(height: 24.0,),
              dsW,
            ],
          )
          : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              normalW,
              dsW,
            ],
          ),
          SizedBox( height: 30.0, ),
        ],
      )
      
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
