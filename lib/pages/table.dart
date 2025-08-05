import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:archery/data/di.dart';
import 'package:archery/data/data.dart';
import 'package:archery/pages/target.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  late bool isTargetKeyboard = true;
  List<String> tripletarget = ['Верхняя мишень', 'Средняя мишень', 'Нижняя мишень'];

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

  bool isFull(int i_table) {
    for (int i = 0; i < val[i_table].length; ++i) {
      for (int j = 0; j < val[i_table][i].length; ++j) {
        if (val[i_table][i][j] == -1) {
          return false;
        }
      }
    }
    return true;
  }

  Future<void> insertText(BuildContext context, String text) async {
    final t = currentTable;
    final i = currentI;
    final j = currentJ;

    final controller = inputControllers[t][i][j];

    String temp = controller.text;
    if (temp != '') {
      await deleteText(context);
    }

    controller.text = text;
    controller.selection = TextSelection.collapsed(offset: text.length);
    await onValueChanged(text, t, i, j);

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

  Future<void> deleteText(BuildContext context) async {
    final t = currentTable;
    final i = currentI;
    final j = currentJ;

    final controller = inputControllers[t][i][j];

    String temp = controller.text;
    controller.text = '';
    controller.selection = TextSelection.collapsed(offset: ''.length);
    await onValueChanged('', t, i, j);

    if (temp != '') {
      Offset pos = sl<Data>().valueByTarget[sl<Data>().current_name]![currentTable][currentI][currentJ];
      if (pos != Offset(-1, -1)) {
        sl<Data>().hits[sl<Data>().current_name]![currentTable][(sl<Data>().current_name.split('_')[1] == '18м  ') ? currentJ : 0].remove(pos);
        sl<Data>().valueByTarget[sl<Data>().current_name]![currentTable][currentI][currentJ] = Offset(-1, -1);
      }
      return;
    }

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
      '1','2','3','<-',
      '4','5','6','OK',
      '7','8','9','TK',
      'м', '10','x','',
    ];

    return Container(
      height: 300, // 270,
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
          Widget child;

          if (label == 'TK') {
            child = SvgPicture.asset('assets/target18.svg', width: 40, height: 40);
          } else if (label == '<-') {
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
              onTap: isEmpty ? null : () async {
                if (label == 'TK') {
                  setState(() {
                    isTargetKeyboard = true;
                  });
                } else if (label == 'OK') {
                  setState(() {
                    Focus = false;
                    keyboardVisible = false;
                  });
                  await sl<Data>().save();
                  setState(() {
                    val = sl<Data>().tables[sl<Data>().current_name]!;
                  });
                } else if (label == '<-') {
                  await deleteText(context);
                } else {
                  await insertText(context, label);
                }
              },
              child: Center(child: child),
            ),
          );
        },
      ),
    );
  }

  Widget buildTarget18(int curTable, int curJ, bool isView) {
    return Column(
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: TargetWidget(
            svgAsset: 'assets/target18.svg',
            onShot: (pos) async {
              final score = calculateScore(pos, Size(220, 220), 220, 5);
              int pred_currentI = currentI;
              await insertText(context, score);
              // print('${sl<Data>().current_name} | ${sl<Data>().valueByTarget[sl<Data>().current_name]} -------------------------------');
              sl<Data>().valueByTarget[sl<Data>().current_name]![curTable][pred_currentI][curJ] = sl<Data>().hits[sl<Data>().current_name]![curTable][curJ].last;
            },
            currentTable: curTable,
            curJ: curJ,
            width: 220,
            height: 220,
            sizeHits: 4,
            isView: isView,
            size: Size(220, 220),
          ),
        ),

        SizedBox(height: 12),

        if (!isView) Text('${tripletarget[curJ]}', style: TextStyle(fontSize: 20, color: Colors.black)),
      ],
    );
  }

  Widget buildMediumTarget(int curTable, bool isView) {
    return Column(
      children: [
        SizedBox(
          width: 230,
          height: 230,
          child: TargetWidget(
            svgAsset: 'assets/medium_target.svg',
            onShot: (pos) async {
              final score = calculateScore(pos, Size(230, 230), 230, 6.0);
              int pred_currentI = currentI;
              int pred_currentJ = currentJ;
              await insertText(context, score);
              sl<Data>().valueByTarget[sl<Data>().current_name]![curTable][pred_currentI][pred_currentJ] = sl<Data>().hits[sl<Data>().current_name]![curTable][0].last;
            },
            currentTable: curTable,
            curJ: 0,
            width: 230,
            height: 230,
            sizeHits: 3,
            isView: isView,
            size: Size(230, 230),
          ),
        ),
        SizedBox(height: 20,)
      ],
    );
  }

  Widget buildBigTarget(int curTable, bool isView) {
    return Column(
      children: [
        SizedBox(
          width: 300,
          height: 300,
          child: TargetWidget(
            svgAsset: 'assets/big_target.svg',
            onShot: (pos) async {
              final score = calculateScore(pos, Size(300, 300), 300, 10.0);
              int pred_currentI = currentI;
              int pred_currentJ = currentJ;
              await insertText(context, score);
              sl<Data>().valueByTarget[sl<Data>().current_name]![curTable][pred_currentI][pred_currentJ] = sl<Data>().hits[sl<Data>().current_name]![curTable][0].last;
            },
            currentTable: curTable,
            curJ: 0,
            width: 300,
            height: 300,
            sizeHits: 3,
            isView: isView,
            size: Size(300, 300),
          ),
        ),
      ],
    );
  }

  Widget buildCustomTargetKeyboard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black38)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20, top: 10),
                child: Column(
                  children: [
                    IconButton(
                      onPressed: () async {
                        await sl<Data>().save();
                        setState(() {
                          val = sl<Data>().tables[sl<Data>().current_name]!;
                        });

                        setState(() {
                          isTargetKeyboard = false;
                        });
                      },
                      icon: Opacity(
                        opacity: 0.5,
                        child: SvgPicture.asset('assets/icon_table.svg', width: 40, height: 40),
                      ),
                    ),
                  ],
                )
              ),

              Padding(
                padding: EdgeInsets.only(right: 16, top: 10),
                child: Row(
                  children: [
                    SizedBox(
                      height: 50,
                      child: AspectRatio(
                        aspectRatio: 1.5,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[250],
                            // foregroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 1,
                          ),
                          onPressed: () async {
                            await deleteText(context);
                          },
                          child: Opacity(
                            opacity: 0.7,
                            child: Icon(Icons.backspace_outlined, size: 30),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 12),

                    SizedBox(
                      height: 50,
                      child: AspectRatio(
                        aspectRatio: 1.5,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[250],
                            foregroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 1,
                          ),
                          onPressed: () async {
                            setState(() {
                              Focus = false;
                              keyboardVisible = false;
                            });
                            await sl<Data>().save();
                            setState(() {
                              val = sl<Data>().tables[sl<Data>().current_name]!;
                            });
                          },
                          child: Text('OK', style: TextStyle(fontSize: 20, color: Colors.blue)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          if (sl<Data>().current_name.split('_')[1] == '18м  ') ... [
            buildTarget18(currentTable, currentJ, false),
          ] else if (sl<Data>().current_name.split('_')[1] == '30м  ' || sl<Data>().current_name.split('_')[1] == '50м  ') ... [
            buildMediumTarget(currentTable, false),
          ] else buildBigTarget(currentTable, false),

          SizedBox(height: 24),
        ],
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

  Future<void> onValueChanged(String v, int table, int i, int j) async {
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
    });
    // await sl<Data>().save();
  }

  Widget row_of_cells(int table, int i, int dop, bool isVisibleNumber, bool isVisibleCell, BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 8),

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
          SizedBox(width: 8),
          Expanded(
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

                textAlignVertical: TextAlignVertical.center,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.none,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],

                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: Colors.black45,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: (table == currentTable && i == currentI && j == currentJ) && Focus
                          ? Colors.orange
                          : Colors.black45,
                      width: (table == currentTable && i == currentI && j == currentJ) && Focus ? 3 : 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],

        SizedBox(width: 8),

        Expanded(
          child: Visibility(
            visible: isVisibleCell,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            maintainSemantics: false,
            maintainInteractivity: false,
            child: AspectRatio(
              aspectRatio: 1,
              child: GestureDetector(
                onTap: () {},
                child: AbsorbPointer(
                  child: TextField(
                    controller: sumControllers[table][i],
                    readOnly: true,
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.amber.shade50,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ),
          ),
        ),

        SizedBox(width: 8),

        Expanded(
          child: Visibility(
            visible: isVisibleCell,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            maintainSemantics: false,
            maintainInteractivity: false,
            child: AspectRatio(
              aspectRatio: 1,
              child: GestureDetector(
                onTap: () {},
                child: AbsorbPointer(
                  child: TextField(
                    controller: sumSumControllers[table][i],
                    readOnly: true,
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: i == cnt_ser-1 ? Colors.amber.shade100 : Colors.amber.shade50,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ),
          ),
        ),

        SizedBox(width: 8),
      ],
    );
  }

  Widget last_cell() {
    return  Row(
      children: [
        SizedBox(width: 8),

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
          SizedBox(width: 8,),

          Expanded(child:
            Visibility(
              visible: z != 4 ? false : true,
              maintainState: true,
              maintainAnimation: true,
              maintainSize: true,
              maintainSemantics: false,
              maintainInteractivity: false,
              child: AspectRatio(
                aspectRatio: 1,
                child: GestureDetector(
                  onTap: () {},
                  child: AbsorbPointer(
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      textAlign: TextAlign.center,
                      controller: TextEditingController(
                        text: isFull(0) && isFull(1) ?
                        (val[0][cnt_ser-1][cnt_shoot + 1] + val[1][cnt_ser-1][cnt_shoot + 1]).toString() : '',
                      ),
                      readOnly: true,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.amber.shade100,

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            // color: Colors.indigo,
                            // width: 3,
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ),
        ],

        SizedBox(width: 8,),

      ],
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
                      for (int i = 0; i < cnt_ser; i++) ... [
                        SizedBox(height: 8),
                        if (cnt_ser == 6) ... [
                          row_of_cells(table, i, 0, true, false, context),
                          SizedBox(height: 8,),
                        ],
                        row_of_cells(table, i, dop, is12_18, true, context),
                      ],
                    ],
                  ),

                  if (table == 1) ... [
                    SizedBox(height: 8),
                    last_cell(),
                  ] else SizedBox(height: 24),


                  if (sl<Data>().current_name.split('_')[1] == '18м  ') ... [
                    buildTarget18(table, 0, true),
                    buildTarget18(table, 1, true),
                    buildTarget18(table, 2, true),
                  ] else if (sl<Data>().current_name.split('_')[1] == '30м  ' || sl<Data>().current_name.split('_')[1] == '50м  ') ... [
                    buildMediumTarget(table, true),
                  ] else buildBigTarget(table, true),

                ],

                SizedBox(height: 308),
              ]
            )
          ),

          if (keyboardVisible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: isTargetKeyboard ? buildCustomTargetKeyboard() : buildCustomKeyboard(),
            )
        ],
      )
    );
  }
}
