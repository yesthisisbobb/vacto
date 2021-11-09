import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

import 'package:image_picker_web/image_picker_web.dart';

import '../blocs/variables_provider.dart';

class AddNews extends StatefulWidget {
  AddNews({Key key}) : super(key: key);

  @override
  _AddNewsState createState() => _AddNewsState();
}

class _AddNewsState extends State<AddNews> {
  VariablesBloc vB;
  TextStyle bold18 = TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

  String title;
  // TextEditingController titleC;
  String description;
  // TextEditingController descriptionC;
  String source;
  // TextEditingController sourceC;

  String subtype = "nor";
  String answer = "legit";

  var fileBytes;
  Uint8List uploadedImage;
  html.File uploadedFile;

  List<int> selectedTags = [];

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
  Widget build(BuildContext context) {
    vB = VariablesProvider.of(context);

    return Container(
      child: Center(
        child: FractionallySizedBox(
          heightFactor: 0.97,
          widthFactor: 0.7,
          child: Container(
            child: Card(
              child: Container(
                padding: EdgeInsets.all(40.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Add News",
                                style: TextStyle(
                                    fontSize: 30.0, fontWeight: FontWeight.bold)),
                            Text(
                              "Add your own news article for others to guess!",
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.0,),
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
            ),
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
          onPressed: () {},
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

    if(author == null || title == null || description == null || description == null || source == null || subtype == null || answer == null){
      setState(() {
        errorExists = true;
        uploadSuccesful = false;
      });
    }
    else{
      print("Masuk tru");
      var res = await http
          .post(Uri.parse("http://localhost:3000/api/news/add"), body: {
        "author": author,
        "title": title,
        "content": description,
        "source": source,
        "type": type,
        "subtype": subtype,
        "answer": answer,
        "tags": tags
      });

      if (res.statusCode == 200) {
        print(res.body.toString());

        setState(() {
          errorExists = false;
          uploadSuccesful = true;
        });
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

  // _startFilePicker() async{
    // html.InputElement uploadInput = html.FileUploadInputElement();
    // uploadInput.click();

    // uploadInput.onChange.listen((event) {
    //   final files = uploadInput.files;
    //   if (files.length == 1) {
    //     File file = files[0];
    //     setState(() => uploadedFile = file );
    //     html.FileReader reader = html.FileReader();

    //     reader.onLoadEnd.listen((event) {
    //       setState(() {
    //         uploadedImage = reader.result;
    //       });
    //     });

    //     reader.onError.listen((event) {
    //       setState(() {
    //         //error
    //       });
    //     });
        
    //     reader.readAsArrayBuffer(file);
    //   }
    // });

    // var image = await ImagePickerWeb.getImage(outputType: ImageType.file);
    // if(image != null){
    //   setState(() {
    //     uploadedFile = image;
    //   });
    // }
  // }

//   _uploadImage() async {
//     var req = http.MultipartRequest("POST", Uri.parse("http://localhost:3000/api/news/add"));
//     print("1");
//     req.fields["title"] = title;
//     print("2 - $title");
    
//     var pic = await http.MultipartFile.fromPath("picture", uploadedFile.relativePath); // INI GAGAL, ubah ke file
//     print(pic);
//     print("3");
//     req.files.add(pic);
//     print("4");

//     var res = await req.send();
//     print("5");
//     var resData = await res.stream.toBytes();
//     print("6");
//     var resString = String.fromCharCodes(resData);
//     print("7");

//     print(resString);
//   }
}