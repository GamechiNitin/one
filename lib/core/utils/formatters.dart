/// Indian-grouped currency, e.g. 123456 -> ₹1,23,456.
String rs(num n) {
  final s = n.round().toString();
  if (s.length <= 3) return '\u20B9$s';
  final last3 = s.substring(s.length - 3);
  final rest = s.substring(0, s.length - 3);
  final b = StringBuffer();
  for (var i = 0; i < rest.length; i++) {
    if (i > 0 && (rest.length - i) % 2 == 0) b.write(',');
    b.write(rest[i]);
  }
  return '\u20B9${b.toString()},$last3';
}

/// Number with Indian grouping and no currency symbol.
String nf(int n) => rs(n).substring(1);
