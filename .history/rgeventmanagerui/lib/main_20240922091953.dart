
// import 'dart:ui';

import 'dart:async';
import 'dart:developer';
import 'package:another_flushbar/flushbar.dart';
import 'package:intl/intl.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/login.dart';
import 'package:rg_event_management_ui/modules/add_event.dart';
import 'package:rg_event_management_ui/models/Event.dart';
import 'package:rg_event_management_ui/services/eventservice.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'rg eventos',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink, secondary: Colors.blue), 

        ),
        home: LayoutBuilder(
          builder: (context, constraints) {
            return Scaffold(
              body: Center(
                child: SizedBox(
                  width: 980, // Set the desired width for the app
                  height: 700,
                  child: Login(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var history = <WordPair>[];
  var appToken = "";
  Event? selectedEvent;
  // List<PlutoRow> rows = [];

  GlobalKey? historyListKey;

  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];


  void setToken(String token){
    appToken = token;
    // notifyListeners();
  }


  void setSelectedEvent(Event event){
    selectedEvent = event;
    notifyListeners();
  }

  void clearSelectedEvent(){
    selectedEvent = null;
    // notifyListeners();
  }

}

class EventsHomePage extends StatefulWidget {

  @override
  State<EventsHomePage> createState() => _EventsHomePageState();
}

class _EventsHomePageState extends State<EventsHomePage> {
  var selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var appState = context.watch<MyAppState>();

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = EventsPage();
      case 1:
        page = ProveedoresPage();
      case 2: 
        page = EmployeesView();
        case 3: 
        page = EmployeesView();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    // The container for the current page, with its background color
    // and subtle switching animation.
    var mainArea = ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      body: LayoutBuilder(
        
        builder: (context, constraints) {
          if (constraints.maxWidth < 550) {
            // Use a more mobile-friendly layout with BottomNavigationBar
            // on narrow screens.
            return Column(
              children: [
                Expanded(child: mainArea),
                SizedBox(height: 200),
                SafeArea(
                  child: BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Eventos',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite),
                        label: 'Proveedores',
                      ),
                        BottomNavigationBarItem(
                        icon: Icon(Icons.person),
                        label: 'Empleados',
                      ),
                        BottomNavigationBarItem(
                        icon: Icon(Icons.account_balance),
                        label: 'Contabilidad',
                      ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                )
              ],
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: [
                
                      NavigationRailDestination(
                        icon: Icon(Icons.event),
                        label: Text('Eventos'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.contacts),
                        label: Text('Proveedores'),
                      ),
                       NavigationRailDestination(
                        icon: Icon(Icons.person),
                        label: Text('Empleados'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.account_balance),
                        label: Text('Contabilidad'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}

class EventsPage extends StatefulWidget {

  @override
  State<EventsPage> createState() => _EventsPage();
}


class _EventsPage extends State<EventsPage> {

  List<PlutoColumn>  columns = [
         
          PlutoColumn(
            title: 'Tipo de evento',
            field: 'event_type',
            type: PlutoColumnType.text(),
          ),
          PlutoColumn(
            title: 'Nombre del evento',
            field: 'event_name',
            type: PlutoColumnType.text(),
          ),
          PlutoColumn(
            title: 'Fecha del evento',
            field: 'event_date',
            type: PlutoColumnType.text(),
          ),
          PlutoColumn(
            title: 'Invitados',
            field: 'envent_guests',
            type: PlutoColumnType.text(),
            width: 120,
          ),
          PlutoColumn(
            title: 'Salón',
            field: 'event_location',
            type: PlutoColumnType.text(),
          ),
          PlutoColumn(
            title: 'Capacidad',
            field: 'event_capacity',
            type: PlutoColumnType.number(),
            width: 120,
          ),
          PlutoColumn(title: 'Estado', field: 'event_status', 
          type: PlutoColumnType.select(<String>['Activo', 'Cerrado']),
          renderer: (rendererContext) {
            Color textColor = Colors.black;

            if (rendererContext.cell.value == 'Cerrado') {
              textColor = Colors.red;
            } else if (rendererContext.cell.value == 'Activo') {
              textColor = Colors.green;
            }

            return Text(
              rendererContext.cell.value.toString(),
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            );
        },),
        ];
        
  List<PlutoRow> rows = [];
  List<PlutoRow> rowsEvents = [];
  late PlutoGridStateManager stateManagerProviders;
  PlutoGridMode mode = PlutoGridMode.selectWithOneTap;

  final controller = ScrollController();
  late Future<List<Event>> _func;
  double offset = 0;
        
  @override
  void initState() {
    var appState = context.read<MyAppState>();
    var token = appState.appToken;
    appState.clearSelectedEvent();
    _func = EventService().getEvents(token);
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
      child: FutureBuilder<List<Event>>(
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
                  // appState.getNext();
                },
              ),
              SizedBox(width: 20),
              Text('Descargar excel', style: Theme.of(context).textTheme.bodyLarge),
              IconButton(
                icon: Icon(Icons.download),
                onPressed: () {
                  // appState.toggleFavorite();
                },
              ),
               SizedBox(width: 20),
              Text('Agregar evento', style: Theme.of(context).textTheme.bodyLarge),

              IconButton(
                icon: Icon(Icons.add_box),
                onPressed: () {
                  appState.clearSelectedEvent();
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddEventPopup()));
                },
              ),
              SizedBox(width: 20),
              Visibility(visible: (appState.selectedEvent!= null) , child: Container( child: Row(children: [
                Text('Editar evento', style: Theme.of(context).textTheme.bodyLarge),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  if (appState.selectedEvent != null){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddEventPopup()));
                  } else {
 
                      Flushbar(
                         flushbarPosition: FlushbarPosition.TOP,
                        title: 'Error',
                        message: 'Selecciona un evento para editar',
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.red,
                      ).show(context);
                        
                  }
                },
              ),
              SizedBox(width: 20),
              Text(appState.selectedEvent != null && appState.selectedEvent!.id == 3 ? 'Administrar Graduados' :'Administrar Pago'  , style: Theme.of(context).textTheme.bodyLarge),
                IconButton(onPressed: () {
                                      Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => GraduationPage(),
                      ),
                    );
                }
                , icon: Icon( Icons.payments_outlined),)
              ],),
                 
              ))
            ],
          )
          ,
          SizedBox(height: 30)
        ,
        Expanded(
          child: PlutoGrid(
            mode: mode,
          columns: columns,
          rows: snapshot.data!.map((e) => PlutoRow( 
                  cells: {
                    'event_type': PlutoCell(value: e.eventType.description),
                    'event_name': PlutoCell(value: e.name),
                    'event_date': PlutoCell(value: DateFormat('yyyy-MM-dd').format(e.eventDate)),
                    'envent_guests': PlutoCell(value: e.minCapacity),
                    'event_location': PlutoCell(value: e.location.locationName),
                    'event_capacity': PlutoCell(value: e.location.capacity),
                    'event_status': PlutoCell(value: e.status),
                  }
                )).toList(),
          onChanged: (PlutoGridOnChangedEvent event) {
            print(event);
          },
          onSelected: (event) => {
            log('selected event: ${event.row!.cells['event_name']!.value}'),
            appState.setSelectedEvent(snapshot.data!.firstWhere((element) => element.name == event.row!.cells['event_name']!.value)),
            // Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddEventPopup()))

          },
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManagerProviders = event.stateManager;
            event.stateManager.setShowColumnFilter(true);
            event.stateManager.setSelecting(true);
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
              // return resolver<PlutoFilterTypeContains>() as PlutoFilterType;}
              ),
          ),
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


class ProveedoresPage extends StatelessWidget {

  List<PlutoColumn> columns = [

  /// Text Column definition

  /// Number Column definition
  PlutoColumn(
    title: 'nombre proovedor',
    field: 'provider_name',
    type: PlutoColumnType.text(),
  ),

  /// Select Column definition
  PlutoColumn(
    title: 'ubicación',
    field: 'provider_location',
    type: PlutoColumnType.text(),
  ),

  /// Datetime Column definition
  PlutoColumn(
    title: 'material proovedor',
    field: 'provider_material',
    type: PlutoColumnType.text(),
  ),

  /// Time Column definition
  PlutoColumn(
    title: 'Telefono',
    field: 'provider_phone',
    type: PlutoColumnType.number(),
  ),
   /// Time Column definition
    PlutoColumn(
    title: 'correo',
    field: 'provider_email',
    type: PlutoColumnType.text(),
  ),
];

List<PlutoRow> rows = [
  PlutoRow(
    cells: {
      'provider_name': PlutoCell(value: 'Juanito'),
      'provider_location': PlutoCell(value: 'Veracruz'),
      'provider_material': PlutoCell(value: 'Flores'),
      'provider_phone': PlutoCell(value: 33333333),
      'provider_email': PlutoCell(value: 'girea.ico@gmail.com'),
    }
  ),
  PlutoRow(
    cells: {
      'provider_name': PlutoCell(value: 'Pedrito'),
      'provider_location': PlutoCell(value: 'Veracrúz'),
      'provider_material': PlutoCell(value: 'Mesas'),
      'provider_phone': PlutoCell(value: 2323232323),
      'provider_email': PlutoCell(value: 'girea.ico@gmail.com'),
    }
  ),
  PlutoRow(
    cells: {
      'provider_name': PlutoCell(value: 'Maria'),
      'provider_location': PlutoCell(value: 'Xalapa'),
      'provider_material': PlutoCell(value: 'Sillas'),
      'provider_phone': PlutoCell(value: 3232323232323),
      'provider_email': PlutoCell(value: 'girea.ico@gmail.com'),
    }
  ),
  ];
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    // if (appState.favorites.isEmpty) {
    //   return Center(
    //     child: Text('No favorites yet.'),
    //   );
    // }

     return  Center( 
      child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [ 
          Row(
            children: [
              Text('Exportar a PDF', style: Theme.of(context).textTheme.bodyLarge),
              IconButton(
                icon: Icon(Icons.picture_as_pdf),
                onPressed: () {
                  appState.getNext();
                },
              ),
              Text('Descargar excel', style: Theme.of(context).textTheme.bodyLarge),
              IconButton(
                icon: Icon(Icons.download),
                onPressed: () {
                  // appState.toggleFavorite();
                },
              ),
              Text('Agregar proveedor', style: Theme.of(context).textTheme.bodyLarge),

              IconButton(
                icon: Icon(Icons.add_box),
                onPressed: () {
                  // appState.toggleFavorite();
                },
              ),
            ],
          )
        ,
        Expanded(
          child: PlutoGrid(
          columns: columns,
          rows: rows,
          onChanged: (PlutoGridOnChangedEvent event) {
            print(event);
          },
          onLoaded: (PlutoGridOnLoadedEvent event) {
            print(event);
          },
          ),
        ),
        ],
      ),
      ),
    );
  }
}

class EmployeesView extends StatefulWidget {
  const EmployeesView({Key? key}) : super(key: key);

  @override
  State<EmployeesView> createState() => _EmployeesViewState();
}

class _EmployeesViewState extends State<EmployeesView> {

  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pagina en progreso...'),
      )
    );
  }
  }

class ContainsClass implements PlutoFilterType {
  @override
  String get title => 'Buscar';

  @override
  get compare => ({
        required String? base,
        required String? search,
        required PlutoColumn? column,
      }) {
        var keys = search!.split(' ').where((element) => element.isNotEmpty).toList();

        return keys.toList().every((key) {
          return base!.toLowerCase().startsWith(key.toLowerCase()) || 
          base.toLowerCase().contains(key.toLowerCase());
        });
      };

  const ContainsClass();
}