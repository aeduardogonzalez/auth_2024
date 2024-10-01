import 'package:auth_2024/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase dependiendo de si es web o no
  // if (GetPlatform.isWeb) {
  //   await Firebase.initializeApp(
  //     options: const FirebaseOptions(
  //         apiKey: "AIzaSyCw1YDJ8hL9woIA3qMC0UhOTMeTg_wn45A",
  //         authDomain: "observatorio-56505.firebaseapp.com",
  //         projectId: "observatorio-56505",
  //         storageBucket: "observatorio-56505.appspot.com",
  //         messagingSenderId: "449702727144",
  //         appId: "1:449702727144:web:e48dec1d6583662c1c285d",
  //         measurementId: "G-MBDFJEVGDN"),
  //   );
  // } else {
  //   await Firebase.initializeApp();
  // }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Authenticaion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}
