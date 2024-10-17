import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/Student.dart';
import 'package:rg_event_management_ui/modules/eventpayment.dart';
import 'package:rg_event_management_ui/services/eventservice.dart';

class GraduationListPage extends StatefulWidget {
  @override
  _GraduationListPageState createState() => _GraduationListPageState();
}

class _GraduationListPageState extends State<GraduationListPage> {
  List<PlutoColumn> columns = [
    PlutoColumn(
      title: 'Nombre',
      field: 'student_name',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Apellido',
      field: 'student_lastname',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'paquete/platillo',
      field: 'package',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Total platillo/paquete',
      field: 'total_cost',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Pagado platillo/paquete',
      field: 'paid',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Restante',
      field: 'remaining',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Estado pago',
      field: 'student_status',
      type: PlutoColumnType.select(<String>['Pendiente', 'Pagado']),
      renderer: (rendererContext) {
        Color textColor = Colors.black;

        if (rendererContext.cell.value == 'Pendiente') {
          textColor = Colors.red;
        } else if (rendererContext.cell.value == 'Pagado') {
          textColor = Colors.green;
        }

        return Text(
          rendererContext.cell.value.toString(),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    ),
    PlutoColumn(
      title: 'Folio',
      field: 'folio',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Total Adicional',
      field: 'additional_cost',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Pagado Adicional',
      field: 'additional_paid',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Restante Adicional',
      field: 'additional_remaining',
      type: PlutoColumnType.text(),
    ),
  ];

  List<PlutoRow> rows = [];
  List<PlutoRow> rowsEvents = [];
  late PlutoGridStateManager stateManagerProviders;
  PlutoGridMode mode = PlutoGridMode.selectWithOneTap;

  final controller = ScrollController();
  late Future<List<Student>> _func;
  double offset = 0;
  @override
  void initState() {
    var appState = context.read<MyAppState>();
    var token = appState.appToken;
    var selectedEvent = appState.selectedEvent;
    appState.clearSelectedStudent();
    _func = EventService().getStudentsByEvent(token, selectedEvent!.id);
    controller.addListener(onScroll);

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onScroll() {
    setState(() {
      offset = (controller.hasClients) ? controller.offset : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: Text(appState.selectedEvent != null ? appState.selectedEvent!.name : '',
            style: TextStyle(fontSize: 24.0, color: Colors.blue[900])),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            appState.setIndex(0);
            Navigator.of(context)
                .pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => EventsHomePage(),
                  ),
                )
                .then((_) {});
          },
        ),
      ),
      body: Center(
          child: FutureBuilder<List<Student>>(
        future: _func,
        builder: (context, snapshot) => snapshot.hasData
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text('Exportar a PDF',
                              style: Theme.of(context).textTheme.bodyLarge),
                          IconButton(
                            icon: Icon(Icons.picture_as_pdf),
                            onPressed: () {},
                          ),
                          SizedBox(width: 20),
                          Text('Descargar excel',
                              style: Theme.of(context).textTheme.bodyLarge),
                          IconButton(
                            icon: Icon(Icons.download),
                            onPressed: () {},
                          ),
                          SizedBox(width: 20),
                          Text('Agregar alumno',
                              style: Theme.of(context).textTheme.bodyLarge),
                          IconButton(
                            icon: Icon(Icons.add_box),
                            onPressed: () {
                              appState.clearSelectedStudent();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => EventPaymentPage()));
                            },
                          ),
                          SizedBox(width: 20),
                          Visibility(
                              visible: (appState.selectedStudent != null),
                              child: Container(
                                child: Row(
                                  children: [
                                    Text('Agregar Pago / Editar Alumno',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        if (appState.selectedStudent != null) {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EventPaymentPage()));
                                        } else {
                                          Flushbar(
                                            flushbarPosition:
                                                FlushbarPosition.TOP,
                                            title: 'Error',
                                            message:
                                                'Selecciona un alumno para editar',
                                            duration: Duration(seconds: 3),
                                            backgroundColor: Colors.red,
                                          ).show(context);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ))
                        ],
                      ),
                      SizedBox(height: 30),
                      Row(
                        children: [
                          Text('Total de alumnos: ${snapshot.data!.length}',
                              style: Theme.of(context).textTheme.bodyMedium),
                          SizedBox(width: 30),
                          Text(
                              'Alumno seleccionado: ${appState.selectedStudent != null ? ('${appState.selectedStudent!.name} ${appState.selectedStudent!.lastName}') : 'Ninguno'}',
                              style: Theme.of(context).textTheme.bodyMedium),
                          SizedBox(width: 30),
                          IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: () {
                              setState(() {
                                appState.clearSelectedStudent();
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Expanded(
                          child: PlutoGrid(
                        mode: mode,
                        columns: columns,
                        rows: snapshot.data!
                            .map((e) => PlutoRow(cells: {
                                  'student_name': PlutoCell(value: e.name),
                                  'student_lastname':
                                      PlutoCell(value: e.lastName),
                                  'package': PlutoCell(value: e.packageType.isEmpty ? 'platillo' : e.packageType),
                                  'total_cost': PlutoCell(value: e.totalCost),
                                  'paid': PlutoCell(
                                      value: e.payments.isNotEmpty && e.payments.where( (element) => element.paymentDetail == 'platillo' || element.paymentDetail == 'paquete').isNotEmpty
                                          ? e.payments.where((element) => element.paymentDetail == 'platillo' || element.paymentDetail == 'paquete').toList()
                                              .map((e) => e.amount)
                                              .reduce((value, element) =>
                                                  value + element)
                                          : 0),
                                  'remaining': PlutoCell(
                                      value: e.totalCost -
                                          (e.payments.isNotEmpty
                                              ? e.payments
                                                  .map((e) => e.amount)
                                                  .reduce((value, element) =>
                                                      value + element)
                                              : 0)),
                                  'student_status': PlutoCell(
                                      value: e.totalCost -
                                                  (e.payments.isNotEmpty && e.payments.where((element) => element.paymentDetail == 'platillo' || element.paymentDetail == 'paquete').isNotEmpty
                                                      ? e.payments.where((element) => element.paymentDetail == 'platillo' 
                                                      || element.paymentDetail == 'paquete').toList()
                                                      .map((e) => e.amount).reduce( (value, element) => value + element) : 0) <= 0
                                              
                                          ? 'Pagado'
                                          : 'Pendiente'),
                                  'folio': PlutoCell(value:  e.folio.isNotEmpty ? e.folio : ''),
                                }))
                            .toList(),
                        onChanged: (PlutoGridOnChangedEvent event) {
                          print(event);
                        },
                        onSelected: (student) => {
                          log('selected student: ${student.row!.cells['student_name']!.value}'),

                          appState.setSelectedStudent(snapshot.data!.firstWhere(
                              (element) =>
                                  element.name ==
                                  student.row!.cells['student_name']!.value)),
                                  appState.selectedStudent!.paid = appState.selectedStudent!.totalCost -
                                                  (appState.selectedStudent!.payments.isNotEmpty
                                                      ? appState.selectedStudent!.payments
                                                          .map((e) => e.amount)
                                                          .reduce((value,
                                                                  element) =>
                                                              value + element)
                                                      : 0) <=
                                              0,
                        },
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          stateManagerProviders = event.stateManager;
                          event.stateManager.setShowColumnFilter(true);
                          event.stateManager.setSelecting(false);
                          event.stateManager
                              .setSelectingMode(PlutoGridSelectingMode.row);
                          event.stateManager.setEditing(false);
                        },
                        configuration: PlutoGridConfiguration(
                          columnFilter: PlutoGridColumnFilterConfig(
                              filters: const [
                                ContainsClass(),
                              ],
                              resolveDefaultColumnFilter: (column, resolver) {
                                return resolver<ContainsClass>()
                                    as PlutoFilterType;
                              }),
                        ),
                        createFooter: (stateManager) {
                          stateManager.setPageSize(15,
                              notify: false); // default 40
                          return PlutoPagination(stateManager);
                        },
                      )),
                    ],
                  ),
                ),
              )
            : snapshot.hasError
                ? Text('Error: ${snapshot.error}')
                : CircularProgressIndicator(),
      )),
    );
  }
}
