import 'package:flutter/material.dart';
import 'package:archery/pages/home.dart';
import 'package:archery/pages/sportsmen.dart';
import 'package:archery/data/data.dart';
import 'package:archery/data/di.dart';
import 'package:archery/pages/profile.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool isCoach = true;
  bool isLoaded = false;
  late List<BottomNavigationBarItem> items = [];

  Widget buildPage(int index) {
    if (isCoach) {
      switch (index) {
        case 0: return Home();
        case 1: return Sportsmen();
        case 2: return Profile();
      }
    } else {
      switch (index) {
        case 0: return Home();
        case 1: return Profile();
      }
    }
    return Center(child: Text('Неизвестная страница'));
  }

  void loadRole() async {
    if (sl<Data>().token.split(':')[3] == 'sportsman') {
      setState(() {
        isCoach = false;
      });
    }

    setState(() {
      isLoaded = true;

      if (isCoach) {
        items = [
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'Запись'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Мои спортсмены'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ];
      } else {
        items = [
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'Запись'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ];
      }
    });
  }

  @override
  void initState() {
    loadRole();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: buildPage(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: items,
      ),
    );
  }
}
