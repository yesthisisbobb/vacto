import 'package:flutter/material.dart';
import 'register_bloc.dart';
export 'register_bloc.dart';

class RegisterProvider extends InheritedWidget {
  RegisterBloc bloc;

  RegisterProvider({Key key, Widget child})
      : bloc = RegisterBloc(),
        super(child: child);

  @override
  bool updateShouldNotify(_) => true;

  static RegisterBloc of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<RegisterProvider>()
            as RegisterProvider)
        .bloc;
  }
}
