import 'dart:io';
import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/formatters/ThousandsSeparatorInputFormatter.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/EventEmployeePayment.dart';
import 'package:rg_event_management_ui/models/Supplier.dart';
import 'package:rg_event_management_ui/services/eventservice.dart';

class AddEmployeePaymentPage extends StatefulWidget {
  @override
  _AddEmployeePaymentPage createState() => _AddEmployeePaymentPage();
}

class _AddEmployeePaymentPage extends State<AddEmployeePaymentPage> {
  var appState;
  final _formKey = GlobalKey<FormState>();
  var token = "";
  var selectedEvent;
  bool isEditMode = false;

  Map<String, List<String>> jobCategories = {
    'Operativo': [
      'Equipo de montaje',
      'Audio DJ o grupo musical',
      'Iluminación',
      'Capitana de lavalozas',
      'Lavalozas'
    ],
    'Cocina': ['Capitana de cocina', 'Ayudantes de Cocina'],
    'Atención': [
      'Anfitrión',
      'Encargada de hostess',
      'Hostess',
      'Capitán de meseros',
      'Meseros',
      'Supervisor',
      'Coordinador'
    ]
  };

  Map<int, List<String>> jobMap = {};

  List<EventEmployeePayment> eventEmployeePayments = [];
  List<Widget> employeePaymentsWidgets = [];

  List<int> nominaIds = [];
  List<TextEditingController> jobCategoriesControllers = [];
  List<TextEditingController> JobPositionControllers = [];
  List<TextEditingController> employeesQuantityTypeControllers = [];
  List<TextEditingController> unitPaymentsControllers = [];
  List<TextEditingController> SubTotalControllers = [];
  List<String?> selectedCategory = [];
  List<String?> selectedJob = [];

  @override
  void initState() {
    appState = context.read<MyAppState>();
    token = appState.appToken;
    selectedEvent = appState.selectedEvent;

    EventService()
        .getEventEmployeePayments(token, selectedEvent!.id)
        .then((value) {
      if (value.isNotEmpty) {
        setState(() {
          eventEmployeePayments = value;
          buildEmployeePaymentsWidgets();
        });
      } else {
        setState(() {
          eventEmployeePayments = [];
          buildEmployeePaymentsWidgets();
        });
      }
    });

    super.initState();
  }

