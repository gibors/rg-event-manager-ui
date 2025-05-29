import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/formatters/ThousandsSeparatorInputFormatter.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/AdditionalService.dart';
import 'package:rg_event_management_ui/models/EventPay.dart';
import 'package:rg_event_management_ui/models/Supplier.dart';
import 'package:rg_event_management_ui/services/eventservice.dart';

class ExpensesEventPage extends StatefulWidget {
  @override
  _ExpensesEventPage createState() => _ExpensesEventPage();
}

class _ExpensesEventPage extends State<ExpensesEventPage> {
  final _formKey = GlobalKey<FormState>();
  var appState;
  var token = "";
  var selectedEvent;
  bool isEditMode = false;
  bool isEnableSupplier = true;
  List<ServiceType> serviceTypes = [];
  Map<int, List<Supplier>> suppliersMap = {};
  Map<int, List<ServiceType>> serviceTypeMaps = {};
  AdditionalService emptyAdditionalService = AdditionalService(
    id: 0,
    description: "Ninguno",
    serviceType: ServiceType(id: -1, name: "Empty", description: "empty"),
    supplier: null,
    eventId: -1,
    quantity: 0,
    cost: 0.0,
    supplierCost: 0.0,
  );
  List<AdditionalService> additionalServices = [];
  List<EventPay> eventPays = [];
  List<Widget> expensesWidgets = [];

  // list controllers to keep track of the values

  List<int> eventPaymentIds = [];
  List<AdditionalService?> selectedAdditionalServices = [];
  List<ServiceType?> selectedServiceTypes = [];
  List<Supplier?> selectedSuppliers = [];

  List<TextEditingController> additionalServiceControllers = [];
  List<TextEditingController> additionalServiceReminderControllers = [];
  List<TextEditingController> serviceTypeControllers = [];
  List<TextEditingController> supplierControllers = [];
  List<TextEditingController> paymentValueControllers = [];
  List<TextEditingController> eventPayDescriptionControllers = [];

  static String _displayStringServiceTypeForOption(ServiceType option) =>
      option.name;
  static String _displayStringAdditionalServicesForOption(
          AdditionalService option) =>
      option.description;
  static String _displayStringSuppliersForOption(Supplier option) =>
      "${option.name} ${option.lastName}";

  @override
  void initState() {
    appState = context.read<MyAppState>();
    token = appState.appToken;
    selectedEvent = appState.selectedEvent;
    additionalServices.add(emptyAdditionalService);

    EventService()
        .getAdditionalServiceByEventId(token, selectedEvent!.id)
        .then((value) {
      setState(() {
        additionalServices.addAll(value);
      });
    });

    EventService().getServices(token).then((value) {
      setState(() {
        serviceTypes = value;
      });
    });

    EventService().getAllEventPayments(token, selectedEvent!.id).then((value) {
      setState(() {
        eventPays = value.isEmpty ? [] : value;
        buildEventPaymentsWidget();
      });
    });

    super.initState();
  }

  void buildEventPaymentsWidget() {
    try {
      if (eventPays.isNotEmpty) {
        for (var expense in eventPays) {
          eventPaymentsWidget(expense);
        }
      } else {
        eventPaymentsWidget();
      }
    } catch (e) {
      log("Error: $e");
      Flushbar(
        title: "Error",
        message: "Ocurrió un error al cargar los pagos: ${e.toString()}",
        duration: Duration(seconds: 3),
        icon: Icon(
          Icons.error,
          color: Colors.red,
        ),
      ).show(context);
    }
  }

