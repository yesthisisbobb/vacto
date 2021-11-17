import 'dart:developer';

import 'package:flutter/material.dart';

import '../blocs/variables_provider.dart';
import '../blocs/login_provider.dart';

class Login extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    VariablesBloc vBloc = VariablesProvider.of(context);
    LoginBloc lBloc = LoginProvider.of(context);
    
    return Scaffold(
      body: loginInputs(context, vBloc, lBloc)
    );
  }

  Widget loginInputs(BuildContext context, VariablesBloc vBloc, LoginBloc lBloc){
    double wf = 0.26, imgWidthP = 0.35;
    if (MediaQuery.of(context).size.width <= 1000) {
      wf = 0.4;
    }
    if (MediaQuery.of(context).size.width <= 700) {
      wf = 0.6;
      imgWidthP = 0.5;
    }
    if (MediaQuery.of(context).size.width <= 500) {
      wf = 0.9;
      imgWidthP = 0.6;
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Container(
            child: Image(
              image: AssetImage("login_page/bg-decor-top-left.png"),
              width: MediaQuery.of(context).size.width * imgWidthP,
            ),
            alignment: Alignment.topLeft,
          ),
          Container(
            child: Image(
              image: AssetImage("login_page/bg-decor-bot-right.png"),
              width: MediaQuery.of(context).size.width * imgWidthP,
            ),
            alignment: Alignment.bottomRight,
          ),
          Center(
            child: FractionallySizedBox(
              widthFactor: wf,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage("vacto_full.png"),
                    width: 300,
                  ),
                  Container(margin: EdgeInsets.only(bottom: 10.0)),
                  emailField(context, vBloc, lBloc),
                  passwordField(context, vBloc, lBloc),
                  errMsgContainer(context, vBloc, lBloc),
                  loginButton(context, vBloc, lBloc),
                  Container(margin: EdgeInsets.only(bottom: 10.0)),
                  registerRedirect(context)
                ],
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget emailField(BuildContext context, VariablesBloc vBloc, LoginBloc lBloc){
    return StreamBuilder(
      stream: lBloc.emailStream,
      builder: (context, snapshot) {
        return Container(
          margin: EdgeInsets.only(
            top: 20.0,
            left: 20.0,
            right: 20.0
          ),
          child: TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "Email",
              hintText: "johndoe@example.com",
              errorText: (snapshot.error != null) ? snapshot.error.toString() : null,
              border: OutlineInputBorder()
            ),
            onChanged: lBloc.changeEmail,
          ),
        );
      });
  }

  Widget passwordField(BuildContext context, VariablesBloc vBloc, LoginBloc lBloc) {
    return StreamBuilder(
      stream: lBloc.passwordStream,
      builder: (context, snapshot){
        return Container(
            margin: EdgeInsets.only(
                top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                hintText: "******",
                errorText: (snapshot.error != null) ? snapshot.error.toString() : null,
                border: OutlineInputBorder(),
              ),
              onChanged: lBloc.changePassword,
            ),
          );
      }
    );
  }

  Widget errMsgContainer(BuildContext context, VariablesBloc vBloc, LoginBloc lBloc){
    return StreamBuilder(
      stream: lBloc.errMsgStream,
      builder: (context, snapshot){
        if (snapshot.hasData) {
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.all(Radius.circular(12.0))
                ),
                padding: EdgeInsets.all(15.0),
                child: Text(snapshot.data,
                  style: TextStyle(
                    color: Colors.red[900],
                    fontSize: 15,
                  ),
                ),
              ),
              SizedBox(height: 12.0,)
            ]
          );
        }
        else{
          return SizedBox();
        }
      }
    );
  }

  Widget loginButton(BuildContext context, VariablesBloc vBloc, LoginBloc lBloc){
    return StreamBuilder(
      stream: lBloc.submitValid,
      builder: (context, snapshot){
        return ElevatedButton(
            child: Text("Login"),
            style: ElevatedButton.styleFrom(
                padding:
                    EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0)),
            onPressed: (){
              if (snapshot.hasData) {
                lBloc.submit(context, vBloc);
              }
            },
          );
      }
    );
  }

  Widget registerRedirect(BuildContext context){
    return Container(
      child: Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text("Don't have an account? ", textAlign: TextAlign.center,),
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/register");
              },
              child: Text("Register here")),
        ],
      ),
    );
  }
}