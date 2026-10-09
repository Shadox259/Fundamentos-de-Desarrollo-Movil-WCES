import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../models/place_model.dart';
import '../services/places_service.dart';
import '../supabase_config.dart';
import '../theme.dart';

class PlaceFormScreen extends StatefulWidget {
  final PlaceModel? place;
  const PlaceFormScreen({super.key, this.place});

  @override
  State<PlaceFormScreen> createState() => _PlaceFormScreenState();
}

class _PlaceFormScreenState extends State<PlaceFormScreen> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _desc = TextEditingController();
  final _mapCtrl = MapController();

  String _categoria = 'otros';
  LatLng _punto = const LatLng(19.4326, -99.1332);
  XFile? _fotoNueva;
  Uint8List? _fotoBytes;
  String? _fotoUrlActual;
  bool _guardando = false;

  bool get _esEdicion => widget.place != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      final p = widget.place!;
      _nombre.text = p.name;
      _desc.text = p.description;
      _categoria = p.category;
      _punto = LatLng(p.latitude, p.longitude);
      _fotoUrlActual = p.photoUrl;
    } else {
      _centrarEnMiUbicacion();
    }
  }

  Future<void> _centrarEnMiUbicacion() async {
    try {
      final permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() => _punto = LatLng(pos.latitude, pos.longitude));
      _mapCtrl.move(_punto, 16);
    } catch (_) {}
  }

  Future<void> _elegirFoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1200,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _fotoNueva = picked;
        _fotoBytes = bytes;
      });
    }
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final uid = supabase.auth.currentUser!.id;

      String? urlFoto = _fotoUrlActual;
      if (_fotoNueva != null) {
        urlFoto = await PlacesService.uploadPhoto(_fotoNueva!);
      }

      final modelo = PlaceModel(
        id: _esEdicion ? widget.place!.id : '',
        userId: uid,
        name: _nombre.text.trim(),
        description: _desc.text.trim(),
        category: _categoria,
        latitude: _punto.latitude,
        longitude: _punto.longitude,
        photoUrl: urlFoto,
        createdAt:
            _esEdicion ? widget.place!.createdAt : DateTime.now(),
      );

      if (_esEdicion) {
        await PlacesService.update(modelo);
      } else {
        await PlacesService.create(modelo);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar lugar' : 'Nuevo lugar'),
      ),
      body: Form(
        key: _form,
        child: ListView(
          children: [
            // Selector de punto en el mapa
            SizedBox(
              height: 260,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapCtrl,
                    options: MapOptions(
                      initialCenter: _punto,
                      initialZoom: 15,
                      onTap: (_, latlng) => setState(() => _punto = latlng),
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
                            point: _punto,
                            width: 50,
                            height: 50,
                            child: const Icon(
                              Icons.location_pin,
                              size: 48,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Text(
                          'Toca el mapa para mover el pin\n'
                          '${_punto.latitude.toStringAsFixed(5)}, '
                          '${_punto.longitude.toStringAsFixed(5)}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: FloatingActionButton.small(
                      heroTag: 'centrar',
                      onPressed: _centrarEnMiUbicacion,
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Foto
                  GestureDetector(
                    onTap: _elegirFoto,
                    child: Container(
                      height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      image: _fotoBytes != null
                          ? DecorationImage(
                              image: MemoryImage(_fotoBytes!),
                              fit: BoxFit.cover,
                            )
                          : (_fotoUrlActual != null
                              ? DecorationImage(
                                  image: NetworkImage(_fotoUrlActual!),
                                  fit: BoxFit.cover,
                                )
                              : null),
                    ),
                    child: (_fotoBytes == null && _fotoUrlActual == null)
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 40),
                                SizedBox(height: 8),
                                Text('Añadir foto'),
                              ],
                            ),
                          )
                        : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nombre,
                    maxLength: 120,
                    decoration: const InputDecoration(
                      labelText: 'Nombre *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _desc,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _categoria,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                    items: CategoryHelper.all
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Row(
                              children: [
                                Icon(CategoryHelper.iconFor(c), size: 18),
                                const SizedBox(width: 8),
                                Text(c),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _categoria = v ?? 'otros'),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _guardando ? null : _guardar,
                      icon: _guardando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(_esEdicion ? 'Guardar cambios' : 'Crear'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}