import 'package:dio/dio.dart';
import 'package:rg_event_management_ui/models/Employee.dart';

class EmployeesService {
  final Dio _dio;

//shared-preferences
  EmployeesService() : _dio = Dio();

  Future<List<Employee>> getAllEmployees(String token) async {
    try {
      final response = await _dio.get('http://localhost:8080/api/v1/employees',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      final data = response.data as List<dynamic>;
      final employees =
          data.map((employee) => Employee.fromJson(employee)).toList();
      return employees;
    } catch (e) {
      throw Exception('Failed to fetch employees: $e');
    }
  }

  Future<Employee> createEmployee(String token, Employee employ) async {
    try {
      var data = employ.toJson();
      final response = await _dio.post('http://localhost:8080/api/v1/employees',
          data: data,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      final responseData = response.data;
      final employee = Employee.fromJson(responseData);
      return employee;
    } catch (e) {
      throw Exception('Failed to save employee: $e');
    }
  }

  Future<Employee> updateEmployee(String token, Employee employ) async {
   try {
      var data = employ.toJson();
      final response = await _dio.put('http://localhost:8080/api/v1/employees',
          data: data,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      final responseData = response.data;
      final employee = Employee.fromJson(responseData);
      return employee;
    } catch (e) {
      throw Exception('Failed to save employee: $e');
    }
  }
}
