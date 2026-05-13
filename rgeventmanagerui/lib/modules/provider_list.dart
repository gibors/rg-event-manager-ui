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
  static const _brandColor = Color.fromARGB(255, 113, 7, 132);

  var selectedSupplier;
  List<PlutoRow> rows = [];
  List<PlutoRow> rowsEvents = [];
  late PlutoGridStateManager stateManagerProviders;
  PlutoGridMode mode = PlutoGridMode.selectWithOneTap;

  final controller = ScrollController();
  late Future<List<Supplier>> _func;
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
      body: FutureBuilder<List<Supplier>>(
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
                                  'lastName': PlutoCell(value: e.lastName),
                                  'email': PlutoCell(value: e.email),
                                  'phone': PlutoCell(value: e.phone),
                                  'serviceType':
                                      PlutoCell(value: e.serviceType.name),
                                  'accountNumber':
                                      PlutoCell(value: e.accountNumber),
                                }))
                            .toList(),
                        onChanged: (PlutoGridOnChangedEvent event) {
                          print(event);
                        },
                        onSelected: (event) => {
                          log('selected supplier: ${event.row!.cells['name']!.value}'),
                          setState(() {
                            selectedSupplier = snapshot.data!.firstWhere(
                                (element) =>
                                    element.name ==
                                    event.row!.cells['name']!.value);
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
      BuildContext context, MyAppState appState, List<Supplier> suppliers) {
    return Container(
      color: Colors.grey.shade50,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Proveedores',
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
                  appState.clearSelectedProvider();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AddProviderPage()));
                },
                icon: Icon(Icons.add, size: 18),
                label: Text('Agregar proveedor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              if (selectedSupplier != null)
                ElevatedButton.icon(
                  onPressed: () {
                    if (appState.selectedProvider != null) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AddProviderPage()));
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
                  icon: Icon(Icons.edit, size: 18),
                  label: Text('Editar proveedor'),
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
                avatar: Icon(Icons.contacts, size: 18),
                label: Text('Total proveedores: ${suppliers.length}'),
              ),
              SizedBox(width: 12),
              Chip(
                avatar: Icon(Icons.person_pin, size: 18),
                label: Text(selectedSupplier != null
                    ? 'Seleccionado: ${selectedSupplier!.name} ${selectedSupplier!.lastName}'
                    : 'Ninguno seleccionado'),
                backgroundColor: selectedSupplier != null
                    ? _brandColor.withOpacity(0.1)
                    : Colors.grey.shade200,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(MyAppState appState, List<Supplier> suppliers) {
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
            'Total de proveedores: ${suppliers.length}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          if (selectedSupplier != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _brandColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Proveedor: ${selectedSupplier!.name} ${selectedSupplier!.lastName}',
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