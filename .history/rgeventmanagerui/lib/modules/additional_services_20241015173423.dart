import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/app_colors.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/Employee.dart';
import 'package:rg_event_management_ui/modules/employees_list.dart';
import 'package:rg_event_management_ui/services/employees_service.dart';

class AdditionalServices extends StatefulWidget {
  @override
  _AdditionalServices createState() => _AdditionalServices();
}

class _AdditionalServices extends State<AdditionalServices> {
  var appState;
  final _formKey = GlobalKey<FormState>();
  var token = "";
  static String _displayStringServicesForOption(String option) => option;
  final _autocompleteJobKey = GlobalKey();
  final _focusJobPositionNode = FocusNode();
  final _textEditingJobPositionController = TextEditingController();
  List<String> jobPositions = [
    'Administrativo',
    'Staff',
    'Practicante',
    'Ventas',
    'Operativo',
  ];

  final _textNameController = TextEditingController();
  final _textLastNameController = TextEditingController();
  final _textLastName2Controller = TextEditingController();
  final _textEmailController = TextEditingController();
  final _textPhoneController = TextEditingController();
  // final _textJobPositionController = TextEditingController();

  @override
  void initState() {
    appState = context.read<MyAppState>();
    token = appState.appToken;
    // if (appState.selectedEmployee != null) {
      // mapEmployeeToForm(appState.selectedEmployee!);
    // }
    super.initState();
  }
  

  @override
  Widget build(BuildContext context) {
    var appState = context.read<MyAppState>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => {
                  appState.setIndex(1),
                  Navigator.of(context).pop(),
                },
            icon: Icon(Icons.arrow_back, color: AppColors.pinkColor)),
        title: Text(
            appState.selectedEmployee == null
                ? 'Agregar empleado'
                : 'Editar empleado',
            style: TextStyle(fontSize: 24.0, color: AppColors.pinkColor)),
      ),
      body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text('Información del empleado',
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.brown)),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  AppColors.pinkColor),
                              foregroundColor:
                                  WidgetStateProperty.all<Color>(Colors.white),
                              fixedSize:
                                  WidgetStateProperty.all<Size>(Size(180, 100)),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Procesando datos')));
                                // saveNewEmployee();
                              }
                            },
                            child: Text('Guardar'),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  AppColors.pinkColor),
                              foregroundColor:
                                  WidgetStateProperty.all<Color>(Colors.white),
                              fixedSize:
                                  WidgetStateProperty.all<Size>(Size(180, 100)),
                            ),
                            onPressed: () {
                             showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Cancelar'),
                                    content: Text(
                                        '¿Estás seguro de que deseas cancelar?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          appState.clearSelectedEmployee();
                                          appState.setIndex(2);
                                          Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EventsHomePage()));
                                        },
                                        child: Text('Sí'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text('Cancelar'),
                          ),
                        ],
                      ),
                    ],
                  )))),
    );
  }
}