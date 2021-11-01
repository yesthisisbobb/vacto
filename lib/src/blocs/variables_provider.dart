import 'package:flutter/material.dart';
import 'variables_bloc.dart';
export 'variables_bloc.dart';

class VariablesProvider extends InheritedWidget{
  VariablesBloc bloc;

  VariablesProvider({Key key, Widget child}): bloc = VariablesBloc(), super(child: child);

  @override
  bool updateShouldNotify(_) => true;

  static VariablesBloc of (BuildContext context){
    return (context.dependOnInheritedWidgetOfExactType<VariablesProvider>() as VariablesProvider).bloc;
  }
}