import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:archery/data/di.dart';
import 'package:archery/data/data.dart';
import 'package:archery/pages/table.dart';
import 'package:archery/pages/enter.dart';
import 'package:archery/pages/root.dart';
import 'package:archery/pages/home_read.dart';
import 'package:archery/pages/home.dart';
import 'package:archery/pages/sportsmen.dart';


Future<Widget> createMainApp() async {
  await Firebase.initializeApp();
  setupDI();

  final loggedIn = await sl<Data>().isLoggedIn();

  return MaterialApp(
    initialRoute: loggedIn ? '/' : '/register',
    routes: {
      '/': (contest) => MainNavigation(),
      '/home_read': (contest) => HomeRead(),
      '/register': (contest) => Register(),
      '/sportsmen': (contest) => Sportsmen(),
      '/home': (context) => Home(),
      '/table': (context) => TablePage(),
    },
  );
}
