import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/app_colors.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/Event.dart';
import 'package:rg_event_management_ui/models/Supplier.dart';
import 'package:rg_event_management_ui/modules/provider_list.dart';
import 'package:rg_event_management_ui/services/eventservice.dart';

class AddProviderPage extends StatefulWidget {
  @override
  State<AddProviderPage> createState() => _AddProviderPage();
}

class _AddProviderPage extends State<AddProviderPage> {

  final _formKey = GlobalKey<FormState>();
  var token = "";
  Supplier? selectedSupplier;
  static String _displayStringServicesForOption(ServiceType option) =>
      option.name;
  final _autocompleteServiceTypeKey = GlobalKey();
  final _focusServiceTypeNode = FocusNode();
  final _textEditingServiceTypeController = TextEditingController();
  final _textEditingSupplierNameController = TextEditingController();
  final _textEditingSupplierLastNameController = TextEditingController();
  final _textEditingSupplierEmailController = TextEditingController();
  final _textEditingSupplierPhoneController = TextEditingController();
  final _textEditingSupplierBankAccountController = TextEditingController();

  final _textEditingLocationStreetController = TextEditingController();
  final _textEditingLocationNumberController = TextEditingController();
  // final _textEditingLocationColonyController = TextEditingController();
  final _textEditingLocationCityController = TextEditingController();
  final _textEditingLocationStateController = TextEditingController();
  final _textEditingLocationPostalCodeController = TextEditingController();

  final _textEditingSalonNameController = TextEditingController();
  final _textEditingSalonCapacityController = TextEditingController();

  List<ServiceType> services = [];
  var selectedServiceType;

  @override
  void initState() {
    var appState = context.read<MyAppState>();
    token = appState.appToken;
    if(appState.selectedProvider != null) {
      selectedSupplier = appState.selectedProvider;
      mapSupplierObjectToForm();
    }
    EventService().getServices(token).then((value) {
      setState(() {
        services = value;
      });
    });
    super.initState();
  }

  mapSupplierObjectToForm() {
    if (selectedSupplier != null) {
      _textEditingSupplierNameController.text = selectedSupplier!.name;
      _textEditingSupplierLastNameController.text = selectedSupplier!.lastName;
      _textEditingSupplierEmailController.text = selectedSupplier!.email;
      _textEditingSupplierPhoneController.text = selectedSupplier!.phone;
      _textEditingSupplierBankAccountController.text =
          selectedSupplier!.accountNumber;

      _textEditingServiceTypeController.text = selectedSupplier!.serviceType.name;
      selectedServiceType = selectedSupplier!.serviceType;

      if (selectedSupplier!.location != null) {
        _textEditingLocationStreetController.text =
            selectedSupplier!.location!.address.street;
        _textEditingLocationNumberController.text =
            selectedSupplier!.location!.address.number;
        _textEditingLocationCityController.text =
            selectedSupplier!.location!.address.city;
        _textEditingLocationStateController.text =
            selectedSupplier!.location!.address.state;
        _textEditingLocationPostalCodeController.text =
            selectedSupplier!.location!.address.zipCode;
        _textEditingSalonNameController.text =
            selectedSupplier!.location!.locationName;
        _textEditingSalonCapacityController.text =
            selectedSupplier!.location!.capacity.toString();
      }
    }
  }

  mapFormToObject() {
    Location? location;
    if (selectedServiceType != null && selectedServiceType!.id == 5) {
      location = Location(
          id: selectedSupplier != null ? selectedSupplier!.location!.id : -1,
          locationType: "1",
          address: Address(
              id: selectedSupplier != null  ? selectedSupplier!.location!.address.id : -1,
              street: _textEditingLocationStreetController.text,
              number: _textEditingLocationNumberController.text,
              city: _textEditingLocationCityController.text,
              state: _textEditingLocationStateController.text,
              zipCode: _textEditingLocationPostalCodeController.text),
          locationName: _textEditingSalonNameController.text,
          capacity: int.parse(_textEditingSalonCapacityController.text));
    }
    selectedSupplier = Supplier(
        id: selectedSupplier != null ?  selectedSupplier!.id : -1,
        name: _textEditingSupplierNameController.text,
        description: '',
        cost: 0,
        costDescription: '',
        serviceType: selectedServiceType,
        lastName: _textEditingSupplierLastNameController.text,
        email: _textEditingSupplierEmailController.text,
        phone: _textEditingSupplierPhoneController.text,
        accountNumber: _textEditingSupplierBankAccountController.text,
        location: location);
  }

