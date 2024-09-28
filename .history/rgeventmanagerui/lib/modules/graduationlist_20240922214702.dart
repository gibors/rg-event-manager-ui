
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/Student.dart';
import 'package:rg_event_management_ui/services/eventservice.dart';

class GraduationListPage extends StatefulWidget {
  @override
  _GraduationListPageState createState() => _GraduationListPageState();

}

class _GraduationListPageState extends State<GraduationListPage> {
  late Future<List<Student>> _func;
  final controller = ScrollController();
  double offset = 0;
  @override
  void initState() {
    
    var appState = context.read<MyAppState>();
    var token = appState.appToken;
    var selectedEvent = appState.selectedEvent;


    _func = EventService().getStudentsByEvent(token, selectedEvent!.id);
    controller.addListener(onScroll);

    super.initState();
    }

        @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onScroll() {
    setState(() {
      offset = (controller.hasClients) ? controller.offset : 0;
    });
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