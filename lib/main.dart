import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pass_mgr/utils/auth.dart';

import 'screens/auth_page.dart';
import 'screens/home.dart';

void main() async {
  await Hive.initFlutter();
  await setupSecuredStorage();
  AuthService auth = AuthService();
  final bool isAuthed = await auth.checkAuthed();
  runApp(MyApp(isAuthed: isAuthed));
}

Future<void> setupSecuredStorage() async {
  const FlutterSecureStorage st = FlutterSecureStorage();

  var containsEncryptionKey = await st.containsKey(key: "hiveKey");
  String? keyBase64;

  if (!containsEncryptionKey) {
    var key = Hive.generateSecureKey();
    print("at main: contains key");
    print("at main: hive generated key: $key");
    try {
      print("Attempting to write key to storage");
      await st.write(
        key: 'hiveKey',
        value: base64UrlEncode(key),
      );

      print("Successfully wrote key to storage");
      var myKey = await st.read(key: "hiveKey");
      print("key: $myKey");
    } catch (e) {
      print("Failed to write key to storage: $e");
    }
    keyBase64 = base64UrlEncode(key);
  } else {
    print("at main: not contain key");
    keyBase64 = await st.read(key: "hiveKey");
  }

  print("at main: encryption key: $keyBase64");

  if (keyBase64 == null) {
    throw Exception(
        'Failed to retrieve the encryption key from secure storage.');
  }
}

class MyApp extends StatelessWidget {
  bool isAuthed;

  MyApp({
    super.key,
    this.isAuthed = false,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 4, 50)),
        useMaterial3: true,
      ),
      home: isAuthed ? const HomePage() : const AuthPage(),
    );
  }
}
