import 'package:flutter/material.dart';
import 'package:archery/main_app.dart';
import 'package:archery/pages/no_internet.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  if (!await hasInternet()) {
    runApp(NoInternetApp());
    return;
  }

  runApp(await createMainApp());
}