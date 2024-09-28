import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/main.dart';

class EventPaymentPage extends StatefulWidget {
  @override
  _EventPaymentPageState createState() => _EventPaymentPageState();

}

class _EventPaymentPageState extends State<EventPaymentPage> {
  var token = "";
  var selectedStudent;
  var appState;
  final _formKey = GlobalKey<FormState>();


@override
  void initState() {
    appState = context.read<MyAppState>();
    selectedStudent = appState.selectedStudent;
    token = appState.appToken;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
      title: Text('Payment'),
      ),
      body: SingleChildScrollView(
        child: Padding(padding: 
        EdgeInsets.all(20),
        key: Key(selectedStudent.id.toString()),
        child: Form(
          key: _formKey,
          child: Column(
            children: [ 
              Row(children: [
                Text('Información del alumno', 
                style: TextStyle(fontSize: 20.0, color: Colors.blue)),
            ],)
          ],))
      ),
    ));
  }
}