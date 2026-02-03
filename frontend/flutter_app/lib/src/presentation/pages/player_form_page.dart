import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prophet_profiler/src/presentation/blocs/players_bloc.dart';
import 'dart:developer' as developer;

class PlayerFormPage extends StatefulWidget {
  const PlayerFormPage({super.key});

  @override
  State<PlayerFormPage> createState() => _PlayerFormPageState();
}

class _PlayerFormPageState extends State<PlayerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  // Valeurs par défaut des axes = 3
  int _aggressivity = 3;
  int _patience = 3;
  int _analysis = 3;
  int _bluff = 3;
  
  String? _photoUrl;
  bool _isSubmitting = false;

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
        listener: (context, state) {
          if (state is PlayerCreated) {
            developer.log('✅ Joueur créé avec succès', name: 'PlayerFormPage');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Joueur créé avec succès !'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); // Retour avec succès
          } else if (state is PlayerCreateError) {
            developer.log('❌ Erreur création: ${state.message}', name: 'PlayerFormPage');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() => _isSubmitting = false);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Nouveau Joueur'),
              actions: [
                TextButton(
                  onPressed: _isSubmitting ? null : () => _submit(context),
                  child: _isSubmitting
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
            const Text(
              'Photo (optionnel)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                  child: _photoUrl == null
                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implémenter sélection galerie
                          developer.log('📷 Sélection photo non implémentée', name: 'PlayerFormPage');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sélection photo à implémenter')),
                          );
                        },
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galerie'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implémenter caméra
                          developer.log('📸 Caméra non implémentée', name: 'PlayerFormPage');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Caméra à implémenter')),
                          );
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Caméra'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
      onPressed: _isSubmitting ? null : () => _submit(context),
      icon: _isSubmitting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.save),
      label: Text(_isSubmitting ? 'Création...' : 'Créer le joueur'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      
      developer.log('📝 Soumission formulaire: ${_nameController.text.trim()}', name: 'PlayerFormPage');
      
      context.read<PlayersBloc>().add(CreatePlayer(
        name: _nameController.text.trim(),
        photoUrl: _photoUrl,
        aggressivity: _aggressivity,
        patience: _patience,
        analysis: _analysis,
        bluff: _bluff,
      ));
    }
  }
}
