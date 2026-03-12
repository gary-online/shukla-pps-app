import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shukla_pps/config/theme.dart';

void main() {
  runApp(const ProviderScope(child: ShuklaPpsApp()));
}

class ShuklaPpsApp extends StatelessWidget {
  const ShuklaPpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shukla PPS',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(
          child: Text('Shukla PPS — App Shell Coming Soon'),
        ),
      ),
    );
  }
}
