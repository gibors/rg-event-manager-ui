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
        title: Text('Budget Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Expense 1',
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Expense 2',
                ),
              ),
              // Add more form fields as needed

              ElevatedButton(
                onPressed: () {
                  // Handle form submission
                },
                child: Text('Generate Budget'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}