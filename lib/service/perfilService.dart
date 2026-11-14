import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class PerfilService {
  static final supabase = Supabase.instance.client;

  // Obtener perfil
  static Future<Map<String, dynamic>?> getPerfilUsuario(int authId) async {
    try {
     
      final perfil = await supabase
          .from('perfiles_estudiante')
          .select()
          .eq('auth_id', authId)
          .maybeSingle();
      return perfil;
    } catch (e) {
      return null;
    }
  }

  static  getIdPerfilUsuario(int authId) async {
    try {
     
      final perfil = await supabase
          .from('perfiles_estudiante')
          .select()
          .eq('auth_id', authId)
          .maybeSingle();
      int id =perfil!['id'];
      return id;
    } catch (e) {
      return null;
    }
  }

  // Actualizar perfil
  static Future<bool> actualizarPerfilUsuario({
    required int authId,
    required String nombres,
    required String apellidos,
    required String facultad,
    required String carrera,
    required String biografia,
    required String proyectoVida,
    required String urlCV,
    required String foto,
  }) async {
    try {
      final data = await supabase
          .from('perfiles_estudiante')
          .update({
            'nombres': nombres,
            'apellidos': apellidos,
            'facultad': facultad,
            'carrera': carrera,
            'biografia': biografia,
            'proyecto_vida': proyectoVida,
            'url_cv': urlCV,
            'foto': foto,
          })
          .eq('auth_id', authId)
          .select()
          .maybeSingle();
      return data != null;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> subirArchivo({required String bucket}) async {
    
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) {
      print("[LOG] No se seleccionó archivo");
      return null;
    }

    final file = result.files.first;

    try {
      // Leer bytes desde el path
      final fileBytes = await File(file.path!).readAsBytes();

      if (fileBytes.isEmpty) {
        print("[ERROR] fileBytes está vacío");
        return null;
      }

      // Subir al bucket
      print("[LOG] Subiendo archivo a bucket=$bucket, nombre=${file.name}");
      await supabase.storage.from(bucket).uploadBinary(
            file.name,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // Obtener URL pública
      final publicUrl = supabase.storage.from(bucket).getPublicUrl(file.name);
      print("[LOG] Archivo subido, publicUrl=$publicUrl");
      return publicUrl;
    } catch (e) {
      print("[ERROR] Error subiendo archivo: $e");
      return null;
    }
  }
}
