import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

import 'package:vacto/src/mixins/validation.dart';

import 'dart:async';

class LoginBloc with Validation{
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _errMsgController = BehaviorSubject<String>();

  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;

  errMsgFound(String msg){
    _errMsgController.sink.add(msg);
  }

  Stream<String> get emailStream => _emailController.stream.transform(validateEmail);
  Stream<String> get passwordStream => _passwordController.stream.transform(validatePassword);
  Stream<String> get errMsgStream => _errMsgController.stream;

  Stream<bool> get submitValid => CombineLatestStream.combine2(_emailController, _passwordController, (a, b) => true);

  submit() async{
    final email = _emailController.value;
    final password = _passwordController.value;
    
    var res = await http.post(Uri.parse("http://localhost:3000/api/user-login"),
      body: {
        "email": email,
        "password": password
      },
    );

    print("Status: ${res.statusCode} | Body: ${res.body.toString()}");
    if (res.statusCode == 404) {
      errMsgFound(res.body.toString());
    }
    else if(res.statusCode == 200){
      print("rite");
    }
  }

  dispose(){
    _emailController.close();
    _passwordController.close();
    _errMsgController.close();
  }
}