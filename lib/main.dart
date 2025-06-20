import 'package:flutter/material.dart';
import 'package:archery/pages/home.dart';
import 'package:archery/pages/table.dart';

void main() => runApp(MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => Home(),
    '/table': (context) => TablePage(),
  }
));