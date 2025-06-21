import 'package:flutter/foundation.dart';

class TableData extends ChangeNotifier {
  final tables = <String, List<List<List<int>>>>{};
  int cnt = 10;

  void createTable(String id) {
    tables[id] = List.generate(2, (_) => List.generate(cnt, (_) => List.filled(cnt, -1)));
    notifyListeners();
  }

  List<List<List<int>>> getTable(String id) {
    return tables[id] ?? List.generate(2, (_) => List.generate(cnt, (_) => List.filled(cnt, -1)));
  }

  void updateTable(String id, List<List<List<int>>> table) {
    tables[id] = table;
    notifyListeners();
  }
}
