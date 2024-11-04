import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:rg_event_management_ui/models/Event.dart';
import 'package:rg_event_management_ui/models/Supplier.dart';
import 'package:rg_event_management_ui/models/Student.dart';

class EventService {
  final Dio _dio;

//shared-preferences
  EventService() : _dio = Dio();

  Future<List<Event>> getEvents(String token) async {
    try {
      final response = await _dio.get('http://localhost:8080/api/v1/events',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      final data = response.data as List<dynamic>;
      final events = data.map((event) => Event.fromJson(event)).toList();
      return events;
    } catch (e) {
      log('Dio get request error: ${e.toString()}');
      throw Exception('Failed to fetch events: $e');
    }
  }

  Future<Event> getEventById(int id, String token) async {
    try {
      final response = await _dio.get('http://localhost:8080/api/v1/events/$id',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      final data = response.data;
      final event = Event.fromJson(data);
      return event;
    } catch (e) {
      throw Exception('Failed to fetch event: $e');
    }
  }

  Future<List<EventType>> getEventTypes(String token) async {
    try {
      final response = await _dio.get(
          'http://localhost:8080/api/v1/events/types',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      final data = response.data as List<dynamic>;
      final eventTypes =
          data.map((eventType) => EventType.fromJson(eventType)).toList();
      return eventTypes;
    } catch (e) {
      throw Exception('Failed to fetch event types: $e');
    }
  }

  Future<List<Location>> getLocations(String token) async {
    try {
      final response = await _dio.get(
          'http://localhost:8080/api/v1/events/locations',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      final data = response.data as List<dynamic>;
      final locations =
          data.map((location) => Location.fromJson(location)).toList();
      return locations;
    } catch (e) {
      throw Exception('Failed to fetch locations: $e');
    }
  }

  Future<Event> createEvent(Event event, String token) async {
    try {
      var data = event.toJson();
      log('data: $data');
      final response = await _dio.post('http://localhost:8080/api/v1/events',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      final eventResponse = Event.fromJson(response.data);
      return eventResponse;
    } catch (e) {
      log('Dio saving event, post request error: ${e.toString()}');
      throw Exception('Failed to create event: $e');
    }
  }

  Future<List<Student>> getStudentsByEvent(String token, int eventId) async {
    try {
      final response = await _dio.get(
          'http://localhost:8080/api/v1/students/events/$eventId',
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
      final response = await _dio.post('http://localhost:8080/api/v1/students',
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
          'http://localhost:8080/api/v1/payments/events/$eventId',
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
      var response = await _dio.post('http://localhost:8080/api/v1/payments',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
        var responsePayment = Payment.fromJson(response.data);

        return responsePayment;

    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  Future<Student> saveStudentWithFolioData(
      Payment payment, Student student, String token) async {
    try {
      Student? studentResponse;
      var folioRequest = await _dio.get(
          'http://localhost:8080/api/v1/students/folio',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      var folioData = folioRequest.data;
      log('folioData: $folioData returned');

      if (folioData != null) {
        // making sure we are storing student and folio correctly
        student.setFolio(folioData.toString());
        payment.setStudent(student.id);
        log('student data : ${student.toJson()}');
        var requestStudent = await _dio.post(
            'http://localhost:8080/api/v1/students',
            data: student.toJson(),
            options: Options(headers: {'Authorization': 'Bearer $token'}));
        studentResponse = Student.fromJson(requestStudent.data);
        justWait() async {
          await Future.delayed(Duration(seconds: 1));
        }
        log('payment data : ${payment.toJson()}');
        var requestPayment = await _dio.post(
            'http://localhost:8080/api/v1/payments',
            data: payment.toJson(),
            options: Options(headers: {'Authorization': 'Bearer $token'}));

        // show processing payment..
      }
      return studentResponse!;
    } catch (e) {
      throw Exception('Failed to create payment and student: $e');
    }
  }

  Future<List<Supplier>> getAllProviders(String token) async {
    try {
      final response = await _dio.get('http://localhost:8080/api/v1/suppliers',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      final data = response.data as List<dynamic>;
      final providers =
          data.map((provider) => Supplier.fromJson(provider)).toList();
      return providers;
    } catch (e) {
      throw Exception('Failed to fetch event types: $e');
    }
  }

  Future<List<ServiceType>> getServices(String token) async {
    try {
      final response = await _dio.get(
          'http://localhost:8080/api/v1/suppliers/service-types',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      final data = response.data as List<dynamic>;
      final services =
          data.map((service) => ServiceType.fromJson(service)).toList();
      return services;
    } catch (e) {
      throw Exception('Failed to fetch services: $e');
    }
  }

  Future<Supplier> createorSaveProvider(Supplier provider, String token) async {
    try {
      var data = provider.toJson();
      log('data: $data');
      var result = await _dio.post('http://localhost:8080/api/v1/suppliers',
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
          'http://localhost:8080/api/v1/students/folio',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      final data = response.data;
      var folio = data.toString();
      return folio;
    } catch (e) {
      throw Exception('Failed to fetch next folio: $e');
    }
  }
}
