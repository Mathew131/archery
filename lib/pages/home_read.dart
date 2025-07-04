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
      if (args != null && args is String) {
        // В память не сохраняем!!!!
        sl<Data>().token = '${args.split(':')[0]}:${args.split(':')[1]}:${args.split(':')[2].replaceAll(',', '.')}:${args.split(':')[3]}';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      // sl<Data>().token = await sl<Data>().loadToken();
      // sl<Data>().token = 'ios:Курченко:mathew.kurchenko23@gmail.com:Тренер';

      await sl<Data>().load();
      setState(() {
        notes = sl<Data>().getNotes();
        current_notes = sl<Data>().getNotes();
      });
    });
  }

  int lastWriteElem(int i_table, int index) {
    var table = sl<Data>().getTable(current_notes[index]);
    for (int i = table[i_table].length-1; i >= 0; --i) {
      if (table[i_table][i].last != -1) {
        return table[i_table][i].last;
      }
    }
    return 0;
  }

  bool rg(int i_table, int index) {
    var table = sl<Data>().getTable(current_notes[index]);

    for (int i = 0; i < table[i_table].length; ++i) {
      for (int j = 0; j < table[i_table][i].length; ++j) {
        if (table[i_table][i][j] == -1) {
          return false;
        }
      }
    }

    return true;
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
      padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent.shade100,
            padding: EdgeInsets.symmetric(vertical: 12),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          onPressed: () async {
            await Navigator.pushNamed(context, '/table', arguments: [current_notes[index], 'hr']);
            final notes = sl<Data>().getNotes();
            setState(() {
              this.notes = notes;
              current_notes = notes;
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
                    '${lastWriteElem(0, index)}',
                    style: TextStyle(color: rg(0, index) ? Color(0xFF4c8f28) : Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    ' + ',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  Text(
                    '${lastWriteElem(1, index)}',
                    style: TextStyle(color: rg(1, index) ? Color(0xFF4c8f28) : Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    ' = ',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  Text(
                    '${lastWriteElem(0, index) + lastWriteElem(1, index)}',
                    style: TextStyle(color: rg(0, index) && rg(1, index) ? Color(0xFF4c8f28) : Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
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
        preferredSize: const Size.fromHeight(66),
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, .2),
                spreadRadius: 3,
                blurRadius: 3,
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
                const SizedBox(height: 6),

                Text(
                  '${sl<Data>().token.split(':')[0]} ${sl<Data>().token.split(':')[1]}',
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),

                const SizedBox(height: 2),

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
            opacity: 0.70,
            child: Image.asset(
              'assets/arch.jpg',
              width: 300,
              height: 300,
            ),
          ),
        ),
        ListView.builder(
          itemCount: current_notes.length,
          itemBuilder: (context, index) {
            return button(context, index);
          },
        ),
      ]),
    );
  }
}