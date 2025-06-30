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
  List<String> names = [];
  List<String> surnames = [];
  String name = '';
  String surname = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Спортсмены'), automaticallyImplyLeading: false,),
      body: Stack(children: [
        Center(
          child: Opacity(
          opacity: 0.7,
            child: Image.asset(
              'assets/arch.jpg',
              width: 300,
              height: 300,
            ),
          ),
        ),
        ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return ElevatedButton(
              onPressed: () {
                // открываем его home
              },
              child: Text('data')
            );
          },
        ),
      ]),

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      onChanged: (v) {
                        setStateDialog(() {
                          name = v;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Имя',
                        hintStyle: TextStyle(fontSize: 23, color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 16),

                    TextField(
                      onChanged: (v) {
                        setStateDialog(() {
                          surname = v;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Фамилия',
                        hintStyle: TextStyle(fontSize: 23, color: Colors.grey),
                      ),
                    ),

                    SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // поиск а бд и добавление
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