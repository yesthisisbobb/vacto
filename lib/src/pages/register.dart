import 'package:flutter/material.dart';

class Register extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: registerInputs(context),
    );
  }
}

Widget registerInputs(BuildContext context){
  return Container(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height,
    child: Center(
      child: FractionallySizedBox(
        widthFactor: 0.7,
        child: Card(
          child: FractionallySizedBox(
            widthFactor: 0.83,
            heightFactor: 0.95,
            child: ListView(
              padding: EdgeInsets.only(top: 38.0, bottom: 30.0),
              children: stepOne(context)
            ),
          ),
        ),
        
        
      )
    ),
  );
}

List<Widget> stepOne(BuildContext context){
  return [
    Text(
      "Hello and Welcome!",
      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
    ),
    Text(
      "First things first, let's set up your credentials",
      style: TextStyle(fontSize: 24),
    ),
    Table(
      columnWidths: <int, TableColumnWidth>{
        0: FlexColumnWidth(1.0),
        1: FlexColumnWidth(0.5),
        2: FlexColumnWidth(2.0)
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: <TableRow>[
        TableRow(
          children: [Text("Name:"), Container(), TextField()],
        ),
        TableRow(
          children: [Text("Email:"), Container(), TextField()],
        ),
        TableRow(
          children: [Text("Password:"), Container(), TextField()],
        ),
        TableRow(
          children: [Text("Confirm Password:"), Container(), TextField()],
        )
      ],
    ),
    Container(
      margin: EdgeInsets.only(bottom: 20.0),
    ),
    continueButton(context),
    Container(
      margin: EdgeInsets.only(bottom: 12.0),
    ),
    loginRedirect(context)
  ];
}

Widget continueButton(BuildContext context){
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

Widget loginRedirect(BuildContext context){
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text("Not the page you're looking for? "),
      TextButton(
        child: Text("Return to login page"),
        onPressed: (){
          Navigator.pushNamed(context, "/login");
        },
      )
    ],
  );
}