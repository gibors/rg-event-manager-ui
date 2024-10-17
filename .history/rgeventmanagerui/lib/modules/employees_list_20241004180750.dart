import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/Employee.dart';
import 'package:rg_event_management_ui/modules/add_employee.dart';
import 'package:rg_event_management_ui/services/employees_service.dart';

class EmployeesView extends StatefulWidget {
  // const EmployeesView({Key? key}) : super(key: key);

  @override
  _EmployeesViewState createState() => _EmployeesViewState();
}

class _EmployeesViewState extends State<EmployeesView> {
  // final _key = GlobalKey();
  var appState;
  Employee ? SelectedEmployee;
  final controller = ScrollController();
  late Future<List<Employee>> _func;
  double offset = 0;
  late PlutoGridStateManager stateManagerProviders;
  PlutoGridMode mode = PlutoGridMode.selectWithOneTap;

  @override
  void initState() {
    
    appState = context.read<MyAppState>();
    appState.clearSelectedEmployee();
    var token = appState.appToken;
    _func = EmployeesService().getAllEmployees(token);
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

  List<PlutoColumn> columns = [
    PlutoColumn(
      title: 'Nombre',
      field: 'name',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Apellido Paterno',
      field: 'first_surname',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Apellido Materno',
      field: 'second_surname',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Email',
      field: 'email',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Telefono',
      field: 'phone',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Puesto',
      field: 'job_title',
      type: PlutoColumnType.text(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
     appState = context.watch<MyAppState>();

    return 
    SizedBox(
      child: FutureBuilder<List<Employee>>(
        future: _func,
        builder: (context, snapshot) => snapshot.hasData
            ? Center(
                child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
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
                        Text('Agregar Empleado',
                            style: Theme.of(context).textTheme.bodyLarge),
                        IconButton(
                          icon: Icon(Icons.add_box),
                          onPressed: () {
                            appState.clearSelectedEmployee();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AddEmployeePage()));
                          },
                        ),
                        SizedBox(width: 20),
                        Visibility(
                            visible: SelectedEmployee != null,
                            child: Container(
                          child: Row(
                            children: [
                              Text('Editar Empleado',
                                  style: Theme.of(context).textTheme.bodyLarge),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => AddEmployeePage()));
                                },
                              ),
                              SizedBox(width: 20),
                            ],
                          ),
                        )),
                      ],
                    ),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Text('Total de empleados: ${snapshot.data!.length}',
                            style: Theme.of(context).textTheme.bodyMedium),
                        SizedBox(width: 30),
                        Text(
                            'Proveedor seleccionado: ${ SelectedEmployee!=null ? '${SelectedEmployee!.name} ${SelectedEmployee!.firstSurname}' : 'Ninguno'}',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                    SizedBox(height: 30),
                    Expanded(
                        child: PlutoGrid(
                      mode: mode,
                      columns: columns,
                      rows: snapshot.data!
                          .map((e) => PlutoRow(cells: {
                                'name': PlutoCell(value: e.name),
                                'first_surname':
                                    PlutoCell(value: e.firstSurname),
                                'second_surname':
                                    PlutoCell(value: e.secondSurname),
                                'email': PlutoCell(value: e.email),
                                'phone': PlutoCell(value: e.phone),
                                'job_title': PlutoCell(value: e.position),
                              }))
                          .toList(),
                      onSelected: (event) => {
                        setState(() {
                        SelectedEmployee = (snapshot.data!.firstWhere(
                            (element) =>
                                element.name ==
                                event.row!.cells['name']!.value));
                        }),
                        appState.setSelectedEmployee(SelectedEmployee!),
                        log('Selected employee: ${SelectedEmployee!.name}')
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
                    ))
                  ],
                ),
              ))
            : snapshot.hasError
                ? Text('Error: ${snapshot.error}')
                : CircularProgressIndicator(),
      ),
    );
  }
}
