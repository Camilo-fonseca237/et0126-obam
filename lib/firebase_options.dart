import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

// Configuración de Firebase para Web (proyecto obam-app).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => web;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDZeZE4DjD4RYeJGmvacJE1SmWOIWryW_M',
    appId: '1:807369576265:web:e75cd4028d525148b79498',
    messagingSenderId: '807369576265',
    projectId: 'obam-app',
    authDomain: 'obam-app.firebaseapp.com',
    storageBucket: 'obam-app.firebasestorage.app',
    measurementId: 'G-HYMHW2ESKK',
  );
}
