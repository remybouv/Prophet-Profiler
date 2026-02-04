// Configuration de l'application
// Le backend tourne sur https://localhost:49704 ou http://localhost:49705

class AppConfig {
  // URL de l'API - Changez cette valeur selon votre environnement
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:49705/api', // HTTP (pas de problème de certificat)
  );
  
  // Configurations selon la plateforme:
  // - Local web/desktop: 'http://localhost:49705/api'
  // - Android emulator: 'http://10.0.2.2:49705/api'  
  // - iOS simulator: 'http://localhost:49705/api'
  // - Appareil physique: 'http://192.168.1.X:49705/api' (IP de votre PC)
  
  static const bool enableLogs = true;
}
