import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:mime/mime.dart';
import 'package:rxdart/subjects.dart';

import 'package:vacto/src/blocs/variables_bloc.dart';
import 'package:vacto/src/blocs/variables_provider.dart';

class ProfileEdit extends StatefulWidget {
  ProfileEdit({Key key}) : super(key: key);

  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  BuildContext context;
  VariablesBloc vBloc;

  TextEditingController unewC;
  TextEditingController pcurrC;
  TextEditingController pnewC;

  bool isUploading = false;
  bool errorExists = false;
  bool uploadSuccesful = false;

  var fileBytes;
  bool filePicked = false;
  Uint8List uploadedImage;
  PlatformFile uploadedFile;
  Stream<List<int>> tempStream;
  BehaviorSubject streamC = BehaviorSubject<List<int>>();
  ImageProvider profileImage = AssetImage("placeholders/default.png");

  List<Map<String,dynamic>> achievements = [];

  _startFilePicker() async {
    print("Masuk file picker");
    filePicked = true;

    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withReadStream: true,
    );
    if (result != null) {
      print("Masuk file picker 2");
      // buat upload
      setState(() {
        uploadedFile = result.files.single;
      });

      // buat display gambar
      tempStream = new http.ByteStream(uploadedFile.readStream);

      streamC.sink.add(await tempStream.last);
      var temp = streamC.stream.value;

      uploadedImage = temp;
    }
  }

  Future<bool> getUserAchievements() async {
    var res = await http.get(Uri.parse("http://localhost:3000/api/user/achievement/get/${vBloc.currentUser.id}"));
    if (res.statusCode == 200) {
      var jsonData = res.body.toString();
      var parsedData = json.decode(jsonData);
      print("PARSEDDATA =============");
      print(parsedData);
      print(parsedData.length);

      achievements = [];
      for (var item in parsedData) {
        // a.id, a.name, a.pic, a.description, ua.date, ua.picked
        achievements.add(
          {
            "uaid": item["uaid"],
            "aid": item["aid"],
            "name": item["name"],
            "pic": item["pic"],
            "description": item["description"],
            "date": item["date"],
            "picked": item["picked"],
          }
        );
        print("achievement lenghhhhhh " + achievements.length.toString());
      }

      return true;
    }
    return false;
  }

  upload() async {
    setState(() {
      isUploading = true;
    });

    bool canUpload = true;

    String userid = vBloc.currentUser.id;
    String unew = unewC.text;
    String pcurr = pcurrC.text;
    String pnew = pnewC.text;

    if (canUpload == true) {
      print("Masuk tru");

      var req = http.MultipartRequest("POST", Uri.parse("http://localhost:3000/api/user/update/for/$userid"));

      req.fields["unew"] = unew;
      req.fields["pcurr"] = pcurr;
      req.fields["pnew"] = pnew;

      if (filePicked == true) {
        var length = uploadedFile.size;
        print("4");
        var mimeType = lookupMimeType(uploadedFile.name ?? "");
        print("5");

        var pic = new http.MultipartFile(
            "picture", Stream<List<int>>.value(streamC.stream.value), length,
            filename: uploadedFile.name,
            contentType: mimeType == null
                ? null
                : http_parser.MediaType.parse(mimeType));
        print("6");

        req.files.add(pic);
        print("7");
      }

      var res = await req.send();

      if (res.statusCode == 200) {
        print("Masuk 200");
        print(await res.stream.transform(utf8.decoder).join());

        await vBloc.currentUser.fillOutDataFromID(vBloc.localS.getItem("id"));

        Navigator.pop(context);
      } else {
        vBloc.addUserUpdateError("Update failed!");
      }
    }

    setState(() {
      isUploading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    unewC = TextEditingController();
    pcurrC = TextEditingController();
    pnewC = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    vBloc = VariablesProvider.of(context);
    this.context = context;
    achievements = [];
    print("ISI E ACHIVEMENT: ${achievements.length}");

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
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 40,),
                    backButton(),
                    SizedBox(height: 24,),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Edit Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    SizedBox(height: 24,),
                    mainCard(),
                  ]
                ),
              )
            )
          ],
        )
      )
    );
  }

  Widget backButton() {
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

  Widget mainCard(){
    if (vBloc.currentUser.pp != "default.png") profileImage = NetworkImage("http://localhost:3000/images/profile/${vBloc.currentUser.pp}");
    if (uploadedImage != null) profileImage = MemoryImage(uploadedImage);
    print("Uploaded Image ===========");
    print(uploadedImage);
    
    Stack profilePic = Stack(
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundImage: profileImage,
          radius: 80,
        ),
        Positioned(
          bottom: -10,
          right: -10,
          child: IconButton(
            onPressed: () async {
              await _startFilePicker();
              setState(() {
                profileImage = MemoryImage(uploadedImage);
              });
            }, 
            icon: Icon(Icons.edit)
          )
        )
      ],
    );

    double inputWidth = 300;
    Container usernameInput = Container(
      width: inputWidth,
      child: TextField(
        controller: unewC,
        decoration: InputDecoration(
          labelText: "New Username",
          hintText: "Current username: ${vBloc.currentUser.username}"
        ),
      ),
    );

    Container cPasswordInput = Container(
      width: inputWidth,
      child: TextField(
        controller: pcurrC,
        decoration: InputDecoration(labelText: "Current Password"),
      ),
    );

    Container passwordInput = Container(
      width: inputWidth,
      child: TextField(
        controller: pnewC,
        decoration: InputDecoration(
          labelText: "New Password"
        ),
      ),
    );

    Widget gridView = Container();
    List<Widget> achievementItems = [];
    int showcasedCount = 0;

    return Container(
      width: double.infinity,
      child: Card(
        child: Container(
          margin: EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              profilePic,
              SizedBox(height: 24.0,),
              usernameInput,
              SizedBox(height: 12.0,),
              cPasswordInput,
              SizedBox(height: 12.0,),
              passwordInput,
              SizedBox(height: 40.0,),
              Text(
                "Achievements to showcase",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 24.0,),
              StreamBuilder(
                stream: vBloc.profileAchievementsStream,
                builder: (context, snapshot){
                  return FutureBuilder(
                    future: Future<bool>(getUserAchievements),
                    builder: (context, snapshot){
                      print(snapshot);
                      if(snapshot.hasData){
                        print("Masuk gridview");
                        if(achievements.isNotEmpty){
                          print("ISI E ACHIVEMENT 2: ${achievements.length}");
                          double itemCount = 3;
                          double itemWidth = 240;
                          double itemHeight = 250;
                          double aWidth = itemCount * itemWidth;

                          for (var item in achievements) {
                            if (item["picked"] == 'y') showcasedCount++;

                            DateTime dateTemp =
                                DateTime.parse(item["date"]);
                            String dateText =
                                "Received at ${dateTemp.day}/${dateTemp.month}/${dateTemp.year}";
                            Container temp = Container(
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                  color: (item["picked"] == 'y')
                                      ? Colors.blue[100]
                                      : null,
                                  borderRadius:
                                      BorderRadius.circular(20.0)),
                              child: Center(
                                  child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    "achievements/${item['aid']}.png",
                                    height: 100,
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    item["name"],
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Container(
                                    width: 200,
                                    child: Text(
                                      item["description"],
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Container(
                                    width: 120,
                                    child: Text(
                                      dateText,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  )
                                ],
                              )),
                            );

                            bool changeStateTo = false;
                            Widget tempFinal = InkWell(
                              child: temp,
                              onTap: () async {
                                if (showcasedCount == 3) {
                                  if (item["picked"] == 'y') {
                                    setState(() {
                                      changeStateTo = false;
                                      showcasedCount--;
                                    });
                                    await vBloc.changeProfileAchievement(
                                        item["uaid"], changeStateTo);
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                            content: Text(
                                                "Maximum for showcased achievement is 3!")));
                                  }
                                } else {
                                  if (item["picked"] == 'y') {
                                    setState(() {
                                      changeStateTo = false;
                                      showcasedCount--;
                                    });
                                  } else {
                                    setState(() {
                                      changeStateTo = true;
                                      showcasedCount++;
                                    });
                                  }
                                  await vBloc.changeProfileAchievement(
                                      item["uaid"], changeStateTo);
                                }
                              },
                            );

                            achievementItems.add(tempFinal);
                          }

                          gridView = Container(
                            height: 600,
                            width: aWidth,
                            child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                        mainAxisExtent: itemHeight,
                                        maxCrossAxisExtent: itemWidth,
                                        crossAxisSpacing: 10.0,
                                        mainAxisSpacing: 10.0,
                                        childAspectRatio: 1 / 1),
                                itemCount: achievements.length,
                                itemBuilder: (context, idx) {
                                  return achievementItems[idx];
                                }),
                          );
                          
                          return gridView;
                        }
                        
                        return Container(
                          child: Text("No achievements"),
                        );
                      }
                      else{
                        print("Gamasuk gridview");
                        return CircularProgressIndicator();
                      }
                    },
                  );
                }
              ),
              SizedBox(height: 24.0,),
              ElevatedButton(
                child: Text("Save Changes"),
                onPressed: () async {
                  await upload();
                },
              ),
              SizedBox(height: 24.0,),
              StreamBuilder(
                stream: vBloc.userUpdateErrorStream,
                builder: (context, snapshot){
                  if (snapshot.hasData) {
                    return Container(
                      padding: EdgeInsets.all(20.0),
                      color: Colors.red[100],
                      child: Text(
                        snapshot.data.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    );
                  }
                  else{
                    return Container();
                  }
                  
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}