import 'competition.dart';

class Event {
  final String id;
  final String uid;
  final String date;
  final String name;
  final String shortName;
  final int week;
  final Competition competition;

  Event({
    required this.id,
    required this.uid,
    required this.date,
    required this.name,
    required this.shortName,
    required this.week,
    required this.competition,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final competitions = json['competitions'] as List<dynamic>? ?? [];
    return Event(
      id: json['id'] ?? '',
      uid: json['uid'] ?? '',
      date: json['date'] ?? '',
      name: json['name'] ?? '',
      shortName: json['shortName'] ?? '',
      week: json['week']?['number'] ?? 0,
      competition: competitions.isNotEmpty
          ? Competition.fromJson(competitions.first)
          : Competition.fromJson({}),
    );
  }

  DateTime get dateTime => DateTime.parse(date).toLocal();
}