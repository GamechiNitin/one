import 'package:flutter/material.dart';

/// Partner brand badges (neutral wordmark placeholders).
/// Replace [BrandBadge] rendering with licensed logo assets when available.
class Brand {
  final String key, name, mark;
  final Color bg, fg;
  final bool dots;
  final double fs;
  const Brand(this.key, this.name, this.mark, this.bg, this.fg, this.fs, {this.dots = false});
}

const brands = <String, Brand>{
  'xfinity': Brand('xfinity', 'Xfinity', 'xfinity', Colors.white, Color(0xFF111827), .21),
  'peacock': Brand('peacock', 'Peacock', 'peacock', Color(0xFF0B0B0F), Colors.white, .2, dots: true),
  'sky': Brand('sky', 'Sky', 'sky', Colors.white, Color(0xFF1F3FD8), .42),
  'nbc': Brand('nbc', 'NBCUniversal', 'NBC', Colors.white, Color(0xFF111827), .3, dots: true),
  'xumo': Brand('xumo', 'Xumo', 'xumo', Colors.white, Color(0xFF111827), .28),
  'comcast': Brand('comcast', 'Comcast', 'COMCAST', Color(0xFF0B0B0F), Colors.white, .14, dots: true),
  'one': Brand('one', 'ONE', 'ONE', Colors.white, Color(0xFF1F5BFF), .3),
};
