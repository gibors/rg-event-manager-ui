import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/formatters/ThousandsSeparatorInputFormatter.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/AdditionalService.dart';
import 'package:rg_event_management_ui/models/Supplier.dart';
import 'package:rg_event_management_ui/services/eventservice.dart';

class AdditionalServices extends StatefulWidget {
  @override
  _AdditionalServices createState() => _AdditionalServices();
}

class _AdditionalServices extends State<AdditionalServices> {
  var appState;
  final _formKey = GlobalKey<FormState>();
  var token = "";
  var selectedEvent;
  bool isEditMode = false;
  List<ServiceType> services = [];
  Map<int, List<Supplier>> suppliersMap = {};

  // arrays of models and widgets
  List<AdditionalService> additionalServices = [];
  List<Widget> additionalServicesWidgets = [];
  List<int> additionalServiceIds = [];
  List<ServiceType?> selectedAdditionalServiceTypes = [];
  List<Supplier?> selectedAdditionalServiceSuppliers = [];

  // Controllers
  List<TextEditingController> additionalServiceDescriptionControllers = [];
  List<TextEditingController> additionalServiceServiceTypeControllers = [];
  List<TextEditingController> additionalServiceSupplierControllers = [];
  List<TextEditingController> additionalServiceCostControllers = [];
  List<TextEditingController> additionalServiceSupplierCostControllers = [];

  // Display strings for options
  static String _displayStringServicesForOption(ServiceType option) =>
      option.name;
  static String _displayStringSuppliersForOption(Supplier option) =>
      "${option.name} ${option.lastName}";

  @override
  void initState() {
    appState = context.read<MyAppState>();
    token = appState.appToken;
    selectedEvent = appState.selectedEvent;

    BuildAdditionalServiceWidget();

    EventService().getServices(token).then((value) {
      setState(() {
        services = value;
      });
    });

    super.initState();
  }

  // Build widget for each additional service
  void BuildAdditionalServiceWidget() {
    additionalServicesWidgets = [];
    additionalServiceIds = [];
    additionalServiceDescriptionControllers = [];
    additionalServiceServiceTypeControllers = [];
    additionalServiceSupplierControllers = [];
    additionalServiceCostControllers = [];
    additionalServiceSupplierCostControllers = [];
    selectedAdditionalServiceTypes = [];
    selectedAdditionalServiceSuppliers = [];
    suppliersMap = {};
    additionalServices = [];

    additionalServices =
        selectedEvent != null ? selectedEvent.additionalServices : [];

    if (additionalServices.isNotEmpty) {
      for (var additionalService in additionalServices) {
        addAdditionalServiceWidget(additionalService);
      }
    } else {
      addAdditionalServiceWidget();
    }
  }

