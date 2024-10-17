import 'dart:developer';
import 'package:another_flushbar/flushbar.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/Student.dart';
import 'package:rg_event_management_ui/modules/graduationlist.dart';
import 'package:rg_event_management_ui/services/eventservice.dart';

class EventPaymentPage extends StatefulWidget {
  @override
  _EventPaymentPageState createState() => _EventPaymentPageState();
}

class _EventPaymentPageState extends State<EventPaymentPage> {
  bool isEditMode = false;
  bool isGraduation = false;
  bool isNewStudent = false;
  var token = "";
  var selectedStudent;
  var selectedEvent;
  var appState;

  final _formKey = GlobalKey<FormState>();
  final GlobalKey _packageTypeKey = GlobalKey();
  final GlobalKey _paymentMethodKey = GlobalKey();
  final FocusNode _packageTypeFocus = FocusNode();
  final FocusNode _paymentMethodFocus = FocusNode();
  var _studentName = TextEditingController();
  var _studentLastName = TextEditingController();
  var _packageType = TextEditingController();
  var _dishNumber = TextEditingController();
  var _paymentMethodController = TextEditingController();
  var _additionalNumber = TextEditingController();
  var _comment = TextEditingController();
  var _paymentAmount = TextEditingController();
  var _paymentDetail = TextEditingController();
  var _paymentDetailKey = GlobalKey<FormFieldState>();
  var _paymentDetailFocus = FocusNode();

  List<Payment> paymentsHistory = [];

  List<String> packageTypes = [];

  List<String> paymentMethods = ['Efectivo', 'Tarjeta', 'Transferencia'];
  List<String> paymentDetails = [];

  @override
  void initState() {
    appState = context.read<MyAppState>();
    selectedStudent = appState.selectedStudent;
    selectedEvent = appState.selectedEvent;
    token = appState.appToken;

    if (selectedEvent != null && selectedEvent!.eventType.id == 3) {
      isGraduation = true;

      if (selectedEvent.pricing!.paq10TICost > 0) {
        packageTypes.add('paq10ti');
      }
      if (selectedEvent.pricing!.paq10SPCost > 0) {
        packageTypes.add('paq10sp');
      }
      if (selectedEvent.pricing!.paq5TIPCost > 0) {
        packageTypes.add('paq5ti');
      }
      if (selectedEvent.pricing!.paq5SPCost > 0) {
        packageTypes.add('paq5sp');
      }
      if (selectedEvent.pricing!.paq10DoubleCost > 0) {
        packageTypes.add('paq20');
      }

      if (packageTypes.isNotEmpty) {
        if(selectedStudent != null && selectedStudent.folio.isNotEmpty){
          paymentDetails.add('adicional');
        } else {
          paymentDetails.add('paquete');
        }
        paymentDetails.add('souvenir');
        paymentDetails.add('pre-fiesta');
        paymentDetails.add('pulsera');
      } else {
        paymentDetails.add('platillo');
        paymentDetails.add('souvenir');
        paymentDetails.add('pre-fiesta');
      }

      if (selectedStudent == null) {
        isNewStudent = true;
        isEditMode = true;
      } else {
        mapSelectedStudent();
        isNewStudent = false;
      }
    } else {
      isGraduation = false;
      EventService()
          .getPaymentsByEventId(token, selectedEvent!.id)
          .then((payments) {
        setState(() {
          paymentsHistory = payments;
        });
      });
    }
    super.initState();
  }

  mapSelectedStudent() {
    _studentName.text = selectedStudent!.name;
    _studentLastName.text = selectedStudent!.lastName;
    _packageType.text = selectedStudent!.packageType;
    _additionalNumber.text = selectedStudent!.additionalNumber.toString();
    _comment.text = selectedStudent!.comments;
    paymentsHistory = selectedStudent!.payments;
    _dishNumber.text = selectedStudent!.dishCount.toString();

  }

  double calculateCost(packageType) {
    var total_cost = 0.0;

    if (packageTypes.isNotEmpty) {
      switch (packageType) {
        case 'paq10ti':
          total_cost = selectedEvent.pricing!.paq10TICost;
        case 'paq10sp':
          total_cost = selectedEvent.pricing!.paq10SPCost;
        case 'paq5ti':
          total_cost = selectedEvent.pricing!.paq5TIPCost;
        case 'paq5sp':
          total_cost = selectedEvent.pricing!.paq5SPCost;
        case 'paq20':
          total_cost = selectedEvent.pricing!.paq10DoubleCost;
        default:
          total_cost = 0.0;
      }
    } else {
      total_cost = _dishNumber.text.isEmpty
          ? 0
          : double.parse(_dishNumber.text) * selectedEvent.pricing!.dishCost;
    }

    return total_cost;
  }

