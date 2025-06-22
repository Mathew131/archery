import 'package:flutter/material.dart';
import 'package:archery/pages/home.dart';
import 'package:archery/pages/table.dart';
import 'package:archery/data/di.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDI();
  runApp(MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
        '/table': (context) => TablePage(),
      }
  ));
}