import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:rxdart/rxdart.dart';

import '../blocs/variables_provider.dart';

class AddNews extends StatefulWidget {
  AddNews({Key key}) : super(key: key);

  @override
  _AddNewsState createState() => _AddNewsState();
}

class _AddNewsState extends State<AddNews> {
  VariablesBloc vB;
  TextStyle bold18 = TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

  String title = "";
  // TextEditingController titleC;
  String description = "";
  // TextEditingController descriptionC;
  String source = "";
  // TextEditingController sourceC;

  String subtype = "nor";
  String answer = "legit";

  var fileBytes;
  Uint8List uploadedImage;
  PlatformFile uploadedFile;
  Stream<List<int>> tempStream;
  BehaviorSubject streamC = BehaviorSubject<List<int>>();

  List<int> selectedTags = [];

  bool filePicked = false;
  bool isUploading = false;
  bool uploadSuccesful = false;
  bool errorExists = false;

  @override
  void initState() {
    super.initState();

    // titleC = TextEditingController();
    // descriptionC = TextEditingController();
    // sourceC = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    streamC.close();
  }

  @override
  Widget build(BuildContext context) {
    vB = VariablesProvider.of(context);

    return Scaffold(
      body: baseContainer(context),
    );
  }

  Widget baseContainer(BuildContext context){
    double wf = 0.7;
    if(MediaQuery.of(context).size.width <= 1000) wf = 0.97;

    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
        child: FractionallySizedBox(
          widthFactor: wf,
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              backButton(context),
              SizedBox(
                height: 12,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Add News",
                      style: TextStyle(
                        fontSize: 46.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )
                    ),
                    Text(
                      "Add your own news article for others to guess!",
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 24,
              ),
              newsSection(),
              SizedBox(
                height: 60,
              ),
            ],
          ),
        ),
        
      ),
    );
  }

  Widget backButton(BuildContext context){
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

  Widget newsSection(){
    return Container(
      child: Card(
        child: Container(
          padding: EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "News type",
                  style: bold18,
                ),
              ),
              SizedBox(height: 12.0,),
              Container(
                child: Column(
                  children: [
                    RadioListTile(
                      title: Text("Normal"),
                      value: "nor",
                      groupValue: subtype,
                      onChanged: (val){
                        setState(() {
                          subtype = val;
                        });
                      }
                    ),
                    RadioListTile(
                      title: Text("URL Only"),
                      value: "url",
                      groupValue: subtype,
                      onChanged: (val){
                        setState(() {
                          subtype = val;
                        });
                      }
                    ),
                    RadioListTile(
                      title: Text("Photo Only"),
                      value: "pho",
                      groupValue: subtype,
                      onChanged: (val){
                        setState(() {
                          subtype = val;
                        });
                      }
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.0,),
              titleField(),
              SizedBox(height: 24.0,),
              (subtype != "url") ? imageField() : Container(),
              (subtype == "nor") ? descField() : Container(),
              (subtype != "pho") ? sourceField() : Container(),
              tagsField(),
              answerField(),
              ElevatedButton(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Upload"),
                      SizedBox(width: 8.0,),
                      Container(
                        height: 18,
                        width: 18,
                        child: (isUploading == true)
                          ? CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Icon(Icons.upload,
                            size: 18,
                          ),
                      ),
                      
                    ],
                  )
                ),
                onPressed: () {
                  upload();
                },
              ),
              SizedBox(height: 24.0,),
              validationMessage(),
              SizedBox(height: 42.0,),
            ],
          ),
        ),
      ),
    );
  }

  Widget titleField(){
    return TextField(
      decoration: InputDecoration(
        labelText: "Title",
        border: OutlineInputBorder()
      ),
      textCapitalization: TextCapitalization.words,
      onChanged: (val){
        setState(() {
          title = val;
        });
      },
    );
  }

  Widget imageField(){
    return Column(
      children: [
        Container(
          height: 300,
          child: (uploadedImage != null) ? Image.memory(uploadedImage) : Container(color: Colors.grey,),
        ),
        SizedBox(height: 12.0,),
        OutlinedButton(
          child: Text("Choose image"),
          onPressed: () {
            _startFilePicker();
          },
        ),
        SizedBox(height: 24.0,),
      ],
    );
  }

  Widget descField(){
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Description",
          ),
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          maxLines: null,
          onChanged: (val){
            setState(() {
              description = val;
            });
          },
        ),
        SizedBox(height: 24.0,),
      ],
    );
  }

  Widget sourceField(){
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Source"
          ),
          onChanged: (val){
            setState(() {
              source = val;
            });
          },
        ),
        SizedBox(height: 24.0,),
      ],
    );
  }

  Widget tagsField(){
    return FutureBuilder(
      future: Future<List<dynamic>>(() async {
        var res = await http.get(Uri.parse("http://localhost:3000/api/news/tags"));
        if (res.statusCode == 200) {
          var jsonData = res.body.toString();
          var parsedJson = json.decode(jsonData);

          return parsedJson;
        }
        return null;
      }),
      builder: (context, snapshot){
        if (snapshot.hasData && snapshot.data != null) {
          List<dynamic> data = snapshot.data;

          return Container(
            child: Column(
              children: [
                Text("News artice tags", style: bold18,),
                SizedBox(height: 12.0,),
                Wrap(
                  direction: Axis.horizontal,
                  children: List<Widget>.generate(data.length,
                    (index) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ChoiceChip(
                                label: Text(data[index]["tag"]),
                                selected: selectedTags.contains(data[index]["id"]),
                                onSelected: (selected) {
                                  setState(() {
                                    selectedTags.contains(data[index]["id"])
                                        ? selectedTags.remove(data[index]["id"])
                                        : selectedTags.add(data[index]["id"]);
                                  });
                                },
                              ),
                              SizedBox(height: 8.0,),
                            ],
                          ),
                          SizedBox(width: 8.0,)
                        ],
                      );
                    }
                  ),
                ),
                SizedBox(height: 30.0,),
              ],
            ),
          );
        }
        else{
          return LinearProgressIndicator();
        }
      },
    );
  }

  Widget answerField(){
    return Column(
      children: [
        Divider(
          thickness: 1.0,
        ),
        SizedBox(height: 12.0,),
        Align(
          alignment: Alignment.centerLeft,
          child: Text("Intended answer for news article",
            style: bold18,
          )
        ),
        SizedBox(height: 12.0,),
        RadioListTile(
          title: Text("Legit"),
          value: "legit",
          groupValue: answer,
          onChanged: (val){
            setState(() {
              answer = val;
            });
          }
        ),
        RadioListTile(
          title: Text("Hoax"),
          value: "hoax",
          groupValue: answer,
          onChanged: (val){
            setState(() {
              answer = val;
            });
          }
        ),
        SizedBox(height: 30.0,),
      ],
    );
  }

  upload() async {
    setState(() {
      isUploading = true;
    });

    bool canUpload = true;

    String author = vB.localS.getItem("id");
    print(author);
    print(title);
    print(description);
    print(source);
    String type = "uc";
    print(subtype);
    print(answer);
    String tags = "";
    if(selectedTags.isNotEmpty){
      for (var i = 0; i < selectedTags.length; i++) {
        if (i < selectedTags.length - 1)
          tags += "${selectedTags[i]},";
        else
          tags += "${selectedTags[i]}";
      }
    }
    print(tags);

    if(subtype == "nor"){
      if(author == null || title == null || description == null || source == null || subtype == null || answer == null){
        setState(() {
          errorExists = true;
          uploadSuccesful = false;
          canUpload = false;
        });
      }
    }
    else if(subtype == "url"){
      if(author == null || title == null || source == null || subtype == null || answer == null){
        setState(() {
          errorExists = true;
          uploadSuccesful = false;
          canUpload = false;
        });
      }
    }
    else if(subtype == "pho"){
      if(author == null || title == null || subtype == null || answer == null){
        setState(() {
          errorExists = true;
          uploadSuccesful = false;
          canUpload = false;
        });
      }
    }

    if (canUpload == true) {
      print("Masuk tru");
      // body: {
      //   "author": author,
      //   "title": title,
      //   "content": description,
      //   "source": source,
      //   "type": type,
      //   "subtype": subtype,
      //   "answer": answer,
      //   "tags": tags
      // }
      var req = http.MultipartRequest("POST", Uri.parse("http://localhost:3000/api/news/add"));

      req.fields["author"] = author;
      req.fields["title"] = title;
      req.fields["content"] = description;
      req.fields["source"] = source;
      req.fields["type"] = type;
      req.fields["subtype"] = subtype;
      req.fields["answer"] = answer;
      req.fields["tags"] = tags;

      if(filePicked == true){
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

        var updateNa = await http.post(Uri.parse("http://localhost:3000/api/user/update/stats/na"),
          body: {
            "uid" : vB.currentUser.id
          }
        );

        setState(() {
          errorExists = false;
          uploadSuccesful = true;
        });
      }
      else{
        print("Ga masuk");
      }
    }

    setState(() {
      isUploading = false;
    });
  }

  Widget validationMessage() {
    if (errorExists == true && uploadSuccesful == false) {
      return Container(
        padding: EdgeInsets.all(12.0),
        color: Colors.red[50],
        child: Text(
          "Fields must not be empty!",
          style: TextStyle(
            color: Colors.red[900],
          ),
        ),
      );
    } else if (uploadSuccesful == true && errorExists == false) {
      return Container(
        padding: EdgeInsets.all(12.0),
        color: Colors.green[50],
        child: Text(
          "News article succesfully added!",
          style: TextStyle(
            color: Colors.green[900],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  _startFilePicker() async{
    filePicked = true;
    
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withReadStream: true,
    );
    if(result != null){
      // buat upload
      setState(() {
        uploadedFile = result.files.single;
      });

      // buat display gambar
      tempStream = new http.ByteStream(uploadedFile.readStream);

      streamC.sink.add(await tempStream.last);
      var temp = streamC.stream.value;

      setState(() {
        uploadedImage = temp;
      });

      // testFunction();
    }
  }

  testFunction() async {
    var uri = Uri.parse("http://localhost:3000/api/news/uploadimage"); print("1");

    // var stream = new http.ByteStream(uploadedFile.readStream); print("2");

    var length = uploadedFile.size; print("3");

    var mimeType = lookupMimeType(uploadedFile.name ?? ""); print("4");

    var req = new http.MultipartRequest("POST", uri); print("5");
    var pic = new http.MultipartFile(
      "picture",
      Stream<List<int>>.value(streamC.stream.value),
      length,
      filename: uploadedFile.name,
      contentType: mimeType == null ? null : http_parser.MediaType.parse(mimeType)
    ); print("6");

    req.files.add(pic); print("7");

    final httpClient = http.Client(); print("8");
    var res = await httpClient.send(req); print("9");

    if(res.statusCode != 200){
      throw Exception("HTTP ${res.statusCode}");
    } print("10");

    final body = await res.stream.transform(utf8.decoder).join(); print("11");
    print(body);

    httpClient.close();
    streamC.close();
  }
}