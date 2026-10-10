import 'package:equatable/equatable.dart';

/// Procedural poster description. Colors are ARGB ints so the domain stays UI-free.
class Art extends Equatable {
  final String type;
  final List<int> colors;
  const Art(this.type, this.colors);

  factory Art.fromJson(Map<String, dynamic> j) =>
      Art(j['type'] as String, (j['colors'] as List).map((e) => (e as num).toInt()).toList());

  Map<String, dynamic> toJson() => {'type': type, 'colors': colors};

  @override
  List<Object?> get props => [type, colors];
}
