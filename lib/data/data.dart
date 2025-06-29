import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Data extends ChangeNotifier {
  String tokenKey = 'auth_token';
  late String token;

  Future<void> saveToken(String name, String lastname, email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, '$name:$lastname:$email');
  }

  Future<String> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(tokenKey) == null) {
      return '';
    } else {
      return prefs.getString(tokenKey)!;
    }
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await loadToken();

    return token.isNotEmpty;

  }


  final tables = <String, List<List<List<int>>>>{};
  late int cnt_ser;
  late int cnt_shoot;

  void removeTable(String name_note) {
    tables.remove(name_note);
    FirebaseFirestore.instance.collection('tables').doc(name_note).delete();
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
    final data = <String, String>{};
    for (final e in tables.entries) {
      data[e.key] = jsonEncode(e.value);
    }
    await FirebaseFirestore.instance.collection(token).doc('tables').set(data);
  }

  Future<void> load() async {
    final snapshot = await FirebaseFirestore.instance.collection(token).doc('tables').get();

    final data = snapshot.data()!;
    for (final key in data.keys) {
      final encoded = data[key] as String;

      final decoded = jsonDecode(encoded);

      final table = (decoded as List)
          .map((list1) => (list1 as List)
          .map((list2) => (list2 as List).map((v) => v as int).toList())
          .toList())
          .toList();

      tables[key] = table;
    }
  }
}
