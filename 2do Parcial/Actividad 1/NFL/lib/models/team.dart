class Team {
  final String id;
  final String location;
  final String name;
  final String abbreviation;
  final String displayName;
  final String shortDisplayName;
  final String color;
  final String alternateColor;
  final String logo;
  final String logoDark;

  Team({
    required this.id,
    required this.location,
    required this.name,
    required this.abbreviation,
    required this.displayName,
    required this.shortDisplayName,
    required this.color,
    required this.alternateColor,
    required this.logo,
    required this.logoDark,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? '',
      location: json['location'] ?? '',
      name: json['name'] ?? '',
      abbreviation: json['abbreviation'] ?? '',
      displayName: json['displayName'] ?? '',
      shortDisplayName: json['shortDisplayName'] ?? '',
      color: json['color'] ?? '000000',
      alternateColor: json['alternateColor'] ?? 'FFFFFF',
      logo: json['logo'] ?? '',
      logoDark: json['logoDark'] ?? '',
    );
  }
}