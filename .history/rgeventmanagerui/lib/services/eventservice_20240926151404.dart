import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:rg_event_management_ui/models/Event.dart';
import 'package:rg_event_management_ui/models/Provider.dart';
import 'package:rg_event_management_ui/models/Student.dart';

class EventService {
  final Dio _dio;

//shared-preferences
  EventService() : _dio = Dio();

  Future<List<Event>> getEvents(String token) async {

    try {
      
        
      final response = await _dio.get('http://localhost:8080/api/v1/events', 
          options: Options(headers: {
          'Authorization': 'Bearer $token'}));
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
      final response = await _dio.get('http://localhost:8080/api/v1/events/$id',  options: Options(headers: {
          'Authorization': 'Bearer $token'}));
      final data = response.data;
      final event = Event.fromJson(data);
      return event;
    } catch (e) {
      throw Exception('Failed to fetch event: $e');
    }
  }

  Future<List<EventType>> getEventTypes(String token) async {
    try {
      final response = await _dio.get('http://localhost:8080/api/v1/events/types',options: Options(headers: {
          'Authorization': 'Bearer $token'}));
      final data = response.data as List<dynamic>;
      final eventTypes = data.map((eventType) => EventType.fromJson(eventType)).toList();
      return eventTypes;
    } catch (e) {
      throw Exception('Failed to fetch event types: $e');
    }
  }

  Future<List<Location>> getLocations(String token) async {
    try {
      final response = await _dio.get('http://localhost:8080/api/v1/events/locations',options: Options(headers: {
          'Authorization': 'Bearer $token'}));
      final data = response.data as List<dynamic>;
      final locations = data.map((location) => Location.fromJson(location)).toList();
      return locations;
    } catch (e) {
      throw Exception('Failed to fetch locations: $e');
    }
  }

  Future<void> createEvent(Event event, String token) async {
    try {

      var data = event.toJson();
      log('data: $data');
      await _dio.post('http://localhost:8080/api/v1/events', data: data,
      options: Options(headers: {
          'Authorization': 'Bearer $token'}));
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  Future <List<Student>> getStudentsByEvent(String token, int eventId) async {
    try {
      final response = await _dio.get('http://localhost:8080/api/v1/students/events/$eventId',options: Options(headers: {
          'Authorization': 'Bearer $token'}));
      final data = response.data as List<dynamic>;
      final students = data.map((student) => Student.fromJson(student)).toList();
      return students;

    } catch (e) {
      throw Exception('Failed to fetch students: $e');
    } 
  }

    Future <Student> saveStudent(Student student, String token) async {
    try {

     var data = student.toJson();
      log('data: $data');
      final response = await _dio.post('http://localhost:8080/api/v1/students',data: data, options: Options(headers: {
          'Authorization': 'Bearer $token'}));

      final studentResponse = Student.fromJson(response.data);
      return studentResponse;

    } catch (e) {
      throw Exception('Failed to fetch students: $e');
    } 
  }

  Future<List<Payment>> getPaymentsByEventId(String token, int eventId) async {
    try {
      final response = await _dio.get('http://localhost:8080/api/v1/payments/events/$eventId',options: Options(headers: {
          'Authorization': 'Bearer $token'}));
      final data = response.data as List<dynamic>;
      final payments = data.map((payment) => Payment.fromJson(payment)).toList();
      return payments;
    } catch (e) {
      throw Exception('Failed to fetch payments: $e');
    }
  }

  Future<void> createPayment(Payment payment, String token) async {
    try {
      var data = payment.toJson();
      log('data: $data');
      await _dio.post('http://localhost:8080/api/v1/payments', data: data,
      options: Options(headers: {
          'Authorization': 'Bearer $token'}));
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  Future <List<Provider>> getAllProviders(String token) async {
    try {
      final response = await _dio.get('http://localhost:8080/api/v1/suppliers',
          options: Options(headers: {
          'Authorization': 'Bearer $token'}));
      final data = response.data as List<dynamic>;
      final suppliers = data.map((sup) => Provider.fromJson(sup)).toList();
      return suppliers;

    } catch (e) {
      throw Exception('Failed to fetch students: $e');
    } 
  }
}