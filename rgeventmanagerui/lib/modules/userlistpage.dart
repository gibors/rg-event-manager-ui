import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/User.dart';
import 'package:rg_event_management_ui/modules/adduserpage.dart';
import 'package:rg_event_management_ui/services/userservices.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  static const _brandColor = Color.fromARGB(255, 113, 7, 132);

  var selectedUser;
  List<PlutoRow> rows = [];
  List<PlutoRow> rowsEvents = [];
  late PlutoGridStateManager stateManagerProviders;
  PlutoGridMode mode = PlutoGridMode.selectWithOneTap;

  final controller = ScrollController();
  late Future<List<User>> _func;
  double offset = 0;

  List<PlutoColumn> columns = [
    PlutoColumn(
      title: 'Nombre',
      field: 'name',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Apellido',
      field: 'lastName',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Email',
      field: 'email',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Nombre de usuario',
      field: 'username',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Role',
      field: 'role',
      type: PlutoColumnType.text(),
    ),
  ];

  @override
  void initState() {
    var appState = context.read<MyAppState>();
    var token = appState.appToken;
    _func = UserService().getUsers(token);
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
      body: FutureBuilder<List<User>>(
        future: _func,
        builder: (context, snapshot) => snapshot.hasData
            ? Column(
                children: [
                  _buildHeaderSection(context, appState, snapshot.data!),
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
                                  'lastName': PlutoCell(value: e.lastname),
                                  'email': PlutoCell(value: e.email),
                                  'username': PlutoCell(value: e.username),
                                  'role': PlutoCell(
                                      value: e.role == 1
                                          ? 'Admin'
                                          : (e.role == 2
                                              ? 'Operador'
                                              : 'Solo lectura')),
                                }))
                            .toList(),
                        onChanged: (PlutoGridOnChangedEvent event) {
                          print(event);
                        },
                        onSelected: (event) => {
                          log('selected user: ${event.row!.cells['name']!.value}'),
                          setState(() {
                            selectedUser = snapshot.data!.firstWhere(
                                (element) =>
                                    element.username ==
                                    event.row!.cells['username']!.value);
                            appState.setSelectedUserToEdit(selectedUser);
                          })
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
                            },
                          ),
                        ),
                        createFooter: (stateManager) {
                          stateManager.setPageSize(15, notify: false);
                          return PlutoPagination(stateManager);
                        },
                      ),
                    ),
                  ),
                  _buildFooter(appState, snapshot.data!),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildHeaderSection(
      BuildContext context, MyAppState appState, List<User> users) {
    return Container(
      color: Colors.grey.shade50,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Administrar Usuarios',
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
                  appState.clearSelectedUserToEdit();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AddUserPage()));
                },
                icon: Icon(Icons.person_add, size: 18),
                label: Text('Agregar usuario'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              if (appState.selectedUserToEdit != null)
                ElevatedButton.icon(
                  onPressed: () {
                    if (appState.selectedUserToEdit != null) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AddUserPage()));
                    } else {
                      Flushbar(
                        flushbarPosition: FlushbarPosition.TOP,
                        title: 'Error',
                        message: 'Selecciona un usuario para editar',
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.red,
                      ).show(context);
                    }
                  },
                  icon: Icon(Icons.edit, size: 18),
                  label: Text('Editar usuario'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
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
                avatar: Icon(Icons.security, size: 18),
                label: Text('Total usuarios: ${users.length}'),
              ),
              SizedBox(width: 12),
              Chip(
                avatar: Icon(Icons.person_pin, size: 18),
                label: Text(selectedUser != null
                    ? 'Seleccionado: ${selectedUser!.name} ${selectedUser!.lastname}'
                    : 'Ninguno seleccionado'),
                backgroundColor: selectedUser != null
                    ? _brandColor.withOpacity(0.1)
                    : Colors.grey.shade200,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(MyAppState appState, List<User> users) {
    final adminCount = users.where((u) => u.role == 1).length;
    final operatorCount = users.where((u) => u.role == 2).length;
    final readOnlyCount = users.where((u) => u.role != 1 && u.role != 2).length;

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
            'Admin: $adminCount  |  Operadores: $operatorCount  |  Solo lectura: $readOnlyCount  |  Total: ${users.length}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          if (selectedUser != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _brandColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Usuario: ${selectedUser!.name} ${selectedUser!.lastname}',
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