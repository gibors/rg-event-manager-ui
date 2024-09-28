

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GraduationPage extends StatefulWidget {
  @override
  _GraduationState createState() => _GraduationState();

}

class _GraduationState extends State<GraduationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Graduation'),
      ),
      body: Center(
        child: Text('Graduation'),
      ),
    );
  }
}