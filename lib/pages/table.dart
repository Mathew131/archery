import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:archery/data/di.dart';
import 'package:archery/data/table_data.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  late List<List<TextEditingController>> sumControllers;
  late List<List<TextEditingController>> sumSumControllers;
  late List<List<List<TextEditingController>>> inputControllers;
  late List<List<List<int>>> val;
  late int cnt;

  late String id;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      id = args;
      val = sl<TableData>().getTable(id);
    } else {
      id = 'default_id';
      val = List.generate(2, (_) => List.generate(cnt, (_) => List.filled(cnt, -1)));
    }

    cnt = val[0].length;

    sumControllers = List.generate(2, (table) => List.generate(cnt, (i) {
      final value = val[table][i][3];
      return TextEditingController(text: value != -1 ? value.toString() : '');
    }));

    sumSumControllers = List.generate(2, (table) => List.generate(cnt, (i) {
      final value = val[table][i][4];
      return TextEditingController(text: value != -1 ? value.toString() : '');
    }));

    inputControllers = List.generate(2, (table) =>
        List.generate(cnt, (i) =>
            List.generate(3, (j) {
              final value = val[table][i][j];
              return TextEditingController(text: value != -1 ? value.toString() : '');
            }),
        ),
    );

  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var i in inputControllers) {
      for (var j in i) {
        for (var k in j) {
          k.dispose();
        }
      }
    }

    for (var row in sumControllers) {
      for (var c in row) {
        c.dispose();
      }
    }

    for (var row in sumSumControllers) {
      for (var c in row) {
        c.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Запись'),
        centerTitle: true,
        backgroundColor: Colors.orangeAccent,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
              child: Column(
                  children: [
                    for (int table = 0; table < 2; ++table) ... [
                      Padding(
                        padding: EdgeInsets.only(top: 24, bottom: 16),
                        child: Text(
                          '${table+1} дистанция',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          for (int i = 0; i < cnt; i++)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.grey.shade200,
                                    child: Text(
                                      '${i + 1}',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),

                                  for (int j = 0; j < 3; j++)
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: TextField(
                                            controller: inputControllers[table][i][j],

                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400,
                                            ),

                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(4),
                                                borderSide: BorderSide(
                                                  color: Colors.orange,
                                                  width: 3,
                                                ),
                                              ),
                                            ),
                                            onChanged: (v) {
                                              int n = int.tryParse(v) ?? -1;
                                              setState(() {
                                                val[table][i][j] = n;
                                                if (val[table][i][0] != -1 && val[table][i][1] != -1 && val[table][i][2] != -1) {
                                                  val[table][i][3] = val[table][i][0] + val[table][i][1] + val[table][i][2];
                                                  if (i == 0) {
                                                    val[table][i][4] = val[table][i][3];
                                                  } else {
                                                    val[table][i][4] = val[table][i-1][4] + val[table][i][3];
                                                  }
                                                  sumControllers[table][i].text = val[table][i][3].toString();
                                                  sumSumControllers[table][i].text = val[table][i][4].toString();
                                                } else {
                                                  sumControllers[table][i].text = '';
                                                  sumSumControllers[table][i].text = '';
                                                }
                                                sl<TableData>().updateTable(id, val);
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: TextField(
                                            textAlign: TextAlign.center,
                                            controller: sumControllers[table][i],
                                            readOnly: true,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.amber.shade50,

                                              border: OutlineInputBorder(),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(4),
                                                borderSide: BorderSide(
                                                  color: Colors.indigo,
                                                  width: 3,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: TextField(
                                            textAlign: TextAlign.center,
                                            controller: sumSumControllers[table][i],
                                            readOnly: true,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            decoration: InputDecoration(

                                              filled: true,
                                              fillColor: Colors.amber.shade50,

                                              border: OutlineInputBorder(),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(4),
                                                borderSide: BorderSide(
                                                  color: Colors.indigo,
                                                  width: 3,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                    SizedBox(height: 20),
                  ]
              )
          )
      ),
    );
  }
}
