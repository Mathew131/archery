import 'package:flutter/material.dart';
import 'package:archery/data/di.dart';
import 'package:archery/data/data.dart';
// import 'package:synchronized/synchronized.dart';

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

  late List<List<String>> itemsByDay;
  late List<String> cur_sportsmen;

  List<String> items = [];

  late VoidCallback? onComplete;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    onComplete = ModalRoute.of(context)?.settings.arguments as VoidCallback?;
  }

  @override
  void dispose() {
    onComplete?.call();
    super.dispose();
  }

  Future<void> loadNotes() async {
    var now = DateTime.now();
    int cnt_week = 4;
    List<String> temp = [];

    for (int j = 0; j < cnt_week; ++j) {
      for (int i = 0; i < 7; ++i) {
        temp.add(days[(now.weekday - 1 - i) >= 0 ? (now.weekday - 1 - i) : 7 + (now.weekday - 1 - i)]);
      }
    }
    days = temp;

    itemsByDay = List.generate(7 * cnt_week, (_) => []);
    await sl<Data>().searchNotes(7 * cnt_week, cur_sportsmen, itemsByDay);
    if (mounted) {
      setState(() {});
    }
  }

  // final Stopwatch dataStopwatch = Stopwatch();
  // final Stopwatch renderStopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    cur_sportsmen = List<String>.from(sl<Data>().getSportsmen());
    loadNotes();

    // dataStopwatch.start();

    // loadNotes().then((_) {
    //   dataStopwatch.stop();
    //   print('Загрузка данных заняла: ${dataStopwatch.elapsedMilliseconds} мс');
    //
    //   renderStopwatch.start();
    //
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     renderStopwatch.stop();
    //     print('Отрисовка UI заняла: ${renderStopwatch.elapsedMilliseconds} мс');
    //   });
    // });
  }

  Widget button(BuildContext context, String text) {
    final last0 = text.split('_')[4];
    final last1 = text.split('_')[5];
    final ok0 = text.split('_')[6];
    final ok1 = text.split('_')[7];

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orangeAccent.shade100,
        padding: EdgeInsets.symmetric(vertical: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: () async {
        // final temp = sl<Data>().token;
        sl<Data>().token = text.split('&')[0];
        await sl<Data>().load();
        sl<Data>().current_name = text.split('&')[1];
        await Navigator.pushNamed(context, '/table', arguments: 'r',);
        // все возвращается назад в VoidCallback
        // sl<Data>().token = temp;
        // await sl<Data>().load();
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
                      color: ok0 == 'true' ? Color(0xFF4c8f28) : Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                Text(' + ', style: TextStyle(color: Colors.black, fontSize: 16)),
                Text('$last1',
                    style: TextStyle(
                      color: ok1 == 'true' ? Color(0xFF4c8f28) : Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                Text(' = ', style: TextStyle(color: Colors.black, fontSize: 16)),
                Text('${int.parse(last0) + int.parse(last1)}',
                    style: TextStyle(
                      color: (ok0 == 'true' && ok1 == 'true') ? Color(0xFF4c8f28) : Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          )

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.2),
                spreadRadius: 2,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: AppBar(
            title: DropdownButtonHideUnderline(
                child: Text('Записи за месяц')
            ),
            centerTitle: true,
            backgroundColor: Color(0xFFf98948),
          ),
        ),
      ),

      body: ListView.builder(
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final buttons = itemsByDay[index];

          var now = DateTime.now();
          var cur_time = now.subtract(Duration(days: index));
          String cur_day = "${cur_time.day.toString().padLeft(2, '0')}.${cur_time.month.toString().padLeft(2, '0')}.${cur_time.year}";

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (days[index] == 'Воскресенье')
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 3,
                    margin: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFf98948),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )
                ),
              Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$cur_day,  $day', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: buttons.map((text) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: button(context, text),
                          );
                        }).toList(),
                      ),
                      if (buttons.isEmpty)
                        Text('Нет записей', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

