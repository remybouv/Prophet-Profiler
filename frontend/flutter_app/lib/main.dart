import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/pages/home_page.dart';

void main() {
  runApp(const ProphetProfilerApp());
}

class ProphetProfilerApp extends StatelessWidget {
  const ProphetProfilerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prophet & Profiler',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1B3A), // Royal Indigo
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}