import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/Event.dart';
import 'package:rg_event_management_ui/services/eventservice.dart';

class AddEventPopup extends StatefulWidget {
  @override
  State<AddEventPopup> createState() => _AddEventPopup();
}

class _AddEventPopup extends State<AddEventPopup> {

  List<Widget> contactFields = [];

  final _formKey = GlobalKey<FormState>();
  var isEditMode = false;

  var token = "";
  var title = "Nuevo evento";

  List<EventType> eventTypes = [];
  List<Location> locations = [];
  static String _displayStringEventTypesForOption(EventType option) =>
      option.description;
  static String _displayStringLocationsForOption(Location option) =>
      option.locationName;
  static String _displayStringCapacityForOption(Location option) =>
      option.capacity.toString();

  TextEditingController eventName = TextEditingController();
  TextEditingController minCapacity = TextEditingController();
  TextEditingController additionalCost = TextEditingController();
  TextEditingController school = TextEditingController();

  TextEditingController grado = TextEditingController();
  TextEditingController contactName = TextEditingController();
  TextEditingController contactPhone = TextEditingController();
  TextEditingController contactEmail = TextEditingController();
  TextEditingController eventCost = TextEditingController();
  TextEditingController eventCostPackage10 = TextEditingController();
  TextEditingController eventCostPackage10NoPre = TextEditingController();
  TextEditingController eventCostPackageHalf = TextEditingController();
  TextEditingController eventCostPackageHalfNoPre = TextEditingController();
  TextEditingController eventCostPackageDouble = TextEditingController();

  Location? selectedLocation;
  EventType? selectedEventType;
  DateTime? selectedDate;
  Event? selectedEvent;

  final TextEditingController _textEditingLocationController =
      TextEditingController();
  final TextEditingController _textEditingCapacityController =
      TextEditingController();

  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusCapacityNode = FocusNode();
  final GlobalKey _autocompleteKey = GlobalKey();
  final GlobalKey _autocompleteKeyCapacity = GlobalKey();

