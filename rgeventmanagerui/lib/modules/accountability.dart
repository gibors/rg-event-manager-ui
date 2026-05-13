
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/Student.dart';

// import 'package:pluto_grid_export/pluto_grid_export.dart' as pluto_grid_export;
class AccountabilityPage extends StatefulWidget {
  @override
  _AccountabilityPage createState() => _AccountabilityPage();
}

class _AccountabilityPage extends State<AccountabilityPage> {
  // late PlutoGridStateManager plutoGridStateManager;

  List<PlutoColumn> columns = [
    PlutoColumn(
      title: 'Nombre',
      field: 'student_name',
      width: 200,
      type: PlutoColumnType.text(),
    ),
  ];

  List<PlutoRow> rows = [];
  List<PlutoRow> rowsEvents = [];
  late PlutoGridStateManager stateManagerProviders;
  PlutoGridMode mode = PlutoGridMode.selectWithOneTap;

  final controller = ScrollController();
  // late Future<List<Student>> _func;
  double offset = 0;
  @override
  void initState() {
    var appState = context.read<MyAppState>();
    var token = appState.appToken;
    // var selectedEvent = appState.selectedEvent;
    // appState.clearSelectedStudent();
    // _func = EventService().getStudentsByEvent(token, selectedEvent!.id);
    // controller.addListener(onScroll);

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
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Icon(Icons.event_note, color: const Color.fromARGB(255, 113, 7, 132), size: 28),
              SizedBox(width: 10),
              Text('RG Eventos',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 113, 7, 132))),
            ],
          ),
          actions: [
            if (appState.selectedUser != null)
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color.fromARGB(255, 113, 7, 132),
                      child: Text(
                        '${appState.selectedUser!.name[0]}${appState.selectedUser!.lastname[0]}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${appState.selectedUser!.name} ${appState.selectedUser!.lastname}',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          appState.selectedUser!.role == 1 ? 'Admin' : (appState.selectedUser!.role == 2 ? 'Operador' : 'Solo lectura'),
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      body: Center(
          child: FutureBuilder<List<Student>>(
         future: null,
        builder: (context, snapshot) => snapshot.hasData
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                       
                          Text('Agregar pago',
                              style: Theme.of(context).textTheme.bodyLarge),
                          IconButton(
                            icon: Icon(Icons.add_box),
                            onPressed: () {
                              // appState.clearSelectedStudent();
                              // Navigator.of(context).push(MaterialPageRoute(
                              //     builder: (context) =>
                              //         GraduationPaymentPage()));
                            },
                          ),                          
                        ],
                      ),
                      SizedBox(height: 30),
                      // Row(
                      //   children: [
                      //     Text('Total de alumnos: ${snapshot.data!.length}',
                      //         style: TextStyle(
                      //             fontSize: 20.0,
                      //             color: Colors.blue[900],
                      //             fontWeight: FontWeight.bold)),
                      //     SizedBox(width: 30),
                      //     Text(
                      //         'Alumno seleccionado: ${appState.selectedStudent != null ? ('${appState.selectedStudent!.name} ${appState.selectedStudent!.lastName}') : 'Ninguno'}',
                      //         style: TextStyle(
                      //             fontSize: 20.0,
                      //             color: Colors.blue[900],
                      //             fontWeight: FontWeight.bold)),
                      //   ],
                      // ),
                      // SizedBox(height: 20),
                      Expanded(
                        child: PlutoGrid(
                        mode: mode,
                        columns: columns,
                        rows: snapshot.data!
                            .map((e) => PlutoRow(cells: {
                                  'student_name': PlutoCell(value: e.name),
                                }))
                            .toList(),
                        onChanged: (PlutoGridOnChangedEvent event) {
                          print(event);
                        },
                        onSelected: (student) => {
                          // log('selected student: ${student.row!.cells['student_name']!.value}'),
                          // appState.setSelectedStudent(snapshot.data!.firstWhere(
                          //     (element) =>
                          //         element.name ==
                          //         student.row!.cells['student_name']!.value)),
                          // appState.selectedStudent!.paid = appState
                          //             .selectedStudent!.totalCost -
                          //         (appState.selectedStudent!.payments.isNotEmpty
                          //             ? appState.selectedStudent!.payments
                          //                 .map((e) => e.amount)
                          //                 .reduce((value, element) =>
                          //                     value + element)
                          //             : 0) <=
                          //     0,
                        },
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          stateManagerProviders = event.stateManager;
                          event.stateManager.setShowColumnFilter(true);
                          event.stateManager.setSelecting(false);
                          stateManagerProviders
                              .setSelectingMode(PlutoGridSelectingMode.row);
                          event.stateManager
                              .setSelectingMode(PlutoGridSelectingMode.row);
                          event.stateManager.setSortOnlyEvent(true);
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
