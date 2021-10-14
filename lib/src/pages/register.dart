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
        child: ListView(
          children: [
            loginRedirect(context)
          ],
        ),
      )
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
          Navigator.pop(context);
        },
      )
    ],
  );
}