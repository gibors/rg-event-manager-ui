
import 'dart:developer';

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
  static const _brandColor = Color.fromARGB(255, 113, 7, 132);

  var appState;
  var token = '';
  String searchQuery = '';
  List<StudentSearchDto> students = [];
  StudentSearchDto? selectedStudent;
  var indexSelected = -1;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    appState = context.read<MyAppState>();
    token = appState.appToken;
    EventService().getAllStudentsGraduation(token).then((data) {
      setState(() {
        students = data;
        isLoading = false;
      });
      log('Search page loaded ${data.length} students');
    }).catchError((e) {
      log('Error loading students in search page: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Error al cargar alumnos: $e';
      });
    });
    super.initState();
  }

  void goToGraduationList() {
    EventService().getEventById(selectedStudent!.eventId, token).then((event) {
      setState(() {
        appState.setSelectedEvent(event);
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GraduationListPage()),
      );
    });
  }

  void goToEvent() {
    EventService().getEventById(selectedStudent!.eventId, token).then((event) {
      setState(() {
        appState.setSelectedEvent(event);
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddEventPopup()),
      );
    });
  }

  void goToPayments() {
    EventService().getEventById(selectedStudent!.eventId, token).then((event) {
      setState(() {
        appState.setSelectedEvent(event);
        appState.setSelectedStudent(selectedStudent!.student);
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GraduationPaymentPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    appState = context.watch<MyAppState>();

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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 12),
                      Text(errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: 16)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildHeaderSection(),
                    Divider(height: 1),
                    Expanded(child: _buildStudentList()),
                    _buildFooter(),
                  ],
                ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      color: Colors.grey.shade50,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Búsqueda Rápida',
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.bold, color: _brandColor),
          ),
          SizedBox(height: 16),
          // Search field
          TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Buscar por nombre, apellido o evento...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() => searchQuery = '');
                      },
                    )
                  : null,
            ),
          ),
          SizedBox(height: 16),
          // Action buttons row
          Row(
            children: [
              if (selectedStudent != null) ...[
                ElevatedButton.icon(
                  onPressed: goToGraduationList,
                  icon: Icon(Icons.school_outlined, size: 18),
                  label: Text('Ir a graduación'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: goToEvent,
                  icon: Icon(Icons.event, size: 18),
                  label: Text('Ir a evento'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: goToPayments,
                  icon: Icon(Icons.payment_rounded, size: 18),
                  label: Text('Ir a pagos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
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
                avatar: Icon(Icons.people, size: 18),
                label: Text('Total alumnos: ${students.length}'),
              ),
              SizedBox(width: 12),
              Chip(
                avatar: Icon(Icons.person_pin, size: 18),
                label: Text(selectedStudent != null
                    ? 'Seleccionado: ${selectedStudent!.student.name} ${selectedStudent!.student.lastName}'
                    : 'Ninguno seleccionado'),
                backgroundColor: selectedStudent != null
                    ? Colors.blue.shade50
                    : Colors.grey.shade200,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    final filtered = students.where((s) {
      if (searchQuery.isEmpty) return true;
      final q = searchQuery.toLowerCase();
      return s.student.name.toLowerCase().contains(q) ||
          s.student.lastName.toLowerCase().contains(q) ||
          s.eventName.toLowerCase().contains(q);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('No se encontraron resultados',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final student = filtered[index];
        final isSelected = selectedStudent != null &&
            selectedStudent!.student.id == student.student.id;
        return Container(
          decoration: BoxDecoration(
            color: isSelected
                ? _brandColor.withOpacity(0.08)
                : (index % 2 == 0 ? Colors.white : Colors.grey.shade50),
            border: Border(
              left: isSelected
                  ? BorderSide(color: _brandColor, width: 4)
                  : BorderSide.none,
              bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _brandColor.withOpacity(0.1),
              child: Text(
                student.student.name.isNotEmpty
                    ? student.student.name[0].toUpperCase()
                    : '?',
                style: TextStyle(
                    color: _brandColor, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              '${student.student.name} ${student.student.lastName}',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Evento: ${student.eventName.isNotEmpty ? student.eventName : "N/A"} -- Escuela: ${student.school.isNotEmpty ? student.school : "N/A"}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            trailing: isSelected
                ? Icon(Icons.check_circle, color: _brandColor)
                : null,
            onTap: () {
              setState(() {
                selectedStudent = student;
                indexSelected = index;
              });
              log('Tapped on ${student.student.lastName}');
            },
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    final filteredCount = students.where((s) {
      if (searchQuery.isEmpty) return true;
      final q = searchQuery.toLowerCase();
      return s.student.name.toLowerCase().contains(q) ||
          s.student.lastName.toLowerCase().contains(q) ||
          s.eventName.toLowerCase().contains(q);
    }).length;

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
            searchQuery.isNotEmpty
                ? 'Mostrando $filteredCount de ${students.length} alumnos'
                : 'Total de alumnos: ${students.length}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          if (selectedStudent != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _brandColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Alumno: ${selectedStudent!.student.name} ${selectedStudent!.student.lastName}',
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
