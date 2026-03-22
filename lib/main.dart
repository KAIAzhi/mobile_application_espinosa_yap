import 'package:flutter/material.dart';

import 'pages/login.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RescueHub',
      theme: AppTheme.lightTheme,
      home: Scaffold(
        backgroundColor: AppTheme.surfaceLight,
        body: const SafeArea(
          child: LoginnWidget(),
        ),
      ),
    );
  }
}
