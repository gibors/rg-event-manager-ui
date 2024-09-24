import 'package:flutter/material.dart';

class EventPaymentPage extends StatefulWidget {
  @override
  _EventPaymentPageState createState() => _EventPaymentPageState();

}

class _EventPaymentPageState extends State<EventPaymentPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pago de Evento'),
      ),
      body: Center(
        child: Text('Página de Pago de Evento'),
      ),
    );
  }
}