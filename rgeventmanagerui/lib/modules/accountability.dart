import 'package:flutter/material.dart';
import 'package:rg_event_management_ui/app_colors.dart';

class AccountabilityPage extends StatefulWidget {
  @override
  _AccountabilityPageState createState() => _AccountabilityPageState();
}

class _AccountabilityPageState extends State<AccountabilityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: 
          IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.pinkColor),
            onPressed: () { 
              // Navigator.pop(context);
             },),
        
        title: Text('Accountability Page'),
      ),
      body: Center(
        child: Text(
          'Work in Progress',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}