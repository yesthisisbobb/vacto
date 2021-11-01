import 'package:flutter/material.dart';

class Login extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loginInputs(context)
    );
  }

  Widget loginInputs(BuildContext context){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.26,
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
                  usernameField(context),
                  passwordField(context),
                  loginButton(context),
                  Container(margin: EdgeInsets.only(bottom: 10.0)),
                  registerRedirect(context)
                ],
              ),
            ),
          ),
          Container(
            child: Image(
              image: AssetImage("login_page/bg-decor-top-left.png"),
              width: MediaQuery.of(context).size.width * 0.35,
            ),
            alignment: Alignment.topLeft,
          ),
          Container(
              child: Image(
                image: AssetImage("login_page/bg-decor-bot-right.png"),
                width: MediaQuery.of(context).size.width * 0.35,
              ),
              alignment: Alignment.bottomRight,
            )
        ],
      )
    );
  }

  Widget usernameField(BuildContext context){
    return Container(
        margin: EdgeInsets.only(
          top: 20.0,
          left: 20.0,
          right: 20.0
        ),
        child: TextField(
        decoration: InputDecoration(
          labelText: "Username",
          border: OutlineInputBorder()
        ),
      ),
    );
  }

  Widget passwordField(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 20.0,
        left: 20.0,
        right: 20.0,
        bottom: 20.0
      ),
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
          labelText: "Password",
          border: OutlineInputBorder()
        ),
      ),
    );
  }

  Widget loginButton(BuildContext context){
    return ElevatedButton(
      child: Text("Login"),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0)
      ),
      onPressed: () {
        
      },
    );
  }

  Widget registerRedirect(BuildContext context){
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Don't have an account? "),
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