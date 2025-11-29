

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/Employee.dart';
import 'package:rg_event_management_ui/models/RgEmployeePayment.dart';
import 'package:rg_event_management_ui/services/employees_service.dart';
class GeneralNominalPage extends StatefulWidget {

  @override
  _GeneralNominalPage createState() => _GeneralNominalPage();
}

class _GeneralNominalPage extends State<GeneralNominalPage> {
  var appState;
  final _formKey = GlobalKey<FormState>();
  var token = "";

  List<Widget> rgEmployeePaymentsWidgets = [];
  List<Employee> employees = [];
  List<RgEmployeePayment> rgEmployeePayments = [];
  List<TextEditingController> salaryControllers = [];
  List<TextEditingController> compensationControllers   = [];

  @override
  /// Called when the widget is inserted into the tree.
  ///
  /// This method obtains the employees list from the server and stores
  /// them in the [employees] list.
  void initState() {
    appState = context.read<MyAppState>();
    token = appState.appToken;

    EmployeesService().getAllEmployees(token).then((value) {
      setState(() {
        employees = value;
        log('Employees: ${employees.length}');
      });
    });

    EmployeesService().getRgEmployeePayments(token).then((value) {
      setState(() {
        rgEmployeePayments = value;
        log(
           'RG Employee Payments: ${rgEmployeePayments.length}');
      });
    });

    addNominaWidgets();

    super.initState();
  } 

  void addNominaWidgets() {
    rgEmployeePaymentsWidgets = [];
    for (var i = 0; i < rgEmployeePayments.length; i++) {
      rgEmployeePaymentsWidgets.add(addNominaWidget(rgEmployeePayments[i].paymentReason, rgEmployeePayments[i]));
    }
  }

  Widget addNominaWidget(String paymentReason, RgEmployeePayment rgEmployeePayment) {
    var salaryController = TextEditingController(text: rgEmployeePayment.amount.toString());

    salaryControllers.add(salaryController);

    return Card(
      child: ListTile(
        title: Text('Tipo de pago: $paymentReason'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: salaryController,
              decoration: InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
        appState = context.watch<MyAppState>();
    return Scaffold(
      appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Text(
            'Sistema RG Eventos - Usuario conectado: ${appState.selectedUser != null ? '${appState.selectedUser!.name} ${appState.selectedUser!.lastname} con rol de ${appState.selectedUser!.role == 1 ? 'admin' : (appState.selectedUser!.role == 2 ? 'operativo' : 'solo lectura')}' : ''}',
            style: TextStyle(
                fontSize: 28.0, color: const Color.fromARGB(255, 113, 7, 132))),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 22,
            ),
            Row(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () {
                    log('Generar Nomina');
                  },
                  child: Text(
                    'Generar Nomina General',
                    style: TextStyle(fontSize: 20.0, color: Colors.black),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () {
                    log('Generar Nomina por Evento');
                  },
                  child: Text(
                    'Generar Pago de comisiones',
                    style: TextStyle(fontSize: 20.0, color: Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 22,
            ),
            Row(
              children: [

              ],
            ),
          ],
        )
      ,)
    );
  }  
}