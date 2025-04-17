import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/formatters/ThousandsSeparatorInputFormatter.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/AdditionalService.dart';
import 'package:rg_event_management_ui/models/Event.dart';
import 'package:rg_event_management_ui/models/EventPay.dart';
import 'package:rg_event_management_ui/models/Supplier.dart';
import 'package:rg_event_management_ui/services/eventservice.dart';

class ExpensesEventPage extends StatefulWidget {
  @override
  _ExpensesEventPage createState() => _ExpensesEventPage();
}

class _ExpensesEventPage extends State<ExpensesEventPage> {
  var appState;
  final _formKey = GlobalKey<FormState>();
  var token = "";
  var selectedEvent;
  bool isEditMode = false;
  bool isEnableSupplier = true;
  List<ServiceType> services = [];
  Map<int, List<Supplier>> suppliersMap = {};
  List<AdditionalService> additionalServices = [];
  List<EventPay> expenses = [];
  List<Widget> expensesWidgets = [];

  // list controllres to keep track of the values

  List<int> eventPaymentIds = [];
  List<TextEditingController> eventPayDescriptionControllers = [];
  List<ServiceType?> selectedServiceTypes = [];
  List<TextEditingController> eventPaymentServiceTypeControllers = [];
  List<Supplier?> selectedAdditionalServiceSuppliers = [];
  List<TextEditingController> additionalServiceSupplierControllers = [];
  List<TextEditingController> paymentValueControllers = [];

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
        .getAdditionalServiceByEventId(token, selectedEvent.id)
        .then((value) {
      setState(() {
        additionalServices = value;
      });
    });

    EventService().getServices(token).then((value) {
      setState(() {
        services = value;
      });
    });

    EventService().getAllEventPayments(token, selectedEvent.id).then((value) {
      setState(() {
        expenses = value;
        if (value.isNotEmpty) {
          for (var expense in expenses) {
            eventPaymentsWidget(expense);
          }
        } else {
          eventPaymentsWidget();
        }
      });
    });

    super.initState();
  }

  onSelectedServiceType(ServiceType option, int index) {
    EventService().getProvidersByService(token, option.id).then((value) {
      setState(() {
        selectedServiceTypes[index] = option;
        eventPaymentServiceTypeControllers[index].text = option.name.toString();

        // selectedAdditionalServiceSuppliers[index] = null;
        // additionalServiceSupplierControllers[index].text = "";

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

  //TODO: Save Additional Services
  void saveAdditionalServices() {
    expenses = [];
    var eventTotalAdditional = 0.0;
    for (int i = 0; i < expensesWidgets.length; i++) {
  
    }
    selectedEvent!.totalAdditional = eventTotalAdditional;
    selectedEvent!.additionalServices.clear();
    selectedEvent!.additionalServices.addAll(expenses);

    EventService().createOrUpdateEvent(selectedEvent, token).then((value) {
      Flushbar(
        showProgressIndicator: true,
        flushbarPosition: FlushbarPosition.TOP,
        backgroundColor: Colors.green,
        title: "Pago de nomina del evento",
        message: "Servicios adicionales guardados correctamente",
        duration: Duration(seconds: 3),
      ).show(context);
    });
  }

  void eventPaymentsWidget([EventPay? eventPay]) {
    TextEditingController additionalServiceDescriptionController = TextEditingController();
    TextEditingController serviceTypeController = TextEditingController();
    TextEditingController supplierEditorController = TextEditingController();
    
    FocusNode additionalServiceDescriptionFocusNode = FocusNode();
    FocusNode serviceTypeFocusNode = FocusNode();
    FocusNode supplierFocusNode = FocusNode();
    
    TextEditingController descriptionController = TextEditingController();
    TextEditingController paymentValueController = TextEditingController();

    int index = expensesWidgets.length;
    AdditionalService? selectedAdditionalService;
    ServiceType? selectedServiceType;
    Supplier? selectedSupplier;

    if (eventPay != null) {
      // selectedAdditionalService = eventPay!.supplier!.
      descriptionController.text = eventPay.description;

      supplierEditorController.text = selectedSupplier != null
          ? "${selectedSupplier.name} ${eventPay.supplier.lastName}"
          : "";

      paymentValueController.text = eventPay.amount.toString();
      eventPaymentIds.add(eventPay.id);
      eventPayDescriptionControllers.add(descriptionController);
      eventPaymentServiceTypeControllers.add(serviceTypeController);
      selectedAdditionalServiceSuppliers.add(selectedSupplier);
      additionalServiceSupplierControllers.add(supplierEditorController);

      suppliersMap[index] = [];
    } else {
      eventPaymentIds.add(0);
      eventPayDescriptionControllers.add(descriptionController);
      eventPaymentServiceTypeControllers.add(serviceTypeController);
      selectedAdditionalServiceSuppliers.add(selectedSupplier);
      additionalServiceSupplierControllers.add(supplierEditorController);

      suppliersMap[index] = [];
    }

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
                        isEnableSupplier = false;
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
                  return services.isEmpty
                      ? []
                      : services.where((ServiceType option) {
                          return option.name
                              .toLowerCase()
                              .startsWith(textEditingValue.text.toLowerCase());
                        }).toList();
                },
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
                    selectedServiceType = option;
                    serviceTypeController.text = option.name;
                    getSuppliersForServiceType(option, index);
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
                    // log("No suppliers found");
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
                  // setState(() {
                  //   selectedAdditionalServiceSuppliers[index] = option;
                  //   additionalServiceSupplierControllers[index].text = "${option.name} ${option.lastName}";
                  // });
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
                              setState(() {
                                expensesWidgets.removeAt(index - 1);
                              });
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
