import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/main.dart';

class EventPaymentPage extends StatefulWidget {
  @override
  _EventPaymentPageState createState() => _EventPaymentPageState();

}

class _EventPaymentPageState extends State<EventPaymentPage> {
  bool isEditMode = false;
  bool isGraduation = false;
  var token = "";
  var selectedStudent;
  var appState;
  final _formKey = GlobalKey<FormState>();
  var _studentName = TextEditingController();
  var _studentLastName = TextEditingController();
  var _packageType = TextEditingController();
  var _additionCost = TextEditingController();
  var _comment = TextEditingController();
  var _paymentAmount = TextEditingController();
  

  List<String> packageTypes = [
    'paq10ti',
    'paq10sp',
    'paq5ti',
    'paq5sp',
    'paq20'
  ];

@override
  void initState() {
    appState = context.read<MyAppState>();
    selectedStudent = appState.selectedStudent;
    token = appState.appToken;
    if (selectedStudent != null) {
      isEditMode = true;
      mapSelectedStudent();
    }
    if(appState.selectedEvent != null && appState.selectedEvent!.id == 3) {
      isGraduation = true;
    }
    log('isGraduation: $isGraduation');
    super.initState();
  }

  mapSelectedStudent() {
    _studentName.text = selectedStudent!.name;
    _studentLastName.text = selectedStudent!.lastName;
    // _packateType.text = selectedStudent!.packageType;
    // _paymentAmount.text = selectedStudent!.paymentAmount;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
      title: Text( isEditMode ? (isGraduation ? 'Editar alumno / agregar pago' : 'Agregar pago') : (isGraduation ?'Agregar alumno':'Agregar pago'),
      )),
      body: SingleChildScrollView(
        child: Padding(padding: 
        EdgeInsets.all(20),
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
              SizedBox(width: 20),
              Expanded(child: RawAutocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return packageTypes.where((String option) {
                    return option.contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  _packageType.text = selection;
                },
                fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: 'Tipo de paquete',
                      border: OutlineInputBorder()
                    ),
                  );
                }, 
                optionsViewBuilder: (BuildContext context, void Function(String) onSelected, Iterable<String> options) { 
                  return Material(
                    child: ListView(
                      children: options.map((String option) => ListTile(
                        title: Text(option),
                        onTap: () {
                          onSelected(option);
                        },
                      )).toList(),
                    ),
                  );
                 },
              )),

            ],),
            SizedBox(height: 20),
            Row(children: [
                Expanded(child: TextFormField(
                  controller: _additionCost,
                  decoration: InputDecoration(
                    labelText: 'Costo Adicional',
                    border: OutlineInputBorder()
                  ),
                  
                )),
                SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                  controller: _comment,
                  decoration: InputDecoration(
                    labelText: 'Comentarios',
                    border: OutlineInputBorder()
                  ),
                  
                )),
              ],),
              SizedBox(height: 30),
              Row(children: [
                Text('Historial de pagos', 
                style: TextStyle(fontSize: 20.0, color: Colors.blue)),
              ],),
              SizedBox(height: 20),
              Row(children: [
                Expanded(child:
                TextFormField(
                  controller: _paymentAmount,
                  decoration: InputDecoration(
                    labelText: 'Monto del pago',
                    border: OutlineInputBorder()
                  )),
                  
                ),
                SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                  controller: _comment,
                  decoration: InputDecoration(
                    labelText: 'Comentarios',
                    border: OutlineInputBorder()
                  ),
                  
                )),
              ],),
              SizedBox(height: 30),
            Row(children: [
                Text('Pagos', 
                style: TextStyle(fontSize: 20.0, color: Colors.blue)),
            ],),
            SizedBox(height: 20),
            Row(children: [
                Expanded(child: TextFormField(
                  controller: _paymentAmount,
                  decoration: InputDecoration(
                    labelText: 'Monto del pago',
                    border: OutlineInputBorder()
                  ),
                  
                )),
                SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                  controller: _comment,
                  decoration: InputDecoration(
                    labelText: 'Comentarios',
                    border: OutlineInputBorder()
                  ),
                  
                )),
              ],),
              SizedBox(height: 20),
              Row( children: [ OutlinedButton(
                      onPressed: () {
                        // Navigator.pushNamed(context, '/addcontact');
                      },
                      child: Text('Agregar pago'),
                    ),
                ],
              ),
              SizedBox(height: 20),
              Row( 
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (isEditMode) {
                        // updateStudent();
                      } else {
                        // createStudent();
                      }
                    }
                  },
                  child: Text('Guardar')
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancelar')
                ),
              ],)
            // ],
          ],))
      ),
    ));
  }
}