// import 'dart:math';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/formatters/ThousandsSeparatorInputFormatter.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/Student.dart';
import 'package:rg_event_management_ui/modules/amenities_page.dart';
import 'package:rg_event_management_ui/modules/graduationlist.dart';
import 'package:rg_event_management_ui/services/eventservice.dart';
import 'package:intl/intl.dart';
import 'dart:developer';

class GraduationPaymentPage extends StatefulWidget {
  @override
  _GraduationPaymentPageState createState() => _GraduationPaymentPageState();
}

class _GraduationPaymentPageState extends State<GraduationPaymentPage> {
  static const String ADDITIONAL = 'adicional';
  bool isEditMode = false;
  bool isGraduation = false;
  bool isNewStudent = false;
  var token = "";
  var selectedStudent;
  var selectedEvent;
  bool showAQuantityNumberInput = false;
  double remindingAdditional = 0.0;
  var appState;

  final _formKey = GlobalKey<FormState>();
  final _studentFormKey = GlobalKey<FormState>();
  final GlobalKey _packageTypeKey = GlobalKey();
  final GlobalKey _paymentMethodKey = GlobalKey();
  final FocusNode _packageTypeFocus = FocusNode();
  final FocusNode _paymentMethodFocus = FocusNode();
  var _studentName = TextEditingController();
  var _studentLastName = TextEditingController();
  var _packageType = TextEditingController();
  var _dishNumber = TextEditingController();
  var _paymentMethodController = TextEditingController();
  var _quantityNumber = TextEditingController();
  var _telephone = TextEditingController();
  var _comment = TextEditingController();
  var _paymentAmount = TextEditingController();
  var _paymentDetail = TextEditingController();
  var _paymentDetailKey = GlobalKey<FormFieldState>();
  var _paymentDetailFocus = FocusNode();

  List<Payment> paymentsHistory = [];

  List<String> packageTypes = [];

  List<String> paymentMethods = [
    'Efectivo',
    'Tarjeta',
    'Transferencia',
    'Retiro sin tarjeta',
    'Pago en escuela'
  ];
  List<String> paymentDetails = [];

  bool addSouvenir = false;
  bool addPreParty = false;
  bool addBracelet = false;
  bool isComity = false;

