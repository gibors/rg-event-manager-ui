import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:rg_event_management_ui/models/AdditionalService.dart';
import 'package:rg_event_management_ui/models/AdditionalServiceResponse.dart';
import 'package:rg_event_management_ui/models/Event.dart' as eventprefix;
import 'package:rg_event_management_ui/models/Supplier.dart';
import 'package:rg_event_management_ui/models/Student.dart';

class EventService {
  final Dio _dio;

//shared-preferences
  EventService()
      : _dio = createDio(
            baseUrl: 'https://localhost:8443/api/v1', trustSelfSigned: true);

  Future<List<eventprefix.Event>> getEvents(String token) async {
    try {
      final response = await _dio.get('https://localhost:8443/api/v1/events',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      final data = response.data as List<dynamic>;
      final events =
          data.map((event) => eventprefix.Event.fromJson(event)).toList();
      return events;
    } catch (e) {
      log('Dio get request error: ${e.toString()}');

      throw Exception('Failed to fetch events: $e');
    }
  }

  Future<eventprefix.Event> getEventById(int id, String token) async {
    try {
      final response = await _dio.get(
          'https://localhost:8443/api/v1/events/$id',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      final data = response.data;
      final event = eventprefix.Event.fromJson(data);
      return event;
    } catch (e) {
      throw Exception('Failed to fetch event: $e');
    }
  }

  Future<List<eventprefix.EventType>> getEventTypes(String token) async {
    try {
      final response = await _dio.get(
          'https://localhost:8443/api/v1/events/types',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      final data = response.data as List<dynamic>;
      final eventTypes = data
          .map((eventType) => eventprefix.EventType.fromJson(eventType))
          .toList();
      return eventTypes;
    } catch (e) {
      throw Exception('Failed to fetch event types: $e');
    }
  }

  Future<List<eventprefix.Location>> getLocations(String token) async {
    try {
      final response = await _dio.get(
          'https://localhost:8443/api/v1/events/locations',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      final data = response.data as List<dynamic>;
      final locations = data
          .map((location) => eventprefix.Location.fromJson(location))
          .toList();
      return locations;
    } catch (e) {
      throw Exception('Failed to fetch locations: $e');
    }
  }

  Future<eventprefix.Event> createOrUpdateEvent(
      eventprefix.Event event, String token) async {
    try {
      var data = event.toJson();
      log('data: $data');
      final response = await _dio.post('https://localhost:8443/api/v1/events',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      final eventResponse = eventprefix.Event.fromJson(response.data);
      return eventResponse;
    } catch (e) {
      log('Dio saving event, post request error: ${e.toString()}');
      throw Exception('Failed to create event: $e');
    }
  }

  Future<List<Student>> getStudentsByEvent(String token, int eventId) async {
    try {
      final response = await _dio.get(
          'https://localhost:8443/api/v1/students/events/$eventId',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      final data = response.data as List<dynamic>;
      final students =
          data.map((student) => Student.fromJson(student)).toList();
      return students;
    } catch (e) {
      throw Exception('Failed to fetch students: $e');
    }
  }

  Future<Student> saveStudent(Student student, String token) async {
    try {
      var data = student.toJson();  
      log('data: $data');
      final response = await _dio.post('https://localhost:8443/api/v1/students',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      final studentResponse = Student.fromJson(response.data);
      return studentResponse;
    } catch (e) {
      throw Exception('Failed to fetch students: $e');
    }
  }

  Future<List<Payment>> getPaymentsByEventId(String token, int eventId) async {
    try {
      final response = await _dio.get(
          'https://localhost:8443/api/v1/payments/events/$eventId',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      final data = response.data as List<dynamic>;
      final payments =
          data.map((payment) => Payment.fromJson(payment)).toList();
      return payments;
    } catch (e) {
      throw Exception('Failed to fetch payments: $e');
    }
  }

  Future<Payment> createPayment(Payment payment, String token) async {
    try {
      var data = payment.toJson();
      log('payment single: $data');
      var response = await _dio.post('https://localhost:8443/api/v1/payments',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      var responsePayment = Payment.fromJson(response.data);

      return responsePayment;
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  Future<bool> deletePayment(int paymentId, String token) async {
    try {
      var response = await _dio.delete(
          'https://localhost:8443/api/v1/payments/$paymentId',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to delete payment: $e');
    }
  }

  Future<bool> deleteStudent(int studentId, String token) async {
    try {
      var response = await _dio.delete(
          'https://localhost:8443/api/v1/students/$studentId',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to delete student: $e');
    }
  }

  Future<Student> saveStudentWithFolioData(
      Student student, String token) async {
    try {
      Student? studentResponse;
      var folioRequest = await _dio.get(
          'https://localhost:8443/api/v1/students/folio?eventId=${student.eventId}',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      var folioData = folioRequest.data;
      log('folioData: $folioData returned');

      if (folioData != null) {
        student.setFolio(folioData.toString());

        log('student data : ${student.toJson()}');
        var requestStudent = await _dio.post(
            'https://localhost:8443/api/v1/students',
            data: student.toJson(),
            options: Options(headers: {'Authorization': 'Bearer $token'}));
        studentResponse = Student.fromJson(requestStudent.data);
      }
      return studentResponse!;
    } catch (e) {
      throw Exception('Failed to create payment and student: $e');
    }
  }

  Future<List<Supplier>> getAllProviders(String token) async {
    try {
      final response = await _dio.get('https://localhost:8443/api/v1/suppliers',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      final data = response.data as List<dynamic>;
      final providers =
          data.map((provider) => Supplier.fromJson(provider)).toList();
      return providers;
    } catch (e) {
      throw Exception('Failed to fetch event types: $e');
    }
  }

    Future<List<Supplier>> getProvidersByService(String token, serviceId) async {
    try {
      final response = await _dio.get('https://localhost:8443/api/v1/suppliers/service-type/$serviceId',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      final data = response.data as List<dynamic>;
      final providers =
          data.map((provider) => Supplier.fromJson(provider)).toList();
      return providers;
    } catch (e) {
      throw Exception('Failed to fetch event types: $e');
    }
  }

  Future<ServiceType> createService(ServiceType service, String token) async {
    try {
      var data = service.toJson();
      log('data: $data');
      var result = await _dio.post('https://localhost:8443/api/v1/suppliers/service-type',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      log('result: $result');
      final serviceResponse = ServiceType.fromJson(result.data);
      return serviceResponse;
    } catch (e) {
      throw Exception('Failed to create service type: $e');
    }
  }

  Future<List<ServiceType>> getServices(String token) async {
    try {
      final response = await _dio.get(
          'https://localhost:8443/api/v1/suppliers/service-types',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      final data = response.data as List<dynamic>;
      final services =
          data.map((service) => ServiceType.fromJson(service)).toList();
      return services;
    } catch (e) {
      throw Exception('Failed to fetch services: $e');
    }
  }

  Future<List<AdditionalService>> getAdditionalServiceByEventId(String token, int eventId) async {
    try {
      final response = await _dio.get(
          'https://localhost:8443/api/v1/additional-services/events/$eventId',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      final data = response.data as List<dynamic>;
      final services = data.map((additionalServices) => AdditionalService.fromJson(additionalServices)).toList();
      return services;
    } catch (e) {
      throw Exception('Failed to fetch service: $e');
    }
  }
  
  Future<Additionalserviceresponse> createAdditionalServices(List<AdditionalService> additionalServices, String token) async {
    try {
      var data = additionalServices.map((service) => service.toJson()).toList();
      log('data: $data');
      var result = await _dio.post('https://localhost:8443/api/v1/additional-services',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      log('result: $result');
      final serviceResponse = Additionalserviceresponse.fromJson(result.data);
      return serviceResponse;
    } catch (e) {
      throw Exception('Failed to create service: $e');
    }
  }

  Future<Supplier> createOrSaveProvider(Supplier provider, String token) async {
    try {
      var data = provider.toJson();
      log('data: $data');
      var result = await _dio.post('https://localhost:8443/api/v1/suppliers',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      log('result: $result');
      final providerResponse = Supplier.fromJson(result.data);
      return providerResponse;
    } catch (e) {
      throw Exception('Failed to create provider: $e');
    }
  }

  Future<String> getNextFolioStudent(token) async {
    try {
      final response = await _dio.get(
          'https://localhost:8443/api/v1/students/folio',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      final data = response.data;
      var folio = data.toString();
      return folio;
    } catch (e) {
      throw Exception('Failed to fetch next folio: $e');
    }
  }

  Future<String> DownloadGraduationListPDF(token, event, path, isInternal) async {
    try {
      var current = Directory.current.path;
      log('current path: $current');
      var eventeventId = event.id;
      var eventname = event.name.replaceAll(' ', '-');
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      var pathToSave = '$path/lista-$eventname-$timestamp.pdf';
      var export = isInternal ? 'export-internal' : 'export';
      final response = (await _dio.download(
          'https://localhost:8443/api/v1/students/$export?eventId=$eventeventId&format=pdf',
          pathToSave,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'responseType': ResponseType.bytes,              
            },
          )));
      return pathToSave;
    } catch (e) {
      log('Failed to fetch next folio: $e.toString()');
      throw Exception('Failed to fetch next folio: $e');
    }
  }

  Future<String> DownloadEventList(token, List<int> eventIds, path) async {
    try {
      var current = Directory.current.path;
      log('current path: $current');
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      var pathToSave = '$path/lista-eventos-$timestamp.pdf';
      var downloadAll = eventIds.isEmpty;
      final response = (await _dio.download(
          'https://localhost:8443/api/v1/events/export-pdf',
          pathToSave,
          data: {'eventIds': eventIds, 'exportAllEvents': downloadAll},
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'responseType': ResponseType.bytes,              
            },
          )));
      return pathToSave;
      
    } catch (e) {
      log('Failed to fetch next folio: $e.toString()');
      throw Exception('Failed to fetch next folio: $e');
    }
  }

  static Dio createDio(
      {required String baseUrl, bool trustSelfSigned = false}) {
    // initialize dio
    final dio = Dio()..options.baseUrl = baseUrl;

    // allow self-signed certificate
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => trustSelfSigned;
      return client;
    };

    return dio;
  }
}
