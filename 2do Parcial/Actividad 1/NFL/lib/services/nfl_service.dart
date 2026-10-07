import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class NflService {
  static const String apiUrl =
      'https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard';

  Future<List<Event>> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final events = (data['events'] as List<dynamic>? ?? [])
            .map((e) => Event.fromJson(e))
            .toList();
        return events;
      } else {
        throw Exception('Error al cargar los partidos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  List<Event> parseEventsFromString(String jsonString) {
    final data = json.decode(jsonString);
    return (data['events'] as List<dynamic>? ?? [])
        .map((e) => Event.fromJson(e))
        .toList();
  }
}