  @override
  void initState() {
    appState = context.read<MyAppState>();
    selectedStudent = appState.selectedStudent;
    selectedEvent = appState.selectedEvent;
    token = appState.appToken;

    if (selectedEvent != null && selectedEvent!.eventType.id == 3) {
      isGraduation = true;
      if (selectedStudent != null) {
        selectedStudent.paid = selectedStudent != null &&
                selectedStudent.payments!
                    .where((e) =>
                        e.paymentDetail == 'platillo' ||
                        e.paymentDetail == 'paquete')
                    .isNotEmpty
            ? selectedStudent.payments
                    .where((e) =>
                        e.paymentDetail == 'platillo' ||
                        e.paymentDetail == 'paquete')
                    .map((e) => e.amount)
                    .reduce((a, b) => a + b) >=
                selectedStudent.totalCost
            : false;
        setState(() {
          remindingAdditional = selectedStudent != null &&
                  selectedStudent.payments!
                      .where((e) => e.paymentDetail == ADDITIONAL)
                      .isNotEmpty
              ? selectedStudent.additionalQuantity -
                  selectedStudent.payments
                      .where((e) => e.paymentDetail == ADDITIONAL)
                      .map((e) => e.amount)
                      .reduce((a, b) => a + b)
              : 0.0;
        });
      }

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

  setAdditionalNumber() {
    if (_paymentDetail.text.isNotEmpty &&
        _paymentDetail.text != 'platillo' &&
        _paymentDetail.text != 'paquete') {
      setState(() {
        showAQuantityNumberInput = true;
      });
    } else {
      setState(() {
        showAQuantityNumberInput = false;
      });
    }
  }

  setPaymentDetails() {
    paymentDetails.clear();
    if (packageTypes.isNotEmpty) {
      if (selectedStudent != null &&
          selectedStudent.folio.isNotEmpty &&
          selectedEvent.pricing!.additionalCost > 0) {
        paymentDetails.add(ADDITIONAL);
      } else {
        paymentDetails.add('paquete');
      }
    } else {
      if (selectedStudent != null &&
          packageTypes.isEmpty &&
          !selectedStudent.paid) {
        paymentDetails.add('platillo');
      }
    }

    if (selectedStudent != null && selectedStudent.hasPreParty) {
      paymentDetails.add('pre-fiesta');
    }
    if (selectedStudent != null && selectedStudent.hasSouvenir) {
      paymentDetails.add('souvenir');
    }
    if (selectedStudent != null && selectedStudent.hasBracelet) {
      paymentDetails.add('pulsera');
    }
  }

  mapSelectedStudent() {
    _telephone.text = selectedStudent!.phone;
    _studentName.text = selectedStudent!.name;
    _studentLastName.text = selectedStudent!.lastName;
    _packageType.text = selectedStudent!.packageType;
    _comment.text = selectedStudent!.comments;
    paymentsHistory = selectedStudent!.payments;
    _dishNumber.text = selectedStudent!.dishCount.toString();
    addSouvenir = selectedStudent!.hasSouvenir;
    addPreParty = selectedStudent!.hasPreParty;
    addBracelet = selectedStudent!.hasBracelet;
    isComity = selectedStudent!.committee;
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

    // payment for dish
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
      // payent by package
      EventService().saveStudent(student, token,false).then((studentResponse) {
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

  Student BuildStudentObject(
      [int additionalNumber = 0, double additionalQuantity = 0.0]) {
    var student = Student(
      id: selectedStudent != null ? selectedStudent!.id : -1,
      name: _studentName.text,
      lastName: _studentLastName.text,
      packageType: _packageType.text,
      age: 0,
      email: '',
      phone: _telephone.text,
      additionalQuantity: selectedStudent != null
          ? selectedStudent!.additionalQuantity + additionalQuantity
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
          ? selectedStudent!.additionalNumber + additionalNumber
          : 0,
      hasPreParty: addPreParty,
      hasSouvenir: addSouvenir,
      hasBracelet: addBracelet,
      paid: selectedStudent != null ? selectedStudent!.paid : false,
      cancelled: selectedStudent != null ? selectedStudent!.cancelled : false,
      committee: isComity,
    );
    return student;
  }

  addPayment() {
    try {
      var paymentAmount = double.parse(_paymentAmount.text.isEmpty
          ? "0"
          : _paymentAmount.text.replaceAll(',', ''));

      var paymentsDishOrPackage = selectedStudent!.payments
          .where((e) =>
              e.paymentDetail == 'platillo' || e.paymentDetail == 'paquete')
          .toList();

      var totalPaid = paymentsDishOrPackage.isNotEmpty
          ? paymentsDishOrPackage.map((e) => e.amount).reduce((a, b) => a + b)
          : 0;

      var isAlreadyPaidDishOrPackage =
          selectedStudent!.totalCost - totalPaid == 0;

      // check if the student has already paid the total cost
      var isPayingWithCurrentPayment = paymentsDishOrPackage.isNotEmpty
          ? selectedStudent!.totalCost <=
              paymentsDishOrPackage
                      .map((e) => e.amount)
                      .reduce((a, b) => a + b) +
                  paymentAmount
          : (selectedStudent!.totalCost <= paymentAmount);

      // This is just to make sure that the student has already paid the total cost
      if ((_paymentDetail.text == 'platillo' ||
              _paymentDetail.text == 'paquete') &&
          selectedStudent.totalCost == 0) {
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          title: 'Error',
          message:
              'El alumno no tiene paquete/platillos asignado, por favor asigna paquete/platillos antes de agregar un pago',
          duration: Duration(seconds: 6),
          backgroundColor: Colors.red,
        ).show(context);
        return;
      }
      if (isAlreadyPaidDishOrPackage &&
          (_paymentDetail.text == 'platillo' ||
              _paymentDetail.text == 'paquete')) {
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          title: 'Error',
          message:
              'El alumno ya ha pagado el total de su paquete/platillo revisa si se puede pagar otro servicio desde el evento',
          duration: Duration(seconds: 6),
          backgroundColor: Colors.red,
        ).show(context);
        return;
      }

      var reminding = 0.0;
      if (isAlreadyPaidDishOrPackage) {
        reminding = selectedStudent!.additionalQuantity -
            (selectedStudent!.payments.isNotEmpty &&
                    selectedStudent!.payments
                        .where((e) => e.paymentDetail == ADDITIONAL)
                        .isNotEmpty
                ? selectedStudent!.payments
                    .where((e) => e.paymentDetail == ADDITIONAL)
                    .map((e) => e.amount)
                    .reduce((a, b) => a + b)
                : 0.0);
      }

      // if we have reminding amount to pay for additional services
      if (isAlreadyPaidDishOrPackage &&
          reminding > 0 &&
          _paymentDetail.text == ADDITIONAL &&
          paymentAmount > reminding) {
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          title: 'Error',
          message:
              'Hay un saldo pendiente de adicionales, puede abonar o completar el pago antes de agregar más \$$reminding ',
          duration: Duration(seconds: 6),
          backgroundColor: Colors.red,
        ).show(context);
        return;
      }

      if (reminding > 0 && _paymentDetail.text == ADDITIONAL) {
        setState(() {
          remindingAdditional = selectedStudent != null &&
                  selectedStudent.payments!
                      .where((e) => e.paymentDetail == ADDITIONAL)
                      .isNotEmpty
              ? selectedStudent.additionalQuantity -
                  paymentAmount -
                  selectedStudent.payments
                      .where((e) => e.paymentDetail == ADDITIONAL)
                      .map((e) => e.amount)
                      .reduce((a, b) => a + b)
              : 0.0;
        });
      }

      var quantityNumber =
          _quantityNumber.text.isEmpty ? 0 : int.tryParse(_quantityNumber.text);

      switch (_paymentDetail.text) {
        case ADDITIONAL:
          if (reminding > 0) {
            quantityNumber = 0;
          }
        case 'pre-fiesta':
          paymentAmount = selectedEvent!.pricing.prePartyCost * quantityNumber!;
        case 'souvenir':
          paymentAmount = selectedEvent!.pricing.souvenirCost * quantityNumber!;
        case 'pulsera':
          paymentAmount = selectedEvent!.pricing.braceletCost * quantityNumber!;
        default:
          break;
      }

      double iva = 0;
      if (_paymentMethodController.text.trim() == paymentMethods[2].trim()) {
        iva = double.parse((paymentAmount * 0.16).toStringAsFixed(2));
      }

      // package or dish payment validation
      if (_paymentDetail.text == 'platillo' ||
          _paymentDetail.text == 'paquete') {
        var totalAmount = totalPaid + paymentAmount;
        if ((totalAmount > selectedStudent!.totalCost)) {
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

      var payment = Payment(
          id: -1,
          amount: paymentAmount,
          paymentMethod: _paymentMethodController.text,
          paymentDate: DateTime.now(),
          studentId: selectedStudent != null ? selectedStudent!.id : -1,
          eventId: selectedEvent!.id,
          addedBy: '',
          paymentDetail: _paymentDetail.text,
          iva: iva,
          quantity: quantityNumber);

      if (isPayingWithCurrentPayment || isAlreadyPaidDishOrPackage) {
        setState(() {
          selectedStudent!.paid = true;
        });
      }

      if (!isPayingWithCurrentPayment || _paymentDetail.text == 'platillo') {
        EventService().createPayment(payment, token).then((value) {
          log('payment added $value');
          setState(() {
            selectedStudent.payments.add(value);
            if (isPayingWithCurrentPayment) {
              selectedStudent!.paid = true;
              setPaymentDetails();
            }
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
      } else if (_paymentDetail.text != 'platillo' &&
          _paymentDetail.text != 'paquete') {
        // payment other types
        var additionalPaymentCost = 0.0;

        if (_paymentDetail.text == ADDITIONAL) {
          double additionalNum = quantityNumber != null
              ? double.parse(quantityNumber.toString())
              : 0.0;
          additionalPaymentCost =
              additionalNum * selectedEvent!.pricing.additionalCost;
        } else {
          quantityNumber = 0;
        }

        if (_paymentDetail.text == ADDITIONAL && quantityNumber! > 0 && paymentAmount > additionalPaymentCost) {
          Flushbar(
            flushbarPosition: FlushbarPosition.TOP,
            title: 'Error',
            message:
                'El pago excede el total de adicionales, puedes abonar o pagar el total \$$additionalPaymentCost y despues agregar pagos adicionales u otro servicio',
            duration: Duration(seconds: 10),
            backgroundColor: Colors.red,
          ).show(context);
          return;
        }

        selectedStudent.payments.add(payment);

        var student =
            BuildStudentObject(quantityNumber!, additionalPaymentCost);

        EventService().saveStudent(student, token, payment.paymentDetail == ADDITIONAL).then((studentResponse) {
          if (studentResponse.id != -1) {
            setState(() {
              selectedStudent = studentResponse;
            });
            isEditMode = false;
            isNewStudent = false;
            mapSelectedStudent();
            remindingAdditional = selectedStudent != null &&
                    selectedStudent.payments!
                        .where((e) => e.paymentDetail == ADDITIONAL)
                        .isNotEmpty
                ? selectedStudent.additionalQuantity -
                    selectedStudent.payments
                        .where((e) => e.paymentDetail == ADDITIONAL)
                        .map((e) => e.amount)
                        .reduce((a, b) => a + b)
                : 0.0;
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
      _quantityNumber.clear();
      setAdditionalNumber();

      if (isPayingWithCurrentPayment && selectedStudent.folio.isEmpty) {
        selectedStudent.payments.add(payment);
        EventService()
            .saveStudentWithFolioData(selectedStudent, token)
            .then((value) => {
                  if (value.folio.isNotEmpty)
                    {
                      setState(() {
                        selectedStudent = value;
                        mapSelectedStudent();
                        setPaymentDetails();
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
    } catch (e) {
      log('error on add payment $e');
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        title: 'Error',
        message:
            'Error al agregar el pago, intente de nuevo o contacte a soporte, error $e.toString()',
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      ).show(context);
    }
  }

  void onQuantityChange(String value) {
    log("OnQuantityChange: $value");
    switch (_paymentDetail.text) {
      case ADDITIONAL:
        _paymentAmount.text = (double.tryParse(value)! *
                (selectedEvent.pricing!.additionalCost == 0
                    ? 0
                    : selectedEvent.pricing!.additionalCost!))
            .toString();
      case 'pre-fiesta':
        _paymentAmount.text =
            (double.tryParse(value)! * selectedEvent.pricing!.prePartyCost)
                .toString();
      case 'souvenir':
        _paymentAmount.text =
            (double.tryParse(value)! * selectedEvent.pricing!.souvenirCost)
                .toString();
      case 'pulsera':
        _paymentAmount.text =
            (double.tryParse(value)! * selectedEvent.pricing!.braceletCost)
                .toString();
      default:
        _paymentAmount.text = 0.0.toString();
        break;
    }

    log(_paymentAmount.text);
  }

  void deletePayment(Payment payment) {
    log('delete payment');
    setState(() {
      selectedStudent.payments.remove(payment);
    });

    if (payment.paymentDetail == ADDITIONAL) {
        remindingAdditional = selectedStudent != null &&
                selectedStudent.payments!
                    .where((e) => e.paymentDetail == ADDITIONAL)
                    .isNotEmpty
            ? selectedStudent.additionalQuantity -
                selectedStudent.payments
                    .where((e) => e.paymentDetail == ADDITIONAL)
                    .map((e) => e.amount)
                    .reduce((a, b) => a + b)
            : 0.0;
      if (remindingAdditional <= 0) {
        remindingAdditional = 0.0;
        selectedStudent!.additionalNumber -= payment.quantity;
        selectedStudent!.additionalQuantity = 0.0;
      } else {
        setState(() {
          remindingAdditional = remindingAdditional - payment.amount;
        });
        if(remindingAdditional <=0 ){
          selectedStudent!.additionalNumber -= payment.quantity;
          selectedStudent!.additionalQuantity =0;
        }
      }

      if (selectedStudent.additionalQuantity < 0) {
        log('(Alert) -- additional quantity is less than 0 for student ${selectedStudent.id}');
        selectedStudent.additionalQuantity = 0;
      }
      if (selectedStudent.additionalNumber < 0) {
        log('(Alert) -- additional additionalNumber is less than 0 for student ${selectedStudent.id}');
        selectedStudent.additionalNumber = 0;
      }
    }

    EventService()
        .saveStudent(selectedStudent, token, payment.paymentDetail == ADDITIONAL)
        .then((value) => {
              if (value.id != -1)
                {
                  setState(() {
                    paymentsHistory.remove(payment);
                  }),
                  Flushbar(
                    flushbarPosition: FlushbarPosition.TOP,
                    title: 'Éxito',
                    message: 'Pago del estudiante eliminado correctamente',
                    duration: Duration(seconds: 3),
                    backgroundColor: Colors.green,
                  ).show(context)
                }
              else
                {
                  Flushbar(
                    flushbarPosition: FlushbarPosition.TOP,
                    title: 'Error',
                    message:
                        'Error al eliminar el pago, intente de nuevo o contacte a soporte',
                    duration: Duration(seconds: 3),
                    backgroundColor: Colors.red,
                  ).show(context)
                }
            })
        .catchError((error) => {
              Flushbar(
                flushbarPosition: FlushbarPosition.TOP,
                title: 'Error',
                message:
                    'Error al eliminar el pago, intente de nuevo o contacte a soporte',
                duration: Duration(seconds: 3),
                backgroundColor: Colors.red,
              ).show(context)
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
                              appState.clearSelectedStudent(),
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => GraduationListPage(),
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
            title: Text(
              selectedStudent != null
                  ? (isEditMode ? 'Editando Alumno' : 'Administrar Pagos')
                  : 'Agregar Alumno',
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
                                      labelText: 'Apellidos del alumno',
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
                                    validator: (value) => (value != null &&
                                            value.isNotEmpty &&
                                            value.length < 10)
                                        ? 'La longitud del telefono debe ser de 10 digitos'
                                        : null,
                                    controller: _telephone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10)
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
                              children: [
                                Visibility(
                                    visible: selectedEvent != null &&
                                        selectedEvent.pricing!.souvenirCost > 0,
                                    child: Text('souvenir')),
                                SizedBox(width: 10),
                                Visibility(
                                    visible: selectedEvent != null &&
                                        selectedEvent.pricing!.souvenirCost > 0,
                                    child: Checkbox(
                                      value: addSouvenir,
                                      onChanged: (value) {
                                        isEditMode
                                            ? setState(() {
                                                addSouvenir = value!;
                                              })
                                            : null;
                                      },
                                    )),
                                SizedBox(width: 20),
                                Visibility(
                                    visible: selectedEvent != null &&
                                        selectedEvent.pricing!.prePartyCost > 0,
                                    child: Text('Pre fiesta')),
                                SizedBox(width: 10),
                                Visibility(
                                    visible: selectedEvent != null &&
                                        selectedEvent.pricing!.prePartyCost > 0,
                                    child: Checkbox(
                                      value: addPreParty,
                                      onChanged: (value) {
                                        isEditMode
                                            ? setState(() {
                                                addPreParty = value!;
                                              })
                                            : null;
                                      },
                                    )),
                                SizedBox(width: 20),
                                Visibility(
                                    visible: selectedEvent != null &&
                                        selectedEvent.pricing!.braceletCost > 0,
                                    child: Text('Pulsera')),
                                SizedBox(width: 10),
                                Visibility(
                                    visible: selectedEvent != null &&
                                        selectedEvent.pricing!.braceletCost > 0,
                                    child: Checkbox(
                                      value: addBracelet,
                                      onChanged: (value) {
                                        isEditMode
                                            ? setState(() {
                                                addBracelet = value!;
                                              })
                                            : null;
                                      },
                                    )),
                                SizedBox(width: 10),
                                Text('Es Alumno de cómite'),
                                Checkbox(
                                  value: isComity,
                                  onChanged: (value) {
                                    isEditMode
                                        ? setState(() {
                                            isComity = value!;
                                          })
                                        : null;
                                  },
                                )
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
                                      if (_telephone.text.isNotEmpty &&
                                          _telephone.text.length < 10) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                backgroundColor: Colors.red,
                                                content: Text(
                                                    'La longitud del telefono debe ser de 10 digitos')));
                                      } else {
                                        try {
                                          saveStudentData();
                                        } catch (e) {
                                          log('error on save student data $e');
                                          Flushbar(
                                            flushbarPosition:
                                                FlushbarPosition.TOP,
                                            title: 'Error',
                                            message:
                                                'Error al guardar el alumno, error: ${e.toString()}',
                                            duration: Duration(seconds: 3),
                                            backgroundColor: Colors.red,
                                          ).show(context);
                                        }
                                      }
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
                                SizedBox(width: 20),
                                ButtonTheme(
                                  minWidth: 100.0,
                                  height: 50.0,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStateProperty.all(Colors.blue),
                                      foregroundColor:
                                          WidgetStateProperty.all(Colors.white),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                  '¿Estás seguro que desea agregar cortesias?'),
                                              content: Text(
                                                  'Si sales se perderán los cambios realizados'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: Text('Cancelar'),
                                                ),
                                                TextButton(
                                                  onPressed: () => {
                                                    appState
                                                        .clearSelectedStudent(),
                                                    Navigator.of(context)
                                                        .pushReplacement(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            AmenitiesPage(),
                                                      ),
                                                    )
                                                  },
                                                  child: Text('Aceptar'),
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                    child: Text('Agregar cortesias'),
                                  ),
                                ),
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
                                    (selectedStudent.folio.isNotEmpty &&
                                            packageTypes.isNotEmpty ||
                                        selectedStudent!.paid),
                                child: Expanded(
                                    child: Text('PAGADO',
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.green))),
                              ),
                              // SizedBox(width: 20),
                              Expanded(
                                // flex: 1,
                                child: Text(
                                    'Total pagado: \$${(selectedStudent != null && selectedStudent!.payments.where((e) => e.paymentDetail == 'platillo' || e.paymentDetail == 'paquete').isNotEmpty ? selectedStudent.payments.where((e) => e.paymentDetail == 'platillo' || e.paymentDetail == 'paquete').map((e) => e.amount).reduce((a, b) => a + b) : 0)}',
                                    style: TextStyle(
                                        fontSize: 14.0, color: Colors.black)),
                              ),
                              SizedBox(width: 25),
                              Expanded(
                                child: Text(
                                    'Restante: \$${(selectedStudent != null && selectedStudent.payments.where((e) => e.paymentDetail == 'platillo' || e.paymentDetail == 'paquete').isNotEmpty ? selectedStudent!.totalCost - selectedStudent.payments.where((e) => e.paymentDetail == 'platillo' || e.paymentDetail == 'paquete').map((e) => e.amount).reduce((a, b) => a + b) : 0)}'),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                    'Total: \$${(selectedStudent != null ? selectedStudent!.totalCost : 0)}',
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
                          Visibility(
                              visible: selectedStudent != null &&
                                  packageTypes.isNotEmpty &&
                                  selectedStudent.folio.isNotEmpty,
                              child: Row(children: [
                                // Expanded(child:  Text('')),
                                Expanded(
                                  child: Text(
                                      'Total abonado adicionales: \$${(selectedStudent != null && selectedStudent!.payments.isNotEmpty && selectedStudent!.payments.where((e) => e.paymentDetail == ADDITIONAL).isNotEmpty ? selectedStudent.payments.where((e) => e.paymentDetail == ADDITIONAL).map((e) => e.amount)?.reduce((a, b) => a + b) : 0)}',
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(width: 25),
                                Expanded(
                                  child: Text(
                                      'Restante: \$${(selectedStudent != null && selectedStudent.payments.isNotEmpty && selectedStudent!.payments.where((e) => e.paymentDetail == ADDITIONAL).isNotEmpty ? remindingAdditional : 0)}',
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Text(
                                      'Total Adicionales: \$${(selectedStudent != null ? selectedStudent!.additionalQuantity : 0)}',
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                    child: Text(
                                        'Cantidad adicionales: ${selectedStudent != null ? selectedStudent!.additionalNumber : 0}',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold))),
                              ])),
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
                                                  controller: TextEditingController(
                                                      text: DateFormat(
                                                              'dd/MM/yyyy HH:mm')
                                                          .format(payment
                                                              .paymentDate)),
                                                  decoration: InputDecoration(
                                                      labelText:
                                                          'Fecha y hora de pago',
                                                      border:
                                                          OutlineInputBorder()),
                                                  readOnly: true,
                                                ),
                                              ),
                                              SizedBox(width: 20),
                                              Expanded(
                                                child: TextFormField(
                                                  controller: TextEditingController(
                                                      text: payment.quantity > 0
                                                          ? "${payment.paymentDetail} cant: ${payment.quantity}"
                                                          : payment
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
                                              Visibility(
                                                visible: selectedStudent !=
                                                        null &&
                                                    (!selectedStudent.paid ||
                                                        (payment.paymentDetail !=
                                                                'platillo' &&
                                                            payment.paymentDetail !=
                                                                'paquete')) &&
                                                    appState.selectedUser!
                                                            .role ==
                                                        1,
                                                child: Expanded(
                                                  child: IconButton(
                                                    icon: Icon(Icons.delete),
                                                    onPressed: () => {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  '¿Estás seguro de eliminar el pago, el historial de pago se puede ver afectado?'),
                                                              content: Text(
                                                                  'El pago se eliminará permanentemente'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(),
                                                                  child: Text(
                                                                      'Cancelar'),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () => {
                                                                    deletePayment(
                                                                        payment)
                                                                  },
                                                                  child: Text(
                                                                      'Eliminar'),
                                                                ),
                                                              ],
                                                            );
                                                          }),
                                                    },
                                                  ),
                                                ),
                                              ),
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
                              Text('Pago: ',
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
                                  readOnly: false,
                                  controller: _paymentAmount,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    ThousandsSeparatorInputFormatter(),
                                  ],
                                  decoration: InputDecoration(
                                      labelText: 'Monto del pago',
                                      border: OutlineInputBorder()),
                                  validator: (value) =>
                                      _paymentDetail.text != ADDITIONAL &&
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
                                      log('selected payment detail $selection');

                                      setAdditionalNumber();
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
                                    visible: showAQuantityNumberInput &&
                                        remindingAdditional <= 0.0,
                                    child: Expanded(
                                      child: TextFormField(
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        validator: (value) => selectedStudent !=
                                                    null &&
                                                showAQuantityNumberInput &&
                                                remindingAdditional > 0.0 &&
                                                (value != null && value.isEmpty)
                                            ? 'El número de personas es requerido'
                                            : null,
                                        controller: _quantityNumber,
                                        decoration: InputDecoration(
                                          labelText:
                                              _paymentDetail.text == ADDITIONAL
                                                  ? 'Personas adicionales'
                                                  : 'cantidad',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) => {
                                          if (value.isNotEmpty)
                                            {onQuantityChange(value)}
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
                                    if (((selectedStudent == null) ||
                                        (selectedStudent.folio.isEmpty &&
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
                                    } else if ((_paymentDetail.text ==
                                                ADDITIONAL &&
                                            selectedStudent!
                                                .folio.isNotEmpty) ||
                                        (_paymentDetail.text != ADDITIONAL &&
                                            _paymentDetail.text != 'platillo' &&
                                            _paymentDetail.text != 'paquete')) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Confirmar pago'),
                                              content: Text(
                                                  '¿Está seguro de agregar el pago de ${_paymentDetail.text} ${double.parse(_paymentAmount.text.replaceAll(",", ""))} ?'),
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
                                      log('total cost ${selectedStudent!.totalCost}');
                                      if ((_paymentDetail.text == 'platillo' ||
                                              _paymentDetail.text ==
                                                  'paquete') &&
                                          selectedStudent!.totalCost == 0) {
                                        Flushbar(
                                          flushbarPosition:
                                              FlushbarPosition.TOP,
                                          title: 'Error',
                                          message:
                                              'El alumno no tiene paquete/platillo asignado, por favor asigna paquete/platillo antes de agregar un pago',
                                          duration: Duration(seconds: 6),
                                          backgroundColor: Colors.red,
                                        ).show(context);
                                      } else {
                                        Flushbar(
                                          flushbarPosition:
                                              FlushbarPosition.TOP,
                                          title: 'Error',
                                          message:
                                              'El alumno ya ha pagado el total de su paquete/platillo solo puedes pagar adicionales o extras',
                                          duration: Duration(seconds: 6),
                                          backgroundColor: Colors.red,
                                        ).show(context);
                                      }
                                    }
                                  }
                                },
                                child: Text('Agregar Pago'),
                              ),
                              SizedBox(width: 20),
                              SizedBox(height: 200),
                            ],
                          )
                        ]),
                      ),
                    ],
                  ))),
        ));
  }
}