  saveSupplier() {
    mapFormToObject();
    EventService().createorSaveProvider(selectedSupplier!, token).then((value) {
      if (value != null) {
        selectedSupplier = value;
       Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
          title: 'Proveedor guardado',
          message: 'El proveedor ha sido guardado exitosamente',
          duration: Duration(seconds: 3),
        ).show(context);
      } 
      
    }, onError: (error) {
      log('Error saving provider: $error');
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        title: 'Error',
        message: 'Hubo un error al guardar el proveedor',
        duration: Duration(seconds: 3),
      ).show(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      appBar: AppBar(
        leading: 
          IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.pinkColor),
            onPressed: () {
              setState(() {
                appState.setIndex(1);
              });
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => EventsHomePage()),
              );
            },
          ),
        title: Text('Agregar proveedor',
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
                          Text('Información del proveedor',
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.brown)),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: TextFormField(
                            controller: _textEditingSupplierNameController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-z A-Z]'))
                            ],
                            decoration: InputDecoration(
                                labelText: 'Nombre del proovedor',
                                border: OutlineInputBorder()),
                          )),
                          SizedBox(width: 20),
                          Expanded(
                              child: TextFormField(
                            controller: _textEditingSupplierLastNameController,
                            decoration: InputDecoration(
                                labelText: 'Apellido',
                                border: OutlineInputBorder()),
                          )),
                          SizedBox(width: 20),
                          Expanded(
                            child: RawAutocomplete<ServiceType>(
                              displayStringForOption:
                                  _displayStringServicesForOption,
                              key: _autocompleteServiceTypeKey,
                              focusNode: _focusServiceTypeNode,
                              textEditingController:
                                  _textEditingServiceTypeController,
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                return services.where((ServiceType option) {
                                  return option.name.toLowerCase().startsWith(
                                      textEditingValue.text.toLowerCase());
                                }).toList();
                              },
                              optionsViewBuilder: (BuildContext context,
                                  AutocompleteOnSelected<ServiceType>
                                      onSelected,
                                  Iterable<ServiceType> options) {
                                return Material(
                                  elevation: 4.0,
                                  child: ListView(
                                    children: options
                                        .map((ServiceType option) =>
                                            GestureDetector(
                                              onTap: () {
                                                onSelected(option);
                                              },
                                              child: ListTile(
                                                title: Text(option.name),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                );
                              },
                              fieldViewBuilder: (
                                BuildContext context,
                                TextEditingController
                                    fieldTextEditingController,
                                FocusNode fieldFocusNode,
                                VoidCallback onFieldSubmitted,
                              ) {
                                return TextFormField(
                                enabled: selectedSupplier == null,
                                  controller: fieldTextEditingController,
                                  focusNode: fieldFocusNode,
                                  decoration: const InputDecoration(
                                      labelText: 'Selecciona tipo de servicio',
                                      border: OutlineInputBorder()),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Ingresa el tipo de servicio'
                                          : null,
                                );
                              },
                              onSelected: (ServiceType selection) {
                                log('Selected service type: ${selection.id}');
                                setState(() {
                                  selectedServiceType = selection;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: TextFormField(
                            controller: _textEditingSupplierEmailController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9@.]'))
                            ],
                            decoration: InputDecoration(
                                labelText: 'Correo electrónico',
                                border: OutlineInputBorder()),
                          )),
                          SizedBox(width: 20),
                          Expanded(
                              child: TextFormField(
                            controller: _textEditingSupplierPhoneController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]'))
                            ],
                            decoration: InputDecoration(
                                labelText: 'Teléfono',
                                border: OutlineInputBorder()),
                          )),
                          SizedBox(width: 20),
                          Expanded(
                            child: TextFormField(
                              controller:
                                  _textEditingSupplierBankAccountController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]'))
                              ],
                              decoration: InputDecoration(
                                  labelText: 'Cuenta bancaria',
                                  border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 33),
                      Visibility(
                          visible: selectedServiceType != null && selectedServiceType!.id == 5,
                          child: Column(children: [
                        Row(
                          children: [
                            Text('Ubicación',
                                style: TextStyle(
                                    fontSize: 20.0, color: Colors.brown)),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller:
                                      _textEditingLocationStreetController,
                                  decoration: InputDecoration(
                                      labelText: 'Calle',
                                      border: OutlineInputBorder()),
                                )),
                            SizedBox(width: 20),
                            Expanded(
                                child: TextFormField(
                              controller: _textEditingLocationNumberController,
                              decoration: InputDecoration(
                                  labelText: 'Número',
                                  border: OutlineInputBorder()),
                            )),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                                child: TextFormField(
                              controller: _textEditingLocationCityController,
                              decoration: InputDecoration(
                                  labelText: 'Ciudad',
                                  border: OutlineInputBorder()),
                            )),
                            SizedBox(width: 20),
                            Expanded(
                                child: TextFormField(
                              controller: _textEditingLocationStateController,
                              decoration: InputDecoration(
                                  labelText: 'Estado',
                                  border: OutlineInputBorder()),
                            )),
                            SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                controller:
                                    _textEditingLocationPostalCodeController,
                                decoration: InputDecoration(
                                    labelText: 'Código postal',
                                    border: OutlineInputBorder()),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 33),
                        Row(
                          children: [
                            Text('Información del salón',
                                style: TextStyle(
                                    fontSize: 20.0, color: Colors.brown)),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                                child: TextFormField(
                              controller: _textEditingSalonNameController,
                              decoration: InputDecoration(
                                  labelText: 'Nombre del salón',
                                  border: OutlineInputBorder()),
                            )),
                            SizedBox(width: 20),
                            Expanded(
                                child: TextFormField(
                              controller: _textEditingSalonCapacityController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]'))
                              ],
                              decoration: InputDecoration(
                                  labelText: 'Capacidad',
                                  border: OutlineInputBorder()),
                            )),
                            SizedBox(width: 20),
                            Expanded(child: Text(''))
                          ],
                        ),
                      ])),
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
                                  WidgetStateProperty.all<Size>(Size(130, 70)),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Procesando datos')));
                                        saveSupplier();
                              }
                            },
                            child: Text('Guardar'),
                          ),
                        ],
                      ),
                    ],
                  )))),
    );
  }
}
