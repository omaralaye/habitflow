import 'package:flutter/material.dart';
import 'utils/constants.dart';
import 'widgets/main_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sanctuary',
      debugShowCheckedModeBanner: false,
      theme: AppStyles.theme,
      home: const MainNavigation(),
    );
  }
}
