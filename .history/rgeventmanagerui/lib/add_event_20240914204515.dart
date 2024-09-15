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
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: eventName,
                          decoration: InputDecoration(labelText: 'Event Name'),
                          validator: (value) {
                            if (value != null || value!.isEmpty) {
                              return 'Please enter the event name';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: TextFormField(
                          controller: minCapacity,
                          decoration: InputDecoration(labelText: 'Min Capacity'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null || value.isEmpty) {
                              return 'Please enter the min capacity';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: TextFormField(
                          controller: additionalCost,
                          decoration: InputDecoration(labelText: 'Additional Cost'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null || value.isEmpty) {
                              return 'Please enter the additional cost';
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
                        child: TextFormField(
                          controller: contactName,
                          decoration: InputDecoration(labelText: 'Contact Name'),
                          validator: (value) {
                            if (value != null || value.isEmpty) {
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
                          decoration: InputDecoration(labelText: 'Contact Phone'),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value != null || value.isEmpty) {
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
                          decoration: InputDecoration(labelText: 'Contact Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null || value.isEmpty) {
                              return 'Please enter the contact email';
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
                        child: TextFormField(
                          controller: eventCost,
                          decoration: InputDecoration(labelText: 'Event Cost'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null || value.isEmpty) {
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
                          decoration: InputDecoration(labelText: 'Event Cost Package 10'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null || value.isEmpty) {
                              return 'Please enter the event cost package 10';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: TextFormField(
                          controller: eventCostPackage10NoPre,
                          decoration: InputDecoration(labelText: 'Event Cost Package 10 No Pre'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null || value.isEmpty) {
                              return 'Please enter the event cost package 10 no pre';
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
                        child: TextFormField(
                          controller: eventCostPackageHalf,
                          decoration: InputDecoration(labelText: 'Event Cost Package Half'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null || value.isEmpty) {
                              return 'Please enter the event cost package half';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: TextFormField(
                          controller: eventCostPackageHalfNoPre,
                          decoration: InputDecoration(labelText: 'Event Cost Package Half No Pre'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null || value.isEmpty) {
                              return 'Please enter the event cost package half no pre';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: TextFormField(
                          controller: eventCostPackageDouble,
                          decoration: InputDecoration(labelText: 'Event Cost Package Double'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null || value.isEmpty) {
                              return 'Please enter the event cost package double';
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
                        child: TextFormField(
                          controller: _textEditingLocationController,
                          decoration: InputDecoration(labelText: 'Location'),
                          onTap: () {
                            // TODO: Implement location selection logic
                          },
                          validator: (value) {
                            if (value != null || value.isEmpty) {
                              return 'Please select a location';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: TextFormField(
                          controller: _textEditingCapacityController,
                          decoration: InputDecoration(labelText: 'Capacity'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null || value.isEmpty) {
                              return 'Please enter the capacity';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Event Type'),
                          onTap: () {
                            // TODO: Implement event type selection logic
                          },
                          validator: (value) {
                            if (value != null || value.isEmpty) {
                              return 'Please select an event type';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      // if (_formKey!.currentState.validate()) {
                      //   saveEvent();
                      // }
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
        );
  }
}