  saveStudentData() {
    if (isGraduation) {
      var student = Student(
        id: selectedStudent != null ? selectedStudent!.id : -1,
        name: _studentName.text,
        lastName: _studentLastName.text,
        packageType: _packageType.text,
        age: 0,
        email: '',
        phone: '',
        additionalQuantity: _additionalNumber.text.isEmpty || _additionalNumber.text == '0'
            ? 0
            : double.parse(_additionalNumber.text) * selectedEvent.pricing!.additionalCost,
        totalCost: calculateCost(_packageType.text),
        eventId: appState.selectedEvent.id,
        comments: _comment.text,
        payments: selectedStudent != null ? selectedStudent!.payments : [],
        folio: selectedStudent != null && selectedStudent!.folio != null
            ? selectedStudent!.folio
            : '',
        dishCount: _dishNumber.text.isEmpty ? 0 : int.parse(_dishNumber.text),
        additionalNumber: _additionalNumber.text.isEmpty ? 0 : int.parse(_additionalNumber.text),
      );

      EventService().saveStudent(student, token).then((studentResponse) {
        if (studentResponse.id != -1) {
          setState(() {
            selectedStudent = studentResponse;
          });
          isEditMode = false;
          isNewStudent = false;
          mapSelectedStudent();
          Flushbar(
            flushbarPosition: FlushbarPosition.TOP,
            title: 'Éxito',
            message: 'Alumno guardado correctamente',
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ).show(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al guardar el alumno')));
        }
      });
    }
  }

  addPayment() {
    var success = false;

    double iva = 0;
    if (_paymentMethodController.text.trim() == paymentMethods[2].trim()) {
      iva = double.parse(
          (double.tryParse(_paymentAmount.text)! * 0.16).toStringAsFixed(2));
    }

    var payments = paymentsHistory
        .where((e) =>
            e.paymentDetail == 'platillo' || e.paymentDetail == 'paquete')
        .toList();
    var totalPaid = payments.isNotEmpty ? payments.map((e) => e.amount).reduce((a, b) => a + b) : 0;

    var totalAmount = totalPaid + double.parse(_paymentAmount.text);
    if( totalAmount > selectedStudent!.totalCost){
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        title: 'Error',
        message: 'El pago excede el costo total del paquete/platillo, solo puedes cobrar  \$${double.parse(_paymentAmount.text) - (totalAmount - selectedStudent!.totalCost)} y despues agregar pagos adicionales u otro servicio',
        duration: Duration(seconds: 10),
        backgroundColor: Colors.red,
      ).show(context);
      return;
    }

    var paid = payments.isNotEmpty ? selectedStudent!.totalCost <= payments.map((e) => e.amount).reduce((a, b) => a + b) + double.parse(_paymentAmount.text) 
      : (selectedStudent!.totalCost <= double.parse(_paymentAmount.text));

    var payment = Payment(
        id: -1,
        amount: double.parse(_paymentAmount.text),
        paymentMethod: _paymentMethodController.text,
        paymentDate: DateTime.now(),
        studentId: selectedStudent != null ? selectedStudent!.id : -1,
        eventId: selectedEvent!.id,
        paymentDetail: _paymentDetail.text,
        iva: iva);
      
    EventService().createPayment(payment, token).then((value) {
      success = true;
      setState(() {
        if (success) {
          paymentsHistory.add(payment);
        }
      });
      _paymentAmount.clear();
      _paymentMethodController.clear();
      _paymentDetail.clear();
     if(paid) {
       EventService().getNextFolioStudent(token)
       .then((value) => {
         selectedStudent.folio = value,
         paymentDetails.add('adicional'),
         paymentDetails.remove('paquete'),
         saveStudentData()
       });
     }
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        title: 'Éxito',
        message: 'Pago agregado correctamente',
        duration: Duration(seconds: 3),
        backgroundColor: Colors.green,
      ).show(context);
    }, onError: (error) {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        title: 'Error',
        message: 'Error al agregar el pago',
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      ).show(context);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => {
                if (isGraduation)
                  {
                    setState(() {
                      appState.clearSelectedStudent();
                    }),
                    Navigator.of(context)
                        .pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => GraduationListPage(),
                          ),
                        )
                        .then((_) {})
                  }
                else
                  {
                    setState(() {
                      appState.clearSelectedEvent();
                    }),
                    Navigator.of(context)
                        .pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => EventsHomePage(),
                          ),
                        )
                        .then((_) {})
                  }
              },
            ),
            title: Text(
              isEditMode
                  ? (isGraduation
                      ? 'Editar alumno / agregar pago'
                      : 'Agregar pago')
                  : (isGraduation ? 'Agregar alumno' : 'Agregar pago'),
            )),
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Visibility(
                        visible: isGraduation,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text('Información del alumno',
                                    style: TextStyle(
                                        fontSize: 20.0, color: Colors.blue)),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                    child: TextFormField(
                                  controller: _studentName,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z]'))
                                  ],
                                  decoration: InputDecoration(
                                      labelText: 'Nombre del alumno',
                                      border: OutlineInputBorder()),
                                  readOnly: !isEditMode,
                                )),
                                SizedBox(width: 20),
                                Expanded(
                                    child: TextFormField(
                                  controller: _studentLastName,
                                  decoration: InputDecoration(
                                      labelText: 'Apellido del alumno',
                                      border: OutlineInputBorder()),
                                  readOnly: !isEditMode,
                                )),
                                SizedBox(width: 20),
                                Visibility(
                                  child: Expanded(
                                      child: TextFormField(
                                    controller: _dishNumber,
                                    decoration: InputDecoration(
                                        labelText: 'Numero de personas',
                                        border: OutlineInputBorder()),
                                    readOnly: !isEditMode,
                                  )),
                                  visible: packageTypes.isEmpty,
                                ),
                                Visibility(
                                    visible: packageTypes.isNotEmpty,
                                    child: selectedStudent != null && selectedStudent.folio.isNotEmpty ? 
                                      Text('Folio: ${selectedStudent.folio}', style: TextStyle(fontSize: 20.0, color: Colors.blue)):
                                     Expanded(
                                        child: RawAutocomplete<String>(
                                      key: _packageTypeKey,
                                      focusNode: _packageTypeFocus,
                                      textEditingController: _packageType,
                                      optionsBuilder:
                                          (TextEditingValue textEditingValue) {
                                        return packageTypes
                                            .where((String option) {
                                          return option.contains(
                                              textEditingValue.text
                                                  .toLowerCase());
                                        });
                                      },
                                      
                                      onSelected: (String selection) {
                                        _packageType.text = selection;
                                      },
                                      fieldViewBuilder: (BuildContext context,
                                          TextEditingController
                                              textEditingController,
                                          FocusNode focusNode,
                                          VoidCallback onFieldSubmitted) {
                                        return TextFormField(
                                          controller: textEditingController,
                                          focusNode: focusNode,
                                          readOnly: !isEditMode && (selectedStudent != null && selectedStudent.folio.isNotEmpty),
                                          decoration: InputDecoration(
                                              labelText: 'Tipo de paquete',
                                              border: OutlineInputBorder()),
                                              
                                        );
                                      },
                                      optionsViewBuilder: (BuildContext context,
                                          void Function(String) onSelected,
                                          Iterable<String> options) {
                                        return Material(
                                          child: ListView(
                                            children: options
                                                .map(
                                                    (String option) => ListTile(
                                                          title: Text(option),
                                                          onTap: () {
                                                            onSelected(option);
                                                          },
                                                        ))
                                                .toList(),
                                          ),
                                        );
                                      },
                                    ))),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Visibility(
                                  visible: isGraduation &&
                                      selectedStudent != null && selectedStudent.folio.length > 0,
                                  child: Expanded(
                                      child: TextFormField(
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                    controller: _additionalNumber,
                                    decoration: InputDecoration(
                                      labelText: 'Personas adicionales',
                                      border: OutlineInputBorder(),
                                    ),
                                    readOnly: !isEditMode,
                                  )),
                                ),
                                Visibility(
                                    visible: isGraduation &&
                                        selectedStudent != null &&
                                        selectedStudent.folio.length > 0,
                                    child: SizedBox(width: 20)),
                                Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: _comment,
                                      decoration: InputDecoration(
                                          labelText: 'Comentarios',
                                          border: OutlineInputBorder()),
                                      readOnly: !isEditMode,
                                    )),
                              ],
                            ),
                            SizedBox(height: 30),
                            Row(
                              children: [
                                Visibility(
                                  visible: isGraduation && isEditMode,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      // fixedSize: WidgetStateProperty.all(Size(100, 50)),
                                      backgroundColor:
                                          WidgetStateProperty.all(Colors.blue),
                                      foregroundColor:
                                          WidgetStateProperty.all(Colors.white),
                                    ),
                                    onPressed: () {
                                      log('save student data');
                                      saveStudentData();
                                    },
                                    child: Text('Guardar alumno'),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Visibility(
                                    visible: isGraduation && !isNewStudent,
                                    child: OutlinedButton(
                                      style: ButtonStyle(
                                        // fixedSize: WidgetStateProperty.all(Size(100, 50)),
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                Colors.blue),
                                        foregroundColor:
                                            WidgetStateProperty.all(
                                                Colors.white),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isEditMode = !isEditMode;
                                        });
                                      },
                                      child: Text(isEditMode
                                          ? 'Cancelar'
                                          : 'Editar alumno'),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Visibility(
                        visible: selectedStudent != null || !isGraduation,
                        child: Column(children: [
                          Row(
                            children: [
                              Text('Historial de pagos',
                                  style: TextStyle(
                                      fontSize: 20.0, color: Colors.blue)),
                                      SizedBox(width: 20),
                                      Visibility(
                                        visible: selectedStudent != null && selectedStudent.folio.isNotEmpty,
                                        child: Text('Folio: ${selectedStudent.folio}', style: TextStyle(fontSize: 20.0, color: Colors.blue)),
                                      ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Column(
                            children: paymentsHistory.isNotEmpty
                                ? paymentsHistory
                                    .map((payment) => Column(children: [
                                          SizedBox(height: 20),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller:
                                                      TextEditingController(
                                                          text: payment.amount
                                                              .toString()),
                                                  decoration: InputDecoration(
                                                      labelText:
                                                          'Monto del pago',
                                                      border:
                                                          OutlineInputBorder()),
                                                  readOnly: true,
                                                ),
                                              ),
                                              SizedBox(width: 20),
                                              Expanded(
                                                child: TextFormField(
                                                  controller:
                                                      TextEditingController(
                                                          text: payment
                                                              .paymentMethod),
                                                  decoration: InputDecoration(
                                                      labelText:
                                                          'Método de pago',
                                                      border:
                                                          OutlineInputBorder()),
                                                  readOnly: true,
                                                ),
                                              ),
                                              SizedBox(width: 20),
                                              Expanded(
                                                child: TextFormField(
                                                  controller:
                                                      TextEditingController(
                                                          text: DateFormat(
                                                                  'dd/MM/yyyy')
                                                              .format(payment
                                                                  .paymentDate)),
                                                  decoration: InputDecoration(
                                                      labelText:
                                                          'Fecha de pago',
                                                      border:
                                                          OutlineInputBorder()),
                                                  readOnly: true,
                                                ),
                                              ),
                                              SizedBox(width: 20),
                                              Expanded(
                                                child: TextFormField(
                                                  controller:
                                                      TextEditingController(
                                                          text: payment
                                                              .paymentDetail),
                                                  decoration: InputDecoration(
                                                      labelText:
                                                          'Detalle de pago',
                                                      border:
                                                          OutlineInputBorder()),
                                                  readOnly: true,
                                                ),
                                              ),
                                              SizedBox(width: 20),
                                            ],
                                          ),
                                        ]))
                                    .toList()
                                : [Text('No hay pagos actualmente')],
                          ),
                        ]),
                      ),
                      SizedBox(height: 30),
                      Visibility(
                        visible: selectedStudent != null || !isGraduation,
                        child: Column(children: [
                          Row(
                            children: [
                              Text('Pagos',
                                  style: TextStyle(
                                      fontSize: 20.0, color: Colors.blue)),
                            ],
                          ),
                          SizedBox(height: 20),
                          Column(children: [
                            Row(
                              children: [
                                Expanded(
                                    child: TextFormField(
                                  controller: _paymentAmount,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}'))
                                  ],
                                  decoration: InputDecoration(
                                      labelText: 'Monto del pago',
                                      border: OutlineInputBorder()),
                                  validator: (value) =>
                                      value != null && value.isEmpty
                                          ? 'El monto del pago es requerido'
                                          : null,
                                )),
                                SizedBox(width: 20),
                                Expanded(
                                    child: RawAutocomplete<String>(
                                  key: _paymentMethodKey,
                                  focusNode: _paymentMethodFocus,
                                  textEditingController:
                                      _paymentMethodController,
                                  optionsBuilder:
                                      (TextEditingValue textEditingValue) {
                                    return paymentMethods
                                        .where((String option) {
                                      return option.contains(
                                          textEditingValue.text.toLowerCase());
                                    });
                                  },
                                  onSelected: (String selection) {
                                    _paymentMethodController.text = selection;
                                  },
                                  fieldViewBuilder: (BuildContext context,
                                      TextEditingController
                                          textEditingController,
                                      FocusNode focusNode,
                                      VoidCallback onFieldSubmitted) {
                                    return TextFormField(
                                      controller: textEditingController,
                                      focusNode: _paymentMethodFocus,
                                      readOnly: false,
                                      decoration: InputDecoration(
                                          labelText: 'Método de pago',
                                          border: OutlineInputBorder()),
                                      validator: (value) =>
                                          value != null && value.isEmpty
                                              ? 'El método de pago es requerido'
                                              : null,
                                    );
                                  },
                                  optionsViewBuilder: (BuildContext context,
                                      void Function(String) onSelected,
                                      Iterable<String> options) {
                                    return Material(
                                      child: ListView(
                                        children: options
                                            .map((String option) => ListTile(
                                                  title: Text(option),
                                                  onTap: () {
                                                    onSelected(option);
                                                  },
                                                ))
                                            .toList(),
                                      ),
                                    );
                                  },
                                )),
                                SizedBox(width: 20),
                                Expanded(
                                  child: RawAutocomplete(
                                    key: _paymentDetailKey,
                                    focusNode: _paymentDetailFocus,
                                    textEditingController: _paymentDetail,
                                    optionsBuilder:
                                        (TextEditingValue textEditingValue) {
                                      return paymentDetails
                                          .where((String option) {
                                        return option.contains(textEditingValue
                                            .text
                                            .toLowerCase());
                                      });
                                    },
                                    onSelected: (String selection) {
                                      _paymentDetail.text = selection;
                                    },
                                    fieldViewBuilder: (BuildContext context,
                                        TextEditingController
                                            textEditingController,
                                        FocusNode focusNode,
                                        VoidCallback onFieldSubmitted) {
                                      return TextFormField(
                                        controller: textEditingController,
                                        focusNode: focusNode,
                                        readOnly: false,
                                        decoration: InputDecoration(
                                          labelText: 'Detalle de pago',
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) => value != null &&
                                                value.isEmpty
                                            ? 'El detalle de pago es requerido'
                                            : null,
                                      );
                                    },
                                    optionsViewBuilder: (BuildContext context,
                                        void Function(String) onSelected,
                                        Iterable<String> options) {
                                      return Material(
                                        child: ListView(
                                          children: options
                                              .map((String option) => ListTile(
                                                    title: Text(option),
                                                    onTap: () {
                                                      onSelected(option);
                                                    },
                                                  ))
                                              .toList(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ]),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all(Colors.blue),
                                  foregroundColor:
                                      WidgetStateProperty.all(Colors.white),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (!selectedStudent.folio.isNotEmpty &&
                                        (_paymentDetail.text == 'platillo' ||
                                            _paymentDetail.text == 'paquete')) {
                                      if (_paymentMethodController.text
                                              .trim() ==
                                          paymentMethods[2].trim()) {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                    'Confirmar pago por transferencia'),
                                                content: Text(
                                                    '¿Recuerde que la cantidad ingresada por transferencia ${_paymentAmount.text} se le cobrará el 16% qué es un total de ${double.tryParse(_paymentAmount.text)! * 1.16} ?'),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('Cancelar')),
                                                  TextButton(
                                                      onPressed: () {
                                                        addPayment();
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('Aceptar'))
                                                ],
                                              );
                                            });
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Confirmar pago'),
                                                content: Text(
                                                    '¿Está seguro de agregar el pago?'),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('Cancelar')),
                                                  TextButton(
                                                    
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        addPayment();
                                                      },
                                                      child: Text('Aceptar'))
                                                ],
                                              );
                                            });
                                      }
                                    } else {
                                      Flushbar(
                                        flushbarPosition: FlushbarPosition.TOP,
                                        title: 'Error',
                                        message:
                                            'El alumno ya ha pagado el total de su paquete/platillo solo puedes pagar adicionales o extras',
                                        duration: Duration(seconds: 6),
                                        backgroundColor: Colors.red,
                                      ).show(context);
                                    }
                                  }
                                },
                                child: Text('Agregar Pago'),
                              ),
                              SizedBox(width: 20),
                            ],
                          )
                        ]),
                      ),
                    ],
                  ))),
        ));
  }
}
