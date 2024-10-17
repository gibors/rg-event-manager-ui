import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/app_colors.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/Event.dart';
import 'package:rg_event_management_ui/models/Supplier.dart';
import 'package:rg_event_management_ui/services/eventservice.dart';

class AddProviderPage extends StatefulWidget {
  @override
  State<AddProviderPage> createState() => _AddProviderPage();
}

class _AddProviderPage extends State<AddProviderPage> {
  final _formKey = GlobalKey<FormState>();
  var token ="";
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

  @override
  void initState() {
    var appState = context.read<MyAppState>();
    token = appState.appToken;

    EventService().getServices(token).then((value) {
      setState(() {
        services = value;
      });
    });
    super.initState();
  }

  mapSupplierObjectToForm() {
    if(selectedSupplier != null) {
    
    _textEditingSupplierNameController.text = selectedSupplier!.name;
    _textEditingSupplierLastNameController.text = selectedSupplier!.lastName;
    _textEditingSupplierEmailController.text = selectedSupplier!.email;
    _textEditingSupplierPhoneController.text = selectedSupplier!.phone;
    _textEditingSupplierBankAccountController.text = selectedSupplier!.accountNumber;

    if(selectedSupplier!.location != null) {
    _textEditingLocationStreetController.text = selectedSupplier!.location!.address.street;
    _textEditingLocationNumberController.text = selectedSupplier!.location!.address.number;
    _textEditingLocationCityController.text = selectedSupplier!.location!.address.city;
    _textEditingLocationStateController.text = selectedSupplier!.location!.address.state;
    _textEditingLocationPostalCodeController.text = selectedSupplier!.location!.address.zipCode;
    _textEditingSalonNameController.text = selectedSupplier!.location!.locationName;
    _textEditingSalonCapacityController.text = selectedSupplier!.location!.capacity.toString();
    }
    }
  }

  mapFormToObject() {
    Location? location;
    if(_textEditingServiceTypeController.text == "Salón") {
      location = Location(
        id: selectedSupplier!.location!.id ?? -1,
        locationType: "1",
        address: Address(
          id: selectedSupplier!.location!.address.id ?? -1,
            street: _textEditingLocationStreetController.text,
            number: _textEditingLocationNumberController.text,
            city: _textEditingLocationCityController.text,
            state: _textEditingLocationStateController.text,
            zipCode: _textEditingLocationPostalCodeController.text),
        locationName: _textEditingSalonNameController.text,
        capacity: int.parse(_textEditingSalonCapacityController.text));
      
    }
    selectedSupplier = Supplier(
        id: selectedSupplier!.id ?? -1,
        name: _textEditingSupplierNameController.text,
        description: '',
        cost: 0,
        costDescription: '',
        serviceType: services.firstWhere((element) => element.name == _textEditingServiceTypeController.text),
        lastName: _textEditingSupplierLastNameController.text,
        email: _textEditingSupplierEmailController.text,
        phone: _textEditingSupplierPhoneController.text,
        accountNumber: _textEditingSupplierBankAccountController.text,
        location: location);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                                labelText: 'Apellido', border: OutlineInputBorder()),
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
                                  controller: fieldTextEditingController,
                                  focusNode: fieldFocusNode,
                                  decoration: const InputDecoration(
                                      labelText: 'Selecciona tipo de servicio',
                                      border: OutlineInputBorder()
                                      ),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Ingresa el tipo de servicio'
                                          : null,
                                );
                              },
                              onSelected: (ServiceType selection) {
                                log('Selected location: ${selection.name}');
                                // _textEditingCapacityController.text =
                                //     selection.capacity.toString();
                                // setState(() {
                                //   selectedLocation = selection;
                                // });
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
                                  RegExp(r'[a-zA-Z]'))
                            ],
                            decoration: InputDecoration(
                                labelText: 'Correo electrónico',
                                border: OutlineInputBorder()),
                          )),
                          SizedBox(width: 20),
                          Expanded(
                              child: TextFormField(
                            controller: _textEditingSupplierPhoneController,
                            decoration: InputDecoration(
                                labelText: 'Teléfono', border: OutlineInputBorder()),
                          )),
                          SizedBox(width: 20),
                            Expanded(
                              child: TextFormField( 
                            controller: _textEditingSupplierBankAccountController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]'))
                            ],
                            decoration: InputDecoration(
                                labelText: 'Cuenta bancaria', border: OutlineInputBorder()),
                              ),
                          ),
                        ],
                      ),
                      SizedBox(height: 33),
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
                            controller: _textEditingLocationStreetController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z]'))
                            ],
                            decoration: InputDecoration(
                                labelText: 'Calle', border: OutlineInputBorder()),
                          )),
                          SizedBox(width: 20),
                          Expanded(
                              child: TextFormField(
                            controller: _textEditingLocationNumberController,
                            decoration: InputDecoration(
                                labelText: 'Número', border: OutlineInputBorder()),
                          )),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: TextFormField(
                            controller: _textEditingLocationCityController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z]'))
                            ],
                            decoration: InputDecoration(
                                labelText: 'Ciudad', border: OutlineInputBorder()),
                          )),
                          SizedBox(width: 20),
                          Expanded(
                              child: TextFormField(
                            controller: _textEditingLocationStateController,
                            decoration: InputDecoration(
                                labelText: 'Estado', border: OutlineInputBorder()),
                          )),
                          SizedBox(width: 20),
                          Expanded(
                              child: TextFormField(
                            controller: _textEditingLocationPostalCodeController,
                            decoration: InputDecoration(
                                labelText: 'Código postal', border: OutlineInputBorder()),
                          ),)
                        ],
                      ),

                      SizedBox(height: 33),
                      Visibility(
                        child: Column(children: [
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
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z]'))
                            ],
                            decoration: InputDecoration(
                                labelText: 'Nombre del salón',
                                border: OutlineInputBorder()),
                          )),
                          SizedBox(width: 20),
                          Expanded(
                              child: TextFormField(
                            controller: _textEditingSalonCapacityController,
                            decoration: InputDecoration(
                                labelText: 'Capacidad', border: OutlineInputBorder()),
                          )),
                          SizedBox(width: 20),
                          Expanded(
                              child: Text(''))
                        ],
                      ),
                    ]),
                      ),
                      SizedBox(height: 33),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(AppColors.pinkColor),
                                  foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                                  fixedSize: WidgetStateProperty.all<Size>(Size(130, 70)),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Procesando datos')));
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
