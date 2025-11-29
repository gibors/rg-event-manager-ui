import 'package:rg_event_management_ui/models/Student.dart';

class StudentSearchDto {

  Student student;
  int eventId;
  String eventName;
  String school;
  DateTime eventDate;

  StudentSearchDto({
    required this.student,
    required this.eventId,
    required this.eventName,
    required this.school,
    required this.eventDate,
  });
  
  Map<String, dynamic> toJson() => {
        'student': student.toJson(),
        'eventId': eventId,
        'eventName': eventName,
        'school': school,
        'eventDate': eventDate.toLocal().toIso8601String(),
      };

    factory StudentSearchDto.fromJson(Map<String, dynamic> json) {
      return StudentSearchDto(
        student: Student.fromJson(json['student']),
        eventId: json['eventId'],
        eventName: json['eventName'],
        school: json['school'],
        eventDate: DateTime.parse(json['eventDate']),
      );
    }
}