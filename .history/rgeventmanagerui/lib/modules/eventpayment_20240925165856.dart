import 'dart:developer';
import 'dart:ffi';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/Student.dart';
import 'package:rg_event_management_ui/services/eventservice.dart';
import 'dart:ui' as ui;

class EventPaymentPage extends StatefulWidget {
  @override
  _EventPaymentPageState createState() => _EventPaymentPageState();

}

class _EventPaymentPageState extends State<EventPaymentPage> {
  bool isEditMode = false;
  bool isGraduation = false;
  bool isNewStudent = false;
  var token = "";
  var selectedStudent;
  var selectedEvent;
  var appState;
  
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _packageTypeKey = GlobalKey();
  final GlobalKey _paymentMethodKey = GlobalKey();
  final FocusNode _packageTypeFocus = FocusNode();
  final FocusNode _paymentMethodFocus = FocusNode();
  var _studentName = TextEditingController();
  var _studentLastName = TextEditingController();
  var _packageType = TextEditingController();
  var _paymentMethodController = TextEditingController();
  var _additionCost = TextEditingController();
  var _comment = TextEditingController();
  var _paymentAmount = TextEditingController();
  var _paymentMethod = TextEditingController();
  
  List<Payment> paymentsHistory = [];

  List<String> packageTypes = [
    'paq10ti',
    'paq10sp',
    'paq5ti',
    'paq5sp',
    'paq20'
  ];

  List<String> paymentMethods = [
    'Efectivo',
    'Tarjeta',
    'Transferencia'
  ];

@override
  void initState() {
    appState = context.read<MyAppState>();
    selectedStudent = appState.selectedStudent;
    selectedEvent = appState.selectedEvent;
    token = appState.appToken;

    if(selectedEvent != null && selectedEvent!.eventType.id == 3) {
      isGraduation = true;

      if(selectedStudent == null) {
        isNewStudent = true;
        isEditMode = true;
      } else {
        mapSelectedStudent();
        isNewStudent = false;
      }
    }
    super.initState();
  }

  mapSelectedStudent() {
    _studentName.text = selectedStudent!.name;
    _studentLastName.text = selectedStudent!.lastName;
    _packageType.text = selectedStudent!.packageType;
    _additionCost.text = selectedStudent!.additionalQuantity.toString();
    _comment.text = selectedStudent!.comments;
    paymentsHistory = selectedStudent!.payments;
  }

  double calculateCost(packageType) {
    var packageCost = 0.0;
    switch(packageType){
      case 'paq10ti':
        packageCost = selectedEvent.pricing!.paq10TICost;
      case 'paq10sp':
        packageCost = selectedEvent.pricing!.paq10SPCost;
      case 'paq5ti':
        packageCost = selectedEvent.pricing!.paq5TIPCost;
      case 'paq5sp':
        packageCost = selectedEvent.pricing!.paq5SPCost;
      case 'paq20':
        packageCost = selectedEvent.pricing!.paq10DoubleCost;
      default:
        packageCost = 0.0;
    }
    var additionalCost = double.parse(_additionCost.text.isEmpty ? '0' : _additionCost.text);
    return packageCost + additionalCost;
  }

