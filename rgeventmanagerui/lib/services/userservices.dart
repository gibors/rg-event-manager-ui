
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:rg_event_management_ui/models/AuthResponse.dart';
import 'dart:developer';
import 'package:rg_event_management_ui/models/User.dart';

class UserService {
  final Dio _dio;

    UserService() : _dio = createDio(baseUrl: 'https://localhost:8443/api/v1', trustSelfSigned: true);

  
  Future<AuthResponse> login(username, password) async {
    
    try {

      final response = await _dio.post(
        'https://localhost:8443/api/v1/auth/login',
        data: {'username': username, 'password': password},
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
      log('Dio post request error: ${e.toString()}');
    try {
      final response = await _dio.get('https://localhost:8443/api/v1/health');
      return AuthResponse(token: "", type: "", error: "OK");
    }catch(e){
      log('HealthCheck request error: ${e.toString()}');
            return AuthResponse(token: "", type: "", error: "DOWN");
    }
    }
  }

  Future<List<User>> getUsers(token) async {
    try {
      _dio.options.headers['content-Type'] = 'application/json';
      _dio.options.headers["authorization"] = "Bearer $token";
      return _dio.get('https://localhost:8443/api/v1/users/all').then((response) {
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
    final response = await dio.post('https://localhost:8443/api/v1/auth/register',
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
      final response = await _dio.get('https://localhost:8443/api/v1/health');
      return response.data;
    }catch(e){
      log('HealthCheck request error: ${e.toString()}');
      return "ERROR";
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
