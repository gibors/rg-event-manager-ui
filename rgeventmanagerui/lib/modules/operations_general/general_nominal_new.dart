import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/formatters/ThousandsSeparatorInputFormatter.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/Employee.dart';
import 'package:rg_event_management_ui/models/NominaEntry.dart';
import 'package:rg_event_management_ui/services/employees_service.dart';
// TODO: Uncomment when backend is ready
// import 'package:rg_event_management_ui/models/NominaGeneral.dart';
// import 'package:rg_event_management_ui/services/nomina_general_service.dart';

class GeneralNominalPage extends StatefulWidget {
  @override
  _GeneralNominalPageState createState() => _GeneralNominalPageState();
}

class _GeneralNominalPageState extends State<GeneralNominalPage> {
  var appState;
  String token = "";
  final currencyFormat = NumberFormat("#,##0.00");

  List<Employee> employees = [];
  List<_EmployeePayrollRow> payrollRows = [];
  bool isLoading = true;
  bool isSaving = false;

  // Nomina period fields
  final TextEditingController _periodController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 15));

  @override
  void initState() {
    super.initState();
    appState = context.read<MyAppState>();
    token = appState.appToken;
    _periodController.text =
        'Quincena ${DateFormat('dd/MM/yyyy').format(DateTime.now())}';
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    try {
      final emps = await EmployeesService().getAllEmployees(token);
      setState(() {
        employees = emps;
        payrollRows = emps
            .map((e) => _EmployeePayrollRow(
                  employee: e,
                  baseSalaryController: TextEditingController(text: '0'),
                  bonuses: [],
                  notesController: TextEditingController(),
                ))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      log('Error loading employees: $e');
      setState(() => isLoading = false);
    }
  }

  double _parseAmount(String text) {
    return double.tryParse(text.replaceAll(',', '')) ?? 0;
  }

  double _getRowTotal(_EmployeePayrollRow row) {
    double base = _parseAmount(row.baseSalaryController.text);
    double bonusTotal = row.bonuses.fold(
        0.0, (sum, b) => sum + _parseAmount(b.amountController.text));
    return base + bonusTotal;
  }

  double _getGrandTotal() {
    return payrollRows.fold(0.0, (sum, row) => sum + _getRowTotal(row));
  }

  void _addBonus(_EmployeePayrollRow row) {
    setState(() {
      row.bonuses.add(_BonusRow(
        conceptController: TextEditingController(),
        amountController: TextEditingController(text: '0'),
      ));
    });
  }

  void _removeBonus(_EmployeePayrollRow row, int index) {
    setState(() {
      row.bonuses[index].conceptController.dispose();
      row.bonuses[index].amountController.dispose();
      row.bonuses.removeAt(index);
    });
  }

  Future<void> _saveNomina() async {
    setState(() => isSaving = true);
    try {
      // Build entries from the UI
      List<NominaEntry> entries = payrollRows.map((row) {
        return NominaEntry(
          id: 0,
          nominaId: 0,
          employee: row.employee,
          baseSalary: _parseAmount(row.baseSalaryController.text),
          bonuses: row.bonuses
              .map((b) => NominaBonusItem(
                    id: 0,
                    concept: b.conceptController.text,
                    amount: _parseAmount(b.amountController.text),
                  ))
              .toList(),
          totalPayment: _getRowTotal(row),
          notes: row.notesController.text,
        );
      }).toList();

      // For now, log the payload (backend not yet implemented)
      log('Nomina period: ${_periodController.text}');
      log('Start: $_startDate, End: $_endDate');
      log('Total entries: ${entries.length}');
      log('Grand total: \$${currencyFormat.format(_getGrandTotal())}');
      for (var entry in entries) {
        if (entry.baseSalary > 0 || entry.bonuses.isNotEmpty) {
          log('${entry.employee.name} ${entry.employee.firstSurname}: '
              'Base=\$${entry.baseSalary}, '
              'Bonuses=${entry.bonuses.length}, '
              'Total=\$${entry.totalPayment}');
        }
      }

      if (mounted) {
        Flushbar(
          message: 'Nómina guardada exitosamente',
          duration: Duration(seconds: 3),
          backgroundColor: Colors.green,
        ).show(context);
      }
    } catch (e) {
      log('Error saving nomina: $e');
      if (mounted) {
        Flushbar(
          message: 'Error al guardar nómina: $e',
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ).show(context);
      }
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    _periodController.dispose();
    for (var row in payrollRows) {
      row.baseSalaryController.dispose();
      row.notesController.dispose();
      for (var b in row.bonuses) {
        b.conceptController.dispose();
        b.amountController.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(Icons.event_note, color: const Color.fromARGB(255, 113, 7, 132), size: 28),
            SizedBox(width: 10),
            Text('RG Eventos',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 113, 7, 132))),
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
                    backgroundColor: const Color.fromARGB(255, 113, 7, 132),
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
          : Column(
              children: [
                // Header section - period info and actions
                _buildHeaderSection(),
                Divider(height: 1),
                // Employee payroll table
                Expanded(child: _buildPayrollTable()),
                // Footer - grand total
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
            'Nómina General',
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 113, 7, 132)),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              // Period name
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _periodController,
                  decoration: InputDecoration(
                    labelText: 'Periodo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                ),
              ),
              SizedBox(width: 16),
              // Start date
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, true),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Fecha inicio',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.date_range),
                    ),
                    child:
                        Text(DateFormat('dd/MM/yyyy').format(_startDate)),
                  ),
                ),
              ),
              SizedBox(width: 16),
              // End date
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, false),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Fecha fin',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.date_range),
                    ),
                    child: Text(DateFormat('dd/MM/yyyy').format(_endDate)),
                  ),
                ),
              ),
              SizedBox(width: 24),
              // Save button
              ElevatedButton.icon(
                onPressed: isSaving ? null : _saveNomina,
                icon: isSaving
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.save),
                label: Text('Guardar Nómina',
                    style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 113, 7, 132),
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Chip(
                avatar: Icon(Icons.people, size: 18),
                label: Text('Total empleados: ${employees.length}'),
              ),
              SizedBox(width: 12),
              Chip(
                avatar: Icon(Icons.attach_money, size: 18),
                label: Text(
                    'Total nómina: \$${currencyFormat.format(_getGrandTotal())}'),
                backgroundColor: Colors.green.shade50,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollTable() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Table header
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 113, 7, 132),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(8)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _headerCell('Empleado', flex: 3),
                  _headerCell('Puesto', flex: 2),
                  _headerCell('Salario Base', flex: 2),
                  _headerCell('Bonos/Extras', flex: 4),
                  _headerCell('Total', flex: 2),
                  _headerCell('Notas', flex: 2),
                ],
              ),
            ),
            // Table rows
            ...payrollRows.asMap().entries.map((entry) {
              int index = entry.key;
              var row = entry.value;
              return _buildPayrollRow(row, index);
            }),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildPayrollRow(_EmployeePayrollRow row, int index) {
    bool isEven = index % 2 == 0;
    return Container(
      decoration: BoxDecoration(
        color: isEven ? Colors.white : Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
          left: BorderSide(color: Colors.grey.shade300, width: 0.5),
          right: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Employee name
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${row.employee.name} ${row.employee.firstSurname} ${row.employee.secondSurname}',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  row.employee.email,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          // Position
          Expanded(
            flex: 2,
            child: Text(
              row.employee.position,
              style: TextStyle(fontSize: 13),
            ),
          ),
          // Base salary
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: row.baseSalaryController,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          SizedBox(width: 8),
          // Bonuses section
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...row.bonuses.asMap().entries.map((bEntry) {
                  int bIndex = bEntry.key;
                  var bonus = bEntry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 36,
                            child: TextField(
                              controller: bonus.conceptController,
                              decoration: InputDecoration(
                                hintText: 'Concepto',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                isDense: true,
                              ),
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 36,
                            child: TextField(
                              controller: bonus.amountController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                ThousandsSeparatorInputFormatter()
                              ],
                              decoration: InputDecoration(
                                prefixText: '\$ ',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                isDense: true,
                              ),
                              style: TextStyle(fontSize: 13),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        InkWell(
                          onTap: () => _removeBonus(row, bIndex),
                          child: Icon(Icons.remove_circle,
                              color: Colors.red.shade400, size: 20),
                        ),
                      ],
                    ),
                  );
                }),
                InkWell(
                  onTap: () => _addBonus(row),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle,
                          color: Colors.green.shade600, size: 18),
                      SizedBox(width: 4),
                      Text('Agregar bono',
                          style: TextStyle(
                              color: Colors.green.shade600, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          // Total
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: _getRowTotal(row) > 0
                    ? Colors.green.shade50
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '\$${currencyFormat.format(_getRowTotal(row))}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: _getRowTotal(row) > 0
                      ? Colors.green.shade800
                      : Colors.grey,
                ),
              ),
            ),
          ),
          // Notes
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: row.notesController,
                decoration: InputDecoration(
                  hintText: 'Notas...',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  isDense: true,
                ),
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
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
            'Total de empleados en nómina: ${payrollRows.where((r) => _getRowTotal(r) > 0).length} / ${payrollRows.length}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 113, 7, 132),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'TOTAL NÓMINA: \$${currencyFormat.format(_getGrandTotal())}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

/// Internal class to hold the UI state for each employee row
class _EmployeePayrollRow {
  final Employee employee;
  final TextEditingController baseSalaryController;
  final List<_BonusRow> bonuses;
  final TextEditingController notesController;

  _EmployeePayrollRow({
    required this.employee,
    required this.baseSalaryController,
    required this.bonuses,
    required this.notesController,
  });
}

/// Internal class for bonus input rows
class _BonusRow {
  final TextEditingController conceptController;
  final TextEditingController amountController;

  _BonusRow({
    required this.conceptController,
    required this.amountController,
  });
}