  saveStudentData() {
    if(isGraduation) {

    var student = Student(
      id: selectedStudent!= null  ? selectedStudent!.id : -1,
      name: _studentName.text,
      lastName: _studentLastName.text,
      packageType: _packageType.text,
      age: 0,
      email: '',
      phone: '',
      additionalQuantity: double.parse(_additionCost.text.isEmpty ? '0' : _additionCost.text),
      totalCost: calculateCost(_packageType.text),
      eventId: appState.selectedEvent.id,
      comments: _comment.text,
      payments: selectedStudent != null ? selectedStudent!.payments : []
      
    );
   
    EventService().saveStudent(student, token).then((studentResponse) {
      if (studentResponse != null && studentResponse!.id != null && studentResponse.id != -1 ) {
        setState(() {
          selectedStudent = studentResponse;
        });
        isEditMode = false;
        isNewStudent = false;
        mapSelectedStudent();
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar el alumno')));
      }
    });

    } 
    
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
              Visibility(
                visible: isGraduation,
                child: 
              Column( 
                children: [
                  Row(children: [
                Text('Información del alumno', 
                style: TextStyle(fontSize: 20.0, color: Colors.blue)),
            ],),
            SizedBox(height: 20),
            Row(children: [
              Expanded(child: TextFormField(
                controller: _studentName,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]'))
                ],
                decoration: InputDecoration(
                  labelText: 'Nombre del alumno',
                  border: OutlineInputBorder()
                ),
                readOnly: !isEditMode,
              )),
              SizedBox(width: 20),
              Expanded(child: TextFormField(
                controller: _studentLastName,
                decoration: InputDecoration(
                  labelText: 'Apellido del alumno',
                  border: OutlineInputBorder()
                ),
                readOnly: !isEditMode,
              )),
              SizedBox(width: 20),
              Expanded(child: RawAutocomplete<String>(
                key: _packageTypeKey,
                focusNode: _packageTypeFocus,
                textEditingController: _packageType,
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
                    readOnly: !isEditMode,
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
                    border: OutlineInputBorder(),
                  ),
                  readOnly: !isEditMode,
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
                  readOnly: !isEditMode,
                )),
              ],),
              SizedBox(height: 30),
                 Row(children: [
                  Visibility(
                visible: isGraduation && isEditMode,
                child:
                ElevatedButton(
                      onPressed: () {
                        log('save student data');
                        saveStudentData();
                      },
                      child: Text('Guardar alumno'),
                    ),),
                    SizedBox(width: 20),
                    Visibility(
                      visible: isGraduation && !isNewStudent,
                      child: OutlinedButton(
                      onPressed: () {
                      setState(() {
                        isEditMode = !isEditMode;
                      });
                      },
                      child: Text(isEditMode ? 'Cancelar' : 'Editar alumno'),
                    )),
                    
              ],),
                ],
              ),),
              SizedBox(height: 30),
               Visibility(
                visible: selectedStudent != null || !isGraduation,
                child:  Column(
                  children:  [
              Row(children: [
                Text('Historial de pagos', 
                style: TextStyle(fontSize: 20.0, color: Colors.blue)),
              ],),
              SizedBox(height: 20),
              Column(children: paymentsHistory.length > 0 ? paymentsHistory.map((payment) => Column(children: [
              Row(children: [
                Expanded(child:
                TextFormField(
                  controller: TextEditingController(text: payment.amount.toString()),
                  decoration: InputDecoration(
                    labelText: 'Monto del pago',
                    border: OutlineInputBorder()
                  ),
                  readOnly: true,
                  ),
                  
                ),
                SizedBox(width: 20),
                Expanded(
                  child: TextFormField(
                  controller: TextEditingController(text: payment.paymentMethod),
                  decoration: InputDecoration(
                    labelText: 'Método de pago',
                    border: OutlineInputBorder()
                  ),
                  readOnly: true,
                ),),
                SizedBox(width: 20),
                Expanded(
                  child: TextFormField(
                  controller: TextEditingController(text: DateFormat('dd/MM/yyyy').format(DateTime.parse(payment.paymentDate))),
                  decoration: InputDecoration(
                    labelText: 'Fecha de pago',
                    border: OutlineInputBorder()
                  ),
                  readOnly: true,
                ),),
                SizedBox(width: 20),
              ],),])).toList() : [ Text('No hay pagos actualmente')],),
                  ]),
              ),
              SizedBox(height: 30),
              Visibility(
                visible: selectedStudent != null || !isGraduation,
                child:
              Column (
                children:  [
            Row(children: [
                Text('Pagos', 
                style: TextStyle(fontSize: 20.0, color: Colors.blue)),
            ],),
            SizedBox(height: 20),
            Column(children: [
            Row(children: [
                Expanded(child: TextFormField(
                  controller: _paymentAmount,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'))                  ],
                  decoration: InputDecoration(
                    labelText: 'Monto del pago',
                    border: OutlineInputBorder()
                  ),
                  
                )),
                SizedBox(width: 20),
                Expanded(child: RawAutocomplete<String>(
                key: _paymentMethodKey,
                focusNode: _paymentMethodFocus,
                textEditingController: _paymentMethodController,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return paymentMethods.where((String option) {
                    return option.contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  _paymentMethodController.text = selection;
                },
                fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: _paymentMethodFocus,
                    readOnly: false,
                    decoration: InputDecoration(
                      labelText: 'Método de pago',
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
              ],),]),
                ]),),
              SizedBox(height: 20),
              Row( 
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    // ignore: deprecated_member_use
                    fixedSize: MaterialStateProperty.resolveWith((states) => )
                  ),
                  onPressed: () {
                   if(selectedStudent != null) {
                     var payment = Payment(
                      id: -1,
                       amount: double.parse(_paymentAmount.text),
                       paymentMethod: _paymentMethod.text,
                       paymentDate: DateTime.now().toString(),
                       studentId: selectedStudent!.id ?? null,
                        eventId: selectedEvent!.id
                     );
                     setState(() {
                       paymentsHistory.add(payment);
                     });
                   }
                  },
                  child: Text('Guardar')
                ),
                SizedBox(width: 20),
              
              ],)
            // ],
          ],))
      ),
    ));
  }
}