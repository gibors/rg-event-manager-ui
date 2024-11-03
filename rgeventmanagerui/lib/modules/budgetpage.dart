import 'package:flutter/material.dart';

class BudgetPage extends StatefulWidget {
  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: 
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () { 
              // Navigator.pop(context);
             },),
        title: Text('Budget Page'),
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