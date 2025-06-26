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
  late int cnt_ser;
  late int cnt_shoot;
  late bool flag;
  late int dop;

  late String name_note;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var args = ModalRoute.of(context)?.settings.arguments!;
    if (args != null && args is String) {
      name_note = args;
      val = sl<TableData>().getTable(name_note);
    }

    if (name_note.split('_')[1] == '12м  ' || name_note.split('_')[1] == '18м  ') {
      cnt_ser = 10;
      cnt_shoot = 3;
      flag = true;
      dop = 0;
    } else {
      cnt_ser = 6;
      cnt_shoot = 6;
      flag = false;
      dop = 3;
    }


    sumControllers = List.generate(2, (table) => List.generate(cnt_ser, (i) {
      final value = val[table][i][cnt_shoot];
      for (int z = 0; z < cnt_shoot; ++z) {
        if (val[table][i][z] != -1) {
          return TextEditingController(text: value.toString());
        }
      }
      return TextEditingController(text: '');
    }));

    sumSumControllers = List.generate(2, (table) => List.generate(cnt_ser, (i) {
      final value = val[table][i][cnt_shoot+1];
      for (int z = 0; z < cnt_shoot; ++z) {
        if (val[table][i][z] != -1) {
          return TextEditingController(text: value.toString());
        }
      }
      return TextEditingController(text: '');
    }));

    inputControllers = List.generate(2, (table) =>
        List.generate(cnt_ser, (i) =>
            List.generate(cnt_shoot, (j) {
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
            title: Text(name_note.substring(0, name_note.indexOf('_')), style: TextStyle(fontSize: 20)),
            centerTitle: true,
            backgroundColor: Color(0xFFffbf69),
            scrolledUnderElevation: 0,
          ),
        ),
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
                          for (int i = 0; i < cnt_ser; i++)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child:
                                Column(
                                  children: [
                                    if (cnt_ser == 6)
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor: Colors.grey.shade200,
                                            child: Text(
                                              '${i + 1}',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),

                                          for (int j = 0; j < 3; j++) ... [
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
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.digitsOnly
                                                    ],
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
                                                        int sum = 0;
                                                        for (int k = 0; k < cnt_shoot; ++k) {
                                                          sum += val[table][i][k];
                                                          if (val[table][i][k] == -1) sum += 1;
                                                        }

                                                        val[table][i][cnt_shoot] = sum;
                                                        for (int z = 0; z < cnt_ser; ++z) {
                                                          if (z == 0) {
                                                            val[table][z][cnt_shoot+1] = val[table][z][cnt_shoot];
                                                            if (val[table][z][cnt_shoot] == -1) {
                                                              val[table][z][cnt_shoot+1] += 1;
                                                            }
                                                          } else {
                                                            val[table][z][cnt_shoot+1] = val[table][z-1][cnt_shoot+1] + val[table][z][cnt_shoot];
                                                            if (val[table][z-1][cnt_shoot+1] == -1) {
                                                              val[table][z][cnt_shoot+1] += 1;
                                                            }
                                                            if (val[table][z][cnt_shoot] == -1) {
                                                              val[table][z][cnt_shoot+1] += 1;
                                                            }
                                                          }

                                                          bool flag = true;
                                                          for (int w = 0; w < cnt_shoot; ++w) {
                                                            if (val[table][z][w] != -1) {
                                                              sumControllers[table][z].text = val[table][z][cnt_shoot].toString();
                                                              sumSumControllers[table][z].text = val[table][z][cnt_shoot+1].toString();
                                                              flag = false;
                                                            }
                                                          }
                                                          if (flag) {
                                                            sumControllers[table][z].text = '';
                                                            sumSumControllers[table][z].text = '';
                                                          }

                                                        }
                                                        sl<TableData>().updateTable(name_note, val);
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                          Expanded(child:
                                            Visibility(
                                              visible: false,
                                              maintainState: true,
                                              maintainAnimation: true,
                                              maintainSize: true,
                                              maintainSemantics: false,
                                              maintainInteractivity: false,
                                              child: Padding(
                                                  padding: EdgeInsets.only(left: 8),
                                                  child: AspectRatio(
                                                    aspectRatio: 1,
                                                    child: TextField(),
                                                  )
                                              ),
                                            ),
                                          ),

                                          Expanded(child:
                                            Visibility(
                                              visible: false,
                                              maintainState: true,
                                              maintainAnimation: true,
                                              maintainSize: true,
                                              maintainSemantics: false,
                                              maintainInteractivity: false,
                                              child: Padding(
                                                  padding: EdgeInsets.only(left: 8),
                                                  child: AspectRatio(
                                                    aspectRatio: 1,
                                                    child: TextField(),
                                                  )
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    Padding(
                                      padding: cnt_ser == 6 ? EdgeInsets.only(top: 8) : EdgeInsets.only(top: 0),
                                      child: Row(
                                        children: [
                                          Visibility(
                                            visible: flag,
                                            maintainState: true,
                                            maintainAnimation: true,
                                            maintainSize: true,
                                            maintainSemantics: false,
                                            maintainInteractivity: false,
                                            child: CircleAvatar(
                                              radius: 16,
                                              backgroundColor: Colors.grey.shade200,
                                              child: Text(
                                                '${i + 1}',
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),



                                          for (int j = dop; j < 3+dop; j++) ... [
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
                                                        int sum = 0;
                                                        for (int k = 0; k < cnt_shoot; ++k) {
                                                          sum += val[table][i][k];
                                                          if (val[table][i][k] == -1) sum += 1;
                                                        }

                                                        val[table][i][cnt_shoot] = sum;
                                                        for (int z = 0; z < cnt_ser; ++z) {
                                                          if (z == 0) {
                                                            val[table][z][cnt_shoot+1] = val[table][z][cnt_shoot];
                                                            if (val[table][z][cnt_shoot] == -1) {
                                                              val[table][z][cnt_shoot+1] += 1;
                                                            }
                                                          } else {
                                                            val[table][z][cnt_shoot+1] = val[table][z-1][cnt_shoot+1] + val[table][z][cnt_shoot];
                                                            if (val[table][z-1][cnt_shoot+1] == -1) {
                                                              val[table][z][cnt_shoot+1] += 1;
                                                            }
                                                            if (val[table][z][cnt_shoot] == -1) {
                                                              val[table][z][cnt_shoot+1] += 1;
                                                            }
                                                          }

                                                          bool flag = true;
                                                          for (int w = 0; w < cnt_shoot; ++w) {
                                                            if (val[table][z][w] != -1) {
                                                              sumControllers[table][z].text = val[table][z][cnt_shoot].toString();
                                                              sumSumControllers[table][z].text = val[table][z][cnt_shoot+1].toString();
                                                              flag = false;
                                                            }
                                                          }
                                                          if (flag) {
                                                            sumControllers[table][z].text = '';
                                                            sumSumControllers[table][z].text = '';
                                                          }

                                                        }
                                                        sl<TableData>().updateTable(name_note, val);
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
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
                                                      fillColor: i == cnt_ser-1 ? Colors.amber.shade100 : Colors.amber.shade50,

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
                                    )
                                  ],
                                )
                            ),
                        ],
                      ),
                    ],
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              Visibility(
                                  visible: false,
                                  maintainState: true,
                                  maintainAnimation: true,
                                  maintainSize: true,
                                  maintainSemantics: false,
                                  maintainInteractivity: false,
                                  child:
                                    CircleAvatar(
                                      radius: 16,
                                      child: Text(''),
                                    ),
                              ),
                              for (int z = 0; z < 5; ++z) ... [
                                Expanded(
                                  child:
                                    Visibility(
                                      visible: z != 4 ? false : true,
                                      maintainState: true,
                                      maintainAnimation: true,
                                      maintainSize: true,
                                      maintainSemantics: false,
                                      maintainInteractivity: false,
                                      child:
                                        Padding(
                                          padding: EdgeInsets.only(left: 8),
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: TextField(
                                              textAlign: TextAlign.center,
                                              controller: TextEditingController(
                                                text: val[0][cnt_ser-1][cnt_shoot + 1] != -1 && val[1][cnt_ser-1][cnt_shoot + 1] != -1 ?
                                                (val[0][cnt_ser-1][cnt_shoot + 1] + val[1][cnt_ser-1][cnt_shoot + 1]).toString() : '',
                                              ),
                                              readOnly: true,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.amber.shade100,

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
                                    )
                                ),
                              ],
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 4),
                  ]
              )
          )
      ),
    );
  }
}
