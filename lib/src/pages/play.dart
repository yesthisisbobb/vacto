import 'package:flutter/material.dart';

import '../blocs/variables_provider.dart';

class Play extends StatelessWidget {
  const Play({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    VariablesBloc vBloc = VariablesProvider.of(context);

    return Scaffold(
      body: Container(
        child: Text("asd"),
      ),
    );
  }
}