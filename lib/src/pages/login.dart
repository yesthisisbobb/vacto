import 'package:flutter/material.dart';

class Login extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return loginInputs(context);
  }

  Widget loginInputs(BuildContext context){
    return Container(
      child: Center(
        child: Column(
          children: [
            Text("ayy"),
            Text("asd"),
            Text("bitj"),
            Text("ayy"),
            ElevatedButton(
              child: Text("Ligma"),
              onPressed: (){
                Navigator.pushNamed(context, "/register");
              },
            )
          ],
        ),
      ),
    );
  }
}