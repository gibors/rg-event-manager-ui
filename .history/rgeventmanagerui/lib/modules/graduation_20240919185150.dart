

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rg_event_management_ui/login.dart';
import 'package:rg_event_management_ui/main.dart';

class GraduationPage extends StatefulWidget {
  @override
  _GraduationState createState() => _GraduationState();

}

class _GraduationState extends State<GraduationPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

        var appState = context.read<MyAppState>();
    if (appState.token == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Graduacion'),  
      ),
      body: Center(
        child: Text('Graduation'),
      ),
    );
  }
}