
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/Student.dart';

class GraduationListPage extends StatefulWidget {
  @override
  _GraduationListPageState createState() => _GraduationListPageState();

}

class _GraduationListPageState extends State<GraduationListPage> {
  late Future<List<Student>> _func;

  @override
  void initState() {
    
    var appState = context.read<MyAppState>();
    var token = appState.appToken;

    log('Token: $token');

    super.initState();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Graduación'),  
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
          ]

      ),
    ),
    );
  }
}