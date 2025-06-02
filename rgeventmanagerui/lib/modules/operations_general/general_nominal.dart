
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/main.dart';
class GeneralNominalPage extends StatefulWidget {

  @override
  _GeneralNominalPage createState() => _GeneralNominalPage();
}

class _GeneralNominalPage extends State<GeneralNominalPage> {
  var appState;
  final _formKey = GlobalKey<FormState>();
  var token = "";
  var selectedEvent;

  @override
  Widget build(BuildContext context) {
        appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Text(
            'Sistema RG Eventos - Usuario conectado: ${appState.selectedUser != null ? '${appState.selectedUser!.name} ${appState.selectedUser!.lastname} con rol de ${appState.selectedUser!.role == 1 ? 'admin' : (appState.selectedUser!.role == 2 ? 'operativo' : 'solo lectura')}' : ''}',
            style: TextStyle(
                fontSize: 28.0, color: const Color.fromARGB(255, 113, 7, 132))),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 22,
            ),
            Row(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/general');
                  },
                  child: Text(
                    'Generar Nomina',
                    style: TextStyle(fontSize: 20.0, color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        )
      ,)
    );
  }  
}