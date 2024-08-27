// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/login.dart';
import 'package:rg_event_management_ui/add_event.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 14, 165, 210)),
        ),
        home: LayoutBuilder(
          builder: (context, constraints) {
            return Scaffold(
              body: Center(
                child: Container(
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

  GlobalKey? historyListKey;

  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current;
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
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

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = ProveedoresPage();
        break;
      case 2: 
        page = EmployeesView();
        break;
        case 3: 
        page = EmployeesView();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    // The container for the current page, with its background color
    // and subtle switching animation.
    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
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

class GeneratorPage extends StatelessWidget {
  List<PlutoColumn> columns = [

  /// Text Column definition
  PlutoColumn(
    title: 'folio evento',
    field: 'event_id',
    type: PlutoColumnType.text(),
  ),

  /// Number Column definition
  PlutoColumn(
    title: 'tipo de evento',
    field: 'event_type',
    type: PlutoColumnType.text(),
  ),

  /// Select Column definition
  PlutoColumn(
    title: 'nombre del evento',
    field: 'event_name',
    type: PlutoColumnType.text(),
  ),

  /// Datetime Column definition
  PlutoColumn(
    title: 'fecha del evento',
    field: 'event_date',
    type: PlutoColumnType.date(),
  ),

  /// Time Column definition
  PlutoColumn(
    title: 'No paquete',
    field: 'event_package',
    type: PlutoColumnType.number(),
  ),
   /// Time Column definition
  PlutoColumn(
    title: 'Ubicación',
    field: 'event_location',
    type: PlutoColumnType.text(),
  ),
    PlutoColumn(
    title: 'capacidad',
    field: 'event_capacity',
    type: PlutoColumnType.number(),
  ),
];

List<PlutoRow> rows = [
  PlutoRow(
    cells: {
      'event_id': PlutoCell(value: '1234'),
      'event_type': PlutoCell(value: 'Boda'),
      'event_name': PlutoCell(value: 'boda juanito'),
      'event_date': PlutoCell(value: '2020-08-06'),
      'event_package': PlutoCell(value: 3),
      'event_location': PlutoCell(value: 'Salon 1'),
      'event_capacity': PlutoCell(value: 100),
    },
  ),
  PlutoRow(
    cells: {
      'event_id': PlutoCell(value: '5444'),
      'event_type': PlutoCell(value: 'Graduación'),
      'event_name': PlutoCell(value: 'Generación 2020-IMA'),
      'event_date': PlutoCell(value: '2020-08-06'),
      'event_package': PlutoCell(value: 3),
      'event_location': PlutoCell(value: 'Salon san juan'),
      'event_capacity': PlutoCell(value: 120),
    },
  ),
  PlutoRow(
     cells: {
      'event_id': PlutoCell(value: '5534'),
      'event_type': PlutoCell(value: 'Graduación'),
      'event_name': PlutoCell(value: 'Generación 2024-Grupo-Isima'),
      'event_date': PlutoCell(value: '2020-08-06'),
      'event_package': PlutoCell(value: 3),
      'event_location': PlutoCell(value: 'Salon moon'),
      'event_capacity': PlutoCell(value: 200),
    },
    
  ),
   PlutoRow(
     cells: {
      'event_id': PlutoCell(value: '8756'),
      'event_type': PlutoCell(value: 'Boda'),
      'event_name': PlutoCell(value: 'Boda Maria-Jose'),
      'event_date': PlutoCell(value: '2023-08-06'),
      'event_package': PlutoCell(value: 2),
      'event_location': PlutoCell(value: 'Salon sun'),
      'event_capacity': PlutoCell(value: 180),
    },
    
  ),
     PlutoRow(
     cells: {
      'event_id': PlutoCell(value: '3487'),
      'event_type': PlutoCell(value: 'Boda'),
      'event_name': PlutoCell(value: 'Boda Ana-Pedro'),
      'event_date': PlutoCell(value: '2024-03-06'),
      'event_package': PlutoCell(value: 2),
      'event_location': PlutoCell(value: 'Palacio de los eventos'),
      'event_capacity': PlutoCell(value: 100),
    },
    
  ),
];

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

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
                  appState.toggleFavorite();
                },
              ),
              Text('Agregar evento', style: Theme.of(context).textTheme.bodyLarge),

              IconButton(
                icon: Icon(Icons.add_box),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddEventPopup()));
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
                  appState.toggleFavorite();
                },
              ),
              Text('Agregar proveedor', style: Theme.of(context).textTheme.bodyLarge),

              IconButton(
                icon: Icon(Icons.add_box),
                onPressed: () {
                  appState.toggleFavorite();
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

