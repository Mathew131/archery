import 'package:flutter/material.dart';
import 'package:archery/pages/home.dart';
import 'package:archery/pages/enter.dart';
import 'package:archery/pages/sportsmen.dart';
import 'package:archery/data/data.dart';
import 'package:archery/data/di.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  List<Widget> _pages = [
    Home(),
    Sportsmen(),
    Register(),
  ];

  var _items = [
    BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'Запись'),
    BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Мои спортсмены'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
  ];

  void Who() async {
    String who = await sl<Data>().loadToken();
    if (who.split(':')[3] == 'Спортсмен') {
      setState(() {
        _pages.removeAt(1);
        _items.removeAt(1);
      });
    }
  }

  @override
  void initState() {

    Who();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _items,
      ),
    );
  }
}
