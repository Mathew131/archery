import 'package:flutter/material.dart';
import 'package:archery/data/di.dart';
import 'package:archery/data/data.dart';
import 'package:synchronized/synchronized.dart';

class WeekNotes extends StatefulWidget {
  const WeekNotes({super.key});

  @override
  State<WeekNotes> createState() => _WeekNotesState();
}

class _WeekNotesState extends State<WeekNotes> {
  var days = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ];

  final Map<String, List<String>> _itemsByDay = {
    'Понедельник': [],
    'Вторник'    : [],
    'Среда'      : [],
    'Четверг'    : [],
    'Пятница'    : [],
    'Суббота'    : [],
    'Воскресенье': [],
  };

  void _addItem(String day, String item) {
    setState(() => _itemsByDay[day]!.add(item));
  }

  List<String> items = [];

  void loadNotes() async {
    var now = DateTime.now();

    List<String> temp = [];
    for (int i = 0; i < 7; ++i) {
      temp.add(days[(now.weekday - 1 - i) >= 0 ? (now.weekday - 1 - i) : 7 + (now.weekday - 1 - i)]);
    }
    days = temp;

    for (int j = 0; j < 7; ++j) {
      var cur_time = now.subtract(Duration(days: j));
      String cur_day = "${cur_time.day.toString().padLeft(2, '0')}.${cur_time.month.toString().padLeft(2, '0')}.${cur_time.year}";
      items = await sl<Data>().searchNotes(cur_day);
      for (int i = 0; i < items.length; ++i) {
        _addItem(days[j], items[i]);
      }
    }
  }

  @override
  void initState() {
    loadNotes();

    super.initState();
  }

  Future<int> lastWriteElem(int i_table, String text, table) async {

    for (int i = table[i_table].length-1; i >= 0; --i) {
      if (table[i_table][i].last != -1) {
        return table[i_table][i].last;
      }
    }
    return 0;
  }

  Future<bool> rg(int i_table, String text, table) async {

    for (int i = 0; i < table[i_table].length; ++i) {
      for (int j = 0; j < table[i_table][i].length; ++j) {
        if (table[i_table][i][j] == -1) {
          return false;
        }
      }
    }

    return true;
  }

  final _mutex = Lock();

  Future<List<dynamic>> runSequentially(String text) async {
    return _mutex.synchronized(() async {
      // String temp = sl<Data>().token;
      sl<Data>().token = text.split('&')[0];
      await sl<Data>().load();
      var table = sl<Data>().getTable(text.split('&')[1]);

      final results = await Future.wait([
        lastWriteElem(0, text, table),
        lastWriteElem(1, text, table),
        rg(0, text, table),
        rg(1, text, table),
      ]);

      // print('${sl<Data>().token} | $temp &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
      // sl<Data>().token = temp;
      // await sl<Data>().load();

      return [results[0], results[1], results[2], results[3]];
    });
  }

  Widget button(BuildContext context, String text) {
    return FutureBuilder<List<dynamic>>(
      future: runSequentially(text),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final last0 = snap.data![0] as int;
        final last1 = snap.data![1] as int;
        final ok0 = snap.data![2] as bool;
        final ok1 = snap.data![3] as bool;

        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent.shade100,
            padding: EdgeInsets.symmetric(vertical: 12),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: () async {
            final temp = sl<Data>().token;
            sl<Data>().token = text.split('&')[0];
            await sl<Data>().load();
            await Navigator.pushNamed(context, '/table', arguments: [text.split('&')[1], 'hr'],);
            sl<Data>().token = temp;
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${text.split(':')[0]} ${text.split(':')[1]}',
                        style: TextStyle(fontSize: 16)),
                    Text('${text.split('_')[1]} ${text.split('&')[1].split('_')[0]}',
                        style: TextStyle(color: Colors.black54, fontSize: 12)),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: Row(
                  children: [
                    Text('$last0',
                        style: TextStyle(
                          color: ok0 ? Color(0xFF4c8f28) : Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                    Text(' + ', style: TextStyle(fontSize: 16)),
                    Text('$last1',
                        style: TextStyle(
                          color: ok1 ? Color(0xFF4c8f28) : Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                    Text(' = ', style: TextStyle(fontSize: 16)),
                    Text('${last0 + last1}',
                        style: TextStyle(
                          color: (ok0 && ok1) ? Color(0xFF4c8f28) : Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              )

            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Неделя')),
      body: ListView.builder(
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final buttons = _itemsByDay[day]!;

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day, style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: buttons.map((text) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: button(context, text),
                      );
                    }).toList(),
                  ),
                  if (buttons.isEmpty)
                    Text('Нет записей', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