  onSelectAdditionalService(int index, AdditionalService option) {
    if (option.description == emptyAdditionalService.description) {
      selectedAdditionalServices[index] = null;
      additionalServiceControllers[index].text = "Ninguno";
      additionalServiceReminderControllers[index].text = "";
      selectedServiceTypes[index] = null;
      selectedSuppliers[index] = null;
      serviceTypeControllers[index].text = "";
      supplierControllers[index].text = "";

      serviceTypeMaps[index] = serviceTypes;
      suppliersMap[index] = [];
    } else {
      double reminder = eventPays.isNotEmpty &&
              eventPays.where((e) => e.eventId == option.eventId).isNotEmpty
          ? option.supplierCost -
              eventPays
                  .where((e) => e.eventId == option.eventId)
                  .map((e) => e.amount)
                  .reduce((a, b) => a + b)
          : option.supplierCost;
      selectedAdditionalServices[index] = option;
      additionalServiceControllers[index].text = option.description.toString();
      additionalServiceReminderControllers[index].text = reminder.toString();
      selectedServiceTypes[index] = option.serviceType;
      selectedSuppliers[index] =
          option.supplier;
      serviceTypeControllers[index].text = option.serviceType.description;
      supplierControllers[index].text = option.supplier != null
          ? "${option.supplier!.name} ${option.supplier!.lastName}"
          : "";
      serviceTypeMaps[index] = [];
      suppliersMap[index] = [];
    }
  }

  onSelectedServiceType(ServiceType option, int index) {
    EventService().getProvidersByService(token, option.id).then((value) {
      setState(() {
        selectedServiceTypes[index] = option;
        serviceTypeControllers[index].text = option.name.toString();

        if (suppliersMap.isNotEmpty && value.isNotEmpty) {
          suppliersMap[index] = value;
        } else {
          suppliersMap[index] = [];
        }
      });
    });
  }

  getSuppliersForServiceType(ServiceType serviceType, int index) {
    EventService().getProvidersByService(token, serviceType.id).then((value) {
      setState(() {
        if (suppliersMap.isNotEmpty && value.isNotEmpty) {
          suppliersMap[index] = value;
        } else {
          suppliersMap[index] = [];
        }
      });
    });
  }

  //TODO: Save expenses
  void saveAdditionalServices() {
    List<EventPay> eventPayments = [];
    for (int i = 0; i < expensesWidgets.length; i++) {
      EventPay eventPay = EventPay(
        id: eventPaymentIds[i],
        eventId: selectedEvent!.id,
        supplier: selectedSuppliers[i],
        additionalService: selectedAdditionalServices[i],
        paymentReason: "",
        description: eventPayDescriptionControllers[i].text,
        amount:
            double.parse(paymentValueControllers[i].text.replaceAll(",", "")),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        addedBy: appState!.selectedUser,
        updateBy: appState!.selectedUser,
      );
      eventPayments.add(eventPay);
    }
    EventService().saveEventPayments(token, eventPayments).then((value) {
      if (value.isNotEmpty) {
        setState(() {
          eventPays = value;
          expensesWidgets.clear();
          additionalServiceControllers.clear();
          serviceTypeControllers.clear();
          supplierControllers.clear();
          eventPayDescriptionControllers.clear();
          selectedAdditionalServices.clear();
          selectedServiceTypes.clear();
          selectedSuppliers.clear();
          buildEventPaymentsWidget();
        });
        Flushbar(
          title: "Guardado",
          message: "Los pagos han sido guardados exitosamente",
          flushbarPosition: FlushbarPosition.TOP,
          duration: Duration(seconds: 3),
          icon: Icon(
            Icons.check,
            color: Colors.green,
          ),
        ).show(context);
      } else {
        // Handle error
        Flushbar(
          title: "Error",
          message: "No se pudo guardar el pago",
          duration: Duration(seconds: 3),
          icon: Icon(
            Icons.error,
            color: Colors.orange,
          ),
        ).show(context);
      }
    });
  }

