
import 'dart:async';
import 'dart:developer';
import 'package:another_flushbar/flushbar.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/app_colors.dart';
import 'package:rg_event_management_ui/login.dart';
import 'package:rg_event_management_ui/models/Employee.dart';
import 'package:rg_event_management_ui/models/Student.dart';
import 'package:rg_event_management_ui/models/Supplier.dart';
import 'package:rg_event_management_ui/models/User.dart';
import 'package:rg_event_management_ui/modules/accountability.dart';
import 'package:rg_event_management_ui/modules/add_event.dart';
import 'package:rg_event_management_ui/models/Event.dart';
import 'package:rg_event_management_ui/modules/budgetpage.dart';
import 'package:rg_event_management_ui/modules/employees_list.dart';
import 'package:rg_event_management_ui/modules/eventpayment.dart';
import 'package:rg_event_management_ui/modules/provider_list.dart';
import 'package:rg_event_management_ui/modules/userlistpage.dart';
import 'package:rg_event_management_ui/services/eventservice.dart';
import 'package:rg_event_management_ui/modules/graduationlist.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.purpleColor),  

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
  Student? selectedStudent;
  Supplier? selectedProvider;
  Employee? selectedEmployee;
  User? selectedUser;
  int selectedIndex = 0;
  // List<PlutoRow> rows = [];

  void setToken(String token){
    appToken = token;
    // notifyListeners();
  }

  void setIndex(int index){
    selectedIndex = index;
    notifyListeners();
  }

  void setSelectedEvent(Event event){
    selectedEvent = event;
    notifyListeners();
  }

  void setSelectedStudent(Student student){
    selectedStudent = student;
    notifyListeners();
  }

  void clearSelectedEvent(){
    selectedEvent = null;
    // notifyListeners();
  }

  void clearSelectedStudent(){
    selectedStudent = null;
    // notifyListeners();
  }

  void setSelectedProvider(Supplier provider){
    selectedProvider = provider;
    notifyListeners();
  }

  void setSelectedUser(User user){
    selectedUser = user;
    notifyListeners();
  }

  void clearSelectedProvider(){
    selectedProvider = null;
  }

  void clearSelectedUser(){
    selectedUser = null;
  }

  void setSelectedEmployee(Employee employee){
    selectedEmployee = employee;
     notifyListeners();
  }

  void clearSelectedEmployee(){
    selectedEmployee = null;
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
  void initState() {
    var appState = context.read<MyAppState>();
    
    selectedIndex = appState.selectedIndex ?? 0;
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    var colorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.pink);
    var appState = context.watch<MyAppState>();

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = EventsPage();
      case 1:
        page = ProviderListPage();
      case 2: 
        page = EmployeesView();
        case 3: 
        page = AccountabilityPage();
        case 4:
        page = BudgetPage();
        case 5:
        page = UserListPage();
        
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    // The container for the current page, with its background color
    // and subtle switching animation.
    var mainArea = ColoredBox(
      color: const Color.fromARGB(255, 239, 200, 246),
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
                ß
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
                        BottomNavigationBarItem(
                        icon: Icon(Icons.money_rounded),
                        label: 'Cotización',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.security),
                        label: 'Administrar Usuarios',
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
                Expanded(
                  child: Container(
                    color: colorScheme.background,
                    child: Center(
                      child: OutlinedButton(
                        
                      ),
                    ),
                  ),
                )
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
                      NavigationRailDestination(
                        icon: Icon(Icons.money_rounded),
                        label: Text('Cotización'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.security),
                        label: Text('Administrar Usuarios'),
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
            title: 'Invitados/Min graduados',
            field: 'envent_guests',
            type: PlutoColumnType.text(),
            width: 200,
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
          PlutoColumn(title: 'Total', field: 'event_total', type: PlutoColumnType.text(),width: 120),
          PlutoColumn(title: 'Estado', field: 'event_status', 
          type: PlutoColumnType.select(<String>['Activo', 'Cerrado']),
          renderer: (rendererContext) {
            Color textColor = Colors.black;

            if (rendererContext.cell.value == 'Cerrado') {
              textColor = Colors.red;
            } else if (rendererContext.cell.value == 'En progreso') {
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
              Text(appState.selectedEvent != null && appState.selectedEvent!.eventType.id == 3 ? 'Administrar Graduados' :'Administrar Pago'  , style: Theme.of(context).textTheme.bodyLarge),
                IconButton(onPressed: () {
                  
                  if(appState.selectedEvent != null && appState.selectedEvent!.eventType.id == 3){
                    Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GraduationListPage(),
                          ),
                        );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EventPaymentPage(),
                      ),
                    );
                  }
                }
                , icon: Icon( appState.selectedEvent != null && appState.selectedEvent!.eventType.id == 3 ? Icons.school_outlined :Icons.payment_rounded),)
              ],),
                 
              ))
            ],
          )
          ,
          SizedBox(height: 30),
          Row(children: [
            Text('Total de eventos: ${snapshot.data!.length}', style: Theme.of(context).textTheme.bodyMedium),
             SizedBox(width: 30),
             Text('Evento seleccionado: ${appState.selectedEvent != null ? appState.selectedEvent!.name : 'Ninguno'}', style: Theme.of(context).textTheme.bodyMedium),

          ],),
          SizedBox(height: 20),
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
                    'event_total': PlutoCell(value: e.totalCost > 0 && e.eventType.id != 3 ? e.totalCost.toString() : ''),
                    'event_status': PlutoCell(value: e.eventDate.isAfter(DateTime.now()) ? 'En progreso' : 'Cerrado'),
                  }
                )).toList(),
          onChanged: (PlutoGridOnChangedEvent event) {
            print(event);
          },
          onSelected: (event) => {
            log('selected event: ${event.row!.cells['event_name']!.value}'),
            appState.setSelectedEvent(snapshot.data!.firstWhere((element) => element.name == event.row!.cells['event_name']!.value)),

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