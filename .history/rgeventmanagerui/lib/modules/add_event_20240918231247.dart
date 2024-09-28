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
  
  List<TextEditingController> contactNameList = [];
  List<TextEditingController> contactPhoneList = [];
  List<TextEditingController> contactEmailList = [];
  List<TextEditingController> contactIds = [];
  List<Widget> contactFields = [];

  List<String> grados = [
    "Preescolar",
    "Primaria",
    "Secundaria",
    "Preparatoria",
    "Licenciatura",
    "Maestria",
    "Doctorado"
  ];
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

      final TextEditingController _textEditingGradoController = TextEditingController();

  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusCapacityNode = FocusNode();
  final FocusNode _focusGradoNode = FocusNode();

  final GlobalKey _autocompleteKey = GlobalKey();
  final GlobalKey _autocompleteKeyCapacity = GlobalKey();
  final GlobalKey _autocompleteKeyGrado = GlobalKey();

  @override
  void initState() {
    var appState = context.read<MyAppState>();
    token = appState.appToken;

    TextEditingController contactName = TextEditingController();
    TextEditingController contactPhone = TextEditingController();
    TextEditingController contactEmail = TextEditingController();
    TextEditingController contactId = TextEditingController();

    if(!isEditMode) {
    contactNameList.add(contactName);
    contactPhoneList.add(contactPhone);
    contactEmailList.add(contactEmail);
    contactIds.add(contactId);
    contactFields.add(
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: contactName,
              decoration: InputDecoration(labelText: 'Nombre de contacto:'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa el nombre del contacto';
                }
                return null;
              },
            ),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: TextFormField(
              controller: contactPhone,
              decoration: InputDecoration(labelText: 'Teléfono de contacto:'),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa el teléfono del contacto';
                }
                return null;
              },
            ),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: TextFormField(
              controller: contactEmail,
              decoration: InputDecoration(labelText: 'Correo de contacto:'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa el correo del contacto';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
    }
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
    super.initState();
  }

  void mapSelectedEventToFields() {
    if (selectedEvent != null) {
      eventName.text = selectedEvent!.name;
      minCapacity.text = selectedEvent!.minCapacity.toString();
      additionalCost.text = selectedEvent!.pricing.additionalCost.toString();

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
          for(var i = 0; i < selectedEvent!.contacts.length; i++) {
            if(i > 0) {
              addContactField();
            }
            contactNameList[i].text = selectedEvent!.contacts[i].name;
            contactPhoneList[i].text = selectedEvent!.contacts[i].phone;
            contactEmailList[i].text = selectedEvent!.contacts[i].email;
          }

      if (selectedEventType != null && selectedEventType!.id == 3) {
        grado.text = selectedEvent!.grade ?? "";
        school.text = selectedEvent!.school ?? "";
        _textEditingGradoController.text = grado.text;
      }


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
    var contacts = <Contact>[];

    for (var i = 0; i < contactFields.length; i++) {
      contacts.add(Contact(
        id: -1,
        name: contactNameList[i].text,
        phone: contactPhoneList[i].text,
        email: contactEmailList[i].text,
      ));
    }
    var event = Event(
      id: selectedEvent?.id ?? -1,
      name: eventName.text,
      minCapacity: int.parse(minCapacity.text.isEmpty ? "0" : minCapacity.text),
      contacts: contacts,
      eventType: selectedEventType!,
      location: selectedLocation!,
      eventDate: selectedDate! ?? DateTime.now(),

      pricing: Pricing(
        id: selectedEvent?.pricing.id ?? -1,
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
      grade: selectedEventType != null && selectedEventType!.id == 3
          ? grado.text
          : null,
      school: selectedEventType != null && selectedEventType!.id == 3 ? school.text : null,
      // not sending these fields
      createdDate: DateTime.now(),
      updatedDate: DateTime.now(),
      createdBy: 'admin',
      updatedBy: 'admin',
      status: 'active',
      folio: 0,
    );

    EventService().createEvent(event, token).then((value) {
      Navigator.of(context)
          .pushReplacement(
        MaterialPageRoute(
          builder: (context) => EventsHomePage(),
        ),
      )
          .then((_) {
        // Refresh data or perform any necessary actions after returning to the page
        setState(() {
          log('Event created');
          selectedEvent = null;
        });
      });
    }, onError: (error) {
      log('Error creating event: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Error al guardar el evento'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar'),
              )
            ],
          );
        },
      );
    });
  }

  void addContactField() {
    TextEditingController contactName = TextEditingController();
    TextEditingController contactPhone = TextEditingController();
    TextEditingController contactEmail = TextEditingController();

    contactNameList.add(contactName);
    contactPhoneList.add(contactPhone);
    contactEmailList.add(contactEmail);
    setState(() {
      if (contactFields.length < 4) {
        contactFields.add(
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: contactName,
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
                  controller: contactPhone,
                  decoration:
                      InputDecoration(labelText: 'Teléfono de contacto:'),
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
                  controller: contactEmail,
                  decoration: InputDecoration(labelText: 'Correo de contacto:'),
                  keyboardType: TextInputType.emailAddress,
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
            style: TextStyle(
                fontSize: 24.0, color: Color.fromRGBO(250, 10, 100, 0.8))),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(22.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Información general',
                        style:
                            TextStyle(fontSize: 20.0, color: Colors.grey[400]))
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
                            return 'Ingresaa el nombre del evento';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: isEditMode
                          ? TextField(
                              enabled: false,
                              controller: TextEditingController(
                                  text: selectedEvent?.eventType.description
                                      .toString()),
                              decoration: InputDecoration(
                                labelText: 'Tipo de Evento',
                              ),
                            )
                          : Autocomplete<EventType>(
                              initialValue: TextEditingValue(
                                  text: selectedEventType?.description ?? ''),
                              displayStringForOption:
                                  _displayStringEventTypesForOption,
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                return eventTypes.where((EventType option) {
                                  return option.description
                                      .toLowerCase()
                                      .startsWith(
                                          textEditingValue.text.toLowerCase());
                                });
                              },
                              onSelected: (EventType selection) {
                                setState(() {
                                  selectedEventType = selection;
                                });
                              },
                              fieldViewBuilder: (BuildContext context,
                                  TextEditingController textEditingController,
                                  FocusNode focusNode,
                                  VoidCallback onFieldSubmitted) {
                                return TextFormField(
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Ingresa el tipo de evento'
                                          : null,
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                    labelText: 'Tipo de evento',
                                  ),
                                  onChanged: (String value) {},
                                );
                              },
                              optionsViewBuilder: (BuildContext context,
                                  AutocompleteOnSelected<EventType> onSelected,
                                  Iterable<EventType> options) {
                                return Material(
                                  child: SizedBox(
                                    height: 100.0,
                                    width: 200,
                                    child: ListView(
                                      children: options
                                          .map((EventType option) =>
                                              GestureDetector(
                                                onTap: () {
                                                  onSelected(option);
                                                },
                                                child: ListTile(
                                                  title:
                                                      Text(option.description),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: TextFormField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        controller: minCapacity,
                        decoration: InputDecoration(
                            labelText: selectedEventType == null ||
                                    selectedEventType!.id != 3
                                ? 'Número Invitados'
                                : 'Mínimo de graduados'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value!.isEmpty) {
                            return selectedEventType == null ||
                                    selectedEventType!.id != 3
                                ? 'Ingresa número invitados'
                                : 'Ingresa el mínimo de graduados';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(children: [
                  Expanded(
                    child: RawAutocomplete<Location>(
                      displayStringForOption: _displayStringLocationsForOption,
                      key: _autocompleteKey,
                      focusNode: _focusNode,
                      textEditingController: _textEditingLocationController,
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        return locations.where((Location option) {
                          return option.locationName
                              .toLowerCase()
                              .startsWith(textEditingValue.text.toLowerCase());
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
                          decoration: const InputDecoration(
                              labelText: 'Selecciona salón'),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Ingresa el salón'
                              : null,
                        );
                      },
                      onSelected: (Location selection) {
                        log('Selected location: ${selection.locationName}');
                        _textEditingCapacityController.text =
                            selection.capacity.toString();
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
                          return option.capacity
                              .toString()
                              .startsWith(textEditingValue.text.toLowerCase());
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
                          decoration: const InputDecoration(
                              labelText: 'Selecciona capacidad'),
                        );
                      },
                      onSelected: (Location selection) {
                        log('Selected location: ${selection.locationName}');
                        _textEditingLocationController.text =
                            selection.locationName;
                        _textEditingLocationController.selection =
                            TextSelection.fromPosition(TextPosition(
                                offset: _textEditingCapacityController
                                    .text.length));
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
                        TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                              text: selectedDate?.toString().substring(0, 10) ??
                                  ''),
                          decoration: InputDecoration(
                            labelText: 'Fecha del evento',
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Ingresa la fecha del evento'
                              : null,
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate:
                                  DateTime.now().subtract(Duration(days: 365)),
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
                ]),
                SizedBox(height: 16.0),
                Visibility(
                  visible:
                      selectedEventType != null && selectedEventType!.id == 3,
                  child: Row(
                    children: [
                      Expanded(
                          child: RawAutocomplete<String>(
                        key: _autocompleteKeyGrado,
                        focusNode: _focusGradoNode,
                            textEditingController: _textEditingGradoController,
                        displayStringForOption: (dynamic option) =>
                            option.toString(),
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          return grados.where((String option) {
                            return option.toLowerCase().startsWith(
                                textEditingValue.text.toLowerCase());
                          }).toList();
                        },
                        fieldViewBuilder: (BuildContext context,
                            TextEditingController fieldTextEditingController,
                            FocusNode fieldFocusNode,
                            VoidCallback onFieldSubmitted) {
                          return TextFormField(
                            controller: fieldTextEditingController,
                            focusNode: fieldFocusNode,
                            decoration: const InputDecoration(
                                labelText: 'Selecciona grado'),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Ingresa el grado'
                                : null,
                          );
                        },
                        optionsViewBuilder: (BuildContext context,
                            void Function(String) onSelected,
                            Iterable<String> options) {
                          return Material(
                            elevation: 4.0,
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
                        onSelected: (String selection) {
                          setState(() {
                            grado.text = selection;
                          });
                        },
                      )),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: TextFormField(
                          controller: school,
                          decoration: InputDecoration(labelText: 'Escuela'),
                          validator: (value) {
                            if ((selectedEventType != null &&
                                    selectedEventType!.id == 3) &&
                                (value == null || value.isEmpty)) {
                              return 'Ingresa la escuela';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.0),
                Row(
                  children: [
                    Text('Contacto',
                        style:
                            TextStyle(fontSize: 20.0, color: Colors.grey[400]))
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
                      onPressed:
                          contactFields.length < 4 ? addContactField : null,
                      child: Text('Agregar contacto'),
                    ),
                    SizedBox(width: 16.0),
                    OutlinedButton(
                      onPressed: contactFields.length <= 1
                          ? null
                          : () {
                              if (contactFields.length > 1) {
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
                    Text('Costos',
                        style:
                            TextStyle(fontSize: 20.0, color: Colors.grey[400]))
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: eventCost,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'))
                        ],
                        decoration:
                            InputDecoration(labelText: 'Costo por platillo:'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa el costo del platillo';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 32.0),
                    Visibility(
                      visible: selectedEventType != null &&
                          selectedEventType!.id == 3,
                      child: Expanded(
                        child: TextFormField(
                          controller: additionalCost,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'))
                          ],
                          decoration:
                              InputDecoration(labelText: 'Costo adicional:'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                    SizedBox(width: 200.0),
                    Text(''),
                  ],
                ),
                SizedBox(height: 32.0),
                Visibility(
                  visible:
                      selectedEventType != null && selectedEventType!.id == 3,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: eventCostPackage10,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'))
                          ],
                          decoration:
                              InputDecoration(labelText: 'Costo paquete 10:'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: TextFormField(
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'))
                          ],
                          controller: eventCostPackage10NoPre,
                          decoration: InputDecoration(
                              labelText: 'Costo paquete 10 sin pre:'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: TextFormField(
                          controller: eventCostPackageHalf,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'))
                          ],
                          decoration:
                              InputDecoration(labelText: 'Costo paquete 5:'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: TextFormField(
                          controller: eventCostPackageHalfNoPre,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'))
                          ],
                          decoration: InputDecoration(
                              labelText: 'Costo paquete 5 sin pre:'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: TextFormField(
                          controller: eventCostPackageDouble,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'))
                          ],
                          decoration: InputDecoration(
                              labelText: 'Costo paquete doble:'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50.0),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromRGBO(250, 50, 100, 0.8)),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    fixedSize: MaterialStateProperty.all<Size>(Size(200, 80)),
                  ),
                  onPressed: () {
                    if (_formKey != null &&
                        _formKey!.currentState != null &&
                        _formKey.currentState!.validate()) {
                      saveEvent();
                    }
                  },
                  child: Text('Guardar Evento'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
