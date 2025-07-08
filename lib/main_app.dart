import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:archery/data/di.dart';
import 'package:archery/data/data.dart';
import 'package:archery/pages/table.dart';
import 'package:archery/pages/registration.dart';
import 'package:archery/pages/root.dart';
import 'package:archery/pages/home_read.dart';
import 'package:archery/pages/home.dart';
import 'package:archery/pages/sportsmen.dart';
import 'package:archery/pages/week_notes.dart';
import 'package:archery/pages/enter.dart';
import 'package:archery/pages/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<Widget> createMainApp() async {
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  setupDI();

  final loggedIn = await sl<Data>().isLoggedIn();

  return MaterialApp(
    initialRoute: loggedIn ? '/' : '/registration',
    routes: {
      '/': (contest) => MainNavigation(),
      '/week_notes': (contest) => WeekNotes(),
      '/home_read': (contest) => HomeRead(),
      '/profile': (contest) => Profile(),
      '/registration': (contest) => Register(),
      '/enter': (contest) => Enter(),
      '/sportsmen': (contest) => Sportsmen(),
      '/home': (context) => Home(),
      '/table': (context) => TablePage(),
    },
  );
}
