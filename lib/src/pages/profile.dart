import 'package:flutter/material.dart';
import 'package:vacto/src/blocs/variables_provider.dart';

class Profile extends StatefulWidget {
  Profile({Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  VariablesBloc vBloc;

  @override
  Widget build(BuildContext context) {
    vBloc = VariablesProvider.of(context);

    return Scaffold(
      body: baseContainer(),
    );
  }

  Widget baseContainer(){
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(50.0),
            child: Column(
              children: [
                userCard(),
                otherStats(),
              ],
            ),
          )
          
        ),
      ),
    );
  }

  Widget userCard(){
    return Card(
      borderOnForeground: true,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(70.0),
              topLeft: Radius.circular(70.0))),
      shadowColor: Color.fromRGBO(0, 0, 0, 0.2),
      elevation: 5.0,
      child: Container(
        padding: EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            children: [
              Container(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://www.woolha.com/media/2020/03/eevee.png',
                      scale: 0.5),
                  backgroundColor:
                      Theme.of(context).colorScheme.primary,
                  radius: 60,
                ),
              ),
              SizedBox(
                height: 12.0,
              ),
              Container(
                child: Image(
                  image: AssetImage(
                      "tiers/tier${vBloc.currentUser.level}.png"),
                  height: 32,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                vBloc.currentUser.username,
                style: TextStyle(
                    fontSize: 22.0, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 8.0,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 26,
                    child: Image.asset(
                        "country-flags/${vBloc.currentUser.nationality}.png"),
                  ),
                  SizedBox(width: 12.0,),
                  Text(
                    "Your rating: ${vBloc.currentUser.rating.toString()}",
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w200),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(
                height: 8.0,
              ),
              SizedBox(
                height: 12.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget otherStats(){
    TextStyle tStyle = TextStyle(
      fontSize: 18.0,
      color: Colors.white
    );
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      padding: EdgeInsets.all(34.0),
      child: Table(
        columnWidths: {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(0.1),
          2: FlexColumnWidth(1),
        },
        children: [
          TableRow(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child:Text("Standard games played", style: tStyle,)
              ),
              Container(),
              Text("${vBloc.currentUser.sgp}", style: tStyle,),
            ]
          ),
          TableRow(children: [
            Align(
              alignment: Alignment.centerRight,
              child:Text("Timed games played", style: tStyle,)
            ),
            Container(),
            Text("${vBloc.currentUser.tgp}", style: tStyle,),
          ]),
          TableRow(children: [
            Align(
              alignment: Alignment.centerRight,
              child:Text("Times spent on Timed gamemode", style: tStyle,)
            ),
            Container(),
            Text("${vBloc.currentUser.tstg}", style: tStyle,),
          ]),
          TableRow(children: [
            Align(
              alignment: Alignment.centerRight,
              child:Text("Challenge gamemode played", style: tStyle,)
            ),
            Container(),
            Text("${vBloc.currentUser.cgp}", style: tStyle,),
          ]),
          TableRow(children: [
            Align(
              alignment: Alignment.centerRight,
              child:Text("Challenge won", style: tStyle,)
            ),
            Container(),
            Text("${vBloc.currentUser.cw}", style: tStyle,),
          ]),
          TableRow(children: [
            Align(
              alignment: Alignment.centerRight,
              child:Text("Correct answers", style: tStyle,)
            ),
            Container(),
            Text("${vBloc.currentUser.ca}", style: tStyle,),
          ]),
          TableRow(children: [
            Align(
              alignment: Alignment.centerRight,
              child:Text("Total questions faced", style: tStyle,)
            ),
            Container(),
            Text("${vBloc.currentUser.tqf}", style: tStyle,),
          ]),
          TableRow(children: [
            Align(
              alignment: Alignment.centerRight,
              child:Text("News added", style: tStyle,)
            ),
            Container(),
            Text("${vBloc.currentUser.na}", style: tStyle,),
          ]),
        ],
      ),
    );
  }
}