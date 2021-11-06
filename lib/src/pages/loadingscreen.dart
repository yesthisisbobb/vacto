import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';

class LoadingScreen extends StatefulWidget {
  LoadingScreen({Key key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loadingScreen(),
    );
  }

  Future<String> test() async {
    return await Future.delayed(Duration(seconds: 2), (){ return "true"; });
  }
  Widget loadingScreen(){
    return Container(
      child: Center(
        child: FutureBuilder(
          future: test(),
          builder: (context, snapshot){
            if (snapshot.hasData && snapshot.data == "true") {
              Navigator.pushNamed(context, "/play");
              return Text("Loading success");
            }
            else{
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}