  @override
  void initState() {
    var appState = context.read<MyAppState>();
    grado.text = "Secundaria";
    token = appState.appToken;

    contactFields.add(
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: TextEditingController(),
              decoration: InputDecoration(labelText: 'Nombre de contacto:'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the contact name';
                }
                return null;
              },
            ),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: TextFormField(
              controller: TextEditingController(),
              decoration: InputDecoration(labelText: 'Teléfono de contacto:'),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the contact phone';
                }
                return null;
              },
            ),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: TextFormField(
              controller: TextEditingController(),
              decoration: InputDecoration(labelText: 'Correo de contacto:'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the contact email';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );

    if (appState.selectedEvent != null) {
      selectedEvent = appState.selectedEvent;
      title = "Editar evento";
      isEditMode = true;
      log('Selected event: ${selectedEvent!.name}');
      mapSelectedEventToFields();
    } else {
      log('No event selected');
      isEditMode = false;
    }

    log('Token: $token');
    EventService().getEventTypes(token).then((value) {
      setState(() {
        eventTypes = value;
      });
    });
    EventService().getLocations(token).then((value) {
      setState(() {
        locations = value;
      });
    });
    // controller.addListener(onScroll);
    super.initState();
  }

  void mapSelectedEventToFields() {
    if (selectedEvent != null) {
      eventName.text = selectedEvent!.name;
      minCapacity.text = selectedEvent!.minCapacity.toString();
      additionalCost.text = selectedEvent!.pricing.additionalCost.toString();
      contactName.text = selectedEvent!.contactName;
      contactPhone.text = selectedEvent!.contactPhone.trim();
      contactEmail.text = selectedEvent!.contactEmail;
      eventCost.text = selectedEvent!.pricing.dishCost.toString();
      eventCostPackage10.text = selectedEvent!.pricing.paq10TICost.toString();
      eventCostPackage10NoPre.text =
          selectedEvent!.pricing.paq10SPCost.toString();
      eventCostPackageHalf.text = selectedEvent!.pricing.paq5TIPCost.toString();
      eventCostPackageHalfNoPre.text =
          selectedEvent!.pricing.paq5SPCost.toString();
      eventCostPackageDouble.text =
          selectedEvent!.pricing.paq10DoubleCost.toString();

      selectedDate = selectedEvent!.eventDate.toLocal();
      selectedEventType = selectedEvent!.eventType;
      selectedLocation = selectedEvent!.location;

      _textEditingLocationController.text = selectedLocation!.locationName;
      _textEditingCapacityController.text =
          selectedLocation!.capacity.toString();
    }
  }

  void saveEvent() {
    if (selectedEventType == null ||
        selectedLocation == null ||
        selectedDate == null) {
      return;
    }

    if (eventName.text.isEmpty) {
      return;
    }

    var event = Event(
      name: eventName.text,
      minCapacity: int.parse(minCapacity.text.isEmpty ? "0" : minCapacity.text),
      contactName: contactName.text,
      contactPhone: contactPhone.text,
      contactEmail: contactEmail.text,
      eventType: selectedEventType!,
      location: selectedLocation!,
      eventDate: selectedDate! ?? DateTime.now(),
      pricing: Pricing(
        id: 0,
        additionalCost: double.parse(
            additionalCost.text.isEmpty ? "0" : additionalCost.text),
        dishCost: double.parse(eventCost.text.isEmpty ? "0" : eventCost.text),
        paq10TICost: double.parse(
            eventCostPackage10.text.isEmpty ? "0" : eventCostPackage10.text),
        paq10SPCost: double.parse(eventCostPackage10NoPre.text.isEmpty
            ? "0"
            : eventCostPackage10NoPre.text),
        paq5TIPCost: double.parse(eventCostPackageHalf.text.isEmpty
            ? "0"
            : eventCostPackageHalf.text),
        paq5SPCost: double.parse(eventCostPackageHalfNoPre.text.isEmpty
            ? "0"
            : eventCostPackageHalfNoPre.text),
        paq10DoubleCost: double.parse(eventCostPackageDouble.text.isEmpty
            ? "0"
            : eventCostPackageDouble.text),
      ),
      // not sending these fields
      createdDate: DateTime.now(),
      updatedDate: DateTime.now(),
      createdBy: 'admin',
      updatedBy: 'admin',
      status: 'active',
      folio: 0,
      id: 0,
    );

    EventService().createEvent(event, token).then((value) {
      Navigator.of(context).popAndPushNamed('/events');
    });
  }

                    void addContactField() {
                    setState(() {
                      if(contactFields.length < 4){
                      contactFields.add(
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: TextEditingController(),
                                decoration: InputDecoration(labelText: 'Nombre de contacto:'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the contact name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 16.0),
                            Expanded(
                              child: TextFormField(
                                controller: TextEditingController(),
                                decoration: InputDecoration(labelText: 'Teléfono de contacto:'),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the contact phone';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 16.0),
                            Expanded(
                              child: TextFormField(
                                controller: TextEditingController(),
                                decoration: InputDecoration(labelText: 'Correo de contacto:'),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the contact email';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                      }
                    });
                  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title,
              style: TextStyle(fontSize: 24.0, color: Color.fromRGBO(250, 50, 100, 0.8))),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Información general', style: TextStyle(fontSize: 20.0, color: Colors.grey[400]))
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: eventName,
                          decoration: InputDecoration(labelText: 'Nombre'),
                          validator: (value) {
                            if (value == null || value!.isEmpty) {
                              return 'Please enter the event name';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded( 
                      child: isEditMode ? TextField(
                        enabled: false,
                        controller: TextEditingController(text: selectedEvent?.eventType.description.toString()),
                        decoration: InputDecoration(
                          labelText: 'Tipo de Evento',
                        ),
                      ) 
                       : Autocomplete<EventType>(
                        initialValue: TextEditingValue(text: selectedEventType?.description ?? ''),
                      displayStringForOption: _displayStringEventTypesForOption,
                      optionsBuilder: (TextEditingValue textEditingValue) {
                      
                      return eventTypes
                          .where((EventType option) {
                        return option.description.toLowerCase().startsWith(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (EventType selection) {
                      setState(() {
                        selectedEventType = selection;
                      });
                    },
                    fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                      return TextFormField(
                        validator: (value) => value!.isEmpty ? 'Seleccione el tipo de evento' : null,
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Tipo de evento',
                      ),
                      onChanged: (String value) {
                       
                      },
                      
                      );    
                    },
                    optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<EventType> onSelected, Iterable<EventType> options) {
                      return Material(
                        child:
                        SizedBox( 
                        height: 100.0,
                        width: 200,
                      child: ListView(
                        children: options.map((EventType option) => GestureDetector(
                          onTap: () {
                            onSelected(option);
                          },
                          child: ListTile(
                            title: Text(option.description),
                          ),
                        )).toList(),
                      ),
                      ),
                      );
                    },
                  ), 
                ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: TextFormField(
                          controller: minCapacity,
                          decoration: InputDecoration(labelText: selectedEventType == null || selectedEventType!.id != 3 ? 'Número Invitados': 'Mínimo de graduados'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value!.isEmpty) {
                              return selectedEventType == null || selectedEventType!.id != 3 ? 'Ingresa número invitados': 'Ingresa el mínimo de graduados';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                Expanded(
                    child: RawAutocomplete<Location>(
                      displayStringForOption: _displayStringLocationsForOption,
                  key: _autocompleteKey,
                  focusNode: _focusNode,
                  textEditingController: _textEditingLocationController,
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    return locations.where((Location option) {
                      return option.locationName.toLowerCase().startsWith(textEditingValue.text.toLowerCase());
                    }).toList();
                  },
                  optionsViewBuilder: (BuildContext context,
                      AutocompleteOnSelected<Location> onSelected,
                      Iterable<Location> options) {
                    return Material(
                      elevation: 4.0,
                      child: ListView(
                        children: options
                            .map((Location option) => GestureDetector(
                                  onTap: () {
                                    onSelected(option);
                                  },
                                  child: ListTile(
                                    title: Text(option.locationName),
                                  ),
                                ))
                            .toList(),
                      ),
                    );
                  },
                  fieldViewBuilder: (
                    BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    return TextFormField(
                      controller: fieldTextEditingController,
                      focusNode: fieldFocusNode,
                      decoration: const InputDecoration(labelText: 'Selecciona salón'),
                    );
                  },
                  onSelected: (Location selection) {
                    log('Selected location: ${selection.locationName}');
                    _textEditingCapacityController.text = selection.capacity.toString();
                          setState(() {
                            selectedLocation = selection;
                          });
                        },
                  ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: RawAutocomplete<Location>(
                      displayStringForOption: _displayStringCapacityForOption,
              key: _autocompleteKeyCapacity,
              focusNode: _focusCapacityNode,
              textEditingController: _textEditingCapacityController,
              optionsBuilder: (TextEditingValue textEditingValue) {
                return locations.where((Location option) {
                  return option.capacity.toString().startsWith(textEditingValue.text.toLowerCase());
                }).toList();
              },
              optionsViewBuilder: (BuildContext context,
                  AutocompleteOnSelected<Location> onSelected,
                  Iterable<Location> options) {
                return Material(
                  elevation: 4.0,
                  child: ListView(
                    children: options
                        .map((Location option) => GestureDetector(
                              onTap: () {
                                onSelected(option);
                              },
                              child: ListTile(
                                title: Text(option.capacity.toString()),
                              ),
                            ))
                        .toList(),
                  ),
                );
              },
              fieldViewBuilder: (
                BuildContext context,
                TextEditingController fieldTextEditingController,
                FocusNode fieldFocusNode,
                VoidCallback onFieldSubmitted,
              ) {
                return TextFormField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  decoration: const InputDecoration(labelText: 'Selecciona capacidad'),
                );
              },
              onSelected: (Location selection) {
                log('Selected location: ${selection.locationName}');
                _textEditingLocationController.text = selection.locationName;
                _textEditingLocationController.selection = TextSelection.fromPosition( TextPosition(offset: _textEditingCapacityController.text.length));
                      setState(() {
                        selectedLocation = selection;
                      });
                    },
            ),
                ),
                SizedBox(width: 16.0),
                Expanded( 
                  flex: 1,
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      readOnly: true,
                      controller: TextEditingController(text: selectedDate?.toString().substring(0, 10) ?? ''),
                      decoration: InputDecoration(
                        labelText: 'Fecha del evento',
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(Duration(days: 365)),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    )
                  ],
                ),
                ),
                    ]
                  ),
                   SizedBox(height: 32.0),
                   Row(
                    children: [
                      Text('Contacto', style: TextStyle(fontSize: 20.0, color: Colors.grey[400]))
                    ],
                  ),
                
                  Container(
                    child: Column(
                      children: contactFields,
                    ),
                  ),
                  
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: contactFields.length < 4 ? addContactField : null,
                        child: Text('Agregar contacto'),
                      ),
                      SizedBox(width: 16.0),
                      OutlinedButton(
                        onPressed: contactFields.length <= 1 ? null :  () {
                          if(contactFields.length > 1){
                          contactFields.removeLast();
                          setState(() {});
                          }
                        },
                        child: Text('Eliminar contacto'),
                      ),
                    ],
                  ),
                  SizedBox(height: 22.0),
                  Row(
                    children: [
                      Text('Costos', style: TextStyle(fontSize: 20.0, color: Colors.grey[400]))
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: eventCost,
                          decoration: InputDecoration(labelText: 'Costo por platillo:'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the event cost';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: TextFormField(
                          controller: eventCostPackage10,
                          decoration: InputDecoration(labelText: 'Costo paquete 10:'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the event cost';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: TextFormField(
                          controller: eventCostPackage10NoPre,
                          decoration: InputDecoration(labelText: 'Costo paquete 10 sin pre:'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the event cost';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    
                  )
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      // if (_formKey!.currentState.validate()) {
                      //   saveEvent();
                      // }
                    },
                    child: Text('Guardar'),
                  ),
                ],
              ),
            ),
          ),
        ),
        );
  }
}
