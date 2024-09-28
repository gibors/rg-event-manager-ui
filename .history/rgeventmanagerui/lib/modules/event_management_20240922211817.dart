

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rg_event_management_ui/main.dart';

class EventHandlerPage extends StatefulWidget {
  @override
  _EventHandlerState createState() => _EventHandlerState();

}

class _EventHandlerState extends State<EventHandlerPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var appState = context.read<MyAppState>();
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