// USE THIS FILE FOR LAYOUTING

import 'package:flutter/material.dart';

class PaintingGround extends StatefulWidget {
  PaintingGround({Key key}) : super(key: key);

  @override
  _PaintingGroundState createState() => _PaintingGroundState();
}

class _PaintingGroundState extends State<PaintingGround> with TickerProviderStateMixin{
  AnimationController controller;
  Animation<Offset> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600)
    );

    animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(1.5, 0)
    ).animate(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(""),
    );
  }

  Widget animTest(){
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      child: SlideTransition(
        position: animation,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              GestureDetector(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
                onTap: (){
                  controller.forward();
                },
              ),
              Text(
                "Generating Questions...",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              )
            ]
          )
        ),
      ),
    );
  }
}