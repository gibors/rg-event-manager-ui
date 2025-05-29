
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/StudentSearchDto.dart';
import 'package:rg_event_management_ui/modules/add_event.dart';
import 'package:rg_event_management_ui/modules/graduationlist.dart';
import 'package:rg_event_management_ui/modules/graduationpayment.dart';
import 'package:rg_event_management_ui/services/eventservice.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var appState;
  var token = '';
  String searchQuery = '';
  List<StudentSearchDto> students = []; // Replace with actual student data
  StudentSearchDto? selectedStudent;
  var indexSelected = -1;
  @override
  void initState() {
    appState = context.read<MyAppState>();
    token = appState.appToken;
    // Initialize the students list with actual data
    EventService().getAllStudentsGraduation(token).then((data) {
      setState(() {
        students = data;
      });
    });

    super.initState();
  }

  void goToGraduationList() {
    // Handle navigation to graduation list
     EventService().getEventById(selectedStudent!.eventId, token).then((event) {
      setState(() {
        appState.setSelectedEvent(event);
      });
      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GraduationListPage(),
      ),
    );
    });
  }

  void goToEvent() {
    // Handle navigation to event
 EventService().getEventById(selectedStudent!.eventId, token).then((event) {
      setState(() {
        appState.setSelectedEvent(event);
      });
      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventPopup(),
      ),
    );
    });
  }

  void goToPayments() {
    // Handle navigation to payments
  EventService().getEventById(selectedStudent!.eventId, token).then((event) {
      setState(() {
        appState.setSelectedEvent(event);
        appState.setSelectedStudent(selectedStudent!.student);
      });
      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GraduationPaymentPage(),
      ),
    );
    });
    
  }

  // void getEventById(int eventId) {
  //   // Handle getting event by ID
  
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Busqueda rapida'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Visibility(
              visible: selectedStudent != null,
              child: Row(
                children: [
                  Text(
                    'Ir a graduación',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () {
                      // Handle navigation to graduation list
                     goToGraduationList();
                    },
                  ),
                  SizedBox(width: 25),
                  Text(
                    'Ir a evento',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () {
                      // Handle navigation to event
                      goToEvent();
                    },
                  ),
                  SizedBox(width: 25),
                  Text(
                    'Ir a pagos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () {
                      // Handle navigation to payments
                      goToPayments();
                    },
                  ),
                ],
              )),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  'Alumno seleccionado: ${selectedStudent != null
                          ? '${selectedStudent!.student.name} ${selectedStudent!.student.lastName}'
                          : 'Ninguno'}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  )),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Busqueda',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: students.length, // Replace with actual student data
              itemBuilder: (context, index) {
                final student = students[index];
                if (student.student.name
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    student.student.lastName
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    student.eventName
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase())) {
                  return ListTile(
                    title: Text('${student.student.name} ${student.student.lastName}'),
                    subtitle: Text(
                        'Evento: ${student.eventName} -- Escuela: ${student.school}'),
                    tileColor: indexSelected == index
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.transparent,
                    onTap: () {
                      // Handle tap on student
                      setState(() {
                        selectedStudent = student;
                        indexSelected = index;
                      });
                      print('Tapped on ${student.student.lastName}');
                    },
                  );
                } else {
                  return Container(); // Return an empty container if the search query doesn't match
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
