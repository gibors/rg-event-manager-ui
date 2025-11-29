import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/main.dart';

class RGHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
 var appState = context.read<MyAppState>();
    
    return AppBar(
      title: Text('RG Event Manager - ${appState.selectedUser!.name}'),
      // Add more customization options for the header here
    );
  }
}