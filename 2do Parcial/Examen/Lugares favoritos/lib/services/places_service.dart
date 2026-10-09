import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/place_model.dart';
import '../supabase_config.dart';

class PlacesService {
  static Future<List<PlaceModel>> fetchMyPlaces() async {
    final uid = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('places')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => PlaceModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<PlaceModel> create(PlaceModel p) async {
    final data = await supabase
        .from('places')
        .insert(p.toMap())
        .select()
        .single();
    return PlaceModel.fromMap(Map<String, dynamic>.from(data));
  }

  static Future<void> update(PlaceModel p) async {
    await supabase.from('places').update(p.toMap()).eq('id', p.id);
  }

  static Future<void> delete(String id) async {
    await supabase.from('places').delete().eq('id', id);
  }

  static Future<String> uploadPhoto(XFile file) async {
    final uid = supabase.auth.currentUser!.id;
    final extension = file.name.contains('.')
        ? file.name.split('.').last.toLowerCase()
        : 'jpg';

    final fileName = '${const Uuid().v4()}.$extension';
    final path = '$uid/$fileName';
    final Uint8List bytes = await file.readAsBytes();

    await supabase.storage.from('place-photos').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: _mimeFromExtension(extension),
            upsert: false,
          ),
        );

    return supabase.storage.from('place-photos').getPublicUrl(path);
  }

  static String _mimeFromExtension(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }
}