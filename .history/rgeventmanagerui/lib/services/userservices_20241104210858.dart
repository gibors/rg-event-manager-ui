import 'package:dio/dio.dart';
import 'package:rg_event_management_ui/models/AuthResponse.dart';
import 'dart:developer';

import 'package:rg_event_management_ui/models/User.dart';

class UserService {
  Future<AuthResponse> login(username, password) async {
    
    try {

      final dio = Dio();
      final response = await dio.post(
        'http://localhost:8080/api/v1/auth/login',
        data: {'userName': username, 'password': password},
      );

      var statusCode = response.statusCode;
      if (statusCode == 200) {

        var authResponse = AuthResponse.fromJson(response.data);
        return authResponse;
      
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        log("error: ${response.data.toString()}, status: ${int.parse(statusCode as String)}");
        return AuthResponse.fromJson(response.data);
      }
    } catch (e) {
      log('Dio poost request error: ${e.toString()}');
      return AuthResponse(token: "", type: "", error: e.toString());
    }
  }

  Future<List<User>> getUsers(token) async {
    try {
      final dio = Dio();
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers["authorization"] = "Bearer $token";
      return dio.get('http://localhost:8080/api/v1/users/all').then((response) {
        if (response.statusCode == 200) {
          return (response.data as List).map((user) => User.fromJson(user)).toList();
        } else {
          throw Exception('Failed to load user');
        }
      });
  }
  catch (e) {
    log('Dio get request error: ${e.toString()}');
    return [];
  }
}

Future<User> saveUser(user) async {
  try {
    final dio = Dio();
    dio.options.headers['content-Type'] = 'application/json';
    final response = await dio.post('http://localhost:8080/api/v1/auth/register',
        data: user.toJson());
   
    if (response.statusCode == 200) {
      final eventResponse = User.fromJson(response.data);
      return eventResponse;
    } else {
      return throw Exception('Failed to save user');
    }
  } catch (e) {
    log('Dio get request error: ${e.toString()}');
          throw Exception('Failed to load user');
  }

}

Future<String> healthcheck() async {

    try {
      final dio = Dio();
      final response = await dio.get('http://localhost:8080/api/v1/health');
      return response.data;
    }catch(e){

    }
}
}
