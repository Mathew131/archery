import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Data {
  String tokenKey = 'auth_token';
  late String token;
  bool notification_about_update = true;
  late String minRequiredVersion;
  Map<String, List<List<List<int>>>> tables = {};

  // список: дистанция, мишень, попадания
  Map<String, List<List<List<Offset>>>> hits = {};

  // в таблице находиться индекс hits, который отвечает за ячейку или -1, если мы вводили данные с клавиатуры
  // список: дистанция, строка таблицы, мишень
  Map<String, List<List<List<Offset>>>> valueByTarget = {};
  List<String> sportsmen = [];
  List<String> coaches = [];
  String current_name = '';
  late int cnt_ser;
  late int cnt_shoot;

  // сохраняем в локальную память 
  Future<void> saveIsVisibleNotes(Map<String, bool> isVisible) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(isVisible);
    await prefs.setString('isVisibleNotes', encoded);
  }

  Future<Map<String, bool>> loadIsVisibleNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString('isVisibleNotes');
    if (encoded == null) return {};

    final Map<String, dynamic> decoded = jsonDecode(encoded);
    return decoded.map((key, value) => MapEntry(key, value == true));
  }

  // token --------------------------------------------------------

  // вызывается только в registration, когда мы первый раз заходим
  Future<void> firstSaveToken(String name, String lastname, String email, String type) async {
    final prefs = await SharedPreferences.getInstance();
    token = '$name:$lastname:$email:$type';
    await prefs.setString(tokenKey, token);

    String emailKey = token.split(':')[2].replaceAll('.', ','); // в ключе в firebase не надо точек
    String name_surname = '${token.split(':')[0]}:${token.split(':')[1]}';
    if (token.split(':')[3] == 'sportsman') {
      await FirebaseFirestore.instance.collection('users').doc('sportsmen_en').update({emailKey : name_surname});
      await FirebaseFirestore.instance.collection('users').doc('sportsmen_ne').update({name_surname : emailKey});
    } else {
      await FirebaseFirestore.instance.collection('users').doc('coaches_en').update({emailKey : name_surname});
      await FirebaseFirestore.instance.collection('users').doc('coaches_ne').update({name_surname : emailKey});
    }
  }

  Future<void> logout() async {
    tables.clear();
    sportsmen.clear();
    coaches.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, '');

    await FirebaseAuth.instance.signOut();
  }

  Future<void> saveToken(String name, String surname, String email, String type) async {
    final prefs = await SharedPreferences.getInstance();
    token = '$name:$surname:$email:$type';
    await prefs.setString(tokenKey, token);
  }

  Future<void> searchAndSaveTokenByEmail(String email) async {
    var coachData = FirebaseFirestore.instance.collection('users').doc('coaches_en').get();
    var sportsmenData = FirebaseFirestore.instance.collection('users').doc('sportsmen_en').get();
    var results = await Future.wait([coachData, sportsmenData]);
    String emailKey = email.replaceAll('.', ',');

    var coachSnapshot = results[0];
    var data_c = coachSnapshot.data() ?? {};
    String? name_surname_c = data_c?['$emailKey'];
    if (name_surname_c != null) {
      saveToken(name_surname_c.split(':')[0], name_surname_c.split(':')[1], email, 'coach');
    }


    var sportsmenSnapshot = results[1];
    var data_s = sportsmenSnapshot.data() ?? {};
    String? name_surname_s = data_s?['$emailKey'];
    if (name_surname_s != null) {
      saveToken(name_surname_s.split(':')[0], name_surname_s.split(':')[1], email, 'sportsman');
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

  // sportsmen and coaches ------------------------------------------------------

  Future<void> addSportsman(String token_s) async {
    if (!sportsmen.contains(token_s)) {
      sportsmen.add(token_s);
    }
    await FirebaseFirestore.instance.collection(token_s).doc('coaches').set({'data': FieldValue.arrayUnion([token])}, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection(token).doc('sportsmen').set({'data': FieldValue.arrayUnion([token_s])}, SetOptions(merge: true));
  }

  Future<void> removeSportsman(String token_s) async {
    sportsmen.remove(token_s);
    await FirebaseFirestore.instance.collection(token_s).doc('coaches').set({'data': FieldValue.arrayRemove([token])}, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection(token).doc('sportsmen').set({'data': FieldValue.arrayRemove([token_s])}, SetOptions(merge: true));
  }

  List<String> getCoaches() {
    return List.from(coaches);
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

  Future<void> removeUser(String _token) async {
    String email = _token.split(':')[2];
    email = email.replaceAll('.', ',');
    if (_token.split(':')[3] == 'sportsman') {
      await FirebaseFirestore.instance.collection('users').doc('sportsmen_en').update({email: FieldValue.delete(),});
      await FirebaseFirestore.instance.collection('users').doc('sportsmen_ne').update({'${_token.split(':')[0]}:${_token.split(':')[1]}': FieldValue.delete(),});

      DocumentSnapshot  doc = await FirebaseFirestore.instance.collection(_token).doc('coaches').get();
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      for (var token_c in data['data']) {
        await FirebaseFirestore.instance.collection(token_c).doc('sportsmen').set({'data': FieldValue.arrayRemove([_token])}, SetOptions(merge: true));
      }
    } else {
      await FirebaseFirestore.instance.collection('users').doc('coaches_en').update({email: FieldValue.delete(),});
      await FirebaseFirestore.instance.collection('users').doc('coaches_ne').update({'${_token.split(':')[0]}:${_token.split(':')[1]}': FieldValue.delete(),});

      DocumentSnapshot  doc = await FirebaseFirestore.instance.collection(_token).doc('sportsmen').get();
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      for (var token_s in data['data']) {
        await FirebaseFirestore.instance.collection(token_s).doc('coaches').set({'data': FieldValue.arrayRemove([_token])}, SetOptions(merge: true));
      }
    }

    final collection = FirebaseFirestore.instance.collection(_token);
    final snapshots = await collection.get();

    for (final doc in snapshots.docs) {
      await doc.reference.delete();
    }

    // этот код удаляет только данные пользователя из Firestore, но не удаляет сам аккаунт из Firebase Authentication.
    // Это необходимо сделать вручную.

    logout();
  }

  // tables ------------------------------------------------------

  Future<void> removeTable(String name_note) async {
    tables.remove(name_note);
    hits.remove(name_note);
    valueByTarget.remove(name_note);
    FirebaseFirestore.instance.collection('tables').doc(name_note).delete();
    await save();
  }

  Future<void> renameTable(String old_name_note, String new_name_note) async {
    if (new_name_note != old_name_note) {
      tables[new_name_note] = tables[old_name_note]!
          .map((table) => table
          .map((row) => List<int>.from(row))
          .toList())
          .toList();
      tables.remove(old_name_note);

      hits[new_name_note] = hits[old_name_note]!
          .map((list2) => list2
          .map((list1) => list1
          .map((o) => Offset(o.dx, o.dy))
          .toList())
          .toList())
          .toList();
      hits.remove(old_name_note);

      valueByTarget[new_name_note] = valueByTarget[old_name_note]!
          .map((list2) => list2
          .map((list1) => list1
          .map((o) => Offset(o.dx, o.dy))
          .toList())
          .toList())
          .toList();
      valueByTarget.remove(old_name_note);
    }

    await save();
  }

  Future<void> createTable(String name_note) async {
    if (name_note.split('_')[1] == '12м  ' || name_note.split('_')[1] == '18м  ') {
      cnt_ser = 10;
      cnt_shoot = 3;
    } else {
      cnt_ser = 6;
      cnt_shoot = 6;
    }

    tables[name_note] = List.generate(2, (_) => List.generate(cnt_ser, (_) => List.filled(cnt_shoot+2, -1)));
    hits[name_note] = [[[], [], []], [[], [], []]];
    valueByTarget[name_note] = List.generate(2, (_) => List.generate(10, (_) => List.filled(6, Offset(-1, -1))));
    await save();
  }

  List<List<List<int>>> getTable(String name_note) {
    return tables[name_note]!; // передаем ссылку
  }

  List<String> getNotes() {
    var keys_in_order = tables.keys.toList();
    keys_in_order.sort((a, b) => int.parse(b.split('_')[3]).compareTo(int.parse(a.split('_')[3])));
    return keys_in_order;
  }

  // ----------------------------------

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

  // ----------------------------------

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

  List offsetListToJson(List<List<List<Offset>>>? list) {
    if (list == null) return [];
    return list
        .map((l2) => l2
        .map((l1) => l1.map((o) => {'dx': o.dx, 'dy': o.dy}).toList())
        .toList())
        .toList();
  }

  List<List<List<Offset>>> offsetListFromJson(dynamic list) {
    return (list as List)
        .map((l2) => (l2 as List)
        .map((l1) => (l1 as List)
        .map((o) => Offset(o['dx'], o['dy']))
        .toList())
        .toList())
        .toList();
  }

  // самое важное ----------------------------------------------------------------
  Future<void> save() async {
    final data = <String, String>{};
    final oldKeys = List<String>.from(tables.keys);


    for (final key in oldKeys) {
      // hits[key] = [[[], [], []], [[], [], []]];
      // valueByTarget[key] = List.generate(2, (_) => List.generate(10, (_) => List.filled(6, Offset(-1, -1))));

      var lw0 = lastWriteElem(0, key);
      var lw1 = lastWriteElem(1, key);
      var rg0 = rg(0, key);
      var rg1 = rg(1, key);

      String newKey = '${key.split('_')[0]}_${key.split('_')[1]}_${key.split('_')[2]}_${key.split('_')[3]}_${lw0}_${lw1}_${rg0}_${rg1}';
      // data[newKey] = jsonEncode(tables[key]); // раньше
      data[newKey] = jsonEncode([
        tables[key],
        offsetListToJson(hits[key]),
        offsetListToJson(valueByTarget[key])
      ]);


      if (key != newKey) {
        if (key == current_name) {
          current_name = newKey;
        }
        tables[newKey] = tables[key]!
            .map((table) => table.map((row) => List<int>.from(row)).toList())
            .toList();
        tables.remove(key);

        hits[newKey] = hits[key]!
            .map((list2) => list2
            .map((list1) => list1
            .map((offset) => Offset(offset.dx, offset.dy))
            .toList())
            .toList())
            .toList();
        hits.remove(key);

        valueByTarget[newKey] = valueByTarget[key]!
            .map((list2) => list2
            .map((list1) => list1
            .map((offset) => Offset(offset.dx, offset.dy))
            .toList())
            .toList())
            .toList();
        valueByTarget.remove(key);
      }
    }

    await FirebaseFirestore.instance.collection(token).doc('tables').set(data);
  }


  Future<void> load() async {
    tables.clear();
    sportsmen.clear();
    coaches.clear();

    minRequiredVersion = (await FirebaseFirestore.instance.collection('version').doc('minRequiredVersion').get()).data()?['data'] as String;

    final tablesFuture = FirebaseFirestore.instance.collection(token).doc('tables').get();
    final sportsmenFuture = FirebaseFirestore.instance.collection(token).doc('sportsmen').get();
    final coachesFuture = FirebaseFirestore.instance.collection(token).doc('coaches').get();

    final results = await Future.wait([tablesFuture, sportsmenFuture, coachesFuture]);

    final tablesSnapshot = results[0];

    final data = tablesSnapshot.data() ?? {};


    for (final key in data.keys) {
      final encoded = data[key] as String;
      final decoded = jsonDecode(encoded);

      List<List<List<int>>> table;
      List<List<List<Offset>>> hitsList;
      List<List<List<Offset>>> valueList;

      // Новый формат — список из 3 элементов: [tables, hits, valueByTarget]
      if (decoded.length == 3) {
        table = (decoded[0] as List)
            .map((l2) => (l2 as List)
            .map((l1) => List<int>.from(l1 as List))
            .toList())
            .toList();

        hitsList = (decoded[1] as List)
            .map((l2) => (l2 as List)
            .map((l1) => (l1 as List)
            .map((o) => Offset(o['dx'], o['dy']))
            .toList())
            .toList())
            .toList();

        valueList = (decoded[2] as List)
            .map((l2) => (l2 as List)
            .map((l1) => (l1 as List)
            .map((o) => Offset(o['dx'], o['dy']))
            .toList())
            .toList())
            .toList();
      } else { // Старый формат — просто table (List<List<List<int>>>). decoded.length = 2, т.к. 2 дистанции
        table = (decoded as List)
            .map((l2) => (l2 as List)
            .map((l1) => List<int>.from(l1 as List))
            .toList())
            .toList();

        hitsList = [[[], [], []], [[], [], []]];
        valueList = List.generate(2, (_) => List.generate(10, (_) => List.filled(6, Offset(-1, -1))));
      }
      tables[key] = table;
      hits[key] = hitsList;
      valueByTarget[key] = valueList;
    }




    final sportsmenSnapshot = results[1];
    sportsmen = (sportsmenSnapshot.data()?['data'] as List?)?.cast<String>() ?? [];

    final coachesSnapshot = results[2];
    coaches = (coachesSnapshot.data()?['data'] as List?)?.cast<String>() ?? [];
  }
}