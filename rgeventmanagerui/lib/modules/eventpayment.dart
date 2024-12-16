import 'dart:developer';
import 'package:another_flushbar/flushbar.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/formatters/ThousandsSeparatorInputFormatter.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/Student.dart';
import 'package:rg_event_management_ui/modules/graduationlist.dart';
import 'package:rg_event_management_ui/services/eventservice.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

class EventPaymentPage extends StatefulWidget {
  @override
  _EventPaymentPageState createState() => _EventPaymentPageState();
}

enum RequireSouvenir { YES, NO }

enum RequirePreParty { YES, NO }

class _EventPaymentPageState extends State<EventPaymentPage> {
  bool isEditMode = false;
  bool isGraduation = false;
  bool isNewStudent = false;
  var token = "";
  var selectedStudent;
  var selectedEvent;
  var appState;

  RequireSouvenir? _requireSouvenir = RequireSouvenir.NO;
  int souvenirSelected = 0;
  RequirePreParty? _requirePreParty = RequirePreParty.NO;

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
  var _telephone = TextEditingController();
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
      selectedStudent.paid = selectedStudent.payments.isNotEmpty
        ? selectedStudent.payments
            .where((e) =>
                e.paymentDetail == 'platillo' || e.paymentDetail == 'paquete')
            .map((e) => e.amount)
            .reduce((a, b) => a + b) >= selectedStudent.totalCost
        : false;

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
    setPaymentDetails();
    super.initState();
  }

  setPaymentDetails() {
    paymentDetails.clear();
    if (isGraduation) {
      if (packageTypes.isNotEmpty) {
        if (selectedStudent != null &&
            selectedStudent.folio.isNotEmpty &&
            selectedEvent.pricing!.additionalCost > 0) {
          paymentDetails.add('adicional');
        } else {
          paymentDetails.add('paquete');
        }
      } else {
        if (selectedStudent != null && packageTypes.isEmpty && !selectedStudent.paid) {
          paymentDetails.add('platillo');
        }
      }
    } else {
      paymentDetails.add(selectedEvent!.name);
    }
  }

  setSelectedSouvenir(value) {
    setState(() {
      souvenirSelected = value;
    });
  }

  mapSelectedStudent() {
    _telephone.text = selectedStudent!.phone;
    _studentName.text = selectedStudent!.name;
    _studentLastName.text = selectedStudent!.lastName;
    _packageType.text = selectedStudent!.packageType;
    _comment.text = selectedStudent!.comments;
    paymentsHistory = selectedStudent!.payments;
    _dishNumber.text = selectedStudent!.dishCount.toString();
  }

  double calculateCost(packageType) {
    var totalCost = 0.0;

    if (packageTypes.isNotEmpty) {
      switch (packageType) {
        case 'paq10ti':
          totalCost = selectedEvent.pricing!.paq10TICost;
        case 'paq10sp':
          totalCost = selectedEvent.pricing!.paq10SPCost;
        case 'paq5ti':
          totalCost = selectedEvent.pricing!.paq5TIPCost;
        case 'paq5sp':
          totalCost = selectedEvent.pricing!.paq5SPCost;
        case 'paq20':
          totalCost = selectedEvent.pricing!.paq10DoubleCost;
        default:
          totalCost = 0.0;
      }
    } else {
      totalCost = _dishNumber.text.isEmpty
          ? 0
          : double.parse(_dishNumber.text) * selectedEvent.pricing!.dishCost;
    }

    return totalCost;
  }

  saveStudentData() {
    var student = BuildStudentObject();

    if (packageTypes.isEmpty && student.folio.isEmpty) {
      EventService()
          .saveStudentWithFolioData(student, token)
          .then((studentResponse) {
        if (studentResponse.id != -1) {
          setState(() {
            selectedStudent = studentResponse;
          });
          isEditMode = false;
          isNewStudent = false;
          mapSelectedStudent();
          setPaymentDetails();
          Flushbar(
            flushbarPosition: FlushbarPosition.TOP,
            title: 'Éxito',
            message: 'Alumno guardado correctamente y folio generado',
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ).show(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al guardar el alumno')));
        }
      });
    } else {
      EventService().saveStudent(student, token).then((studentResponse) {
        if (studentResponse.id != -1) {
          setState(() {
            selectedStudent = studentResponse;
          });
          isEditMode = false;
          isNewStudent = false;
          mapSelectedStudent();
          setPaymentDetails();
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

  Student BuildStudentObject() {
    var student = Student(
      id: selectedStudent != null ? selectedStudent!.id : -1,
      name: _studentName.text,
      lastName: _studentLastName.text,
      packageType: _packageType.text,
      age: 0,
      email: '',
      phone: _telephone.text,
      additionalQuantity: selectedStudent != null
          ? selectedStudent!.additionalQuantity +
              (_additionalNumber.text.isEmpty
                  ? 0
                  : (double.tryParse(_additionalNumber.text)! *
                      selectedEvent.pricing.additionalCost))
          : 0,
      totalCost: calculateCost(_packageType.text),
      eventId: appState.selectedEvent.id,
      comments: _comment.text,
      payments: selectedStudent != null ? selectedStudent!.payments : [],
      folio: selectedStudent != null && selectedStudent!.folio != null
          ? selectedStudent!.folio
          : '',
      dishCount: _dishNumber.text.isEmpty ? 0 : int.parse(_dishNumber.text),
      additionalNumber: selectedStudent != null
          ? selectedStudent!.additionalNumber +
              int.tryParse(
                  _additionalNumber.text.isEmpty ? "0" : _additionalNumber.text)
          : 0,
    );
    return student;
  }

  addPayment() {
    if (isGraduation) {
      var payments = selectedStudent!.payments
          .where((e) =>
              e.paymentDetail == 'platillo' || e.paymentDetail == 'paquete')
          .toList();
      var totalPaid = payments.isNotEmpty
          ? payments.map((e) => e.amount).reduce((a, b) => a + b)
          : 0;

      var isAlreadyPaid = selectedStudent!.totalCost - totalPaid == 0;

      if (isAlreadyPaid &&
          (_paymentDetail.text == 'platillo' ||
              _paymentDetail.text == 'paquete')) {
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          title: 'Error',
          message: 'El alumno ya ha pagado el total de su paquete/platillo',
          duration: Duration(seconds: 6),
          backgroundColor: Colors.red,
        ).show(context);
        return;
      }

      var paymentAmount = double.parse(_paymentAmount.text.isEmpty
          ? "0"
          : _paymentAmount.text.replaceAll(',', ''));

      switch (_paymentDetail.text) {
        case 'adicional':
          paymentAmount = selectedEvent!.pricing.additionalCost *
              double.tryParse(_additionalNumber.text)!;

        case 'pre-fiesta':
          paymentAmount = selectedEvent!.pricing.prePartyCost;
      }

      double iva = 0;
      if (_paymentMethodController.text.trim() == paymentMethods[2].trim()) {
        iva = double.parse((paymentAmount * 0.16).toStringAsFixed(2));
      }

      // package or dish payment validation
      if (_paymentDetail.text == 'platillo' ||
          _paymentDetail.text == 'paquete') {
        var totalAmount = totalPaid + paymentAmount;
        if (selectedStudent.folio.isEmpty &&
            (totalAmount > selectedStudent!.totalCost)) {
          Flushbar(
            flushbarPosition: FlushbarPosition.TOP,
            title: 'Error',
            message:
                'El pago excede el costo total del paquete/platillo, solo puedes cobrar  \$${double.parse(_paymentAmount.text.replaceAll(',', '')) - (totalAmount - selectedStudent!.totalCost)} y despues agregar pagos adicionales u otro servicio',
            duration: Duration(seconds: 10),
            backgroundColor: Colors.red,
          ).show(context);
          return;
        }
      }

      // check if the student has already paid the total cost
      var isPaid = payments.isNotEmpty
          ? selectedStudent!.totalCost <=
              payments
                      .where((e) =>
                          e.paymentDetail == 'platillo' ||
                          e.paymentDetail == 'paquete')
                      .map((e) => e.amount)
                      .reduce((a, b) => a + b) +
                  paymentAmount
          : (selectedStudent!.totalCost <= paymentAmount);

      var payment = Payment(
          id: -1,
          amount: paymentAmount,
          paymentMethod: _paymentMethodController.text,
          paymentDate: DateTime.now(),
          studentId: selectedStudent != null ? selectedStudent!.id : -1,
          eventId: selectedEvent!.id,
          addedBy: '',
          paymentDetail: _paymentDetail.text,
          iva: iva);

      if (!isPaid) {
        EventService().createPayment(payment, token).then((value) {
          log('payment added $value');
          setState(() {
            selectedStudent.payments.add(value);
          });
          Flushbar(
            flushbarPosition: FlushbarPosition.TOP,
            title: 'Éxito',
            message: 'Pago agregado correctamente',
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ).show(context);
        }).catchError((error) {
          Flushbar(
            flushbarPosition: FlushbarPosition.TOP,
            title: 'Error',
            message:
                'Error al agregar el pago, intente de nuevo o contacte a soporte',
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ).show(context);
          return;
        });
      } else if (_paymentDetail.text != 'platillo' ||
          _paymentDetail.text != 'paquete') {
        selectedStudent.payments.add(payment);
        var student = BuildStudentObject();
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
              message: 'Pago de ${_paymentDetail.text} agregado correctamente',
              duration: Duration(seconds: 3),
              backgroundColor: Colors.green,
            ).show(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al guardar el alumno')));
            return;
          }
        });
      }

      _paymentAmount.clear();
      _paymentMethodController.clear();
      _paymentDetail.clear();
      _additionalNumber.clear();

      if (isPaid && selectedStudent.folio.isEmpty) {
        selectedStudent.payments.add(payment);
        EventService()
            .saveStudentWithFolioData(selectedStudent, token)
            .then((value) => {
                  if (value.folio.isNotEmpty)
                    {
                      setState(() {
                        selectedStudent = value;
                        paymentsHistory.add(payment);
                        if (packageTypes.isNotEmpty) {
                          paymentDetails.remove('paquete');
                        } else {
                          paymentDetails.remove('platillo');
                        }
                      }),
                      Flushbar(
                        flushbarPosition: FlushbarPosition.TOP,
                        title: 'Éxito',
                        message: 'Pago agregado correctamente y folio generado',
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.green,
                      ).show(context),
                    }
                  else
                    log('error on creating folio and saving payment '),
                  Flushbar(
                    flushbarPosition: FlushbarPosition.TOP,
                    title: 'Error',
                    message:
                        'Error al agregar el pago, intente de nuevo o contacte a soporte',
                    duration: Duration(seconds: 3),
                    backgroundColor: Colors.red,
                  )
                })
            .catchError((error) => {
                  log('error agregando pago $error'),
                  Flushbar(
                    flushbarPosition: FlushbarPosition.TOP,
                    title: 'Error',
                    message:
                        'Error al agregar el pago, intente de nuevo o contacte a soporte',
                    duration: Duration(seconds: 3),
                    backgroundColor: Colors.red,
                  ).show(context),
                });
      }
    } else {
      var payment = Payment(
          id: -1,
          amount: double.parse(_paymentAmount.text.isEmpty
              ? "0"
              : _paymentAmount.text.replaceAll(',', '')),
          paymentMethod: _paymentMethodController.text,
          paymentDate: DateTime.now(),
          studentId: -1,
          eventId: selectedEvent!.id,
          addedBy: '',
          paymentDetail: selectedEvent!.name,
          iva: 0);

      EventService().createPayment(payment, token).then((value) {
        log('payment added $value');
        setState(() {
          paymentsHistory.add(value);
        });
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          title: 'Éxito',
          message: 'Pago agregado correctamente',
          duration: Duration(seconds: 3),
          backgroundColor: Colors.green,
        ).show(context);
      }).catchError((error) {
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          title: 'Error',
          message:
              'Error al agregar el pago, intente de nuevo o contacte a soporte',
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ).show(context);
        return;
      });

      _paymentAmount.clear();
      _paymentMethodController.clear();
      _paymentDetail.clear();
    }
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
                                  visible: packageTypes.isEmpty,
                                  child: Expanded(
                                      child: TextFormField(
                                    controller: _dishNumber,
                                    decoration: InputDecoration(
                                        labelText: 'Numero de personas',
                                        border: OutlineInputBorder()),
                                    readOnly: !isEditMode,
                                  )),
                                ),
                                Visibility(
                                    visible: packageTypes.isNotEmpty,
                                    child: selectedStudent != null &&
                                            selectedStudent.folio.isNotEmpty
                                        ? Text(
                                            'Folio: ${selectedStudent.folio}',
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                color: Colors.blue))
                                        : Expanded(
                                            child: RawAutocomplete<String>(
                                            key: _packageTypeKey,
                                            focusNode: _packageTypeFocus,
                                            textEditingController: _packageType,
                                            optionsBuilder: (TextEditingValue
                                                textEditingValue) {
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
                                            fieldViewBuilder: (BuildContext
                                                    context,
                                                TextEditingController
                                                    textEditingController,
                                                FocusNode focusNode,
                                                VoidCallback onFieldSubmitted) {
                                              return TextFormField(
                                                controller:
                                                    textEditingController,
                                                focusNode: focusNode,
                                                readOnly: !isEditMode &&
                                                    (selectedStudent != null &&
                                                        selectedStudent
                                                            .folio.isNotEmpty),
                                                decoration: InputDecoration(
                                                    labelText:
                                                        'Tipo de paquete',
                                                    border:
                                                        OutlineInputBorder()),
                                              );
                                            },
                                            optionsViewBuilder:
                                                (BuildContext context,
                                                    void Function(String)
                                                        onSelected,
                                                    Iterable<String> options) {
                                              return Material(
                                                child: ListView(
                                                  children: options
                                                      .map((String option) =>
                                                          ListTile(
                                                            title: Text(option),
                                                            onTap: () {
                                                              onSelected(
                                                                  option);
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
                                  visible: isGraduation,
                                  child: Expanded(
                                      child: TextFormField(
                                    controller: _telephone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    decoration: InputDecoration(
                                        labelText: 'Telefono',
                                        border: OutlineInputBorder()),
                                    readOnly: !isEditMode,
                                  )),
                                ),
                                SizedBox(width: 20),
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
                            SizedBox(height: 22),
                            Row(
                              children: <Widget>[
                                Text('Agregar souvenir: '),
                                SizedBox(width: 10),
                                Text('Si'),
                                Radio(
                                  value: 1,
                                  groupValue: souvenirSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      setSelectedSouvenir(value);
                                    });
                                  },
                                ),
                                SizedBox(width: 10),
                                Text('No'),
                                Radio(
                                  value: 2,
                                  groupValue: souvenirSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      setSelectedSouvenir(value);
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            Row(
                              children: [
                                Visibility(
                                  visible: isGraduation && isEditMode,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
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
                                visible: selectedStudent != null &&
                                    selectedStudent.folio.isNotEmpty &&
                                    selectedStudent!.paid,
                                child: Expanded(
                                    child: Text('PAGADO',
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.green))),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                flex: 1,
                                child: Text(
                                    'Total pagado: \$${isGraduation ? (selectedStudent != null && selectedStudent!.payments.isNotEmpty ? selectedStudent.payments.where((e) => e.paymentDetail == 'platillo' || e.paymentDetail == 'paquete').map((e) => e.amount).reduce((a, b) => a + b) : 0) : (paymentsHistory.isNotEmpty ? paymentsHistory.where((e) => e.paymentDetail == selectedEvent!.name).map((e) => e.amount).reduce((a, b) => a + b) : 0)}',
                                    style: TextStyle(
                                        fontSize: 14.0, color: Colors.black)),
                              ),
                              SizedBox(width: 25),
                              Expanded(
                                child: Text(
                                    'Restante: \$${isGraduation ? (selectedStudent != null && selectedStudent.payments.isNotEmpty ? selectedStudent!.totalCost - selectedStudent.payments.where((e) => e.paymentDetail == 'platillo' || e.paymentDetail == 'paquete').map((e) => e.amount).reduce((a, b) => a + b) : 0) : (selectedEvent!.totalCost - (paymentsHistory.isNotEmpty ? paymentsHistory.where((e) => e.paymentDetail == selectedEvent!.name).map((e) => e.amount).reduce((a, b) => a + b) : 0))}'),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                    'Total: \$${isGraduation ? (selectedStudent != null ? selectedStudent!.totalCost : 0) : (selectedEvent!.totalCost)}',
                                    style: TextStyle(
                                        fontSize: 14.0, color: Colors.black)),
                              ),
                              SizedBox(width: 20),
                              Visibility(
                                  visible: isGraduation &&
                                      selectedStudent != null &&
                                      selectedStudent.folio.isNotEmpty &&
                                      packageTypes.isEmpty,
                                  child: Text(
                                      selectedStudent != null
                                          ? 'Folio: ${selectedStudent!.folio}'
                                          : '',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: 20.0, color: Colors.blue))),
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
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    ThousandsSeparatorInputFormatter(),
                                  ],
                                  decoration: InputDecoration(
                                      labelText: 'Monto del pago',
                                      border: OutlineInputBorder()),
                                  validator: (value) =>
                                      _paymentDetail.text != 'adicional' &&
                                              value != null &&
                                              value.isEmpty
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
                                SizedBox(width: 20),
                                Visibility(
                                    visible: selectedStudent != null &&
                                        packageTypes.isNotEmpty &&
                                        selectedStudent.folio.isNotEmpty,
                                    child: Expanded(
                                      child: TextFormField(
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        validator: (value) => selectedStudent !=
                                                    null &&
                                                selectedStudent
                                                    .folio.isNotEmpty &&
                                                _paymentDetail.text ==
                                                    'adicional' &&
                                                value != null &&
                                                value.isEmpty
                                            ? 'El número de personas es requerido'
                                            : null,
                                        controller: _additionalNumber,
                                        decoration: InputDecoration(
                                          labelText: 'Personas adicionales',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) => {
                                          if (value.isNotEmpty)
                                            {
                                              log("value: " + value),
                                              log("additional cost: " +
                                                  selectedEvent
                                                      .pricing!.additionalCost
                                                      .toString()),
                                              _paymentAmount.text = (double
                                                          .tryParse(value)! *
                                                      (selectedEvent.pricing!
                                                                  .additionalCost ==
                                                              0
                                                          ? 0
                                                          : selectedEvent
                                                              .pricing!
                                                              .additionalCost!))
                                                  .toString(),
                                              log(_paymentAmount.text)
                                            }
                                        },
                                      ),
                                    )),
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
                                    if (((selectedStudent == null) || (selectedStudent.folio.isEmpty &&
                                            packageTypes.isNotEmpty &&
                                            _paymentDetail.text == 'paquete') ||
                                        (packageTypes.isEmpty &&
                                            _paymentDetail.text == 'platillo' &&
                                            !selectedStudent!.paid))) {
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
                                                    '¿Recuerde que la cantidad ingresada por transferencia ${_paymentAmount.text} se le cobrará el 16% qué es un total de ${double.tryParse(_paymentAmount.text.replaceAll(',', ''))! * 1.16} ?'),
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
                                    } else if (_formKey.currentState!
                                            .validate() &&
                                        _paymentDetail.text == 'adicional' &&
                                        selectedStudent!.folio.isNotEmpty) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Confirmar pago'),
                                              content: Text(
                                                  '¿Está seguro de agregar el pago adicional de ${double.tryParse(_additionalNumber.text)! * selectedEvent.pricing!.additionalCost} ?'),
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
