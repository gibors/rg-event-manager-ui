
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/services/providersservice.dart';

class ProviderListPage extends StatefulWidget {
  @override
  _ProviderListPageState createState() => _ProviderListPageState();

}

class _ProviderListPageState extends State<ProviderListPage> {
  
  List<PlutoColumn> columns = [
    PlutoColumn(
      title: 'Nombre',
      field: 'name',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Email',
      field: 'email',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Teléfono',
      field: 'phone',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Tipo de servicio',
      field: 'serviceType',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Costo',
      field: 'cost',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Descripción de costo',
      field: 'costDescription',
      type: PlutoColumnType.text(),
    ),
  ];
        
  List<PlutoRow> rows = [];
  List<PlutoRow> rowsEvents = [];
  late PlutoGridStateManager stateManagerProviders;
  PlutoGridMode mode = PlutoGridMode.selectWithOneTap;

  final controller = ScrollController();
  late Future<List<Provider>> _func;
  double offset = 0;
  @override
  void initState() {
    
    var appState = context.read<MyAppState>();
    var token = appState.appToken; 

    ProviderService providerService = ProviderService();
    _func = providerService.getAllProviders(token);

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
        title: Text('Proveedores'),  
      ),
      body: Center(
        child: FutureBuilder<List<Provider>>(
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
              Text('Exportar a PDF', style: Theme.of(context).textTheme.bodyLarge),
              IconButton(
                icon: Icon(Icons.picture_as_pdf),
                onPressed: () {
                },
              ),
              SizedBox(width: 20),
              Text('Descargar excel', style: Theme.of(context).textTheme.bodyLarge),
              IconButton(
                icon: Icon(Icons.download),
                onPressed: () {
                },
              ),
               SizedBox(width: 20),
              Text('Agregar proveedor', style: Theme.of(context).textTheme.bodyLarge),

              IconButton(
                icon: Icon(Icons.add_box),
                onPressed: () {
                  
                },
              ),
              SizedBox(width: 20),
              Visibility(visible: false , child: Container( child: Row(children: [
                Text('Editar proveedor', style: Theme.of(context).textTheme.bodyLarge),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                
                },
              ),
              ],),
                 
              ))
            ],
          )
          ,
          // SizedBox(height: 30),
          // Row(children: [
          //   Text('Total de alumnos: ${snapshot.data!.length}', style: Theme.of(context).textTheme.bodyMedium),
          //    SizedBox(width: 30),
          //    Text('Alumno seleccionado: ${appState.selectedStudent != null ? (appState.selectedStudent!.name + ' '+ appState.selectedStudent!.lastName) : 'Ninguno'}', style: Theme.of(context).textTheme.bodyMedium),
          //    SizedBox(width: 30),
          //    IconButton(
          //       icon: Icon(Icons.refresh),
          //       onPressed: () {
          //         setState(() {
          //           appState.clearSelectedStudent();
                     
          //       });
          //        },
          //     ),
          // ],),
          SizedBox(height: 20),
        Expanded(
          child: PlutoGrid(
            mode: mode,
          columns: columns,
          rows: snapshot.data!.map((e) => PlutoRow( 
                  cells: {
                    // 'name': PlutoCell(value: e.name),
                    // 'email': PlutoCell(value: e.email),
                    // 'phone': PlutoCell(value: e.phone),
                    // 'serviceType': PlutoCell(value: e.serviceType),
                    // 'cost': PlutoCell(value: e.cost),
                    // 'costDescription': PlutoCell(value: e.costDescription),
                  }
                )).toList(),
          onChanged: (PlutoGridOnChangedEvent event) {
            print(event);
          },
          onSelected: (student) => {
            // log('selected student: ${student.row!.cells['student_name']!.value}'),
            // appState.setSelectedStudent(snapshot.data!.firstWhere((element) => element.name == student.row!.cells['student_name']!.value))

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
              : snapshot.hasError
                  ? Text('Error: ${snapshot.error}')
                  : CircularProgressIndicator(),

        )
    ),
    );
  }
}