class StringClass {
  String toCapitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

final stringClass = StringClass();
