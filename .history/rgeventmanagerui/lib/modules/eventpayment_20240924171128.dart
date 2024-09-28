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
      title: Text(selectedStudent != null + 'Editar Alumno y Pago' : 'Pago de Evento'),
      ),
      body: Center(
        child: Text('Página de Pago de Evento'),
      ),
    );
  }
}