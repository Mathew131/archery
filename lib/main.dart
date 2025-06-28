import 'package:flutter/material.dart';
import 'package:archery/main_app.dart';
import 'package:archery/pages/no_internet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!await hasInternet()) {
    runApp(NoInternetApp());
    return;
  }

  runApp(await createMainApp());
}



