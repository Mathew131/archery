import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TableData extends ChangeNotifier {
  final tables = <String, List<List<List<int>>>>{};
  late int cnt_ser;
  late int cnt_shoot;

  void removeTable(String name_note) {
    tables.remove(name_note);
    save();
  }

  void renameTable(String old_name_note, String new_name_note) {
    tables[new_name_note] = tables[old_name_note]!
        .map((table) => table
        .map((row) => List<int>.from(row))
        .toList())
        .toList();
    tables.remove(old_name_note);
    save();
  }

  void createTable(String name_note) {
    if (name_note.split('_')[1] == '12м  ' || name_note.split('_')[1] == '18м  ') {
      cnt_ser = 10;
      cnt_shoot = 3;
    } else {
      cnt_ser = 6;
      cnt_shoot = 6;
    }
    
    tables[name_note] = List.generate(2, (_) => List.generate(cnt_ser, (_) => List.filled(cnt_shoot+2, -1)));
    notifyListeners();
    save();
  }

  List<List<List<int>>> getTable(String name_note) {
    return tables[name_note]!;
  }

  void updateTable(String name_note, List<List<List<int>>> table) {
    tables[name_note] = table;
    notifyListeners();
    save();
  }

  List<String> getNotes() {
    return tables.keys.toList();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(tables);
    await prefs.setString('tables', jsonString);
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('tables');
    if (jsonString != null) {
      final decoded = jsonDecode(jsonString);
      tables.clear();
      decoded.forEach((key, value) {
        tables[key] = List<List<List<int>>>.from(
          (value as List).map((table) => List<List<int>>.from(
              (table as List).map((row) => List<int>.from(row),),
            ),
          ),
        );
      });
    }
  }
}
