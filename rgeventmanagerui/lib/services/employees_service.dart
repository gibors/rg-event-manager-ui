import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:rg_event_management_ui/models/Employee.dart';

class EmployeesService {
  final Dio _dio;

//shared-preferences
  EmployeesService() : _dio = createDio(baseUrl: 'https://localhost:8443/api/v1', trustSelfSigned: true);

  Future<List<Employee>> getAllEmployees(String token) async {
    try {
      final response = await _dio.get('https://localhost:8443/api/v1/employees',
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
      final response = await _dio.post('https://localhost:8443/api/v1/employees',
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
      final response = await _dio.put('https://localhost:8443/api/v1/employees',
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

  Future<bool> deleteEmployee(String token, int id) async {
    try {
      var response = await _dio.delete('https://localhost:8443/api/v1/employees/$id',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      if(response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('Error al eliminar empleado: $e');
      return false;
    }
  }

   static Dio createDio({required String baseUrl, bool trustSelfSigned = false}) {
  // initialize dio
  final dio = Dio()
    ..options.baseUrl = baseUrl;

  // allow self-signed certificate
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => trustSelfSigned;
    return client;
  };
  
  return dio;
}
}
