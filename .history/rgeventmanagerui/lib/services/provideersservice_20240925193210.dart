import 'package:dio/dio.dart';

class ProviderService {
  final Dio _dio;

//shared-preferences
  ProviderService() : _dio = Dio();


  Future<List<Provider>> getProviders(String token) async {
    try {
      final response = await _dio.get('http://localhost:8080/api/v1/providers', 
          options: Options(headers: {
          'Authorization': 'Bearer $token'}));
        final data = response.data as List<dynamic>;
        final providers = data.map((provider) => Provider.fromJson(provider)).toList();
        return providers;
      } catch (e) {
        log('Dio get request error: ${e.toString()}');
        throw Exception('Failed to fetch providers: $e');
      }
  }
}