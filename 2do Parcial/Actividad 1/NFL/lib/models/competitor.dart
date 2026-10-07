import 'team.dart';

class Competitor {
  final String id;
  final String homeAway;
  final bool winner;
  final Team team;
  final String score;
  final List<LineScore> linescores;
  final List<Record> records;

  Competitor({
    required this.id,
    required this.homeAway,
    required this.winner,
    required this.team,
    required this.score,
    required this.linescores,
    required this.records,
  });

  factory Competitor.fromJson(Map<String, dynamic> json) {
    return Competitor(
      id: json['id'] ?? '',
      homeAway: json['homeAway'] ?? '',
      winner: json['winner'] ?? false,
      team: Team.fromJson(json['team'] ?? {}),
      score: json['score'] ?? '0',
      linescores: (json['linescores'] as List<dynamic>? ?? [])
          .map((e) => LineScore.fromJson(e))
          .toList(),
      records: (json['records'] as List<dynamic>? ?? [])
          .map((e) => Record.fromJson(e))
          .toList(),
    );
  }

  String get overallRecord {
    try {
      return records.firstWhere((r) => r.type == 'total').summary;
    } catch (_) {
      return '';
    }
  }
}

class LineScore {
  final int period;
  final String displayValue;

  LineScore({required this.period, required this.displayValue});

  factory LineScore.fromJson(Map<String, dynamic> json) {
    return LineScore(
      period: json['period'] ?? 0,
      displayValue: json['displayValue'] ?? '0',
    );
  }
}

class Record {
  final String name;
  final String type;
  final String summary;

  Record({required this.name, required this.type, required this.summary});

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      summary: json['summary'] ?? '',
    );
  }
}