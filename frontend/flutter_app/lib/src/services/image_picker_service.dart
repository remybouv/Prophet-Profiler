import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Service pour la sélection d'images (galerie ou caméra)
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Sélectionne une image depuis la galerie
  Future<File?> pickFromGallery() async {
    try {
      developer.log('📷 Sélection galerie...', name: 'ImagePickerService');
      
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        developer.log('✅ Image sélectionnée: ${pickedFile.path}', name: 'ImagePickerService');
        return File(pickedFile.path);
      }
      
      developer.log('⚠️ Aucune image sélectionnée', name: 'ImagePickerService');
      return null;
    } catch (e) {
      developer.log('❌ Erreur galerie: $e', name: 'ImagePickerService');
      throw Exception('Erreur lors de l\'accès à la galerie: $e');
    }
  }

  /// Prend une photo avec la caméra
  Future<File?> pickFromCamera() async {
    try {
      developer.log('📸 Ouverture caméra...', name: 'ImagePickerService');
      
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        developer.log('✅ Photo prise: ${pickedFile.path}', name: 'ImagePickerService');
        return File(pickedFile.path);
      }
      
      developer.log('⚠️ Aucune photo prise', name: 'ImagePickerService');
      return null;
    } catch (e) {
      developer.log('❌ Erreur caméra: $e', name: 'ImagePickerService');
      throw Exception('Erreur lors de l\'accès à la caméra: $e');
    }
  }

  /// Montre un dialog pour choisir entre galerie et caméra
  Future<File?> showPickerDialog(BuildContext context) async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter une photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Galerie'),
                subtitle: const Text('Choisir une photo existante'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('Caméra'),
                subtitle: const Text('Prendre une nouvelle photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );

    if (source == null) return null;

    if (source == ImageSource.gallery) {
      return await pickFromGallery();
    } else {
      return await pickFromCamera();
    }
  }
}
