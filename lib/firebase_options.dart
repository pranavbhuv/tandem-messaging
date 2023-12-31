// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyD9PBhON7R2Qxezj61wTC5spMUlEM2IbWQ',
    appId: '1:216291031442:web:7edc330ef9ea3d8ed0a94b',
    messagingSenderId: '216291031442',
    projectId: 'tandem-messaging',
    authDomain: 'tandem-messaging.firebaseapp.com',
    databaseURL: 'https://tandem-messaging-default-rtdb.firebaseio.com',
    storageBucket: 'tandem-messaging.appspot.com',
    measurementId: 'G-YJVB9VWX5Z',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCEJ_0CETXpHmSBt5Mx8bzq09Fb_939qhI',
    appId: '1:216291031442:android:76bf7ad82cf0bb86d0a94b',
    messagingSenderId: '216291031442',
    projectId: 'tandem-messaging',
    databaseURL: 'https://tandem-messaging-default-rtdb.firebaseio.com',
    storageBucket: 'tandem-messaging.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD5_KMIIGF7l-Ypuf7xkqNsNqDehPrp32s',
    appId: '1:216291031442:ios:e375a9994c12cf47d0a94b',
    messagingSenderId: '216291031442',
    projectId: 'tandem-messaging',
    databaseURL: 'https://tandem-messaging-default-rtdb.firebaseio.com',
    storageBucket: 'tandem-messaging.appspot.com',
    iosBundleId: 'com.pranavb.tandemorg.tandem',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD5_KMIIGF7l-Ypuf7xkqNsNqDehPrp32s',
    appId: '1:216291031442:ios:b59f4158e37e324bd0a94b',
    messagingSenderId: '216291031442',
    projectId: 'tandem-messaging',
    databaseURL: 'https://tandem-messaging-default-rtdb.firebaseio.com',
    storageBucket: 'tandem-messaging.appspot.com',
    iosBundleId: 'com.pranavb.tandemorg.tandem.RunnerTests',
  );
}
