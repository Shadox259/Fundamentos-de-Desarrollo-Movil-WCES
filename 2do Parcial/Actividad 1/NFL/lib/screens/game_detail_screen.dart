import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../widgets/team_logo.dart';

class GameDetailScreen extends StatelessWidget {
  final Event event;

  const GameDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final comp = event.competition;
    final home = comp.homeTeam;
    final away = comp.awayTeam;
    final status = comp.status;

    return Scaffold(
      appBar: AppBar(
        title: Text(event.shortName),
        backgroundColor: const Color(0xFF013369),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: status.isLive
                    ? Colors.red
                    : status.isFinal
                        ? Colors.grey[700]
                        : Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status.isLive
                    ? 'EN VIVO · ${status.type.shortDetail}'
                    : status.type.detail,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: _teamColumn(away, status)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '@',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(child: _teamColumn(home, status)),
              ],
            ),
            const SizedBox(height: 24),

            if (status.isLive || status.isFinal) _linescoreTable(away, home),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información del partido',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _infoRow(Icons.calendar_today,
                        DateFormat('EEEE d MMMM, yyyy · HH:mm', 'es')
                            .format(event.dateTime)),
                    _infoRow(Icons.location_on, comp.venue.fullName),
                    _infoRow(Icons.place, comp.venue.fullAddress),
                    if (comp.attendance > 0)
                      _infoRow(Icons.people, 'Asistencia: ${comp.attendance}'),
                    if (comp.broadcast != null)
                      _infoRow(Icons.tv, comp.broadcast!),
                    _infoRow(
                      comp.venue.indoor ? Icons.home : Icons.park,
                      comp.venue.indoor ? 'Estadio techado' : 'Estadio abierto',
                    ),
                  ],
                ),
              ),
            ),

            if (comp.headlines.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      ...comp.headlines.map(
                        (h) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            h.shortLinkText ?? h.description ?? '',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _teamColumn(dynamic team, dynamic status) {
    return Column(
      children: [
        TeamLogo(url: team.team.logo, size: 80),
        const SizedBox(height: 8),
        Text(
          team.team.shortDisplayName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          team.overallRecord,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        if (status.isLive || status.isFinal)
          Text(
            team.score,
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: team.winner ? Colors.green[700] : Colors.black87,
            ),
          ),
      ],
    );
  }

  Widget _linescoreTable(dynamic away, dynamic home) {
    final periods = [1, 2, 3, 4];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(1),
            5: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[200]),
              children: [
                const Padding(
                  padding: EdgeInsets.all(6),
                  child: Text('Equipo',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ...periods.map((p) => Padding(
                      padding: const EdgeInsets.all(6),
                      child: Text('Q$p',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    )),
                const Padding(
                  padding: EdgeInsets.all(6),
                  child: Text('T',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            _teamRow(away),
            _teamRow(home),
          ],
        ),
      ),
    );
  }

  TableRow _teamRow(dynamic team) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(team.team.abbreviation),
        ),
        ...List.generate(4, (i) {
          final ls = team.linescores.where((l) => l.period == i + 1);
          return Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              ls.isNotEmpty ? ls.first.displayValue : '-',
              textAlign: TextAlign.center,
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            team.score,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}