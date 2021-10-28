import 'package:flutter/material.dart';

class MainMenu extends StatefulWidget {
  MainMenu({Key key}) : super(key: key);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Row(
          children: [
            Expanded(flex: 3, child: leftContent(context)),
            Expanded(flex: 7, child: rightContent(context))
          ],
        ),
      ),
    );
  }
}

// class MainMenu extends StatelessWidget {

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height,
//         child: Row(
//           children: [
//             Expanded(
//               flex: 3,
//               child: leftContent(context)
//             ),
//             Expanded(
//               flex: 7,
//               child: rightContent(context)
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

Widget leftContent(BuildContext context){
  return Container(
    margin: EdgeInsets.zero,
    child: Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          Image(
            image: AssetImage("vacto_full.png"),
            width: 220,
          ),
          SizedBox(
            height: 20,
          ),
          Card(
            borderOnForeground: true,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(70.0),
                    bottomRight: Radius.circular(70.0))),
            shadowColor: Color.fromRGBO(0, 0, 0, 0.2),
            elevation: 5.0,
            child: Container(
              padding: EdgeInsets.all(30.0),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        radius: 60,
                      ),
                    ),
                    SizedBox(height: 12.0,),
                    Container(
                      child: Image(
                        image: AssetImage("tiers/tier3.png"),
                        height: 32,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      "Joseph Emmerich Stoltz",
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.w500),
                    ),
                    Container(
                      child: Text("[Bendera] [Ranking di negara]"),
                    ),
                    Container(
                      child: Text("[Showcase Achievement]"),
                    ),
                    SizedBox(
                      height: 12.0,
                    ),
                    Container(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0)
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Logout"),
                            SizedBox(width: 5.0,),
                            Icon(Icons.logout),
                          ],
                        ),
                        onPressed: () {},
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      )
    ),
  );
}

Widget rightContent(BuildContext context){
  return Container(
    padding: EdgeInsets.all(20.0),
    child: GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 20.0,
      crossAxisSpacing: 20.0,
      children: menus(context),
    ),
  );
}

List<Widget> menus(BuildContext context){
  return [
    menuItem(context, "menu_icon/play.png", "Play", (){
      print("playtest");
    }),
    menuItem(context, "menu_icon/challenge.png", "Challenge Another Player", () {
      print("playtest2");
    }),
    menuItem(context, "menu_icon/leaderboard.png", "Leaderboard", () {
      print("playtest3");
    }),
    menuItem(context, "menu_icon/profile.png", "Profile", () {
      print("playtest4");
    }),
    menuItem(context, "menu_icon/settings.png", "Settings", () {
      print("playtest5");
    }),
    menuItem(context, "menu_icon/view-data.png", "View Data", () {
      print("playtest6");
    }),
    menuItem(context, "menu_icon/verify.png", "Verify Questions", () {
      print("playtest7");
    }),
  ];
}

Widget menuItem(BuildContext context, String path, String text, Function ontap){
  return InkWell(
    hoverColor: Theme.of(context).colorScheme.secondary,
    highlightColor: Theme.of(context).colorScheme.secondaryVariant,
    borderRadius: BorderRadius.all(Radius.circular(35.0)),
    child: Container(
      child: Card(
        color: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0))
        ),
        child: Container(
          padding: EdgeInsets.all(22.0),
          alignment: Alignment.topLeft,
          child: Stack(
            children: [
              Text(
                text,
                style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.left,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Image(
                  image: AssetImage(path),
                  height: 90,
                ),
              )
            ],
          ),
        ),
      ),
    ),
    onTap: ontap,
  );
}