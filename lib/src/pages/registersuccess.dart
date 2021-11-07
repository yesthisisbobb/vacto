import 'dart:ui';

import 'package:flutter/material.dart';

class RegisterSuccess extends StatelessWidget {
  const RegisterSuccess({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Colors.blue[900],
            Theme.of(context).colorScheme.primary,
          ],
          radius: 1.0,
          center: Alignment.bottomCenter
        )
      ),
      child: Center(
        child: Container(
          child: Card(
            elevation: 20,
            child: Container(
              padding: EdgeInsets.all(36.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  //TODO: make this a gif with a circular indicator before changing to a check
                  Image.asset(
                    "vacto_logo.png",
                    height: 160,
                  ),
                  SizedBox(height: 20.0,),
                  Text(
                    "Register Successful!",
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700
                    ),
                  ),
                  SizedBox(height: 6.0,),
                  Text(
                    "Now let's head over to login to complete your account creation",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0
                    ),
                  ),
                  SizedBox(height: 20.0,),
                  ElevatedButton(
                    child: Text("Head to login"),
                    onPressed: (){
                      Navigator.pushNamed(context, "/login");
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}