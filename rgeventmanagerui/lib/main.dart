import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
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
import 'package:rg_event_management_ui/modules/add_event.dart';
import 'package:rg_event_management_ui/models/Event.dart';
import 'package:rg_event_management_ui/modules/additional_services.dart';
import 'package:rg_event_management_ui/modules/budgetpage.dart';
import 'package:rg_event_management_ui/modules/employees_list.dart';
import 'package:rg_event_management_ui/modules/event_operations/expenses_event.dart';
import 'package:rg_event_management_ui/modules/event_operations/nomina_event.dart';
import 'package:rg_event_management_ui/modules/eventspayment.dart';
import 'package:rg_event_management_ui/modules/operations_general/general_nominal.dart';
import 'package:rg_event_management_ui/modules/operations_general/general_payments.dart';
import 'package:rg_event_management_ui/modules/provider_list.dart';
import 'package:rg_event_management_ui/modules/search_page.dart';
import 'package:rg_event_management_ui/modules/userlistpage.dart';
import 'package:rg_event_management_ui/services/eventservice.dart';
import 'package:rg_event_management_ui/modules/graduationlist.dart';
import 'package:rg_event_management_ui/services/userservices.dart';
// import 'package:window_manager/window_manager.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();

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
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.greyColor),
        ),
        home: LayoutBuilder(
          builder: (context, constraints) {
            return Scaffold(
              body: Center(
                child: SizedBox(
                  // width: 980, // Set the desired width for the app
                  // height: 700,
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
  User? selectedUserToEdit;
  int selectedIndex = 0;
  // List<PlutoRow> rows = [];

  void setToken(String token) {
    appToken = token;
    // notifyListeners();
  }

  void setIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void setSelectedEvent(Event event) {
    selectedEvent = event;
    notifyListeners();
  }

  void setSelectedStudent(Student student) {
    selectedStudent = student;
    notifyListeners();
  }

  void clearSelectedEvent() {
    selectedEvent = null;
    // notifyListeners();
  }

  void clearSelectedStudent() {
    selectedStudent = null;
    // notifyListeners();
  }

  void setSelectedProvider(Supplier provider) {
    selectedProvider = provider;
    notifyListeners();
  }

  void setSelectedUser(User? user) {
    selectedUser = user;
    notifyListeners();
  }

  void clearSelectedProvider() {
    selectedProvider = null;
  }

  void clearSelectedUser() {
    selectedUser = null;
  }

  void setSelectedEmployee(Employee employee) {
    selectedEmployee = employee;
    notifyListeners();
  }

  void clearSelectedEmployee() {
    selectedEmployee = null;
    // notifyListeners();
  }

  void setSelectedUserToEdit(User user) {
    selectedUserToEdit = user;
    notifyListeners();
  }

  void clearSelectedUserToEdit() {
    selectedUserToEdit = null;
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

    if (appState.appToken.isNotEmpty) {
      UserService().isValidToken(appState.appToken).then((value) {
        if (!value) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => Login()),
              (Route<dynamic> route) => false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey);
    var appState = context.watch<MyAppState>();

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = EventsPage();
      case 1:
        page = SearchPage();
      case 2:
        page = ProviderListPage();  
      case 3:
        page = EmployeesView();
      case 4:
        page = GeneralNominalPage();
      case 5:
        page = GeneralPaymentsPage();
      case 6:
        page = BudgetPage();
      case 7:
        page = UserListPage();
      case 8:
        page = Login();

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
          
            return Row(
              children: [
                SafeArea(
                  child: Row(children: [
                    NavigationRail(
                       extended: constraints.maxWidth >= 100,
                      destinations: [
                        NavigationRailDestination(  
                          icon: Icon(Icons.event),
                          label: Text('Eventos'),
                        ),
                         NavigationRailDestination(  
                          icon: Icon(Icons.event),
                          label: Text('Busqueda'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.contacts),
                          label: Text('Proveedores'),
                        ),
                        NavigationRailDestination(
                          disabled: appState.selectedUser != null && appState.selectedUser!.role != 1,
                          icon: Icon(Icons.person),
                          label: Text('Empleados'),
                        ),
                        NavigationRailDestination(
                          disabled: appState.selectedUser != null && appState.selectedUser!.role != 1,
                          icon: Icon(Icons.payment_sharp),
                          label: Text('Nomina general'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.attach_money),
                          disabled:  true, //appState.selectedUser != null && appState.selectedUser!.role != 1,
                          label: Text('Pagos y gastos'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.money_rounded),
                          disabled: true,
                          label: Text('Cotización'),
                        ),
                        NavigationRailDestination(
                          disabled: appState.selectedUser != null && appState.selectedUser!.role != 1,
                          icon: Icon(Icons.security),
                          label: Text('Administrar Usuarios'),
                        ),
                        NavigationRailDestination(
                            icon: Icon(Icons.logout),
                            label: Text('Cerrar sesión'))
                      ],
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (value) {
                        if (value == 8) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Cerrar sesión'),
                                  content: Text(
                                      '¿Estás seguro de que deseas cerrar sesión?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        setState(() {
                                          appState.setIndex(0);
                                          appState.setToken("");
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                            MaterialPageRoute(
                                                builder: (context) => Login()),
                                            (Route<dynamic> route) => false,
                                          );
                                        });
                                      },
                                      child: Text('Sí'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('No'),
                                    ),
                                  ],
                                );
                              });
                        } else {
                          setState(() {
                            selectedIndex = value;
                          });
                        }
                      },
                    ),
                  ]),
                ),
                Expanded(child: mainArea),
              ],
            );
          
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
  static const _brandColor = Color.fromARGB(255, 113, 7, 132);

  List<PlutoColumn> columns = [
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
    PlutoColumn(
        title: 'Total',
        field: 'event_total',
        type: PlutoColumnType.currency(symbol: '\$'),
        width: 120),
    PlutoColumn(
      title: 'Estado',
      field: 'event_status',
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
      },
    ),
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
        body: FutureBuilder<List<Event>>(
      future: _func,
      builder: (context, snapshot) => snapshot.hasData
          ? Column(
              children: [
                // Header section
                _buildHeaderSection(context, appState, snapshot.data!),
                Divider(height: 1),
                // Grid
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: PlutoGrid(
                      mode: mode,
                      columns: columns,
                      rows: snapshot.data!
                          .map((e) => PlutoRow(cells: {
                                'event_type':
                                    PlutoCell(value: e.eventType.description),
                                'event_name': PlutoCell(value: e.name),
                                'event_date': PlutoCell(
                                    value: DateFormat('yyyy-MM-dd')
                                        .format(e.eventDate)),
                                'envent_guests':
                                    PlutoCell(value: e.minCapacity),
                                'event_location':
                                    PlutoCell(value: e.location.locationName),
                                'event_capacity':
                                    PlutoCell(value: e.location.capacity),
                                'event_total': PlutoCell(
                                    value:
                                        e.totalCost + e.totalAdditional > 0 &&
                                                e.eventType.id != 3
                                            ? (e.totalCost + e.totalAdditional)
                                                .toString()
                                            : '-'),
                                'event_status': PlutoCell(
                                    value: e.eventDate.isAfter(DateTime.now())
                                        ? 'En progreso'
                                        : 'Cerrado'),
                              }))
                          .toList(),
                      onChanged: (PlutoGridOnChangedEvent event) {
                        print(event);
                      },
                      onSelected: (event) => {
                        log('selected event: ${event.row!.cells['event_name']!.value}'),
                        appState.setSelectedEvent(snapshot.data!.firstWhere(
                            (element) =>
                                element.name ==
                                event.row!.cells['event_name']!.value)),
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
                    ),
                  ),
                ),
                // Footer
                _buildFooter(appState, snapshot.data!),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    ));
  }

  Widget _buildHeaderSection(
      BuildContext context, MyAppState appState, List<Event> events) {
    return Container(
      color: Colors.grey.shade50,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Eventos',
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.bold, color: _brandColor),
          ),
          SizedBox(height: 16),
          // Primary actions row
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.clearSelectedEvent();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AddEventPopup()));
                },
                icon: Icon(Icons.add, size: 18),
                label: Text('Agregar evento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  var path = Directory.current.path;
                  try {
                    final file = DirectoryPicker()..title = 'Select a directory';
                    final result = file.getDirectory();
                    if (result != null) {
                      path = result.path;
                    }
                  } catch (e) {
                    log("error selecting directory:  ${e.toString()}");
                  }
                  try {
                    EventService()
                        .DownloadEventList(appState.appToken, [], path)
                        .then((value) {
                      Flushbar(
                        flushbarPosition: FlushbarPosition.TOP,
                        title: 'Éxito',
                        message: 'Archivo descargado en $path',
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.green,
                      ).show(context);
                    }, onError: (e) {
                      Flushbar(
                        flushbarPosition: FlushbarPosition.TOP,
                        title: 'Error',
                        message: 'Error al descargar archivo',
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.red,
                      ).show(context);
                    });
                  } catch (e) {
                    Flushbar(
                      flushbarPosition: FlushbarPosition.TOP,
                      title: 'Error',
                      message: 'Error al descargar archivo',
                      duration: Duration(seconds: 3),
                      backgroundColor: Colors.red,
                    ).show(context);
                  }
                },
                icon: Icon(Icons.picture_as_pdf, size: 18),
                label: Text('Exportar a PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              if (appState.selectedEvent != null) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AddEventPopup()));
                  },
                  icon: Icon(Icons.edit, size: 18),
                  label: Text('Editar evento'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                if (appState.selectedEvent!.eventType.id != 3 &&
                    appState.selectedEvent!.eventDate.isAfter(DateTime.now()))
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AdditionalServices()));
                    },
                    icon: Icon(Icons.room_service_sharp, size: 18),
                    label: Text('Servicios adicionales'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (appState.selectedEvent!.eventType.id == 3) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => GraduationListPage()));
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => EventPaymentPage()));
                    }
                  },
                  icon: Icon(
                      appState.selectedEvent!.eventType.id == 3
                          ? Icons.school_outlined
                          : Icons.payment_rounded,
                      size: 18),
                  label: Text(appState.selectedEvent!.eventType.id == 3
                      ? 'Administrar graduados'
                      : 'Cobro clientes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AddEmployeePaymentPage()));
                  },
                  icon: Icon(Icons.monetization_on, size: 18),
                  label: Text('Nómina'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ExpensesEventPage()));
                  },
                  icon: Icon(Icons.payment_rounded, size: 18),
                  label: Text('Pagos del evento'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Chip(
                avatar: Icon(Icons.event, size: 18),
                label: Text('Total eventos: ${events.length}'),
              ),
              SizedBox(width: 12),
              Chip(
                avatar: Icon(Icons.check_circle_outline, size: 18),
                label: Text(appState.selectedEvent != null
                    ? 'Seleccionado: ${appState.selectedEvent!.name}'
                    : 'Ninguno seleccionado'),
                backgroundColor: appState.selectedEvent != null
                    ? _brandColor.withOpacity(0.1)
                    : Colors.grey.shade200,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(MyAppState appState, List<Event> events) {
    final activeCount =
        events.where((e) => e.eventDate.isAfter(DateTime.now())).length;
    final closedCount = events.length - activeCount;

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
            'En progreso: $activeCount  |  Cerrados: $closedCount  |  Total: ${events.length}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          if (appState.selectedEvent != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _brandColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Evento: ${appState.selectedEvent!.name}',
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

class ContainsClass implements PlutoFilterType {
  @override
  String get title => 'Buscar';

  @override
  get compare => ({
        required String? base,
        required String? search,
        required PlutoColumn? column,
      }) {
        var keys =
            search!.split(' ').where((element) => element.isNotEmpty).toList();

        return keys.toList().every((key) {
          return base!.toLowerCase().startsWith(key.toLowerCase()) ||
              base.toLowerCase().contains(key.toLowerCase());
        });
      };

  const ContainsClass();
}
