import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/place_model.dart';
import '../services/places_service.dart';
import '../theme.dart';
import 'place_form_screen.dart';

class PlaceDetailScreen extends StatelessWidget {
  final PlaceModel place;
  const PlaceDetailScreen({super.key, required this.place});

  Future<void> _editar(BuildContext context) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PlaceFormScreen(place: place)),
    );
    if (ok == true && context.mounted) Navigator.pop(context, true);
  }

  Future<void> _eliminar(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar lugar'),
        content: Text('¿Eliminar "${place.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await PlacesService.delete(place.id);
    if (context.mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editar(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _eliminar(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          if (place.photoUrl != null)
            Image.network(
              place.photoUrl!,
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 240,
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image, size: 80),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(CategoryHelper.iconFor(place.category)),
                    const SizedBox(width: 8),
                    Chip(label: Text(place.category)),
                  ],
                ),
                const SizedBox(height: 12),
                if (place.description.isNotEmpty)
                  Text(place.description, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                Text(
                  'Coordenadas: ${place.latitude.toStringAsFixed(5)}, ${place.longitude.toStringAsFixed(5)}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter:
                            LatLng(place.latitude, place.longitude),
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.lugares_app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(place.latitude, place.longitude),
                              width: 40,
                              height: 40,
                              child: Icon(
                                CategoryHelper.iconFor(place.category),
                                size: 40,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}