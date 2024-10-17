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
    List<Supplier> suppliers = [];
  static String _displayStringServicesForOption(ServiceType option) =>
      option.name;
  static String _displayStringSuppliersForOption(Supplier option) =>
      option.name;
  final _autocompleteServiceTypeKey = GlobalKey();
  final _focusServiceTypeNode = FocusNode();
  final _textEditingServiceTypeController = TextEditingController();
  final _autocompleteSupplierKey = GlobalKey();
  final _focusSupplierNode = FocusNode();
  final _textEditingSupplierController = TextEditingController();

  final _textEditingPrice = TextEditingController();
  
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
                          Text('Agregar servicios adicionales',
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.brown)),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: RawAutocomplete<ServiceType>(
                              key: _autocompleteServiceTypeKey,
                              focusNode: _focusServiceTypeNode,
                              textEditingController: _textEditingServiceTypeController,
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                if (textEditingValue.text == '') {
                                  return const Iterable<ServiceType>.empty();
                                }
                                return services.where((ServiceType option) {
                                  return option.name
                                      .toLowerCase()
                                      .contains(textEditingValue.text.toLowerCase());
                                });
                              },
                              displayStringForOption: _displayStringServicesForOption,
                              fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                                return TextFormField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                      labelText: 'Tipo de servicio',
                                      border: OutlineInputBorder()),
                                  onFieldSubmitted: (_) => onFieldSubmitted(),
                                );
                              },
                              onSelected: (ServiceType selection) {
                                _textEditingServiceTypeController.text = selection.name;
                              }, optionsViewBuilder: (BuildContext context, void Function(ServiceType) onSelected, Iterable<ServiceType> options) 
                              { 
                                return Material(
                                  child: ListView(
                                    children: options
                                        .map((ServiceType option) => ListTile(
                                              title: Text(option.name),
                                              onTap: () {
                                                onSelected(option);
                                              },
                                            ))
                                        .toList(),
                                  ),
                                ); 
                              },
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(child: 
                          RawAutocomplete<Supplier>(
                            key: _autocompleteSupplierKey,
                            focusNode: _focusSupplierNode,
                            textEditingController: _textEditingSupplierController,
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return const Iterable<Supplier>.empty();
                              }
                              return suppliers.where((Supplier option) {
                                return option.name
                                    .toLowerCase()
                                    .contains(textEditingValue.text.toLowerCase());
                              });
                            },
                            displayStringForOption: _displayStringSuppliersForOption,
                            fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                              return TextFormField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                    labelText: 'Proveedor',
                                    border: OutlineInputBorder()),
                                onFieldSubmitted: (_) => onFieldSubmitted(),
                              );
                            },
                            onSelected: (Supplier selection) {
                              _textEditingSupplierController.text = selection.name;
                            }, optionsViewBuilder: (BuildContext context, void Function(Supplier) onSelected, Iterable<Supplier> options) 
                            { 
                              return Material(
                                child: ListView(
                                  children: options
                                      .map((Supplier option) => ListTile(
                                            title: Text(option.name),
                                            onTap: () {
                                              onSelected(option);
                                            },
                                          ))
                                      .toList(),
                                ),
                              ); 
                            },
                          ),
                          ),                          
                          SizedBox(width: 20),
                          Expanded(
                              child: TextFormField(
                            controller: _textEditingPrice,
                            decoration: InputDecoration(
                                labelText: 'Precio',
                                border: OutlineInputBorder()),
                          )),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: 
                             ElevatedButton(onPressed: 
                             
                             , child: child)
                             
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
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
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
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