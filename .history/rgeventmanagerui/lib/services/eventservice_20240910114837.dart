import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:rg_event_management_ui/models/Event.dart';

class EventService {
  final Dio _dio;

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

  Future<void> updateEvent(Event event) async {
    try {
      await _dio.put('https://api.example.com/events/${event.id}', data: event.toJson());
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  Future<void> deleteEvent(int id) async {
    try {
      await _dio.delete('https://api.example.com/events/$id');
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }
}

