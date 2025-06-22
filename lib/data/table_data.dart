import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TableData extends ChangeNotifier {
  final tables = <String, List<List<List<int>>>>{};
  int cnt = 10;

  void removeTable(String id) {
    tables.remove(id);
    save();
  }

  void createTable(String id) {
    tables[id] = List.generate(2, (_) => List.generate(cnt, (_) => List.filled(cnt, -1)));
    notifyListeners();
    save();
  }

  List<List<List<int>>> getTable(String id) {
    return tables[id] ?? List.generate(2, (_) => List.generate(cnt, (_) => List.filled(cnt, -1)));
  }

  void updateTable(String id, List<List<List<int>>> table) {
    tables[id] = table;
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
