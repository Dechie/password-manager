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
    try {
      await st.write(
        key: 'hiveKey',
        value: base64UrlEncode(key),
      );
    } catch (e) {
      // ignore
    }
    keyBase64 = base64UrlEncode(key);
  } else {
    keyBase64 = await st.read(key: "hiveKey");
  }

  if (keyBase64 == null) {
    throw Exception('Failed to retrieve the encryption key from secure storage.');
  }
}

class MyApp extends StatelessWidget {
  final bool isAuthed;

  const MyApp({
    super.key,
    this.isAuthed = false,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC10124),
          surface: const Color(0xFFF5F5F7),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 2,
        ),
      ),
      home: isAuthed ? const HomePage() : const AuthPage(),
    );
  }
}
