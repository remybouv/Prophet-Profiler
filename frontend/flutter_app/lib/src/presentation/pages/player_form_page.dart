import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prophet_profiler/src/presentation/blocs/players_bloc.dart';
import 'package:prophet_profiler/src/services/image_picker_service.dart';

class PlayerFormPage extends StatefulWidget {
  const PlayerFormPage({super.key});

  @override
  State<PlayerFormPage> createState() => _PlayerFormPageState();
}

class _PlayerFormPageState extends State<PlayerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imagePickerService = ImagePickerService();
  
  // Valeurs par défaut des axes = 3
  int _aggressivity = 3;
  int _patience = 3;
  int _analysis = 3;
  int _bluff = 3;
  
  File? _photoFile;
  bool _isSubmitting = false;
  bool _isUploadingPhoto = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlayersBloc(),
      child: BlocConsumer<PlayersBloc, PlayersState>(
        listener: (context, state) async {
          if (state is PlayerCreated) {
            developer.log('✅ Joueur créé: ${state.player.id}', name: 'PlayerFormPage');
            
            // Upload photo si sélectionnée
            if (_photoFile != null) {
              setState(() => _isUploadingPhoto = true);
              try {
                await context.read<PlayersBloc>().uploadPlayerPhoto(
                  state.player.id,
                  _photoFile!,
                );
                developer.log('✅ Photo uploadée', name: 'PlayerFormPage');
              } catch (e) {
                developer.log('❌ Erreur upload photo: $e', name: 'PlayerFormPage');
                // On continue même si l'upload échoue
              }
              setState(() => _isUploadingPhoto = false);
            }
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Joueur créé avec succès !'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true);
            }
          } else if (state is PlayerCreateError) {
            developer.log('❌ Erreur création: ${state.message}', name: 'PlayerFormPage');
            setState(() => _isSubmitting = false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Nouveau Joueur'),
              actions: [
                TextButton(
                  onPressed: (_isSubmitting || _isUploadingPhoto) ? null : () => _submit(context),
                  child: (_isSubmitting || _isUploadingPhoto)
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('ENREGISTRER'),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildNameField(),
                    const SizedBox(height: 24),
                    _buildPhotoSection(),
                    const SizedBox(height: 32),
                    _buildProfileSection(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Nom du joueur *',
        hintText: 'Entrez le nom (2-50 caractères)',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Le nom est obligatoire';
        }
        if (value.trim().length < 2) {
          return 'Le nom doit faire au moins 2 caractères';
        }
        if (value.trim().length > 50) {
          return 'Le nom ne doit pas dépasser 50 caractères';
        }
        return null;
      },
    );
  }

  Widget _buildPhotoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Photo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_photoFile != null)
                  TextButton.icon(
                    onPressed: () => setState(() => _photoFile = null),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Supprimer'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _photoFile != null 
                        ? FileImage(_photoFile!) 
                        : null,
                    child: _photoFile == null
                        ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                        : null,
                  ),
                  if (_isUploadingPhoto)
                    Positioned.fill(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.black54,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: Colors.white),
                            const SizedBox(height: 8),
                            Text(
                              'Upload...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: FloatingActionButton.small(
                      onPressed: _isUploadingPhoto ? null : _pickImage,
                      child: const Icon(Icons.camera_alt),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: _isUploadingPhoto ? null : _pickImage,
                icon: const Icon(Icons.add_photo_alternate),
                label: Text(_photoFile == null ? 'Ajouter une photo' : 'Changer la photo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final file = await _imagePickerService.showPickerDialog(context);
      if (file != null) {
        setState(() => _photoFile = file);
        developer.log('📷 Photo sélectionnée: ${file.path}', name: 'PlayerFormPage');
      }
    } catch (e) {
      developer.log('❌ Erreur sélection photo: $e', name: 'PlayerFormPage');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Widget _buildProfileSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profil du joueur',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Notez chaque axe de 1 à 5 (défaut: 3)',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildAxisSlider('Agressivité', _aggressivity, Icons.local_fire_department, Colors.red, (v) => setState(() => _aggressivity = v)),
            _buildAxisSlider('Patience', _patience, Icons.timer, Colors.blue, (v) => setState(() => _patience = v)),
            _buildAxisSlider('Analyse', _analysis, Icons.psychology, Colors.green, (v) => setState(() => _analysis = v)),
            _buildAxisSlider('Bluff', _bluff, Icons.visibility_off, Colors.purple, (v) => setState(() => _bluff = v)),
          ],
        ),
      ),
    );
  }

  Widget _buildAxisSlider(
    String label,
    int value,
    IconData icon,
    Color color,
    Function(int) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$value',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: '$value',
          activeColor: color,
          onChanged: (v) => onChanged(v.round()),
        ),
        const Divider(height: 8),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: (_isSubmitting || _isUploadingPhoto) ? null : () => _submit(context),
      icon: (_isSubmitting || _isUploadingPhoto)
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.save),
      label: Text(_isSubmitting 
          ? 'Création...' 
          : _isUploadingPhoto 
              ? 'Upload photo...' 
              : 'Créer le joueur'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      
      developer.log('📝 Création joueur: ${_nameController.text.trim()}', name: 'PlayerFormPage');
      
      context.read<PlayersBloc>().add(CreatePlayer(
        name: _nameController.text.trim(),
        photoUrl: null, // Sera mis à jour après upload
        aggressivity: _aggressivity,
        patience: _patience,
        analysis: _analysis,
        bluff: _bluff,
      ));
    }
  }
}
