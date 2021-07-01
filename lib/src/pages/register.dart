import 'package:flutter/material.dart';

class Register extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("i am register and i am here to kill u"),
        ElevatedButton(
          child: Text("back 2 login"),
          onPressed: (){
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}