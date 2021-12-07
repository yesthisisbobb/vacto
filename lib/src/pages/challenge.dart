import 'package:flutter/material.dart';

import '../blocs/variables_provider.dart';

class Challenge extends StatefulWidget {
  Challenge({Key key}) : super(key: key);

  @override
  _ChallengeState createState() => _ChallengeState();
}

class _ChallengeState extends State<Challenge> {
  VariablesBloc vBloc;

  double screenW, screenH;
  
  Color primary = Colors.blue[900];
  Color hover = Color.fromRGBO(0, 26, 77, 1);
  Color container1Color;
  Color container2Color;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    vBloc = VariablesProvider.of(context);
    primary = Theme.of(context).colorScheme.primary;

    screenH = MediaQuery.of(context).size.height;
    screenW = MediaQuery.of(context).size.width;
    print(screenH.toString());
    print(screenW.toString());

    container1Color = primary;
    container2Color = primary;

    return Scaffold(
      body: selectionScreen(context),
    );
  }

  Widget selectionScreen(BuildContext context){
    Widget menu = Row(
      children: [
        toChallenge(),
        Container(
          height: double.infinity,
          width: 2.0,
          color: Colors.white,
        ),
        toRequest()
      ],
    );

    if (screenW <= 900) menu = Column(
      children: [
        toChallenge(),
        Container(
          width: double.infinity,
          height: 2.0,
          color: Colors.white,
        ),
        toRequest()
      ],
    );
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          menu,
          Container(
            child: Center(
              child: GestureDetector(
                child: Card(
                  elevation: 7.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.0)),
                  child: Container(
                    padding: EdgeInsets.all(40.0),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcATop),
                      child: Image.asset(
                        "menu_icon/challenge.png",
                        height: 120,
                      ),
                    )
                  ),
                ),
                onTap: (){
                  Navigator.pop(context);
                },
              ),
            )
          )
        ],
      )
    );
  }

  Widget toChallenge(){
    return Expanded(
      child: InkWell(
        child: AnimatedContainer(
          color: container1Color,
          duration: Duration(milliseconds: 1000),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 50.0,
                ),
                Text(
                  "Challenge",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: (){
          Navigator.pushNamed(context, "/challenge/find");
        },
      ),
    );
  }

  Widget toRequest(){
    return Expanded(
      child: InkWell(
        child: AnimatedContainer(
          color: container2Color,
          duration: Duration(milliseconds: 1000),
          child: Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: Text(
                    "Requests",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 70,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(
                  width: 50.0,
                ),
              ],
            ),
          ),
        ),
        onTap: (){
          Navigator.pushNamed(context, "/challenge/requests");
        },
      ),
    );
  }
}