  //TODO:
  void saveEmployeePayments() {
    eventEmployeePayments = [];
    var widgetsWithColumns =
        employeePaymentsWidgets.whereType<Column>().toList();
    for (int i = 0; i < widgetsWithColumns.length; i++) {
      var quantity = double.parse(employeesQuantityTypeControllers[i].text);
      var unitPayment = double.parse(unitPaymentsControllers[i].text);
      var subTotal = quantity * unitPayment;
      var employeePayment = EventEmployeePayment(
        id: nominaIds[i],
        jobCategory: jobCategoriesControllers[i].text,
        job: JobPositionControllers[i].text,
        quantity: quantity,
        unitPayment: unitPayment,
        subtotal: subTotal,
        event: selectedEvent!,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        addedBy: appState.selectedUser!,
        updateBy: appState.selectedUser!,
      );
      setState(() {
        eventEmployeePayments.add(employeePayment);
      });
    }
    EventService()
        .saveEventEmployeePayment(
            eventEmployeePayments, token, selectedEvent!.id)
        .then((value) {
      if (value.isNotEmpty) {
        setState(() {
          employeePaymentsWidgets = [];
          eventEmployeePayments = value;
          buildEmployeePaymentsWidgets();
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Guardado"),
              content: Text("Los pagos de nómina se guardaron correctamente"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Aceptar"),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Ocurrió un error al guardar los pagos de nómina"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Aceptar"),
                ),
              ],
            );
          },
        );
      }
    });
  }

  void buildEmployeePaymentsWidgets() {
    if (eventEmployeePayments.isNotEmpty) {
      for (var cat in jobCategories.keys) {
        addSeparator(cat);

        var employeesInCategory = eventEmployeePayments
            .where((element) => element.jobCategory == cat)
            .toList();

        for (var emp in employeesInCategory) {
          addNominaWidget(cat, emp.job, emp);
        }
      }
    } else {
      for (var cat in jobCategories.keys) {
        addSeparator(cat);
        for (var job in jobCategories[cat]!) {
          addNominaWidget(cat, job);
        }
      }
    }
  }

  addSeparator(category) {
    setState(() {
      employeePaymentsWidgets.add(SizedBox(
        height: 22,
      ));
      employeePaymentsWidgets.add(Text(
        category,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ));
      employeePaymentsWidgets.add(
        Divider(
          color: Colors.black,
          height: 2,
          thickness: 2,
        ),
      );
    });
  }

  void DownloadEventEmployeePayments() {
    var path = Directory.current.path;
    try {
      final file = DirectoryPicker()..title = 'Select a directory';

      final result = file.getDirectory();
      if (result != null) {
        print(result.path);
        path = result.path;
      }
    } catch (e) {
      print("Error: $e");
    }
    try {
      EventService()
          .DownloadEventEmployeePayments(token, selectedEvent!.id, path)
          .then((value) {
        Flushbar(
          icon: Icon(
            Icons.check,
            size: 28.0,
            color: Colors.green[300],
          ),
          flushbarPosition: FlushbarPosition.TOP,
          title: "Descarga exitosa",
          message: "La nómina se descargó correctamente en $path",
          duration: Duration(seconds: 5),
        ).show(context);
            });
    } catch (e) {
      print("Error: $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Ocurrió un error al descargar la nómina"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Aceptar"),
              ),
            ],
          );
        },
      );
    }
  }

  void addNominaWidget(category, job, [EventEmployeePayment? employeePayment]) {
    TextEditingController categoryController = TextEditingController();
    TextEditingController jobController = TextEditingController();
    TextEditingController employeeQuantityController = TextEditingController();
    TextEditingController unitPaymentController = TextEditingController();
    TextEditingController subTotalController = TextEditingController();
    final autocompleteCategoryKey = GlobalKey();
    final focusCategory = FocusNode();
    final autocompleteJob = GlobalKey();
    final focusJob = FocusNode();

    if (employeePayment != null) {
      nominaIds.add(employeePayment.id);
      categoryController.text = employeePayment.jobCategory;
      jobController.text = employeePayment.job;
      employeeQuantityController.text = employeePayment.quantity.toString();
      unitPaymentController.text = employeePayment.unitPayment.toString();
      subTotalController.text = employeePayment.subtotal.toString();
    } else {
      nominaIds.add(0);
      categoryController.text = category;
      jobController.text = job;
      employeeQuantityController.text = '0';
      unitPaymentController.text = '0';
      subTotalController.text = '0';
    }
    jobCategoriesControllers.add(categoryController);
    JobPositionControllers.add(jobController);
    employeesQuantityTypeControllers.add(employeeQuantityController);
    unitPaymentsControllers.add(unitPaymentController);
    SubTotalControllers.add(subTotalController);

    setState(() {
      employeePaymentsWidgets.add(Column(
        children: [
          SizedBox(
            height: 22,
          ),
          Row(
            children: [
              SizedBox(
                width: 20,
              ),
              Expanded(child: Text(job)),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: TextFormField(
                  controller: employeeQuantityController,
                  // inputFormatters: [ThousandsSeparatorInputFormatter()],
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty
                      ? 'La cantidad de empleados es requerida'
                      : null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Cantidad de empleados",
                    hintText: "Cantidad de empleados",
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: TextFormField(
                  // inputFormatters: [ThousandsSeparatorInputFormatter()],
                  controller: unitPaymentController,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'El pago unitario es requerido' : null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Pago unitario",
                    hintText: "Pago unitario",
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: TextFormField(
                  enabled: false,
                  controller: subTotalController,
                  validator: (value) =>
                      value!.isEmpty ? 'El subtotal es requerido' : null,
                  // inputFormatters: [ThousandsSeparatorInputFormatter()],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Subtotal",
                    hintText: "Subtotal",
                  ),
                ),
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
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Nómina del Evento"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Salir"),
                    content: Text("¿Estás seguro de que deseas salir?"),
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
                          Navigator.of(context).pop();
                        },
                        child: Text("Salir"),
                      ),
                    ],
                  );
                },
              );
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
                          'Total de Pago de Nomina: ${eventEmployeePayments.isNotEmpty ? eventEmployeePayments.map((e) => e.subtotal).reduce((a, b) => a + b).toString() : '0'}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ))),
                  SizedBox(width: 300),
                ],
              ),
              SizedBox(height: 22),
              Row(
                children: [
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
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Guardar pagos de nómina"),
                              content: Text(
                                  "¿Estás seguro de que deseas guardar estos cambios?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Cancelar"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    saveEmployeePayments();
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
                        DownloadEventEmployeePayments();
                      },
                      child: Text("Descargar Nomina"),
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
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Salir"),
                              content:
                                  Text("¿Estás seguro de que deseas salir?"),
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
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Salir"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text("Cancelar"),
                    ),
                  ),
                  Expanded(flex: 2, child: Text('')),
                ],
              ),
              Column(
                children: employeePaymentsWidgets,
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
