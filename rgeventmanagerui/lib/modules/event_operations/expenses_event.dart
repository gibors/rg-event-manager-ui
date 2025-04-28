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
  var appState;
  var token = "";
  var selectedEvent;
  bool isEditMode = false;
  bool isEnableSupplier = true;
  List<ServiceType> serviceTypes = [];
  Map<int, List<Supplier>> suppliersMap = {};
  Map<int, List<ServiceType>> serviceTypeMaps = {};

  List<AdditionalService> additionalServices = [];
  List<EventPay> expenses = [];
  List<Widget> expensesWidgets = [];

  // list controllers to keep track of the values

  List<int> eventPaymentIds = [];
  List<AdditionalService?> selectedAdditionalServices = [];
  List<ServiceType?> selectedServiceTypes = [];
  List<Supplier?> selectedSuppliers = [];

  List<TextEditingController> additionalServiceControllers = [];
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

    EventService()
        .getAdditionalServiceByEventId(token, selectedEvent!.id)
        .then((value) {
      setState(() {
        additionalServices = value;
      });
    });

    EventService().getServices(token).then((value) {
      setState(() {
        serviceTypes = value;
      });
    });

    EventService().getAllEventPayments(token, selectedEvent!.id).then((value) {
      setState(() {
        expenses = value;
      });
    });

    buildEventPaymentsWidget();

    super.initState();
  }

  void buildEventPaymentsWidget() {
    if (expenses.isNotEmpty) {
      for (var expense in expenses) {
        eventPaymentsWidget(expense);
      }
    } else {
      eventPaymentsWidget();
    }
  }

  onSelectAdditionalService(int index, AdditionalService option) {
    selectedAdditionalServices[index] = option;
    selectedServiceTypes[index] = option.serviceType;
    serviceTypeControllers[index].text = option.serviceType.description;
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
        amount: double.parse(paymentValueControllers[i].text.replaceAll(",", "")),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        addedBy: appState.user,
        updateBy: appState.user,
      );
      eventPayments.add(eventPay);
    }
    EventService().saveEventPayments(token, eventPayments).then((value) {
      if (value.isNotEmpty) {
        setState(() {
          expenses = value;
          expensesWidgets.clear();
          additionalServiceControllers.clear();
          serviceTypeControllers.clear();
          supplierControllers.clear();
          eventPayDescriptionControllers.clear();
          selectedAdditionalServices.clear();
          selectedServiceTypes.clear();
          selectedSuppliers.clear();
        });
        buildEventPaymentsWidget();
      } else {
        // Handle error
        
      }
    });
  }


//TODO: Delete event payment
  void deleteEventPayments(int index) {
    setState(() {
      expensesWidgets.removeAt(index);
      eventPaymentIds.removeAt(index);
      additionalServiceControllers.removeAt(index);
      serviceTypeControllers.removeAt(index);
      supplierControllers.removeAt(index);
      eventPayDescriptionControllers.removeAt(index);
      selectedAdditionalServices.removeAt(index);
      selectedServiceTypes.removeAt(index);
      selectedSuppliers.removeAt(index);  
    });
  }

  void eventPaymentsWidget([EventPay? eventPay]) {
    FocusNode supplierFocusNode = FocusNode();

    TextEditingController additionalServiceController = TextEditingController();
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

      additionalServiceController.text = ""; // TODO:
      supplierEditorController.text = eventPay.supplier != null
          ? "${eventPay.supplier!.name} ${eventPay.supplier!.lastName}"
          : "";
      serviceTypeController.text = eventPay.supplier != null
          ? eventPay.supplier!.serviceType.description
          : "";
      paymentValueController.text = eventPay.amount.toString();
      descriptionController.text = eventPay.description;

      selectedAdditionalServices.add(eventPay.additionalService!);
      selectedServiceTypes.add(eventPay.additionalService!.serviceType);
    } else {
      eventPaymentIds.add(0);
      suppliersMap[index] = [];
      serviceTypeMaps[index] = serviceTypes;
      selectedAdditionalServices.add(null);
      selectedServiceTypes.add(null);
    }

    additionalServiceControllers.add(additionalServiceController);
    serviceTypeControllers.add(serviceTypeController);
    supplierControllers.add(supplierEditorController);
    eventPayDescriptionControllers.add(descriptionController);

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
                              Navigator.of(context).pop();
                            },
                            child: Text("Eliminar"),
                          ),
                        ],
                      );
                    },
                  );
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
    var appState = context.read<MyAppState>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Pagos del evento"),
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
                    expenses.isNotEmpty
                        ? "Total : \$${expenses.map((e) => e.amount).reduce((a, b) => a + b).toStringAsFixed(2)}"
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
                      foregroundColor: WidgetStateProperty.all(Colors.white),
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
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      textStyle: WidgetStateProperty.all(
                        TextStyle(fontSize: 20),
                      ),
                      backgroundColor: WidgetStateProperty.all(Colors.blue),
                    ),
                    onPressed: () {
                      // Save Additional Services
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Guardar Pagos"),
                            content:
                                Text("¿Estás seguro de que deseas guardar ?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Cancelar"),
                              ),
                              TextButton(
                                onPressed: () {
                                  saveAdditionalServices();
                                  Navigator.of(context).pop();
                                },
                                child: Text("Aceptar"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text("Guardar"),
                  ),
                ),
                Expanded(flex: 2, child: Text('')),
              ],
            ),
            SizedBox(height: 22),
            // Row( children: [

            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
