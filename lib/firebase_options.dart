import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

// Configuración de Firebase para Web (FlutLab) y Android (proyecto obam-app).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => kIsWeb ? web : android;

  // Client ID web usado por google_sign_in en Android para obtener el idToken.
  static const String googleWebClientId =
      '807369576265-594617ht1osfott34us5c7i9b71k7k02.apps.googleusercontent.com';

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDZeZE4DjD4RYeJGmvacJE1SmWOIWryW_M',
    appId: '1:807369576265:web:e75cd4028d525148b79498',
    messagingSenderId: '807369576265',
    projectId: 'obam-app',
    authDomain: 'obam-app.firebaseapp.com',
    storageBucket: 'obam-app.firebasestorage.app',
    measurementId: 'G-HYMHW2ESKK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCLmMcaab8nHTkgAtwCCdj_FFP_qaXEmMw',
    appId: '1:807369576265:android:e6d24b9f2693dc11b79498',
    messagingSenderId: '807369576265',
    projectId: 'obam-app',
    storageBucket: 'obam-app.firebasestorage.app',
  );
}
