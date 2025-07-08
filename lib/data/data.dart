import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Data extends ChangeNotifier {
  String tokenKey = 'auth_token';
  late String token;
  Map<String, List<List<List<int>>>> tables = {};
  List<String> sportsmen = [];
  String current_name = '';
  late int cnt_ser;
  late int cnt_shoot;

  Future<void> saveToken(String name, String lastname, String email, String type) async {
    final prefs = await SharedPreferences.getInstance();
    token = '$name:$lastname:$email:$type';
    await prefs.setString(tokenKey, '$name:$lastname:$email:$type');
  }

  Future<void> searchAndSaveTokenByEmail(String email) async {
    var coachData = FirebaseFirestore.instance.collection('users').doc('coach_en').get();
    var sportsmenData = FirebaseFirestore.instance.collection('users').doc('sportsmen_en').get();
    var results = await Future.wait([coachData, sportsmenData]);
    var coachSnapshot = results[0];

    var data = coachSnapshot.data() ?? {};

    String emailKey = email.replaceAll('.', ',');
    String? token_no_email = data?['$emailKey'];
    if (token_no_email != null) {
      saveToken(token_no_email.split(':')[0], token_no_email.split(':')[1], email, 'coach');
    }

    var sportsmenSnapshot = results[1];

    data = sportsmenSnapshot.data() ?? {};

    emailKey = email.replaceAll('.', ',');
    token_no_email = data?['$emailKey'];
    if (token_no_email != null) {
      saveToken(token_no_email.split(':')[0], token_no_email.split(':')[1], email, 'sportsman');
    }
  }

  Future<String> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(tokenKey) == null) {
      return '';
    } else {
      token = prefs.getString(tokenKey)!;
      return token;
    }
  }

  Future<bool> isLoggedIn() async {
    token = await loadToken();
    return token.isNotEmpty;
  }

  // ------------------------------------------------------

  void addSportsman(String token_s) {
    sportsmen.add(token_s);
    save();
  }

  void deleteSportsman(String token_s) {
    sportsmen.remove(token_s);
    save();
  }

  List<String> getSportsmen() {
    List<String> sportsmen_in_order = List.from(sportsmen);
    sportsmen_in_order.sort((a, b) {
      final aParts = a.split(':');
      final bParts = b.split(':');

      final lastA = aParts[1];
      final lastB = bParts[1];

      final firstA = aParts[0];
      final firstB = bParts[0];

      final lastCompare = lastA.compareTo(lastB);
      if (lastCompare != 0) return lastCompare;

      return firstA.compareTo(firstB);
    });

    return sportsmen_in_order;
  }

  // ------------------------------------------------------

  void removeTable(String name_note) {
    tables.remove(name_note);
    FirebaseFirestore.instance.collection('tables').doc(name_note).delete();
    save(); // может не надо
  }

  void renameTable(String old_name_note, String new_name_note) {
    tables[new_name_note] = tables[old_name_note]!
        .map((table) => table
        .map((row) => List<int>.from(row))
        .toList())
        .toList();
    if (new_name_note != old_name_note) {
      tables.remove(old_name_note);
    }
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
    // print('$name_note ++++++++++++++++++++++++++++++++++++');
    notifyListeners();

    save();
  }

  List<List<List<int>>> getTable(String name_note) {
    // print('$name_note ---------------------------------------- ${tables.keys}');
    return tables[name_note]!;
  }

  void updateTable(String name_note, List<List<List<int>>> table) {
    // print('$name_note ^^^^^^^^^^^^^^^^^^^^^^^^^');
    tables[name_note] = table;
    notifyListeners();

    save();
  }

  List<String> getNotes() {
    var keys_in_order = tables.keys.toList();
    keys_in_order.sort((a, b) => int.parse(b.split('_')[3]).compareTo(int.parse(a.split('_')[3])));
    return keys_in_order;
  }

  int lastWriteElem(int i_table, String name) {
    for (int i = tables[name]![i_table].length-1; i >= 0; --i) {
      if (tables[name]![i_table][i].last != -1) {
        return tables[name]![i_table][i].last;
      }
    }
    return 0;
  }

  bool rg(int i_table, String name) {
    for (int i = 0; i < tables[name]![i_table].length; ++i) {
      for (int j = 0; j < tables[name]![i_table][i].length; ++j) {
        if (tables[name]![i_table][i][j] == -1) {
          return false;
        }
      }
    }
    return true;
  }

  Future<void> save() async {
    final data = <String, String>{};
    final oldKeys = List<String>.from(tables.keys);

    // print('${tables.keys} до ***********************************');
    for (final key in oldKeys) {
      var lw0 = lastWriteElem(0, key);
      var lw1 = lastWriteElem(1, key);
      var rg0 = rg(0, key);
      var rg1 = rg(1, key);

      String newKey = '${key.split('_')[0]}_${key.split('_')[1]}_${key.split('_')[2]}_${key.split('_')[3]}_${lw0}_${lw1}_${rg0}_${rg1}';
      data[newKey] = jsonEncode(tables[key]);


      if (key != newKey) {
        if (key == current_name) {
          current_name = newKey;
        }
        tables[newKey] = tables[key]!
            .map((table) => table.map((row) => List<int>.from(row)).toList())
            .toList();

        tables.remove(key);
      }
    }
    // print('${tables.keys} после *********************************** ${data.keys}');

    await FirebaseFirestore.instance.collection(token).doc('tables').set(data);

    String emailKey = token.split(':')[2].replaceAll('.', ','); // в ключе в firebase не надо точек
    if (token.split(':')[3] == 'sportsman') {
      // await FirebaseFirestore.instance.collection('sportsmen').doc('data').update({'${token.split(':')[0]}:${token.split(':')[1]}' : token.split(':')[2]});
      await FirebaseFirestore.instance.collection('users').doc('sportsmen_en').update({emailKey : '${token.split(':')[0]}:${token.split(':')[1]}:${token.split(':')[3]}'});
      await FirebaseFirestore.instance.collection('users').doc('sportsmen_ne').update({'${token.split(':')[0]}:${token.split(':')[1]}' : emailKey});
    } else {
      await FirebaseFirestore.instance.collection('users').doc('coach_en').update({emailKey : '${token.split(':')[0]}:${token.split(':')[1]}:${token.split(':')[3]}'});
      await FirebaseFirestore.instance.collection('users').doc('coach_ne').update({'${token.split(':')[0]}:${token.split(':')[1]}' : emailKey});

      await FirebaseFirestore.instance.collection(token).doc('sportsmen').set({'sportsmen' : sportsmen});
    }
  }

  Future<void> load() async {
    tables.clear();
    sportsmen.clear();

    final tablesFuture = FirebaseFirestore.instance.collection(token).doc('tables').get();
    final sportsmenFuture = FirebaseFirestore.instance.collection(token).doc('sportsmen').get();

    final results = await Future.wait([tablesFuture, sportsmenFuture]);

    final tablesSnapshot = results[0];

    final data = tablesSnapshot.data() ?? {};

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

    final sportsmenSnapshot = results[1];
    sportsmen = (sportsmenSnapshot.data()?['sportsmen'] as List?)?.cast<String>() ?? [];

  }

  Future<String> search_sportsman(String name, String surname) async {
    final all_sportsmen = await FirebaseFirestore.instance.collection('users').doc('sportsmen_ne').get();

    final data = all_sportsmen.data();
    String? email = data?['$name:$surname'];
    if (email != null) {
      return '$name:$surname:${email.replaceAll(',', '.')}:sportsman';
    } else {
      return '';
    }
  }

  Future<void> searchNotes(int cnt_day, List<String> currentSportsmen, List<List<String>> itemsByDay) async {
    var now = DateTime.now();

    // параллельно запускаем
    await Future.wait(currentSportsmen.map((curs) async {
      final snapshot = await FirebaseFirestore.instance.collection(curs).doc('tables').get();
      final data = snapshot.data() ?? {};

      for (int j = 0; j < cnt_day; ++j) {
        var cur_time = now.subtract(Duration(days: j));
        String cur_day = "${cur_time.day.toString().padLeft(2, '0')}.${cur_time.month.toString().padLeft(2, '0')}.${cur_time.year}";

        for (final key in data.keys) {
          if (key.split('_')[2] == cur_day) {
            itemsByDay[j].add('$curs&$key');
          }
        }
      }
    }));
  }
}