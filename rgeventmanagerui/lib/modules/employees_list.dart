import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/Employee.dart';

class EmployeesView extends StatefulWidget {
  const EmployeesView({Key? key}) : super(key: key);

  @override
  State<EmployeesView> createState() => _EmployeesViewState();
}

class _EmployeesViewState extends State<EmployeesView> {

  final _key = GlobalKey();
  final controller = ScrollController();
  late Future<List<Employee>> _func;
  double offset = 0;


  @override
  void initState() {
    var appState = context.read<MyAppState>();
    var token = appState.appToken;
    // _func = 
    // controller.addListener(onScroll);
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
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    return SizedBox(
      // height: 800,
      // width: 1500,
      child: FutureBuilder<List<Employee>>(
        future: _func,
        builder: (context, snapshot) => snapshot.hasData
            ? Center( 
      child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(snapshot.data![index].photo),
                    ),
                    title: Text(snapshot.data![index].name),
                    subtitle: Text(snapshot.data![index].email),
                    onTap: () {
                      // appState.selectedEmployee = snapshot.data![index];
                      Navigator.of(context).pushNamed('/employee');
                    },
                  ),
                );
              },
            ),
          ),
        ]),),)
            : (snapshot.hasError) ? Center(child: Text('Error: ${snapshot.error}')
    ) : const Center(child: CircularProgressIndicator()),
      ),
    );  
  } 
}