  void deleteEventPayments(int index) {
    if (eventPaymentIds[index] > 0) {
      EventService()
          .deleteEventPayment(eventPaymentIds[index], token)
          .then((value) {
        if (value.isEmpty) {
          removeControls(index);
          Flushbar(
            title: "Eliminado",
            message: "El pago ha sido eliminado exitosamente",
            duration: Duration(seconds: 3),
            icon: Icon(
              Icons.check,
              color: Colors.green,
            ),
          ).show(context);
        } else {
          Flushbar(
            title: "Error",
            message: "No se pudo eliminar el pago: $value",
            duration: Duration(seconds: 3),
            icon: Icon(
              Icons.error,
              color: Colors.red,
            ),
          ).show(context);
        }
      });
    } else {
      removeControls(index);
    }
  }

  void removeControls(int index) {
    setState(() {
      expensesWidgets.removeAt(index);
      eventPaymentIds.removeAt(index);
      additionalServiceControllers.removeAt(index);
      additionalServiceReminderControllers.removeAt(index);
      serviceTypeControllers.removeAt(index);
      supplierControllers.removeAt(index);
      eventPayDescriptionControllers.removeAt(index);
      paymentValueControllers.removeAt(index);
      serviceTypeMaps.remove(index);
      suppliersMap.remove(index);

      selectedAdditionalServices.removeAt(index);
      selectedServiceTypes.removeAt(index);
      selectedSuppliers.removeAt(index);
    });
  }

