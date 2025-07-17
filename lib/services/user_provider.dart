import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  dynamic _user;

  dynamic get user => _user;

  void setUser(dynamic user) {
    _user = user;
    notifyListeners();
  }
}
