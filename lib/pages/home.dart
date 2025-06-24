import 'package:flutter/material.dart';
import 'package:archery/data/di.dart';
import 'package:archery/data/table_data.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> notes = [];
  String name_note = 'Новая запись';
  String selectedDistance = 'Дистанция: 18м';

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await sl<TableData>().load();
      setState(() {
        notes = sl<TableData>().getNotes();
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Все записи'),
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Stack(children: [
        Center(
          child: Opacity(
          opacity: 0.70,
            child: Image.asset(
              'assets/arch.jpg',
              width: 300,
              height: 300,
            ),
          ),
        ),
        ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent, //Color.fromRGBO(255, 180, 85, 1),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.pushNamed(context, '/table', arguments: notes[index],),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text(
                                notes[index].split('_')[0],
                                style: TextStyle(color: Colors.black),
                              )
                            ),
                            Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: Text(
                              notes[index].split('_').sublist(1, 3).join(' '),
                              style: TextStyle(color: Colors.black),
                              )
                            ),
                        ])
                      ),
                  ),
                  // SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        sl<TableData>().removeTable(notes[index]);
                        notes.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ]),


      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        child: Icon(Icons.add),
        onPressed: () {

          showDialog(
            useRootNavigator: true,
            context: context,
            builder: (ctx) => StatefulBuilder(
              builder: (ctx2, setStateDialog) => AlertDialog(
                contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 16),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      onChanged: (v) => name_note = v,
                      decoration: InputDecoration(
                        hintText: 'Название',
                        hintStyle: TextStyle(fontSize: 23, color: Colors.grey),
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(21),
                      ],
                    ),
                    SizedBox(height: 16),
                    DropdownButton<String>(
                      value: selectedDistance,
                      underline: SizedBox(),
                      hint: Text('Дистанция: 18м'),
                      isExpanded: true,
                      items: [
                        'Дистанция: 12м','Дистанция: 18м','Дистанция: 30м',
                        'Дистанция: 40м','Дистанция: 50м','Дистанция: 60м',
                        'Дистанция: 70м','Дистанция: 80м','Дистанция: 90м',
                      ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: (v) => setStateDialog(() => selectedDistance = v!),
                    ),
                    SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            String distance = RegExp(r'\d+').firstMatch(selectedDistance ?? '')?.group(0) ?? '';
                            print(distance);
                            var now = DateTime.now();
                            String date = "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}";

                            name_note = '${name_note}_${distance}м  _${date}';
                            print(name_note);
                            notes.add(name_note);
                            sl<TableData>().createTable(name_note);
                            name_note = 'Новая запись';
                            selectedDistance = 'Дистанция: 18м';
                          });
                          Navigator.of(ctx).pop();
                        },
                        child: Text('Добавить'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),


    );
  }
}