  void eventPaymentsWidget([EventPay? eventPay]) {
    FocusNode supplierFocusNode = FocusNode();

    TextEditingController additionalServiceController = TextEditingController();
    TextEditingController additionalServiceReminderController =
        TextEditingController();
    TextEditingController serviceTypeController = TextEditingController();
    TextEditingController supplierEditorController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController paymentValueController = TextEditingController();

    int index = expensesWidgets.length;

    if (eventPay != null) {
      // ignore: unnecessary_null_comparison

      eventPaymentIds.add(eventPay.id);
      suppliersMap[index] = [];
      serviceTypeMaps[index] =
          eventPay.additionalService != null ? [] : serviceTypes;

      additionalServiceController.text = eventPay.additionalService != null
          ? eventPay.additionalService!.description
          : "";

      double reminder = eventPay.additionalService != null &&
              eventPays.isNotEmpty &&
              eventPays
                  .where((e) =>
                      e.eventId == eventPay.eventId &&
                      e.additionalService != null &&
                      e.additionalService!.id == eventPay.additionalService!.id)
                  .isNotEmpty
          ? eventPay.additionalService!.supplierCost -
              eventPays
                  .where((e) =>
                      e.eventId == eventPay.eventId &&
                      e.additionalService != null &&
                      e.additionalService!.id == eventPay.additionalService!.id)
                  .map((e) => e.amount)
                  .reduce((a, b) => a + b)
                  .toDouble()
          : eventPay.additionalService != null
              ? eventPay.additionalService!.supplierCost
              : 0.0;

      additionalServiceReminderController.text = reminder.toString();
      supplierEditorController.text = eventPay.supplier != null
          ? "${eventPay.supplier!.name} ${eventPay.supplier!.lastName}"
          : "";
      serviceTypeController.text = eventPay.supplier != null
          ? eventPay.supplier!.serviceType.description
          : (eventPay.additionalService != null
              ? eventPay.additionalService!.serviceType.description
              : "");
      paymentValueController.text = eventPay.amount.toString();
      descriptionController.text = eventPay.description;

      var selectedAdditional = eventPay.additionalService;
      ServiceType? selectedServiceType;
      Supplier? selectedSupplier = eventPay.supplier;
      if (selectedAdditional != null) {
        selectedServiceType = selectedAdditional.serviceType;
        selectedSupplier = selectedAdditional.supplier;
      }

      selectedAdditionalServices.add(selectedAdditional);
      selectedServiceTypes.add(selectedServiceType);
      selectedSuppliers.add(selectedSupplier);
    } else {
      eventPaymentIds.add(0);
      suppliersMap[index] = [];
      serviceTypeMaps[index] = serviceTypes;

      selectedAdditionalServices.add(null);
      selectedServiceTypes.add(null);
      selectedSuppliers.add(null);
    }

    additionalServiceControllers.add(additionalServiceController);
    additionalServiceReminderControllers
        .add(additionalServiceReminderController);
    serviceTypeControllers.add(serviceTypeController);
    supplierControllers.add(supplierEditorController);
    eventPayDescriptionControllers.add(descriptionController);
    paymentValueControllers.add(paymentValueController);

    setState(() {
      expensesWidgets.add(Column(
        children: [
          SizedBox(
            height: 22,
          ),
          Row(
            children: [
              SizedBox(
                width: 20,
              ),
              Visibility(
                  visible:
                      selectedEvent != null && selectedEvent!.eventType.id != 3,
                  child: Expanded(
                      child: RawAutocomplete<AdditionalService>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      return additionalServices.isEmpty
                          ? []
                          : additionalServices
                              .where((AdditionalService option) {
                              return option.description
                                  .toLowerCase()
                                  .startsWith(
                                      textEditingValue.text.toLowerCase());
                            }).toList();
                    },
                    textEditingController: additionalServiceController,
                    focusNode: FocusNode(),
                    displayStringForOption:
                        _displayStringAdditionalServicesForOption,
                    optionsViewBuilder: (BuildContext context,
                        AutocompleteOnSelected<AdditionalService> onSelected,
                        Iterable<AdditionalService> options) {
                      return Material(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option = options.elementAt(index);
                            return ListTile(
                              title: Text(
                                  _displayStringAdditionalServicesForOption(
                                      option)),
                              onTap: () {
                                onSelected(option);
                              },
                            );
                          },
                        ),
                      );
                    },
                    onSelected: (AdditionalService option) {
                      setState(() {
                        onSelectAdditionalService(index, option);
                      });
                    },
                    fieldViewBuilder: (context, textEditingController,
                            focusNode, onFieldSubmitted) =>
                        TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Servicio adicional',
                            )),
                  ))),
              SizedBox(width: 15),
              Visibility(
                  visible:
                      selectedEvent != null && selectedEvent!.eventType.id != 3,
                  child: Expanded(
                      child: TextField(
                    controller: additionalServiceReminderController,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Restante',
                    ),
                  ))),
              SizedBox(
                width: 20,
              ),
              Expanded(
                  child: RawAutocomplete<ServiceType>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return serviceTypeMaps[index]!.isEmpty
                      ? []
                      : serviceTypeMaps[index]!.where((ServiceType option) {
                          return option.name
                              .toLowerCase()
                              .startsWith(textEditingValue.text.toLowerCase());
                        }).toList();
                },
                textEditingController: serviceTypeController,
                focusNode: FocusNode(),
                displayStringForOption: _displayStringServiceTypeForOption,
                optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<ServiceType> onSelected,
                    Iterable<ServiceType> options) {
                  return Material(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title:
                              Text(_displayStringServiceTypeForOption(option)),
                          onTap: () {
                            onSelectedServiceType(option, index);
                            onSelected(option);
                          },
                        );
                      },
                    ),
                  );
                },
                onSelected: (ServiceType option) {
                  setState(() {
                    serviceTypeController.text = option.name;
                    getSuppliersForServiceType(option, index);
                  });
                },
                fieldViewBuilder: (context, textEditingController, focusNode,
                        onFieldSubmitted) =>
                    TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Tipo de servicio',
                        )),
              )),
              SizedBox(
                width: 20,
              ),
              Expanded(
                  child: RawAutocomplete<Supplier>(
                displayStringForOption: _displayStringSuppliersForOption,
                key: UniqueKey(),
                focusNode: supplierFocusNode,
                textEditingController: supplierEditorController,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (suppliersMap.isEmpty || suppliersMap[index] == null) {
                    return [];
                  }
                  return suppliersMap[index]!.where((Supplier option) {
                    return option.name
                        .toLowerCase()
                        .toLowerCase()
                        .startsWith(textEditingValue.text.toLowerCase());
                  }).toList();
                },
                optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<Supplier> onSelected,
                    Iterable<Supplier> options) {
                  return Material(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: Text(_displayStringSuppliersForOption(option)),
                          onTap: () {
                            onSelected(option);
                          },
                        );
                      },
                    ),
                  );
                },
                onSelected: (Supplier option) {
                  setState(() {
                    selectedSuppliers[index] = option;
                  });
                },
                fieldViewBuilder: (context, textEditingController, focusNode,
                        onFieldSubmitted) =>
                    TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        enabled: isEnableSupplier,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Proveedor',
                        )),
              )),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: TextFormField(
                  enabled: true,
                  validator: (value) => value!.isEmpty
                      ? "Por favor ingrese una descripción"
                      : null,
                  controller: descriptionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Descripción',
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: TextFormField(
                  controller: paymentValueController,
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  validator: (value) =>
                      value!.isEmpty ? "Por favor ingrese un monto" : null,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Monto pagado',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(Colors.red),
                ),
                onPressed: () {
                  if (eventPaymentIds[index] > 0) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Eliminar pago"),
                          content: Text(
                              "¿Estás seguro de que deseas eliminar este pago?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () {
                                deleteEventPayments(index);
                              },
                              child: Text("Eliminar"),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    removeControls(index);
                  }
                },
              ),
              SizedBox(
                width: 20,
              )
            ],
          )
        ],
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Pagos del evento"),
            backgroundColor: Colors.blue,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 22,
                ),
                Row(
                  children: [
                    SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        textAlign: TextAlign.left,
                        eventPays.isNotEmpty
                            ? "Total : \$${eventPays.map((e) => e.amount).reduce((a, b) => a + b).toStringAsFixed(2)}"
                            : "Total: \$0.00",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 22),
                Column(
                  children: expensesWidgets,
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ButtonStyle(
                          foregroundColor:
                              WidgetStateProperty.all(Colors.white),
                          textStyle: WidgetStateProperty.all(
                            TextStyle(fontSize: 20),
                          ),
                          backgroundColor: WidgetStateProperty.all(Colors.blue),
                        ),
                        onPressed: () {
                          eventPaymentsWidget();
                        },
                        child: Text("Agregar pago"),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        style: ButtonStyle(
                          foregroundColor:
                              WidgetStateProperty.all(Colors.white),
                          textStyle: WidgetStateProperty.all(
                            TextStyle(fontSize: 20),
                          ),
                          backgroundColor: WidgetStateProperty.all(Colors.blue),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Form is valid, proceed with saving
                            // Save Additional Services
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Guardar Pagos"),
                                  content: Text(
                                      "¿Estás seguro de que deseas guardar ?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Cancelar"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        try {
                                          saveAdditionalServices();
                                          Navigator.of(context).pop();
                                        } catch (e) {
                                          Flushbar(
                                            title: "Error",
                                            flushbarPosition:
                                                FlushbarPosition.TOP,
                                            message:
                                                "Ocurrió un error al guardar los pagos: ${e.toString()}",
                                            duration: Duration(seconds: 3),
                                            icon: Icon(
                                              Icons.error,
                                              color: Colors.orange,
                                            ),
                                          ).show(context);
                                        }
                                      },
                                      child: Text("Aceptar"),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            Flushbar(
                              title: "Error",
                              message: "Por favor complete todos los campos",
                              duration: Duration(seconds: 3),
                              icon: Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                            ).show(context);
                          }
                        },
                        child: Text("Guardar"),
                      ),
                    ),
                    Expanded(flex: 2, child: Text('')),
                  ],
                ),
                SizedBox(height: 22),
              ],
            ),
          ),
        ));
  }
}
