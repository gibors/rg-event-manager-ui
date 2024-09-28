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
  var _studentName = TextEditingController();
  var _studentLastName = TextEditingController();
  var _packateType = TextEditingController();
  var _paymentAmount = TextEditingController();

@override
  void initState() {
    appState = context.read<MyAppState>();
    selectedStudent = appState.selectedStudent;
    token = appState.appToken;
    if (selectedStudent == null) {
      mapSelectedStudent();
    }
    super.initState();
  }

  mapSelectedStudent() {
    _studentName.text = selectedStudent.name;
    _studentLastName.text = selectedStudent.lastName;
    _packateType.text = selectedStudent.packageType;
    _paymentAmount.text = selectedStudent.paymentAmount;
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
            ],),
            SizedBox(height: 20),
            Row(children: [
              Expanded(child: TextFormField(
                controller: _studentName,
                decoration: InputDecoration(
                  labelText: 'Nombre del alumno',
                  border: OutlineInputBorder()
                ),
                readOnly: true,
              )),
              SizedBox(width: 20),
              Expanded(child: TextFormField(
                controller: _studentLastName,
                decoration: InputDecoration(
                  labelText: 'Apellido del alumno',
                  border: OutlineInputBorder()
                ),
                readOnly: true,
              )),
            ],),
            
          ],))
      ),
    ));
  }
}