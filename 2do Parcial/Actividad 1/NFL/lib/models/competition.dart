import 'competitor.dart';

class Competition {
  final String id;
  final String date;
  final int attendance;
  final bool neutralSite;
  final Venue venue;
  final List<Competitor> competitors;
  final Status status;
  final List<Broadcast> broadcasts;
  final String? broadcast;
  final List<Headline> headlines;

  Competition({
    required this.id,
    required this.date,
    required this.attendance,
    required this.neutralSite,
    required this.venue,
    required this.competitors,
    required this.status,
    required this.broadcasts,
    this.broadcast,
    required this.headlines,
  });

  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      attendance: json['attendance'] ?? 0,
      neutralSite: json['neutralSite'] ?? false,
      venue: Venue.fromJson(json['venue'] ?? {}),
      competitors: (json['competitors'] as List<dynamic>? ?? [])
          .map((e) => Competitor.fromJson(e))
          .toList(),
      status: Status.fromJson(json['status'] ?? {}),
      broadcasts: (json['broadcasts'] as List<dynamic>? ?? [])
          .map((e) => Broadcast.fromJson(e))
          .toList(),
      broadcast: json['broadcast'],
      headlines: (json['headlines'] as List<dynamic>? ?? [])
          .map((e) => Headline.fromJson(e))
          .toList(),
    );
  }

  Competitor get homeTeam =>
      competitors.firstWhere((c) => c.homeAway == 'home');
  Competitor get awayTeam =>
      competitors.firstWhere((c) => c.homeAway == 'away');
}

class Venue {
  final String id;
  final String fullName;
  final String city;
  final String? state;
  final String country;
  final bool indoor;

  Venue({
    required this.id,
    required this.fullName,
    required this.city,
    this.state,
    required this.country,
    required this.indoor,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    final address = json['address'] ?? {};
    return Venue(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      city: address['city'] ?? '',
      state: address['state'],
      country: address['country'] ?? '',
      indoor: json['indoor'] ?? false,
    );
  }

  String get fullAddress {
    if (state != null && state!.isNotEmpty) {
      return '$city, $state';
    }
    return city;
  }
}

class Status {
  final int clock;
  final String displayClock;
  final int period;
  final StatusType type;

  Status({
    required this.clock,
    required this.displayClock,
    required this.period,
    required this.type,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      clock: json['clock'] ?? 0,
      displayClock: json['displayClock'] ?? '0:00',
      period: json['period'] ?? 0,
      type: StatusType.fromJson(json['type'] ?? {}),
    );
  }

  bool get isLive => type.state == 'in';
  bool get isFinal => type.state == 'post';
  bool get isPre => type.state == 'pre';
}

class StatusType {
  final String id;
  final String name;
  final String state;
  final bool completed;
  final String description;
  final String detail;
  final String shortDetail;

  StatusType({
    required this.id,
    required this.name,
    required this.state,
    required this.completed,
    required this.description,
    required this.detail,
    required this.shortDetail,
  });

  factory StatusType.fromJson(Map<String, dynamic> json) {
    return StatusType(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      state: json['state'] ?? '',
      completed: json['completed'] ?? false,
      description: json['description'] ?? '',
      detail: json['detail'] ?? '',
      shortDetail: json['shortDetail'] ?? '',
    );
  }
}

class Broadcast {
  final String market;
  final List<String> names;

  Broadcast({required this.market, required this.names});

  factory Broadcast.fromJson(Map<String, dynamic> json) {
    return Broadcast(
      market: json['market'] ?? '',
      names: (json['names'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class Headline {
  final String type;
  final String? description;
  final String? shortLinkText;

  Headline({required this.type, this.description, this.shortLinkText});

  factory Headline.fromJson(Map<String, dynamic> json) {
    return Headline(
      type: json['type'] ?? '',
      description: json['description'],
      shortLinkText: json['shortLinkText'],
    );
  }
}