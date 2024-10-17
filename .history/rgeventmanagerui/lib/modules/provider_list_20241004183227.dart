import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/Supplier.dart';
import 'package:rg_event_management_ui/modules/add_provider.dart';
import 'package:rg_event_management_ui/services/eventservice.dart';

class ProviderListPage extends StatefulWidget {
  @override
  _ProviderListPageState createState() => _ProviderListPageState();

}

class _ProviderListPageState extends State<ProviderListPage> {
  
  var selectedSupplier;
  List<PlutoRow> rows = [];
  List<PlutoRow> rowsEvents = [];
  late PlutoGridStateManager stateManagerProviders;
  PlutoGridMode mode = PlutoGridMode.selectWithOneTap;

  final controller = ScrollController();
  late Future<List<Supplier>> _func;
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
      title: 'Telefono',
      field: 'phone',
      type: PlutoColumnType.text(),
    ),
       PlutoColumn(
      title: 'Tipo de servicio',
      field: 'serviceType',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Cuenta bancaria',
      field: 'accountNumber',
      type: PlutoColumnType.text(),
    ),
    
  ];



  @override
  void initState() {
    var appState = context.read<MyAppState>();
    var token = appState.appToken;
    _func = EventService().getAllProviders(token);
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

      return SizedBox(
      // height: 800,
      // width: 1500,
      child: FutureBuilder<List<Supplier>>(
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
                  appState.clearSelectedProvider();
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddProviderPage()));
                },
              ),
              SizedBox(width: 20),
              Visibility(visible: appState.selectedProvider != null , 
              child: Container( child: Row(children: [
                Text('Editar evento', style: Theme.of(context).textTheme.bodyLarge),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  if (appState.selectedProvider != null){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddProviderPage()));
                  } else {
 
                      Flushbar(
                         flushbarPosition: FlushbarPosition.TOP,
                        title: 'Error',
                        message: 'Selecciona un proveedor para editar',
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
            Text('Total de proveedores: ${snapshot.data!.length}', style: Theme.of(context).textTheme.bodyMedium),
             SizedBox(width: 30),
             Text('Proveedor seleccionado: ${selectedSupplier != null ? (selectedSupplier!.name + ' ' + selectedSupplier!.lastName) : 'Ninguno'}', style: Theme.of(context).textTheme.bodyMedium),

          ],),
          SizedBox(height: 20),
        Expanded(
          child: PlutoGrid(
            mode: mode,
          columns: columns,
          rows: snapshot.data!.map((e) => PlutoRow( 
                  cells: {
                    'name': PlutoCell(value: e.name),
                    'lastName': PlutoCell(value: e.lastName),
                    'email': PlutoCell(value: e.email),
                    'phone': PlutoCell(value: e.phone),
                    'serviceType': PlutoCell(value: e.serviceType.name),
                    'cost': PlutoCell(value: e.cost),
                    // 'costDescription': PlutoCell(value: e.costDescription),
                    'accountNumber': PlutoCell(value: e.accountNumber),
                  }
                )).toList(),
          onChanged: (PlutoGridOnChangedEvent event) {
            print(event);
          },
          onSelected: (event) => {
            log('selected supplier: ${event.row!.cells['name']!.value}'),
            setState(() {
              selectedSupplier = snapshot.data!.firstWhere((element) => element.name == event.row!.cells['name']!.value);
              appState.setSelectedProvider(selectedSupplier);
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