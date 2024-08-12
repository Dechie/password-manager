import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/home.dart';

void main() async {
  await Hive.initFlutter();
  //Hive.registerAdapter(ItemAdapter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 4, 50)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
