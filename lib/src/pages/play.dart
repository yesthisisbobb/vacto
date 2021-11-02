import 'dart:async';

import 'package:flutter/material.dart';

import '../blocs/variables_provider.dart';

class Play extends StatefulWidget {
  Play({Key key}) : super(key: key);

  @override
  _PlayState createState() => _PlayState();
}

class _PlayState extends State<Play> with TickerProviderStateMixin{
  AnimationController mainCardController;

  Animation<Offset> swipeRightCardAnimation;
  Animation<Offset> swipeLeftCardAnimation;

  Animation<Offset> selectedAnimation;

  @override
  void initState() {
    super.initState();

    mainCardController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    swipeRightCardAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(1.5, 0.0)
    ).animate(CurvedAnimation(parent: mainCardController, curve: Curves.easeIn));

    swipeRightCardAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        print("OK Kanan");
        Timer(Duration(milliseconds: 1500), (){
          mainCardController.reverse();
        });
        // mainCardController.reverse();
      }
    });

    swipeLeftCardAnimation =
        Tween<Offset>(begin: Offset.zero, end: Offset(-1.5, 0.0)).animate(
            CurvedAnimation(parent: mainCardController, curve: Curves.easeIn));

    swipeLeftCardAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        print("OK Kiri");
        Timer(Duration(milliseconds: 1500), () {
          mainCardController.reverse();
        });
        // mainCardController.reverse();
      }
    });
  }

  @override
  void dispose(){
    super.dispose();
    mainCardController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    VariablesBloc vBloc = VariablesProvider.of(context);

    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: FractionallySizedBox(
                widthFactor: 0.65,
                heightFactor: 0.95,
                child: Draggable<bool>(
                  data: true,
                  affinity: Axis.horizontal,
                  axis: Axis.horizontal,
                  feedback: Container(color: Colors.red, height: 200, width: 200,),
                  child: mainNewsContainer(context, vBloc, mainCardController, swipeRightCardAnimation)
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.zero,
              elevation: 7,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.2,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 16.0,),
                          IconButton(
                            icon: Icon(Icons.exit_to_app_rounded),
                            iconSize: 26,
                            onPressed: () {
                              Navigator.pushNamed(context, "/main");
                            },
                          ),
                        ],
                      ),
                    ),
                    FractionallySizedBox(
                      heightFactor: 1.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.close_rounded),
                            iconSize: 40,
                            color: Colors.red,
                            onPressed: () {
                              vBloc.swipeDirection = vBloc.CARD_SWIPE_LEFT;
                              mainCardController.forward();
                            },
                          ),
                          SizedBox(
                            width: 28.0,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Theme.of(context).colorScheme.primary),
                            width: 80,
                            height: 80,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Round",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    "1",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 28.0,
                          ),
                          IconButton(
                            icon: Icon(Icons.check_rounded),
                            iconSize: 40,
                            color: Theme.of(context).colorScheme.secondary,
                            onPressed: () {
                              vBloc.swipeDirection = vBloc.CARD_SWIPE_RIGHT;
                              mainCardController.forward();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget mainNewsContainer(BuildContext context, VariablesBloc vBloc, AnimationController mainCardController, Animation<Offset> swipeCardAnimation) {
    String lorem =
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Feugiat pretium nibh ipsum consequat nisl vel pretium. Consequat mauris nunc congue nisi vitae. Elementum sagittis vitae et leo duis ut diam quam nulla. Diam vulputate ut pharetra sit amet aliquam id diam maecenas. Commodo ullamcorper a lacus vestibulum sed arcu. Non enim praesent elementum facilisis leo vel fringilla est. Viverra maecenas accumsan lacus vel facilisis volutpat. Aliquam etiam erat velit scelerisque. Hac habitasse platea dictumst vestibulum rhoncus est pellentesque elit ullamcorper. Vitae semper quis lectus nulla at. Sagittis vitae et leo duis ut diam quam nulla porttitor. Scelerisque eu ultrices vitae auctor eu. Enim lobortis scelerisque fermentum dui faucibus in ornare. Dolor morbi non arcu risus. In est ante in nibh mauris cursus mattis molestie a. Erat imperdiet sed euismod nisi porta. Tempor commodo ullamcorper a lacus. Malesuada fames ac turpis egestas maecenas pharetra convallis posuere morbi. Malesuada fames ac turpis egestas sed. Consectetur adipiscing elit duis tristique sollicitudin nibh. Ipsum nunc aliquet bibendum enim facilisis. Id aliquet lectus proin nibh nisl condimentum id. Sit amet facilisis magna etiam tempor orci eu lobortis. Feugiat sed lectus vestibulum mattis ullamcorper. Tempor id eu nisl nunc mi ipsum faucibus vitae aliquet. Viverra suspendisse potenti nullam ac tortor vitae purus. Ultrices tincidunt arcu non sodales neque sodales ut etiam. Lobortis elementum nibh tellus molestie nunc. Platea dictumst vestibulum rhoncus est. Tincidunt eget nullam non nisi est sit amet facilisis magna. Elementum facilisis leo vel fringilla est ullamcorper eget. Erat nam at lectus urna duis convallis convallis. Risus viverra adipiscing at in tellus. Eget duis at tellus at urna condimentum. Placerat duis ultricies lacus sed turpis. Lacus luctus accumsan tortor posuere ac ut consequat. Iaculis urna id volutpat lacus laoreet non. Consequat mauris nunc congue nisi. Tortor id aliquet lectus proin nibh. Donec massa sapien faucibus et. Cursus mattis molestie a iaculis at erat pellentesque adipiscing commodo. Neque convallis a cras semper auctor neque vitae. Fermentum posuere urna nec tincidunt praesent semper feugiat. Integer eget aliquet nibh praesent tristique. Nec tincidunt praesent semper feugiat nibh sed pulvinar.";

    return AnimatedBuilder(
      animation: mainCardController,
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Container(
          padding: EdgeInsets.all(25.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Local Celeb Saves an Entire Village Just by Simply Existing!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text("24 August 2021"),
                ),
                SizedBox(
                  height: 18.0,
                ),
                Image.asset(
                  "placeholders/testpp.jpg",
                  fit: BoxFit.fitWidth,
                ),
                SizedBox(
                  height: 18.0,
                ),
                Container(
                  child: Text(
                    "$lorem",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(
                  height: 18.0,
                ),
                Text("Source: www.jawapos.co.id"),
                SizedBox(
                  height: 36.0,
                ),
              ],
            ),
          ),
        ),
      ),
      builder: (BuildContext context, Widget child){
        if (vBloc.swipeDirection == vBloc.CARD_SWIPE_RIGHT) {
          return SlideTransition(
            position: swipeRightCardAnimation,
            child: child,
          );
        }
        else{
          return SlideTransition(
            position: swipeLeftCardAnimation,
            child: child,
          );
        }
      },
    );
  }
}