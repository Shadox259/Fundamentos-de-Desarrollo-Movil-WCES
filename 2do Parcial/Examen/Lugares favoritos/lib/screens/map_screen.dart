import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../models/place_model.dart';
import '../theme.dart';
import 'place_detail_screen.dart';

class MapScreen extends StatefulWidget {
  final List<PlaceModel> places;
  final VoidCallback onChanged;

  const MapScreen({
    super.key,
    required this.places,
    required this.onChanged,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapCtrl = MapController();
  LatLng? _miUbicacion;
  bool _cargandoUbicacion = true;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacion();
  }

  Future<void> _obtenerUbicacion() async {
    try {
      final permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _miUbicacion = LatLng(pos.latitude, pos.longitude);
        _cargandoUbicacion = false;
      });
    } catch (_) {
      setState(() => _cargandoUbicacion = false);
    }
  }

  void _irAMiUbicacion() {
    if (_miUbicacion != null) {
      _mapCtrl.move(_miUbicacion!, 15);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener tu ubicación')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final centroInicial = widget.places.isNotEmpty
        ? LatLng(widget.places.first.latitude, widget.places.first.longitude)
        : const LatLng(19.4326, -99.1332);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapCtrl,
          options: MapOptions(
            initialCenter: _miUbicacion ?? centroInicial,
            initialZoom: 13,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.lugares_app',
            ),
            MarkerLayer(
              markers: widget.places
                  .map(
                    (p) => Marker(
                      point: LatLng(p.latitude, p.longitude),
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () async {
                          final cambio = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlaceDetailScreen(place: p),
                            ),
                          );
                          if (cambio == true) widget.onChanged();
                        },
                        child: Icon(
                          CategoryHelper.iconFor(p.category),
                          size: 40,
                          color: Colors.deepPurple,
                          shadows: const [
                            Shadow(color: Colors.white, blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            // Mi ubicación
            if (_miUbicacion != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _miUbicacion!,
                    width: 24,
                    height: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        if (_cargandoUbicacion)
          const Positioned(
            top: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: 'zoomIn',
                onPressed: () =>
                    _mapCtrl.move(_mapCtrl.camera.center, _mapCtrl.camera.zoom + 1),
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'zoomOut',
                onPressed: () =>
                    _mapCtrl.move(_mapCtrl.camera.center, _mapCtrl.camera.zoom - 1),
                child: const Icon(Icons.remove),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'miUbicacion',
                onPressed: _irAMiUbicacion,
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
      ],
    );
  }
}