import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pass_mgr/utils/auth.dart';

import 'screens/auth_page.dart';
import 'screens/home.dart';

void main() async {
  await Hive.initFlutter();
  //Hive.registerAdapter(ItemAdapter());

  AuthService auth = AuthService();
  final bool isAuthed = await auth.checkAuthed();
  runApp(MyApp(isAuthed: isAuthed));
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
