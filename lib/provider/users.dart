import 'dart:math';

import 'package:flutter/material.dart';
import 'package:myapp/data/dummy_users.dart';
import 'package:myapp/models/user.dart';

class Users with ChangeNotifier {
  final Map<String, User> _items = {};

  List<User> get all {
    return [..._items.values];
  }

  int get count {
    return _items.length;
  }

  User byIndex(int i) {
    return _items.values.elementAt(i);
  }

  void put(User user) {
    if (user == null) {
      return;
    }

    if (user.id != null &&
        user.id!.trim().isNotEmpty &&
        _items.containsKey(user.id)) {
      _items.update(
        user.id!,
        (_) => User(
          id: user.id,
          dataDoProcedimento: user.dataDoProcedimento,
          procedimento: user.procedimento,
          observacao: user.observacao,
          arquivo: user.arquivo,
        ),
      );
    } else {
      final id = Random().nextDouble().toString();
      _items.putIfAbsent(
        id,
        () => User(
          id: id,
          dataDoProcedimento: user.dataDoProcedimento,
          procedimento: user.procedimento,
          observacao: user.observacao,
          arquivo: user.arquivo,
        ),
      );
    }

    notifyListeners();
  }

  void remove(User user) {
    if (user.id != null) {
      _items.remove(user.id);
      notifyListeners();
    }
  }
}
