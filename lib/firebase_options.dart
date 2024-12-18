// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDhKhwMaHBoFpCF6oIJDrmvQC5-Ea9cYqo',
    appId: '1:813107115564:web:057bd7d065b657387b0389',
    messagingSenderId: '813107115564',
    projectId: 'proyeksregep',
    authDomain: 'proyeksregep.firebaseapp.com',
    storageBucket: 'proyeksregep.appspot.com',
    measurementId: 'G-2VFMCLZK2X',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDWZ713sQPWBuxuMUdNaymQMK8rBEGeqEY',
    appId: '1:813107115564:android:fbf9ea591680d8eb7b0389',
    messagingSenderId: '813107115564',
    projectId: 'proyeksregep',
    storageBucket: 'proyeksregep.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDv_cTlAadKr_W4dLlLz-Z9rfL1M_JKBTM',
    appId: '1:813107115564:ios:1494668f9763ac727b0389',
    messagingSenderId: '813107115564',
    projectId: 'proyeksregep',
    storageBucket: 'proyeksregep.appspot.com',
    iosBundleId: 'com.example.proyeksregep',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDv_cTlAadKr_W4dLlLz-Z9rfL1M_JKBTM',
    appId: '1:813107115564:ios:1494668f9763ac727b0389',
    messagingSenderId: '813107115564',
    projectId: 'proyeksregep',
    storageBucket: 'proyeksregep.appspot.com',
    iosBundleId: 'com.example.proyeksregep',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDhKhwMaHBoFpCF6oIJDrmvQC5-Ea9cYqo',
    appId: '1:813107115564:web:563be065fa26c2fc7b0389',
    messagingSenderId: '813107115564',
    projectId: 'proyeksregep',
    authDomain: 'proyeksregep.firebaseapp.com',
    storageBucket: 'proyeksregep.appspot.com',
    measurementId: 'G-QK75DCHFE6',
  );
}
