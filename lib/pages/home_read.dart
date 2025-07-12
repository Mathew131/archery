import 'package:flutter/material.dart';
import 'package:archery/data/di.dart';
import 'package:archery/data/data.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

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
              Expanded(
                child: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          current_notes[index].split('_')[0],
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          maxLines: 2,
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


              Padding(
                padding: EdgeInsets.only(left: 10, right: 20),
                child: Row(
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
                  ],
                ),
              ),
            ]
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final token = sl<Data>().token.split(':');
    final userName = '${token[1]} ${token[0]}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: .2,
              child: Image.asset('assets/arch.jpg', width: 300, height: 300),
            ),
          ),

          NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverAppBar(
                // surfaceTintColor: Colors.transparent,
                backgroundColor: Color(0xFFf98948),
                toolbarHeight: 56,
                pinned: true,
                elevation: 4,
                centerTitle: true,
                title: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    value: selectedFilterDistance,
                    iconStyleData:
                    IconStyleData(iconEnabledColor: Colors.black),
                    style: TextStyle(color: Colors.black, fontSize: 20),
                    items: ['Все дистанции', '12м', '18м', '30м', '40м', '50м',
                      '60м', '70м', '80м', '90м'].map((d) => DropdownMenuItem(
                      value: d,
                      child: d == 'Все дистанции' ? Text(d) : Text('Дистанция: $d'),
                    )).toList(),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                    ),
                    onChanged: (v) => setState(() {
                      selectedFilterDistance = v!;

                      current_notes = [];
                      if (selectedFilterDistance != 'Все дистанции') {
                        for (int i = 0; i < notes.length; ++i) {
                          if ('$selectedFilterDistance  ' == notes[i].split('_')[1]) {
                            current_notes.add(notes[i]);
                          }
                        }
                        selectedDistance = 'Дистанция: $selectedFilterDistance';
                      } else {
                        for (int i = 0; i < notes.length; ++i) {
                          current_notes.add(notes[i]);
                        }
                      }
                    }),
                  ),
                ),
              ),

              SliverPersistentHeader(
                pinned: true,
                delegate: _NameBanner(userName),
              ),
            ],

            body: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 6),
              itemCount: current_notes.length,
              itemBuilder: (c, i) => button(c, i),
            ),
          ),
        ],
      ),
    );
  }
}

class _NameBanner extends SliverPersistentHeaderDelegate {
  final String name;
  _NameBanner(this.name);

  @override
  double get minExtent => 40;
  @override
  double get maxExtent => 40;

  @override
  Widget build(BuildContext context, double shrink, bool overlaps) {
    return Material(
      elevation: 2,
      color: Colors.white,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF765dba),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _NameBanner old) => old.name != name;
}
