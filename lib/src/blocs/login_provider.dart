import 'package:flutter/material.dart';
import 'login_bloc.dart';
export 'login_bloc.dart';

class LoginProvider extends InheritedWidget {
  LoginBloc bloc;

  LoginProvider({Key key, Widget child})
      : bloc = LoginBloc(),
        super(child: child);

  @override
  bool updateShouldNotify(_) => true;

  static LoginBloc of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<LoginProvider>()
            as LoginProvider)
        .bloc;
  }
}
