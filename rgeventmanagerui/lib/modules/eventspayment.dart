import 'dart:developer';
import 'package:another_flushbar/flushbar.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/formatters/ThousandsSeparatorInputFormatter.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/Student.dart';
import 'package:rg_event_management_ui/services/eventservice.dart';

class EventPaymentPage extends StatefulWidget {
  @override
  _EventPaymentPageState createState() => _EventPaymentPageState();
}

class _EventPaymentPageState extends State<EventPaymentPage> {
  var token = "";
  var selectedEvent;
  var appState;

  final _formKey = GlobalKey<FormState>();
  final GlobalKey _paymentMethodKey = GlobalKey();
  final FocusNode _paymentMethodFocus = FocusNode();

  var _dishNumber = TextEditingController();
  var _paymentMethodController = TextEditingController();
  var _additionalNumber = TextEditingController();
  var _paymentAmount = TextEditingController();
  var _paymentDetail = TextEditingController();
  var _paymentDetailKey = GlobalKey<FormFieldState>();
  var _paymentDetailFocus = FocusNode();

  List<Payment> paymentsHistory = [];

  List<String> packageTypes = [];

  List<String> paymentMethods = ['Efectivo', 'Tarjeta', 'Transferencia'];
  List<String> paymentDetails = [];

  bool addSouvenir = false;
  bool addPreParty = false;

  @override
  void initState() {
    appState = context.read<MyAppState>();
    selectedEvent = appState.selectedEvent;
    token = appState.appToken;
    
      EventService()
          .getPaymentsByEventId(token, selectedEvent!.id)
          .then((payments) {
        setState(() {
          paymentsHistory = payments;
        });
      });
    
    setPaymentDetails();
    super.initState();
  }


  setPaymentDetails() {
    setState(() {
    paymentDetails.clear();
    paymentDetails.add(selectedEvent!.eventType.description);
  });

    
  }

  double calculateCost(packageType) {
    var totalCost = 0.0;

   
      totalCost = _dishNumber.text.isEmpty
          ? 0
          : double.parse(_dishNumber.text) * selectedEvent.pricing!.dishCost;
    

    return totalCost;
  }

 
  
  addPayment() {

      var ispaid = selectedEvent.totalCost <=
          (paymentsHistory.isNotEmpty
              ? paymentsHistory
                  .where((e) => e.paymentDetail == selectedEvent.name)
                  .map((e) => e.amount)
                  .reduce((a, b) => a + b)
              : 0) +
              double.parse(_paymentAmount.text.isEmpty
                  ? "0"
                  : _paymentAmount.text.replaceAll(',', ''));

      // payments for other events
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
          iva: 0,
          quantity: 0);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => {
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
                  
              },
            ),
            title: Text(
              'Administrar pago'),
            ),
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      Visibility(
                        visible: true,
                        child: Column(children: [
                          Row(
                            children: [
                              Text('Historial de pagos',
                                  style: TextStyle(
                                      fontSize: 20.0, color: Colors.blue)),
                              SizedBox(width: 20),
                              Visibility(
                                visible: false,
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
                                    'Total pagado: \$${ (paymentsHistory.isNotEmpty ? paymentsHistory.where((e) => e.paymentDetail == selectedEvent!.name).map((e) => e.amount).reduce((a, b) => a + b) : 0)}',
                                    style: TextStyle(
                                        fontSize: 14.0, color: Colors.black)),
                              ),
                              SizedBox(width: 25),
                              Expanded(
                                child: Text(
                                    'Restante: \$${(selectedEvent!.totalCost - (paymentsHistory.isNotEmpty ? paymentsHistory.where((e) => e.paymentDetail == selectedEvent!.name).map((e) => e.amount).reduce((a, b) => a + b) : 0))}'),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                    'Total: \$${(selectedEvent!.totalCost)}',
                                    style: TextStyle(
                                        fontSize: 14.0, color: Colors.black)),
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
                        visible: selectedEvent != null && selectedEvent!.totalCost > 0,
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
                                      log('selected payment detail $selection');
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
