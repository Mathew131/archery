import 'package:flutter/material.dart';
import 'package:archery/data/di.dart';
import 'package:archery/data/data.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> notes = [];
  List<String> current_notes = [];
  List<TextEditingController> name_current_controller = [];
  String name_note = 'Новая запись';
  String selectedDistance = 'Дистанция: 18м';
  String selectedFilterDistance = 'Все дистанции';

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await sl<Data>().load();
      setState(() {
        notes = sl<Data>().getNotes();
        current_notes = sl<Data>().getNotes();
        name_current_controller = sl<Data>().getNotes().map((note) => TextEditingController(text: note.split('_')[0])).toList();
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

  Widget button(BuildContext context, int index, bool isLast) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, isLast ? 90 : 0),
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
          await Navigator.pushNamed(context, '/table', arguments: 'w');
          await sl<Data>().save();

          setState(() {
            notes = sl<Data>().getNotes();
            current_notes = sl<Data>().getNotes();
            name_current_controller = sl<Data>().getNotes().map((note) => TextEditingController(text: note.split('_')[0])).toList();
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
                        maxLines: 3,
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
              padding: EdgeInsets.only(left: 10, right: 0),
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

                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.black, size: 22),
                    onSelected: (value) async {
                      if (value == 'delete') {
                        String temp = current_notes[index];
                        setState(() {
                          notes.remove(current_notes[index]);
                          current_notes.removeAt(index);
                          name_current_controller.removeAt(index);
                        });
                        await sl<Data>().removeTable(temp);
                      } else if (value == 'rename') {
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
                                    controller: name_current_controller[index],
                                    onChanged: (v) {
                                      setStateDialog(() {
                                        name_note = v;
                                      });
                                    },
                                    maxLength: 60,
                                    buildCounter: (
                                        BuildContext context, {
                                          required int currentLength,
                                          required int? maxLength,
                                          required bool isFocused,
                                        }) => null, // убираем надпись maxLength
                                    decoration: InputDecoration(
                                      hintText: 'Название',
                                      hintStyle: TextStyle(fontSize: 23, color: Colors.grey),
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        name_note = '${name_note}_${current_notes[index].substring(current_notes[index].indexOf('_') + 1)}';
                                        String temp = current_notes[index];

                                        setState(() {
                                          for (int k = 0; k < notes.length; ++k) {
                                            if (notes[k] == current_notes[index]) {
                                              notes[k] = name_note;
                                              break;
                                            }
                                          }
                                          current_notes[index] = name_note;
                                          name_current_controller[index] = TextEditingController(text: name_note.split('_')[0]);
                                        });

                                        await sl<Data>().renameTable(temp, name_note);

                                        name_note = 'Новая запись';
                                        selectedDistance = 'Дистанция: 18м';
                                        Navigator.of(ctx).pop();
                                      },
                                      child: Text('Сохранить'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'rename', child: Text('Переименовать')),
                      PopupMenuItem(value: 'delete', child: Text('Удалить')),
                    ],
                  ),
                ],
              ),
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
            // surfaceTintColor: Colors.transparent,
            title: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                iconStyleData: const IconStyleData(
                  iconEnabledColor: Colors.black,
                ),
                value: selectedFilterDistance,
                style: TextStyle(color: Colors.black, fontSize: 20),
                items: ['Все дистанции', '12м', '18м', '30м', '40м', '50м', '60м', '70м', '80м', '90м'].map((d) {
                  return DropdownMenuItem(
                    value: d,
                    child: d == 'Все дистанции' ? Text('$d') : Text('Дистанция: $d'),
                  );
                }).toList(),
                dropdownStyleData: DropdownStyleData(
                  // width: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                ),
                onChanged: (v) {
                  setState(() {
                    selectedFilterDistance = v!;

                    current_notes = [];
                    name_current_controller = [];
                    if (selectedFilterDistance != 'Все дистанции') {
                      for (int i = 0; i < notes.length; ++i) {
                        if ('$selectedFilterDistance  ' == notes[i].split('_')[1]) {
                          current_notes.add(notes[i]);
                          name_current_controller.add(TextEditingController(text:notes[i].split('_')[0]));
                        }
                      }
                      selectedDistance = 'Дистанция: $selectedFilterDistance';
                    } else {
                      for (int i = 0; i < notes.length; ++i) {
                        current_notes.add(notes[i]);
                        name_current_controller.add(TextEditingController(text:notes[i].split('_')[0]));
                      }
                    }
                  });
                },
              ),
            ),
            automaticallyImplyLeading: false,
            centerTitle: true,
            backgroundColor: Color(0xFFf98948),
          ),
        ),
      ),

      body: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 0),
              child: Center(
                child: Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                    'assets/arch.jpg',
                    width: 300,
                    height: 300,
                  ),
                ),
              ),
            ),
            ListView.builder(
              itemCount: current_notes.length,
              itemBuilder: (context, index) {
                return button(context, index, index == current_notes.length - 1);
              },
            ),
          ]
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF95d5b2),
        elevation: 3,
        child: Icon(Icons.add, color: Colors.black,),
        onPressed: () {
          showDialog(
            useRootNavigator: true,
            context: context,
            builder: (ctx) => StatefulBuilder(
              builder: (ctx2, setStateDialog) => AlertDialog(
                contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 16),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      onChanged: (v) {
                        setStateDialog(() {
                          name_note = v;
                        });
                      },
                      maxLength: 60,
                      buildCounter: (
                          BuildContext context, {
                            required int currentLength,
                            required int? maxLength,
                            required bool isFocused,
                          }) => null, // убираем надпись maxLength
                      decoration: InputDecoration(
                        hintText: 'Название',
                        hintStyle: TextStyle(fontSize: 23, color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 16),

                    DropdownButton2<String>(
                      isExpanded: true,
                      value: selectedDistance,
                      items: validDistance().map((v) => DropdownMenuItem(
                        value: v,
                        child: Text(v, style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
                      )).toList(),
                      onChanged: (v) => setStateDialog(() => selectedDistance = v!),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 300,
                        width: 235,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          String distance = RegExp(r'\d+').firstMatch(selectedDistance ?? '')?.group(0) ?? '';
                          var now = DateTime.now();
                          String date = "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}";
                          name_note = '${name_note}_${distance}м  _${date}_${now.millisecondsSinceEpoch}_0_0_false_false';

                          setState(() {
                            notes.insert(0, name_note);
                            current_notes.insert(0, name_note);
                            name_current_controller.insert(0, TextEditingController(text: name_note.split('_')[0]));
                          });
                          await sl<Data>().createTable(name_note);
                          name_note = 'Новая запись';
                          selectedDistance = 'Дистанция: 18м';

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
