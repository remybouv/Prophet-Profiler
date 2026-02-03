// Configuration de l'application
// Pour tester sur mobile physique, remplacez par l'IP de votre machine
// Exemple: const String apiBaseUrl = 'http://192.168.1.100:5000/api';

class AppConfig {
  // URL de l'API - Changez cette valeur selon votre environnement
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:5000/api', // Android emulator localhost
  );
  
  // Pour iOS simulator: 'http://localhost:5000/api'
  // Pour Android emulator: 'http://10.0.2.2:5000/api'
  // Pour appareil physique: remplacez par l'IP locale de votre PC
  
  static const bool enableLogs = true;
}
