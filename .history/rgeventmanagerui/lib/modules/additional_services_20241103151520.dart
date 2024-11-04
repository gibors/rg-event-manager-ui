import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/AdditionalService.dart';
import 'package:rg_event_management_ui/models/Supplier.dart';
import 'package:rg_event_management_ui/services/eventservice.dart';

class AdditionalServices extends StatefulWidget {
  @override
  _AdditionalServices createState() => _AdditionalServices();
}

class _AdditionalServices extends State<AdditionalServices> {
  var appState;
  final _formKey = GlobalKey<FormState>();
  var token = "";
  List<ServiceType> services = [];
  List<Supplier> suppliers = [];

  List<AdditionalService> additionalServices = [];
  List<Widget> additionalServicesWidgets = [];
  List<TextEditingController> additionalServiceIds = [];
  List<TextEditingController> additionalServiceDescriptions = [];
  List<TextEditingController> additionalServiceSuppliers = [];
  List<TextEditingController> additionalServiceEvents = [];
  List<TextEditingController> additionalServiceCosts = [];
  List<TextEditingController> additionalServiceSupplierCosts = [];

  static String _displayStringServicesForOption(ServiceType option) =>
      option.name;
  static String _displayStringSuppliersForOption(Supplier option) =>
      option.name;

  @override
  void initState() {
    appState = context.read<MyAppState>();
    token = appState.appToken;

    EventService().getServices(token).then((value) {
      setState(() {
        services = value;
      });
    });

    super.initState();
  }

  void addAdditionalServiceWidget(){
    
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.read<MyAppState>();
    return Scaffold();
    
  
}
}