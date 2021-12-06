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
      color: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(50.0),
            child: Column(
              children: [
                backButton(context),
                SizedBox(height: 20.0,),
                userCard(),
                bottomCard(),
              ],
            ),
          )
          
        ),
      ),
    );
  }

  Widget backButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: Icon(Icons.arrow_back_rounded),
        iconSize: 40,
        color: Colors.white,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget userCard(){
    return Card(
      borderOnForeground: true,
      color: Colors.grey[50],
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(70.0),
              topLeft: Radius.circular(70.0))),
      shadowColor: Color.fromRGBO(0, 0, 0, 0.2),
      elevation: 5.0,
      child: Container(
        padding: EdgeInsets.all(30.0),
        child: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    child: CircleAvatar(
                      backgroundImage: (vBloc.currentUser.pp == "default.png")
                        ? AssetImage("placeholders/default.png") 
                        : NetworkImage("http://localhost:3000/images/profile/${vBloc.currentUser.pp}", scale: 0.5),
                      backgroundColor: Theme.of(context).colorScheme.primary,
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
                    style:
                        TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
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
                            "country-flags/${vBloc.currentUser.nationality.toLowerCase()}.png"),
                      ),
                      SizedBox(
                        width: 12.0,
                      ),
                      Text(
                        "Your rating: ${vBloc.currentUser.rating.toString()}",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.w200),
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
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(Icons.edit),
                color: Theme.of(context).colorScheme.primary,
                iconSize: 30,
                onPressed: (){
                  Navigator.pushNamed(context, "/profile/edit").then((value) => setState((){}));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget middleCard(){
    return Container();
  }

  Widget bottomCard(){
    TextStyle tStyle = TextStyle(
      fontSize: 18.0,
      color: Theme.of(context).colorScheme.primary
    );
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(70.0), bottomRight: Radius.circular(70.0)),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(34.0),
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.5,
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: {
              0: FractionColumnWidth(0.50),
              1: FractionColumnWidth(0.05),
              2: FractionColumnWidth(0.10),
              3: FractionColumnWidth(0.35),
            },
            children: [
              TableRow(children: [
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Standard games played",
                      textAlign: TextAlign.end,
                      style: tStyle,
                    )),
                Container(),
                Text(
                  "${vBloc.currentUser.sgp}",
                  style: tStyle,
                ),
                Container(),
              ]),
              TableRow(children: [
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Timed games played",
                      textAlign: TextAlign.end,
                      style: tStyle,
                    )),
                Container(),
                Text(
                  "${vBloc.currentUser.tgp}",
                  style: tStyle,
                ),
                Container(),
              ]),
              TableRow(children: [
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Times spent on Timed gamemode",
                      textAlign: TextAlign.end,
                      style: tStyle,
                    )),
                Container(),
                Text(
                  "${vBloc.currentUser.tstg}",
                  style: tStyle,
                ),
                Container(),
              ]),
              TableRow(children: [
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Challenge gamemode played",
                      textAlign: TextAlign.end,
                      style: tStyle,
                    )),
                Container(),
                Text(
                  "${vBloc.currentUser.cgp}",
                  style: tStyle,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.remove_red_eye_rounded),
                    color: Theme.of(context).colorScheme.primary,
                    iconSize: 25,
                    onPressed: () {
                      vBloc.chosenProfileDataSource = vBloc.DATA_SOURCE_CHALLENGE;
                      Navigator.pushNamed(context, "/profile/detail");
                    },
                  ),
                ),
              ]),
              TableRow(children: [
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Challenge won",
                      textAlign: TextAlign.end,
                      style: tStyle,
                    )),
                Container(),
                Text(
                  "${vBloc.currentUser.cw}",
                  style: tStyle,
                ),
                Container(),
              ]),
              TableRow(children: [
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Correct answers",
                      textAlign: TextAlign.end,
                      style: tStyle,
                    )),
                Container(),
                Text(
                  "${vBloc.currentUser.ca}",
                  style: tStyle,
                ),
                Container(),
              ]),
              TableRow(children: [
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Total questions faced",
                      textAlign: TextAlign.end,
                      style: tStyle,
                    )),
                Container(),
                Text(
                  "${vBloc.currentUser.tqf}",
                  style: tStyle,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.remove_red_eye_rounded),
                    color: Theme.of(context).colorScheme.primary,
                    iconSize: 25,
                    onPressed: () {
                      vBloc.chosenProfileDataSource = vBloc.DATA_SOURCE_ANSWERS;
                      Navigator.pushNamed(context, "/profile/detail");
                    },
                  ),
                ),
              ]),
              TableRow(children: [
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "News added",
                      textAlign: TextAlign.end,
                      style: tStyle,
                    )),
                Container(),
                Text(
                  "${vBloc.currentUser.na}",
                  style: tStyle,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.remove_red_eye_rounded),
                    color: Theme.of(context).colorScheme.primary,
                    iconSize: 25,
                    onPressed: () {
                      vBloc.chosenProfileDataSource = vBloc.DATA_SOURCE_NEWS;
                      Navigator.pushNamed(context, "/profile/detail");
                    },
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}