import 'package:flutter/material.dart';
import 'package:archery/data/di.dart';
import 'package:archery/data/data.dart';
import 'package:flutter/services.dart';

class HomeRead extends StatefulWidget {
  const HomeRead({super.key});

  @override
  State<HomeRead> createState() => _HomeReadState();
}

class _HomeReadState extends State<HomeRead> {
  List<String> notes = [];
  List<String> current_notes = [];
  String name_note = 'Новая запись';
  String selectedDistance = 'Дистанция: 18м';
  String selectedFilterDistance = 'Все дистанции';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var args = ModalRoute.of(context)?.settings.arguments!;
    setState(() {
      if (args is String) {
        sl<Data>().token = args;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await sl<Data>().load();
      setState(() {
        notes = sl<Data>().getNotes();
        current_notes = sl<Data>().getNotes();
      });
    });
  }

  List<String> validDistance() {
    if (selectedFilterDistance == 'Все дистанции') {
      return [
        'Дистанция: 12м','Дистанция: 18м','Дистанция: 30м',
        'Дистанция: 40м','Дистанция: 50м','Дистанция: 60м',
        'Дистанция: 70м','Дистанция: 80м','Дистанция: 90м',
      ];
    } else {
      return ['Дистанция: $selectedFilterDistance'];
    }
  }

  Widget button(BuildContext context, int index) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent.shade100,
            padding: EdgeInsets.symmetric(vertical: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          onPressed: () async {
            sl<Data>().current_name = current_notes[index];
            await Navigator.pushNamed(context, '/table', arguments: 'r');

            setState(() {
              notes = sl<Data>().getNotes();
              current_notes = sl<Data>().getNotes();
            });
          },

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded (
                child: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          current_notes[index].split('_')[0],
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          current_notes[index].split('_').sublist(1, 3).join(' '),
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    )
                ),
              ),

              Row(
                children: [
                  Text(
                    '${current_notes[index].split('_')[4]}',
                    style: TextStyle(color: current_notes[index].split('_')[6] == 'true' ? Color(0xFF4c8f28) : Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    ' + ',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  Text(
                    '${current_notes[index].split('_')[5]}',
                    style: TextStyle(color: current_notes[index].split('_')[7] == 'true' ? Color(0xFF4c8f28) : Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    ' = ',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  Text(
                    '${int.parse(current_notes[index].split('_')[4]) + int.parse(current_notes[index].split('_')[5])}',
                    style: TextStyle(color: current_notes[index].split('_')[6] == 'true' && current_notes[index].split('_')[7] == 'true' ? Color(0xFF4c8f28) : Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(width: 32,)
                ],
              )
            ]
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(73),
        child: Container(
          decoration: const BoxDecoration(
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
            elevation: 0,
            backgroundColor: const Color(0xFFf98948),
            centerTitle: true,

            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                Text(
                  '${sl<Data>().token.split(':')[0]} ${sl<Data>().token.split(':')[1]}',
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),

                // const SizedBox(height: 2),

                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isDense: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                    value: selectedFilterDistance,
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black, fontSize: 20),
                    items: ['Все дистанции', '12м', '18м', '30м', '40м', '50м',
                      '60м', '70м', '80м', '90м'].map((d) => DropdownMenuItem(
                      value: d,
                      child: Text(d == 'Все дистанции' ? d : 'Дистанция: $d'),
                    )).toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedFilterDistance = v!;
                        current_notes = selectedFilterDistance == 'Все дистанции' ? List.from(notes) : notes.where((n) =>
                        '$selectedFilterDistance  ' == n.split('_')[1]).toList();
                        selectedDistance = selectedFilterDistance == 'Все дистанции' ? '' : 'Дистанция: $selectedFilterDistance';
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: Stack(children: [
        Center(
          child: Opacity(
            opacity: 0.20,
            child: Image.asset(
              'assets/arch.jpg',
              width: 300,
              height: 300,
            ),
          ),
        ),
        Column(
          children: [
            SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                itemCount: current_notes.length,
                itemBuilder: (context, index) {
                  return button(context, index);
                },
              ),
            ),
            SizedBox(height: 6),
          ],
        )
      ]),
    );
  }
}