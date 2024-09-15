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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title,
              style: TextStyle(fontSize: 24.0, color: Colors.grey[800])),
        ),
        body: Padding(
          padding: EdgeInsets.all(18.0),
          child: Form(
            key: _formKey,
            child: Expanded(
              child: Container(
                child: Singlechildscrollview(
                  padding: EdgeInsets.all(18),
                  children: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Información del evento',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: eventName,
                            decoration: InputDecoration(
                              labelText: 'Nombre del evento',
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: isEditMode
                              ? TextField(
                                  enabled: false,
                                  controller: TextEditingController(
                                      text: selectedEvent?.eventType.description
                                          .toString()),
                                  decoration: InputDecoration(
                                    labelText: 'Tipo del Evento',
                                  ),
                                )
                              : Autocomplete<EventType>(
                                  initialValue: TextEditingValue(
                                      text:
                                          selectedEventType?.description ?? ''),
                                  displayStringForOption:
                                      _displayStringEventTypesForOption,
                                  optionsBuilder:
                                      (TextEditingValue textEditingValue) {
                                    return eventTypes.where((EventType option) {
                                      return option.description
                                          .toLowerCase()
                                          .startsWith(textEditingValue.text
                                              .toLowerCase());
                                    });
                                  },
                                  onSelected: (EventType selection) {
                                    log('Selected: ${selection.description}');
                                    setState(() {
                                      selectedEventType = selection;
                                    });
                                  },
                                  fieldViewBuilder: (BuildContext context,
                                      TextEditingController
                                          textEditingController,
                                      FocusNode focusNode,
                                      VoidCallback onFieldSubmitted) {
                                    return TextFormField(
                                      validator: (value) => value!.isEmpty
                                          ? 'Seleccione el tipo de evento'
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
                                      AutocompleteOnSelected<EventType>
                                          onSelected,
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
                                                      title: Text(
                                                          option.description),
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                            child: TextField(
                          controller: minCapacity,
                          decoration: InputDecoration(
                            labelText: selectedEventType != null &&
                                    selectedEventType!.id != 3
                                ? 'Numero de personas'
                                : 'Mínimo de graduados',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        )),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: contactName,
                            decoration: InputDecoration(
                              labelText: 'Nombre de contacto',
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: TextField(
                            controller: contactPhone,
                            decoration: InputDecoration(
                              labelText: 'Teléfono de contacto',
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: TextField(
                            controller: contactEmail,
                            decoration: InputDecoration(
                              labelText: 'Correo de contacto',
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Visibility(
                      visible: (selectedEventType != null &&
                          selectedEventType!.id == 3), // condition here
                      child: Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: grado,
                                decoration: InputDecoration(
                                  labelText: 'Grado',
                                ),
                              ),
                            ),
                            SizedBox(width: 200),
                            Expanded(
                              child: TextFormField(
                                controller: school,
                                decoration: InputDecoration(
                                  labelText: 'Escuela',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
