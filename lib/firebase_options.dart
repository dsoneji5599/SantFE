import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCJPUh14-WnZYLF3Vrl4TyNZpOesO8pqJE',
    appId: '1:362404631572:android:14f6f1583b12635fa7c301',
    messagingSenderId: '362404631572',
    projectId: 'sant-app-f9d25',
    storageBucket: 'sant-app-f9d25.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAsa4m2GZy4yaS1CujGWcm9LI6fBtOtRCI',
    appId: '1:362404631572:ios:c3a31333cb2c03fca7c301',
    messagingSenderId: '362404631572',
    projectId: 'sant-app-f9d25',
    storageBucket: 'sant-app-f9d25.firebasestorage.app',
    iosClientId: '362404631572-bsqfifdhuhm4ufvu4u2l4106lrn7doet.apps.googleusercontent.com',
    iosBundleId: 'com.app.sant',
  );

}