  onSelectedServiceType(ServiceType option, int index) {
    EventService().getProvidersByService(token, option.id).then((value) {
      setState(() {
        selectedAdditionalServiceTypes[index] = option;
        additionalServiceServiceTypeControllers[index].text =
            option.name.toString();

        selectedAdditionalServiceSuppliers[index] = null;
        additionalServiceSupplierControllers[index].text = "";

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
    additionalServices = [];
    var eventTotalAdditional = 0.0;
    for (int i = 0; i < additionalServicesWidgets.length; i++) {
      AdditionalService additionalService = AdditionalService(
        id: additionalServiceIds[i],
        eventId: selectedEvent!.id,
        description: additionalServiceDescriptionControllers[i].text,
        serviceType: selectedAdditionalServiceTypes[i]!,
        supplier: selectedAdditionalServiceSuppliers[i],
        cost: double.parse(
            additionalServiceCostControllers[i].text.replaceAll(",", "")),
        supplierCost: double.parse(additionalServiceSupplierCostControllers[i]
            .text
            .replaceAll(",", "")),
        quantity: 0,
      );
      eventTotalAdditional += additionalService.cost;
      additionalServices.add(additionalService);
    }
    selectedEvent!.totalAdditional = eventTotalAdditional;
    selectedEvent!.additionalServices.clear();
    selectedEvent!.additionalServices.addAll(additionalServices);

    EventService().createOrUpdateEvent(selectedEvent, token).then((value) {
      setState(() {
        appState.selectedEvent = value;
        BuildAdditionalServiceWidget();
      });
      Flushbar(
        showProgressIndicator: true,
        flushbarPosition: FlushbarPosition.TOP,
        backgroundColor: Colors.green,
        title: "Servicios Adicionales",
        message: "Servicios adicionales guardados correctamente",
        duration: Duration(seconds: 3),
      ).show(context);
    });
  }

  void addAdditionalServiceWidget([AdditionalService? additionalService]) {
    TextEditingController serviceTypeController = TextEditingController();
    FocusNode serviceTypeFocusNode = FocusNode();
    TextEditingController supplierEditorController = TextEditingController();
    FocusNode supplierFocusNode = FocusNode();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController customerCostController = TextEditingController();
    TextEditingController supplierCostController = TextEditingController();

    int index = additionalServicesWidgets.length;
    ServiceType? selectedServiceType;
    Supplier? selectedSupplier;

    if (additionalService != null) {
      descriptionController.text = additionalService.description;
      serviceTypeController.text = additionalService.serviceType.name;
      selectedServiceType = additionalService.serviceType;
      serviceTypeController.text = additionalService.serviceType.name;

      if (additionalService.supplier != null) {
        selectedSupplier = additionalService.supplier;
      }

      supplierEditorController.text = selectedSupplier != null
          ? "${selectedSupplier.name} ${additionalService.supplier!.lastName}"
          : "";
      customerCostController.text = additionalService.cost.toString();
      supplierCostController.text = additionalService.supplierCost.toString();

      additionalServiceIds.add(additionalService.id);

      suppliersMap[index] = [];
      getSuppliersForServiceType(selectedServiceType, index);
    } else {
      additionalServiceIds.add(0);
      suppliersMap[index] = [];
    }

    additionalServiceServiceTypeControllers.add(serviceTypeController);
    selectedAdditionalServiceTypes.add(selectedServiceType);

    additionalServiceSupplierControllers.add(supplierEditorController);
    selectedAdditionalServiceSuppliers.add(selectedSupplier);

    additionalServiceCostControllers.add(customerCostController);
    additionalServiceSupplierCostControllers.add(supplierCostController);
    additionalServiceDescriptionControllers.add(descriptionController);

    setState(() {
      additionalServicesWidgets.add(Column(
        children: [
          SizedBox(
            height: 22,
          ),
          Row(
            children: [
              SizedBox(
                width: 20,
              ),
              Expanded(
                  child: RawAutocomplete<ServiceType>(
                displayStringForOption: _displayStringServicesForOption,
                key: UniqueKey(),
                focusNode: serviceTypeFocusNode,
                textEditingController: serviceTypeController,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return services.where((ServiceType option) {
                    return option.name
                        .toLowerCase()
                        .toLowerCase()
                        .startsWith(textEditingValue.text.toLowerCase());
                  }).toList();
                },
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
                          title: Text(_displayStringServicesForOption(option)),
                          onTap: () {
                            onSelected(option);
                          },
                        );
                      },
                    ),
                  );
                },
                onSelected: (ServiceType option) {
                  onSelectedServiceType(option, index);
                },
                fieldViewBuilder: (context, textEditingController, focusNode,
                        onFieldSubmitted) =>
                    TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Tipo de Servicio',
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
                  setState(() {
                    selectedAdditionalServiceSuppliers[index] = option;
                    additionalServiceSupplierControllers[index].text =
                        "${option.name} ${option.lastName}";
                  });
                },
                fieldViewBuilder: (context, textEditingController, focusNode,
                        onFieldSubmitted) =>
                    TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
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
                  controller: customerCostController,
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Costo cliente",
                    hintText: "Costo cliente",
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: TextFormField(
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  controller: supplierCostController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Costo proveedor",
                    hintText: "Costo proveedor",
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Descripción",
                    hintText: "Descripción",
                  ),
                ),
              ),
              SizedBox(
                width: 20,
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
                        title: Text("Eliminar Pago"),
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
                              deleteAdditionalServiceWidget(index);
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

  void deleteAdditionalServiceWidget(int index) {
    setState(() {
      additionalServicesWidgets.removeAt(index);
      additionalServiceIds.removeAt(index);
      additionalServiceDescriptionControllers.removeAt(index);
      additionalServiceServiceTypeControllers.removeAt(index);
      additionalServiceSupplierControllers.removeAt(index);
      additionalServiceCostControllers.removeAt(index);
      additionalServiceSupplierCostControllers.removeAt(index);
      selectedAdditionalServiceTypes.removeAt(index);
      selectedAdditionalServiceSuppliers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.read<MyAppState>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Servicios Adicionales"),
        backgroundColor: Colors.blue,
        leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('¿Estás seguro de salir?'),
                        content:
                            Text('Si sales se perderán los cambios realizados'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => {
                              appState.setIndex(0),
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => EventsHomePage(),
                                ),
                              )
                            },
                            child: Text('Salir'),
                          ),
                        ],
                      );
                    }),
              },
            ),
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
                  additionalServices.isNotEmpty
                      ? "Total : \$${selectedEvent!.totalAdditional.toString()}"
                      : "Total: \$0.00",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )),
                SizedBox(width: 20),
              ],
            ),
            SizedBox(height: 22),
            Column(
              children: additionalServicesWidgets,
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
                      addAdditionalServiceWidget();
                    },
                    child: Text("Agregar Servicio"),
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
                            title: Text("Guardar Servicios Adicionales"),
                            content: Text(
                                "¿Estás seguro de que deseas guardar los servicios adicionales?"),
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
