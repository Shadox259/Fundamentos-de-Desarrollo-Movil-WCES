import 'dart:io';
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

  static Future<String> uploadPhoto(File file) async {
    final uid = supabase.auth.currentUser!.id;
    final ext = file.path.split('.').last;
    final fileName = '${const Uuid().v4()}.$ext';
    final path = '$uid/$fileName';

    await supabase.storage.from('place-photos').upload(path, file);

    return supabase.storage.from('place-photos').getPublicUrl(path);
  }
}