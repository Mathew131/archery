import 'package:flutter/material.dart';
import 'package:archery/data/di.dart';
import 'package:archery/data/data.dart';
import 'package:flutter/services.dart';

class Sportsmen extends StatefulWidget {
  const Sportsmen({super.key});

  @override
  State<Sportsmen> createState() => _SportsmenState();
}

class _SportsmenState extends State<Sportsmen> {
  List<String> sportsmen = [];
  String name = '';
  String surname = '';
  bool notFind = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      sportsmen = sl<Data>().getSportsmen();
    });
  }


  Widget button(BuildContext context, int index, bool isLast) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, isLast ? 12 : 0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orangeAccent.shade100,
          padding: EdgeInsets.symmetric(vertical: 11),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        onPressed: () async {
          String temp = sl<Data>().token;
          await Navigator.pushNamed(context, '/home_read', arguments: sportsmen[index],);

          sl<Data>().token = temp;
          await sl<Data>().load();
          sportsmen = sl<Data>().getSportsmen();
        },

        child: Row(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 4),
                    child: Text('${index + 1})', style: TextStyle(fontSize: 16, color: Colors.black)),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 4, right: 16),
                      child: Text(
                        '${sportsmen[index].split(':')[1]} ${sportsmen[index].split(':')[0]}',
                        style: TextStyle(fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 0),
              child: SizedBox(
                width: 48,
                height: 32,
                child: PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.black, size: 22),
                  onSelected: (value) async {
                    await sl<Data>().removeSportsman(sportsmen[index]);
                    setState(() {
                      sportsmen.removeAt(index);
                    });
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'delete', child: Text('Удалить')),
                  ],
                ),
              ),
            )
          ],
        ),
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
                child: Text('Мои спортсмены')
            ),
            automaticallyImplyLeading: false,
            centerTitle: true,
            backgroundColor: Color(0xFFf98948),
            // backgroundColor: Colors.deepOrangeAccent.shade200,
          ),
        ),
      ),
      body: Stack(children: [
        Padding(
          padding: EdgeInsets.only(top: 72),
          // padding: EdgeInsets.only(top: 0),
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
          itemCount: sportsmen.length,
          itemBuilder: (context, index) {
            return button(context, index, index == sportsmen.length - 1);
          },
        ),
      ]),

      // extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  String prev = sl<Data>().token;

                  await Navigator.pushNamed(
                    context,
                    '/week_notes',
                    arguments: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        if (!mounted) return;

                        sl<Data>().token = prev;
                        await sl<Data>().load();

                        if (!mounted) return;

                        setState(() {
                          sportsmen = sl<Data>().getSportsmen();
                        });
                      });
                    },
                  );

                },
                child: Text('Их записи за месяц'),
              ),
            ),

            SizedBox(width: 16),

            FloatingActionButton(
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
                                surname = v;

                                if (surname == '' && name == '') notFind = false;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Фамилия',
                              hintStyle: TextStyle(fontSize: 21, color: Colors.grey),
                            ),
                          ),

                          SizedBox(height: 12),

                          TextField(
                            onChanged: (v) {
                              setStateDialog(() {
                                name = v;
                                if (surname == '' && name == '') notFind = false;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Имя',
                              hintStyle: TextStyle(fontSize: 21, color: Colors.grey),
                            ),
                          ),

                          SizedBox(height: 16),

                          Text('* Спортсмен должен быть зарегистрирован в приложении', style: TextStyle(fontSize: 11, color: Colors.black38)),

                          SizedBox(height: 12),
                          Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                String token_s = await sl<Data>().search_sportsman(name, surname);
                                if (token_s != '') {
                                  await sl<Data>().addSportsman(token_s);
                                }

                                setStateDialog(() {
                                  if (token_s == '') {
                                    // спортсмен не найден
                                    notFind = true;
                                  } else {
                                    // спортсмен найдет и есть его токен
                                    notFind = false;
                                    setState(() {
                                      sportsmen = sl<Data>().getSportsmen();
                                    });
                                    Navigator.of(ctx).pop();
                                  }
                                });

                              },
                              child: Text('Добавить'),
                            ),
                          ),

                          if (notFind)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Text(
                                  'Спортсмен не найден',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                ).then((_) {
                  setState(() {
                    notFind = false;
                  });
                });;
              },
            ),
          ],
        ),
      ),
    );
  }
}