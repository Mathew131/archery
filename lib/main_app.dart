import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:archery/data/di.dart';
import 'package:archery/pages/home.dart';
import 'package:archery/pages/table.dart';

Future<Widget> createMainApp() async {
  await Firebase.initializeApp();
  setupDI();

  return MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => Home(),
      '/table': (context) => TablePage(),
    },
  );
}
