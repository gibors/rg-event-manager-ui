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
  
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.read<MyAppState>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => {
                  appState.clearSelectedEmployee(),
                  appState.setIndex(2),
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => EventsHomePage()))
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
                          Expanded(
                              child: TextFormField(
                            controller: _textNameController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-z A-Z]'))
                            ],
                            decoration: InputDecoration(
                                labelText: 'Nombre',
                                border: OutlineInputBorder()),
                            validator: (value) => value!.isEmpty
                                ? 'El nombre es requerido'
                                : null,
                          )),
                          SizedBox(width: 20),
                          Expanded(
                              child: TextFormField(
                            controller: _textLastNameController,
                            decoration: InputDecoration(
                                labelText: 'Apellido Paterno',
                                border: OutlineInputBorder()),
                            validator: (value) => value!.isEmpty
                                ? 'El apellido paterno es requerido'
                                : null,
                          )),
                          SizedBox(width: 20),
                          Expanded(
                              child: TextFormField(
                            controller: _textLastName2Controller,
                            decoration: InputDecoration(
                                labelText: 'Apellido Materno',
                                border: OutlineInputBorder()),
                            validator: (value) => value!.isEmpty
                                ? 'El apellido materno es requerido'
                                : null,
                          )),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: TextFormField(
                            controller: _textEmailController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9@.]'))
                            ],
                            decoration: InputDecoration(
                                labelText: 'Correo electrónico',
                                border: OutlineInputBorder()),
                            validator: (value) => value!.isEmpty
                                ? 'El correo electrónico es requerido'
                                : null,
                          )),
                          SizedBox(width: 20),
                          Expanded(
                              child: TextFormField(
                            controller: _textPhoneController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]'))
                            ],
                            decoration: InputDecoration(
                                labelText: 'Teléfono',
                                border: OutlineInputBorder()),
                            validator: (value) => value!.isEmpty
                                ? 'El teléfono es requerido'
                                : null,
                          )),
                          SizedBox(width: 20),
                          Expanded(
                            child: RawAutocomplete<String>(
                              key: _autocompleteJobKey,
                              focusNode: _focusJobPositionNode,
                              textEditingController:
                                  _textEditingJobPositionController,
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                return jobPositions.where((String option) {
                                  return option.contains(
                                      textEditingValue.text.toLowerCase());
                                });
                              },
                              onSelected: (String selection) {
                                _textEditingJobPositionController.text =
                                    selection;
                              },
                              fieldViewBuilder: (BuildContext context,
                                  TextEditingController textEditingController,
                                  FocusNode focusNode,
                                  VoidCallback onFieldSubmitted) {
                                return TextFormField(
                                  controller: _textEditingJobPositionController,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                    labelText: 'Puesto',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) => value!.isEmpty
                                      ? 'El puesto es requerido'
                                      : null,
                                );
                              },
                              optionsViewBuilder: (BuildContext context,
                                  AutocompleteOnSelected<String> onSelected,
                                  Iterable<String> options) {
                                return Material(
                                  child: ListView(
                                    children: options
                                        .map((String option) => GestureDetector(
                                              onTap: () {
                                                onSelected(option);
                                              },
                                              child: ListTile(
                                                title: Text(option),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 33),
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
                                saveNewEmployee();
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
