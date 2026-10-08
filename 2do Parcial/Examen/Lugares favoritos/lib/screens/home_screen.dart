import 'package:flutter/material.dart';
import '../services/places_service.dart';
import '../models/place_model.dart';
import 'map_screen.dart';
import 'place_form_screen.dart';
import 'place_detail_screen.dart';
import 'profile_screen.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const HomeScreen({super.key, required this.onToggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  List<PlaceModel> _places = [];
  List<PlaceModel> _filtrados = [];
  bool _loading = true;
  String _busqueda = '';
  String? _categoria;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final data = await PlacesService.fetchMyPlaces();
      setState(() {
        _places = data;
        _aplicarFiltros();
      });
    } catch (e) {
      _snack('Error al cargar: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _aplicarFiltros() {
    _filtrados = _places.where((p) {
      final coincideNombre = _busqueda.isEmpty ||
          p.name.toLowerCase().contains(_busqueda.toLowerCase());
      final coincideCat = _categoria == null || p.category == _categoria;
      return coincideNombre && coincideCat;
    }).toList();
  }

  void _snack(String m, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m),
        backgroundColor: error ? Colors.red : null,
      ),
    );
  }

  Future<void> _abrirFormulario({PlaceModel? place}) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PlaceFormScreen(place: place)),
    );
    if (ok == true) _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _buildLista(),
      MapScreen(places: _places, onChanged: _cargar),
      ProfileScreen(onToggleTheme: widget.onToggleTheme),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(_tab == 0
            ? 'Mis lugares (${_places.length})'
            : _tab == 1
                ? 'Mapa'
                : 'Perfil'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: tabs[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list), label: 'Lista'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Mapa'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: () => _abrirFormulario(),
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Agregar'),
            )
          : null,
    );
  }

  Widget _buildLista() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() {
                  _busqueda = v;
                  _aplicarFiltros();
                }),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    FilterChip(
                      label: const Text('Todas'),
                      selected: _categoria == null,
                      onSelected: (_) => setState(() {
                        _categoria = null;
                        _aplicarFiltros();
                      }),
                    ),
                    const SizedBox(width: 6),
                    ...CategoryHelper.all.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          avatar: Icon(CategoryHelper.iconFor(c), size: 16),
                          label: Text(c),
                          selected: _categoria == c,
                          onSelected: (_) => setState(() {
                            _categoria = _categoria == c ? null : c;
                            _aplicarFiltros();
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _filtrados.isEmpty
              ? const Center(
                  child: Text('No hay lugares que coincidan.'),
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.builder(
                    itemCount: _filtrados.length,
                    itemBuilder: (_, i) {
                      final p = _filtrados[i];
                      return Card(
                        child: ListTile(
                          leading: p.photoUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    p.photoUrl!,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                        CategoryHelper.iconFor(p.category),
                                        size: 40),
                                  ),
                                )
                              : CircleAvatar(
                                  child: Icon(
                                      CategoryHelper.iconFor(p.category)),
                                ),
                          title: Text(p.name),
                          subtitle: Text(
                            p.description.isEmpty
                                ? p.category
                                : '${p.category} · ${p.description}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final cambio = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PlaceDetailScreen(place: p),
                              ),
                            );
                            if (cambio == true) _cargar();
                          },
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}