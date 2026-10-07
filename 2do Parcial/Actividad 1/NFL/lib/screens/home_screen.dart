import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/nfl_service.dart';
import '../widgets/game_card.dart';
import 'game_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final NflService _service = NflService();
  late TabController _tabController;

  List<Event> _allEvents = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final events = await _service.fetchEvents();
      setState(() {
        _allEvents = events;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Event> get _liveEvents =>
      _allEvents.where((e) => e.competition.status.isLive).toList();

  List<Event> get _upcomingEvents =>
      _allEvents.where((e) => e.competition.status.isPre).toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  List<Event> get _finishedEvents =>
      _allEvents.where((e) => e.competition.status.isFinal).toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFL Scoreboard'),
        backgroundColor: const Color(0xFF013369),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'En Vivo'),
            Tab(text: 'Próximos'),
            Tab(text: 'Finalizados'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _errorView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _eventsList(_allEvents),
                    _eventsList(_liveEvents, emptyMsg: 'No hay partidos en vivo'),
                    _eventsList(_upcomingEvents,
                        emptyMsg: 'No hay partidos próximos'),
                    _eventsList(_finishedEvents,
                        emptyMsg: 'No hay partidos finalizados'),
                  ],
                ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error al cargar partidos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadEvents,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _eventsList(List<Event> events, {String emptyMsg = 'No hay partidos'}) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_football, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              emptyMsg,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return GameCard(
            event: event,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GameDetailScreen(event: event),
                ),
              );
            },
          );
        },
      ),
    );
  }
}