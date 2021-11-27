import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

import 'dart:async';

import 'package:vacto/src/mixins/validation.dart';

class RegisterBloc with Validation{
  final _usernameController = BehaviorSubject<String>();
  final _nameController = BehaviorSubject<String>();
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _cpasswordController = BehaviorSubject<String>();
  final _dobController = BehaviorSubject<String>();
  final _extrasController = BehaviorSubject<String>();

  final _errorController = BehaviorSubject<String>();

  Function(String) get changeUsername => _usernameController.sink.add;
  Function(String) get changeName => _nameController.sink.add;
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePass => _passwordController.sink.add;
  Function(String) get changeCpass => _cpasswordController.sink.add;
  Function(String) get changeDob => _dobController.sink.add;
  Function(String) get addExtras => _extrasController.sink.add;
  
  Function(String) get addError => _errorController.sink.add;

  Stream<String> get usernameStream => _usernameController.stream.transform(validateUsername);
  Stream<String> get nameStream => _nameController.stream.transform(validateName);
  Stream<String> get emailStream => _emailController.stream.transform(validateEmail);
  // TODO: Sync what's typed between pass and cpass
  Stream<String> get passwordStream => _passwordController.stream.transform(validatePassword);
  Stream<String> get cpasswordStream => _cpasswordController.stream.transform(StreamTransformer<String, String>.fromHandlers(
    handleData: (cpass, sink){
      if(cpass != _passwordController.value){
        sink.addError("Value doesn't match with password");
      }
      else{
        sink.add(cpass);
      }
    }
  ));
  Stream<String> get dobStream => _dobController.stream.transform(StreamTransformer<String, String>.fromHandlers(
    handleData: (dob, sink) {
      if (dob != _dobController.value) {
        sink.addError("This field cannot be empty");
      } else {
        sink.add(dob);
      }
    })
  );
  Stream<String> get extrasStream => _extrasController.stream;

  Stream<String> get errorStream => _errorController.stream;

  submit(BuildContext context) async{
    String username = (_usernameController.hasValue) ? _usernameController.value : "";
    // print("here?");
    String name = (_nameController.hasValue) ? _nameController.value : "";
    // print("here?2");
    String email = (_emailController.hasValue) ? _emailController.value : "";
    // print("here?3");
    String pass = (_passwordController.hasValue) ? _passwordController.value : "";
    // print("here?4");
    String cpass = (_cpasswordController.hasValue) ? _cpasswordController.value : "";
    // print("here?5");
    String dob = (_dobController.hasValue) ? _dobController.value : "";
    // NOTE: i thought giving dob a streamcontroller would help with error message. it didn't and i coded a shitton for this so fuck it
    // print("here?6");
    String nationality, gender, role;

    String extrasData = "";
    if(_extrasController.value != ""){
      // Urutan: Nationality|gender(m,f,n)|role(n,d)
      extrasData = _extrasController.value;

      // print(name);
      // print(email);
      // print(pass);
      // print(cpass);
      // print(dob);
      // print(extrasData);

      List<String> extrasSplit = extrasData.split("|");
      nationality = extrasSplit[0];
      gender = extrasSplit[1];
      role = extrasSplit[2];

      if (username == "" || name == "" || email == "" || pass == "" || cpass == "" || dob == "" || nationality == "" || gender == "" || role == "") {
        addError("One or more field is empty / has an error");
      }
      else{
        var res = await http.post(
          Uri.parse("http://localhost:3000/api/user/register"),
          body: {
            "username": username.trim(),
            "password": pass.trim(),
            "email": email.trim(),
            "name": name.trim(),
            "nationality": nationality,
            "dob": dob,
            "gender": gender,
            "role": role,
          },
        );

        print("Status: ${res.statusCode} | Body: ${res.body.toString()}");
        if (res.statusCode == 400) {
          addError(res.body.toString());
        } else if (res.statusCode == 200) {
          Navigator.pushNamed(context, "/register/success");
        }
      }
    }
  }

  dispose(){
    _usernameController.close();
    _nameController.close();
    _emailController.close();
    _passwordController.close();
    _cpasswordController.close();
    _dobController.close();
    _extrasController.close();
    _errorController.close();
  }
}