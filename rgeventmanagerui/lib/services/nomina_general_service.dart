import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:rg_event_management_ui/models/NominaEntry.dart';
import 'package:rg_event_management_ui/models/NominaGeneral.dart';

class NominaGeneralService {
  final Dio _dio;

  NominaGeneralService()
      : _dio = _createDio(
            baseUrl: 'https://localhost:8443/api/v1', trustSelfSigned: true);

  /// Get all nomina periods
  Future<List<NominaGeneral>> getAllNominas(String token) async {
    try {
      final response = await _dio.get(
        'https://localhost:8443/api/v1/nomina-general',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data as List<dynamic>;
      return data.map((n) => NominaGeneral.fromJson(n)).toList();
    } catch (e) {
      log('Error fetching nominas: $e');
      throw Exception('Failed to fetch nominas: $e');
    }
  }

  /// Create a new nomina period
  Future<NominaGeneral> createNomina(String token, NominaGeneral nomina) async {
    try {
      final response = await _dio.post(
        'https://localhost:8443/api/v1/nomina-general',
        data: nomina.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return NominaGeneral.fromJson(response.data);
    } catch (e) {
      log('Error creating nomina: $e');
      throw Exception('Failed to create nomina: $e');
    }
  }

  /// Get entries for a specific nomina
  Future<List<NominaEntry>> getNominaEntries(String token, int nominaId) async {
    try {
      final response = await _dio.get(
        'https://localhost:8443/api/v1/nomina-general/$nominaId/entries',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data as List<dynamic>;
      return data.map((e) => NominaEntry.fromJson(e)).toList();
    } catch (e) {
      log('Error fetching nomina entries: $e');
      throw Exception('Failed to fetch nomina entries: $e');
    }
  }

  /// Save or update a nomina entry (employee salary + bonuses)
  Future<NominaEntry> saveNominaEntry(String token, NominaEntry entry) async {
    try {
      final response = await _dio.post(
        'https://localhost:8443/api/v1/nomina-general/${entry.nominaId}/entries',
        data: entry.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return NominaEntry.fromJson(response.data);
    } catch (e) {
      log('Error saving nomina entry: $e');
      throw Exception('Failed to save nomina entry: $e');
    }
  }

  /// Save all entries for a nomina (batch save)
  Future<List<NominaEntry>> saveAllEntries(
      String token, int nominaId, List<NominaEntry> entries) async {
    try {
      final response = await _dio.post(
        'https://localhost:8443/api/v1/nomina-general/$nominaId/entries/batch',
        data: entries.map((e) => e.toJson()).toList(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data as List<dynamic>;
      return data.map((e) => NominaEntry.fromJson(e)).toList();
    } catch (e) {
      log('Error saving all entries: $e');
      throw Exception('Failed to save entries: $e');
    }
  }

  /// Mark nomina as paid/generated
  Future<NominaGeneral> updateNominaStatus(
      String token, int nominaId, String status) async {
    try {
      final response = await _dio.put(
        'https://localhost:8443/api/v1/nomina-general/$nominaId/status',
        data: {'status': status},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return NominaGeneral.fromJson(response.data);
    } catch (e) {
      log('Error updating nomina status: $e');
      throw Exception('Failed to update nomina status: $e');
    }
  }

  /// Delete a nomina entry
  Future<void> deleteNominaEntry(String token, int entryId) async {
    try {
      await _dio.delete(
        'https://localhost:8443/api/v1/nomina-general/entries/$entryId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      log('Error deleting entry: $e');
      throw Exception('Failed to delete entry: $e');
    }
  }

  static Dio _createDio(
      {required String baseUrl, bool trustSelfSigned = false}) {
    final dio = Dio()..options.baseUrl = baseUrl;
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => trustSelfSigned;
      return client;
    };
    return dio;
  }
}
