import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import 'team_logo.dart';

class GameCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const GameCard({super.key, required this.event, this.onTap});

  Color _hexColor(String hex, {Color fallback = Colors.grey}) {
    try {
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final comp = event.competition;
    final home = comp.homeTeam;
    final away = comp.awayTeam;
    final status = comp.status;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statusChip(status, context),
                  Text(
                    _formatDate(event.dateTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _teamRow(away, isWinner: away.winner, status: status),
              const SizedBox(height: 8),
              _teamRow(home, isWinner: home.winner, status: status),

              const Divider(height: 20),

              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${comp.venue.fullName} · ${comp.venue.fullAddress}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (comp.broadcast != null && comp.broadcast!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.tv, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      comp.broadcast!,
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamRow(dynamic team, {required bool isWinner, required dynamic status}) {
    final bool showScore = status.isLive || status.isFinal;
    return Row(
      children: [
        TeamLogo(url: team.team.logo, size: 36),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                team.team.displayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isWinner ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                team.overallRecord,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        if (showScore)
          Text(
            team.score,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isWinner ? Colors.green[700] : Colors.black87,
            ),
          ),
      ],
    );
  }

  Widget _statusChip(dynamic status, BuildContext context) {
    Color color;
    String text;
    IconData icon;

    if (status.isLive) {
      color = Colors.red;
      text = 'EN VIVO · ${status.type.shortDetail}';
      icon = Icons.fiber_manual_record;
    } else if (status.isFinal) {
      color = Colors.grey[700]!;
      text = 'FINAL';
      icon = Icons.check_circle;
    } else {
      color = Colors.blue;
      text = status.type.shortDetail;
      icon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now).inDays;

    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'HOY · ${DateFormat('HH:mm').format(dt)}';
    } else if (diff == 1) {
      return 'MAÑANA · ${DateFormat('HH:mm').format(dt)}';
    } else if (diff == -1) {
      return 'AYER · ${DateFormat('HH:mm').format(dt)}';
    }
    return DateFormat('EEE d MMM · HH:mm', 'es').format(dt);
  }
}