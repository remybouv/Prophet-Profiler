import 'package:flutter/material.dart';
import 'core/theme/widgets_theme.dart';
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
      theme: createProphetTheme(),
      home: const HomePage(),
    );
  }
}