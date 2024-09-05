import 'package:dio/dio.dart';
import 'package:rg_event_management_ui/models/User.dart';
import 'dart:developer';

class UserService {
  Future<String> login(username, password) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        'http://localhost:8080/api/v1/auth/login',
        data: {'userName': username, 'password': password},
      );

      var statusCode = response.statusCode;
      if (statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        return response.data;
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        log("error: ${response.data.toString()}, status: ${int.parse(statusCode as String)}");
        return "";
      }
    } catch (e) {
      log('Dio poost request error: ${e.toString()}');
      return "";
    }
  }
}
