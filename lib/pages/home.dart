import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> notes = [];
  String name_note = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Все записи'),
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/table'),
                    child: Text(
                      notes[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      notes.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),


      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(context: context, builder: (BuildContext context){
            return AlertDialog(
              actionsAlignment: MainAxisAlignment.center,
              title: Text(
                'Добавить запись',
                textAlign: TextAlign.center,
              ),
              content: TextField(
                onChanged: (String value) {
                  name_note = value;
                },
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        notes.add(name_note);
                      });

                      Navigator.of(context).pop();
                    },
                    child: Text('Добавить')
                )
              ],
            );
          });
        },
      ),
    );
  }
}