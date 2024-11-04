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
    TextEditingController id = new TextEditingController();
    TextEditingController description = new TextEditingController();
    TextEditingController eventId = new TextEditingController();
    TextEditingController supplierId = new TextEditingController();
    TextEditingController customerCost =  new TextEditingController();
    TextEditingController supplierCost = new TextEditingController();
    int index = additionalServicesWidgets.length - 1;
    
    setState(() {
      additionalServicesWidgets.add(
        Column(children: [
          SizedBox(height: 22,),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: description,
                decoration: InputDecoration(
                  labelText: "Description",
                  hintText: "Description",
                ),
              ),
            ),
            Expanded(
              child: RawAutocomplete<ServiceType>(
                optionsBuilder: (textEditingValue) => {
                  for (var service in services)
                    if (service.name.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                      service

                }, optionsViewBuilder: (BuildContext context, void Function(ServiceType) onSelected, Iterable<ServiceType> options) { 
                  return Material(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: Text(_displayStringServicesForOption(option)),
                          onTap: () {
                            onSelected(option);
                          },
                        );
                      },
                    ),
                  );
                 },
                              fieldViewBuilder: (
               BuildContext context,
               TextEditingController fieldTextEditingController,
               FocusNode fieldFocusNode,
               VoidCallback onFieldSubmitted,
             ) {
               return TextFormField(
                 controller: fieldTextEditingController,
                 focusNode: fieldFocusNode,
                 decoration: const InputDecoration(labelText: 'Servicio'),
               );
             },
                  onSelected: (ServiceType option) {
                    setState(() {
                      id.text = option.id.toString();
                    });
                  },
              ),    
              )
            ,
            Expanded(
              child: RawAutocomplete<Supplier>(
                optionsViewBuilder: (context, onSelected, options) {
                  return Material(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: Text(_displayStringSuppliersForOption(option)),
                          onTap: () {
                            onSelected(option);
                          },
                        );
                      },
                    ),
                  );
                },

                onSelected: (Supplier option) {
                  setState(() {
                    supplierId.text = option.id.toString();
                  });
                },
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<Supplier>.empty();
                  }
                  return suppliers.where((Supplier option) {
                    return option.name
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  });
                },
              )
            ),
            Expanded(
              child: TextFormField(
                controller: customerCost,
                decoration: InputDecoration(
                  labelText: "Customer Cost",
                  hintText: "Customer Cost",
                ),
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: supplierCost,
                decoration: InputDecoration(
                  labelText: "Supplier Cost",
                  hintText: "Supplier Cost",
                ),
              ),
            ),
          ],)
        ],)
      );
    });

  }

  @override
  Widget build(BuildContext context) {
    var appState = context.read<MyAppState>();
    return Scaffold( 
      appBar: AppBar(
        title: Text("Additional Services"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 22,),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      addAdditionalServiceWidget();
                    },
                    child: Text("Add Additional Service"),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Save Additional Services
                    },
                    child: Text("Save Additional Services"),
                  ),
                ),
              ],
            ),
            Column(
              children: additionalServicesWidgets,
            ),
          ],
        ),
      ),
    );
    
  
}
}