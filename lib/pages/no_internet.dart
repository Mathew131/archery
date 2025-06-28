import 'package:flutter/material.dart';
import 'package:archery/main_app.dart';
import 'dart:io';

class NoInternetApp extends StatelessWidget {
  const NoInternetApp({super.key});

  Future<void> _checkAndRestart(BuildContext context) async {
    if (await hasInternet()) {
      runApp(await createMainApp());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, size: 80, color: Colors.grey),
                SizedBox(height: 24),
                Text(
                  'Для корректной работы необходимо\nинтернет-соединение',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _checkAndRestart(context),
                  child: Text('Попробовать снова'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> hasInternet() async {
  try {
    final result = await InternetAddress.lookup('example.com')
        .timeout(const Duration(milliseconds: 500));
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}