import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/app_colors.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/Employee.dart';
import 'package:rg_event_management_ui/models/Supplier.dart';
import 'package:rg_event_management_ui/modules/employees_list.dart';
import 'package:rg_event_management_ui/services/employees_service.dart';
import 'package:rg_event_management_ui/services/eventservice.dart';

class AdditionalServices extends StatefulWidget {
  @override
  _AdditionalServices createState() => _AdditionalServices();
}

class _AdditionalServices extends State<AdditionalServices> {
  var appState;
  final _formKey = GlobalKey<FormState>();
  var token = "";
    List<ServiceType> services = [];

  static String _displayStringServicesForOption(ServiceType option) =>
      option.name;
  final _autocompleteServiceTypeKey = GlobalKey();
  final _focusServiceTypeNode = FocusNode();
  final _textEditingServiceTypeController = TextEditingController();

  @override
  void initState() {
    appState = context.read<MyAppState>();
    token = appState.appToken;

   EventService().getServices(token).then((value) {
     setState(() {
       services = value;
     });
   });

    super.initState();
  }
  

  @override
  Widget build(BuildContext context) {
    var appState = context.read<MyAppState>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => {
                  Navigator.of(context).pop(),
                },
            icon: Icon(Icons.arrow_back, color: AppColors.pinkColor)),
        title: Text('Servicios adicionales',
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
                          Text('Agrega servicios adicionales',
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.brown)),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        children: [
                          
                        ],
                      ),
                      SizedBox(height: 20),
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