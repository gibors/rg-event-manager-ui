
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/main.dart';

class GraduationListPage extends StatefulWidget {
  @override
  _EventHandlerState createState() => _EventHandlerState();

}

class _EventHandlerState extends State<GraduationListPage> {

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