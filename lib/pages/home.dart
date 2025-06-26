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

  // bool isDuplicate = false;

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

  int lastWriteElem(int i_table, int index) {
    var table = sl<TableData>().getTable(notes[index]);

    for (int i = table[i_table].length-1; i >= 0; --i) {
      if (table[i_table][i].last != -1) {
        return table[i_table][i].last;
      }
    }
    return 0;
  }

  bool rg(int i_table, int index) {
    var table = sl<TableData>().getTable(notes[index]);

    for (int i = 0; i < table[i_table].length; ++i) {
      for (int j = 0; j < table[i_table][i].length; ++j) {
        if (table[i_table][i][j] == -1) {
          return false;
        }
      }
    }

    return true;
  }

  Widget button(BuildContext context, int index) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            // backgroundColor: Colors.orangeAccent, //Color.fromRGBO(255, 180, 85, 1),
            backgroundColor: Color(0xFFffbf69),
            padding: EdgeInsets.symmetric(vertical: 12),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            // shadowColor: Colors.black12,
          ),

          onPressed: () async {
            await Navigator.pushNamed(context, '/table', arguments: notes[index],);
            setState(() {});
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
                            notes[index].split('_')[0],
                            style: TextStyle(color: Colors.black, fontSize: 16),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            notes[index].split('_').sublist(1, 3).join(' '),
                            style: TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ],
                      )
                  ),
                ),

                Row(
                  children: [
                    // Padding(
                    //   padding: EdgeInsets.only(right: 10),
                    //   child: Text(
                    //     '${sl<TableData>().getTable(notes[index]).first.last.last} + ${sl<TableData>().getTable(notes[index]).last.last.last} = '
                    //         '${sl<TableData>().getTable(notes[index]).first.last.last + sl<TableData>().getTable(notes[index]).last.last.last}',
                    //     style: TextStyle(color: Color(0xFF52992c), fontSize: 18, fontWeight: FontWeight.bold),
                    //   ),
                    // ),
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

                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Colors.black, size: 22),
                        onSelected: (value) {
                          if (value == 'delete') {
                            setState(() {
                              sl<TableData>().removeTable(notes[index]);
                              notes.removeAt(index);
                            });
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
                                        onChanged: (v) {
                                          setStateDialog(() {
                                            name_note = v;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Название',
                                          hintStyle: TextStyle(fontSize: 23, color: Colors.grey),
                                        ),
                                      ),
                                      SizedBox(height: 24),
                                      Center(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              var now = DateTime.now();
                                              name_note = '${name_note}_${notes[index].split('_')[1]}_${notes[index].split('_')[2]}_${now.millisecondsSinceEpoch}';

                                              sl<TableData>().renameTable(notes[index], name_note);
                                              notes[index] = name_note;

                                              name_note = 'Новая запись';
                                              selectedDistance = 'Дистанция: 18м';
                                            });
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
                    ),

                    // Padding(
                    //   padding: EdgeInsets.only(right: 10),
                    //   child: IconButton(
                    //     icon: Icon(Icons.delete_outline, color: Colors.red.shade700, size: 24,),
                    //     onPressed: () {
                    //       setState(() {
                    //         sl<TableData>().removeTable(notes[index]);
                    //         notes.removeAt(index);
                    //       });
                    //     },
                    //   ),
                    // ),

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
        preferredSize: Size.fromHeight(56),
        child: Container( // extra container for custom bottom shadows
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.2),
                spreadRadius: 3,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: AppBar(
            title: Text('Все записи'),
            centerTitle: true,
            backgroundColor: Color(0xFFf98948),
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
          itemCount: notes.length,
          itemBuilder: (context, index) {
            return button(context, index);
          },
        ),
      ]),


      floatingActionButton: FloatingActionButton(
        // backgroundColor: Colors.greenAccent,
        // backgroundColor: Color(0xFF7ae582),
        // backgroundColor: Color(0xFF74c69d),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      onChanged: (v) {
                        setStateDialog(() {
                          name_note = v;
                          // List <String> ls = (notes.map((el) => el.split('_')[0])).toList();
                          // isDuplicate = ls.contains(v);
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Название',
                        hintStyle: TextStyle(fontSize: 23, color: Colors.grey),
                        // errorText: isDuplicate == true ? 'Такое имя уже существует' : null,
                      ),
                      // inputFormatters: [
                      //   LengthLimitingTextInputFormatter(16),
                      // ],
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
                            var now = DateTime.now();
                            String date = "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}";

                            name_note = '${name_note}_${distance}м  _${date}_${now.millisecondsSinceEpoch}';
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