import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:archery/data/di.dart';
import 'package:archery/data/data.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  late List<List<TextEditingController>> sumControllers;
  late List<List<TextEditingController>> sumSumControllers;
  late List<List<List<TextEditingController>>> inputControllers;
  late List<List<List<FocusNode>>> inputFocusNodes;
  late List<List<List<int>>> val;
  late int cnt_ser;
  late int cnt_shoot;
  late bool isVisible;
  late bool is12_18;
  late int dop;

  late int currentTable = 0;
  late int currentI = 0;
  late int currentJ = 0;
  bool keyboardVisible = false;
  bool Focus = false;
  bool isWrite = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    setState(() {
      var args = ModalRoute.of(context)?.settings.arguments!;
      if (args is String && args == 'r') {
        isWrite = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    val = sl<Data>().getTable(sl<Data>().current_name);

    if (sl<Data>().current_name.split('_')[1] == '12м  ' || sl<Data>().current_name.split('_')[1] == '18м  ') {
      cnt_ser = 10;
      cnt_shoot = 3;
      isVisible = true;
      is12_18 = true;
      dop = 0;
    } else {
      cnt_ser = 6;
      cnt_shoot = 6;
      isVisible = false;
      is12_18 = false;
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

    inputFocusNodes = List.generate(2, (table) =>
        List.generate(cnt_ser, (i) =>
            List.generate(cnt_shoot, (j) {
              return FocusNode();
            }),
        ),
    );
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

    for (var i in inputFocusNodes) {
      for (var j in i) {
        for (var k in j) {
          k.dispose();
        }
      }
    }

    super.dispose();
  }

  void insertText(BuildContext context, String text) {
    final t = currentTable;
    final i = currentI;
    final j = currentJ;

    final controller = inputControllers[t][i][j];
    controller.text = text;
    controller.selection = TextSelection.collapsed(offset: text.length);
    onValueChanged(text, t, i, j);

    int nextI = i;
    int nextJ = j + 1;

    if (nextJ >= cnt_shoot) {
      nextJ = 0;
      nextI++;
    }

    setState(() {
      if (nextI < cnt_ser) {
        currentI = nextI;
        currentJ = nextJ;
        FocusScope.of(context).requestFocus(inputFocusNodes[t][nextI][nextJ]);
      }
    });
  }

  void deleteText(BuildContext context) {
    final t = currentTable;
    final i = currentI;
    final j = currentJ;

    final controller = inputControllers[t][i][j];
    controller.text = '';
    controller.selection = TextSelection.collapsed(offset: ''.length);
    onValueChanged('', t, i, j);

    int nextI = i;
    int nextJ = j - 1;

    if (nextJ < 0) {
      nextJ = cnt_shoot-1;
      nextI--;
    }

    setState(() {
      if (nextI >= 0) {
        currentI = nextI;
        currentJ = nextJ;
        FocusScope.of(context).requestFocus(inputFocusNodes[t][nextI][nextJ]);
      }
    });
  }

  Widget buildCustomKeyboard() {
    const labels = [
      '1','2','3','←',
      '4','5','6','OK',
      '7','8','9','',
      'м', '10','x','',
    ];

    return Container(
      height: 300,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFFEEEEEE),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.5,
        ),
        itemCount: labels.length,
        itemBuilder: (_, idx) {
          final label = labels[idx];
          final isEmpty = label.isEmpty;
          Color outerColor = Colors.grey[350]!;
          Color innerColor = isEmpty ? outerColor : Colors.white;
          Widget child;

          if (label == '←') {
            child = const Icon(Icons.backspace_outlined, size: 24);
          } else if (label == 'OK') {
            child = const Text('OK', style: TextStyle(fontSize: 24, color: Colors.blue));
          } else if (isEmpty) {
            child = const SizedBox();
          } else {
            child = Text(label, style: const TextStyle(fontSize: 24));
          }

          return Material(
            color: outerColor,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: isEmpty ? null : () {
                if (label == 'OK') {
                  setState(() {
                    Focus = false;
                    keyboardVisible = false;
                  });
                } else if (label == '←') {
                  deleteText(context);
                } else {
                  insertText(context, label);
                }
              },
              child: Center(child: child),
            ),
          );
        },
      ),
    );
  }

  TextEditingController getController(int table, int i, int j) {
    final controller = inputControllers[table][i][j];

    if (controller.text == '0') {
      controller.text = 'м';
    } else if (controller.text == '11') {
      controller.text = 'x';
    }

    return controller;
  }

  void onValueChanged(String v, int table, int i, int j) {
    late int n;
    if (v == 'м') {
      n = 0;
    } else if (v == 'x') {
      n = 11;
    } else {
      n = int.tryParse(v) ?? -1;
    }

    setState(() {
      val[table][i][j] = n;
      int sum = 0;
      for (int k = 0; k < cnt_shoot; ++k) {
        sum += val[table][i][k];
        if (val[table][i][k] == 11) sum -= 1;
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

        bool isVisible = true;
        for (int w = 0; w < cnt_shoot; ++w) {
          if (val[table][z][w] != -1) {
            sumControllers[table][z].text = val[table][z][cnt_shoot].toString();
            sumSumControllers[table][z].text = val[table][z][cnt_shoot+1].toString();
            isVisible = false;
          }
        }
        if (isVisible) {
          sumControllers[table][z].text = '';
          sumSumControllers[table][z].text = '';
        }

      }

      sl<Data>().updateTable(sl<Data>().current_name, val);
    });
  }

  Widget row_of_cells(int table, int i, int dop, bool isVisibleNumber, bool isVisibleCell) {
    return Row(
      children: [
        Visibility(
          visible: isVisibleNumber,
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
                  readOnly: false,

                  focusNode: inputFocusNodes[table][i][j],

                  showCursor: Focus && isWrite,
                  enableInteractiveSelection: false,

                  onTap: isWrite == true ? () {
                    setState(() {
                      Focus = true;
                      currentTable = table;
                      currentI = i;
                      currentJ = j;
                      keyboardVisible = true;
                    });
                  } : null,

                  controller: getController(table, i, j),

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),

                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.none,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],

                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                        color: (table == currentTable && i == currentI && j == currentJ) && Focus
                            ? Colors.orange
                            : Colors.grey,
                        width: (table == currentTable && i == currentI && j == currentJ) && Focus ? 3 : 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],

        Expanded(child:
          Visibility(
            visible: isVisibleCell,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            maintainSemantics: false,
            maintainInteractivity: false,
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
        ),

        Expanded(child:
          Visibility(
            visible: isVisibleCell,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            maintainSemantics: false,
            maintainInteractivity: false,
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
        ),


      ],
    );
  }

  Widget last_cell() {
    return  Padding(
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
            title: Text(sl<Data>().current_name.split('_')[0], style: TextStyle(fontSize: 20)),
            centerTitle: true,
            backgroundColor: Color(0xFFffbf69),
            scrolledUnderElevation: 0,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                                  row_of_cells(table, i, 0, true, false),
                                Padding(
                                  padding: cnt_ser == 6 ? EdgeInsets.only(top: 8) : EdgeInsets.only(top: 0),
                                  child: row_of_cells(table, i, dop, is12_18, true),
                                )
                              ],
                            )
                        ),
                    ],
                  ),
                ],

                last_cell(),

                SizedBox(height: 304),
              ]
            )
          ),

          if (keyboardVisible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: buildCustomKeyboard(),
            )
        ],
      )
    );
  }
}
