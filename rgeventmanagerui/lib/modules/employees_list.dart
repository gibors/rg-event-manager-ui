import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/Employee.dart';
import 'package:rg_event_management_ui/modules/add_employee.dart';
import 'package:rg_event_management_ui/services/employees_service.dart';

class EmployeesView extends StatefulWidget {
  @override
  _EmployeesViewState createState() => _EmployeesViewState();
}

class _EmployeesViewState extends State<EmployeesView> {
  static const _brandColor = Color.fromARGB(255, 113, 7, 132);

  var appState;
  Employee? SelectedEmployee;
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

  bool deleteEmployee(Employee employee) {
    EmployeesService()
        .deleteEmployee(appState!.appToken, employee.id)
        .then((value) {
              if (value == "ForeignKey") {
                  Flushbar(
                    title: 'Empleado eliminado',
                    message: 'El empleado ha sido eliminado correctamente',
                    duration: Duration(seconds: 3),
                  )..show(context).then((r) => setState(() {
                        _func = EmployeesService()
                            .getAllEmployees(appState.appToken);
                      }));
                }
            })
        .catchError((error) {
              Flushbar(
                title: 'Error',
                message: 'No se pudo eliminar el empleado',
                duration: Duration(seconds: 3),
              ).show(context);
            });
    return true;
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

  String _getRoleName(int? role) {
    if (role == 1) return 'Admin';
    if (role == 2) return 'Operador';
    return 'Solo lectura';
  }

  @override
  Widget build(BuildContext context) {
    appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(Icons.event_note, color: _brandColor, size: 28),
            SizedBox(width: 10),
            Text('RG Eventos',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _brandColor)),
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
                    backgroundColor: _brandColor,
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
                        _getRoleName(appState.selectedUser!.role),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
      body: FutureBuilder<List<Employee>>(
        future: _func,
        builder: (context, snapshot) => snapshot.hasData
            ? Column(
                children: [
                  _buildHeaderSection(context, snapshot.data!),
                  Divider(height: 1),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16),
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
                          stateManager.setPageSize(15, notify: false);
                          return PlutoPagination(stateManager);
                        },
                      ),
                    ),
                  ),
                  _buildFooter(snapshot.data!),
                ],
              )
            : snapshot.hasError
                ? Text('Error: ${snapshot.error}')
                : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, List<Employee> employees) {
    return Container(
      color: Colors.grey.shade50,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Empleados',
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.bold, color: _brandColor),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.clearSelectedEmployee();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AddEmployeePage()));
                },
                icon: Icon(Icons.person_add, size: 18),
                label: Text('Agregar empleado'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              if (SelectedEmployee != null)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AddEmployeePage()));
                  },
                  icon: Icon(Icons.edit, size: 18),
                  label: Text('Editar empleado'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              if (SelectedEmployee != null)
                ElevatedButton.icon(
                  onPressed: () {
                    if (SelectedEmployee != null) {
                      deleteEmployee(SelectedEmployee!);
                      appState.clearSelectedEmployee();
                      appState.setIndex(3);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => EventsHomePage(),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.delete, size: 18),
                  label: Text('Eliminar empleado'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Chip(
                avatar: Icon(Icons.badge, size: 18),
                label: Text('Total empleados: ${employees.length}'),
              ),
              SizedBox(width: 12),
              Chip(
                avatar: Icon(Icons.person_pin, size: 18),
                label: Text(SelectedEmployee != null
                    ? 'Seleccionado: ${SelectedEmployee!.name} ${SelectedEmployee!.firstSurname}'
                    : 'Ninguno seleccionado'),
                backgroundColor: SelectedEmployee != null
                    ? _brandColor.withValues(alpha: 0.1)
                    : Colors.grey.shade200,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(List<Employee> employees) {
    final positions = employees.map((e) => e.position).toSet();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Puestos: ${positions.length}  |  Total empleados: ${employees.length}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          if (SelectedEmployee != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _brandColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Empleado: ${SelectedEmployee!.name} ${SelectedEmployee!.firstSurname}',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
