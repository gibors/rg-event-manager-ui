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
  var selectedUser;
  List<PlutoRow> rows = [];
  List<PlutoRow> rowsEvents = [];
  late PlutoGridStateManager stateManagerProviders;
  PlutoGridMode mode = PlutoGridMode.selectWithOneTap;

  final controller = ScrollController();
  late Future<List<User>> _func;
  double offset = 0;

  List<PlutoColumn>  columns = [
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
      // height: 800,
      // width: 1500,
              appBar: AppBar(
            title: Text('Sistema RG Eventos - Usuario conectado: ${appState.selectedUser != null ? '${appState.selectedUser!.name} ${appState.selectedUser!.lastname} con rol de ${appState.selectedUser!.role == 1 ? 'admin': (appState.selectedUser!.role == 2 ? 'operativo' : 'solo lectura')}': ''}',
                style: TextStyle(fontSize: 28.0, color: const Color.fromARGB(255, 113, 7, 132))),
                    automaticallyImplyLeading: false,
        ),
      body: FutureBuilder<List<User>>(
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
              Text('Agregar usuario', style: Theme.of(context).textTheme.bodyLarge),

              IconButton(
                icon: Icon(Icons.add_box),
                onPressed: () {
                  appState.clearSelectedUserToEdit();
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddUserPage()));
                },
              ),
              SizedBox(width: 20),
              Visibility(visible: appState.selectedUserToEdit != null , 
              child: Container( child: Row(children: [
                Text('Editar usuario', style: Theme.of(context).textTheme.bodyLarge),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  if (appState.selectedUserToEdit != null){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddUserPage()));
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
              ),
           
              ],),
                 
              ))
            ],
          )
          ,
          SizedBox(height: 30),
          Row(children: [
            Text('Total de usuarios: ${snapshot.data!.length}', style: Theme.of(context).textTheme.bodyMedium),
             SizedBox(width: 30),
             Text('Usuario seleccionado: ${selectedUser != null ? (selectedUser!.name + ' ' + selectedUser!.lastname) : 'Ninguno'}', 
             style: Theme.of(context).textTheme.bodyMedium),

          ],),
          SizedBox(height: 20),
        Expanded(
          child: PlutoGrid(
            mode: mode,
          columns: columns,
          rows: snapshot.data!.map((e) => PlutoRow( 
                  cells: {
                    'name': PlutoCell(value: e.name),
                    'lastName': PlutoCell(value: e.lastname),
                    'email': PlutoCell(value: e.email),
                    'username': PlutoCell(value: e.username),
                    'role': PlutoCell(value: e.role == 1 ? 'Admin' : (e.role == 2 ? 'Operador' : 'Solo lectura')),
                  }
                )).toList(),
          onChanged: (PlutoGridOnChangedEvent event) {
            print(event);
          },
          onSelected: (event) => {
            log('selected user: ${event.row!.cells['name']!.value}'),
            setState(() {
              selectedUser = snapshot.data!.firstWhere((element) => element.username == event.row!.cells['username']!.value);
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
                return resolver<ContainsClass>() as PlutoFilterType;
              }           
              ),
          ),
          createFooter: (stateManager) {
                      stateManager.setPageSize(15   , notify: false); // default 40
          return PlutoPagination(stateManager);

          },
          ) 
        ),
        ],
        
      ),
      ),
    )
          
            : const Center(child: CircularProgressIndicator()),
      )
    );

  }
}